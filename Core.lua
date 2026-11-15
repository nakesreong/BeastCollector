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
addon.TomeByDropNpcID = {}
addon.TomeByEncounterID = {}
addon.LootedCorpseGUIDs = {}

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
    wipe(self.TomeByDropNpcID)
    wipe(self.TomeByEncounterID)

    if self.TamingTomes then
        for tKey, tome in pairs(self.TamingTomes) do
            tome.beastCount = 0
            if tome.dropNpcIDs then
                for _, dNpcID in ipairs(tome.dropNpcIDs) do
                    self.TomeByDropNpcID[dNpcID] = tKey
                end
            end
            if tome.dropEncounterID then
                self.TomeByEncounterID[tome.dropEncounterID] = tKey
            end
        end
    end

    for idx, fam in ipairs(self.Families or {}) do
        fam.order = idx
        self.FamilyByID[fam.id] = fam
    end

    local modelGroupCounts = {}
    local npcLookCounts = {}
    for _, beast in ipairs(self.Beasts or {}) do
        if beast.modelGroup and beast.modelGroup ~= "" then
            modelGroupCounts[beast.modelGroup] = (modelGroupCounts[beast.modelGroup] or 0) + 1
        end
        if beast.npcIDs then
            for _, nid in ipairs(beast.npcIDs) do
                npcLookCounts[nid] = (npcLookCounts[nid] or 0) + 1
            end
        elseif beast.npcID then
            npcLookCounts[beast.npcID] = (npcLookCounts[beast.npcID] or 0) + 1
        end
    end

    for idx, beast in ipairs(self.Beasts or {}) do
        beast.order = idx
        self.BeastByID[beast.id] = beast
        beast.modelGroupCount = (beast.modelGroup and modelGroupCounts[beast.modelGroup]) or 1
        beast.isUniqueModel = (beast.modelGroupCount == 1)

        local nidCount = beast.npcIDs and #beast.npcIDs or 0
        local sameNamedNpc = false
        if nidCount > 1 and nidCount <= 4 and beast.npcs and #beast.npcs > 1 then
            local firstEN = beast.npcs[1].nameEN
            if firstEN and firstEN ~= "" then
                sameNamedNpc = true
                for i = 2, #beast.npcs do
                    if beast.npcs[i].nameEN ~= firstEN then
                        sameNamedNpc = false
                        break
                    end
                end
            end
        end
        local isNonCommon = (beast.rarity and beast.rarity ~= "COMMON") or (beast.questOnly == true)
        local isNotChameleon = not beast.npcID or ((npcLookCounts[beast.npcID] or 1) == 1)
        beast.isUniqueNpc = isNonCommon and isNotChameleon and ((nidCount == 1) or sameNamedNpc)
        beast.isUniqueLook = (beast.isUniqueModel or beast.isUniqueNpc)
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
    db.stabledSlotsCache = db.stabledSlotsCache or {}
    db.manualCollected = db.manualCollected or {}
    db.manualTomes = db.manualTomes or {}
    db.tomeAttempts = db.tomeAttempts or {}
    -- Аня уже выбила и изучила «Испытания охотника на флорафавнов» и «Древний фолиант диномантии»:
    if db.manualTomes["FLORAFAUN"] == nil then
        db.manualTomes["FLORAFAUN"] = true
    end
    if db.manualTomes["DIREHORN"] == nil then
        db.manualTomes["DIREHORN"] = true
    end
    db.minimap = db.minimap or { hide = false }
    db.settings = db.settings or {
        showUnitTooltips = true,
        onlyUncollected = false,
        language = "AUTO",
    }
    if db.settings.language == nil then
        db.settings.language = "AUTO"
    end
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

-- Возвращает количество траев (убийств мобов/боссов) на выбиваемый фолиант и накопленную вероятность (%)
function addon:GetTomeAttempts(tomeKey)
    if not tomeKey or not self.db or not self.db.tomeAttempts then return 0, 0 end
    local rec = self.db.tomeAttempts[tomeKey]
    local tries = (type(rec) == "table" and (rec.total or 0)) or (tonumber(rec) or 0)
    local tome = self.TamingTomes and self.TamingTomes[tomeKey]
    local chance = (tome and tome.dropChance and tome.dropChance > 0) and tome.dropChance or 20
    local luckPct = 0
    if tries > 0 then
        if chance <= 1 then
            luckPct = 100
        else
            luckPct = (1 - math.pow(1 - (1 / chance), tries)) * 100
        end
    end
    return tries, luckPct
end

function addon:RecordTomeAttempt(tomeKey, mobName, uniqueCorpseKey)
    if not tomeKey or not self.db then return end
    local tome = self.TamingTomes and self.TamingTomes[tomeKey]
    if not tome or not tome.isDrop then return end

    if uniqueCorpseKey then
        if self.LootedCorpseGUIDs[uniqueCorpseKey] then return end
        self.LootedCorpseGUIDs[uniqueCorpseKey] = true
    end

    self.db.tomeAttempts = self.db.tomeAttempts or {}
    local rec = self.db.tomeAttempts[tomeKey]
    if type(rec) ~= "table" then
        rec = { total = tonumber(rec) or 0 }
    end
    rec.total = (rec.total or 0) + 1
    rec.lastKill = time()
    self.db.tomeAttempts[tomeKey] = rec

    if self.RefreshUI then
        self:RefreshUI()
    end
end

function addon:HandleLootReadyForTomes()
    if not _G.GetNumLootItems or not _G.GetLootSourceInfo then return end
    local numItems = GetNumLootItems()
    local seenCorpses = {}

    for slot = 1, numItems do
        local sources = { GetLootSourceInfo(slot) }
        for i = 1, #sources, 2 do
            local guid = sources[i]
            if SafeNotSecret(guid) and type(guid) == "string" and not seenCorpses[guid] then
                seenCorpses[guid] = true
                local unitType, _, _, _, _, npcIDStr = strsplit("-", guid)
                if unitType == "Creature" or unitType == "Vehicle" then
                    local npcID = tonumber(npcIDStr)
                    if npcID then
                        local tKey = self.TomeByDropNpcID and self.TomeByDropNpcID[npcID]
                        if not tKey then
                            -- Для Костоплета (UNDEAD) считаем лут элитных мобов в Малдраксусе / Чумопаде, если книга ещё не изучена
                            local curMap = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
                            local undeadTome = self.TamingTomes and self.TamingTomes.UNDEAD
                            if curMap and undeadTome and undeadTome.dropZoneMapIDs and undeadTome.dropZoneMapIDs[curMap] and not self:IsTomeLearned("UNDEAD") then
                                tKey = "UNDEAD"
                            end
                        end
                        if tKey and not self:IsTomeLearned(tKey) then
                            local tName = UnitName("target")
                            local mobLabel = (SafeNotSecret(tName) and tName) or ("NPC #" .. tostring(npcID))
                            self:RecordTomeAttempt(tKey, mobLabel, guid)
                        end
                    end
                end
            end
        end
    end
end

function addon:HandleEncounterEndForTomes(encounterID, encounterName, success)
    if success ~= 1 then return end
    local tKey = self.TomeByEncounterID and self.TomeByEncounterID[encounterID]
    if tKey and not self:IsTomeLearned(tKey) then
        local lockKey = "ENC_" .. tostring(encounterID) .. "_" .. tostring(math.floor(GetTime() / 30))
        self:RecordTomeAttempt(tKey, (SafeNotSecret(encounterName) and encounterName) or "Босс", lockKey)
    end
end

-- ============================================================================
-- АВТО-СКАНИРОВАНИЕ СТОЙЛ ОХОТНИКА (C_StableInfo + Активный питомец)
-- При отпускании питомца на волю (PetAbandon) или смене активных слотов
-- старые записи полностью очищаются (wipe), чтобы отпущенные звери не висели в коллекции!
-- ============================================================================
function addon:ScanHunterStables(event)
    if not self.db then return end

    self.db.stabledSlotsCache = self.db.stabledSlotsCache or {}

    local function ExtractPetEntry(petInfo)
        if type(petInfo) ~= "table" then return nil end
        local cID = petInfo.creatureID
        local dID = petInfo.displayID or petInfo.modelID
        local pName = petInfo.name or "Питомец"
        local famName = petInfo.familyName or ""
        local safeName = (SafeNotSecret(pName) and pName ~= "") and pName or "Питомец"
        local safeFam = SafeNotSecret(famName) and famName or ""
        local safeCID = (cID and SafeNotSecret(cID) and cID > 0) and cID or nil
        local safeDID = (dID and SafeNotSecret(dID) and dID > 0) and dID or nil
        if not safeCID and not safeDID then return nil end
        return {
            creatureID = safeCID,
            displayID = safeDID,
            name = safeName,
            familyName = safeFam,
            slotID = petInfo.slotID,
        }
    end

    local function ApplyPetEntry(entry)
        if not entry then return end
        if entry.creatureID then
            self.db.stabledByCreatureID[entry.creatureID] = {
                name = entry.name,
                familyName = entry.familyName,
                slotID = entry.slotID,
            }
        end
        if entry.displayID then
            self.db.stabledByDisplay[entry.displayID] = {
                name = entry.name,
                familyName = entry.familyName,
                slotID = entry.slotID,
            }
        end
    end

    -- 1. Полностью очищаем результирующие таблицы перед пересборкой,
    --    чтобы все отпущенные на волю питомцы мгновенно пропадали!
    wipe(self.db.stabledByCreatureID)
    wipe(self.db.stabledByDisplay)

    if C_StableInfo then
        -- 2. Обновляем кэш дальних стойл (слоты > 5 у смотрителя стойл), если список доступен
        if C_StableInfo.GetStabledPetList then
            local ok, list = pcall(C_StableInfo.GetStabledPetList)
            if ok and type(list) == "table" and (#list > 0 or event == "PET_STABLE_SHOW" or event == "PET_STABLE_UPDATE") then
                wipe(self.db.stabledSlotsCache)
                for _, petInfo in ipairs(list) do
                    local entry = ExtractPetEntry(petInfo)
                    if entry then
                        table.insert(self.db.stabledSlotsCache, entry)
                    end
                end
            end
        end

        -- Применяем сохранённые слоты смотрителя стойл
        for _, entry in ipairs(self.db.stabledSlotsCache) do
            ApplyPetEntry(entry)
        end

        -- 3. Сканируем 5 активных слотов свистка (всегда актуальны в открытом мире!)
        if C_StableInfo.GetActivePetList then
            local ok, list = pcall(C_StableInfo.GetActivePetList)
            if ok and type(list) == "table" then
                for _, petInfo in ipairs(list) do
                    ApplyPetEntry(ExtractPetEntry(petInfo))
                end
            end
        end
    end

    -- 4. Проверяем физически призванного рядом питомца (если он жив и не отпущен)
    if UnitExists("pet") then
        local guid = UnitGUID("pet")
        if SafeNotSecret(guid) and type(guid) == "string" then
            local unitType, _, _, _, _, npcIDStr = strsplit("-", guid)
            if unitType == "Pet" or unitType == "Creature" then
                local cID = tonumber(npcIDStr)
                local petName = UnitName("pet")
                if cID and cID > 0 and not self.db.stabledByCreatureID[cID] then
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

    -- 1. Явная ручная отметка или ручное снятие отметки пользователем («Отметить своим» / «Снять отметку»)
    --    Значение false означает, что пользователь принудительно снял галочку (например, у второго окраса того же NPC ID)!
    if self.db.manualCollected[beast.id] == true then
        return true, self:L("COL_MANUAL")
    elseif self.db.manualCollected[beast.id] == false then
        return false, nil
    end

    local bName = self:GetBeastName(beast)

    -- 2. Если у зверя задан конкретный displayID (уникальный окрас), а в стойлах есть другой окрас с тем же npcID,
    --    проверяем совпадение по displayID в приоритете, если в базе есть несколько окрасов на один npcID!
    if beast.displayID and self.db.stabledByDisplay[beast.displayID] then
        local info = self.db.stabledByDisplay[beast.displayID]
        return true, self:L("COL_STABLED_FMT", info.name or bName)
    end

    if beast.npcID and self.db.stabledByCreatureID[beast.npcID] then
        local info = self.db.stabledByCreatureID[beast.npcID]
        return true, self:L("COL_STABLED_FMT", info.name or bName)
    end

    if beast.npcIDs then
        for _, nid in ipairs(beast.npcIDs) do
            local info = self.db.stabledByCreatureID[nid]
            if info then
                return true, self:L("COL_STABLED_FMT", info.name or bName)
            end
        end
    end

    return false, nil
end

function addon:ToggleManualCollected(beast)
    if not beast or not self.db then return end
    local currentlyCollected = self:IsBeastCollected(beast)
    if currentlyCollected then
        -- Принудительно снимаем отметку (даже если моб делит npcID с другим окрасом в стойлах)
        self.db.manualCollected[beast.id] = false
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
    if mapID == 2413 or mapID == 2576 or ancestors[2413] then return "HARANDAR" end
    if mapID == 2405 or ancestors[2405] then return "VOIDSTORM" end
    if mapID == 2200 or ancestors[2200] then return "EMERALD_DREAM" end
    if mapID == 2133 or ancestors[2133] then return "ZARALEK" end

    -- Midnight (Кель'Талас 2537 / Луносвет 2393, 2605 / Леса Вечной Песни 2395, 2594 / Зул'Аман 2437)
    -- Важно проверять ДО Восточных королевств (13), т.к. у 2537 родитель = 13!
    if mapID == 2393 or mapID == 2605 or mapID == 2395 or mapID == 2594 or mapID == 2437 or mapID == 2537
        or ancestors[2393] or ancestors[2395] or ancestors[2437] or ancestors[2537] or ancestors[2424]
    then
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
function addon:ActivateCurrentRouteStep(silent)
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
    local isEN = self:IsEnglish()
    local stepLabel = totalSteps > 1
        and string.format(isEN and "[Step %d/%d] %s" or "[Шаг %d/%d] %s", route.currentStep, totalSteps, step.note or route.targetName)
        or string.format("BeastCollector: %s (%s)", route.targetName, step.note or "")

    -- 1. Ставим стрелку TomTom на текущий шаг (и на подкарту, если задана subMapID, например Логово 2576 или Луносвет 2393)
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
        if step.subMapID and step.subX and step.subY then
            local okSub, uidSub = pcall(_G.TomTom.AddWaypoint, _G.TomTom, step.subMapID, step.subX / 100, step.subY / 100, {
                title = stepLabel,
                persistent = false,
                minimap = true,
                world = true,
                crazy = true,
            })
            if okSub and uidSub then
                table.insert(self.portalTomTomUids, uidSub)
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
                C_Timer.After(0.10, function()
                    if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
                        pcall(C_SuperTrack.SetSuperTrackedUserWaypoint, true)
                    end
                end)
            end
        end
    end

    if not silent then
        local mapInfo = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(step.mapID)
        local zoneName = step.zone or (mapInfo and SafeNotSecret(mapInfo.name) and mapInfo.name) or self:L("UNKNOWN_ZONE")
        if totalSteps > 1 then
            print(string.format(
                isEN
                    and "|cff00ff96[BeastCollector Route %d/%d]|r Minimap arrow leads to: |cffffd100%s|r — |cff00ccff%s (%.1f, %.1f)|r"
                    or "|cff00ff96[BeastCollector Маршрут %d/%d]|r Стрелка миникарты ведёт: |cffffd100%s|r — |cff00ccff%s (%.1f, %.1f)|r",
                route.currentStep, totalSteps, step.note or route.targetName, zoneName, step.x, step.y
            ))
        else
            print(string.format(
                isEN
                    and "|cff00ff96[BeastCollector]|r Route plotted to |cffffd100%s|r: |cff00ccff%s (%.1f, %.1f)|r%s"
                    or "|cff00ff96[BeastCollector]|r Проложен путь к |cffffd100%s|r: |cff00ccff%s (%.1f, %.1f)|r%s",
                route.targetName, zoneName, step.x, step.y, step.note and (" — " .. step.note) or ""
            ))
        end
    end
end

-- Проверяет при смене зоны или движении, не перешёл ли игрок на следующий шаг маршрута
function addon:CheckPortalRouteProgress()
    local route = self.activePortalRoute
    if not route or not route.steps or #route.steps == 0 then return end

    local playerMapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    if not playerMapID then return end

    local playerRegion = GetMapMacroRegion(playerMapID)
    local playerInstID = GetMapInstanceID(playerMapID)
    local finalStep = route.steps[#route.steps]
    local finalRegion = GetMapMacroRegion(finalStep.mapID)
    local finalInstID = GetMapInstanceID(finalStep.mapID)

    -- 1. Если игрок уже в целевой зоне или на том же континенте, что и финальная цель
    if playerMapID == finalStep.mapID
        or (playerRegion == finalRegion and finalRegion ~= "HARANDAR" and finalRegion ~= "VOIDSTORM" and finalRegion ~= "EMERALD_DREAM")
        or (playerInstID and finalInstID and playerInstID == finalInstID and playerRegion == finalRegion)
    then
        if route.currentStep ~= #route.steps then
            route.currentStep = #route.steps
            self:ActivateCurrentRouteStep(false)
        elseif C_Map and C_Map.HasUserWaypoint and not C_Map.HasUserWaypoint() then
            self:ActivateCurrentRouteStep(true)
        end
        return
    end

    -- 2. Ищем самый дальний шаг маршрута, в регионе или карте которого сейчас оказался игрок
    for i = #route.steps, 1, -1 do
        local st = route.steps[i]
        local stRegion = GetMapMacroRegion(st.mapID)
        if playerMapID == st.mapID or playerMapID == st.subMapID or playerRegion == stRegion then
            if i > route.currentStep then
                route.currentStep = i
                self:ActivateCurrentRouteStep(false)
            elseif i == route.currentStep then
                -- Если во время загрузочного экрана или телепорта в Башню магов игра сбросила точку — восстановим её!
                if C_Map and C_Map.HasUserWaypoint and not C_Map.HasUserWaypoint() then
                    self:ActivateCurrentRouteStep(true)
                elseif C_SuperTrack and C_SuperTrack.IsSuperTrackingUserWaypoint and not C_SuperTrack.IsSuperTrackingUserWaypoint() then
                    pcall(C_SuperTrack.SetSuperTrackedUserWaypoint, true)
                end
            end
            return
        end
    end
end

-- Строит цепочку шагов по ТОЧНЫМ координатам AreaPOI из базы клиента WoW 12.0 (Wago DB2):
--   * Харандар (#2413): Корнистый путь в леса Вечной Песни (53.3, 55.5) / внутри Логова (#2576): (64.5, 71.4)
--   * Луносвет (#2393 / #2395): Зал с порталами — Портал в Штормград (#2393 52.6, 64.5 / #2395 52.6, 25.5), Портал в Оргриммар (#2393 52.2, 65.2 / #2395 52.5, 25.7)
--   * Штормград (#84): Портал в Деревню Лап'дон / Пандарию (68.7, 17.2 у шара пандаренов) или Зал порталов (48.7, 88.1)
--   * Оргриммар (#85): Портал в Деревню Медовой Росы / Пандарию (68.6, 40.7) или Зал порталов (57.3, 89.7)
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

    -- Если мы уже на одном континенте и ни старт, ни цель не являются изолированной зоной
    if (playerRegion == targetRegion or (playerInstID and targetInstID and playerInstID == targetInstID and playerRegion == targetRegion))
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
    local capName    = isAlliance and "Зал порталов Штормграда" or "Зал порталов Оргриммара"
    local capX       = isAlliance and 48.7 or 57.3
    local capY       = isAlliance and 88.1 or 89.7
    local capRegion  = isAlliance and "EASTERN_KINGDOMS" or "KALIMDOR"

    -- ========================================================================
    -- ЭТАП А: ВЫХОД ИЗ ТЕКУЩЕЙ ЗОНЫ / ЭКСПАНШЕНА В ЗАЛ ПОРТАЛОВ СТОЛИЦЫ
    -- ========================================================================
    if playerRegion == "HARANDAR" then
        -- AreaPOI #8478 / #8784: «Корнистый путь в леса Вечной Песни»
        -- На карте Харандара (#2413) это (53.3, 55.5), а внутри подкарты Логова (#2576) — (64.5, 71.4)!
        table.insert(steps, {
            mapID = 2413,
            x = 53.3,
            y = 55.5,
            subMapID = 2576,
            subX = 64.5,
            subY = 71.4,
            zone = "Харандар (Логово)",
            note = "Корнистый путь в леса Вечной Песни / Луносвет (Логово, нижний ярус)",
        })
        if targetRegion ~= "MIDNIGHT_QUELTHALAS" then
            -- AreaPOI #8310 (Штормград: 2393 52.6, 64.5 / 2395 52.6, 25.5) и #8309 (Оргриммар: 2393 52.2, 65.2 / 2395 52.5, 25.7)
            -- Карта 2393 (Луносвет) имеет флаг CanSetUserWaypoint=false, поэтому ставим пин на 2395 с подкартой 2393!
            table.insert(steps, {
                mapID = 2395,
                x = isAlliance and 52.6 or 52.5,
                y = isAlliance and 25.5 or 25.7,
                subMapID = 2393,
                subX = isAlliance and 52.6 or 52.2,
                subY = isAlliance and 64.5 or 65.2,
                zone = "Луносвет",
                note = isAlliance and "Зал с порталами Луносвета: Портал в Штормград (52.6, 64.5)" or "Зал с порталами Луносвета: Портал в Оргриммар (52.2, 65.2)",
            })
        end
    elseif playerRegion == "VOIDSTORM" then
        local dx, dy, dnote = FindDynamicExitOrPortalOnMap(playerMapID, { "луносвет", "silvermoon", "portal", "портал", "выход" })
        table.insert(steps, {
            mapID = playerMapID,
            x = dx or 50.0,
            y = dy or 50.0,
            zone = "Буря Бездны",
            note = dnote or "Портал из Бури Бездны в Луносвет",
        })
        if targetRegion ~= "MIDNIGHT_QUELTHALAS" then
            table.insert(steps, {
                mapID = 2395,
                x = isAlliance and 52.6 or 52.5,
                y = isAlliance and 25.5 or 25.7,
                subMapID = 2393,
                subX = isAlliance and 52.6 or 52.2,
                subY = isAlliance and 64.5 or 65.2,
                zone = "Луносвет",
                note = isAlliance and "Зал с порталами Луносвета: Портал в Штормград (52.6, 64.5)" or "Зал с порталами Луносвета: Портал в Оргриммар (52.2, 65.2)",
            })
        end
    elseif playerRegion == "MIDNIGHT_QUELTHALAS" then
        table.insert(steps, {
            mapID = 2395,
            x = isAlliance and 52.6 or 52.5,
            y = isAlliance and 25.5 or 25.7,
            subMapID = 2393,
            subX = isAlliance and 52.6 or 52.2,
            subY = isAlliance and 64.5 or 65.2,
            zone = "Луносвет",
            note = isAlliance and "Зал с порталами Луносвета: Портал в Штормград (52.6, 64.5)" or "Зал с порталами Луносвета: Портал в Оргриммар (52.2, 65.2)",
        })
    elseif playerRegion == "KHAZ_ALGAR" then
        -- AreaPOI #7919: Комната порталов зала Основания (41.9, 28.3)
        table.insert(steps, {
            mapID = 2339,
            x = 41.9,
            y = 28.3,
            zone = "Дорногал",
            note = isAlliance and "Комната порталов Дорногала: Портал в Штормград" or "Комната порталов Дорногала: Портал в Оргриммар",
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
                x = 57.9,
                y = 35.3,
                zone = "Вальдраккен",
                note = "Престол Аспектов (Вальдраккен): Портал в столицу",
            })
        end
    elseif playerRegion == "DRAGON_ISLES" then
        table.insert(steps, {
            mapID = 2112,
            x = 57.9,
            y = 35.3,
            zone = "Вальдраккен",
            note = "Престол Аспектов (Вальдраккен): Портал в столицу",
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
        if not (not isAlliance and targetRegion == "KUL_TIRAS") then
            table.insert(steps, {
                mapID = 1165,
                x = 49.9,
                y = 85.0,
                zone = "Дазар'алор",
                note = "Комната порталов в Оргриммар (Великая Печать)",
            })
        end
    elseif playerRegion == "KUL_TIRAS" then
        if not (isAlliance and targetRegion == "ZANDALAR") then
            table.insert(steps, {
                mapID = 1161,
                x = 70.4,
                y = 16.8,
                zone = "Боралус",
                note = "Комната порталов в Штормград (Боралус)",
            })
        end
    elseif playerRegion == "BROKEN_ISLES" then
        table.insert(steps, {
            mapID = 627,
            x = isAlliance and 39.5 or 55.3,
            y = isAlliance and 63.2 or 24.0,
            zone = "Даларан",
            note = isAlliance and "Портал в Штормград (Даларан)" or "Портал в Оргриммар (Даларан)",
        })
    elseif playerRegion == "PANDARIA" then
        -- AreaPOI #5892 (Штормград 46.2, 85.2) и #5890 (Оргриммар 28.5, 14.0)
        table.insert(steps, {
            mapID = 371,
            x = isAlliance and 46.2 or 28.5,
            y = isAlliance and 85.2 or 14.0,
            zone = "Нефритовый лес",
            note = isAlliance and "Портал в Штормград (Деревня Лап'дон)" or "Портал в Оргриммар (Деревня Медовой Росы)",
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
    -- ЭТАП Б: СТОЛИЦА (Штормград #84 / Оргриммар #85) -> ПОРТАЛ В КОНТИНЕНТ ЦЕЛИ
    -- ========================================================================
    local DEST_PORTAL_NAMES = {
        PANDARIA            = isAlliance and "Портал в Деревню Лап'дон (Нефритовый лес, Пандария)" or "Портал в Деревню Медовой Росы (Нефритовый лес, Пандария)",
        BROKEN_ISLES        = "Портал в Азсуну / Даларан (Расколотые острова)",
        ARGUS               = "Портал в Азсуну -> Даларан -> Аргус",
        ZANDALAR            = isAlliance and "Портал в Боралус (Кул-Тирас) -> Корабль в Зандалар" or "Портал в Зулдазар (Зандалар)",
        KUL_TIRAS           = isAlliance and "Портал в Боралус (Кул-Тирас)" or "Портал в Зулдазар -> Корабль в Кул-Тирас",
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
        local skipCapStep = (playerRegion == "HARANDAR" and targetRegion == "MIDNIGHT_QUELTHALAS")
            or (isAlliance and playerRegion == "KUL_TIRAS" and targetRegion == "ZANDALAR")
            or (not isAlliance and playerRegion == "ZANDALAR" and targetRegion == "KUL_TIRAS")
        local portalAction = DEST_PORTAL_NAMES[targetRegion] or ("Портал в " .. (targetZone or "нужный континент"))
        if not skipCapStep then
            -- Для Пандарии в Штормграде (#84) есть прямой открытый портал AreaPOI #5891 на (68.7, 17.2) у шара пандаренов
            -- (а в Оргриммаре #85 — AreaPOI #5889 на 68.6, 40.7 в Аллее Чести)!
            -- Это также решает проблему, когда при телепорте в Башню магов (48.7, 88.1) игра мгновенно стирает точку из-за нулевого расстояния!
            local stepX, stepY = capX, capY
            local stepNote = string.format("%s: %s", capName, portalAction)
            if targetRegion == "PANDARIA" then
                stepX = isAlliance and 68.7 or 68.6
                stepY = isAlliance and 17.2 or 40.7
                stepNote = isAlliance
                    and "Портал в Деревню Лап'дон (Нефритовый лес) — у шара пандаренов (68.7, 17.2) или в Зале порталов"
                    or "Портал в Деревню Медовой Росы (Нефритовый лес) — Аллея Чести (68.6, 40.7) или в Зале порталов"
            end
            table.insert(steps, {
                mapID = capMapID,
                x = stepX,
                y = stepY,
                zone = isAlliance and "Штормград" or "Оргриммар",
                note = stepNote,
            })
        end
    end

    -- ========================================================================
    -- ЭТАП В: ПРОМЕЖУТОЧНЫЙ ПОРТАЛ / КОРАБЛЬ ХАБА (Харандар, Изумрудный Сон, Зандалар/Кул-Тирас)
    -- ========================================================================
    if isAlliance and targetRegion == "ZANDALAR" and playerRegion ~= "ZANDALAR" then
        table.insert(steps, {
            mapID = 1161,
            x = 70.4,
            y = 26.7,
            zone = "Боралус (Гавань)",
            note = "Корабль «Искупление ветра» (70.4, 26.7): адмирал Джес-Терет — отплытие в Зандалар",
        })
    elseif not isAlliance and targetRegion == "KUL_TIRAS" and playerRegion ~= "KUL_TIRAS" then
        table.insert(steps, {
            mapID = 1165,
            x = 58.4,
            y = 62.6,
            zone = "Дазар'алор (Порт)",
            note = "Корабль «Вой Банши» (58.4, 62.6): капитан Рез'окун — отплытие в Кул-Тирас",
        })
    elseif targetRegion == "HARANDAR" and playerRegion ~= "HARANDAR" then
        -- AreaPOI #8308: Корнистый путь в Харандар (Луносвет #2393 36.7, 68.2 / #2395 47.9, 26.6)
        table.insert(steps, {
            mapID = 2395,
            x = 47.9,
            y = 26.6,
            subMapID = 2393,
            subX = 36.7,
            subY = 68.2,
            zone = "Луносвет (Сады Памяти)",
            note = "Корнистый путь в Харандар (Луносвет 36.7, 68.2)",
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

    local isEN = self:IsEnglish()
    local bName = (beast.enName and isEN and beast.enName) or self:GetBeastName(beast)
    local bZone = (beast.zoneEN and isEN and beast.zoneEN) or self:GetBeastZone(beast)

    if not beast.coords or #beast.coords == 0 or not beast.mapID then
        if beast.mapID then
            print(string.format(
                isEN
                    and "|cff00ff96[BeastCollector]|r Opened map of |cff00ccff%s|r for |cffffd100%s|r."
                    or "|cff00ff96[BeastCollector]|r Открыта карта зоны |cff00ccff%s|r для поиска |cffffd100%s|r.",
                bZone, bName
            ))
        else
            print(string.format(
                isEN
                    and "|cff00ff96[BeastCollector]|r |cffffd100%s|r is located in: |cff00ccff%s|r."
                    or "|cff00ff96[BeastCollector]|r Зверь |cffffd100%s|r обитает в: |cff00ccff%s|r.",
                bName, bZone
            ))
        end
        return
    end

    local pt = beast.coords[coordIndex or 1] or beast.coords[1]
    if not pt then return end
    local ptNote = self:GetCoordNote(pt)

    -- Строим пошаговый маршрут (выход из зоны -> порталы -> финальная точка)
    local steps = self:BuildMultiHopRoute(
        beast.mapID,
        pt.x,
        pt.y,
        bName,
        bZone,
        ptNote and (bName .. " — " .. ptNote) or bName
    )

    self.activePortalRoute = {
        targetName = bName,
        targetMapID = beast.mapID,
        steps = steps,
        currentStep = 1,
    }

    -- Если у зверя несколько точек спавна в финальной зоне и включён TomTom, добавим их на карту финальной зоны
    if _G.TomTom and _G.TomTom.AddWaypoint and coordIndex == nil and #beast.coords > 1 then
        for i, c in ipairs(beast.coords) do
            local cNote = self:GetCoordNote(c)
            local subTitle = string.format("%s [%d/%d: %s]", bName, i, #beast.coords, cNote or bZone or "")
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
        print((isEN and "|cff00ff96[BeastCollector Navigator]|r Full portal route: |cffffffff" or "|cff00ff96[BeastCollector Навигатор]|r Полный маршрут по порталам: |cffffffff") .. table.concat(chainParts, " -> ") .. "|r")
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

        -- Если этот NPC (например, Зандаларский диномант 69795 или Охотник Петрус 167501) дропает фолиант охотника:
        local isEN = self:IsEnglish()
        local dropTomeKey = self.TomeByDropNpcID and self.TomeByDropNpcID[npcID]
        if dropTomeKey and self.TamingTomes and self.TamingTomes[dropTomeKey] then
            local isLearned, tDef = self:IsTomeLearned(dropTomeKey)
            local tries, luckPct = self:GetTomeAttempts(dropTomeKey)
            local tName = self:GetTomeName(tDef)
            local tDrop = self:GetTomeDropRateText(tDef)
            local tExp = self:GetTomeExpectedKillsText(tDef)
            tooltip:AddLine(" ")
            tooltip:AddLine("|TInterface\\ICONS\\INV_Misc_Book_09:14:14:0:0|t |cff00ff96" .. (isEN and "BeastCollector Tome:" or "BeastCollector Фолиант:") .. "|r |cffffd100" .. tName .. "|r")
            if tDrop then
                tooltip:AddLine("   |cffffd100" .. (isEN and "Drop Chance:" or "Шанс выпадения:") .. "|r " .. tDrop, 0.9, 0.9, 0.9, true)
            end
            if tExp then
                tooltip:AddLine("   |cff00ccff" .. (isEN and "Expected Kills:" or "Ожидание:") .. "|r " .. tExp, 0.85, 0.9, 1.0, true)
            end
            tooltip:AddLine(string.format(isEN and "   |cffffaa00Your Attempts (Kills):|r %d (cumulative luck: %.1f%%)" or "   |cffffaa00Твои траи (убито):|r %d (накопленная удача: %.1f%%)", tries, luckPct), 1, 0.85, 0.5, true)
            if isLearned then
                tooltip:AddLine("   |TInterface\\RaidFrame\\ReadyCheck-Ready:14:14:0:0|t |cff00ff96" .. (isEN and "This tome is already learned!" or "Этот фолиант уже изучен!") .. "|r")
            else
                tooltip:AddLine("   |TInterface\\COMMON\\ReputationStar:14:14:0:0:32:32:0:16:0:16|t |cffff8800" .. (isEN and "Not learned yet — kill & loot!" or "Ещё не изучен — убей и залутай!") .. "|r")
            end
        end

        local beast = self.BeastByNpcID[npcID]
        if not beast then return end

        local fam = self.FamilyByID[beast.family]
        local spec = fam and self.PetSpecs[fam.spec]
        local isCollected, colText = self:IsBeastCollected(beast)

        local famLabel = (fam and self:GetFamilyName(fam)) or (isEN and "Tameable Beast" or "Приручаемый зверь")
        if fam and fam.exotic then
            famLabel = famLabel .. (isEN and " |cffc678dd(Exotic — BM Only)|r" or " |cffc678dd(Экзотика — только БМ)|r")
        end

        tooltip:AddLine(" ")
        tooltip:AddDoubleLine(
            "|TInterface\\ICONS\\Ability_Hunter_BeastMastery:14:14:0:0|t |cff00ff96BeastCollector:|r " .. famLabel,
            spec and (spec.color .. self:GetSpecName(spec) .. "|r") or ""
        )
        if fam and self:GetFamilySkill(fam) ~= "" then
            tooltip:AddLine("   |cffffd100" .. (isEN and "Ability:" or "Умеет:") .. "|r " .. self:GetFamilySkill(fam), 0.9, 0.9, 0.9, true)
        end

        if beast.isUniqueModel and beast.isUniqueNpc then
            tooltip:AddLine(self:L("UNIT_TT_UNIQUE_BOTH"), 1.0, 0.55, 1.0, true)
        elseif beast.isUniqueModel then
            tooltip:AddLine(self:L("UNIT_TT_UNIQUE_MODEL"), 1.0, 0.55, 1.0, true)
        elseif beast.isUniqueNpc then
            tooltip:AddLine(self:L("UNIT_TT_UNIQUE_SKIN"), 0.85, 0.65, 1.0, true)
        end

        -- Проверка: почему зверь может не приручаться прямо сейчас (БМ-спек / уровень моба / фолиант)
        if fam and fam.exotic and _G.GetSpecialization then
            local curSpec = GetSpecialization()
            if SafeNotSecret(curSpec) and curSpec ~= 1 then
                tooltip:AddLine("   |TInterface\\DialogFrame\\UI-Dialog-Icon-AlertNew:14:14:0:0|t |cffff4444" .. (isEN and "Cannot tame in current spec: requires Beast Mastery (BM)!" or "Нельзя приручить в текущем спеке: нужен «Повелитель Зверей» (БМ)!") .. "|r", 1, 0.3, 0.3, true)
            end
        end

        local mobLevel = UnitLevel("mouseover")
        local playerLevel = UnitLevel("player")
        if SafeNotSecret(mobLevel) and SafeNotSecret(playerLevel) and type(mobLevel) == "number" and type(playerLevel) == "number" then
            if mobLevel > playerLevel or mobLevel < 0 then
                local lvlStr = (mobLevel < 0) and "??" or tostring(mobLevel)
                tooltip:AddLine("   |TInterface\\DialogFrame\\UI-Dialog-Icon-AlertNew:14:14:0:0|t |cffff4444" .. (isEN and ("Cannot tame right now: creature level (" .. lvlStr .. ") is higher than yours (" .. tostring(playerLevel) .. ")!") or ("Нельзя приручить сейчас: уровень зверя (" .. lvlStr .. ") выше твоего (" .. tostring(playerLevel) .. ")!")) .. "|r", 1, 0.3, 0.3, true)
            end
        end

        if beast.tomes and #beast.tomes > 0 then
            for _, tKey in ipairs(beast.tomes) do
                local isLearned, tome = self:IsTomeLearned(tKey)
                if tome then
                    if isLearned then
                        tooltip:AddLine("   |TInterface\\RaidFrame\\ReadyCheck-Ready:14:14:0:0|t |cff00ff96" .. (isEN and "Tome Learned:" or "Книга изучена:") .. "|r " .. self:GetTomeName(tome), 0.6, 1.0, 0.6, true)
                    else
                        tooltip:AddLine("   |TInterface\\RaidFrame\\ReadyCheck-NotReady:14:14:0:0|t |cffff4444" .. (isEN and "Requires Tome:" or "Требуется книга:") .. "|r " .. self:GetTomeName(tome), 1.0, 0.4, 0.4, true)
                    end
                end
            end
        end
        if isCollected then
            tooltip:AddLine("   |TInterface\\RaidFrame\\ReadyCheck-Ready:14:14:0:0|t |cff00ff96" .. (colText or (isEN and "Collected" or "Уже в коллекции")) .. "|r")
        else
            tooltip:AddLine("   |TInterface\\COMMON\\ReputationStar:14:14:0:0:32:32:0:16:0:16|t |cffff8800" .. (isEN and "You haven't collected this look in your stables yet!" or "Этой модели ещё нет в твоих стойлах!") .. "|r")
        end
        if beast.questOnly then
            tooltip:AddLine(self:L("UNIT_TT_QUEST_ONLY_WARN"), 1.0, 0.35, 0.0, true)
            if not isCollected then
                local uName = SafeNotSecret(UnitName("mouseover")) and UnitName("mouseover") or nil
                self:TriggerQuestBeastAlert(beast, uName, false)
            end
        end
    end)

    -- 2. Тултип при наведении мышки на точку маршрута (на карте мира и на 3D-ромбике)
    local function AppendRouteToTooltip(tip)
        local route = self.activePortalRoute
        if not route or not route.steps or #route.steps == 0 then return end
        if not C_Map or not C_Map.HasUserWaypoint or not C_Map.HasUserWaypoint() then return end

        -- Защита от повторного добавления строк в один и тот же показ тултипа
        for i = 1, tip:NumLines() do
            local leftLine = _G[tip:GetName() .. "TextLeft" .. i]
            local txt = leftLine and leftLine:GetText()
            if SafeNotSecret(txt) and type(txt) == "string" and string.find(txt, "BeastCollector Маршрут", 1, true) then
                return
            end
        end

        local step = route.steps[route.currentStep] or route.steps[#route.steps]
        if not step then return end

        local isEN = self:IsEnglish()
        tip:AddLine(" ")
        tip:AddLine(string.format(
            isEN
                and "|TInterface\\ICONS\\Ability_Hunter_BeastMastery:14:14:0:0|t |cff00ff96BeastCollector Маршрут / Route (Step %d of %d)|r"
                or "|TInterface\\ICONS\\Ability_Hunter_BeastMastery:14:14:0:0|t |cff00ff96BeastCollector Маршрут (Шаг %d из %d)|r",
            route.currentStep, #route.steps
        ))
        tip:AddLine(string.format(isEN and "   |cffffd100Waypoint Target:|r %s" or "   |cffffd100Куда ведёт точка:|r %s", step.note or route.targetName), 1, 1, 1, true)
        if step.zone then
            tip:AddLine(string.format(isEN and "   |cff00ccffLocation:|r %s (%.1f, %.1f)" or "   |cff00ccffЛокация:|r %s (%.1f, %.1f)", step.zone, step.x or 0, step.y or 0), 0.85, 0.9, 1.0, true)
        end
        tip:AddLine(string.format(isEN and "   |cffffaa00Final Destination:|r %s" or "   |cffffaa00Финальная цель:|r %s", route.targetName), 1, 0.9, 0.7, true)

        if #route.steps > 1 then
            tip:AddLine(" ")
            tip:AddLine(isEN and "   |cffffd100Portal Route Chain:|r" or "   |cffffd100Цепочка переходов:|r")
            for idx, st in ipairs(route.steps) do
                if idx < route.currentStep then
                    tip:AddLine(string.format("   |cff66cc66[v] %d. %s|r", idx, st.note or st.zone or ""), 0.5, 0.85, 0.5, true)
                elseif idx == route.currentStep then
                    tip:AddLine(string.format(isEN and "   |cffffd100[->] %d. %s (current)|r" or "   |cffffd100[->] %d. %s (сейчас)|r", idx, st.note or st.zone or ""), 1.0, 0.85, 0.2, true)
                else
                    tip:AddLine(string.format("   |cff999999[ ] %d. %s|r", idx, st.note or st.zone or ""), 0.65, 0.65, 0.65, true)
                end
            end
        end
        tip:Show()
    end

    if _G.WaypointLocationPinMixin and _G.hooksecurefunc then
        pcall(hooksecurefunc, _G.WaypointLocationPinMixin, "OnMouseEnter", function()
            if GameTooltip and GameTooltip:IsShown() then
                AppendRouteToTooltip(GameTooltip)
            end
        end)
    end

    if _G.GameTooltip and _G.GameTooltip.HookScript then
        GameTooltip:HookScript("OnShow", function(tip)
            local l1 = _G.GameTooltipTextLeft1 and _G.GameTooltipTextLeft1:GetText()
            if SafeNotSecret(l1) and type(l1) == "string" then
                local wpTitle = _G.WAYPOINT or "Путевая точка"
                if l1 == wpTitle or string.find(l1, "Путевая точка", 1, true) or string.find(l1, "Отметка на карте", 1, true) or string.find(l1, "Waypoint", 1, true) then
                    AppendRouteToTooltip(tip)
                end
            end
        end)
    end

    if _G.SuperTrackedFrame and _G.SuperTrackedFrame.HookScript then
        pcall(function()
            SuperTrackedFrame:HookScript("OnEnter", function(frame)
                if not self.activePortalRoute then return end
                GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT")
                GameTooltip:SetText(_G.WAYPOINT or "Путевая точка", 1, 0.82, 0)
                AppendRouteToTooltip(GameTooltip)
            end)
            SuperTrackedFrame:HookScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        end)
    end
end

-- ============================================================================
-- ВСПЛЫВАЮЩИЙ БАННЕР-АНОНС КВЕСТОВОГО ЭКСКЛЮЗИВА (В СТИЛЕ MOUNTCOLLECTOR)
-- Появляется только когда рядом/внутри квеста обнаружен НЕприрученный зверь,
-- которого можно приручить ТОЛЬКО во время этой квестовой фазы!
-- ============================================================================
addon.questAlertCooldowns = {}

function addon:EnsureQuestAlertFrame()
    if self.alertFrame then return self.alertFrame end

    local f = CreateFrame("Button", "BeastCollectorAlertFrame", UIParent, "BackdropTemplate")
    f:SetSize(446, 86)
    f:SetPoint("TOP", UIParent, "TOP", 0, -130)
    f:SetFrameStrata("HIGH")
    f:SetToplevel(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    f:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    f:SetBackdropColor(0.06, 0.05, 0.04, 0.96)
    f:SetBackdropBorderColor(1.0, 0.50, 0.10, 1.0)
    f:Hide()

    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
    end)

    local iconBox = CreateFrame("Frame", nil, f, "BackdropTemplate")
    iconBox:SetSize(56, 56)
    iconBox:SetPoint("LEFT", f, "LEFT", 14, 0)
    iconBox:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    iconBox:SetBackdropColor(0, 0, 0, 1)
    iconBox:SetBackdropBorderColor(1.0, 0.55, 0.12, 1.0)
    f.iconBox = iconBox

    local iconTex = iconBox:CreateTexture(nil, "ARTWORK")
    iconTex:SetPoint("TOPLEFT", 1, -1)
    iconTex:SetPoint("BOTTOMRIGHT", -1, 1)
    iconTex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    iconTex:SetTexture(132164)
    f.iconTex = iconTex

    local headerFS = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    headerFS:SetPoint("TOPLEFT", iconBox, "TOPRIGHT", 12, -2)
    headerFS:SetPoint("RIGHT", f, "RIGHT", -28, 0)
    headerFS:SetJustifyH("LEFT")
    headerFS:SetWordWrap(false)
    headerFS:SetTextColor(1.0, 0.52, 0.12, 1.0)
    f.headerFS = headerFS

    local nameFS = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    nameFS:SetPoint("TOPLEFT", headerFS, "BOTTOMLEFT", 0, -4)
    nameFS:SetPoint("RIGHT", f, "RIGHT", -28, 0)
    nameFS:SetJustifyH("LEFT")
    nameFS:SetWordWrap(false)
    nameFS:SetTextColor(1.0, 0.88, 0.25, 1.0)
    f.nameFS = nameFS

    local subFS = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    subFS:SetPoint("TOPLEFT", nameFS, "BOTTOMLEFT", 0, -4)
    subFS:SetPoint("RIGHT", f, "RIGHT", -14, 0)
    subFS:SetJustifyH("LEFT")
    subFS:SetWordWrap(true)
    subFS:SetTextColor(0.95, 0.82, 0.65, 1.0)
    f.subFS = subFS

    local closeBtn = CreateFrame("Button", nil, f, "BackdropTemplate")
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -6, -6)
    closeBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    closeBtn:SetBackdropColor(0.15, 0.10, 0.08, 0.95)
    closeBtn:SetBackdropBorderColor(0.45, 0.30, 0.18, 1.0)
    local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    closeTxt:SetPoint("CENTER", 0, 0)
    closeTxt:SetText("X")
    closeTxt:SetTextColor(0.9, 0.8, 0.7, 1)
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    f:SetScript("OnClick", function(frame, button)
        if button == "RightButton" then
            frame:Hide()
            return
        end
        if frame.beast and addon.OpenBeastInUI then
            addon:OpenBeastInUI(frame.beast)
        end
    end)

    f:SetScript("OnEnter", function(frame)
        frame:SetBackdropBorderColor(1.0, 0.82, 0.20, 1.0)
        GameTooltip:SetOwner(frame, "ANCHOR_BOTTOM")
        GameTooltip:SetText(addon:L("ALERT_TT_TITLE"), 1, 0.55, 0.15)
        GameTooltip:AddLine(addon:L("ALERT_TT_DESC"), 0.95, 0.92, 0.85, true)
        if frame.beast then
            local howTo = addon:GetBeastHowTo(frame.beast)
            if howTo and howTo ~= "" then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(howTo, 1.0, 0.85, 0.45, true)
            end
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(addon:L("ALERT_TT_CLICK_HINT"), 0.7, 0.9, 1.0)
        GameTooltip:Show()
    end)

    f:SetScript("OnLeave", function(frame)
        frame:SetBackdropBorderColor(1.0, 0.50, 0.10, 1.0)
        GameTooltip:Hide()
    end)

    self.alertFrame = f
    return f
end

function addon:TriggerQuestBeastAlert(beast, npcName, forceTest)
    if not beast then return end
    if not forceTest and self:IsBeastCollected(beast) then return end

    local now = GetTime and GetTime() or 0
    local lastTime = self.questAlertCooldowns[beast.id] or 0
    if not forceTest and (now - lastTime) < 120 then
        return
    end
    self.questAlertCooldowns[beast.id] = now

    local f = self:EnsureQuestAlertFrame()
    local fam = self.FamilyByID and self.FamilyByID[beast.family]
    local famName = (fam and self:GetFamilyName(fam)) or ""
    local bName = (npcName and npcName ~= "") and npcName or self:GetBeastName(beast)

    f.beast = beast
    f.iconTex:SetTexture((fam and fam.icon) or 132164)
    f.headerFS:SetText("|TInterface\\GossipFrame\\AvailableQuestIcon:13:13:0:0|t " .. self:L("ALERT_QUEST_HEADER"))
    f.nameFS:SetText(bName .. (famName ~= "" and (" |cff00ff96[" .. famName .. "]|r") or ""))
    f.subFS:SetText(self:L("ALERT_QUEST_SUB"))
    f:Show()

    if PlaySound then
        pcall(PlaySound, 8959, "Master")
    end
    print(self:L("CHAT_QUEST_ALERT_FMT", bName, famName))

    f.alertToken = (f.alertToken or 0) + 1
    local myToken = f.alertToken
    C_Timer.After(18.0, function()
        if f.alertToken == myToken and f:IsShown() then
            f:Hide()
        end
    end)
end

function addon:CheckUnitForQuestBeast(unit)
    if not unit or not UnitExists or not UnitExists(unit) then return end
    local guid = UnitGUID and UnitGUID(unit)
    if not SafeNotSecret(guid) or type(guid) ~= "string" then return end

    local unitType, _, _, _, _, npcIDStr = strsplit("-", guid)
    if unitType ~= "Creature" and unitType ~= "Vehicle" and unitType ~= "Vignette" then return end
    local npcID = tonumber(npcIDStr)
    if not npcID then return end

    local beast = self.BeastByNpcID and self.BeastByNpcID[npcID]
    if beast and beast.questOnly and not self:IsBeastCollected(beast) then
        local uName = UnitName and UnitName(unit)
        local cleanName = (SafeNotSecret(uName) and type(uName) == "string") and uName or nil
        self:TriggerQuestBeastAlert(beast, cleanName, false)
    end
end

-- ============================================================================
-- СОБЫТИЯ ЖИЗНЕННОГО ЦИКЛА И ТРЕКЕР ПОРТАЛЬНОГО МАРШРУТА
-- ============================================================================
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
eventFrame:RegisterEvent("ZONE_CHANGED")
eventFrame:RegisterEvent("PET_STABLE_SHOW")
eventFrame:RegisterEvent("PET_STABLE_UPDATE")
eventFrame:RegisterEvent("UNIT_PET")
eventFrame:RegisterEvent("PET_UI_UPDATE")
eventFrame:RegisterEvent("PET_BAR_UPDATE")
eventFrame:RegisterEvent("LOOT_READY")
eventFrame:RegisterEvent("ENCOUNTER_END")
eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")

if _G.hooksecurefunc and _G.PetAbandon then
    pcall(hooksecurefunc, "PetAbandon", function()
        C_Timer.After(0.25, function() addon:ScanHunterStables("PET_ABANDON") end)
        C_Timer.After(1.00, function() addon:ScanHunterStables("PET_ABANDON") end)
    end)
end

eventFrame:SetScript("OnEvent", function(_, event, arg1, arg2, arg3, arg4, arg5)
    if event == "ADDON_LOADED" and arg1 == addonName then
        addon:InitDB()
        addon:BuildIndices()
        addon:InitTooltips()
        if addon.InitUI then
            addon:InitUI()
        end
    elseif event == "LOOT_READY" then
        addon:HandleLootReadyForTomes()
    elseif event == "ENCOUNTER_END" then
        addon:HandleEncounterEndForTomes(arg1, arg2, arg5)
    elseif event == "PLAYER_ENTERING_WORLD" or event == "PET_STABLE_SHOW" or event == "PET_STABLE_UPDATE" then
        if event == "PLAYER_ENTERING_WORLD" and addon.SetupRoundMinimapButton then
            addon:SetupRoundMinimapButton()
        end
        C_Timer.After(0.5, function()
            if addon.SetupRoundMinimapButton then
                addon:SetupRoundMinimapButton()
            end
            addon:ScanHunterStables(event)
            addon:CheckPortalRouteProgress()
        end)
        if event == "PLAYER_ENTERING_WORLD" then
            -- Повторная проверка после полной прогрузки портала / Башни магов, чтобы точка не пропадала!
            C_Timer.After(1.6, function() addon:CheckPortalRouteProgress() end)
            C_Timer.After(3.0, function() addon:CheckPortalRouteProgress() end)
        end
    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED" then
        C_Timer.After(0.4, function()
            addon:CheckPortalRouteProgress()
        end)
        C_Timer.After(1.4, function()
            addon:CheckPortalRouteProgress()
        end)
    elseif (event == "UNIT_PET" and arg1 == "player") or event == "PET_UI_UPDATE" or event == "PET_BAR_UPDATE" then
        addon:ScanHunterStables(event)
        C_Timer.After(0.35, function() addon:ScanHunterStables(event) end)
    elseif event == "NAME_PLATE_UNIT_ADDED" and arg1 then
        addon:CheckUnitForQuestBeast(arg1)
    elseif event == "PLAYER_TARGET_CHANGED" then
        addon:CheckUnitForQuestBeast("target")
    end
end)
