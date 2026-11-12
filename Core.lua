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
    db.minimap = db.minimap or { hide = false }
    db.settings = db.settings or {
        showUnitTooltips = true,
        onlyUncollected = false,
    }
    self.db = db
end

-- ============================================================================
-- ПРОВЕРКА ФОЛИАНТОВ ПРИРУЧЕНИЯ (КНИГ НАВЫКОВ)
-- ============================================================================
function addon:IsTomeLearned(tomeKey)
    if not tomeKey then return true, nil end
    local tome = self.TamingTomes and self.TamingTomes[tomeKey]
    if not tome then return true, nil end

    if self.db and self.db.manualTomes and self.db.manualTomes[tomeKey] then
        return true, tome
    end

    local _, raceFile = UnitRace("player")
    if tome.autoRaces and raceFile and tome.autoRaces[raceFile] then
        return true, tome
    end

    if tome.spellID then
        if (_G.IsPlayerSpell and IsPlayerSpell(tome.spellID)) or (_G.IsSpellKnown and IsSpellKnown(tome.spellID)) then
            return true, tome
        end
    end

    if tome.questID and C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
        if C_QuestLog.IsQuestFlaggedCompleted(tome.questID) then
            return true, tome
        end
    end

    return false, tome
end

function addon:ToggleManualTome(tomeKey)
    if not tomeKey or not self.db then return end
    self.db.manualTomes = self.db.manualTomes or {}
    if self.db.manualTomes[tomeKey] then
        self.db.manualTomes[tomeKey] = nil
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
-- ПРОКЛАДКА ПУТИ К ЗВЕРЮ (TomTom + Карта Blizzard + Чат)
-- ============================================================================
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

    local title = string.format("BeastCollector: %s (%s)", beast.name, pt.note or beast.zone or "")

    -- 1. Интеграция с TomTom (если включён)
    if _G.TomTom and _G.TomTom.AddWaypoint then
        if coordIndex == nil and #beast.coords > 1 then
            for i, c in ipairs(beast.coords) do
                local subTitle = string.format("%s [%d/%d: %s]", beast.name, i, #beast.coords, c.note or beast.zone)
                pcall(_G.TomTom.AddWaypoint, _G.TomTom, beast.mapID, c.x / 100, c.y / 100, {
                    title = subTitle,
                    persistent = false,
                    minimap = true,
                    world = true,
                })
            end
        else
            pcall(_G.TomTom.AddWaypoint, _G.TomTom, beast.mapID, pt.x / 100, pt.y / 100, {
                title = title,
                persistent = false,
                minimap = true,
                world = true,
            })
        end
    end

    -- 2. Нативная путевая точка Blizzard + авто-отслеживание стрелкой
    if C_Map and C_Map.SetUserWaypoint and _G.UiMapPoint and _G.UiMapPoint.CreateFromCoordinates then
        local canSet = true
        if C_Map.CanSetUserWaypointOnMap then
            local ok, res = pcall(C_Map.CanSetUserWaypointOnMap, beast.mapID)
            if ok then canSet = res end
        end
        if canSet then
            local uiPt = UiMapPoint.CreateFromCoordinates(beast.mapID, pt.x / 100, pt.y / 100)
            pcall(C_Map.SetUserWaypoint, uiPt)
            if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
                pcall(C_SuperTrack.SetSuperTrackedUserWaypoint, true)
            end
        end
    end

    local noteStr = pt.note and (" — " .. pt.note) or ""
    print(string.format(
        "|cff00ff96[BeastCollector]|r Проложен путь к |cffffd100%s|r: |cff00ccff%s (%.1f, %.1f)|r%s",
        beast.name, beast.zone or "Локация", pt.x, pt.y, noteStr
    ))
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

        tooltip:AddLine(" ")
        tooltip:AddDoubleLine(
            "|TInterface\\ICONS\\Ability_Hunter_BeastMastery:14:14:0:0|t |cff00ff96BeastCollector:|r " .. (fam and fam.name or "Приручаемый зверь"),
            spec and (spec.color .. spec.name .. "|r") or ""
        )
        if fam and fam.familySkill then
            tooltip:AddLine("   |cffffd100Умеет:|r " .. fam.familySkill, 0.9, 0.9, 0.9, true)
        end
        if beast.tomes and #beast.tomes > 0 then
            for _, tKey in ipairs(beast.tomes) do
                local tome = self.TamingTomes and self.TamingTomes[tKey]
                if tome then
                    tooltip:AddLine("   |TInterface\\ICONS\\INV_Misc_Book_09:14:14:0:0|t |cffffaa00Книга:|r " .. tome.name, 0.95, 0.85, 0.65, true)
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
-- СОБЫТИЯ ЖИЗНЕННОГО ЦИКЛА
-- ============================================================================
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
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
        end)
    elseif event == "UNIT_PET" and arg1 == "player" then
        addon:ScanHunterStables()
    end
end)
