local addonName, addon = ...
_G.BeastCollector = addon

-- ============================================================================
-- BeastCollector — Core.lua
-- Ядро аддона:
--   1. Индексация 61 семейства, специализаций, фолиантов и 2 635 моделей зверей
--   2. Авто-сканирование стойл охотника (C_StableInfo: creatureID + displayID)
--   3. Проверка изученных фолиантов приручения (C_QuestLog.IsQuestFlaggedCompleted)
--   4. Навигация: TomTom + нативная путевая точка Blizzard (C_Map / SuperTrack)
--   5. Интеграция в тултипы зверей в мире (с защитой от WoW 12.1.5 Secret Value)
-- ============================================================================

local function SafeNotSecret(val)
    if val == nil then return false end
    if _G.issecretvalue and _G.issecretvalue(val) then
        return false
    end
    return true
end
addon.SafeNotSecret = SafeNotSecret

addon.FamilyByID = {}
addon.BeastByID = {}
addon.BeastByNpcID = {}
addon.BeastByDisplayID = {}

function addon:GetBeastTomes(beast)
    local res = {}
    if not beast then return res end

    local function addTome(key)
        if not key then return end
        for _, k in ipairs(res) do
            if k == key then return end
        end
        table.insert(res, key)
    end

    if beast.id == "spiritbeast_dreamowl_fire" or beast.lookID == "dreamowl_fire" then
        addTome("NAHQI")
    end

    local mgTomes = self.ModelGroupTomes and beast.modelGroup and self.ModelGroupTomes[beast.modelGroup]
    if mgTomes then
        for _, tKey in ipairs(mgTomes) do
            addTome(tKey)
        end
    end

    local lid = string.lower(beast.lookID or beast.id or "")
    if string.find(lid, "diseased", 1, true)
        or string.find(lid, "undead", 1, true)
        or string.find(lid, "plague", 1, true)
        or string.find(lid, "skeletal", 1, true)
        or string.find(lid, "zombie", 1, true)
    then
        addTome("UNDEAD")
    end

    if #res == 0 then
        local fam = self.FamilyByID and self.FamilyByID[beast.family]
        if fam and fam.tome and beast.family ~= "stonehound" then
            addTome(fam.tome)
        end
    end

    return res
end

function addon:BuildIndices()
    wipe(self.FamilyByID)
    wipe(self.BeastByID)
    wipe(self.BeastByNpcID)
    wipe(self.BeastByDisplayID)

    if self.TamingTomes then
        for _, tome in pairs(self.TamingTomes) do
            tome.beastCount = 0
        end
    end

    for idx, fam in ipairs(self.Families or {}) do
        fam.order = idx
        self.FamilyByID[fam.id] = fam
    end

    for idx, beast in ipairs(self.Beasts or {}) do
        beast.order = idx
        self.BeastByID[beast.id] = beast
        if self.ModelGroupRuNames and beast.modelGroup and self.ModelGroupRuNames[beast.modelGroup] then
            beast.ruModelGroup = self.ModelGroupRuNames[beast.modelGroup]
            if beast.subTitle and not string.find(beast.subTitle, beast.ruModelGroup, 1, true) then
                beast.subTitle = beast.ruModelGroup .. " • " .. beast.subTitle
            elseif not beast.subTitle then
                beast.subTitle = beast.ruModelGroup
            end
        end
        beast.tomes = self:GetBeastTomes(beast)
        if self.TamingTomes and beast.tomes then
            for _, tKey in ipairs(beast.tomes) do
                local tDef = self.TamingTomes[tKey]
                if tDef then
                    tDef.beastCount = (tDef.beastCount or 0) + 1
                end
            end
        end
        if beast.npcID then
            self.BeastByNpcID[beast.npcID] = beast
        end
        if beast.npcIDs then
            for _, nid in ipairs(beast.npcIDs) do
                if not self.BeastByNpcID[nid] then
                    self.BeastByNpcID[nid] = beast
                end
            end
        end
        if beast.displayID then
            self.BeastByDisplayID[beast.displayID] = beast
        end
    end
end

function addon:InitDB()
    if type(_G.BeastCollectorDB) ~= "table" then
        _G.BeastCollectorDB = {}
    end
    local db = _G.BeastCollectorDB
    db.stabledByCreatureID = db.stabledByCreatureID or {}
    db.stabledByDisplay = db.stabledByDisplay or {}
    db.stabledByName = db.stabledByName or {}
    db.manualCollected = db.manualCollected or {}
    db.manualTomes = db.manualTomes or {}
    -- Аня уже выбила и изучила «Испытания охотника на флорафавнов» в Харандаре:
    if db.manualTomes["FLORAFAUN"] == nil then
        db.manualTomes["FLORAFAUN"] = true
    end
    db.minimap = db.minimap or { hide = false }
    db.settings = db.settings or {
        showUnitTooltips = true,
        onlyUncollected = false,
    }
    self.db = db

    -- Предзагрузка данных предметов-фолиантов в кэш клиента для чтения их тултипов и спеллов
    if C_Item and C_Item.RequestLoadItemDataByID and self.TamingTomes then
        for _, tome in pairs(self.TamingTomes) do
            if tome.itemID then
                pcall(C_Item.RequestLoadItemDataByID, tome.itemID)
            end
        end
    end
end

-- ============================================================================
-- ПРОВЕРКА ФОЛИАНТОВ ПРИРУЧЕНИЯ (КНИГ НАВЫКОВ)
-- ============================================================================
function addon:IsTomeLearned(tomeKey)
    if not tomeKey then return true, nil end
    local tome = self.TamingTomes and self.TamingTomes[tomeKey]
    if not tome then return true, nil end

    -- 1. Ручной флаг (если явно включён или выключен пользователем)
    if self.db and self.db.manualTomes then
        if self.db.manualTomes[tomeKey] == true then
            return true, tome
        elseif self.db.manualTomes[tomeKey] == false then
            return false, tome
        end
    end

    -- 2. Расовый врождённый навык
    local _, raceFile = UnitRace("player")
    if tome.autoRaces and raceFile and tome.autoRaces[raceFile] then
        return true, tome
    end

    -- 3. Проверка пассивного заклинания навыка (напрямую и через спелл предмета)
    local function CheckSpellKnown(sID)
        if not sID then return false end
        if _G.IsPlayerSpell and IsPlayerSpell(sID) then return true end
        if _G.IsSpellKnown and IsSpellKnown(sID) then return true end
        if C_SpellBook and C_SpellBook.IsSpellKnown and C_SpellBook.IsSpellKnown(sID) then return true end
        return false
    end

    if CheckSpellKnown(tome.spellID) then
        return true, tome
    end

    if tome.itemID and C_Item and C_Item.GetItemSpell then
        local _, itemSpellID = C_Item.GetItemSpell(tome.itemID)
        if CheckSpellKnown(itemSpellID) then
            return true, tome
        end
    end

    -- 4. Проверка скрытых трекинг-квестов Blizzard (основной + альтернативные ID)
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
        if tome.questID and C_QuestLog.IsQuestFlaggedCompleted(tome.questID) then
            return true, tome
        end
        if tome.questIDs then
            for _, qID in ipairs(tome.questIDs) do
                if C_QuestLog.IsQuestFlaggedCompleted(qID) then
                    return true, tome
                end
            end
        end
    end

    -- 5. Сканирование тултипа предмета через C_TooltipInfo на предмет строки «Уже известно» (ITEM_SPELL_KNOWN)
    if tome.itemID and C_TooltipInfo and C_TooltipInfo.GetItemByID then
        local ok, tipData = pcall(C_TooltipInfo.GetItemByID, tome.itemID)
        if ok and tipData and type(tipData.lines) == "table" then
            local knownPattern = _G.ITEM_SPELL_KNOWN or "Уже известно"
            for _, line in ipairs(tipData.lines) do
                local lt = line.leftText
                if SafeNotSecret(lt) and type(lt) == "string" then
                    if string.find(lt, knownPattern, 1, true)
                        or string.find(lt, "Уже известно", 1, true)
                        or string.find(lt, "Already known", 1, true)
                    then
                        return true, tome
                    end
                end
            end
        end
    end

    -- 6. Авто-вывод из стойл: если у охотника в стойлах уже приручен зверь, требующий этот фолиант!
    if self.db and self.Beasts then
        for _, beast in ipairs(self.Beasts) do
            if beast.tomes then
                for _, reqKey in ipairs(beast.tomes) do
                    if reqKey == tomeKey then
                        local inStables = (beast.npcID and self.db.stabledByCreatureID[beast.npcID])
                            or (beast.displayID and self.db.stabledByDisplay[beast.displayID])
                        if not inStables and beast.npcIDs then
                            for _, nid in ipairs(beast.npcIDs) do
                                if self.db.stabledByCreatureID[nid] then
                                    inStables = true
                                    break
                                end
                            end
                        end
                        if inStables then
                            return true, tome
                        end
                    end
                end
            end
        end
    end

    return false, tome
end

function addon:ToggleManualTome(tomeKey)
    if not tomeKey or not self.db then return end
    self.db.manualTomes = self.db.manualTomes or {}
    local currentlyLearned = self:IsTomeLearned(tomeKey)
    if currentlyLearned then
        self.db.manualTomes[tomeKey] = false
    else
        self.db.manualTomes[tomeKey] = true
    end
    if self.RefreshUI then
        self:RefreshUI()
    end
end

function addon:GetTomeProgress()
    local learnedCount, totalCount = 0, 0
    for _, tKey in ipairs(self.TamingTomesOrder or {}) do
        totalCount = totalCount + 1
        if self:IsTomeLearned(tKey) then
            learnedCount = learnedCount + 1
        end
    end
    return learnedCount, totalCount
end

-- ============================================================================
-- АВТО-СКАНИРОВАНИЕ СТОЙЛ ОХОТНИКА (C_StableInfo + Активный питомец)
-- ============================================================================
function addon:ScanHunterStables()
    if not self.db then return end

    local function RecordPetInfo(petInfo)
        if type(petInfo) ~= "table" then return end
        local cID = petInfo.creatureID
        local dID = petInfo.displayID or petInfo.modelID
        local pName = petInfo.name or "Питомец"
        local famName = petInfo.familyName or ""
        local safeName = (SafeNotSecret(pName) and pName ~= "") and pName or "Питомец"
        local safeFam = SafeNotSecret(famName) and famName or ""

        if cID and SafeNotSecret(cID) and cID > 0 then
            self.db.stabledByCreatureID[cID] = {
                name = safeName,
                familyName = safeFam,
                slotID = petInfo.slotID,
            }
        end
        if dID and SafeNotSecret(dID) and dID > 0 then
            self.db.stabledByDisplay[dID] = {
                name = safeName,
                familyName = safeFam,
                slotID = petInfo.slotID,
            }
        end
    end

    if C_StableInfo then
        if C_StableInfo.GetActivePetList then
            local ok, list = pcall(C_StableInfo.GetActivePetList)
            if ok and type(list) == "table" then
                for _, petInfo in ipairs(list) do
                    RecordPetInfo(petInfo)
                end
            end
        end
        if C_StableInfo.GetStabledPetList then
            local ok, list = pcall(C_StableInfo.GetStabledPetList)
            if ok and type(list) == "table" then
                for _, petInfo in ipairs(list) do
                    RecordPetInfo(petInfo)
                end
            end
        end
        if C_StableInfo.GetStablePetInfo then
            for slot = 1, 205 do
                local ok, petInfo = pcall(C_StableInfo.GetStablePetInfo, slot)
                if ok and petInfo then
                    RecordPetInfo(petInfo)
                end
            end
        end
    end

    if UnitExists("pet") then
        local guid = UnitGUID("pet")
        if SafeNotSecret(guid) and type(guid) == "string" then
            local unitType, _, _, _, _, npcIDStr = strsplit("-", guid)
            if unitType == "Pet" or unitType == "Creature" then
                local cID = tonumber(npcIDStr)
                local petName = UnitName("pet")
                if cID and cID > 0 then
                    self.db.stabledByCreatureID[cID] = {
                        name = (SafeNotSecret(petName) and petName) or "Активный питомец",
                    }
                end
            end
        end
    end

    if self.RefreshUI then
        self:RefreshUI()
    end
end

function addon:IsBeastCollected(beast)
    if not beast or not self.db then return false, nil end

    if self.db.manualCollected[beast.id] then
        return true, "Отмечено в твоей коллекции"
    end

    if beast.npcID and self.db.stabledByCreatureID[beast.npcID] then
        local info = self.db.stabledByCreatureID[beast.npcID]
        return true, string.format("В стойлах: %s", info.name or beast.name)
    end

    if beast.npcIDs then
        for _, nid in ipairs(beast.npcIDs) do
            local info = self.db.stabledByCreatureID[nid]
            if info then
                return true, string.format("В стойлах: %s", info.name or beast.name)
            end
        end
    end

    if beast.displayID and self.db.stabledByDisplay[beast.displayID] then
        local info = self.db.stabledByDisplay[beast.displayID]
        return true, string.format("В стойлах: %s", info.name or beast.name)
    end

    return false, nil
end

function addon:ToggleManualCollected(beast)
    if not beast or not self.db then return end
    if self.db.manualCollected[beast.id] then
        self.db.manualCollected[beast.id] = nil
    else
        self.db.manualCollected[beast.id] = true
    end
    if self.RefreshUI then
        self:RefreshUI()
    end
end

function addon:GetCollectionProgress(familyID, specID)
    local collected, total = 0, 0
    for _, beast in ipairs(self.Beasts or {}) do
        local fam = self.FamilyByID and self.FamilyByID[beast.family]
        local matchFam = (not familyID or familyID == "ALL" or beast.family == familyID)
        local matchSpec = (not specID or specID == "ALL" or (fam and fam.spec == specID))
        if matchFam and matchSpec then
            total = total + 1
            if self:IsBeastCollected(beast) then
                collected = collected + 1
            end
        end
    end
    return collected, total
end

-- ============================================================================
-- МНОГОШАГОВЫЙ НАВИГАТОР ПО ПОРТАЛАМ И ВЫХОДАМ ИЗ ЗОН (Minimap Arrow + TomTom)
-- Ведёт стрелочкой на миникарте к выходу из текущей зоны -> через портал в столицу
-- -> через портал в целевой континент -> к зверю или фолианту!
-- ============================================================================
addon.activePortalRoute = nil
addon.portalTomTomUids = {}

local function GetMapAncestry(mapID)
    local chain = {}
    local visited = {}
    local cur = mapID
    while cur and cur > 0 and not visited[cur] do
        visited[cur] = true
        table.insert(chain, cur)
        local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(cur)
        cur = info and info.parentMapID or nil
    end
    return chain, visited
end

local function GetMapInstanceID(mapID)
    if not mapID or not C_Map or not C_Map.GetWorldPosFromMapPos or not _G.CreateVector2D then
        return nil
    end
    local ok, instID = pcall(C_Map.GetWorldPosFromMapPos, mapID, CreateVector2D(0.5, 0.5))
    if ok and instID then
        return instID
    end
    return nil
end

-- Определяет макро-регион / аддон для маршрутизации через Зал Порталов
local function GetMapMacroRegion(mapID)
    if not mapID then return "UNKNOWN" end
    local _, ancestors = GetMapAncestry(mapID)

    -- Изолированные подзоны, требующие отдельного выхода:
    if mapID == 2413 or ancestors[2413] then return "HARANDAR" end
    if mapID == 2405 or ancestors[2405] then return "VOIDSTORM" end
    if mapID == 2200 or ancestors[2200] then return "EMERALD_DREAM" end
    if mapID == 2133 or ancestors[2133] then return "ZARALEK" end

    -- Midnight (Кель'Талас / Луносвет / Зул'Аман)
    if mapID == 2393 or mapID == 2395 or mapID == 2437 or ancestors[2393] or ancestors[2395] or ancestors[2437] or ancestors[2424] then
        return "MIDNIGHT_QUELTHALAS"
    end
    -- Каз Алгар (TWW)
    if mapID == 2339 or ancestors[2274] or ancestors[2248] or ancestors[2214] or ancestors[2215] or ancestors[2255] then
        return "KHAZ_ALGAR"
    end
    -- Драконьи острова (Dragonflight)
    if mapID == 2112 or ancestors[1978] or ancestors[2022] or ancestors[2023] or ancestors[2024] or ancestors[2025] or ancestors[2151] then
        return "DRAGON_ISLES"
    end
    -- Темные Земли (Shadowlands)
    if mapID == 1670 or ancestors[1550] or ancestors[1525] or ancestors[1533] or ancestors[1536] or ancestors[1565] or ancestors[1543] or ancestors[1970] then
        return "SHADOWLANDS"
    end
    -- Зандалар и Кул-Тирас (BfA)
    if mapID == 1165 or ancestors[875] or ancestors[862] or ancestors[863] or ancestors[864] then
        return "ZANDALAR"
    end
    if mapID == 1161 or ancestors[876] or ancestors[895] or ancestors[896] or ancestors[942] then
        return "KUL_TIRAS"
    end
    -- Расколотые острова и Аргус (Legion)
    if mapID == 627 or ancestors[619] or ancestors[630] or ancestors[641] or ancestors[650] or ancestors[634] or ancestors[680] or ancestors[646] then
        return "BROKEN_ISLES"
    end
    if ancestors[905] or mapID == 830 or mapID == 882 or mapID == 885 then
        return "ARGUS"
    end
    -- Дренор (WoD)
    if ancestors[572] then
        return "DRAENOR"
    end
    -- Пандария (MoP — включая Остров Великанов 507, Нефритовый лес 371 и др.)
    if ancestors[424] or mapID == 371 or mapID == 507 or mapID == 504 or mapID == 554 or mapID == 376 or mapID == 379 or mapID == 388 or mapID == 390 or mapID == 418 or mapID == 422 then
        return "PANDARIA"
    end
    -- Расколотый мир Запределья (TBC)
    if ancestors[101] or mapID == 111 then
        return "OUTLAND"
    end
    -- Нордскол (WotLK)
    if ancestors[113] or mapID == 125 then
        return "NORTHREND"
    end
    -- Калимдор и Восточные королевства
    if ancestors[12] or mapID == 85 then
        return "KALIMDOR"
    end
    if ancestors[13] or mapID == 84 then
        return "EASTERN_KINGDOMS"
    end
    return "OTHER_" .. tostring(mapID)
end

-- Живое сканирование карты (C_Map.GetMapLinksForMap и C_AreaPoiInfo.GetAreaPOIForMap)
-- для поиска точных координат выхода из зоны или портала на текущей карте игрока!
local function FindDynamicExitOrPortalOnMap(mapID, preferredKeywords)
    if not mapID then return nil end

    -- 1. Проверяем C_AreaPoiInfo (иконки порталов и телепортов на карте)
    if C_AreaPoiInfo and C_AreaPoiInfo.GetAreaPOIForMap and C_AreaPoiInfo.GetAreaPOIInfo then
        local ok, poiIDs = pcall(C_AreaPoiInfo.GetAreaPOIForMap, mapID)
        if ok and type(poiIDs) == "table" then
            local bestMatch = nil
            for _, poiID in ipairs(poiIDs) do
                local okInfo, info = pcall(C_AreaPoiInfo.GetAreaPOIInfo, mapID, poiID)
                if okInfo and info and info.position then
                    local nameLow = string.lower((SafeNotSecret(info.name) and info.name) or "")
                    local descLow = string.lower((SafeNotSecret(info.description) and info.description) or "")
                    local atlasLow = string.lower((SafeNotSecret(info.atlasName) and info.atlasName) or "")
                    local combined = nameLow .. " " .. descLow .. " " .. atlasLow
                    local x, y = info.position:GetXY()
                    if x and y and x > 0 and y > 0 then
                        if preferredKeywords then
                            for _, kw in ipairs(preferredKeywords) do
                                if string.find(combined, kw, 1, true) then
                                    return x * 100, y * 100, (SafeNotSecret(info.name) and info.name) or "Портал / Выход"
                                end
                            end
                        end
                        if string.find(combined, "portal", 1, true)
                            or string.find(combined, "портал", 1, true)
                            or string.find(combined, "teleporter", 1, true)
                            or string.find(combined, "телепорт", 1, true)
                            or string.find(combined, "waygate", 1, true)
                            or string.find(combined, "оргриммар", 1, true)
                            or string.find(combined, "штормград", 1, true)
                            or string.find(combined, "луносвет", 1, true)
                            or string.find(combined, "silvermoon", 1, true)
                        then
                            bestMatch = { x = x * 100, y = y * 100, note = (SafeNotSecret(info.name) and info.name) or "Портал" }
                        end
                    end
                end
            end
            if bestMatch then
                return bestMatch.x, bestMatch.y, bestMatch.note
            end
        end
    end

    -- 2. Проверяем C_Map.GetMapLinksForMap (стрелочки переходов и выходов из зон на карте Blizzard)
    if C_Map and C_Map.GetMapLinksForMap then
        local ok, links = pcall(C_Map.GetMapLinksForMap, mapID)
        if ok and type(links) == "table" and #links > 0 then
            for _, link in ipairs(links) do
                if link.position then
                    local x, y = link.position:GetXY()
                    local linkName = (SafeNotSecret(link.name) and link.name) or "Выход из зоны"
                    if x and y and x > 0 and y > 0 then
                        return x * 100, y * 100, "Выход: " .. linkName
                    end
                end
            end
        end
    end

    return nil
end

-- Проецирует координаты в родительскую карту, если текущая карта (например, город) не принимает пины напрямую
local function ResolvePinnableMapCoords(mapID, normX, normY)
    if not mapID or not C_Map or not C_Map.CanSetUserWaypointOnMap then
        return mapID, normX, normY
    end
    local ok, canSet = pcall(C_Map.CanSetUserWaypointOnMap, mapID)
    if ok and canSet then
        return mapID, normX, normY
    end
    if not C_Map.GetMapInfo or not C_Map.GetWorldPosFromMapPos or not C_Map.GetMapPosFromWorldPos or not _G.CreateVector2D then
        return mapID, normX, normY
    end
    local curMap = mapID
    for _ = 1, 5 do
        local info = C_Map.GetMapInfo(curMap)
        if not info or not info.parentMapID or info.parentMapID == 0 then break end
        local parentID = info.parentMapID
        local okP, canParent = pcall(C_Map.CanSetUserWaypointOnMap, parentID)
        if okP and canParent then
            local okW, instID, worldPos = pcall(C_Map.GetWorldPosFromMapPos, mapID, CreateVector2D(normX, normY))
            if okW and instID and worldPos then
                local okM, _, parentPos = pcall(C_Map.GetMapPosFromWorldPos, instID, worldPos, parentID)
                if okM and parentPos then
                    local px, py = parentPos:GetXY()
                    if px and py and px > 0 and px < 1 and py > 0 and py < 1 then
                        return parentID, px, py
                    end
                end
            end
        end
        curMap = parentID
    end
    return mapID, normX, normY
end

-- Ставит активную точку Blizzard (SuperTrack) + стрелку TomTom для ТЕКУЩЕГО шага маршрута
function addon:ActivateCurrentRouteStep()
    local route = self.activePortalRoute
    if not route or not route.steps or #route.steps == 0 then return end

    local step = route.steps[route.currentStep] or route.steps[#route.steps]
    if not step then return end

    -- Очищаем старые промежуточные стрелки TomTom
    if _G.TomTom and _G.TomTom.RemoveWaypoint and self.portalTomTomUids then
        for _, uid in ipairs(self.portalTomTomUids) do
            pcall(_G.TomTom.RemoveWaypoint, _G.TomTom, uid)
        end
        wipe(self.portalTomTomUids)
    end

    local totalSteps = #route.steps
    local stepLabel = totalSteps > 1
        and string.format("[Шаг %d/%d] %s", route.currentStep, totalSteps, step.note or route.targetName)
        or string.format("BeastCollector: %s (%s)", route.targetName, step.note or "")

    -- 1. Ставим стрелку TomTom на текущий шаг (и на финальную цель, если мы ещё в пути)
    if _G.TomTom and _G.TomTom.AddWaypoint then
        local ok, uid = pcall(_G.TomTom.AddWaypoint, _G.TomTom, step.mapID, step.x / 100, step.y / 100, {
            title = stepLabel,
            persistent = false,
            minimap = true,
            world = true,
            crazy = true,
        })
        if ok and uid then
            table.insert(self.portalTomTomUids, uid)
            if _G.TomTom.SetCrazyArrow then
                pcall(_G.TomTom.SetCrazyArrow, _G.TomTom, uid, 15, stepLabel)
            end
        end
    end

    -- 2. Ставим нативную путевую точку Blizzard (с проекцией на родительскую карту, если нужно)
    --    и принудительно включаем стрелочку миникарты (C_SuperTrack.SetSuperTrackedUserWaypoint)!
    if C_Map and C_Map.SetUserWaypoint and _G.UiMapPoint and _G.UiMapPoint.CreateFromCoordinates then
        local pinMapID, pinX, pinY = ResolvePinnableMapCoords(step.mapID, step.x / 100, step.y / 100)
        local okCan, canSet = pcall(C_Map.CanSetUserWaypointOnMap, pinMapID)
        if not okCan or canSet then
            local uiPt = UiMapPoint.CreateFromCoordinates(pinMapID, pinX, pinY)
            pcall(C_Map.SetUserWaypoint, uiPt)
            if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
                pcall(C_SuperTrack.SetSuperTrackedUserWaypoint, true)
                C_Timer.After(0.08, function()
                    if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
                        pcall(C_SuperTrack.SetSuperTrackedUserWaypoint, true)
                    end
                end)
            end
        end
    end

    local mapInfo = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(step.mapID)
    local zoneName = (mapInfo and SafeNotSecret(mapInfo.name) and mapInfo.name) or step.zone or "Локация"
    if totalSteps > 1 then
        print(string.format(
            "|cff00ff96[BeastCollector Маршрут %d/%d]|r Стрелка миникарты ведёт: |cffffd100%s|r — |cff00ccff%s (%.1f, %.1f)|r",
            route.currentStep, totalSteps, step.note or route.targetName, zoneName, step.x, step.y
        ))
    else
        print(string.format(
            "|cff00ff96[BeastCollector]|r Проложен путь к |cffffd100%s|r: |cff00ccff%s (%.1f, %.1f)|r%s",
            route.targetName, zoneName, step.x, step.y, step.note and (" — " .. step.note) or ""
        ))
    end
end

-- Проверяет при смене зоны или движении, не перешёл ли игрок на следующий шаг маршрута
function addon:CheckPortalRouteProgress()
    local route = self.activePortalRoute
    if not route or not route.steps or route.currentStep >= #route.steps then return end

    local playerMapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    if not playerMapID then return end

    local playerRegion = GetMapMacroRegion(playerMapID)
    local playerInstID = GetMapInstanceID(playerMapID)
    local finalStep = route.steps[#route.steps]
    local finalRegion = GetMapMacroRegion(finalStep.mapID)
    local finalInstID = GetMapInstanceID(finalStep.mapID)

    -- 1. Если игрок уже в целевой зоне или на том же континенте, что и финальная цель (и это не изолированная пещера)
    if playerMapID == finalStep.mapID
        or (playerRegion == finalRegion and finalRegion ~= "HARANDAR" and finalRegion ~= "VOIDSTORM" and finalRegion ~= "EMERALD_DREAM")
        or (playerInstID and finalInstID and playerInstID == finalInstID and playerRegion == finalRegion)
    then
        route.currentStep = #route.steps
        self:ActivateCurrentRouteStep()
        return
    end

    -- 2. Ищем самый дальний шаг маршрута, в регионе или карте которого сейчас оказался игрок
    for i = #route.steps, route.currentStep + 1, -1 do
        local st = route.steps[i]
        local stRegion = GetMapMacroRegion(st.mapID)
        if playerMapID == st.mapID or playerRegion == stRegion then
            route.currentStep = i
            -- Если на новой карте есть динамический портал/выход, уточним координаты
            if i < #route.steps and st.dynamicScan then
                local dx, dy, dnote = FindDynamicExitOrPortalOnMap(playerMapID, st.keywords)
                if dx and dy then
                    st.mapID = playerMapID
                    st.x = dx
                    st.y = dy
                    if dnote and not st.keepNote then st.note = dnote end
                end
            end
            self:ActivateCurrentRouteStep()
            return
        end
    end
end

-- Строит цепочку шагов (выход из зоны -> портал в столицу -> портал в нужный континент -> цель)
function addon:BuildMultiHopRoute(targetMapID, targetX, targetY, targetName, targetZone, targetNote)
    local steps = {}
    local playerMapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    if not playerMapID or playerMapID == targetMapID then
        table.insert(steps, {
            mapID = targetMapID,
            x = targetX,
            y = targetY,
            zone = targetZone,
            note = targetNote or targetName,
        })
        return steps
    end

    local playerRegion = GetMapMacroRegion(playerMapID)
    local targetRegion = GetMapMacroRegion(targetMapID)
    local playerInstID = GetMapInstanceID(playerMapID)
    local targetInstID = GetMapInstanceID(targetMapID)

    -- Если мы уже на одном континенте и ни старт, ни цель не являются изолированной зоной (как Харандар или Изумрудный Сон)
    if (playerRegion == targetRegion or (playerInstID and targetInstID and playerInstID == targetInstID))
        and playerRegion ~= "HARANDAR" and targetRegion ~= "HARANDAR"
        and playerRegion ~= "VOIDSTORM" and targetRegion ~= "VOIDSTORM"
        and playerRegion ~= "EMERALD_DREAM" and targetRegion ~= "EMERALD_DREAM"
    then
        table.insert(steps, {
            mapID = targetMapID,
            x = targetX,
            y = targetY,
            zone = targetZone,
            note = targetNote or targetName,
        })
        return steps
    end

    local isAlliance = (UnitFactionGroup("player") == "Alliance")
    local capMapID   = isAlliance and 84 or 85
    local capName    = isAlliance and "Башня магов Штормграда" or "Зал порталов Оргриммара"
    local capX       = isAlliance and 49.3 or 50.2
    local capY       = isAlliance and 86.8 or 37.6
    local capRegion  = isAlliance and "EASTERN_KINGDOMS" or "KALIMDOR"

    -- ========================================================================
    -- ЭТАП А: ВЫХОД ИЗ ТЕКУЩЕЙ ЗОНЫ / ЭКСПАНШЕНА В ЗАЛ ПОРТАЛОВ СТОЛИЦЫ
    -- ========================================================================
    if playerRegion == "HARANDAR" then
        -- Ищем портал/выход прямо на карте Харандара (2413)
        local dx, dy, dnote = FindDynamicExitOrPortalOnMap(2413, { "луносвет", "silvermoon", "оргриммар", "штормград", "portal", "портал", "выход" })
        table.insert(steps, {
            mapID = 2413,
            x = dx or 51.8,
            y = dy or 50.6,
            zone = "Харандар",
            note = dnote or "Выход из Харандара: Портал в Луносвет / Столицу (Логово)",
            dynamicScan = true,
        })
        if targetRegion ~= "MIDNIGHT_QUELTHALAS" then
            table.insert(steps, {
                mapID = 2393,
                x = 53.3,
                y = 66.2,
                zone = "Луносвет",
                note = isAlliance and "Портал в Штормград (Луносвет)" or "Портал в Оргриммар (Луносвет)",
                dynamicScan = true,
                keywords = { "оргриммар", "штормград", "orgrimmar", "stormwind", "портал", "portal" },
            })
        end
    elseif playerRegion == "VOIDSTORM" then
        local dx, dy, dnote = FindDynamicExitOrPortalOnMap(playerMapID, { "луносвет", "silvermoon", "портал", "portal", "выход" })
        table.insert(steps, {
            mapID = playerMapID,
            x = dx or 50.0,
            y = dy or 50.0,
            zone = "Буря Бездны",
            note = dnote or "Портал из Бури Бездны в Луносвет",
            dynamicScan = true,
        })
        if targetRegion ~= "MIDNIGHT_QUELTHALAS" then
            table.insert(steps, {
                mapID = 2393,
                x = 53.3,
                y = 66.2,
                zone = "Луносвет",
                note = isAlliance and "Портал в Штормград (Луносвет)" or "Портал в Оргриммар (Луносвет)",
                dynamicScan = true,
            })
        end
    elseif playerRegion == "MIDNIGHT_QUELTHALAS" then
        local dx, dy, dnote = FindDynamicExitOrPortalOnMap(playerMapID, { "оргриммар", "штормград", "портал", "portal" })
        if dx and dy then
            table.insert(steps, {
                mapID = playerMapID,
                x = dx,
                y = dy,
                note = dnote or ("Портал в " .. capName),
            })
        else
            table.insert(steps, {
                mapID = 2393,
                x = 53.3,
                y = 66.2,
                zone = "Луносвет",
                note = isAlliance and "Портал в Штормград (Луносвет)" or "Портал в Оргриммар (Луносвет)",
                dynamicScan = true,
            })
        end
    elseif playerRegion == "KHAZ_ALGAR" then
        table.insert(steps, {
            mapID = 2339,
            x = isAlliance and 51.9 or 57.5,
            y = isAlliance and 49.0 or 52.8,
            zone = "Дорногал",
            note = isAlliance and "Портал в Штормград (Дорногал)" or "Портал в Оргриммар (Дорногал)",
        })
    elseif playerRegion == "EMERALD_DREAM" then
        table.insert(steps, {
            mapID = 2200,
            x = 62.7,
            y = 57.6,
            zone = "Изумрудный Сон",
            note = "Портал выхода из Изумрудного Сна (Древняя Ветвь)",
        })
        if targetRegion ~= "DRAGON_ISLES" then
            table.insert(steps, {
                mapID = 2112,
                x = 58.0,
                y = 35.4,
                zone = "Вальдраккен",
                note = "Портал в столицу (Башня Аспектов, Вальдраккен)",
            })
        end
    elseif playerRegion == "DRAGON_ISLES" then
        table.insert(steps, {
            mapID = 2112,
            x = 58.0,
            y = 35.4,
            zone = "Вальдраккен",
            note = "Портал в столицу (Башня Аспектов, Вальдраккен)",
        })
    elseif playerRegion == "SHADOWLANDS" then
        table.insert(steps, {
            mapID = 1670,
            x = 22.4,
            y = 50.2,
            zone = "Орибос",
            note = "Портал в столицу (Кольцо Судеб, Орибос)",
        })
    elseif playerRegion == "ZANDALAR" then
        table.insert(steps, {
            mapID = 1165,
            x = 49.9,
            y = 85.0,
            zone = "Дазар'алор",
            note = "Комната порталов в Оргриммар (Великая Печать)",
        })
    elseif playerRegion == "KUL_TIRAS" then
        table.insert(steps, {
            mapID = 1161,
            x = 70.4,
            y = 16.8,
            zone = "Боралус",
            note = "Комната порталов в Штормград (Боралус)",
        })
    elseif playerRegion == "BROKEN_ISLES" then
        table.insert(steps, {
            mapID = 627,
            x = isAlliance and 39.5 or 55.3,
            y = isAlliance and 63.2 or 24.0,
            zone = "Даларан",
            note = isAlliance and "Портал в Штормград (Даларан)" or "Портал в Оргриммар (Даларан)",
        })
    elseif playerRegion == "PANDARIA" then
        table.insert(steps, {
            mapID = 371,
            x = isAlliance and 46.2 or 28.5,
            y = isAlliance and 85.2 or 14.0,
            zone = "Нефритовый лес",
            note = isAlliance and "Портал в Штормград (Лагерь Лазурного Крыла)" or "Портал в Оргриммар (Деревня Медовой Росы)",
        })
    elseif playerRegion ~= capRegion then
        local dx, dy, dnote = FindDynamicExitOrPortalOnMap(playerMapID, { "оргриммар", "штормград", "портал", "portal", "выход" })
        if dx and dy then
            table.insert(steps, {
                mapID = playerMapID,
                x = dx,
                y = dy,
                note = dnote or ("Выход / Портал в " .. capName),
            })
        end
    end

    -- ========================================================================
    -- ЭТАП Б: ЗАЛ ПОРТАЛОВ СТОЛИЦЫ (Оргриммар #85 / Штормград #84) -> КОНТИНЕНТ ЦЕЛИ
    -- ========================================================================
    local DEST_PORTAL_NAMES = {
        PANDARIA            = "Портал в Нефритовый лес (Пандария)",
        BROKEN_ISLES        = "Портал в Азсуну / Даларан (Расколотые острова)",
        ARGUS               = "Портал в Азсуну -> Даларан -> Аргус",
        ZANDALAR            = "Портал в Зулдазар (Зандалар)",
        KUL_TIRAS           = "Портал в Боралус (Кул-Тирас)",
        SHADOWLANDS         = "Портал в Орибос (Темные Земли)",
        DRAGON_ISLES        = "Портал в Вальдраккен (Драконьи острова)",
        EMERALD_DREAM       = "Портал в Вальдраккен -> Изумрудный Сон",
        KHAZ_ALGAR          = "Портал в Дорногал (Каз Алгар)",
        MIDNIGHT_QUELTHALAS = "Портал в Луносвет (Midnight)",
        HARANDAR            = "Портал в Луносвет -> Харандар",
        VOIDSTORM           = "Портал в Луносвет -> Буря Бездны",
        NORTHREND           = "Портал в Даларан (Нордскол)",
        OUTLAND             = "Портал в Шаттрат (Запределье)",
        DRAENOR             = "Портал в Ашран (Дренор)",
    }

    if targetRegion ~= capRegion then
        local portalAction = DEST_PORTAL_NAMES[targetRegion] or ("Портал в " .. (targetZone or "нужный континент"))
        -- Не дублируем шаг столицы, если мы уже перешли из Харандара прямо в Луносвет, а цель в Кель'Таласе
        if not (playerRegion == "HARANDAR" and targetRegion == "MIDNIGHT_QUELTHALAS") then
            table.insert(steps, {
                mapID = capMapID,
                x = capX,
                y = capY,
                zone = isAlliance and "Штормград" or "Оргриммар",
                note = string.format("%s: %s", capName, portalAction),
            })
        end
    end

    -- ========================================================================
    -- ЭТАП В: ПРОМЕЖУТОЧНЫЙ ПОРТАЛ ХАБА (если цель в Харандаре или Изумрудном Сне)
    -- ========================================================================
    if targetRegion == "HARANDAR" and playerRegion ~= "HARANDAR" then
        table.insert(steps, {
            mapID = 2393,
            x = 36.7,
            y = 68.6,
            zone = "Луносвет",
            note = "Луносвет: Портал в Харандар",
            dynamicScan = true,
            keywords = { "харандар", "harandar", "логово", "den" },
            keepNote = true,
        })
    elseif targetRegion == "EMERALD_DREAM" and playerRegion ~= "EMERALD_DREAM" then
        table.insert(steps, {
            mapID = 2023,
            x = 18.6,
            y = 52.2,
            zone = "Равнины Он'ары",
            note = "Портал в Изумрудный Сон (Древняя Ветвь, Равнины Он'ары)",
        })
    end

    -- ========================================================================
    -- ЭТАП Г: ФИНАЛЬНАЯ ТОЧКА (Зверь или Фолиант)
    -- ========================================================================
    table.insert(steps, {
        mapID = targetMapID,
        x = targetX,
        y = targetY,
        zone = targetZone,
        note = targetNote or targetName,
    })

    return steps
end

function addon:NavigateToBeast(beast, coordIndex, openWorldMap)
    if not beast then return end

    if openWorldMap and beast.mapID and _G.OpenWorldMap then
        pcall(OpenWorldMap, beast.mapID)
    end

    if not beast.coords or #beast.coords == 0 or not beast.mapID then
        if beast.mapID then
            print(string.format(
                "|cff00ff96[BeastCollector]|r Открыта карта зоны |cff00ccff%s|r для поиска |cffffd100%s|r.",
                beast.zone or "Локация", beast.name
            ))
        else
            print(string.format(
                "|cff00ff96[BeastCollector]|r Зверь |cffffd100%s|r обитает в: |cff00ccff%s|r.",
                beast.name, beast.zone or "Инстанс / Подземелье"
            ))
        end
        return
    end

    local pt = beast.coords[coordIndex or 1] or beast.coords[1]
    if not pt then return end

    -- Строим пошаговый маршрут (выход из зоны -> порталы -> финальная точка)
    local steps = self:BuildMultiHopRoute(
        beast.mapID,
        pt.x,
        pt.y,
        beast.name,
        beast.zone,
        pt.note and (beast.name .. " — " .. pt.note) or beast.name
    )

    self.activePortalRoute = {
        targetName = beast.name,
        targetMapID = beast.mapID,
        steps = steps,
        currentStep = 1,
    }

    -- Если у зверя несколько точек спавна в финальной зоне и включён TomTom, добавим их на карту финальной зоны
    if _G.TomTom and _G.TomTom.AddWaypoint and coordIndex == nil and #beast.coords > 1 then
        for i, c in ipairs(beast.coords) do
            local subTitle = string.format("%s [%d/%d: %s]", beast.name, i, #beast.coords, c.note or beast.zone or "")
            pcall(_G.TomTom.AddWaypoint, _G.TomTom, beast.mapID, c.x / 100, c.y / 100, {
                title = subTitle,
                persistent = false,
                minimap = true,
                world = true,
            })
        end
    end

    -- Активируем Шаг 1 (в текущей зоне игрока!), чтобы стрелка миникарты сразу повела к выходу и порталам
    self:ActivateCurrentRouteStep()

    -- Если шагов больше одного, выведем в чат краткую сводку всего маршрута
    if #steps > 1 then
        local chainParts = {}
        for idx, st in ipairs(steps) do
            table.insert(chainParts, string.format("%d) %s", idx, st.note or st.zone or ""))
        end
        print("|cff00ff96[BeastCollector Навигатор]|r Полный маршрут по порталам: |cffffffff" .. table.concat(chainParts, " -> ") .. "|r")
    end
end

-- ============================================================================
-- ТУЛТИПЫ НА ЗВЕРЯХ В ОТКРЫТОМ МИРЕ (Защита от Secret Value 12.1.5)
-- ============================================================================
function addon:InitTooltips()
    if self.tooltipsHooked then return end
    if not _G.TooltipDataProcessor or not _G.Enum or not _G.Enum.TooltipDataType then return end
    self.tooltipsHooked = true

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip, data)
        if tooltip ~= GameTooltip then return end
        if not self.db or not self.db.settings or not self.db.settings.showUnitTooltips then return end
        if not data or not SafeNotSecret(data.guid) or type(data.guid) ~= "string" then return end

        local unitType, _, _, _, _, npcIDStr = strsplit("-", data.guid)
        if unitType ~= "Creature" and unitType ~= "Vehicle" and unitType ~= "Vignette" then return end
        local npcID = tonumber(npcIDStr)
        if not npcID then return end

        local beast = self.BeastByNpcID[npcID]
        if not beast then return end

        local fam = self.FamilyByID[beast.family]
        local spec = fam and self.PetSpecs[fam.spec]
        local isCollected, colText = self:IsBeastCollected(beast)

        local famLabel = (fam and fam.name) or "Приручаемый зверь"
        if fam and fam.exotic then
            famLabel = famLabel .. " |cffc678dd(Экзотика — только БМ)|r"
        end

        tooltip:AddLine(" ")
        tooltip:AddDoubleLine(
            "|TInterface\\ICONS\\Ability_Hunter_BeastMastery:14:14:0:0|t |cff00ff96BeastCollector:|r " .. famLabel,
            spec and (spec.color .. spec.name .. "|r") or ""
        )
        if fam and fam.familySkill then
            tooltip:AddLine("   |cffffd100Умеет:|r " .. fam.familySkill, 0.9, 0.9, 0.9, true)
        end

        -- Проверка: почему зверь может не приручаться прямо сейчас (БМ-спек / уровень моба / фолиант)
        if fam and fam.exotic and _G.GetSpecialization then
            local curSpec = GetSpecialization()
            if SafeNotSecret(curSpec) and curSpec ~= 1 then
                tooltip:AddLine("   |TInterface\\DialogFrame\\UI-Dialog-Icon-AlertNew:14:14:0:0|t |cffff4444Нельзя приручить в текущем спеке: нужен «Повелитель Зверей» (БМ)!|r", 1, 0.3, 0.3, true)
            end
        end

        local mobLevel = UnitLevel("mouseover")
        local playerLevel = UnitLevel("player")
        if SafeNotSecret(mobLevel) and SafeNotSecret(playerLevel) and type(mobLevel) == "number" and type(playerLevel) == "number" then
            if mobLevel > playerLevel or mobLevel < 0 then
                local lvlStr = (mobLevel < 0) and "??" or tostring(mobLevel)
                tooltip:AddLine("   |TInterface\\DialogFrame\\UI-Dialog-Icon-AlertNew:14:14:0:0|t |cffff4444Нельзя приручить сейчас: уровень зверя (" .. lvlStr .. ") выше твоего (" .. tostring(playerLevel) .. ")!|r", 1, 0.3, 0.3, true)
            end
        end

        if beast.tomes and #beast.tomes > 0 then
            for _, tKey in ipairs(beast.tomes) do
                local isLearned, tome = self:IsTomeLearned(tKey)
                if tome then
                    if isLearned then
                        tooltip:AddLine("   |TInterface\\RaidFrame\\ReadyCheck-Ready:14:14:0:0|t |cff00ff96Книга изучена:|r " .. tome.name, 0.6, 1.0, 0.6, true)
                    else
                        tooltip:AddLine("   |TInterface\\RaidFrame\\ReadyCheck-NotReady:14:14:0:0|t |cffff4444Требуется книга:|r " .. tome.name, 1.0, 0.4, 0.4, true)
                    end
                end
            end
        end
        if isCollected then
            tooltip:AddLine("   |TInterface\\RaidFrame\\ReadyCheck-Ready:14:14:0:0|t |cff00ff96" .. (colText or "Уже в коллекции") .. "|r")
        else
            tooltip:AddLine("   |TInterface\\COMMON\\ReputationStar:14:14:0:0:32:32:0:16:0:16|t |cffff8800Этой модели ещё нет в твоих стойлах!|r")
        end
    end)
end

-- ============================================================================
-- СОБЫТИЯ ЖИЗНЕННОГО ЦИКЛА И ТРЕКЕР ПОРТАЛЬНОГО МАРШРУТА
-- ============================================================================
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("ZONE_CHANGED")
eventFrame:RegisterEvent("PET_STABLE_SHOW")
eventFrame:RegisterEvent("PET_STABLE_UPDATE")
eventFrame:RegisterEvent("UNIT_PET")

eventFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        addon:InitDB()
        addon:BuildIndices()
        addon:InitTooltips()
        if addon.InitUI then
            addon:InitUI()
        end
    elseif event == "PLAYER_ENTERING_WORLD" or event == "PET_STABLE_SHOW" or event == "PET_STABLE_UPDATE" then
        if event == "PLAYER_ENTERING_WORLD" and addon.SetupRoundMinimapButton then
            addon:SetupRoundMinimapButton()
        end
        C_Timer.After(0.5, function()
            if addon.SetupRoundMinimapButton then
                addon:SetupRoundMinimapButton()
            end
            addon:ScanHunterStables()
            addon:CheckPortalRouteProgress()
        end)
    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" then
        C_Timer.After(0.4, function()
            addon:CheckPortalRouteProgress()
        end)
    elseif event == "UNIT_PET" and arg1 == "player" then
        addon:ScanHunterStables()
    end
end)
