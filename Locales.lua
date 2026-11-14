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

    deDE = {
        TITLE_ALL_FAMILIES      = "Jägerbegleiter — Alle 61 Familien",
        TITLE_TOMES_TAB         = "Jägerbegleiter — Zähmungsfolianten (11)",
        TITLE_SPEC_PREFIX       = "Jägerbegleiter — Spezialisierung: ",
        TITLE_PREFIX            = "Jägerbegleiter — ",
        TAB_ALL_MODELS          = "Alle Modelle",
        TAB_UNCOLLECTED         = "Nicht gesammelt",
        TAB_TOMES_FMT           = " Folianten (%d)",
        PROGRESS_TOMES_FMT      = "Folianten: %d / %d",
        SEARCH_PLACEHOLDER      = "Wildtier / Zone / Foliant...",
        LANG_BTN_LABEL          = "RU",
        LANG_BTN_TOOLTIP_TITLE  = "Sprache: Deutsch (DE)",
        LANG_BTN_TOOLTIP_DESC   = "Klicken zum Umschalten (RU / EN) oder /bc lang auto!",
        CHAT_LANG_SWITCHED      = "|cff00ff96[BeastCollector]|r Sprache geändert auf: |cffffd100Deutsch (DE)|r.",
        FILTER_TRAITS_DEFAULT   = "Fähigkeiten & Rollen [v]",
        SPEC_MENU_ALL_FMT       = "Alle: %s (%d)",
        TAG_EXOTIC_PAREN        = "(Exotisch)",
        TAG_TOME_PAREN          = "(Foliant)",
        TAG_EXOTIC_FULL         = " |cff00ccff(Exotisch — Nur Tierherrschaft)|r",
        TAG_ALL_SPECS_FULL      = " |cff88ff88(Alle 3 Speccs)|r",
        TT_ALL_FAMILIES_TITLE   = "Alle 61 Begleiterfamilien",
        TT_ALL_FAMILIES_DESC    = "Zeigt alle zähmbaren Modelle (Wildheit, Gerissenheit und Hartnäckigkeit).",
        RARITY_SPIRIT           = "Geisterbestie",
        RARITY_SECRET           = "Geheimnis / Beschwörung",
        RARITY_BOSS             = "Raid- / Dungeonboss",
        RARITY_RARE             = "Seltener Gegner (Rare)",
        RARITY_COMMON           = "Gewöhnlich",
        PAGE_FMT                = "Seite %d/%d",
        DOCK_TITLE_BEAST        = " |cffffd100Begleiter-Dossier|r",
        DOCK_TITLE_TOME         = " |cffffd100Folianten-Dossier|r",
        DOCK_ROTATE_HINT        = "LMT: Drehen • Mausrad: Zoom",
        DOCK_STATUS_LEARNED     = " |cff00ff96Erlernt!|r",
        DOCK_STATUS_UNLEARNED   = " |cffff8800Noch nicht erlernt|r",
        DOCK_STATUS_UNTAMED     = " |cffff8800Noch nicht gezähmt|r",
        DOCK_SCOPE_ACCOUNT      = "|cff00ccffAccountweit|r",
        DOCK_SCOPE_CHAR         = "|cffffaa00Charakterspezifisch|r",
        BTN_NAV_BEAST           = " Route zum Wildtier (TomTom + Karte)",
        BTN_NAV_TOME            = " Route zum Folianten (TomTom + Karte)",
        BTN_SHOW_MAP            = "Auf Karte",
        BTN_MARK_COLLECTED      = " Als gesammelt",
        BTN_UNMARK              = "Abwählen",
        BTN_MARK_LEARNED        = " Als erlernt",
        BTN_BEASTS_COUNT_FMT    = "Wildtiere (%d)",
        COL_MANUAL              = "In Sammlung markiert",
        COL_STABLED_FMT         = "Im Stall: %s",
        ACTIVE_PET_FALLBACK     = "Aktiver Begleiter",
        UNKNOWN_ZONE            = "Unbekannt",
        MINIMAP_TT_SUBTITLE     = "3D-Begleiter-Kleiderschrank & Folianten-Tracker",
        MINIMAP_TT_COLLECTED    = "Gesammelte Modelle: |cff00ff96%d / %d|r",
        UNIT_TT_MISSING_MODEL   = "   %s |cffffaa00Dieses Modell fehlt noch in deinem Stall!|r",
        UNIT_TT_QUEST_ONLY_WARN = "   |cffff5500! QUEST-EXKLUSIV: VOR Questabgabe zähmen (danach nicht mehr verfügbar)!|r",
        ALERT_QUEST_HEADER      = "ACHTUNG: QUEST-EXKLUSIVES WILDTIER IN DER NÄHE!",
        ALERT_QUEST_SUB         = "Zähme es VOR Abgabe der Quest — danach für immer verloren!",
        ALERT_TT_TITLE          = "|cffff6600BeastCollector — Quest-Exklusiv|r",
        ALERT_TT_DESC           = "Dieses Wildtier existiert nur während dieser Questphase und fehlt noch in deiner Sammlung!",
        ALERT_TT_CLICK_HINT     = "|cff00ff96Linksklick:|r Dossier öffnen   |cffaaaaaaRechtsklick:|r Schließen",
        CHAT_QUEST_ALERT_FMT    = "|cffff6600[BeastCollector — Quest-Exklusiv!]|r |cffffd100%s|r (%s) in der Nähe — fehlt in deinem Stall! Unbedingt VOR Questabgabe zähmen!",
    },

    frFR = {
        TITLE_ALL_FAMILIES      = "Familiers du chasseur — Les 61 familles",
        TITLE_TOMES_TAB         = "Familiers du chasseur — Tomes de domptage (11)",
        TITLE_SPEC_PREFIX       = "Familiers du chasseur — Spécialisation : ",
        TITLE_PREFIX            = "Familiers du chasseur — ",
        TAB_ALL_MODELS          = "Tous les modèles",
        TAB_UNCOLLECTED         = "Non collectés",
        TAB_TOMES_FMT           = " Tomes (%d)",
        PROGRESS_TOMES_FMT      = "Tomes : %d / %d",
        SEARCH_PLACEHOLDER      = "Chercher bête / zone / tome...",
        LANG_BTN_LABEL          = "RU",
        LANG_BTN_TOOLTIP_TITLE  = "Langue : Français (FR)",
        LANG_BTN_TOOLTIP_DESC   = "Cliquez pour basculer (RU / EN) ou /bc lang auto !",
        CHAT_LANG_SWITCHED      = "|cff00ff96[BeastCollector]|r Langue changée en : |cffffd100Français (FR)|r.",
        FILTER_TRAITS_DEFAULT   = "Traits & Techniques [v]",
        SPEC_MENU_ALL_FMT       = "Tout : %s (%d)",
        TAG_EXOTIC_PAREN        = "(Exotique)",
        TAG_TOME_PAREN          = "(Tome)",
        TAG_EXOTIC_FULL         = " |cff00ccff(Exotique — Maîtrise des bêtes)|r",
        TAG_ALL_SPECS_FULL      = " |cff88ff88(Les 3 spécialisations)|r",
        RARITY_SPIRIT           = "Esprit de bête",
        RARITY_SECRET           = "Secret / Invocation",
        RARITY_BOSS             = "Boss de raid / donjon",
        RARITY_RARE             = "Monstre rare",
        RARITY_COMMON           = "Commun",
        PAGE_FMT                = "Page %d/%d",
        DOCK_TITLE_BEAST        = " |cffffd100Dossier du familier|r",
        DOCK_TITLE_TOME         = " |cffffd100Dossier du tome|r",
        DOCK_ROTATE_HINT        = "Clic G : Tourner • Molette : Zoom",
        DOCK_STATUS_LEARNED     = " |cff00ff96Appris !|r",
        DOCK_STATUS_UNLEARNED   = " |cffff8800Non appris|r",
        DOCK_STATUS_UNTAMED     = " |cffff8800Non dompté|r",
        DOCK_SCOPE_ACCOUNT      = "|cff00ccffLié au compte|r",
        DOCK_SCOPE_CHAR         = "|cffffaa00Lié au personnage|r",
        BTN_NAV_BEAST           = " Tracer la route vers la bête (TomTom + Carte)",
        BTN_NAV_TOME            = " Tracer la route vers le tome (TomTom + Carte)",
        BTN_SHOW_MAP            = "Carte",
        BTN_MARK_COLLECTED      = " Marquer acquis",
        BTN_UNMARK              = "Retirer",
        BTN_MARK_LEARNED        = " Marquer appris",
        BTN_BEASTS_COUNT_FMT    = "Bêtes (%d)",
        COL_MANUAL              = "Marqué dans la collection",
        COL_STABLED_FMT         = "À l'écurie : %s",
        ACTIVE_PET_FALLBACK     = "Familier actif",
        UNKNOWN_ZONE            = "Inconnu",
        MINIMAP_TT_SUBTITLE     = "Garde-robe 3D des familiers & Suivi des tomes",
        MINIMAP_TT_COLLECTED    = "Apparences collectées : |cff00ff96%d / %d|r",
        UNIT_TT_MISSING_MODEL   = "   %s |cffffaa00Cette apparence n'est pas encore dans votre écurie !|r",
        UNIT_TT_QUEST_ONLY_WARN = "   |cffff5500! EXCLUSIVITÉ DE QUÊTE : Domptez AVANT de rendre la quête !|r",
        ALERT_QUEST_HEADER      = "ATTENTION : BÊTE EXCLUSIVE DE QUÊTE À PROXIMITÉ !",
        ALERT_QUEST_SUB         = "Domptez-la AVANT de rendre la quête — impossible à obtenir ensuite !",
        ALERT_TT_TITLE          = "|cffff6600BeastCollector — Exclusivité de quête|r",
        ALERT_TT_DESC           = "Cette bête n'existe que pendant cette phase de quête et n'est PAS encore dans votre collection !",
        ALERT_TT_CLICK_HINT     = "|cff00ff96Clic gauche :|r Ouvrir le dossier   |cffaaaaaaClic droit :|r Fermer",
        CHAT_QUEST_ALERT_FMT    = "|cffff6600[BeastCollector — Exclusivité de quête !]|r |cffffd100%s|r (%s) à proximité — absent de votre écurie ! Domptez-le AVANT de rendre la quête !",
    },

    esES = {
        TITLE_ALL_FAMILIES      = "Mascotas de cazador — Las 61 familias",
        TITLE_TOMES_TAB         = "Mascotas de cazador — Tomos de doma (11)",
        TITLE_SPEC_PREFIX       = "Mascotas de cazador — Especialización: ",
        TITLE_PREFIX            = "Mascotas de cazador — ",
        TAB_ALL_MODELS          = "Todos los modelos",
        TAB_UNCOLLECTED         = "No coleccionados",
        TAB_TOMES_FMT           = " Tomos (%d)",
        PROGRESS_TOMES_FMT      = "Tomos: %d / %d",
        SEARCH_PLACEHOLDER      = "Buscar bestia / zona / tomo...",
        LANG_BTN_LABEL          = "RU",
        LANG_BTN_TOOLTIP_TITLE  = "Idioma: Español (ES)",
        LANG_BTN_TOOLTIP_DESC   = "¡Haz clic para cambiar (RU / EN) o usa /bc lang auto!",
        CHAT_LANG_SWITCHED      = "|cff00ff96[BeastCollector]|r Idioma cambiado a: |cffffd100Español (ES)|r.",
        FILTER_TRAITS_DEFAULT   = "Rasgos y Habilidades [v]",
        SPEC_MENU_ALL_FMT       = "Todo: %s (%d)",
        TAG_EXOTIC_PAREN        = "(Exótica)",
        TAG_TOME_PAREN          = "(Tomo)",
        TAG_EXOTIC_FULL         = " |cff00ccff(Exótica — Solo Bestias)|r",
        TAG_ALL_SPECS_FULL      = " |cff88ff88(Las 3 especializaciones)|r",
        RARITY_SPIRIT           = "Bestia espíritu",
        RARITY_SECRET           = "Secreto / Invocación",
        RARITY_BOSS             = "Jefe de banda / mazmorra",
        RARITY_RARE             = "Raro",
        RARITY_COMMON           = "Común",
        PAGE_FMT                = "Pág. %d/%d",
        DOCK_TITLE_BEAST        = " |cffffd100Dosier de bestia|r",
        DOCK_TITLE_TOME         = " |cffffd100Dosier de tomo|r",
        DOCK_ROTATE_HINT        = "Clic izq.: Rotar • Rueda: Zoom",
        DOCK_STATUS_LEARNED     = " |cff00ff96¡Aprendido!|r",
        DOCK_STATUS_UNLEARNED   = " |cffff8800No aprendido|r",
        DOCK_STATUS_UNTAMED     = " |cffff8800No domesticado|r",
        DOCK_SCOPE_ACCOUNT      = "|cff00ccffPara toda la cuenta|r",
        DOCK_SCOPE_CHAR         = "|cffffaa00Por personaje|r",
        BTN_NAV_BEAST           = " Trazar ruta a la bestia (TomTom + Mapa)",
        BTN_NAV_TOME            = " Trazar ruta al tomo (TomTom + Mapa)",
        BTN_SHOW_MAP            = "En mapa",
        BTN_MARK_COLLECTED      = " Marcar propio",
        BTN_UNMARK              = "Desmarcar",
        BTN_MARK_LEARNED        = " Marcar aprendido",
        BTN_BEASTS_COUNT_FMT    = "Bestias (%d)",
        COL_MANUAL              = "Marcado en tu colección",
        COL_STABLED_FMT         = "En establo: %s",
        ACTIVE_PET_FALLBACK     = "Mascota activa",
        UNKNOWN_ZONE            = "Desconocido",
        MINIMAP_TT_SUBTITLE     = "Armario 3D de mascotas de cazador y Tomos",
        MINIMAP_TT_COLLECTED    = "Apariencias coleccionadas: |cff00ff96%d / %d|r",
        UNIT_TT_MISSING_MODEL   = "   %s |cffffaa00¡Aún no tienes esta apariencia en tu establo!|r",
        UNIT_TT_QUEST_ONLY_WARN = "   |cffff5500! EXCLUSIVO DE MISIÓN: ¡Domestícalo ANTES de entregar la misión!|r",
        ALERT_QUEST_HEADER      = "¡ATENCIÓN: BESTIA EXCLUSIVA DE MISIÓN CERCA!",
        ALERT_QUEST_SUB         = "¡Domestícala ANTES de entregar la misión — no podrás conseguirla después!",
        ALERT_TT_TITLE          = "|cffff6600BeastCollector — Exclusivo de misión|r",
        ALERT_TT_DESC           = "¡Esta bestia solo existe dentro de una fase de misión y AÚN NO está en tu colección!",
        ALERT_TT_CLICK_HINT     = "|cff00ff96Clic izq.:|r Abrir dosier   |cffaaaaaaClic der.:|r Cerrar",
        CHAT_QUEST_ALERT_FMT    = "|cffff6600[BeastCollector — ¡Exclusivo de misión!]|r |cffffd100%s|r (%s) cerca — ¡falta en tu establo! ¡Domestícalo ANTES de entregar la misión!",
    },

    ptBR = {
        TITLE_ALL_FAMILIES      = "Ajudantes de Caçador — Todas as 61 Famílias",
        TITLE_TOMES_TAB         = "Ajudantes de Caçador — Tomos de Domar (11)",
        TITLE_SPEC_PREFIX       = "Ajudantes de Caçador — Especialização: ",
        TITLE_PREFIX            = "Ajudantes de Caçador — ",
        TAB_ALL_MODELS          = "Todos os Modelos",
        TAB_UNCOLLECTED         = "Não Coletados",
        TAB_TOMES_FMT           = " Tomos (%d)",
        PROGRESS_TOMES_FMT      = "Tomos: %d / %d",
        SEARCH_PLACEHOLDER      = "Buscar fera / zona / tomo...",
        LANG_BTN_LABEL          = "RU",
        LANG_BTN_TOOLTIP_TITLE  = "Idioma: Português (BR)",
        LANG_BTN_TOOLTIP_DESC   = "Clique para alternar (RU / EN) ou use /bc lang auto!",
        CHAT_LANG_SWITCHED      = "|cff00ff96[BeastCollector]|r Idioma alterado para: |cffffd100Português (BR)|r.",
        FILTER_TRAITS_DEFAULT   = "Traços e Habilidades [v]",
        SPEC_MENU_ALL_FMT       = "Todos: %s (%d)",
        TAG_EXOTIC_PAREN        = "(Exótico)",
        TAG_TOME_PAREN          = "(Tomo)",
        TAG_EXOTIC_FULL         = " |cff00ccff(Exótico — Apenas Domínio das Feras)|r",
        TAG_ALL_SPECS_FULL      = " |cff88ff88(Todas as 3 Especializações)|r",
        RARITY_SPIRIT           = "Fera Espiritual",
        RARITY_SECRET           = "Segredo / Evocação",
        RARITY_BOSS             = "Chefe de Raide / Masmorra",
        RARITY_RARE             = "Raro",
        RARITY_COMMON           = "Comum",
        PAGE_FMT                = "Pág. %d/%d",
        DOCK_TITLE_BEAST        = " |cffffd100Dossiê da Fera|r",
        DOCK_TITLE_TOME         = " |cffffd100Dossiê do Tomo|r",
        DOCK_ROTATE_HINT        = "Botão Esq.: Girar • Roda: Zoom",
        DOCK_STATUS_LEARNED     = " |cff00ff96Aprendido!|r",
        DOCK_STATUS_UNLEARNED   = " |cffff8800Não Aprendido|r",
        DOCK_STATUS_UNTAMED     = " |cffff8800Não Domado|r",
        DOCK_SCOPE_ACCOUNT      = "|cff00ccffPara toda a Conta|r",
        DOCK_SCOPE_CHAR         = "|cffffaa00Por Personagem|r",
        BTN_NAV_BEAST           = " Traçar Rota para a Fera (TomTom + Mapa)",
        BTN_NAV_TOME            = " Traçar Rota para o Tomo (TomTom + Mapa)",
        BTN_SHOW_MAP            = "No Mapa",
        BTN_MARK_COLLECTED      = " Marcar Coletado",
        BTN_UNMARK              = "Desmarcar",
        BTN_MARK_LEARNED        = " Marcar Aprendido",
        BTN_BEASTS_COUNT_FMT    = "Feras (%d)",
        COL_MANUAL              = "Marcado na Coleção",
        COL_STABLED_FMT         = "No Estábulo: %s",
        ACTIVE_PET_FALLBACK     = "Ajudante Ativo",
        UNKNOWN_ZONE            = "Desconhecido",
        MINIMAP_TT_SUBTITLE     = "Guarda-Roupa 3D de Feras e Rastreador de Tomos",
        MINIMAP_TT_COLLECTED    = "Aparências Coletadas: |cff00ff96%d / %d|r",
        UNIT_TT_MISSING_MODEL   = "   %s |cffffaa00Você ainda não tem esta aparência no estábulo!|r",
        UNIT_TT_QUEST_ONLY_WARN = "   |cffff5500! EXCLUSIVO DE MISSÃO: Dome ANTES de entregar a missão!|r",
        ALERT_QUEST_HEADER      = "ATENÇÃO: FERA EXCLUSIVA DE MISSÃO POR PERTO!",
        ALERT_QUEST_SUB         = "Dome ANTES de entregar a missão — impossível obter depois!",
        ALERT_TT_TITLE          = "|cffff6600BeastCollector — Exclusivo de Missão|r",
        ALERT_TT_DESC           = "Esta fera só existe dentro de uma fase de missão e AINDA NÃO está na sua coleção!",
        ALERT_TT_CLICK_HINT     = "|cff00ff96Clique Esq.:|r Abrir Dossiê   |cffaaaaaaClique Dir.:|r Fechar",
        CHAT_QUEST_ALERT_FMT    = "|cffff6600[BeastCollector — Exclusivo de Missão!]|r |cffffd100%s|r (%s) por perto — falta no seu estábulo! Dome ANTES de entregar a missão!",
    },

    itIT = {
        TITLE_ALL_FAMILIES      = "Famigli del Cacciatore — Tutte le 61 Famiglie",
        TITLE_TOMES_TAB         = "Famigli del Cacciatore — Tomi d'Addomesticamento (11)",
        TITLE_SPEC_PREFIX       = "Famigli del Cacciatore — Specializzazione: ",
        TITLE_PREFIX            = "Famigli del Cacciatore — ",
        TAB_ALL_MODELS          = "Tutti i Modelli",
        TAB_UNCOLLECTED         = "Non Collezionati",
        TAB_TOMES_FMT           = " Tomi (%d)",
        PROGRESS_TOMES_FMT      = "Tomi: %d / %d",
        SEARCH_PLACEHOLDER      = "Cerca bestia / zona / tomo...",
        LANG_BTN_LABEL          = "RU",
        LANG_BTN_TOOLTIP_TITLE  = "Lingua: Italiano (IT)",
        LANG_BTN_TOOLTIP_DESC   = "Clicca per cambiare (RU / EN) o usa /bc lang auto!",
        CHAT_LANG_SWITCHED      = "|cff00ff96[BeastCollector]|r Lingua impostata su: |cffffd100Italiano (IT)|r.",
        FILTER_TRAITS_DEFAULT   = "Tratti e Abilità [v]",
        SPEC_MENU_ALL_FMT       = "Tutti: %s (%d)",
        RARITY_SPIRIT           = "Bestia Spirito",
        RARITY_SECRET           = "Segreto / Evocazione",
        RARITY_BOSS             = "Boss Incursione / Spedizione",
        RARITY_RARE             = "Raro",
        RARITY_COMMON           = "Comune",
        PAGE_FMT                = "Pag. %d/%d",
        DOCK_TITLE_BEAST        = " |cffffd100Dossier Bestia|r",
        DOCK_TITLE_TOME         = " |cffffd100Dossier Tomo|r",
        BTN_NAV_BEAST           = " Traccia Percorso per la Bestia (TomTom + Mappa)",
        BTN_NAV_TOME            = " Traccia Percorso per il Tomo (TomTom + Mappa)",
        BTN_SHOW_MAP            = "Sulla Mappa",
        BTN_MARK_COLLECTED      = " Segna Ottenuto",
        BTN_UNMARK              = "Rimuovi",
        UNIT_TT_MISSING_MODEL   = "   %s |cffffaa00Non hai ancora questo aspetto nella tua scuderia!|r",
        UNIT_TT_QUEST_ONLY_WARN = "   |cffff5500! ESCLUSIVA MISSIONE: Addomestica PRIMA di consegnare la missione!|r",
        ALERT_QUEST_HEADER      = "ATTENZIONE: BESTIA ESCLUSIVA DI MISSIONE VICINA!",
        ALERT_QUEST_SUB         = "Addomesticala PRIMA di consegnare la missione — non ottenibile dopo!",
    },

    koKR = {
        TITLE_ALL_FAMILIES      = "사냥꾼 야수 — 전체 61종 야수 가족",
        TITLE_TOMES_TAB         = "사냥꾼 야수 — 길들이기 고서 및 비전서 (11)",
        TITLE_SPEC_PREFIX       = "사냥꾼 야수 — 전문화: ",
        TITLE_PREFIX            = "사냥꾼 야수 — ",
        TAB_ALL_MODELS          = "모든 모델",
        TAB_UNCOLLECTED         = "미수집",
        TAB_TOMES_FMT           = " 고서 (%d)",
        PROGRESS_TOMES_FMT      = "고서: %d / %d",
        SEARCH_PLACEHOLDER      = "야수 / 지역 / 고서 검색...",
        LANG_BTN_LABEL          = "RU",
        LANG_BTN_TOOLTIP_TITLE  = "인터페이스 언어: 한국어 (KO)",
        LANG_BTN_TOOLTIP_DESC   = "클릭하여 언어 전환 (RU / EN) 또는 /bc lang auto 입력!",
        CHAT_LANG_SWITCHED      = "|cff00ff96[BeastCollector]|r 인터페이스 언어가 |cffffd100한국어 (KO)|r로 변경되었습니다.",
        FILTER_TRAITS_DEFAULT   = "특성 및 능력 [v]",
        SPEC_MENU_ALL_FMT       = "전체: %s (%d)",
        RARITY_SPIRIT           = "야수 정령",
        RARITY_SECRET           = "비밀 / 소환",
        RARITY_BOSS             = "공격대 / 던전 우두머리",
        RARITY_RARE             = "희귀 몬스터",
        RARITY_COMMON           = "일반",
        PAGE_FMT                = "페이지 %d/%d",
        DOCK_TITLE_BEAST        = " |cffffd100야수 상세 정보|r",
        DOCK_TITLE_TOME         = " |cffffd100고서 상세 정보|r",
        DOCK_ROTATE_HINT        = "좌클릭: 회전 • 휠: 확대/축소",
        DOCK_STATUS_LEARNED     = " |cff00ff96습득함!|r",
        DOCK_STATUS_UNLEARNED   = " |cffff8800미습득|r",
        DOCK_STATUS_UNTAMED     = " |cffff8800길들이지 않음|r",
        DOCK_SCOPE_ACCOUNT      = "|cff00ccff계정 공유|r",
        DOCK_SCOPE_CHAR         = "|cffffaa00캐릭터별|r",
        BTN_NAV_BEAST           = " 야수 위치 경로 안내 (TomTom + 지도)",
        BTN_NAV_TOME            = " 고서 위치 경로 안내 (TomTom + 지도)",
        BTN_SHOW_MAP            = "지도 보기",
        BTN_MARK_COLLECTED      = " 수집 완료 표시",
        BTN_UNMARK              = "표시 해제",
        BTN_MARK_LEARNED        = " 습득 완료 표시",
        BTN_BEASTS_COUNT_FMT    = "야수 (%d)",
        COL_MANUAL              = "수집품에 표시됨",
        COL_STABLED_FMT         = "우리 보관 중: %s",
        ACTIVE_PET_FALLBACK     = "소환된 야수",
        UNKNOWN_ZONE            = "알 수 없음",
        MINIMAP_TT_SUBTITLE     = "3D 사냥꾼 야수 옷장 및 고서 추적기",
        MINIMAP_TT_COLLECTED    = "수집한 외형: |cff00ff96%d / %d|r",
        UNIT_TT_MISSING_MODEL   = "   %s |cffffaa00아직 우리에 수집하지 않은 야수 외형입니다!|r",
        UNIT_TT_QUEST_ONLY_WARN = "   |cffff5500! 퀘스트 한정 야수: 퀘스트 완료 전에 반드시 길들이세요!|r",
        ALERT_QUEST_HEADER      = "경고: 주변에 퀘스트 한정 야수 발견!",
        ALERT_QUEST_SUB         = "퀘스트 완료 전에 길들이세요 — 완료 후에는 다시 얻을 수 없습니다!",
        ALERT_TT_TITLE          = "|cffff6600BeastCollector — 퀘스트 위상 한정 야수|r",
        ALERT_TT_DESC           = "이 야수는 퀘스트 진행 중에만 등장하며 아직 수집하지 않았습니다!",
        ALERT_TT_CLICK_HINT     = "|cff00ff96좌클릭:|r 야수 정보 열기   |cffaaaaaa우클릭:|r 닫기",
        CHAT_QUEST_ALERT_FMT    = "|cffff6600[BeastCollector — 퀘스트 한정!]|r 주변에 |cffffd100%s|r (%s) 발견 — 미수집 외형입니다! 퀘스트 완료 전에 길들이세요!",
    },

    zhCN = {
        TITLE_ALL_FAMILIES      = "猎人宠物 — 全部 61 个家族",
        TITLE_TOMES_TAB         = "猎人宠物 — 驯服典籍与手册 (11)",
        TITLE_SPEC_PREFIX       = "猎人宠物 — 专精：",
        TITLE_PREFIX            = "猎人宠物 — ",
        TAB_ALL_MODELS          = "全部模型",
        TAB_UNCOLLECTED         = "未收集",
        TAB_TOMES_FMT           = " 典籍 (%d)",
        PROGRESS_TOMES_FMT      = "典籍：%d / %d",
        SEARCH_PLACEHOLDER      = "搜索野兽 / 区域 / 典籍...",
        LANG_BTN_LABEL          = "RU",
        LANG_BTN_TOOLTIP_TITLE  = "界面语言：简体中文 (ZH)",
        LANG_BTN_TOOLTIP_DESC   = "点击切换语言 (RU / EN) 或输入 /bc lang auto！",
        CHAT_LANG_SWITCHED      = "|cff00ff96[BeastCollector]|r 界面语言已切换为：|cffffd100简体中文 (ZH)|r。",
        FILTER_TRAITS_DEFAULT   = "特质与技能 [v]",
        SPEC_MENU_ALL_FMT       = "全部：%s (%d)",
        TAG_EXOTIC_PAREN        = "(奇珍)",
        TAG_TOME_PAREN          = "(典籍)",
        TAG_EXOTIC_FULL         = " |cff00ccff(奇珍异兽 — 仅限野兽控制)|r",
        TAG_ALL_SPECS_FULL      = " |cff88ff88(全部 3 专精)|r",
        RARITY_SPIRIT           = "灵魂兽",
        RARITY_SECRET           = "隐藏 / 召唤",
        RARITY_BOSS             = "团队 / 地下城首领",
        RARITY_RARE             = "稀有精英",
        RARITY_COMMON           = "普通",
        PAGE_FMT                = "第 %d/%d 页",
        DOCK_TITLE_BEAST        = " |cffffd100宠物档案|r",
        DOCK_TITLE_TOME         = " |cffffd100典籍档案|r",
        DOCK_ROTATE_HINT        = "左键：旋转 • 滚轮：缩放",
        DOCK_STATUS_LEARNED     = " |cff00ff96已学会！|r",
        DOCK_STATUS_UNLEARNED   = " |cffff8800尚未学会|r",
        DOCK_STATUS_UNTAMED     = " |cffff8800尚未驯服|r",
        DOCK_SCOPE_ACCOUNT      = "|cff00ccff战团账号通用|r",
        DOCK_SCOPE_CHAR         = "|cffffaa00角色专属|r",
        BTN_NAV_BEAST           = " 规划前往野兽路线 (TomTom + 地图)",
        BTN_NAV_TOME            = " 规划前往典籍路线 (TomTom + 地图)",
        BTN_SHOW_MAP            = "在地图上",
        BTN_MARK_COLLECTED      = " 标记已收集",
        BTN_UNMARK              = "取消标记",
        BTN_MARK_LEARNED        = " 标记已学会",
        BTN_BEASTS_COUNT_FMT    = "野兽 (%d)",
        COL_MANUAL              = "已标记在收藏中",
        COL_STABLED_FMT         = "兽栏中：%s",
        ACTIVE_PET_FALLBACK     = "当前召唤宠物",
        UNKNOWN_ZONE            = "未知",
        MINIMAP_TT_SUBTITLE     = "3D 猎人宠物外观衣柜与典籍追踪",
        MINIMAP_TT_COLLECTED    = "已收集外观：|cff00ff96%d / %d|r",
        UNIT_TT_MISSING_MODEL   = "   %s |cffffaa00你的兽栏中还没有收集此模型外观！|r",
        UNIT_TT_QUEST_ONLY_WARN = "   |cffff5500! 任务限定：请在交任务前驯服（交任务后位面消失）！|r",
        ALERT_QUEST_HEADER      = "警告：附近发现任务限定绝版野兽！",
        ALERT_QUEST_SUB         = "请在交任务前驯服 — 完成任务后将无法再次获得！",
        ALERT_TT_TITLE          = "|cffff6600BeastCollector — 任务阶段限定野兽|r",
        ALERT_TT_DESC           = "该野兽仅存在于任务镜像或场景战役中，且你尚未收集此外观！",
        ALERT_TT_CLICK_HINT     = "|cff00ff96左键：|r打开野兽档案   |cffaaaaaa右键：|r关闭横幅",
        CHAT_QUEST_ALERT_FMT    = "|cffff6600[BeastCollector — 任务限定！]|r 附近发现 |cffffd100%s|r (%s) — 你的兽栏尚未收集此外观！请在交任务前驯服！",
    },

    zhTW = {
        TITLE_ALL_FAMILIES      = "獵人寵物 — 全部 61 個家族",
        TITLE_TOMES_TAB         = "獵人寵物 — 馴服典籍與手冊 (11)",
        TITLE_SPEC_PREFIX       = "獵人寵物 — 專精：",
        TITLE_PREFIX            = "獵人寵物 — ",
        TAB_ALL_MODELS          = "全部模型",
        TAB_UNCOLLECTED         = "未收集",
        TAB_TOMES_FMT           = " 典籍 (%d)",
        PROGRESS_TOMES_FMT      = "典籍：%d / %d",
        SEARCH_PLACEHOLDER      = "搜尋野獸 / 區域 / 典籍...",
        LANG_BTN_LABEL          = "RU",
        LANG_BTN_TOOLTIP_TITLE  = "介面語言：繁體中文 (TW)",
        LANG_BTN_TOOLTIP_DESC   = "點擊切換語言 (RU / EN) 或輸入 /bc lang auto！",
        CHAT_LANG_SWITCHED      = "|cff00ff96[BeastCollector]|r 介面語言已切換為：|cffffd100繁體中文 (TW)|r。",
        FILTER_TRAITS_DEFAULT   = "特質與技能 [v]",
        SPEC_MENU_ALL_FMT       = "全部：%s (%d)",
        TAG_EXOTIC_PAREN        = "(奇珍)",
        TAG_TOME_PAREN          = "(典籍)",
        TAG_EXOTIC_FULL         = " |cff00ccff(奇珍異獸 — 僅限野獸控制)|r",
        TAG_ALL_SPECS_FULL      = " |cff88ff88(全部 3 專精)|r",
        RARITY_SPIRIT           = "靈魂獸",
        RARITY_SECRET           = "隱藏 / 召喚",
        RARITY_BOSS             = "團隊 / 地城首領",
        RARITY_RARE             = "稀有精英",
        RARITY_COMMON           = "普通",
        PAGE_FMT                = "第 %d/%d 頁",
        DOCK_TITLE_BEAST        = " |cffffd100寵物檔案|r",
        DOCK_TITLE_TOME         = " |cffffd100典籍檔案|r",
        DOCK_ROTATE_HINT        = "左鍵：旋轉 • 滾輪：縮放",
        DOCK_STATUS_LEARNED     = " |cff00ff96已學會！|r",
        DOCK_STATUS_UNLEARNED   = " |cffff8800尚未學會|r",
        DOCK_STATUS_UNTAMED     = " |cffff8800尚未馴服|r",
        DOCK_SCOPE_ACCOUNT      = "|cff00ccff戰團帳號通用|r",
        DOCK_SCOPE_CHAR         = "|cffffaa00角色專屬|r",
        BTN_NAV_BEAST           = " 規劃前往野獸路線 (TomTom + 地圖)",
        BTN_NAV_TOME            = " 規劃前往典籍路線 (TomTom + 地圖)",
        BTN_SHOW_MAP            = "在地圖上",
        BTN_MARK_COLLECTED      = " 標記已收集",
        BTN_UNMARK              = "取消標記",
        BTN_MARK_LEARNED        = " 標記已學會",
        BTN_BEASTS_COUNT_FMT    = "野獸 (%d)",
        COL_MANUAL              = "已標記在收藏中",
        COL_STABLED_FMT         = "獸欄中：%s",
        ACTIVE_PET_FALLBACK     = "當前召喚寵物",
        UNKNOWN_ZONE            = "未知",
        MINIMAP_TT_SUBTITLE     = "3D 獵人寵物外觀衣櫃與典籍追蹤",
        MINIMAP_TT_COLLECTED    = "已收集外觀：|cff00ff96%d / %d|r",
        UNIT_TT_MISSING_MODEL   = "   %s |cffffaa00你的獸欄中還沒有收集此模型外觀！|r",
        UNIT_TT_QUEST_ONLY_WARN = "   |cffff5500! 任務限定：請在交任務前馴服（交任務後鏡像消失）！|r",
        ALERT_QUEST_HEADER      = "警告：附近發現任務限定絕版野獸！",
        ALERT_QUEST_SUB         = "請在交任務前馴服 — 完成任務後將無法再次獲得！",
        ALERT_TT_TITLE          = "|cffff6600BeastCollector — 任務階段限定野獸|r",
        ALERT_TT_DESC           = "該野獸僅存在於任務鏡像或場景戰役中，且你尚未收集此外觀！",
        ALERT_TT_CLICK_HINT     = "|cff00ff96左鍵：|r打開野獸檔案   |cffaaaaaa右鍵：|r關閉橫幅",
        CHAT_QUEST_ALERT_FMT    = "|cffff6600[BeastCollector — 任務限定！]|r 附近發現 |cffffd100%s|r (%s) — 你的獸欄尚未收集此外觀！請在交任務前馴服！",
    },
}

Locales.esMX = Locales.esES
Locales.enGB = Locales.enUS

local SPEC_LOCALE_NAMES = {
    deDE = { FEROCITY = "Wildheit",   CUNNING = "Gerissenheit", TENACITY = "Hartnäckigkeit" },
    frFR = { FEROCITY = "Férocité",   CUNNING = "Ruse",         TENACITY = "Ténacité" },
    esES = { FEROCITY = "Ferocidad",  CUNNING = "Astucia",      TENACITY = "Tenacidad" },
    esMX = { FEROCITY = "Ferocidad",  CUNNING = "Astucia",      TENACITY = "Tenacidad" },
    ptBR = { FEROCITY = "Ferocidade", CUNNING = "Astúcia",      TENACITY = "Tenacidade" },
    itIT = { FEROCITY = "Ferocia",    CUNNING = "Scaltrezza",   TENACITY = "Tenacia" },
    koKR = { FEROCITY = "야수성",      CUNNING = "교활",         TENACITY = "끈기" },
    zhCN = { FEROCITY = "狂野",       CUNNING = "狡诈",         TENACITY = "坚韧" },
    zhTW = { FEROCITY = "狂野",       CUNNING = "狡詐",         TENACITY = "堅韌" },
}

addon.Locales = Locales

function addon:GetActiveLocale()
    local pref = self.db and self.db.settings and self.db.settings.language
    if pref and pref ~= "AUTO" and Locales[pref] then
        return (pref == "enGB") and "enUS" or pref
    end
    local clientLoc = (_G.GetLocale and _G.GetLocale()) or "enUS"
    if clientLoc == "enGB" then
        return "enUS"
    end
    if Locales[clientLoc] then
        return clientLoc
    end
    return "enUS"
end

function addon:IsRussian()
    return self:GetActiveLocale() == "ruRU"
end

function addon:IsEnglish()
    return self:GetActiveLocale() ~= "ruRU"
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
    if self:GetActiveLocale() == "enUS" then
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
local function GetClientMapName(mapID)
    if not mapID or not _G.C_Map or not _G.C_Map.GetMapInfo then return nil end
    local ok, info = pcall(_G.C_Map.GetMapInfo, mapID)
    if ok and info and type(info.name) == "string" and info.name ~= "" then
        return info.name
    end
    return nil
end

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
    local loc = self:GetActiveLocale()
    if loc ~= "ruRU" and loc ~= "enUS" and beast.mapID then
        local nativeZone = GetClientMapName(beast.mapID)
        if nativeZone then return nativeZone end
    end
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
    local loc = self:GetActiveLocale()
    if SPEC_LOCALE_NAMES[loc] and spec.id and SPEC_LOCALE_NAMES[loc][spec.id] then
        return SPEC_LOCALE_NAMES[loc][spec.id]
    end
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
    local loc = self:GetActiveLocale()
    if loc ~= "ruRU" and loc ~= "enUS" and tome.mapID then
        local nativeZone = GetClientMapName(tome.mapID)
        if nativeZone then return nativeZone end
    end
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
