local _, addon = ...

-- ============================================================================
-- BeastCollector — BeastDB.lua
-- Подключает сгенерированную библиотеку Libs/HunterPetsDB-1.0/HunterPetsDB-1.0.lua
-- (61 семейство и 2 635 приручаемых окрасов/моделей из Petopia + Wago DB2 + GHP)
-- и задаёт боевые специализации питомцев и таблицу фолиантов приручения.
-- ============================================================================

local LibStub = _G.LibStub
local HunterPetsDB = (LibStub and LibStub("HunterPetsDB-1.0", true)) or _G.HunterPetsDB or {}

-- 1. БОЕВЫЕ СПЕЦИАЛИЗАЦИИ ПИТОМЦЕВ (Ferocity / Cunning / Tenacity)
addon.PetSpecs = {
    FEROCITY = {
        id = "FEROCITY",
        name = "Свирепость",
        color = "|cffff4d4d",
        icon = 236159,
        activeName = "Древняя истерия (Героизм / БЛ)",
        activeIcon = 136224,
        activeDesc = "Увеличивает скорость атаки и произнесения заклинаний всех участников группы или рейда на 30% на 40 сек.",
        passiveName = "Исступление хищника",
        passiveDesc = "Даёт охотнику и питомцу +10% к самоисцелению (Leech).",
    },
    CUNNING = {
        id = "CUNNING",
        name = "Хитрость",
        color = "|cffffcc00",
        icon = 236160,
        activeName = "Приказ хозяина (Свобода)",
        activeIcon = 236158,
        activeDesc = "Снимает с питомца и выбранного союзника все эффекты обездвиживания и замедления и даёт невосприимчивость к ним на 4 сек.",
        passiveName = "Следопыт",
        passiveDesc = "Повышает скорость передвижения охотника и питомца на 8%.",
    },
    TENACITY = {
        id = "TENACITY",
        name = "Упорство",
        color = "|cff4da6ff",
        icon = 236161,
        activeName = "Выживает сильнейший (Личный сейв)",
        activeIcon = 136080,
        activeDesc = "Уменьшает весь получаемый охотником и питомцем урон на 20% на 6 сек.",
        passiveName = "Выносливость дрессировщика",
        passiveDesc = "Увеличивает максимальный запас здоровья охотника и питомца на 5%.",
    },
}

-- 2. СПЕЦИАЛЬНЫЕ ФОЛИАНТЫ ПРИРУЧЕНИЯ (проверяются по questID / расе)
addon.TamingTomes = {
    DIREHORN = {
        id = "DIREHORN",
        name = "Древний фолиант диномантии",
        questID = 32610,
        itemID = 94232,
        source = "Выбивается с диномантов Зандалари на Острове Великанов (Пандария).",
    },
    MECHANICAL = {
        id = "MECHANICAL",
        name = "Матрица механоуз",
        questID = 42758,
        itemID = 134125,
        autoRaces = { ["Gnome"] = true, ["Goblin"] = true, ["Mechagnome"] = true },
        source = "Создаётся инженерами (Легион) или покупается на Аукционе. Гномы, гоблины и мехагномы умеют с рождения.",
    },
    FEATHERMANE = {
        id = "FEATHERMANE",
        name = "Фолиант гибридных зверей",
        questID = 46339,
        itemID = 147580,
        source = "Покупается у Пана Добрая Лапа в Приюте Стрелка (Оплот Охотника, Легион) после цепочки Расколотого берега.",
    },
    BLOOD_BEAST = {
        id = "BLOOD_BEAST",
        name = "Пропитанный кровью фолиант темного шепота",
        questID = 54753,
        itemID = 166502,
        source = "Падает с босса Зул Перерожденный в рейде Ульдир (сложность Героическая или Эпохальная).",
    },
    UNDEAD = {
        id = "UNDEAD",
        name = "Простой фолиант костоплета",
        questID = 62254,
        itemID = 183123,
        autoRaces = { ["Scourge"] = true },
        source = "Падает с элитных мобов и боссов Малдраксуса / Чумопада и Театра Боли (Shadowlands). Отрекшиеся умеют с рождения.",
    },
    CLOUD_SERPENT = {
        id = "CLOUD_SERPENT",
        name = "Как приручить дракона",
        questID = 62255,
        itemID = 183124,
        autoRaces = { ["Pandaren"] = true },
        source = "Покупается у Сань Рыжей Чешуи в Дендрарии (Нефритовый лес) при Превознесении с Орденом Облачного Змея.",
    },
    GARGON = {
        id = "GARGON",
        name = "Справочник по дрессировке гаргонов",
        questID = 61160,
        itemID = 180942,
        source = "Падает с Охотника Вивора в Ревендрете (62.8, 36.8).",
    },
    DRAGONKIN = {
        id = "DRAGONKIN",
        name = "Как приручить драконида",
        questID = 72094,
        itemID = 201790,
        autoRaces = { ["Dracthyr"] = true },
        source = "Награда за 23 уровень известности с Кентаврами Маруук (Драконьи острова).",
    },
}

addon.Families = HunterPetsDB.Families or {}
addon.Beasts   = HunterPetsDB.Beasts or {}
