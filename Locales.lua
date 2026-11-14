local _, addon = ...

-- ============================================================================
-- BeastCollector — Locales.lua
-- Auto-detects client language (GetLocale()) and supports instant in-game
-- RU / EN hot-swapping via the header [RU]/[EN] button or `/bc lang`!
-- ============================================================================

local Locales = {
    ruRU = {
        -- Верхняя панель и вкладки
        TITLE_ALL_FAMILIES      = "Звери охотника — Все 61 семейство",
        TITLE_TOMES_TAB         = "Звери охотника — Фолианты и предметы приручения (11)",
        TITLE_SPEC_PREFIX       = "Звери охотника — Специализация: ",
        TITLE_PREFIX            = "Звери охотника — ",
        TAB_ALL_MODELS          = "Все модели",
        TAB_UNCOLLECTED         = "Несобранные",
        TAB_TOMES_FMT           = " Фолианты (%d)",
        PROGRESS_TOMES_FMT      = "Фолианты: %d / %d",
        SEARCH_PLACEHOLDER      = "Поиск зверя / зоны / книги...",
        LANG_BTN_LABEL          = "EN",
        LANG_BTN_TOOLTIP_TITLE  = "Язык интерфейса: Русский (RU)",
        LANG_BTN_TOOLTIP_DESC   = "Нажми, чтобы мгновенно переключить весь интерфейс на Английский (EN) для скриншотов (без /reload)!",
        CHAT_LANG_SWITCHED      = "|cff00ff96[BeastCollector]|r Язык интерфейса переключён на: |cffffd100Русский (RU)|r.",

        -- Фильтры и выпадашки
        FILTER_TRAITS_DEFAULT   = "Трейты и абилки [v]",
        SPEC_DROPDOWN_FMT       = "%s [v]",
        SPEC_MENU_ALL_FMT       = "Все: %s (%d)",
        TAG_EXOTIC_PAREN        = "(Экзот)",
        TAG_TOME_PAREN          = "(Фолиант)",
        TAG_EXOTIC_FULL         = " |cff00ccff(Экзотика — только БМ)|r",
        TAG_ALL_SPECS_FULL      = " |cff88ff88(Все 3 спека)|r",
        TT_ALL_FAMILIES_TITLE   = "Все 61 семейство зверей",
        TT_ALL_FAMILIES_DESC    = "Показать полную коллекцию всех моделей (Свирепость, Хитрость и Упорство).",
        TT_SPEC_FAMILIES_COUNT  = "Семейств в этом классе: |cff00ff96%d|r",
        TT_CLICK_OPEN_LIST      = "|cff88ff88Нажми, чтобы открыть список зверей по названиям!|r",
        TT_SHOW_ALL_SPEC_DESC   = "Показать абсолютно все семейства специализации «%s».",
        TT_SPEC_LABEL           = "Специализация: ",
        TT_ACTIVE_LABEL         = "Активно: ",
        TT_PASSIVE_LABEL        = "Пассивно: ",
        TT_FAMILY_SKILL_LABEL   = "Способность: ",
        TT_TOME_LEARNED_FMT     = " Фолиант изучен: %s",
        TT_TOME_REQUIRED_FMT    = " Требуется: %s",

        -- Ролевые фильтры
        ROLE_ALL_NAME           = "Все трейты и способности",
        ROLE_ALL_DESC           = "Показать все модели без фильтра по боевым умениям",
        ROLE_BL_NAME            = "Героизм / Жажда крови (БЛ)",
        ROLE_BL_DESC            = "Древняя истерия (+30% скорости рейду на 40 сек) — все семейства Свирепости",
        ROLE_TANK_NAME          = "Танко-сейв (Щит -50% / -60% урона)",
        ROLE_TANK_DESC          = "Лучшие звери для соло-игры, вылазок и танкования элиты (Копытни, Чешуешкурые, Черепахи, Медведи, Жуки и др.)",
        ROLE_MORTAL_NAME        = "Мортал (-50% исцеления цели)",
        ROLE_MORTAL_DESC        = "Накладывает эффект Смертельных ран, режущий хил врага на 50% (Дьявозавры, Скорпиды, Ящеры, Гиены, Осы, Дикороги и др.)",
        ROLE_DISPEL_NAME        = "Диспел (Снятие Магии + Исступления)",
        ROLE_DISPEL_DESC        = "Снимает 1 магический эффект и 1 исступление с врага (Духи зверя, Скаты Пустоты, Олени, Мотыльки, Спороскаты, Летучие мыши, Чирки)",
        ROLE_STEALTH_NAME       = "Стелс / Крадущийся зверь",
        ROLE_STEALTH_DESC        = "Умеют ходить в невидимости (Духи зверя и Кошки)",
        ROLE_SLOW_NAME          = "Замедление (-50% скорости врага)",
        ROLE_SLOW_DESC          = "Снижает скорость передвижения цели на 50% (Волки, Пауки, Крабы, Прыгуаны, Хищные птицы и др.)",
        ROLE_WATERWALK_NAME     = "Хождение по воде",
        ROLE_WATERWALK_DESC     = "Позволяет охотнику и питомцу бегать по поверхности воды (Водные долгоноги)",
        ROLE_EXOTIC_NAME        = "Экзотические (Только БМ)",
        ROLE_EXOTIC_DESC        = "Уникальные семейства с 2 способностями, доступные только в специализации «Повелитель зверей»",
        ROLE_TOME_NAME          = "Требует Фолиант / Предмет",
        ROLE_TOME_DESC          = "Все звери, для приручения которых нужно выбить или купить книгу (Флорафавны, Нежить, Гаргоны, Шерстоперые, Дикороги, Механизмы и др.)",
        ROLE_SPIRIT_NAME        = "Редкие и Духи Зверя",
        ROLE_SPIRIT_DESC        = "Уникальные рарники с таймером респавна и призрачные звери",
        ROLE_SECRET_NAME        = "Особые призывы и Секреты",
        ROLE_SECRET_DESC        = "Скрытые звери по следам, кликам по предметам, ритуалам и боссы рейдов",

        -- Короткие бейджи на карточках
        BADGE_BL                = "|cffff4d4dБЛ|r",
        BADGE_TANK              = "|cff4da6ffТанк|r",
        BADGE_MORTAL            = "|cffff8000Морт|r",
        BADGE_DISPEL            = "|cffcc66ffДисп|r",
        BADGE_STEALTH           = "|cff88ff88Стелс|r",
        BADGE_SLOW              = "|cffffff66Слоу|r",
        BADGE_WATERWALK         = "|cff00ffffВода|r",
        BADGE_EXOTIC_BM         = "|cff00ccffБМ|r",
        BADGE_TOME_LEARNED      = "|cff00ff96Фол|r",
        BADGE_TOME_UNLEARNED    = "|cffffaa00Фол|r",
        BADGE_QUEST             = "|cffff6600Квест|r",
        BADGE_ACCT_FMT          = "|cff00ccffАкк|r |cffffd100(%d)|r",
        BADGE_CHAR_FMT          = "|cffffaa00Перс|r |cffffd100(%d)|r",

        -- Редкость
        RARITY_SPIRIT           = "Дух Зверя",
        RARITY_SECRET           = "Секрет / Призыв",
        RARITY_BOSS             = "Босс рейда/данжа",
        RARITY_RARE             = "Редкий (Рарник)",
        RARITY_COMMON           = "Обычный",

        -- Сетка и пагинация
        PAGE_FMT                = "Стр. %d/%d",
        EMPTY_GRID_TEXT         = "Ни один зверь не найден по текущему фильтру.\nПопробуй сбросить фильтр «Несобранные» или очистить строку поиска.",

        -- Боковое досье (Side Dock)
        DOCK_TITLE_BEAST        = " |cffffd100Досье питомца|r",
        DOCK_TITLE_TOME         = " |cffffd100Досье фолианта|r",
        DOCK_ROTATE_HINT        = "ЛКМ: вращать • Колёсико: зум",
        DOCK_SELECT_BEAST       = "Выбери зверя в сетке",
        DOCK_STATUS_LEARNED     = " |cff00ff96Изучено!|r",
        DOCK_STATUS_UNLEARNED   = " |cffff8800Ещё не изучен|r",
        DOCK_STATUS_UNTAMED     = " |cffff8800Ещё не приручён|r",
        DOCK_SCOPE_ACCOUNT      = "|cff00ccffНа весь аккаунт|r",
        DOCK_SCOPE_CHAR         = "|cffffaa00На персонажа|r",

        -- Кнопки бокового досье
        BTN_NAV_BEAST           = " Проложить путь к зверю (TomTom + Карта)",
        BTN_NAV_TOME            = " Проложить маршрут за книгой (TomTom + Карта)",
        BTN_SHOW_MAP            = "На карте",
        BTN_MARK_COLLECTED      = " Отметить своим",
        BTN_UNMARK              = "Снять отметку",
        BTN_MARK_LEARNED        = " Отметить изуч.",
        BTN_BEASTS_COUNT_FMT    = "Звери (%d)",

        -- Строки досье Фолианта
        TOME_UNLOCKS_FMT        = "%s |cffffd100Что открывает:|r |cff66ff99%s|r",
        TOME_MODELS_COUNT_FMT   = "   • |cffffcc00Моделей в нашей базе:|r |cffffffff%d|r (кнопка «Звери (%d)» внизу покажет их все!)",
        TOME_SCOPE_ACCT_LINE    = "   • |cffffcc00Разблокировка:|r |cff00ccffНа весь аккаунт (Отряд)|r — достаточно получить один раз!",
        TOME_SCOPE_CHAR_LINE    = "   • |cffffcc00Разблокировка:|r |cffffaa00Только на текущего охотника|r (альтам нужно получать отдельно).",
        TOME_INNATE_RACE_FMT    = "   • |cffffcc00Умеют с рождения без книги:|r |cff00ff96%s|r",
        TOME_DROP_RATE_FMT      = "   • |cffffcc00Шанс выпадения:|r |cff00ccff%s|r",
        TOME_EXPECTED_KILLS_FMT = "   • |cffffcc00Сколько бить (в среднем):|r |cffffffff%s|r",
        TOME_TRIES_LUCK_FMT     = "   • |cffffcc00Твои траи (убито):|r |cffffcc00%d|r |cff88ff88(накопленная удача: %.1f%%)|r",
        TOME_TRIES_SIMPLE_FMT   = "   • |cffffcc00Твои траи (убито):|r |cffffcc00%d|r",
        TOME_HOW_TO_HEADER      = " |cffffd100Где и как достать (подробно):|r",
        TOME_LOCATION_HEADER    = " |cffffd100Локация и точки маршрута:|r",
        TOME_ZONE_LINE_FMT      = "   • |cff00ccffЗона:|r |cffffffff%s|r",
        TOME_POINT_LINE_FMT     = "   • |cffffd100Точка %d:|r |cff00ff96%.1f, %.1f|r%s",

        -- Строки досье Питомца
        BEAST_FAMILY_LINE_FMT   = "%s |cffffd100Семейство:|r |cffffffff%s|r%s",
        BEAST_SPEC_LINE_FMT     = "|T%s:14:14:0:0|t |cffffd100Специализация:|r %s%s|r",
        BEAST_ACTIVE_LINE_FMT   = "   • |cffffcc00Активно:|r %s — %s",
        BEAST_PASSIVE_LINE_FMT  = "   • |cffffcc00Пассивно:|r %s (%s)",
        BEAST_SKILL_LINE_FMT    = "   • |cff00ff96Умение семейства:|r %s",
        BEAST_QUEST_ONLY_LINE   = "   • |cffff6600Доступность:|r |cffffd100Эксклюзив квеста — приручи ДО сдачи задания!|r",
        BEAST_SPECIAL_GROUP_FMT = "%s |cffffd100Особая группа:|r |cff66ff99%s|r",
        BEAST_TOME_LEARNED_FMT  = "   • |cff00ff96Навык изучен:|r %s",
        BEAST_TOME_REQ_RED_FMT  = "   • |cffff5533Требуется предмет/книга:|r |cffffffff%s|r",
        BEAST_TOME_REQ_YEL_FMT  = "   • |cffffaa00Требуется предмет/книга:|r |cffffffff%s|r",
        BEAST_WHERE_GET_FMT     = "|cffffaa66   Где взять:|r %s",
        BEAST_WHERE_HEADER      = " |cffffd100Где водится и точки поиска:|r",
        BEAST_MAIN_ZONE_FMT     = "   • |cff00ccffОсновная зона:|r |cffffffff%s|r",
        BEAST_RESPAWN_FMT       = "   • |cff00ccffРеспавн:|r %s",
        BEAST_NPCS_HEADER_FMT   = "|cffffd100Приручаемые мобы с этой моделью (%d):|r",
        BEAST_HOW_TO_HEADER     = " |cffffd100Секрет и особенности приручения:|r",

        -- Тултипы карточек
        TT_CARD_UNLOCKS_FMT     = "Открывает: |cff66ff99%s|r (%d мод.)",
        TT_CARD_SKILL_LEARNED   = " |cff00ff96Навык изучен!|r",
        TT_CARD_SKILL_UNLEARNED = " |cffff8800Ещё не изучен|r",
        TT_CARD_DROP_CHANCE_FMT = "|cffffd100Шанс выпадения:|r |cff00ccff%s|r",
        TT_CARD_EXPECTED_FMT    = "|cffffd100Сколько бить:|r |cffffffff%s|r",
        TT_CARD_TRIES_LUCK_FMT  = "|cffffd100Твои траи (убито):|r |cffffcc00%d|r |cffaaaaaa(накопленная удача: %.1f%%)|r",
        TT_CARD_TRIES_FMT       = "|cffffd100Твои траи (убито):|r |cffffcc00%d|r",
        TT_CARD_WHERE_GET_FMT   = "|cffffd100Где достать:|r %s",
        TT_CARD_TOME_HELP1      = "|cffffd100ЛКМ:|r Подробное досье  |  |cffffd100ПКМ:|r Проложить маршрут",
        TT_CARD_TOME_HELP2      = "|cffffd100Shift+ЛКМ:|r Показать всех зверей этого фолианта",
        TT_CARD_FAMILY_FMT      = "Семейство: %s",
        TT_CARD_SKILL_FMT       = "Умеет: |cff00ff96%s|r",
        TT_CARD_TOME_OK_FMT     = " %s (Изучено)",
        TT_CARD_TOME_NEED_FMT   = " Требуется: %s",
        TT_CARD_ZONE_FMT        = "Зона: |cff00ccff%s|r",
        TT_CARD_BEAST_HELP      = "|cffffd100ЛКМ:|r Подробное досье  |  |cffffd100ПКМ:|r Путь к зверю",

        -- Статусы в стойлах / коллекции
        COL_MANUAL              = "Отмечено в твоей коллекции",
        COL_STABLED_FMT         = "В стойлах: %s",
        ACTIVE_PET_FALLBACK     = "Активный питомец",
        UNKNOWN_ZONE            = "Неизвестно",

        -- Кнопка у миникарты и попап ссылок
        MINIMAP_TT_SUBTITLE     = "Гардероб 3D-моделей зверей охотника",
        MINIMAP_TT_COLLECTED    = "Собрано расцветок: |cff00ff96%d / %d|r",
        MINIMAP_TT_LCLICK       = "|cffffd100ЛКМ:|r Открыть / закрыть коллекцию",
        MINIMAP_TT_RCLICK       = "|cffffd100ПКМ:|r Сразу фильтр «Несобранные»",
        MINIMAP_TT_DRAG         = "|cffaaaaaaЗажми ЛКМ и тяни по кругу миникарты|r",
        COPY_POPUP_HINT         = "Нажми |cffffd100Ctrl + C|r, чтобы скопировать ссылку в браузер:",

        -- Тултипы мобов в открытом мире и путевых точек
        UNIT_TT_HEADER_FMT      = "%s |cff00ff96BeastCollector:|r %s",
        UNIT_TT_SKILL_FMT       = "   |cffffd100Умеет:|r %s",
        UNIT_TT_EXOTIC_NO_BM    = "   |cffff4444НЕ ПРИРУЧАЕТСЯ СЕЙЧАС:|r Экзотическое семейство — переключись в спек |cff00ccff«Повелитель зверей» (БМ)|r!",
        UNIT_TT_EXOTIC_OK_BM    = "   |cff00ccffЭкзотический зверь:|r Доступен (ты в спеке «Повелитель зверей»)",
        UNIT_TT_LEVEL_HIGH_FMT  = "   |cffff4444НЕ ПРИРУЧАЕТСЯ СЕЙЧАС:|r Уровень моба (%d) выше твоего (%d)!",
        UNIT_TT_NOT_TAMEABLE    = "   |cffff8800Осторожно:|r Конкретно этот моб может быть не приручаемым (проверь «Знание зверя»).",
        UNIT_TT_TOME_OK_FMT     = "   %s |cff00ff96%s:|r изучено",
        UNIT_TT_TOME_NEED_FMT   = "   %s |cffff5533Требуется:|r %s",
        UNIT_TT_MISSING_MODEL   = "   %s |cffffaa00Этой модели ещё нет в твоих стойлах!|r",
        UNIT_TT_QUEST_ONLY_WARN = "   |cffff5500! ЭКСКЛЮЗИВ КВЕСТА: Приручи ДО сдачи задания (потом фаза исчезнет)!|r",
        UNIT_TT_DROPS_TOME_FMT  = "%s |cff00ff96BeastCollector:|r Падает «|cffffd100%s|r»",
        UNIT_TT_DROP_RATE_FMT   = "   • Шанс выпадения: |cff00ccff%s|r",
        UNIT_TT_EXPECTED_FMT    = "   • Сколько бить: |cffffffff%s|r",
        UNIT_TT_TRIES_FMT       = "   • Твои траи (убито): |cffffcc00%d|r (накопленная удача: %.1f%%)",
        UNIT_TT_ALREADY_LEARNED = "   • |cff00ff96У тебя этот фолиант уже изучен!|r",
        WP_TT_HEADER            = "|cff00ff96BeastCollector — Навигатор|r",
        WP_TT_TARGET_FMT        = "|cffffd100Цель:|r |cffffffff%s|r",
        WP_TT_STEP_FMT          = "|cff00ccffЭтап %d из %d:|r %s",
        WP_TT_ROUTE_HEADER      = "|cffffd100Маршрут по порталам:|r",
        WP_TT_STEP_CURRENT_FMT  = "   |cffffd100[->] %d. %s (сейчас)|r",

        -- Всплывающий баннер-анонс квестового эксклюзива (как в MountCollector)
        ALERT_QUEST_HEADER      = "ВНИМАНИЕ: ЭКСКЛЮЗИВ КВЕСТА РЯДОМ!",
        ALERT_QUEST_SUB         = "Приручи ДО сдачи квеста — после завершения его уже не достать!",
        ALERT_TT_TITLE          = "|cffff6600BeastCollector — Квестовый эксклюзив|r",
        ALERT_TT_DESC           = "Этот зверь существует только внутри квестовой фазы или сценария и ещё НЕ собран в твоей коллекции!",
        ALERT_TT_CLICK_HINT     = "|cff00ff96ЛКМ:|r Открыть досье зверя   |cffaaaaaaПКМ:|r Скрыть баннер",
        CHAT_QUEST_ALERT_FMT    = "|cffff6600[BeastCollector — Эксклюзив квеста!]|r Рядом |cffffd100%s|r (%s) — этой модели ещё нет в твоих стойлах! Обязательно приручи ДО сдачи квеста!",
    },

    enUS = {
        -- Header & Tabs
        TITLE_ALL_FAMILIES      = "Hunter Pets — All 61 Families",
        TITLE_TOMES_TAB         = "Hunter Pets — Taming Tomes & Manuals (11)",
        TITLE_SPEC_PREFIX       = "Hunter Pets — Specialization: ",
        TITLE_PREFIX            = "Hunter Pets — ",
        TAB_ALL_MODELS          = "All Models",
        TAB_UNCOLLECTED         = "Uncollected",
        TAB_TOMES_FMT           = " Tomes (%d)",
        PROGRESS_TOMES_FMT      = "Tomes: %d / %d",
        SEARCH_PLACEHOLDER      = "Search beast / zone / tome...",
        LANG_BTN_LABEL          = "RU",
        LANG_BTN_TOOLTIP_TITLE  = "Interface Language: English (EN)",
        LANG_BTN_TOOLTIP_DESC   = "Click to instantly switch the entire interface to Russian (RU) without /reload!",
        CHAT_LANG_SWITCHED      = "|cff00ff96[BeastCollector]|r Interface language switched to: |cffffd100English (EN)|r.",

        -- Filters & Dropdowns
        FILTER_TRAITS_DEFAULT   = "Traits & Abilities [v]",
        SPEC_DROPDOWN_FMT       = "%s [v]",
        SPEC_MENU_ALL_FMT       = "All: %s (%d)",
        TAG_EXOTIC_PAREN        = "(Exotic)",
        TAG_TOME_PAREN          = "(Tome)",
        TAG_EXOTIC_FULL         = " |cff00ccff(Exotic — BM Only)|r",
        TAG_ALL_SPECS_FULL      = " |cff88ff88(All 3 Specs)|r",
        TT_ALL_FAMILIES_TITLE   = "All 61 Hunter Pet Families",
        TT_ALL_FAMILIES_DESC    = "Show the complete collection of all tameable looks (Ferocity, Cunning, and Tenacity).",
        TT_SPEC_FAMILIES_COUNT  = "Families in this specialization: |cff00ff96%d|r",
        TT_CLICK_OPEN_LIST      = "|cff88ff88Click to browse families by name!|r",
        TT_SHOW_ALL_SPEC_DESC   = "Show all families belonging to the '%s' specialization.",
        TT_SPEC_LABEL           = "Specialization: ",
        TT_ACTIVE_LABEL         = "Active: ",
        TT_PASSIVE_LABEL        = "Passive: ",
        TT_FAMILY_SKILL_LABEL   = "Family Ability: ",
        TT_TOME_LEARNED_FMT     = " Tome Learned: %s",
        TT_TOME_REQUIRED_FMT    = " Requires Tome: %s",

        -- Role Filters
        ROLE_ALL_NAME           = "All Traits & Abilities",
        ROLE_ALL_DESC           = "Show all models without filtering by combat traits",
        ROLE_BL_NAME            = "Bloodlust / Heroism (Primal Rage)",
        ROLE_BL_DESC            = "Primal Rage (+30% Haste for all party/raid members for 40s) — all Ferocity families",
        ROLE_TANK_NAME          = "Tank Defensive (-50% / -60% Damage Shield)",
        ROLE_TANK_DESC          = "Best solo & Delve tank pets (Clefthooves, Scalehides, Turtles, Bears, Beetles, etc.)",
        ROLE_MORTAL_NAME        = "Mortal Wounds (-50% Target Healing)",
        ROLE_MORTAL_DESC        = "Reduces healing received by the target by 50% (Devilsaurs, Scorpids, Raptors, Hyenas, Wasps, Direhorns, etc.)",
        ROLE_DISPEL_NAME        = "Dispel (Remove Magic + Enrage)",
        ROLE_DISPEL_DESC        = "Removes 1 Magic and 1 Enrage effect from an enemy (Spirit Beasts, Rays, Stags, Moths, Sporebats, Bats, Waterfowl)",
        ROLE_STEALTH_NAME       = "Stealth / Prowl",
        ROLE_STEALTH_DESC       = "Can prowl in stealth (Spirit Beasts and Cats)",
        ROLE_SLOW_NAME          = "Slow / Snare (-50% Enemy Speed)",
        ROLE_SLOW_DESC          = "Reduces enemy movement speed by 50% (Wolves, Spiders, Crabs, Warp Stalkers, Birds of Prey, etc.)",
        ROLE_WATERWALK_NAME     = "Water Walking (Surface Trot)",
        ROLE_WATERWALK_DESC     = "Allows the Hunter and pet to walk across water (Water Striders)",
        ROLE_EXOTIC_NAME        = "Exotic Families (Beast Mastery Only)",
        ROLE_EXOTIC_DESC        = "Unique families with 2 special abilities, tameable only by Beast Mastery Hunters",
        ROLE_TOME_NAME          = "Requires Taming Tome / Manual",
        ROLE_TOME_DESC          = "Beasts that require learning a special Taming Tome (Florafauns, Undead, Gargons, Feathermanes, Direhorns, Mechanicals, etc.)",
        ROLE_SPIRIT_NAME        = "Rare Spawns & Spirit Beasts",
        ROLE_SPIRIT_DESC        = "Unique rare spawns with respawn timers and Spirit Beasts",
        ROLE_SECRET_NAME        = "Special Summons, Secrets & Raid Bosses",
        ROLE_SECRET_DESC        = "Hidden tracking beasts, item-click summons, rituals, and dungeon/raid bosses",

        -- Short Card Badges
        BADGE_BL                = "|cffff4d4dBL|r",
        BADGE_TANK              = "|cff4da6ffTank|r",
        BADGE_MORTAL            = "|cffff8000MS|r",
        BADGE_DISPEL            = "|cffcc66ffDisp|r",
        BADGE_STEALTH           = "|cff88ff88Stlth|r",
        BADGE_SLOW              = "|cffffff66Slow|r",
        BADGE_WATERWALK         = "|cff00ffffWalk|r",
        BADGE_EXOTIC_BM         = "|cff00ccffBM|r",
        BADGE_TOME_LEARNED      = "|cff00ff96Tome|r",
        BADGE_TOME_UNLEARNED    = "|cffffaa00Tome|r",
        BADGE_QUEST             = "|cffff6600Quest|r",
        BADGE_ACCT_FMT          = "|cff00ccffAcct|r |cffffd100(%d)|r",
        BADGE_CHAR_FMT          = "|cffffaa00Char|r |cffffd100(%d)|r",

        -- Rarity
        RARITY_SPIRIT           = "Spirit Beast",
        RARITY_SECRET           = "Secret / Summon",
        RARITY_BOSS             = "Raid / Dungeon Boss",
        RARITY_RARE             = "Rare Spawn",
        RARITY_COMMON           = "Common",

        -- Grid & Pagination
        PAGE_FMT                = "Page %d/%d",
        EMPTY_GRID_TEXT         = "No beasts match the current filter.\nTry disabling the 'Uncollected' filter or clearing the search box.",

        -- Side Dock
        DOCK_TITLE_BEAST        = " |cffffd100Beast Dossier|r",
        DOCK_TITLE_TOME         = " |cffffd100Tome Dossier|r",
        DOCK_ROTATE_HINT        = "LMB: Rotate • Scroll: Zoom",
        DOCK_SELECT_BEAST       = "Select a beast in the grid",
        DOCK_STATUS_LEARNED     = " |cff00ff96Learned!|r",
        DOCK_STATUS_UNLEARNED   = " |cffff8800Not Learned Yet|r",
        DOCK_STATUS_UNTAMED     = " |cffff8800Not Tamed Yet|r",
        DOCK_SCOPE_ACCOUNT      = "|cff00ccffAccount-Wide|r",
        DOCK_SCOPE_CHAR         = "|cffffaa00Character-Specific|r",

        -- Side Dock Buttons
        BTN_NAV_BEAST           = " Plot Route to Beast (TomTom + Map)",
        BTN_NAV_TOME            = " Plot Route to Tome (TomTom + Map)",
        BTN_SHOW_MAP            = "On Map",
        BTN_MARK_COLLECTED      = " Mark Owned",
        BTN_UNMARK              = "Unmark",
        BTN_MARK_LEARNED        = " Mark Learned",
        BTN_BEASTS_COUNT_FMT    = "Beasts (%d)",

        -- Tome Dossier Lines
        TOME_UNLOCKS_FMT        = "%s |cffffd100Unlocks:|r |cff66ff99%s|r",
        TOME_MODELS_COUNT_FMT   = "   • |cffffcc00Models in database:|r |cffffffff%d|r (click 'Beasts (%d)' below to view them all!)",
        TOME_SCOPE_ACCT_LINE    = "   • |cffffcc00Unlock Scope:|r |cff00ccffAccount-Wide (Warband)|r — only needs to be unlocked once!",
        TOME_SCOPE_CHAR_LINE    = "   • |cffffcc00Unlock Scope:|r |cffffaa00Character-Specific|r (Hunter alts must obtain it separately).",
        TOME_INNATE_RACE_FMT    = "   • |cffffcc00Innate Racial Knowledge:|r |cff00ff96%s|r",
        TOME_DROP_RATE_FMT      = "   • |cffffcc00Drop Chance:|r |cff00ccff%s|r",
        TOME_EXPECTED_KILLS_FMT = "   • |cffffcc00Expected Kills (Avg):|r |cffffffff%s|r",
        TOME_TRIES_LUCK_FMT     = "   • |cffffcc00Your Attempts (Kills):|r |cffffcc00%d|r |cff88ff88(cumulative luck: %.1f%%)|r",
        TOME_TRIES_SIMPLE_FMT   = "   • |cffffcc00Your Attempts (Kills):|r |cffffcc00%d|r",
        TOME_HOW_TO_HEADER      = " |cffffd100How & Where to Obtain (Detailed):|r",
        TOME_LOCATION_HEADER    = " |cffffd100Location & Waypoints:|r",
        TOME_ZONE_LINE_FMT      = "   • |cff00ccffZone:|r |cffffffff%s|r",
        TOME_POINT_LINE_FMT     = "   • |cffffd100Waypoint %d:|r |cff00ff96%.1f, %.1f|r%s",

        -- Beast Dossier Lines
        BEAST_FAMILY_LINE_FMT   = "%s |cffffd100Family:|r |cffffffff%s|r%s",
        BEAST_SPEC_LINE_FMT     = "|T%s:14:14:0:0|t |cffffd100Specialization:|r %s%s|r",
        BEAST_ACTIVE_LINE_FMT   = "   • |cffffcc00Active:|r %s — %s",
        BEAST_PASSIVE_LINE_FMT  = "   • |cffffcc00Passive:|r %s (%s)",
        BEAST_SKILL_LINE_FMT    = "   • |cff00ff96Family Skill:|r %s",
        BEAST_QUEST_ONLY_LINE   = "   • |cffff6600Availability:|r |cffffd100Quest-Phase Exclusive — tame BEFORE turning in!|r",
        BEAST_SPECIAL_GROUP_FMT = "%s |cffffd100Special Group:|r |cff66ff99%s|r",
        BEAST_TOME_LEARNED_FMT  = "   • |cff00ff96Skill Learned:|r %s",
        BEAST_TOME_REQ_RED_FMT  = "   • |cffff5533Requires Item / Tome:|r |cffffffff%s|r",
        BEAST_TOME_REQ_YEL_FMT  = "   • |cffffaa00Requires Item / Tome:|r |cffffffff%s|r",
        BEAST_WHERE_GET_FMT     = "|cffffaa66   Source:|r %s",
        BEAST_WHERE_HEADER      = " |cffffd100Habitat & Spawn Locations:|r",
        BEAST_MAIN_ZONE_FMT     = "   • |cff00ccffPrimary Zone:|r |cffffffff%s|r",
        BEAST_RESPAWN_FMT       = "   • |cff00ccffRespawn:|r %s",
        BEAST_NPCS_HEADER_FMT   = "|cffffd100Tameable NPCs with this Look (%d):|r",
        BEAST_HOW_TO_HEADER     = " |cffffd100Taming Guide & Mechanics:|r",

        -- Card Tooltips
        TT_CARD_UNLOCKS_FMT     = "Unlocks: |cff66ff99%s|r (%d looks)",
        TT_CARD_SKILL_LEARNED   = " |cff00ff96Skill Learned!|r",
        TT_CARD_SKILL_UNLEARNED = " |cffff8800Not Learned Yet|r",
        TT_CARD_DROP_CHANCE_FMT = "|cffffd100Drop Chance:|r |cff00ccff%s|r",
        TT_CARD_EXPECTED_FMT    = "|cffffd100Expected Kills:|r |cffffffff%s|r",
        TT_CARD_TRIES_LUCK_FMT  = "|cffffd100Your Attempts (Kills):|r |cffffcc00%d|r |cffaaaaaa(cumulative luck: %.1f%%)|r",
        TT_CARD_TRIES_FMT       = "|cffffd100Your Attempts (Kills):|r |cffffcc00%d|r",
        TT_CARD_WHERE_GET_FMT   = "|cffffd100Source:|r %s",
        TT_CARD_TOME_HELP1      = "|cffffd100LMB:|r Detailed Dossier  |  |cffffd100RMB:|r Plot Route",
        TT_CARD_TOME_HELP2      = "|cffffd100Shift+LMB:|r Show all beasts unlocked by this tome",
        TT_CARD_FAMILY_FMT      = "Family: %s",
        TT_CARD_SKILL_FMT       = "Ability: |cff00ff96%s|r",
        TT_CARD_TOME_OK_FMT     = " %s (Learned)",
        TT_CARD_TOME_NEED_FMT   = " Requires: %s",
        TT_CARD_ZONE_FMT        = "Zone: |cff00ccff%s|r",
        TT_CARD_BEAST_HELP      = "|cffffd100LMB:|r Detailed Dossier  |  |cffffd100RMB:|r Plot Route",

        -- Stables / Collection Status
        COL_MANUAL              = "Marked in Collection",
        COL_STABLED_FMT         = "In Stables: %s",
        ACTIVE_PET_FALLBACK     = "Active Pet",
        UNKNOWN_ZONE            = "Unknown",

        -- Minimap Button & Copy Link Popup
        MINIMAP_TT_SUBTITLE     = "3D Hunter Pet Model Wardrobe & Tome Tracker",
        MINIMAP_TT_COLLECTED    = "Looks Collected: |cff00ff96%d / %d|r",
        MINIMAP_TT_LCLICK       = "|cffffd100Left-Click:|r Open / Close Collection",
        MINIMAP_TT_RCLICK       = "|cffffd100Right-Click:|r Filter by 'Uncollected'",
        MINIMAP_TT_DRAG         = "|cffaaaaaaHold Left-Click and drag around the minimap|r",
        COPY_POPUP_HINT         = "Press |cffffd100Ctrl + C|r to copy the link to your browser:",

        -- Open-World Unit Tooltips & Waypoint Tooltips
        UNIT_TT_HEADER_FMT      = "%s |cff00ff96BeastCollector:|r %s",
        UNIT_TT_SKILL_FMT       = "   |cffffd100Ability:|r %s",
        UNIT_TT_EXOTIC_NO_BM    = "   |cffff4444CANNOT TAME RIGHT NOW:|r Exotic family — switch to |cff00ccffBeast Mastery|r spec!",
        UNIT_TT_EXOTIC_OK_BM    = "   |cff00ccffExotic Beast:|r Tameable (Beast Mastery active)",
        UNIT_TT_LEVEL_HIGH_FMT  = "   |cffff4444CANNOT TAME RIGHT NOW:|r Creature level (%d) is higher than yours (%d)!",
        UNIT_TT_NOT_TAMEABLE    = "   |cffff8800Note:|r This specific NPC may not be tameable (check with Beast Lore).",
        UNIT_TT_TOME_OK_FMT     = "   %s |cff00ff96%s:|r Learned",
        UNIT_TT_TOME_NEED_FMT   = "   %s |cffff5533Requires:|r %s",
        UNIT_TT_MISSING_MODEL   = "   %s |cffffaa00You haven't collected this look in your stables yet!|r",
        UNIT_TT_QUEST_ONLY_WARN = "   |cffff5500! QUEST EXCLUSIVE: Tame BEFORE turning in the quest (phase locks after)!|r",
        UNIT_TT_DROPS_TOME_FMT  = "%s |cff00ff96BeastCollector:|r Drops '|cffffd100%s|r'",
        UNIT_TT_DROP_RATE_FMT   = "   • Drop Chance: |cff00ccff%s|r",
        UNIT_TT_EXPECTED_FMT    = "   • Expected Kills: |cffffffff%s|r",
        UNIT_TT_TRIES_FMT       = "   • Your Attempts (Kills): |cffffcc00%d|r (cumulative luck: %.1f%%)",
        UNIT_TT_ALREADY_LEARNED = "   • |cff00ff96You have already learned this tome!|r",
        WP_TT_HEADER            = "|cff00ff96BeastCollector — Navigator|r",
        WP_TT_TARGET_FMT        = "|cffffd100Target:|r |cffffffff%s|r",
        WP_TT_STEP_FMT          = "|cff00ccffStep %d of %d:|r %s",
        WP_TT_ROUTE_HEADER      = "|cffffd100Portal Route:|r",
        WP_TT_STEP_CURRENT_FMT  = "   |cffffd100[->] %d. %s (current)|r",

        -- Quest-Exclusive Popup Alert Banner (MountCollector style)
        ALERT_QUEST_HEADER      = "WARNING: QUEST-EXCLUSIVE BEAST NEARBY!",
        ALERT_QUEST_SUB         = "Tame BEFORE turning in the quest — unobtainable afterwards!",
        ALERT_TT_TITLE          = "|cffff6600BeastCollector — Quest-Phase Exclusive|r",
        ALERT_TT_DESC           = "This beast only exists inside a quest phase or scenario and is NOT in your collection yet!",
        ALERT_TT_CLICK_HINT     = "|cff00ff96Left-Click:|r Open Beast Dossier   |cffaaaaaaRight-Click:|r Dismiss",
        CHAT_QUEST_ALERT_FMT    = "|cffff6600[BeastCollector — Quest Exclusive!]|r |cffffd100%s|r (%s) spotted nearby — missing from your stables! Tame BEFORE turning in the quest!",
    },
}

addon.Locales = Locales

function addon:GetActiveLocale()
    local pref = self.db and self.db.settings and self.db.settings.language
    if pref == "ruRU" or pref == "enUS" then
        return pref
    end
    local clientLoc = (_G.GetLocale and _G.GetLocale()) or "enUS"
    if clientLoc == "ruRU" then
        return "ruRU"
    end
    return "enUS"
end

function addon:IsEnglish()
    return self:GetActiveLocale() == "enUS"
end

function addon:L(key, ...)
    local loc = self:GetActiveLocale()
    local tbl = Locales[loc] or Locales.enUS
    local val = tbl[key] or Locales.enUS[key] or Locales.ruRU[key] or key
    if select("#", ...) > 0 then
        local ok, formatted = pcall(string.format, val, ...)
        if ok then return formatted end
    end
    return val
end

function addon:ToggleLanguage()
    if not self.db then return end
    self.db.settings = self.db.settings or {}
    if self:IsEnglish() then
        self.db.settings.language = "ruRU"
    else
        self.db.settings.language = "enUS"
    end
    print(self:L("CHAT_LANG_SWITCHED"))
    if self.ApplyLocaleToStaticUI then
        self:ApplyLocaleToStaticUI()
    end
    if self.RefreshUI then
        self:RefreshUI()
    end
    if self.alertFrame and self.alertFrame:IsShown() and self.alertFrame.beast then
        local b = self.alertFrame.beast
        local fam = self.FamilyByID and self.FamilyByID[b.family]
        local famName = (fam and self:GetFamilyName(fam)) or ""
        local bName = self:GetBeastName(b)
        self.alertFrame.headerFS:SetText("|TInterface\\GossipFrame\\AvailableQuestIcon:13:13:0:0|t " .. self:L("ALERT_QUEST_HEADER"))
        self.alertFrame.nameFS:SetText(bName .. (famName ~= "" and (" |cff00ff96[" .. famName .. "]|r") or ""))
        self.alertFrame.subFS:SetText(self:L("ALERT_QUEST_SUB"))
    end
end

-- ============================================================================
-- LOCALIZED DATA GETTERS (Beasts, Families, Specs, Tomes)
-- ============================================================================
function addon:GetBeastName(beast)
    if not beast then return "" end
    if self:IsEnglish() and beast.nameEN and beast.nameEN ~= "" then
        return beast.nameEN
    end
    return beast.name or beast.nameEN or ""
end

function addon:GetBeastSubTitle(beast)
    if not beast then return "" end
    if self:IsEnglish() then
        return beast.subTitleEN or beast.modelGroup or beast.subTitle or ""
    end
    if beast.ruModelGroup and beast.subTitle and not string.find(beast.subTitle, beast.ruModelGroup, 1, true) then
        return beast.ruModelGroup .. " • " .. beast.subTitle
    end
    return beast.subTitle or beast.ruModelGroup or ""
end

function addon:GetBeastZone(beast)
    if not beast then return self:L("UNKNOWN_ZONE") end
    if self:IsEnglish() then
        return beast.zoneEN or beast.zone or self:L("UNKNOWN_ZONE")
    end
    return beast.zone or beast.zoneEN or self:L("UNKNOWN_ZONE")
end

function addon:GetBeastRespawn(beast)
    if not beast then return nil end
    if self:IsEnglish() then
        return beast.respawnEN or beast.respawn
    end
    return beast.respawn or beast.respawnEN
end

function addon:GetBeastHowTo(beast)
    if not beast then return nil end
    if self:IsEnglish() then
        return beast.howToEN or beast.howTo
    end
    return beast.howTo or beast.howToEN
end

function addon:GetFamilyName(fam)
    if not fam then return "" end
    if self:IsEnglish() and fam.nameEN then
        return fam.nameEN
    end
    return fam.name or fam.nameEN or ""
end

function addon:GetFamilySkill(fam)
    if not fam then return "" end
    if self:IsEnglish() and fam.familySkillEN then
        return fam.familySkillEN
    end
    return fam.familySkill or fam.familySkillEN or ""
end

function addon:GetFamilyDesc(fam)
    if not fam then return nil end
    if self:IsEnglish() and fam.familyDescEN then
        return fam.familyDescEN
    end
    return fam.familyDesc or fam.familyDescEN
end

function addon:GetSpecName(spec)
    if not spec then return "" end
    if self:IsEnglish() and spec.nameEN then
        return spec.nameEN
    end
    return spec.name or spec.nameEN or ""
end

function addon:GetSpecActiveName(spec)
    if not spec then return "" end
    if self:IsEnglish() and spec.activeNameEN then
        return spec.activeNameEN
    end
    return spec.activeName or ""
end

function addon:GetSpecActiveDesc(spec)
    if not spec then return "" end
    if self:IsEnglish() and spec.activeDescEN then
        return spec.activeDescEN
    end
    return spec.activeDesc or ""
end

function addon:GetSpecPassiveName(spec)
    if not spec then return "" end
    if self:IsEnglish() and spec.passiveNameEN then
        return spec.passiveNameEN
    end
    return spec.passiveName or ""
end

function addon:GetSpecPassiveDesc(spec)
    if not spec then return "" end
    if self:IsEnglish() and spec.passiveDescEN then
        return spec.passiveDescEN
    end
    return spec.passiveDesc or ""
end

function addon:GetTomeName(tome)
    if not tome then return "" end
    if self:IsEnglish() and tome.enName then
        return tome.enName
    end
    return tome.name or tome.enName or ""
end

function addon:GetTomeShortTitle(tome)
    if not tome then return "" end
    if self:IsEnglish() and tome.shortTitleEN then
        return tome.shortTitleEN
    end
    return tome.shortTitle or tome.name or ""
end

function addon:GetTomeCategoryName(tome)
    if not tome then return "" end
    if self:IsEnglish() and tome.categoryNameEN then
        return tome.categoryNameEN
    end
    return tome.categoryName or tome.name or ""
end

function addon:GetTomeAutoRaceText(tome)
    if not tome then return nil end
    if self:IsEnglish() then
        return tome.autoRaceTextEN or tome.autoRaceText
    end
    return tome.autoRaceText or tome.autoRaceTextEN
end

function addon:GetTomeDropRateText(tome)
    if not tome then return nil end
    if self:IsEnglish() then
        return tome.dropRateTextEN or tome.dropRateText
    end
    return tome.dropRateText or tome.dropRateTextEN
end

function addon:GetTomeExpectedKillsText(tome)
    if not tome then return nil end
    if self:IsEnglish() then
        return tome.expectedKillsTextEN or tome.expectedKillsText
    end
    return tome.expectedKillsText or tome.expectedKillsTextEN
end

function addon:GetTomeZone(tome)
    if not tome then return self:L("UNKNOWN_ZONE") end
    if self:IsEnglish() then
        return tome.zoneEN or tome.zone or self:L("UNKNOWN_ZONE")
    end
    return tome.zone or tome.zoneEN or self:L("UNKNOWN_ZONE")
end

function addon:GetTomeSource(tome)
    if not tome then return nil end
    if self:IsEnglish() then
        return tome.sourceEN or tome.source
    end
    return tome.source or tome.sourceEN
end

function addon:GetTomeHowTo(tome)
    if not tome then return nil end
    if self:IsEnglish() then
        return tome.howToObtainEN or tome.howToObtain
    end
    return tome.howToObtain or tome.howToObtainEN
end

function addon:GetCoordNote(coord)
    if not coord then return nil end
    if self:IsEnglish() then
        return coord.noteEN or coord.note
    end
    return coord.note or coord.noteEN
end
