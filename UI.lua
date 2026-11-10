local _, addon = ...

-- ============================================================================
-- BeastCollector — UI.lua
-- Интерфейс в стиле окна «Коллекции -> Модели» (WardrobeCollectionFrame):
--   1. Шапка с медальоном, прогресс-баром, поиском и фильтром ролей
--   2. Верхний ряд круглых кнопок семейств зверей (61 семейство с прокруткой
--      колёсиком / стрелками < > и быстрой палитрой всех семейств)
--   3. Сетка 6x3 (18 карточек) с живыми 3D-превьюшками (PlayerModel) и пагинацией
--   4. Правый боковой тултип-док (Side Inspector) при клике на превьюшку:
--      крупная вращаемая 3D-модель, что умеет, список мобов, где водится,
--      кнопка «Проложить путь к»
--   5. Интеграция с CollectionsJournal + /bc + иконка у миникарты (LibDBIcon)
-- ============================================================================

local LibStub = _G.LibStub
local LDB = LibStub and LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub and LibStub("LibDBIcon-1.0", true)

local GRID_COLS = 6
local GRID_ROWS = 3
local PAGE_SIZE = GRID_COLS * GRID_ROWS -- 18 моделей на страницу (как в Гардеробе!)

local ICON_READY = "|TInterface\\RaidFrame\\ReadyCheck-Ready:14:14:0:0|t"
local ICON_STAR  = "|TInterface\\COMMON\\ReputationStar:13:13:0:0:32:32:0:16:0:16|t"
local ICON_PAW   = "|TInterface\\ICONS\\Ability_Hunter_BeastMastery:14:14:0:0|t"
local ICON_BOOK  = "|TInterface\\ICONS\\INV_Misc_Book_09:14:14:0:0|t"
local ICON_PIN   = "|TInterface\\ICONS\\Ability_Spy:14:14:0:0|t"

local ui = {
    selectedSpec = "ALL",
    selectedFamily = "ALL",
    selectedRole = "ALL",
    onlyUncollected = false,
    searchText = "",
    currentPage = 1,
    totalPages = 1,
    selectedBeast = nil,
    filteredBeasts = {},
    specGroups = {},
    gridCards = {},
}

local SHORT_FAMILY_NAMES = {
    clefthoof       = "Копытни",
    raptor          = "Ящеры",
    feathermane     = "Шерстоперые",
    lesserdragonkin = "Малые дракониды",
    whiptail        = "Хлыстохвосты",
    carapid         = "Панцирники",
    bat             = "Летучие мыши",
    birdofprey      = "Хищные птицы",
    boar            = "Вепри",
    carrionbird     = "Падальщики",
    cat             = "Кошки и Тигры",
    fox             = "Лисицы",
    gruffhorn       = "Грубороги",
    hopper          = "Прыгуны и Жабы",
    monkey          = "Обезьяны",
    oxen            = "Быки и Яки",
    ray             = "Скаты Пустоты",
    riverbeast      = "Речные чудища",
    scalehide       = "Чешуешкурые",
    tallstrider     = "Долгоноги",
    waterfowl       = "Чирки и Журавли",
    lizard          = "Ящерицы",
}

local function GetShortFamilyName(fam)
    if not fam then return "" end
    if SHORT_FAMILY_NAMES[fam.id] then
        return SHORT_FAMILY_NAMES[fam.id]
    end
    local clean = string.gsub(fam.name or "", "%s*%b()", "")
    return strtrim(clean)
end

local function GetFamilyDropdownText(fam)
    if not fam then return "" end
    local base = GetShortFamilyName(fam)
    local icStr = fam.icon and ("|T" .. tostring(fam.icon) .. ":14:14:0:0:64:64:5:59:5:59|t ") or ""
    local suffix = ""
    if fam.exotic and fam.tome then
        suffix = " |cff00ccff(Экзот, Фолиант)|r"
    elseif fam.exotic then
        suffix = " |cff00ccff(Экзот)|r"
    elseif fam.tome then
        suffix = " |cffffaa00(Фолиант)|r"
    end
    return icStr .. base .. suffix
end

-- ============================================================================
-- БАЗОВЫЕ ХЕЛПЕРЫ ОФОРМЛЕНИЯ В СТИЛЕ ГАРДЕРОБА BLIZZARD / ELVUI
-- ============================================================================
local function ApplyBackdrop(frame, bgR, bgG, bgB, bgA, brR, brG, brB, brA)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(bgR or 0.07, bgG or 0.06, bgB or 0.05, bgA or 0.96)
    frame:SetBackdropBorderColor(brR or 0.28, brG or 0.24, brB or 0.18, brA or 1.0)
end

local function CreateWardrobeButton(parent, width, height, text, isGoldAccent)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, height)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    if isGoldAccent then
        ApplyBackdrop(btn, 0.20, 0.14, 0.04, 0.96, 0.88, 0.68, 0.16, 1.0)
        btn.defaultBg = { 0.20, 0.14, 0.04, 0.96 }
        btn.defaultBorder = { 0.88, 0.68, 0.16, 1.0 }
    else
        ApplyBackdrop(btn, 0.12, 0.11, 0.10, 0.96, 0.30, 0.27, 0.22, 1.0)
        btn.defaultBg = { 0.12, 0.11, 0.10, 0.96 }
        btn.defaultBorder = { 0.30, 0.27, 0.22, 1.0 }
    end

    btn.label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btn.label:SetPoint("LEFT", btn, "LEFT", 4, 0)
    btn.label:SetPoint("RIGHT", btn, "RIGHT", -4, 0)
    btn.label:SetJustifyH("CENTER")
    btn.label:SetWordWrap(false)
    btn.label:SetText(text or "")
    if isGoldAccent then
        btn.label:SetTextColor(1.0, 0.86, 0.22, 1.0)
    else
        btn.label:SetTextColor(0.92, 0.90, 0.85, 1.0)
    end

    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.24, 0.19, 0.08, 0.98)
        self:SetBackdropBorderColor(1.0, 0.82, 0.0, 1.0)
        self.label:SetTextColor(1.0, 0.92, 0.40, 1.0)
    end)
    btn:SetScript("OnLeave", function(self)
        if self.isActiveTab then
            self:SetBackdropColor(0.22, 0.17, 0.06, 0.98)
            self:SetBackdropBorderColor(1.0, 0.82, 0.0, 1.0)
            self.label:SetTextColor(1.0, 0.86, 0.20, 1.0)
        else
            self:SetBackdropColor(unpack(self.defaultBg))
            self:SetBackdropBorderColor(unpack(self.defaultBorder))
            if isGoldAccent then
                self.label:SetTextColor(1.0, 0.86, 0.22, 1.0)
            else
                self.label:SetTextColor(0.92, 0.90, 0.85, 1.0)
            end
        end
    end)

    function btn:SetText(str)
        self.label:SetText(str or "")
    end

    function btn:SetActiveTab(active)
        self.isActiveTab = active
        if active then
            self:SetBackdropColor(0.22, 0.17, 0.06, 0.98)
            self:SetBackdropBorderColor(1.0, 0.82, 0.0, 1.0)
            self.label:SetTextColor(1.0, 0.86, 0.20, 1.0)
        else
            self:SetBackdropColor(unpack(self.defaultBg))
            self:SetBackdropBorderColor(unpack(self.defaultBorder))
            if isGoldAccent then
                self.label:SetTextColor(1.0, 0.86, 0.22, 1.0)
            else
                self.label:SetTextColor(0.92, 0.90, 0.85, 1.0)
            end
        end
    end

    return btn
end

-- ============================================================================
-- ПРОГРЕВ КЭША CREATURE И ТОЧНЫЙ РЕНДЕР 3D-МОДЕЛИ (PlayerModel:SetCreature)
-- ============================================================================
local hiddenWarmTooltip = nil
local function WarmCreatureCache(npcID)
    if not npcID then return end
    if C_TooltipInfo and C_TooltipInfo.GetHyperlink then
        pcall(C_TooltipInfo.GetHyperlink, string.format("unit:Creature-0-0-0-0-%d-0000000000", npcID))
    end
    if not hiddenWarmTooltip then
        hiddenWarmTooltip = CreateFrame("GameTooltip", "BeastCollectorWarmTooltip", nil, "GameTooltipTemplate")
        hiddenWarmTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    end
    pcall(hiddenWarmTooltip.SetHyperlink, hiddenWarmTooltip, string.format("unit:Creature-0-0-0-0-%d", npcID))
end

local function ApplyBeastToModel(modelFrame, beast, facing)
    if not modelFrame or not beast or not beast.npcID then return end
    local targetRotation = facing or 0.42
    modelFrame.currentBeastID = beast.id
    modelFrame.currentNpcID = beast.npcID
    modelFrame.targetRotation = targetRotation

    if not modelFrame.bcHookedLoaded then
        modelFrame.bcHookedLoaded = true
        modelFrame:HookScript("OnModelLoaded", function(self)
            if self.SetRotation and self.targetRotation then
                pcall(self.SetRotation, self, self.targetRotation)
            end
        end)
    end

    WarmCreatureCache(beast.npcID)

    local function TryApplyCreature(clearFirst)
        if not modelFrame:IsShown() or modelFrame.currentBeastID ~= beast.id then return end
        if clearFirst then
            modelFrame:ClearModel()
        end
        pcall(modelFrame.SetCreature, modelFrame, beast.npcID)
        if modelFrame.SetRotation then
            pcall(modelFrame.SetRotation, modelFrame, targetRotation)
        end
    end

    TryApplyCreature(true)

    -- Если запись Creature ещё летела с сервера в кэш, повторяем через 150мс и 450мс
    C_Timer.After(0.15, function()
        if not modelFrame:IsShown() or modelFrame.currentBeastID ~= beast.id then return end
        local fid = modelFrame.GetModelFileID and modelFrame:GetModelFileID() or 0
        if not fid or fid == 0 then
            WarmCreatureCache(beast.npcID)
            TryApplyCreature(false)
        end
    end)

    C_Timer.After(0.45, function()
        if not modelFrame:IsShown() or modelFrame.currentBeastID ~= beast.id then return end
        local fid = modelFrame.GetModelFileID and modelFrame:GetModelFileID() or 0
        if not fid or fid == 0 then
            TryApplyCreature(false)
        end
    end)

    -- Только если через 0.85с модель всё ещё не прогрузилась И есть строго верифицированный DB2 displayID
    if beast.displayID and beast.displayID > 0 then
        C_Timer.After(0.85, function()
            if not modelFrame:IsShown() or modelFrame.currentBeastID ~= beast.id then return end
            local fid = modelFrame.GetModelFileID and modelFrame:GetModelFileID() or 0
            if not fid or fid == 0 then
                pcall(modelFrame.SetDisplayInfo, modelFrame, beast.displayID)
            end
        end)
    end
end

-- Попап для копирования ссылки на Wowhead / Petopia
function addon:ShowCopyLinkPopup(url, titleText)
    if not ui.copyPopup then
        local p = CreateFrame("Frame", "BeastCollectorCopyPopup", UIParent, "BackdropTemplate")
        p:SetSize(460, 88)
        p:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
        p:SetFrameStrata("FULLSCREEN_DIALOG")
        ApplyBackdrop(p, 0.05, 0.05, 0.06, 0.98, 1.0, 0.82, 0.0, 1.0)
        p:EnableMouse(true)

        p.title = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        p.title:SetPoint("TOPLEFT", p, "TOPLEFT", 14, -12)
        p.title:SetTextColor(1.0, 0.82, 0.0, 1.0)

        local closeBtn = CreateWardrobeButton(p, 22, 22, "X", false)
        closeBtn:SetPoint("TOPRIGHT", p, "TOPRIGHT", -8, -8)
        closeBtn:SetScript("OnClick", function() p:Hide() end)

        local ebFrame = CreateFrame("Frame", nil, p, "BackdropTemplate")
        ebFrame:SetPoint("TOPLEFT", p, "TOPLEFT", 14, -36)
        ebFrame:SetPoint("TOPRIGHT", p, "TOPRIGHT", -14, -36)
        ebFrame:SetHeight(26)
        ApplyBackdrop(ebFrame, 0.02, 0.02, 0.03, 1.0, 0.35, 0.35, 0.40, 1.0)

        local eb = CreateFrame("EditBox", nil, ebFrame)
        eb:SetPoint("TOPLEFT", ebFrame, "TOPLEFT", 8, -2)
        eb:SetPoint("BOTTOMRIGHT", ebFrame, "BOTTOMRIGHT", -8, 2)
        eb:SetFontObject("ChatFontNormal")
        eb:SetAutoFocus(false)
        eb:SetScript("OnEscapePressed", function() p:Hide() end)
        p.editBox = eb

        local hint = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        hint:SetPoint("BOTTOMLEFT", p, "BOTTOMLEFT", 14, 8)
        hint:SetText("|cff888888Нажми Ctrl+C, чтобы скопировать ссылку в браузер|r")

        ui.copyPopup = p
    end

    ui.copyPopup.title:SetText(titleText or "Ссылка на зверя")
    ui.copyPopup.editBox:SetText(url or "")
    ui.copyPopup:Show()
    ui.copyPopup.editBox:SetFocus()
    ui.copyPopup.editBox:HighlightText()
end

-- ============================================================================
-- СПИСОК ФИЛЬТРОВ ПО ТРЕЙТАМ И АБИЛКАМ (Отдельная выпадашка слева)
-- ============================================================================
local ROLE_FILTERS = {
    { id = "ALL",          short = "Трейты и абилки",                                                        label = "Все трейты и абилки",                                                                  desc = "Показать всех зверей без фильтра по боевым способностям и трейтам." },
    { id = "BL",           short = "|TInterface\\ICONS\\Spell_Nature_BloodLust:13:13:0:0|t Героизм / БЛ",     label = "|TInterface\\ICONS\\Spell_Nature_BloodLust:14:14:0:0|t Героизм / БЛ (+10% Leech)",     desc = "Трейт Свирепости: Древняя истерия (+30% скорости боя группе/рейду на 40 сек) и +10% к самоисцелению." },
    { id = "TENACITY_DEF", short = "|T236161:13:13:0:0|t Сейв -20% и +5% ХП",                                label = "|T236161:14:14:0:0|t Личный сейв -20% и +5% ХП",                                       desc = "Трейт Упорства: Выживает сильнейший (снижает получаемый урон на 20% на 6 сек) и +5% к запасу здоровья." },
    { id = "CUNNING_FREE", short = "|T236160:13:13:0:0|t Свобода и +8% бега",                                label = "|T236160:14:14:0:0|t Приказ хозяина и +8% бега",                                       desc = "Трейт Хитрости: снимает все эффекты обездвиживания и замедления с цели и даёт +8% к скорости бега." },
    { id = "DISPEL",       short = "|TInterface\\ICONS\\Spell_Nature_NullifyDisease:13:13:0:0|t Диспел магии", label = "|TInterface\\ICONS\\Spell_Nature_NullifyDisease:14:14:0:0|t Диспел магии + исступления", desc = "Абилка семейства: снимает с врага 1 магический бафф и 1 эффект исступления (Духи зверя, Скаты, Олени, Нетопыри, Мотыльки, Чирки, Водомерки, Спороскаты)." },
    { id = "MORTAL",       short = "|TInterface\\ICONS\\Ability_Warrior_SavageBlow:13:13:0:0|t Срез хила -50%", label = "|TInterface\\ICONS\\Ability_Warrior_SavageBlow:14:14:0:0|t Смертельные раны (-50% хила)", desc = "Абилка семейства: уменьшает получаемое целью исцеление на 50% (Дьявозавры, Скорпиды, Ящеры, Гиены, Дикороги, Осы, Падальщики, Опустошители, Речные чудища, Грызуны, Гидры, Ящерицы)." },
    { id = "TANK",         short = "|TInterface\\ICONS\\Ability_Defend:13:13:0:0|t Танко-щит -50%",           label = "|TInterface\\ICONS\\Ability_Defend:14:14:0:0|t Танко-щит (-50% урона по пету)",       desc = "Абилка семейства: мощное снижение урона по самому питомцу на 40–60% (Копытни, Чешуешкурые, Черепахи, Медведи, Жуки, Механизмы, Гончие недр, Панцирники, Кабаны, Гориллы, Мамонты)." },
    { id = "SLOW",         short = "|TInterface\\ICONS\\Spell_Frost_ChainsOfIce:13:13:0:0|t Замедление -50%", label = "|TInterface\\ICONS\\Spell_Frost_ChainsOfIce:14:14:0:0|t Замедление врага (-50% бега)",  desc = "Абилка семейства: замедляет скорость передвижения цели на 50% (Волки, Пауки, Собаки, Крабы, Кроколиски, Хищные птицы, Прыгуаны, Химеры, Черви, Акиры)." },
    { id = "DODGE",        short = "|TInterface\\ICONS\\Spell_Nature_Invisibilty:13:13:0:0|t Уклонение +30%", label = "|TInterface\\ICONS\\Spell_Nature_Invisibilty:14:14:0:0|t Уклонение пета +30% / Стелс",  desc = "Абилка семейства: повышает уклонение питомца на 30% (Кошки, Лисицы, Змеи, Обезьяны, Дракондоры, Шерстоперые, Прыгуны, Крылатые змеи)." },
    { id = "HEAL",         short = "|T236165:13:13:0:0|t Подхил (Дух зверя)",                                label = "|T236165:14:14:0:0|t Духовное исцеление (Подхил)",                                     desc = "Уникальная способность Духов зверя: лечит выбранного союзника или самого охотника и позволяет ходить в стелсе." },
    { id = "EXOTIC",       short = "|TInterface\\ICONS\\Ability_Hunter_BeastMastery:13:13:0:0|t Экзотика (БМ)", label = "|TInterface\\ICONS\\Ability_Hunter_BeastMastery:14:14:0:0|t Экзотика (только БМ)",     desc = "Экзотические семейства, доступные только специализации «Повелитель Зверей»." },
    { id = "TOME",         short = "|TInterface\\ICONS\\INV_Misc_Book_09:13:13:0:0|t С фолиантом",            label = "|TInterface\\ICONS\\INV_Misc_Book_09:14:14:0:0|t Требуется Фолиант приручения",        desc = "Семейства, требующие изучения особых книг приручения (Дикороги, Механизмы, Шерстоперые, Кровавые чудовища, Малые дракониды, Гаргоны)." },
    { id = "RARE_ONLY",    short = ICON_STAR .. " Редкие и Секреты",                                         label = ICON_STAR .. " Только Редкие / Духи / Секретные",                                      desc = "Показать только рарников, секретных питомцев, боссов подземелий и Духов зверя." },
}

local SPEC_ORDER = { "FEROCITY", "CUNNING", "TENACITY" }

local function CloseAllDropdowns()
    if ui.roleMenu then ui.roleMenu:Hide() end
    for _, sg in pairs(ui.specGroups or {}) do
        if sg.menu then sg.menu:Hide() end
    end
end

local RARITY_BADGES = {
    SPIRIT = { text = ICON_STAR .. " Дух Зверя", color = { 0.35, 0.85, 1.0 } },
    SECRET = { text = ICON_STAR .. " Секрет",    color = { 0.82, 0.45, 1.0 } },
    BOSS   = { text = ICON_STAR .. " Босс",      color = { 1.0,  0.55, 0.15 } },
    RARE   = { text = ICON_STAR .. " Рарник",    color = { 1.0,  0.82, 0.15 } },
    COMMON = { text = "Обычный",                 color = { 0.72, 0.72, 0.75 } },
}

-- ============================================================================
-- ПОСТРОЕНИЕ ГЛАВНОГО ОКНА В СТИЛЕ «КОЛЛЕКЦИИ -> МОДЕЛИ» + БОКОВОЙ ДОК
-- ============================================================================
function addon:InitUI()
    if ui.mainFrame then return end

    local f = CreateFrame("Frame", "BeastCollectorFrame", UIParent, "BackdropTemplate")
    f:SetSize(740, 556)
    f:SetPoint("CENTER", UIParent, "CENTER", -140, 20)
    f:SetFrameStrata("HIGH")
    f:SetToplevel(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    ApplyBackdrop(f, 0.09, 0.08, 0.07, 0.98, 0.42, 0.35, 0.22, 1.0)
    f:Hide()
    ui.mainFrame = f

    tinsert(UISpecialFrames, "BeastCollectorFrame")

    -- 1. Верхняя шапка окна (как в Моделях)
    local topHeader = CreateFrame("Frame", nil, f, "BackdropTemplate")
    topHeader:SetPoint("TOPLEFT", f, "TOPLEFT", 2, -2)
    topHeader:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -2)
    topHeader:SetHeight(28)
    ApplyBackdrop(topHeader, 0.14, 0.11, 0.08, 0.98, 0.32, 0.26, 0.16, 1.0)

    local winTitle = topHeader:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    winTitle:SetPoint("CENTER", topHeader, "CENTER", 0, 0)
    winTitle:SetText("|cffffd100Звери охотника — Модели|r")
    ui.winTitle = winTitle

    local closeBtn = CreateWardrobeButton(topHeader, 22, 22, "X", false)
    closeBtn:SetPoint("RIGHT", topHeader, "RIGHT", -4, 0)
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    -- Круглый портрет-медальон в левом верхнем углу (как в CollectionsJournal)
    local portraitBox = CreateFrame("Frame", nil, f, "BackdropTemplate")
    portraitBox:SetSize(54, 54)
    portraitBox:SetPoint("TOPLEFT", f, "TOPLEFT", -8, 8)
    portraitBox:SetFrameLevel(f:GetFrameLevel() + 10)
    ApplyBackdrop(portraitBox, 0.05, 0.05, 0.05, 1.0, 0.85, 0.68, 0.18, 1.0)

    local portraitIcon = portraitBox:CreateTexture(nil, "ARTWORK")
    portraitIcon:SetPoint("TOPLEFT", portraitBox, "TOPLEFT", 3, -3)
    portraitIcon:SetPoint("BOTTOMRIGHT", portraitBox, "BOTTOMRIGHT", -3, 3)
    portraitIcon:SetTexture("Interface\\ICONS\\Ability_Hunter_BeastMastery")
    portraitIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    ui.portraitIcon = portraitIcon

    -- 2. Полоса вкладок ("Все модели" / "Несобранные"), Зелёный прогресс-бар и Поиск
    local subHeader = CreateFrame("Frame", nil, f)
    subHeader:SetPoint("TOPLEFT", f, "TOPLEFT", 52, -34)
    subHeader:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -34)
    subHeader:SetHeight(28)

    local tabAllModels = CreateWardrobeButton(subHeader, 96, 22, "Все модели", false)
    tabAllModels:SetPoint("LEFT", subHeader, "LEFT", 0, 0)
    tabAllModels:SetScript("OnClick", function()
        ui.onlyUncollected = false
        ui.currentPage = 1
        addon:RefreshUI()
    end)
    ui.tabAllModels = tabAllModels

    local tabMissing = CreateWardrobeButton(subHeader, 102, 22, "Несобранные", false)
    tabMissing:SetPoint("LEFT", tabAllModels, "RIGHT", 4, 0)
    tabMissing:SetScript("OnClick", function()
        ui.onlyUncollected = true
        ui.currentPage = 1
        addon:RefreshUI()
    end)
    ui.tabMissing = tabMissing

    -- Зелёный прогресс-бар коллекции по центру
    local progContainer = CreateFrame("Frame", nil, subHeader, "BackdropTemplate")
    progContainer:SetSize(196, 18)
    progContainer:SetPoint("CENTER", subHeader, "CENTER", -14, 0)
    ApplyBackdrop(progContainer, 0.03, 0.03, 0.03, 0.95, 0.35, 0.32, 0.25, 1.0)

    local progBar = CreateFrame("StatusBar", nil, progContainer)
    progBar:SetPoint("TOPLEFT", progContainer, "TOPLEFT", 1, -1)
    progBar:SetPoint("BOTTOMRIGHT", progContainer, "BOTTOMRIGHT", -1, 1)
    progBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    progBar:SetStatusBarColor(0.08, 0.72, 0.12, 0.95)
    progBar:SetMinMaxValues(0, 1)
    progBar:SetValue(0)
    ui.progBar = progBar

    local progText = progBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    progText:SetPoint("CENTER", progContainer, "CENTER", 0, 0)
    progText:SetText("0 / 0")
    ui.progText = progText

    -- Поле Поиска и кнопка сброса справа
    local searchFrame = CreateFrame("Frame", nil, subHeader, "BackdropTemplate")
    searchFrame:SetSize(168, 22)
    searchFrame:SetPoint("RIGHT", subHeader, "RIGHT", 0, 0)
    ApplyBackdrop(searchFrame, 0.03, 0.03, 0.04, 0.98, 0.30, 0.28, 0.22, 1.0)

    local searchBox = CreateFrame("EditBox", nil, searchFrame)
    searchBox:SetPoint("TOPLEFT", searchFrame, "TOPLEFT", 8, -2)
    searchBox:SetPoint("BOTTOMRIGHT", searchFrame, "BOTTOMRIGHT", -22, 2)
    searchBox:SetFontObject("ChatFontNormal")
    searchBox:SetAutoFocus(false)

    local searchPlaceholder = searchFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    searchPlaceholder:SetPoint("LEFT", searchFrame, "LEFT", 8, 0)
    searchPlaceholder:SetText("Поиск зверя / зоны...")

    local clearSearchBtn = CreateWardrobeButton(searchFrame, 16, 16, "x", false)
    clearSearchBtn:SetPoint("RIGHT", searchFrame, "RIGHT", -3, 0)
    clearSearchBtn:Hide()
    clearSearchBtn:SetScript("OnClick", function()
        searchBox:SetText("")
        searchBox:ClearFocus()
    end)

    searchBox:SetScript("OnTextChanged", function(self)
        local txt = self:GetText() or ""
        ui.searchText = strtrim(string.lower(txt))
        if txt ~= "" then
            searchPlaceholder:Hide()
            clearSearchBtn:Show()
        else
            searchPlaceholder:Show()
            clearSearchBtn:Hide()
        end
        ui.currentPage = 1
        addon:RefreshUI()
    end)
    searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    searchBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

    -- 3. Внутреннее полотно Гардероба (тёмно-шоколадный фон, как в «Моделях»)
    local wardrobeCanvas = CreateFrame("Frame", nil, f, "BackdropTemplate")
    wardrobeCanvas:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -66)
    wardrobeCanvas:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 10)
    ApplyBackdrop(wardrobeCanvas, 0.08, 0.07, 0.06, 0.96, 0.28, 0.24, 0.18, 1.0)
    ui.wardrobeCanvas = wardrobeCanvas

    wardrobeCanvas:EnableMouseWheel(true)
    wardrobeCanvas:SetScript("OnMouseWheel", function(_, delta)
        if delta < 0 and ui.currentPage < ui.totalPages then
            ui.currentPage = ui.currentPage + 1
            addon:RefreshUI()
        elseif delta > 0 and ui.currentPage > 1 then
            ui.currentPage = ui.currentPage - 1
            addon:RefreshUI()
        end
    end)

    -- 4. Верхний ряд внутри полотна:
    --    Слева — отдельная выпадашка с фильтрами по трейтам и абилкам
    --    Справа — кружок «Все» + 3 кружка классов питомцев (Свирепость, Хитрость, Упорство)
    --             с отдельной выпадашкой семейств у каждого кружка!
    local filterBar = CreateFrame("Frame", nil, wardrobeCanvas)
    filterBar:SetPoint("TOPLEFT", wardrobeCanvas, "TOPLEFT", 12, -10)
    filterBar:SetPoint("TOPRIGHT", wardrobeCanvas, "TOPRIGHT", -12, -10)
    filterBar:SetHeight(36)

    local roleDropdownBtn = CreateWardrobeButton(filterBar, 184, 26, "Трейты и абилки [v]", false)
    roleDropdownBtn:SetPoint("LEFT", filterBar, "LEFT", 0, 0)
    ui.roleDropdownBtn = roleDropdownBtn

    local roleMenu = CreateFrame("Frame", nil, roleDropdownBtn, "BackdropTemplate")
    roleMenu:SetSize(284, #ROLE_FILTERS * 21 + 8)
    roleMenu:SetPoint("TOPLEFT", roleDropdownBtn, "BOTTOMLEFT", 0, -2)
    roleMenu:SetFrameStrata("FULLSCREEN_DIALOG")
    roleMenu:SetClampedToScreen(true)
    ApplyBackdrop(roleMenu, 0.05, 0.05, 0.06, 0.99, 0.85, 0.68, 0.18, 1.0)
    roleMenu:Hide()
    ui.roleMenu = roleMenu
    ui.roleMenuItems = {}

    for idx, rf in ipairs(ROLE_FILTERS) do
        local item = CreateWardrobeButton(roleMenu, 276, 19, rf.label, false)
        item:SetPoint("TOPLEFT", roleMenu, "TOPLEFT", 4, -4 - (idx - 1) * 21)
        item.label:SetJustifyH("LEFT")
        item.roleID = rf.id
        item:SetScript("OnEnter", function(self)
            self:SetBackdropColor(0.24, 0.19, 0.08, 0.98)
            self:SetBackdropBorderColor(1.0, 0.82, 0.0, 1.0)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(rf.label, 1, 0.82, 0)
            GameTooltip:AddLine(rf.desc, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        item:SetScript("OnLeave", function(self)
            if self.isActiveTab then
                self:SetBackdropColor(0.22, 0.17, 0.06, 0.98)
                self:SetBackdropBorderColor(1.0, 0.82, 0.0, 1.0)
            else
                self:SetBackdropColor(unpack(self.defaultBg))
                self:SetBackdropBorderColor(unpack(self.defaultBorder))
            end
            GameTooltip:Hide()
        end)
        item:SetScript("OnClick", function()
            ui.selectedRole = rf.id
            ui.currentPage = 1
            ui.selectedBeast = nil
            CloseAllDropdowns()
            addon:RefreshUI()
        end)
        ui.roleMenuItems[idx] = item
    end

    roleDropdownBtn:SetScript("OnClick", function(_, button)
        if button == "RightButton" then
            ui.selectedRole = "ALL"
            ui.currentPage = 1
            ui.selectedBeast = nil
            CloseAllDropdowns()
            addon:RefreshUI()
        elseif roleMenu:IsShown() then
            CloseAllDropdowns()
        else
            CloseAllDropdowns()
            roleMenu:Show()
        end
    end)

    -- Хелпер создания круглой иконки в стиле слотов Гардероба
    local function CreateRoundSpecIcon(parent, size, iconTexture)
        local btn = CreateFrame("Button", nil, parent)
        btn:SetSize(size, size)
        btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetTexture("Interface\\Buttons\\UI-EmptySlot-Disabled")

        local ic = btn:CreateTexture(nil, "ARTWORK")
        ic:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
        ic:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
        ic:SetTexture(iconTexture)
        ic:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        if ic.SetMask then
            ic:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask")
        end
        btn.icon = ic

        local ring = btn:CreateTexture(nil, "OVERLAY")
        ring:SetPoint("TOPLEFT", btn, "TOPLEFT", -2, 2)
        ring:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 2, -2)
        ring:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
        ring:SetTexCoord(0, 0.6, 0, 0.6)
        btn.ring = ring

        local glow = btn:CreateTexture(nil, "OVERLAY", nil, 2)
        glow:SetPoint("TOPLEFT", btn, "TOPLEFT", -2, 2)
        glow:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 2, -2)
        glow:SetTexture("Interface\\Buttons\\CheckButtonHilight")
        glow:SetBlendMode("ADD")
        glow:Hide()
        btn.glow = glow

        return btn
    end

    -- Кружок «Все 61 семейство» (быстрый сброс выбора специализации и семейства)
    local allSpecCircle = CreateRoundSpecIcon(filterBar, 30, "Interface\\ICONS\\Ability_Hunter_BeastMastery")
    allSpecCircle:SetPoint("LEFT", roleDropdownBtn, "RIGHT", 10, 0)
    ui.allSpecCircle = allSpecCircle

    allSpecCircle:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Все семейства зверей (61)", 1, 0.85, 0.2)
        GameTooltip:AddLine("Показать все 2 635 приручаемых моделей во всех трёх классах питомцев (Свирепость, Хитрость, Упорство).", 0.9, 0.9, 0.9, true)
        GameTooltip:Show()
    end)
    allSpecCircle:SetScript("OnLeave", function() GameTooltip:Hide() end)
    allSpecCircle:SetScript("OnClick", function()
        ui.selectedSpec = "ALL"
        ui.selectedFamily = "ALL"
        ui.currentPage = 1
        ui.selectedBeast = nil
        CloseAllDropdowns()
        addon:RefreshUI()
    end)

    -- Три кружка классов петов (Свирепость, Хитрость, Упорство) + отдельная выпадашка семейств у каждого кружка!
    wipe(ui.specGroups)
    local prevAnchor = allSpecCircle

    for specIdx, specID in ipairs(SPEC_ORDER) do
        local specDef = addon.PetSpecs and addon.PetSpecs[specID]
        if specDef then
            local famsInSpec = {}
            for _, fam in ipairs(addon.Families or {}) do
                if fam.spec == specID then
                    table.insert(famsInSpec, fam)
                end
            end
            table.sort(famsInSpec, function(a, b)
                return GetShortFamilyName(a) < GetShortFamilyName(b)
            end)

            local circleBtn = CreateRoundSpecIcon(filterBar, 30, specDef.icon)
            circleBtn:SetPoint("LEFT", prevAnchor, "RIGHT", 10, 0)

            local dropBtn = CreateWardrobeButton(filterBar, 112, 24, specDef.name .. " [v]", false)
            dropBtn:SetPoint("LEFT", circleBtn, "RIGHT", 3, 0)
            prevAnchor = dropBtn

            local totalRows = 1 + #famsInSpec
            local menuW = 258
            local menuH = 8 + totalRows * 19 + 4
            local specMenu = CreateFrame("Frame", nil, dropBtn, "BackdropTemplate")
            specMenu:SetSize(menuW, menuH)
            if specIdx == #SPEC_ORDER then
                specMenu:SetPoint("TOPRIGHT", dropBtn, "BOTTOMRIGHT", 0, -3)
            else
                specMenu:SetPoint("TOPLEFT", circleBtn, "BOTTOMLEFT", 0, -3)
            end
            specMenu:SetFrameStrata("FULLSCREEN_DIALOG")
            specMenu:SetClampedToScreen(true)
            ApplyBackdrop(specMenu, 0.05, 0.05, 0.06, 0.99, 0.88, 0.68, 0.18, 1.0)
            specMenu:EnableMouse(true)
            specMenu:Hide()

            local menuBtns = {}

            -- Верхний пункт в выпадашке: «Все — Свирепость / Хитрость / Упорство»
            local allSpecItem = CreateWardrobeButton(specMenu, menuW - 8, 19, string.format("|T%s:14:14:0:0|t Все — %s (%d)", tostring(specDef.icon), specDef.name, #famsInSpec), true)
            allSpecItem:SetPoint("TOPLEFT", specMenu, "TOPLEFT", 4, -4)
            allSpecItem.label:SetJustifyH("LEFT")
            allSpecItem.familyID = "ALL"
            allSpecItem:SetScript("OnEnter", function(self)
                self:SetBackdropColor(0.26, 0.20, 0.08, 0.98)
                self:SetBackdropBorderColor(1.0, 0.82, 0.0, 1.0)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Все семейства: " .. specDef.color .. specDef.name .. "|r", 1, 0.85, 0.2)
                GameTooltip:AddLine("Активно: |cffffd100" .. specDef.activeName .. "|r", 1, 1, 1, true)
                GameTooltip:AddLine("Пассивно: |cff00ff96" .. specDef.passiveName .. "|r — " .. specDef.passiveDesc, 0.85, 0.85, 0.85, true)
                GameTooltip:Show()
            end)
            allSpecItem:SetScript("OnLeave", function(self)
                if self.isActiveTab then
                    self:SetBackdropColor(0.22, 0.17, 0.06, 0.98)
                    self:SetBackdropBorderColor(1.0, 0.82, 0.0, 1.0)
                else
                    self:SetBackdropColor(unpack(self.defaultBg))
                    self:SetBackdropBorderColor(unpack(self.defaultBorder))
                end
                GameTooltip:Hide()
            end)
            allSpecItem:SetScript("OnClick", function()
                ui.selectedSpec = specID
                ui.selectedFamily = "ALL"
                ui.currentPage = 1
                ui.selectedBeast = nil
                CloseAllDropdowns()
                addon:RefreshUI()
            end)
            table.insert(menuBtns, allSpecItem)

            -- Алфавитный список семейств этого класса (Волки, Пауки и т.д. с (Экзот) и (Фолиант) в скобках)
            for fIdx, famDef in ipairs(famsInSpec) do
                local fBtn = CreateWardrobeButton(specMenu, menuW - 8, 18, GetFamilyDropdownText(famDef), false)
                fBtn:SetPoint("TOPLEFT", specMenu, "TOPLEFT", 4, -8 - fIdx * 19)
                fBtn.label:SetJustifyH("LEFT")
                fBtn.familyID = famDef.id
                fBtn.famDef = famDef

                fBtn:SetScript("OnEnter", function(self)
                    self:SetBackdropColor(0.24, 0.19, 0.08, 0.98)
                    self:SetBackdropBorderColor(1.0, 0.82, 0.0, 1.0)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(famDef.name, 1, 0.85, 0.2)
                    local exTag = famDef.exotic and " |cff00ccff(Экзотика — только БМ)|r" or ""
                    GameTooltip:AddLine("Специализация: " .. specDef.color .. specDef.name .. "|r" .. exTag, 0.9, 0.9, 0.9)
                    GameTooltip:AddLine("Активно: |cffffd100" .. specDef.activeName .. "|r", 0.85, 0.85, 0.85)
                    if famDef.familySkill then
                        GameTooltip:AddLine("Способность: |cff00ff96" .. famDef.familySkill .. "|r", 1, 1, 1, true)
                    end
                    if famDef.familyDesc then
                        GameTooltip:AddLine(" ")
                        GameTooltip:AddLine(famDef.familyDesc, 0.85, 0.85, 0.85, true)
                    end
                    if famDef.tome then
                        local learned, tome = addon:IsTomeLearned(famDef.tome)
                        if tome then
                            GameTooltip:AddLine(" ")
                            if learned then
                                GameTooltip:AddLine(ICON_BOOK .. " Фолиант изучен: " .. tome.name, 0.2, 1.0, 0.4)
                            else
                                GameTooltip:AddLine(ICON_BOOK .. " Требуется: " .. tome.name, 1.0, 0.4, 0.2)
                            end
                        end
                    end
                    GameTooltip:Show()
                end)

                fBtn:SetScript("OnLeave", function(self)
                    if self.isActiveTab then
                        self:SetBackdropColor(0.22, 0.17, 0.06, 0.98)
                        self:SetBackdropBorderColor(1.0, 0.82, 0.0, 1.0)
                    else
                        self:SetBackdropColor(unpack(self.defaultBg))
                        self:SetBackdropBorderColor(unpack(self.defaultBorder))
                    end
                    GameTooltip:Hide()
                end)

                fBtn:SetScript("OnClick", function(self)
                    ui.selectedSpec = specID
                    ui.selectedFamily = self.familyID
                    ui.currentPage = 1
                    ui.selectedBeast = nil
                    CloseAllDropdowns()
                    addon:RefreshUI()
                end)

                table.insert(menuBtns, fBtn)
            end

            local function ShowSpecTooltip(owner)
                GameTooltip:SetOwner(owner, "ANCHOR_TOP")
                GameTooltip:SetText(specDef.color .. specDef.name .. "|r (" .. #famsInSpec .. " семейств)", 1, 0.85, 0.2)
                GameTooltip:AddLine("Активно: |cffffd100" .. specDef.activeName .. "|r — " .. specDef.activeDesc, 0.9, 0.9, 0.9, true)
                GameTooltip:AddLine("Пассивно: |cff00ff96" .. specDef.passiveName .. "|r — " .. specDef.passiveDesc, 0.85, 0.85, 0.85, true)
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("|cffffd100ЛКМ:|r Выбрать семейство из списка  |  |cffffd100ПКМ:|r Сбросить", 0.7, 0.9, 1.0)
                GameTooltip:Show()
            end

            circleBtn:SetScript("OnEnter", ShowSpecTooltip)
            circleBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

            local function ToggleSpecMenu(_, button)
                if button == "RightButton" then
                    ui.selectedSpec = "ALL"
                    ui.selectedFamily = "ALL"
                    ui.currentPage = 1
                    ui.selectedBeast = nil
                    CloseAllDropdowns()
                    addon:RefreshUI()
                elseif specMenu:IsShown() then
                    CloseAllDropdowns()
                else
                    CloseAllDropdowns()
                    specMenu:Show()
                end
            end

            circleBtn:SetScript("OnClick", function(_, button)
                if button == "RightButton" then
                    ToggleSpecMenu(nil, "RightButton")
                else
                    local wasShown = specMenu:IsShown()
                    ui.selectedSpec = specID
                    ui.selectedFamily = "ALL"
                    ui.currentPage = 1
                    ui.selectedBeast = nil
                    CloseAllDropdowns()
                    if not wasShown then
                        specMenu:Show()
                    end
                    addon:RefreshUI()
                end
            end)

            dropBtn:SetScript("OnClick", ToggleSpecMenu)

            ui.specGroups[specID] = {
                specID = specID,
                specDef = specDef,
                circleBtn = circleBtn,
                dropBtn = dropBtn,
                menu = specMenu,
                menuBtns = menuBtns,
            }
        end
    end

    -- 5. ЦЕНТРАЛЬНАЯ СЕТКА 6x3 = 18 ПРЕВЬЮ-КАРТОЧЕК С 3D-МОДЕЛЯМИ (PlayerModel)
    local gridContainer = CreateFrame("Frame", nil, wardrobeCanvas)
    gridContainer:SetPoint("TOPLEFT", wardrobeCanvas, "TOPLEFT", 20, -54)
    gridContainer:SetSize(680, 386)
    ui.gridContainer = gridContainer

    local cardW, cardH = 104, 120
    local gapX, gapY = 11, 12

    for idx = 1, PAGE_SIZE do
        local col = (idx - 1) % GRID_COLS
        local row = math.floor((idx - 1) / GRID_COLS)

        local card = CreateFrame("Button", nil, gridContainer, "BackdropTemplate")
        card:SetSize(cardW, cardH)
        card:SetPoint("TOPLEFT", gridContainer, "TOPLEFT", col * (cardW + gapX), -row * (cardH + gapY))
        card:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        ApplyBackdrop(card, 0.04, 0.04, 0.05, 0.96, 0.24, 0.22, 0.18, 1.0)

        -- 3D-превью с шаблоном ModelWithControlsTemplate (гарантированная инициализация 3D-камеры!)
        local model = CreateFrame("PlayerModel", nil, card, "ModelWithControlsTemplate")
        model:SetPoint("TOPLEFT", card, "TOPLEFT", 3, -3)
        model:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -3, 22)
        if model.controlFrame then
            model.controlFrame:Hide()
        end
        model:SetScript("OnEnter", nil)
        model:SetScript("OnLeave", nil)
        model:EnableMouse(false)
        model:EnableMouseWheel(false)
        card.model = model

        local nameBg = card:CreateTexture(nil, "OVERLAY")
        nameBg:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 1, 1)
        nameBg:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -1, 1)
        nameBg:SetHeight(21)
        nameBg:SetColorTexture(0.02, 0.02, 0.03, 0.88)

        local nameFS = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        nameFS:SetPoint("LEFT", nameBg, "LEFT", 4, 0)
        nameFS:SetPoint("RIGHT", nameBg, "RIGHT", -4, 0)
        nameFS:SetJustifyH("CENTER")
        nameFS:SetWordWrap(false)
        card.nameFS = nameFS

        local roleBadge = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        roleBadge:SetPoint("TOPLEFT", card, "TOPLEFT", 5, -4)
        roleBadge:SetJustifyH("LEFT")
        card.roleBadge = roleBadge

        local checkBadge = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        checkBadge:SetPoint("TOPRIGHT", card, "TOPRIGHT", -4, -4)
        checkBadge:SetText(ICON_READY)
        checkBadge:Hide()
        card.checkBadge = checkBadge

        card:SetScript("OnEnter", function(self)
            if not self.beast then return end
            self:SetBackdropBorderColor(1.0, 0.85, 0.20, 1.0)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local fam = addon.FamilyByID[self.beast.family]
            local spec = fam and addon.PetSpecs[fam.spec]
            GameTooltip:SetText(self.beast.name, 1, 0.85, 0.2)
            if self.beast.subTitle then
                GameTooltip:AddLine(self.beast.subTitle, 0.8, 0.8, 0.85, true)
            end
            if fam then
                GameTooltip:AddDoubleLine("Семейство: " .. fam.name, spec and (spec.color .. spec.name .. "|r") or "")
                GameTooltip:AddLine("Умеет: |cff00ff96" .. (fam.familySkill or "") .. "|r", 0.9, 0.9, 0.9, true)
            end
            if self.beast.zone then
                GameTooltip:AddLine("Где искать: |cff00ccff" .. self.beast.zone .. "|r", 0.9, 0.9, 0.9)
            end
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("|cffffd100ЛКМ:|r Открыть 3D-досье справа  |  |cffffd100ПКМ:|r Проложить путь", 0.7, 0.9, 1.0)
            GameTooltip:Show()
        end)

        card:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
            addon:UpdateCardBorder(self)
        end)

        card:SetScript("OnClick", function(self, button)
            if not self.beast then return end
            CloseAllDropdowns()
            ui.selectedBeast = self.beast
            if ui.sideDock and not ui.sideDock:IsShown() then
                ui.sideDock:Show()
            end
            addon:RefreshUI()
            if button == "RightButton" then
                addon:NavigateToBeast(self.beast, 1, IsShiftKeyDown())
            end
        end)

        ui.gridCards[idx] = card
    end

    -- 6. Нижний бар пагинации («Стр. 1/147  [<] [>]»)
    local pageBar = CreateFrame("Frame", nil, wardrobeCanvas)
    pageBar:SetPoint("BOTTOM", wardrobeCanvas, "BOTTOM", 0, 12)
    pageBar:SetSize(260, 26)

    local pageText = pageBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    pageText:SetPoint("LEFT", pageBar, "LEFT", 16, 0)
    pageText:SetText("Стр. 1/1")
    ui.pageText = pageText

    local prevBtn = CreateWardrobeButton(pageBar, 28, 24, "<", false)
    prevBtn:SetPoint("LEFT", pageText, "RIGHT", 12, 0)
    prevBtn:SetScript("OnClick", function()
        if ui.currentPage > 1 then
            ui.currentPage = ui.currentPage - 1
            addon:RefreshUI()
        end
    end)
    ui.prevBtn = prevBtn

    local nextBtn = CreateWardrobeButton(pageBar, 28, 24, ">", false)
    nextBtn:SetPoint("LEFT", prevBtn, "RIGHT", 6, 0)
    nextBtn:SetScript("OnClick", function()
        if ui.currentPage < ui.totalPages then
            ui.currentPage = ui.currentPage + 1
            addon:RefreshUI()
        end
    end)
    ui.nextBtn = nextBtn

    -- ========================================================================
    -- 7. БОКОВОЙ ТУЛТИП-ДОК СПРАВА ПРИ КЛИКЕ НА ПРЕВЬЮШКУ (SIDE INSPECTOR)
    -- ========================================================================
    local dock = CreateFrame("Frame", "BeastCollectorSideDock", f, "BackdropTemplate")
    dock:SetWidth(374)
    dock:SetPoint("TOPLEFT", f, "TOPRIGHT", 4, 0)
    dock:SetPoint("BOTTOMLEFT", f, "BOTTOMRIGHT", 4, 0)
    ApplyBackdrop(dock, 0.06, 0.06, 0.07, 0.98, 0.85, 0.68, 0.18, 1.0)
    ui.sideDock = dock

    local dockHeader = CreateFrame("Frame", nil, dock, "BackdropTemplate")
    dockHeader:SetPoint("TOPLEFT", dock, "TOPLEFT", 2, -2)
    dockHeader:SetPoint("TOPRIGHT", dock, "TOPRIGHT", -2, -2)
    dockHeader:SetHeight(28)
    ApplyBackdrop(dockHeader, 0.14, 0.11, 0.08, 0.98, 0.32, 0.26, 0.16, 1.0)

    local dockTitle = dockHeader:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dockTitle:SetPoint("CENTER", dockHeader, "CENTER", 0, 0)
    dockTitle:SetText(ICON_PAW .. " |cffffd100Досье питомца|r")

    local dockClose = CreateWardrobeButton(dockHeader, 22, 22, "X", false)
    dockClose:SetPoint("RIGHT", dockHeader, "RIGHT", -4, 0)
    dockClose:SetScript("OnClick", function() dock:Hide() end)

    -- Крупная интерактивная 3D-примерочная зверя
    local bigModelBox = CreateFrame("Frame", nil, dock, "BackdropTemplate")
    bigModelBox:SetPoint("TOPLEFT", dock, "TOPLEFT", 10, -36)
    bigModelBox:SetPoint("TOPRIGHT", dock, "TOPRIGHT", -10, -36)
    bigModelBox:SetHeight(178)
    ApplyBackdrop(bigModelBox, 0.03, 0.03, 0.04, 0.98, 0.30, 0.26, 0.18, 1.0)

    local bigModel = CreateFrame("PlayerModel", nil, bigModelBox, "ModelWithControlsTemplate")
    bigModel:SetPoint("TOPLEFT", bigModelBox, "TOPLEFT", 3, -3)
    bigModel:SetPoint("BOTTOMRIGHT", bigModelBox, "BOTTOMRIGHT", -3, 3)
    bigModel.facing = 0.45
    bigModel.zoomLevel = 0.1
    bigModel.minZoom = -0.5
    bigModel.maxZoom = 1.5
    bigModel:EnableMouse(true)
    bigModel:EnableMouseWheel(true)
    ui.bigModel = bigModel

    local rotateHint = bigModelBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    rotateHint:SetPoint("BOTTOMRIGHT", bigModelBox, "BOTTOMRIGHT", -6, 4)
    rotateHint:SetText("ЛКМ: вращать • Колёсико: зум")

    local dockStatusBadge = bigModelBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dockStatusBadge:SetPoint("TOPLEFT", bigModelBox, "TOPLEFT", 8, -8)
    ui.dockStatusBadge = dockStatusBadge

    local dockRarityBadge = bigModelBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dockRarityBadge:SetPoint("TOPRIGHT", bigModelBox, "TOPRIGHT", -8, -8)
    ui.dockRarityBadge = dockRarityBadge

    local dockBeastName = dock:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    dockBeastName:SetPoint("TOPLEFT", bigModelBox, "BOTTOMLEFT", 2, -8)
    dockBeastName:SetPoint("RIGHT", dock, "RIGHT", -12, 0)
    dockBeastName:SetJustifyH("LEFT")
    dockBeastName:SetWordWrap(false)
    dockBeastName:SetTextColor(1.0, 0.85, 0.2, 1.0)
    ui.dockBeastName = dockBeastName

    local dockSubTitle = dock:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    dockSubTitle:SetPoint("TOPLEFT", dockBeastName, "BOTTOMLEFT", 0, -2)
    dockSubTitle:SetPoint("RIGHT", dock, "RIGHT", -12, 0)
    dockSubTitle:SetJustifyH("LEFT")
    dockSubTitle:SetWordWrap(false)
    dockSubTitle:SetTextColor(0.78, 0.78, 0.82, 1.0)
    ui.dockSubTitle = dockSubTitle

    -- Прокручиваемое досье (Что умеет + Фолиант + Где водится + Список мобов + Как приручить)
    local infoBox = CreateFrame("Frame", nil, dock, "BackdropTemplate")
    infoBox:SetPoint("TOPLEFT", dockSubTitle, "BOTTOMLEFT", -2, -8)
    infoBox:SetPoint("BOTTOMRIGHT", dock, "BOTTOMRIGHT", -10, 68)
    ApplyBackdrop(infoBox, 0.04, 0.04, 0.05, 0.96, 0.24, 0.22, 0.18, 1.0)

    local infoScroll = CreateFrame("ScrollFrame", "BeastCollectorDockScroll", infoBox, "UIPanelScrollFrameTemplate")
    infoScroll:SetPoint("TOPLEFT", infoBox, "TOPLEFT", 8, -8)
    infoScroll:SetPoint("BOTTOMRIGHT", infoBox, "BOTTOMRIGHT", -26, 8)

    local infoContent = CreateFrame("Frame", nil, infoScroll)
    infoContent:SetSize(316, 1)
    infoScroll:SetScrollChild(infoContent)
    ui.infoContent = infoContent

    local detailsFS = infoContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    detailsFS:SetPoint("TOPLEFT", infoContent, "TOPLEFT", 0, 0)
    detailsFS:SetWidth(312)
    detailsFS:SetJustifyH("LEFT")
    detailsFS:SetJustifyV("TOP")
    detailsFS:SetWordWrap(true)
    if detailsFS.SetSpacing then
        detailsFS:SetSpacing(3)
    end
    ui.detailsFS = detailsFS

    -- НИЖНИЕ КНОПКИ В БОКОВОМ ДОКЕ
    local btnNavigate = CreateWardrobeButton(dock, 354, 26, ICON_PIN .. " Проложить путь к зверю (TomTom + Карта)", true)
    btnNavigate:SetPoint("BOTTOMLEFT", dock, "BOTTOMLEFT", 10, 36)
    btnNavigate:SetScript("OnClick", function()
        if ui.selectedBeast then
            addon:NavigateToBeast(ui.selectedBeast, nil, false)
        end
    end)
    ui.btnNavigate = btnNavigate

    local btnShowMap = CreateWardrobeButton(dock, 88, 22, "На карте", false)
    btnShowMap:SetPoint("BOTTOMLEFT", dock, "BOTTOMLEFT", 10, 10)
    btnShowMap:SetScript("OnClick", function()
        if ui.selectedBeast then
            addon:NavigateToBeast(ui.selectedBeast, 1, true)
        end
    end)

    local btnToggleCol = CreateWardrobeButton(dock, 118, 22, ICON_READY .. " Отметить своим", false)
    btnToggleCol:SetPoint("LEFT", btnShowMap, "RIGHT", 4, 0)
    btnToggleCol:SetScript("OnClick", function()
        if ui.selectedBeast then
            addon:ToggleManualCollected(ui.selectedBeast)
        end
    end)
    ui.btnToggleCol = btnToggleCol

    local btnWowhead = CreateWardrobeButton(dock, 70, 22, "Wowhead", false)
    btnWowhead:SetPoint("LEFT", btnToggleCol, "RIGHT", 4, 0)
    btnWowhead:SetScript("OnClick", function()
        if ui.selectedBeast and ui.selectedBeast.npcID then
            local url = string.format("https://www.wowhead.com/ru/npc=%d", ui.selectedBeast.npcID)
            addon:ShowCopyLinkPopup(url, ui.selectedBeast.name .. " — Wowhead")
        end
    end)

    local btnPetopia = CreateWardrobeButton(dock, 66, 22, "Petopia", false)
    btnPetopia:SetPoint("LEFT", btnWowhead, "RIGHT", 4, 0)
    btnPetopia:SetScript("OnClick", function()
        if ui.selectedBeast then
            local slug = ui.selectedBeast.lookID or ui.selectedBeast.id
            local url = string.format("https://www.wow-petopia.com/look.php?id=%s", tostring(slug))
            addon:ShowCopyLinkPopup(url, ui.selectedBeast.name .. " — Petopia")
        end
    end)

    self:InitLDB()
    self:HookCollectionsJournal()
end

-- ============================================================================
-- ОБНОВЛЕНИЕ КРУЖКОВ КЛАССОВ ПИТОМЦЕВ (СВИРЕПОСТЬ / ХИТРОСТЬ / УПОРСТВО) И ИХ ВЫПАДАШЕК
-- ============================================================================
function addon:RefreshFamilyStrip()
    local allActive = (ui.selectedSpec == "ALL" and ui.selectedFamily == "ALL")
    if ui.allSpecCircle then
        if allActive then
            ui.allSpecCircle.ring:SetVertexColor(1.0, 0.85, 0.15, 1.0)
            ui.allSpecCircle.glow:Show()
            ui.allSpecCircle:SetAlpha(1.0)
        else
            ui.allSpecCircle.ring:SetVertexColor(0.65, 0.65, 0.68, 0.90)
            ui.allSpecCircle.glow:Hide()
            ui.allSpecCircle:SetAlpha(0.84)
        end
    end

    local activeFamDef = (ui.selectedFamily ~= "ALL") and self.FamilyByID[ui.selectedFamily] or nil
    if activeFamDef and activeFamDef.spec then
        ui.selectedSpec = activeFamDef.spec
    end

    for _, specID in ipairs(SPEC_ORDER) do
        local sg = ui.specGroups and ui.specGroups[specID]
        if sg then
            local isThisSpec = (ui.selectedSpec == specID)
            if isThisSpec then
                sg.circleBtn.ring:SetVertexColor(1.0, 0.85, 0.15, 1.0)
                sg.circleBtn.glow:Show()
                sg.circleBtn:SetAlpha(1.0)
                sg.dropBtn:SetActiveTab(true)
                if activeFamDef and activeFamDef.spec == specID then
                    local icStr = activeFamDef.icon and ("|T" .. tostring(activeFamDef.icon) .. ":13:13:0:0:64:64:5:59:5:59|t ") or ""
                    sg.dropBtn:SetText(icStr .. GetShortFamilyName(activeFamDef) .. " [v]")
                else
                    sg.dropBtn:SetText(sg.specDef.name .. ": Все [v]")
                end
            else
                sg.circleBtn.ring:SetVertexColor(0.65, 0.65, 0.68, 0.90)
                sg.circleBtn.glow:Hide()
                sg.circleBtn:SetAlpha(0.86)
                sg.dropBtn:SetActiveTab(false)
                sg.dropBtn:SetText(sg.specDef.name .. " [v]")
            end

            for _, mBtn in ipairs(sg.menuBtns or {}) do
                if mBtn.familyID == "ALL" then
                    mBtn:SetActiveTab(isThisSpec and ui.selectedFamily == "ALL")
                else
                    mBtn:SetActiveTab(ui.selectedFamily == mBtn.familyID)
                end
            end
        end
    end

    if ui.roleMenuItems then
        for _, item in ipairs(ui.roleMenuItems) do
            item:SetActiveTab(item.roleID == ui.selectedRole)
        end
    end
end

-- ============================================================================
-- ОБНОВЛЕНИЕ РАМКИ КАРТОЧКИ И ФИЛЬТРАЦИЯ СЕТКИ
-- ============================================================================
function addon:UpdateCardBorder(card)
    if not card or not card.beast then return end
    local isSelected = (ui.selectedBeast and ui.selectedBeast.id == card.beast.id)
    local isCollected = self:IsBeastCollected(card.beast)

    if isSelected then
        card:SetBackdropColor(0.16, 0.13, 0.05, 0.98)
        card:SetBackdropBorderColor(1.0, 0.84, 0.15, 1.0)
    elseif isCollected then
        card:SetBackdropColor(0.05, 0.10, 0.06, 0.96)
        card:SetBackdropBorderColor(0.18, 0.65, 0.30, 0.95)
    elseif card.beast.rarity == "SPIRIT" or card.beast.rarity == "SECRET" then
        card:SetBackdropColor(0.05, 0.05, 0.08, 0.96)
        card:SetBackdropBorderColor(0.32, 0.26, 0.48, 0.95)
    else
        card:SetBackdropColor(0.04, 0.04, 0.05, 0.96)
        card:SetBackdropBorderColor(0.24, 0.22, 0.18, 1.0)
    end
end

local function FamilyHasRole(fam, roleID)
    if not fam then return false end
    for _, r in ipairs(fam.roles or {}) do
        if r == roleID then return true end
    end
    return false
end

local function BeastMatchesRoleFilter(beast, fam, roleID)
    if not roleID or roleID == "ALL" then return true end
    local skillLower = string.lower(fam.familySkill or "")

    if roleID == "BL" then
        return fam.spec == "FEROCITY" or FamilyHasRole(fam, "BL")
    elseif roleID == "TENACITY_DEF" then
        return fam.spec == "TENACITY"
    elseif roleID == "CUNNING_FREE" then
        return fam.spec == "CUNNING"
    elseif roleID == "DISPEL" then
        return FamilyHasRole(fam, "DISPEL")
            or string.find(skillLower, "диспел", 1, true) ~= nil
            or string.find(skillLower, "умиротвор", 1, true) ~= nil
    elseif roleID == "MORTAL" then
        return FamilyHasRole(fam, "MORTAL")
            or string.find(skillLower, "срез хила", 1, true) ~= nil
            or string.find(skillLower, "срез исцел", 1, true) ~= nil
    elseif roleID == "TANK" then
        return string.find(skillLower, "урона", 1, true) ~= nil
            or string.find(skillLower, "щит", 1, true) ~= nil
            or string.find(skillLower, "панцир", 1, true) ~= nil
            or string.find(skillLower, "чешуя", 1, true) ~= nil
            or string.find(skillLower, "шкура", 1, true) ~= nil
            or string.find(skillLower, "матрица", 1, true) ~= nil
    elseif roleID == "SLOW" then
        return FamilyHasRole(fam, "SLOW")
            or string.find(skillLower, "замедлен", 1, true) ~= nil
    elseif roleID == "DODGE" then
        return string.find(skillLower, "уклонен", 1, true) ~= nil
    elseif roleID == "HEAL" then
        return FamilyHasRole(fam, "HEAL") or beast.family == "spiritbeast"
    elseif roleID == "EXOTIC" then
        return fam.exotic == true
    elseif roleID == "TOME" then
        return fam.tome ~= nil
    elseif roleID == "RARE_ONLY" then
        local r = beast.rarity
        return (r == "SPIRIT" or r == "SECRET" or r == "RARE" or r == "BOSS")
    end

    return FamilyHasRole(fam, roleID)
end

local function BeastMatchesFilters(beast)
    local fam = addon.FamilyByID[beast.family]
    if not fam then return false end

    if ui.selectedFamily ~= "ALL" then
        if beast.family ~= ui.selectedFamily then
            return false
        end
    elseif ui.selectedSpec ~= "ALL" then
        if fam.spec ~= ui.selectedSpec then
            return false
        end
    end

    if ui.onlyUncollected and addon:IsBeastCollected(beast) then
        return false
    end

    if ui.selectedRole ~= "ALL" then
        if not BeastMatchesRoleFilter(beast, fam, ui.selectedRole) then
            return false
        end
    end

    if ui.searchText ~= "" then
        local s = ui.searchText
        local matchName = string.find(string.lower(beast.name or ""), s, 1, true)
        local matchSub = beast.subTitle and string.find(string.lower(beast.subTitle), s, 1, true)
        local matchMod = beast.modelGroup and string.find(string.lower(beast.modelGroup), s, 1, true)
        local matchZone = beast.zone and string.find(string.lower(beast.zone), s, 1, true)
        local matchFam = fam.name and string.find(string.lower(fam.name), s, 1, true)
        local matchSkill = fam.familySkill and string.find(string.lower(fam.familySkill), s, 1, true)
        if not (matchName or matchSub or matchMod or matchZone or matchFam or matchSkill) then
            local matchNpc = false
            if beast.npcs then
                for _, n in ipairs(beast.npcs) do
                    if n.name and string.find(string.lower(n.name), s, 1, true) then
                        matchNpc = true
                        break
                    end
                end
            end
            if not matchNpc then return false end
        end
    end

    return true
end

function addon:RefreshSideDock()
    if not ui.sideDock or not ui.sideDock:IsShown() then return end
    local beast = ui.selectedBeast
    if not beast then
        ui.dockBeastName:SetText("Выбери зверя в сетке")
        ui.dockSubTitle:SetText("")
        ui.detailsFS:SetText("")
        return
    end

    local fam = self.FamilyByID[beast.family]
    local spec = fam and self.PetSpecs[fam.spec]
    local isCollected, colSource = self:IsBeastCollected(beast)

    ApplyBeastToModel(ui.bigModel, beast, 0.45)

    ui.dockBeastName:SetText(beast.name)
    ui.dockSubTitle:SetText(beast.subTitle or (fam and fam.name or ""))

    if isCollected then
        ui.dockStatusBadge:SetText(ICON_READY .. " |cff00ff96" .. (colSource or "В коллекции") .. "|r")
        ui.btnToggleCol:SetText("Снять отметку")
    else
        ui.dockStatusBadge:SetText(ICON_STAR .. " |cffff8800Ещё не приручён|r")
        ui.btnToggleCol:SetText(ICON_READY .. " Отметить своим")
    end

    local rBadge = RARITY_BADGES[beast.rarity or "COMMON"] or RARITY_BADGES.COMMON
    ui.dockRarityBadge:SetText(rBadge.text)
    ui.dockRarityBadge:SetTextColor(unpack(rBadge.color))

    local lines = {}

    if fam and spec then
        local exoticStr = fam.exotic and " |cff00ccff(Экзотика — только БМ)|r" or " |cff88ff88(Все 3 спека)|r"
        table.insert(lines, string.format("%s |cffffd100Семейство:|r |cffffffff%s|r%s", ICON_PAW, fam.name, exoticStr))
        table.insert(lines, string.format("|T%s:14:14:0:0|t |cffffd100Специализация:|r %s%s|r", tostring(spec.icon or "Interface\\ICONS\\Ability_Hunter_BeastMastery"), spec.color, spec.name))
        table.insert(lines, string.format("   • |cffffcc00Активно:|r %s — %s", spec.activeName, spec.activeDesc))
        table.insert(lines, string.format("   • |cffffcc00Пассивно:|r %s (%s)", spec.passiveName, spec.passiveDesc))
        table.insert(lines, string.format("   • |cff00ff96Умение семейства:|r %s", fam.familySkill or ""))
        if fam.familyDesc then
            table.insert(lines, "|cffaaaaaa" .. fam.familyDesc .. "|r")
        end
    end

    if fam and fam.tome then
        local learned, tome = self:IsTomeLearned(fam.tome)
        if tome then
            table.insert(lines, " ")
            if learned then
                table.insert(lines, string.format("%s |cff00ff96Спец-навык изучен:|r %s", ICON_BOOK, tome.name))
            else
                table.insert(lines, string.format("%s |cffff5533Требуется изучить:|r |cffffffff%s|r", ICON_BOOK, tome.name))
                table.insert(lines, "|cffffaa66   Где взять книгу:|r " .. (tome.source or ""))
            end
        end
    end

    table.insert(lines, " ")
    table.insert(lines, ICON_PIN .. " |cffffd100Где водится и точки поиска:|r")
    table.insert(lines, string.format("   • |cff00ccffОсновная зона:|r |cffffffff%s|r", beast.zone or "Неизвестно"))
    if beast.respawn then
        table.insert(lines, string.format("   • |cff00ccffРеспавн:|r %s", beast.respawn))
    end
    if beast.coords and #beast.coords > 0 then
        for i, c in ipairs(beast.coords) do
            local notePart = c.note and (" — " .. c.note) or ""
            table.insert(lines, string.format("   • |cffffd100Точка %d:|r |cff00ff96%.1f, %.1f|r%s", i, c.x, c.y, notePart))
        end
    end

    if beast.npcs and #beast.npcs > 0 then
        table.insert(lines, " ")
        table.insert(lines, ICON_PAW .. " |cffffd100Мобы с этой моделью (Petopia):|r")
        for _, n in ipairs(beast.npcs) do
            local tagStr = (n.tag and n.tag ~= "") and (" |cffffaa00[" .. n.tag .. "]|r") or ""
            local lvlStr = (n.level and n.level ~= "") and (" |cff888888(ур. " .. n.level .. ")|r") or ""
            table.insert(lines, string.format("   • |cffffffff%s|r%s%s — |cff00ccff%s|r", n.name or ("NPC #" .. tostring(n.id)), tagStr, lvlStr, n.zone or ""))
        end
    end

    if beast.howTo then
        table.insert(lines, " ")
        table.insert(lines, ICON_STAR .. " |cffffd100Как выследить и приручить:|r")
        table.insert(lines, "|cffffffff" .. beast.howTo .. "|r")
    end

    local fullText = table.concat(lines, "\n")
    ui.detailsFS:SetText(fullText)

    local textH = ui.detailsFS:GetStringHeight() or 220
    ui.infoContent:SetHeight(math.max(180, textH + 16))
end

function addon:RefreshUI()
    if not ui.mainFrame or not ui.mainFrame:IsShown() then return end

    ui.tabAllModels:SetActiveTab(not ui.onlyUncollected)
    ui.tabMissing:SetActiveTab(ui.onlyUncollected)

    local activeRoleLabel = "Трейты и абилки [v]"
    for _, rf in ipairs(ROLE_FILTERS) do
        if rf.id == ui.selectedRole then
            activeRoleLabel = (rf.short or rf.label) .. " [v]"
            break
        end
    end
    ui.roleDropdownBtn:SetText(activeRoleLabel)
    ui.roleDropdownBtn:SetActiveTab(ui.selectedRole ~= "ALL")

    self:RefreshFamilyStrip()

    local activeFamDef = (ui.selectedFamily ~= "ALL") and self.FamilyByID[ui.selectedFamily] or nil
    local activeSpecDef = (ui.selectedSpec ~= "ALL") and self.PetSpecs[ui.selectedSpec] or nil
    if activeFamDef then
        ui.winTitle:SetText("|cffffd100Звери охотника — " .. activeFamDef.name .. "|r")
        ui.portraitIcon:SetTexture(activeFamDef.icon or "Interface\\ICONS\\Ability_Hunter_BeastMastery")
    elseif activeSpecDef then
        ui.winTitle:SetText("|cffffd100Звери охотника — " .. activeSpecDef.color .. activeSpecDef.name .. "|r |cffffd100(Все семейства)|r")
        ui.portraitIcon:SetTexture(activeSpecDef.icon or "Interface\\ICONS\\Ability_Hunter_BeastMastery")
    else
        ui.winTitle:SetText("|cffffd100Звери охотника — Все 61 семейство|r")
        ui.portraitIcon:SetTexture("Interface\\ICONS\\Ability_Hunter_BeastMastery")
    end

    local colCount, totCount = self:GetCollectionProgress(ui.selectedFamily, ui.selectedSpec)
    ui.progBar:SetMinMaxValues(0, math.max(1, totCount))
    ui.progBar:SetValue(colCount)
    ui.progText:SetText(string.format("%d / %d", colCount, totCount))

    wipe(ui.filteredBeasts)
    for _, beast in ipairs(self.Beasts or {}) do
        if BeastMatchesFilters(beast) then
            table.insert(ui.filteredBeasts, beast)
        end
    end

    -- Если выбрано конкретное семейство/спек, с которым несовместим старый фильтр трейта — мягко сбрасываем фильтр трейта
    if #ui.filteredBeasts == 0 and ui.selectedRole ~= "ALL" and ui.searchText == "" and not ui.onlyUncollected then
        ui.selectedRole = "ALL"
        ui.roleDropdownBtn:SetText("Трейты и абилки [v]")
        ui.roleDropdownBtn:SetActiveTab(false)
        self:RefreshFamilyStrip()
        for _, beast in ipairs(self.Beasts or {}) do
            if BeastMatchesFilters(beast) then
                table.insert(ui.filteredBeasts, beast)
            end
        end
    end

    ui.totalPages = math.max(1, math.ceil(#ui.filteredBeasts / PAGE_SIZE))
    if ui.currentPage > ui.totalPages then
        ui.currentPage = ui.totalPages
    end

    ui.pageText:SetText(string.format("Стр. %d/%d", ui.currentPage, ui.totalPages))
    ui.prevBtn:SetAlpha(ui.currentPage > 1 and 1.0 or 0.4)
    ui.nextBtn:SetAlpha(ui.currentPage < ui.totalPages and 1.0 or 0.4)

    if not ui.selectedBeast and ui.filteredBeasts[1] then
        ui.selectedBeast = ui.filteredBeasts[1]
    end

    local startIdx = (ui.currentPage - 1) * PAGE_SIZE
    for i = 1, PAGE_SIZE do
        local card = ui.gridCards[i]
        local beast = ui.filteredBeasts[startIdx + i]
        if beast then
            card.beast = beast
            card.nameFS:SetText(beast.name)

            local fam = self.FamilyByID[beast.family]
            local badges = {}
            for _, r in ipairs((fam and fam.roles) or {}) do
                if r == "BL" then table.insert(badges, "|cffff4d4dБЛ|r")
                elseif r == "MORTAL" then table.insert(badges, "|cffff9900-50%|r")
                elseif r == "DISPEL" then table.insert(badges, "|cff66ccffДисп|r")
                elseif r == "TANK" then table.insert(badges, "|cff4da6ffТанк|r")
                end
            end
            if fam and fam.exotic then
                table.insert(badges, 1, "|cffd966ffБМ|r")
            end
            card.roleBadge:SetText(table.concat(badges, " "))

            if self:IsBeastCollected(beast) then
                card.checkBadge:Show()
            else
                card.checkBadge:Hide()
            end

            self:UpdateCardBorder(card)
            card:Show()
            ApplyBeastToModel(card.model, beast, 0.42)
        else
            card.beast = nil
            card:Hide()
        end
    end

    -- Предварительно прогреваем кэш следующей страницы (18 моделей), чтобы перелистывание было мгновенным
    local nextStart = ui.currentPage * PAGE_SIZE
    for i = 1, PAGE_SIZE do
        local nextBeast = ui.filteredBeasts[nextStart + i]
        if nextBeast and nextBeast.npcID then
            WarmCreatureCache(nextBeast.npcID)
        end
    end

    self:RefreshSideDock()
end

function addon:ToggleMainWindow()
    if not ui.mainFrame then
        self:InitUI()
    end
    if ui.mainFrame:IsShown() then
        ui.mainFrame:Hide()
    else
        ui.mainFrame:Show()
        if ui.sideDock then
            ui.sideDock:Show()
        end
        self:RefreshUI()
    end
end

-- ============================================================================
-- ИНТЕГРАЦИЯ В СТАНДАРТНОЕ ОКНО «КОЛЛЕКЦИИ» (CollectionsJournal) + МИНИКАРТА
-- ============================================================================
function addon:HookCollectionsJournal()
    if self.collectionsHooked then return end

    local function AttachButtonToJournal()
        if self.collectionsHooked or not _G.CollectionsJournal then return end
        self.collectionsHooked = true

        local btn = CreateWardrobeButton(CollectionsJournal, 144, 22, ICON_PAW .. " Звери охотника", true)
        btn:SetPoint("TOPLEFT", CollectionsJournal, "TOPLEFT", 62, -4)
        btn:SetFrameLevel((CollectionsJournal:GetFrameLevel() or 10) + 15)
        btn:SetScript("OnClick", function()
            addon:ToggleMainWindow()
        end)
    end

    if _G.CollectionsJournal then
        AttachButtonToJournal()
    else
        hooksecurefunc("ToggleCollectionsJournal", function()
            AttachButtonToJournal()
        end)
    end
end

function addon:InitLDB()
    if not LDB or self.ldbObj then return end

    self.ldbObj = LDB:NewDataObject("BeastCollector", {
        type = "data source",
        text = "BeastCollector",
        icon = "Interface\\ICONS\\Ability_Hunter_BeastMastery",
        OnClick = function()
            addon:ToggleMainWindow()
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip then return end
            local col, tot = addon:GetCollectionProgress("ALL")
            tooltip:AddLine("|cff00ff96Beast|r|cffffaa00Collector|r — Бестиарий Охотника")
            tooltip:AddLine(string.format("Приручено моделей: |cffffd100%d / %d|r (61 семейство)", col, tot), 0.9, 0.9, 0.9)
            tooltip:AddLine(" ")
            tooltip:AddLine("|cffffd100ЛКМ или /bc:|r Открыть коллекцию 3D-моделей зверей", 0.7, 0.9, 1.0)
        end,
    })

    if LDBIcon and self.db and self.db.minimap then
        LDBIcon:Register("BeastCollector", self.ldbObj, self.db.minimap)
    end
end

SLASH_BEASTCOLLECTOR1 = "/bc"
SLASH_BEASTCOLLECTOR2 = "/beastcollector"
SlashCmdList["BEASTCOLLECTOR"] = function()
    addon:ToggleMainWindow()
end
