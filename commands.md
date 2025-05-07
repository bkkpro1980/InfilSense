# ESP Functions  
- **Stuff ESP**: Highlights mission-critical objects like safes, computers, loot containers, and interactable items with markers.
- **Cleaner ESP**: A visually cleaner and more refined ESP. Offers better aesthetics, but might slightly impact performance on low-end devices.

---

# Telekinesis Functions  
- **Old Telekinesis**: Drag and manipulate NPCs/objects using mouse input. Works with physics-based interactions. This function is deprecated in favor of 'Telekinesis'
    - Removed from the latest release.
- **Better Locking**: Improves target retention for "Old Telekinesis" by reducing accidental drops during movement. This function is deprecated in favor of 'Telekinesis'
    - Removed from the latest release. 
- **Bye Bye**: Instantly teleports grabbed NPCs downward (100 studs) to remove them from play temporarily. This function is deprecated in favor of 'Telekinesis'
    - Removed from the latest release.
- **Telekinesis**: Move unanchored objects freely with your mouse. Will not work while holding a weapon.
- **Telekinesis Fling**: Applies explosive force to grabbed targets, launching them at high velocity.

---

# Loadouts Functions  
- **Infinite Ammo**: Makes your ammo reserves infinite until you disable this function (excludes Thumper).
- **Minigun**: Shoots really quickly (default: 30 RPM). Accepts numerical inputs for custom firerates.
    - Arguments for 'Quick Command': [1] = Firerate
- **Rainbow Guns**: Client-side cosmetic effect that cycles weapon through RGB color patterns.
- **Clear Loadout**: Erases everything from your current loadout slot.
- **Add Gear**: Injects custom equipment into loadouts. Supports non-standard items Items marked with * will cause your loadout page to break until you clear it.
- **Set Primary**: Forces primary weapon selection override to bypass loadout UI glitches.
- **Weapon mods**: Makes all weapons reload instantly, no recoil, no spread, penetrate almost anything, changes magazine sizes, and firerate. (Does not change firerate and magazine sizes for SMGs (S97, MM20)) Best results with 'Infinite Ammo' active.
    - Executors that does not support 'getgc' and 'getraw' will not work

---

# Fun Functions  
- **Kill Rose/Rivera**: Sets their health to 0. Simple.
- **NPC Interact**: Toggles NPC animations between standing/crawling states. Does not disable pathfinding.
- **NPC Follow**: Overrides AI pathfinding to force all NPCs to track and follow your position.
- **Loop Walkspeed**: Sustains customized movement speed (default: 50).
    - Arguments for 'Quick Command': [1] = Desired Walkspeed
- **Infinite Jump**: Makes you be able to jump midair.

---

# NPC / Bring Functions  
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

# Other Functions  
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

# Autofarm Commands  
- **Scientist Autofarm**: Automatically completes the Scientist mission for you. Extremely useful for farming rewards or XP with no effort. it should ready automatically, if it doesn't automatically ready, you have to manually press ready.

---

# Settings  
- **Quick Command**: Allows you to quickly use commands by typing the id. Supports some arguments for commands. Set to 'true' and set a keybind to use. Scroll down to find the IDs.
- **Don't copy Discord link on start**: Sets if the script should copy the Discord invite link to your clipboard when the script runs.
- **Don't auto load on each join**: Sets if the script auto load in missions, so you don't have to execute the script each time.
- **More Command Info**: Copies a link to this page.

---

# Info
**NPC types**:
- g = "guard" (Guards, etc.)
- w = "worker" (Employees, etc.)
- v = "vip" (Manager, etc.)
- ch = "chill" (Rose, etc.)
- c = "civilian" (Civilian)
- e = "enemy" (Swat, etc.)
- m = "mixed" (Police, Halcyon Operative)
- a = "all" (All of the above)

---

# Commands ID for 'Quick Commands' function
- Stuff Esp: 1, stuffesp
- Cleaner ESP: 2, cleanesp
- Telekinesis: 3, telekinesis, tele, tk
- Telekinesis Fling: 4, telekinesisfling, telefling, tkfling, tkf
- Infinite Ammo: 5, infammo, ia
- Minigun: 6, minigun
- Rainbow Guns: 7, rainbowguns, rgbguns
- Clear current loadout: 8, clearloadout, cloadout
- Add gear to loadout*: 9, addgear
- Set primary: 10, setweapon
- Weapon mods*: 11, weaponmods, wepmods, wpmods
- Kill Rose/Rivera: 12, killr
- NPC Interact: 13, npcinteract
- NPC Follow: 14, npcfollow
- Loop Walkspeed: 15, loopwalkspeed, loopws
- Infinite Jump: 16, infinitejump, infjump
- Bring Armed: 17, bringarmed
- Bring Unarmed: 18, bringunarmed
- Bring Type*: 19, bringtype, bring, bt
- Bring Bags: 20, bringbags
- Loop Bring Bags: 21, loopbringbags, loopbb
- Hide NPCs*: 22, hidenpcs, hidenpc, hide
- Void NPCs*: 23, voidnpcs, voidnpc, void
- Stop Forced NPCs: 24, stopforced, noforced, clearforced, unfreeze
- Disable Cams: 25, disablecams, killcams, byecams, nocams
- No Fog: 26
- No Flashbang: 27, noflashbang, noflash
- Unlock Doors: 28, unlockdoors
- Fast Bagging: 29, fastbag
- Break Metal Detectors: 30, breakmetaldetectors, breakmetal, breakmd
- Alt + Click Delete: 31, altdelete, altdel
- FT difficulty: 32, settpmdiff
- Force teleport: 33, teleportmission, tpmission
- Look Away: 34, lookaway
- Set FOV: 35, setfov
- Show Waypoints: 36, showwaypoints, showwp
- Less Class Restrictions: 37, lessclassres, lcr
- Godmode all: 38, godmodeall
- Godmode yourself*: 39, godmodeme
- Stop Godmode Functions: 40, stopgod
- Scientist Autofarm*: 41, sciauto
