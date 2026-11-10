# BeastCollector — Database Architecture & Update Pipeline (`HunterPetsDB-1.0`)

This document explains how `BeastCollector` builds and maintains its embedded database library (`Libs/HunterPetsDB-1.0/HunterPetsDB-1.0.lua`) and how to update it when a new World of Warcraft expansion or patch adds new tameable beasts or families.

---

## 1. Why a Hybrid Multi-Source Pipeline?

No single public WoW addon or database contains everything `BeastCollector` needs:
1. **3D Model Accuracy (`PlayerModel:SetCreature(npcID)`)**:
   - In Retail WoW, `PlayerModel:SetCreature(npcID)` renders the exact 3D creature model and texture variant assigned to that `npcID` in the client's `Creature` / `CreatureDisplayInfo` tables.
   - However, some multi-color NPCs can spawn with multiple `displayID`s. If you pick a multi-look `npcID`, two different color cards might render the same color in the 3D grid.
   - **Solution:** Our pipeline parses the complete **Petopia Tameable Looks Gallery** (`2,635` looks across `61` families), counts how many looks each `npcID` appears in across the entire game (`npc_look_count`), and always selects a **single-appearance `npcID`** (`npc_look_count[npc_id] == 1`) as the primary `beast.npcID` whenever one exists.
2. **Russian & English Localization (`ruRU` + `enUS`)**:
   - Petopia is English-only. To provide native Russian creature names, family names, and zone names while keeping English names searchable, we cross-reference **Wago.tools DB2 CSV exports** (`Creature`, `CreatureFamily`, `UiMap`) in both `ruRU` and `enUS`.
3. **Spawn Coordinates & `uiMapID`s for Waypoints**:
   - To make the **"Проложить путь к зверю (TomTom + Карта)"** button work out of the box for thousands of beasts, we cross-reference `GiuiceHunterPets` (`GHP_Data.lua`) for exact `[x, y]` spawn coordinates and zone names, and map all zone names to official Blizzard `uiMapID`s (`UiMap.db2`).
4. **Verified `displayID`s for Stable Matching**:
   - We cross-reference `CreatureDisplayDB` (`CreatureDisplayDB-1.0` by keyboardturner) to attach verified `displayID`s to `npcID`s without ever guessing or hallucinating model IDs.

---

## 2. Upstream Data Sources

When `python tools/build_database.py --fetch` is executed, it downloads and caches 9 upstream files into `tools/_cache/` (which is git-ignored):

| Cached File | Upstream Source | Purpose |
| :--- | :--- | :--- |
| `petopia_gallery.html` | `https://www.wow-petopia.com/browse/gallery.php` | Master list of all **61 families** and **2,635 tameable looks** (`look_id`, `skin_string`, `look_title`, family slug, and every tameable `npcID` + zone per look). |
| `CreatureFamily_ruRU.csv` | `https://wago.tools/db2/CreatureFamily/csv?locale=ruRU` | Official Blizzard Russian family names and `IconFileID`s for all 61 tameable families. |
| `CreatureFamily_enUS.csv` | `https://wago.tools/db2/CreatureFamily/csv?locale=enUS` | Official Blizzard English family names and `IconFileID`s. |
| `Creature_ruRU.csv` | `https://wago.tools/db2/Creature/csv?locale=ruRU` | Official Russian names (`Name_lang`) for over 245,000 NPCs by `npcID`. |
| `Creature_enUS.csv` | `https://wago.tools/db2/Creature/csv?locale=enUS` | Official English names (`Name_lang`) by `npcID`. |
| `UiMap_ruRU.csv` | `https://wago.tools/db2/UiMap/csv?locale=ruRU` | Official Russian zone/continent names mapped to `uiMapID`. |
| `UiMap_enUS.csv` | `https://wago.tools/db2/UiMap/csv?locale=enUS` | Official English zone/continent names mapped to `uiMapID`. |
| `CreatureDisplayDB_retail_db_general.lua` | `https://raw.githubusercontent.com/keyboardturner/CreatureDisplayDB/main/retail/db_general.lua` | Packed `(npcID, displayID)` pairs (`4 bytes` per entry: `uint24 npcID + uint24 displayID`) used to attach verified `displayID`s. |
| `GHP_Data.lua` | CurseForge API (`project 1221469` — *Giuice's Hunter Pets*) | Per-NPC tameable metadata: `[x, y]` spawn coordinates, min/max levels, exotic/tome flags, and zone names. |

---

## 3. How to Run the Pipeline

### Prerequisites
- Python 3.10+ (standard library only — uses `urllib.request`, `csv`, `re`, `json`, `zipfile`).

### Command Options

1. **Rebuild from local cache (`tools/_cache/`)** — Fast (~4 seconds), ideal when tweaking family combat descriptions, curated Russian taming guides (`CURATED_RU`), or zone overrides in `tools/build_database.py`:
   ```bash
   python tools/build_database.py
   ```

2. **Fetch fresh upstream data and rebuild** — Downloads fresh copies of all 9 files from Petopia, Wago.tools, GitHub, and CurseForge before rebuilding `Libs/HunterPetsDB-1.0/HunterPetsDB-1.0.lua`:
   ```bash
   python tools/build_database.py --fetch
   ```

---

## 4. Pipeline Step-by-Step Internals (`tools/build_database.py`)

### Step 1: Parse Official Blizzard `CreatureFamily` & `UiMap` Tables
- Reads `CreatureFamily_ruRU.csv` and `CreatureFamily_enUS.csv` to map every Blizzard `CreatureFamily.ID` to its localized Russian name, English name, and exact `IconFileID`.
- Reads `UiMap_enUS.csv` and `UiMap_ruRU.csv` (preferring Zone `Type=3` and Continent `Type=2` maps) plus `ZONE_MAP_OVERRIDES` to translate English Petopia zone names into `(uiMapID, ruZoneName)`.

### Step 2: Unpack `CreatureDisplayDB` Binary Stream
- Decodes the Lua string literals in `CreatureDisplayDB_retail_db_general.lua` and unpacks 6-byte records (`3-byte big-endian npcID` + `3-byte big-endian displayID`).
- Only attaches a `displayID` to a look when the primary `npcID` maps unambiguously to a single `displayID`.

### Step 3: Parse `GiuiceHunterPets` (`GHP_Data.lua`)
- Extracts NPC spawn coordinates (`coords = { x, y }`), level ranges, and zone strings keyed by `npcID`.

### Step 4: Parse Petopia Gallery (`petopia_gallery.html`)
- Extracts all `61` family definitions (`PETOPIA_FAMILY_META` maps each Petopia slug to its Blizzard `CreatureFamily.ID`, pet spec `FEROCITY` / `TENACITY` / `CUNNING`, exotic status, taming tome key, and Russian combat ability summary).
- Extracts all `2,635` look modals (`<div id="look_..." class="modal">`), collecting every tameable NPC (`npcID`, name, reaction badge `A`/`H`, level, rare/elite status, and zone) that uses that exact skin.
- **Primary `npcID` Selection Heuristic**:
  Specifically chooses an NPC with `npc_look_count[npc_id] == 1` (so its `SetCreature(npcID)` in WoW's `PlayerModel` widget is guaranteed to show that exact skin/color variant) while prioritizing NPCs that have known `[x, y]` spawn coordinates and Russian `Creature.db2` names.

### Step 5: Merge Curated Taming Guides (`CURATED_RU`)
- Overlays rich hand-written Russian guides (`obtain`, `respawn`, `coords`, `mapID`, `subTitle`) for iconic Hunter pets (Spirit Beasts like Loque'nahak, Arcturis, Gara, Hati, Fenryr, Gargon/Cloud Serpent/Undead tomes, etc.).

### Step 6: Emit `Libs/HunterPetsDB-1.0/HunterPetsDB-1.0.lua`
- Generates a standalone `LibStub` library (`HunterPetsDB-1.0`) exposing:
  - `db.Families` (`61` families)
  - `db.Beasts` (`2,635` looks)
  - `db.Meta` (generation date, look count, family count)

---

## 5. How to Add New Families or Curated Guides in Future Patches

### Adding a New Hunter Pet Family (e.g., in a new WoW expansion)
1. Run `python tools/build_database.py --fetch` to pull the new `petopia_gallery.html` and `CreatureFamily_*.csv`.
2. If Petopia added a new family slug, the script will print a `WARNING: Missing family meta for <slug>`.
3. Open [`tools/build_database.py`](tools/build_database.py) and add an entry to `PETOPIA_FAMILY_META`:
   ```python
   "newslug": (
       <Blizzard_CreatureFamily_ID>,
       "TENACITY", # or "FEROCITY" / "CUNNING"
       False,      # True if Exotic (BM-only)
       None,       # Tome key if required (e.g. "GARGON")
       "Название способности (Краткая роль)",
       "Краткое описание полезности семейства на русском языке."
   ),
   ```
4. Re-run `python tools/build_database.py` and copy the updated `Libs/HunterPetsDB-1.0/HunterPetsDB-1.0.lua` to the WoW AddOns folder.

### Adding or Updating a Detailed Russian Taming Guide
1. Open [`tools/build_database.py`](tools/build_database.py) and locate the `CURATED_RU` dictionary (keyed by `npcID`).
2. Add or edit the entry with `name`, `subTitle`, `obtain`, `respawn`, `mapID`, and `coords`:
   ```python
   32517: {
       "name": "Локе'нахак",
       "subTitle": "Спутница Хар'коа (Уникальный снежный барс)",
       "obtain": "7 точек спавна вокруг Низины Шолазар...",
       "respawn": "6–12 часов",
       "mapID": 119,
       "coords": (36.0, 30.0),
   },
   ```
3. Run `python tools/build_database.py` to regenerate `HunterPetsDB-1.0.lua`.
