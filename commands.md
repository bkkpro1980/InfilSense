# Commands Info
## ESP Functions
- **Stuff ESP**: Highlights mission-critical objects like safes, computers, loot containers, and interactable items with markers.
- **Cleaner ESP**: Shows you where the NPCs are with a corresponding highlight color depending on the NPCs type, but might slightly impact performance on low-end devices.
- **Player ESP**: Shows you where all players are with a yellow highlight, but might slightly impact performance on low-end devices.

---

## Telekinesis Functions
- **Old Telekinesis**: Drag and manipulate NPCs/objects using mouse input. Works with physics-based interactions. This function is deprecated in favor of 'Telekinesis'
    - Removed from the latest release.
- **Better Locking**: Improves target retention for "Old Telekinesis" by reducing accidental drops during movement. This function is deprecated in favor of 'Telekinesis'
    - Removed from the latest release. 
- **Bye Bye**: Instantly teleports grabbed NPCs downward (100 studs) to remove them from play temporarily. This function is deprecated in favor of 'Telekinesis'
    - Removed from the latest release.
- **Telekinesis**: Move unanchored objects freely with your mouse. Will not work while holding a weapon.
- **Telekinesis Fling**: Applies a huge amount of force to grabbed targets, launching them at high velocity.

---

## Loadouts Functions
- **Infinite Ammo**: Makes your ammo reserves infinite until you disable this function (excludes Thumper).
- **Minigun**: Shoots really quickly (default: 30 RPM). Accepts numerical inputs for custom firerates.
    - Arguments for 'Quick Command': [1] = Firerate
- **Rainbow Guns**: Client-side cosmetic effect that cycles weapon through RGB color patterns.
- **Clear Loadout**: Erases everything from your current loadout slot.
- **Add Gear**: Injects custom equipment into loadouts. Supports non-standard items Items marked with * will cause your loadout page to break until you clear it. Might probably break the objectives too.
- **Set Primary**: Forces primary weapon selection override to bypass loadout UI glitches.
- **Weapon mods**: Makes all weapons reload instantly, no recoil, no spread, penetrate almost anything, changes magazine sizes, and firerate. (Does not change firerate and magazine sizes for SMGs (S97, MM20)) Best results with 'Infinite Ammo' active.
    - Executors that does not support 'getgc' and 'getraw' will not work

---

## Fun Functions
- **Kill Rose/Rivera**: Sets their health to 0. Simple.
- **NPC Interact**: Toggles NPC animations between standing/crawling states. Does not disable pathfinding.
- **NPC Follow**: Overrides AI pathfinding to force all NPCs to track and follow your position.
- **Loop Walkspeed**: Sustains customized movement speed (default: 50).
    - Arguments for 'Quick Command': [1] = Desired Walkspeed
- **Infinite Jump**: Makes you be able to jump midair.

---

## NPC / Bring Functions
- **Bring Armed**: Teleports weapon-equipped NPCs to your position. Prioritizes hostile targets.
- **Bring Unarmed**: Retrieves non-combatant NPCs. Ignores armed/hostile entities.
- **Bring Type**: Attempts to bring all NPCs with certain types to you. Defaults to 'All'.
    - Arguments for 'Quick Command': [1] = NPC type, [2] = forced (true/false)
- **Force Bring All**: Continuous version of "Bring All" with configurable refresh rates. This function is deprecated in favor of 'Bring Type'
    - Removed from the latest release.
- **Force Bring All Except Important People**: Looped exclusion-based retrieval for non-VIP NPCs. This function is deprecated in favor of 'Bring Type'
    - Removed from the latest release.
- **Bring Bags**: Teleports loose loot bags to your feet. Works with mission-specific containers.
- **Loop Bring Bags**: Automated version of "Bring Bags" with intervals.
- **Hide NPCs**: Teleports the NPCs to somewhere hidden. Defaults to 'All'.
    - Arguments for 'Quick Command': [1] = NPC type, [2] = loop (true/false)
- **Void NPCs**: Teleports the NPCs into the void. Defaults to 'All'.
    - Arguments for 'Quick Command': [1] = NPC type, [2] = loop (true/false)
- **Stop Forced NPCs**: Stops any forced/looped NPC positions. Used after looping/forcing 'Bring Type', 'Hide NPCs', 'Void NPCs'.
- **Disable Cameras**: Kills the camera operator(s). (If there are any.) Use before Hiding NPCs.

---

## Other Functions
- **No Fog**: Disables environmental fog effects.
- **No Flashbang**: Nullifies flashbang visual distortions.
- **Unlock Doors**: Attempts to unlock every door in the mission. Some may not work. Others will not see unlock doors until you open the door.
- **Fast Bagging**: Accelerates bag interaction in specific heists. Use when the bag can be interacted with.
- **Break Metal Detectors**: Destroys metal detectors via part deletion.
- **Alt + Click Delete**: Environment editor for deleting parts (Right-ALT + Left Click). No undo functionality.
- **Set FOV**: Adjusts camera field-of-view. Toggleable with default restoration.
    - Arguments for 'Quick Command': [1] = FOV
- **Show Waypoints**: Shows default NPC waypoints. No other explanations here.
- **Less Class Restrictions**: Better when used in the menu. Weakens role-based limitations and amplifies perk effectiveness.
- **GodMode Yourself**: Makes yourself invulnerable when you're  (If you're playing singleplayer, then use 'Godmode All' instead.)
- **Godmode All**: Invulnerability (Better with 2+ people alive.) Toggles with Elite+ difficulty requirements. Use 'Stop Godmode' and use a medkit to return back to normal health.
- **Stop Godmode**: Terminates active godmode connections. Use a medkit to return back to normal health.

---

## Autofarm Commands
- **Legacy Scientist Autofarm**: Automatically completes the Scientist mission for you. Extremely useful for farming rewards or XP with no effort. it should ready automatically, if it doesn't automatically ready, you have to manually press ready. This is the old version, use this instead of 'Scientist Autofarm' incase it doesn't work.
- **Scientist Autofarm**: Automatically completes the Scientist mission for you. Extremely useful for farming rewards or XP with no effort. it should ready automatically, if it doesn't automatically ready, you have to manually press ready. This is the latest version which should be used instead of 'Legacy Scientist Autofarm'.

---

## Settings
- **Quick Command**: Allows you to quickly use commands by typing the id. Supports some arguments for commands. Set to 'true' and set a keybind to use. Scroll down to find the IDs.
- **Don't copy Discord link on start**: Sets if the script should copy the Discord invite link to your clipboard when the script runs.
- **Don't auto load on each join**: Sets if the script auto load in missions, so you don't have to execute the script each time.
- **More Command Info**: Copies a link to this page.

---

# Other Info
## NPC types:
- g = "guard" (Guards, etc.)
- w = "worker" (Employees, etc.)
- v = "vip" (Manager, etc.)
- ch = "chill" (Rose, etc.)
- c = "civilian" (Civilian)
- e = "enemy" (Swat, etc.)
- m = "mixed" (Police, Halcyon Operative)
- a = "all" (All of the above)

---

## Commands ID for 'Quick Commands' function
- Stuff Esp: 1, stuffesp
- Cleaner ESP: 2, cleanesp
- Player ESP: 3, playeresp
- Telekinesis: 4, telekinesis, tele, tk
- Telekinesis Fling: 5, telekinesisfling, telefling, tkfling, tkf
- Infinite Ammo: 6, infammo, ia
- Minigun: 7, minigun
- Rainbow Guns: 8, rainbowguns, rgbguns
- Clear current loadout: 9, clearloadout, cloadout
- Add gear to loadout*: 10, addgear
- Set primary: 11, setweapon
- Weapon mods*: 12, weaponmods, wepmods, wpmods
- Kill Rose/Rivera: 13, killr
- NPC Interact: 14, npcinteract
- NPC Follow: 15, npcfollow
- Loop Walkspeed: 16, loopwalkspeed, loopws
- Infinite Jump: 17, infinitejump, infjump, float
- Bring Armed: 18, bringarmed
- Bring Unarmed: 19, bringunarmed
- Bring Type*: 20, bringtype, bring, bt
- Bring Bags: 21, bringbags
- Loop Bring Bags: 22, loopbringbags, loopbb
- Hide NPCs*: 23, hidenpcs, hidenpc, hide
- Void NPCs*: 24, voidnpcs, voidnpc, void
- Stop Forced NPCs: 25, stopforced, noforced, clearforced, unfreeze
- Disable Cams: 26, disablecams, killcams, byecams, nocams
- No Fog: 27
- No Flashbang: 28, noflashbang, noflash
- Unlock Doors: 29, unlockdoors
- Fast Bagging: 30, fastbag
- Break Metal Detectors: 31, breakmetaldetectors, breakmetal, breakmd
- Alt + Click Delete: 32, altdelete, altdel
- FT difficulty: 33, settpmdiff
- Force teleport: 34, teleportmission, tpmission
- Look Away: 35, lookaway
- Set FOV: 36, setfov
- Show Waypoints: 37, showwaypoints, showwp
- Less Class Restrictions: 38, lessclassres, lcr
- Godmode all*: 39, godmodeall, godall
- Godmode yourself*: 40, godmodeme, godme
- Stop Godmode Functions: 41, stopgod
- Legacy Scientist Autofarm*: 42, legacysciauto, lsciauto
- Scientist Autofarm*: 43, sciauto
