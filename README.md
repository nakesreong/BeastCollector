# BeastCollector — 3D Hunter Pet Wardrobe, 61-Family Encyclopedia, Taming Tomes & Multi-Hop Navigator

**Version:** 1.1.0  
**Authors:** Gemini (Tiger) & Anya (5cr3am1ng5oul)  
**Compatibility:** World of Warcraft: Retail / Midnight (`12.1.7`, `12.1.5`, `12.0.1`) & The War Within (`11.2.7`)  
**Source Repository:** [https://github.com/nakesreong/BeastCollector](https://github.com/nakesreong/BeastCollector)  
**License:** Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

***

## Overview

**BeastCollector** is a complete 3D Hunter Pet Model Wardrobe, 61-Family Encyclopedia, Taming Tome Progression Tracker, and Multi-Hop Portal Route Navigator for World of Warcraft (*Midnight* `12.0+`). Modeled after Blizzard's Appearances Wardrobe (`WardrobeCollectionFrame`) with a sleek dark-gold UI, it gives Hunters a live 3D gallery of all **2,635 tameable beast looks** across all **61 pet families**, automatic stable & active-pet synchronization, open-world taming diagnostics, and an exclusive **Quest-Phase Beast Alert Radar**.

*   **3D Hunter Pet Model Wardrobe (`6x3` Grid + Interactive 3D Side Dossier):** Browse all **2,635 unique tameable beast looks** across **61 Hunter Pet families** (`HunterPetsDB-1.0`) with live 3D creature rendering (`PlayerModel`), zoom/rotate controls, and instant search by beast name, zone, family, combat trait, or taming tome.
*   **Complete 11 Taming Tomes & Manuals Tracker (`Tomes (11)` Tab):** Tracks all **11 special Taming Tomes & Manuals** (*Trials of the Florafaun Hunter*, *Simple Tome of Bone-Binding*, *Ancient Tome of Dinomancy*, *Tome of the Hybrid Beast*, *Blood-Soaked Tome of Dark Whispers*, *How to School Your Serpent*, *Mecha-Bond Imprint Matrix*, *Gargon Training Manual*, *How to Train a Dragonkin*, *Ottuk Taming*, and *Cinder of Companionship*) using server-verified quest/achievement flags (`C_QuestLog.IsQuestFlaggedCompleted`), innate racial passives, drop chances, expected kill counts, and a live **Attempt Counter & Cumulative Luck Engine** (`1 - (1 - p)^K`).
*   **Quest-Phase Exclusive Beast Alert Radar & Open-World Unit Tooltips:** Automatically warns you with a movable **Quest-Exclusive Popup Alert Banner** (`BeastCollectorAlertFrame` + sound alert) and unit tooltip warning whenever you encounter an uncollected **Quest-Phase Exclusive beast** (such as the 4 spectral-orange *Paint-Crazed* beasts in Harandar, *Shadow of Dambala*, *Iron War Rylak*, *Death Skitterer*, etc.) that can **only** be tamed before turning in a quest!
*   **Open-World Unit Tooltip Diagnostics (Patch 12.0 Secret-Value Safe):** Hovering over any tameable beast in the world displays its family, specialization (`Ferocity`, `Cunning`, `Tenacity`), active/passive combat abilities, whether its look is already in your stables, and exact reasons why a beast cannot be tamed right now (missing *Beast Mastery* spec for Exotic families, creature level higher than player level, or unlearned Taming Tome).
*   **Multi-Hop Portal & Zone-Exit Route Navigator:** Clicking **Plot Route to Beast / Tome** builds an automatic step-by-step portal chain from isolated zones (*Harandar / The Den*, *Silvermoon City*, *Voidstorm*, *Emerald Dream*, *Dornogal*, *Valdrakken*, *Oribos*, *Boralus / Dazar'alor*, *Stormwind / Orgrimmar*) to your target's exact spawn coordinates using Blizzard's native 3D SuperTrack diamond pin (`C_Map.SetUserWaypoint` + `C_SuperTrack`) and **TomTom**.
*   **Live Stable Sync & Abandon Reconciliation:** Automatically scans your active pet and all **205 Hunter Stable slots** (`C_StableInfo.GetStablePetInfo`), updating your collected looks immediately—even when you release a pet into the wild (`PetAbandon`).
*   **Multi-Language Support (All 11 WoW Client Locales) + Instant Hot-Swap:** Automatically detects your WoW client language (`GetLocale()` — supporting `enUS`, `deDE`, `frFR`, `esES`, `esMX`, `ptBR`, `itIT`, `ruRU`, `koKR`, `zhCN`, `zhTW`) with native localized zone names (`C_Map.GetMapInfo`), plus a quick `[RU]` / `[EN]` toggle button right in the window header (and `/bc lang [auto|en|ru|de|fr|es|pt|it|ko|zh|tw]`) to switch languages on the fly without `/reload`.

***

## Core Features & Interface Tabs

### 1. 3D Pet Wardrobe & 61-Family Encyclopedia (`/bc`)

1.  **All Models & Uncollected Tabs:** View all 2,635 tameable looks or filter down to looks missing from your Hunter Stables.
2.  **Specialization Bar (`Ferocity`, `Cunning`, `Tenacity`) & Family Dropdowns:** Filter by pet specialization or pick any of the **61 families** from categorized dropdown menus with full ability tooltips.
3.  **Combat Traits & Abilities Filter (`Traits & Abilities [v]`):** One-click filtering by combat utility:
    *   *Bloodlust / Heroism (+10% Leech)*
    *   *Survival of the Fittest (-20% DR & +5% HP)*
    *   *Master's Call & +8% Move Speed*
    *   *Dispel Magic & Enrage*
    *   *Mortal Wounds (-50% Healing)*
    *   *Tank Shield (-50% Pet Damage Taken)*
    *   *Slow Target (-50% Move Speed)*
    *   *Pet Dodge +30% / Prowl*
    *   *Spirit Mend (Spirit Beast Heal)*
    *   *Exotic Families (BM Only)*
    *   *Requires Taming Tome / Item*
    *   *Rare Spawns / Spirit Beasts / Secrets*
    *   *Quest-Phase Exclusives (Tame before turn-in!)*
4.  **Interactive Side Dossier (`Beast Dossier` / `Tome Dossier`):** Displays a large rotatable/zoomable 3D preview, collection status, rarity badge (*Spirit Beast*, *Secret*, *Boss*, *Rare Spawn*, *Common*), family skills, required tome status, spawn coordinates, list of all tameable NPCs sharing that look, and detailed taming mechanics.

### 2. Taming Tomes & Manuals (`Tomes (11)` Tab)

*   Displays all **11 Taming Tomes** with live 3D previews of their signature beasts.
*   Clearly badges **Account-Wide (`Acct`)** vs **Character-Specific (`Char`)** unlock scope and how many models each tome unlocks (`Beasts (N)` button filters the wardrobe directly to that tome's beasts).
*   Tracks your personal kill attempts and cumulative drop luck (`1 - (1 - p)^K`) on drop-based tomes (*Ancient Tome of Dinomancy* from Zandalari Dinomancers, *Simple Tome of Bone-Binding* in Maldraxxus, *Blood-Soaked Tome of Dark Whispers* from Zul in Uldir, *Gargon Training Manual* from Huntmaster Petrus, and *Trials of the Florafaun Hunter* in Harandar).

***

## Slash Commands & Controls

*   `/bc` or `/beastcollector` — Toggle the main **BeastCollector** window.
*   `/bc lang [auto|en|ru|de|fr|es|pt|it|ko|zh|tw]` — Instantly switch interface language without reloading UI.
*   `/bc scan` — Force a manual scan of your Hunter Stables and active pet.
*   `/bc testalert` — Preview the **Quest-Exclusive Beast Alert Banner** at the top of the screen.
*   `/bc minimap` or `/bc mm` — Show or hide the round minimap button.
*   **Left-Click (Minimap Button):** Open or close **BeastCollector**.
*   **Right-Click (Minimap Button):** Open **BeastCollector** filtered to **Uncollected** models.
*   **Shift + Right-Click (Minimap Button):** Cycle between 5 Hunter minimap button icons (*Tame Beast*, *Spirit Beast*, *Call Pet*, *Beast Mastery*, *Track Beasts*).
