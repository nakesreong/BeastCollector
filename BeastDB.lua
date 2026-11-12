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

-- 2. СПЕЦИАЛЬНЫЕ ФОЛИАНТЫ И ПРЕДМЕТЫ ПРИРУЧЕНИЯ (проверяются по questID / расе и ищутся через поиск!)
addon.TamingTomes = {
    FLORAFAUN = {
        id = "FLORAFAUN",
        name = "Испытания охотника на флорафавнов",
        categoryName = "Флорафавны (Растительные звери Харандара)",
        autoRaces = { ["Haranir"] = true },
        searchKeywords = "флорафавн флора испытание охотника на флорафавнов испытания охотника florafaun trials of the florafaun hunter харандар harandar растительн дьявозаптор devilsaptor саптор saptor хлороцерос chloroceros лепесткокрыл petalwing клубнежаб картофел potatoad мандрагор mandragora шипопаст thornmaw рощелаз grovecrawler фолиант книга предмет",
        source = "Падает с редких элитных флорафавнов в локации Харандар (Midnight): Королева Хлестоязыкая (59.8, 47.0), Оро'охна (28.1, 81.8), Драцена (40.6, 43.1), Ха'калаве (69.0, 60.0), Птеррок (27.4, 71.4). Охотники-хараниры умеют с рождения.",
    },
    DIREHORN = {
        id = "DIREHORN",
        name = "Древний фолиант диномантии",
        categoryName = "Дикороги (Трицератопсы)",
        questID = 32610,
        itemID = 94232,
        autoRaces = { ["ZandalariTroll"] = true },
        searchKeywords = "древний фолиант диномантии диномантия дикорог direhorn ancient tome of dinomancy трицератопс остров великанов зандалар фолиант книга предмет",
        source = "Выбивается с диномантов Зандалари на Острове Великанов (Пандария). Зандаларские тролли умеют с рождения.",
    },
    MECHANICAL = {
        id = "MECHANICAL",
        name = "Матрица механоуз",
        categoryName = "Механизмы (Механические звери)",
        questID = 42758,
        itemID = 134125,
        autoRaces = { ["Gnome"] = true, ["Goblin"] = true, ["Mechagnome"] = true },
        searchKeywords = "матрица механоуз механизм механическ робот mecha-bond imprint matrix mechanical фолиант книга предмет",
        source = "Создаётся инженерами (Легион) или покупается на Аукционе. Гномы, гоблины и мехагномы умеют с рождения.",
    },
    FEATHERMANE = {
        id = "FEATHERMANE",
        name = "Фолиант гибридных зверей",
        categoryName = "Шерстоперые (Грифоны, Гиппогрифы, Совокоты, Виверны)",
        questID = 46339,
        itemID = 147580,
        searchKeywords = "фолиант гибридных зверей гибрид шерстопер пернат грифон гиппогриф совокот волкоястреб виверн ветрокрыл tome of the hybrid beast feathermane фолиант книга предмет",
        source = "Покупается у Пана Добрая Лапа в Приюте Стрелка (Оплот Охотника, Легион) после цепочки кампании Оплота и Расколотого берега.",
    },
    BLOOD_BEAST = {
        id = "BLOOD_BEAST",
        name = "Пропитанный кровью фолиант темного шепота",
        categoryName = "Кровавые чудовища (Кроги и Кровавые клещи)",
        questID = 54753,
        itemID = 166502,
        searchKeywords = "пропитанный кровью фолиант темного шепота темный шепот кровав чудовищ зверь крог клещ зул ульдир blood-soaked tome of dark whispers blood beast фолиант книга предмет",
        source = "Падает с босса Зул Перерожденный в рейде Ульдир (сложность Героическая или Эпохальная).",
    },
    UNDEAD = {
        id = "UNDEAD",
        name = "Простой фолиант костоплета",
        categoryName = "Звери-нежить (Костяные, чумные и проклятые звери)",
        questID = 62254,
        itemID = 183123,
        autoRaces = { ["Scourge"] = true },
        searchKeywords = "простой фолиант костоплета костоплет нежить скелет костян чумн мертв малдраксус simple tome of bone-binding undead skeletal фолиант книга предмет",
        source = "Падает с элитных мобов и боссов Малдраксуса, Чумопада и Театра Боли (Shadowlands). Отрекшиеся умеют с рождения.",
    },
    CLOUD_SERPENT = {
        id = "CLOUD_SERPENT",
        name = "Как приручить дракона",
        categoryName = "Облачные змеи Пандарии",
        questID = 62255,
        itemID = 183124,
        autoRaces = { ["Pandaren"] = true },
        searchKeywords = "как приручить дракона облачный змей облачные змеи орден облачного змея элегон how to school your serpent cloud serpent фолиант книга предмет",
        source = "Покупается у Сань Рыжей Чешуи в Дендрарии (Нефритовый лес) при Превознесении с Орденом Облачного Змея. Пандарены умеют с рождения.",
    },
    GARGON = {
        id = "GARGON",
        name = "Справочник по дрессировке гаргонов",
        categoryName = "Гаргоны Ревендрета",
        questID = 61160,
        itemID = 180942,
        searchKeywords = "справочник по дрессировке гаргонов гаргон ревендрет вивор gargon training manual фолиант книга предмет",
        source = "Падает с редкого моба Охотник Вивор в Ревендрете (62.8, 36.8).",
    },
    DRAGONKIN = {
        id = "DRAGONKIN",
        name = "Как приручить драконида",
        categoryName = "Малые дракониды и Ворквины",
        questID = 72094,
        itemID = 201790,
        autoRaces = { ["Dracthyr"] = true },
        searchKeywords = "как приручить драконида малые дракониды драконид ворквин чудесный дракончик рогоплав фазовый змей how to train a dragonkin lesser dragonkin vorquin фолиант книга предмет",
        source = "Награда за 23 уровень известности с Кентаврами Маруук (Драконьи острова). Драктиры умеют с рождения.",
    },
}

-- 3. ПРИВЯЗКА КОНКРЕТНЫХ ПОДВИДОВ МОДЕЛЕЙ (modelGroup) К ПРЕДМЕТАМ ПРИРУЧЕНИЯ
-- (Для семейств, где книгу требуют только отдельные подвиды: Флорафавны, Нежить, Ворквины, Облачные змеи, Гаргоны)
addon.ModelGroupTomes = {
    -- Флорафавны Харандара (Midnight 12.0 — «Испытания охотника на флорафавнов»)
    ["Devilsaptors"]             = { "FLORAFAUN" },
    ["Saptors"]                  = { "FLORAFAUN" },
    ["Chloroceroses"]            = { "FLORAFAUN", "DIREHORN" },
    ["Petalwings"]               = { "FLORAFAUN" },
    ["Potatoads"]                = { "FLORAFAUN" },
    ["Mandragoras"]              = { "FLORAFAUN" },
    ["Thornmaws"]                = { "FLORAFAUN" },
    ["Grovecrawlers"]            = { "FLORAFAUN" },

    -- Звери-нежить («Простой фолиант костоплета»)
    ["Skeletal Devilsaurs"]      = { "UNDEAD" },
    ["Skeletal Raptors"]         = { "UNDEAD" },
    ["Saddled Skeletal Raptors"] = { "UNDEAD" },
    ["Armored Undead Raptors"]   = { "UNDEAD" },
    ["Skeletal Windserpents"]    = { "UNDEAD" },
    ["Skeletal Hellhounds"]      = { "UNDEAD" },
    ["Undead Gorillas"]          = { "UNDEAD" },
    ["Bone Spiders"]             = { "UNDEAD" },
    ["Death Chimaeras"]          = { "UNDEAD" },
    ["Saddled Death Chimaeras"]  = { "UNDEAD" },

    -- Гаргоны («Справочник по дрессировке гаргонов»)
    ["Gargons"]                  = { "GARGON" },
    ["Saddled Gargons"]          = { "GARGON" },

    -- Облачные змеи («Как приручить дракона»)
    ["Cloud Serpents"]           = { "CLOUD_SERPENT" },
    ["Celestial Cloud Serpents"] = { "CLOUD_SERPENT" },
    ["Astral Cloud Serpents"]    = { "CLOUD_SERPENT" },

    -- Ворквины в семействе Оленей («Как приручить драконида»)
    ["Vorquins"]                 = { "DRAGONKIN" },
    ["Armoured Vorquins"]        = { "DRAGONKIN" },
}

addon.ModelGroupRuNames = {
    ["Devilsaptors"]             = "Дьявозаптор (Флорафавн Харандара)",
    ["Saptors"]                  = "Саптор (Флорафавн Харандара)",
    ["Chloroceroses"]            = "Хлороцерос (Флорафавн Харандара)",
    ["Petalwings"]               = "Лепесткокрыл (Флорафавн Харандара)",
    ["Potatoads"]                = "Клубнежаба (Флорафавн Харандара)",
    ["Mandragoras"]              = "Мандрагора (Флорафавн Харандара)",
    ["Thornmaws"]                = "Шипопасть (Флорафавн Харандара)",
    ["Grovecrawlers"]            = "Рощелаз (Флорафавн Харандара)",
    ["Skeletal Devilsaurs"]      = "Костяной дьявозавр (Нежить)",
    ["Skeletal Raptors"]         = "Костяной ящер (Нежить)",
    ["Saddled Skeletal Raptors"] = "Оседланный костяной ящер (Нежить)",
    ["Armored Undead Raptors"]   = "Бронированный ящер-нежить",
    ["Skeletal Windserpents"]    = "Костяной крылатый змей (Нежить)",
    ["Skeletal Hellhounds"]      = "Костяная адская гончая (Нежить)",
    ["Undead Gorillas"]          = "Горилла-нежить",
    ["Bone Spiders"]             = "Костяной паук (Нежить)",
    ["Death Chimaeras"]          = "Химера смерти (Нежить)",
    ["Saddled Death Chimaeras"]  = "Оседланная химера смерти (Нежить)",
    ["Gargons"]                  = "Гаргон Ревендрета",
    ["Saddled Gargons"]          = "Оседланный гаргон Ревендрета",
    ["Cloud Serpents"]           = "Облачный змей Пандарии",
    ["Celestial Cloud Serpents"] = "Небожитель — Облачный змей",
    ["Astral Cloud Serpents"]    = "Астральный облачный змей (Элегон)",
    ["Vorquins"]                 = "Ворквин (Драконьи острова)",
    ["Armoured Vorquins"]        = "Бронированный ворквин",
}

addon.Families = HunterPetsDB.Families or {}
addon.Beasts   = HunterPetsDB.Beasts or {}
