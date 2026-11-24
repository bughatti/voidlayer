# VoidLayer - Layer Hop & Finder

**Works on:** WoW Forever

> **New: VoidNet.** All six Void network addons (VoidLayer, VoidSweep, VoidQuest, VoidGather, VoidBounty, VoidDungeon) now share one channel on WoW Forever, so you reach more players. Versions from before November 10, 2026 can't share at all: please update (the CurseForge app does it for you).

**Beta:** new, and it gets better with every player who runs it: each one is someone you can hop to.

**See which layer you're on, hop to another with one click, and know when a rare is up on a layer you're not on.**

WoW Forever splits busy zones into layers: copies of the same zone with different players, rares and herbs. VoidLayer shows your layer under the minimap and moves you to another one when you want: a rare is up over there, your node was taken, the zone is crowded.

---

## Features

### Your layer, always in view
- **Under the minimap:** "Layer 512". Since the game update of November 20 a layer can no longer be read off the NPCs around you (every NPC now carries a number of its own), so **VoidLayer names your layer and the game itself keeps the name right**: when the game moves you (a world refresh or a hop) you get a new name; when Void players turn out to be on one layer (you see each other, or you group up) you all take one name; a hop gives you your helper's name. Nothing to target, it's there as soon as you arrive. Hover it for the other layers Void players are on in your zone. An orange dot means a rare is up on another layer. Click it for the window
- **Players seen on this layer:** every player your nameplates, target or mouseover picked up in the last 15 minutes, and how many are the other faction. You only ever see players on your own layer, so they're all on it. It's a minimum, not everyone: the game gives addons no full count
- **The quietest layer:** next to "Players seen" the window says which layer of your zone is quietest. Void players on other layers send how many players they've seen there; the fewest wins (or "yours", when yours is). Each layer in the list shows its count. Only layers with a Void player on them can be compared

### Your layer, zone to zone
- Every zone has its own layers, and walking over a zone border keeps the one you're on: walk from the Barrens into Ashenvale and back, and your Barrens layer keeps its name (measured)
- When you cross a zone line on your own, VoidLayer remembers which layers are yours on each side. The window says **"Same layer as The Barrens 512"**
- **Rares next door on your layer:** a rare up in the next zone on your number there shows in the window and in chat: walk over, no hop needed
- Other VoidLayer players' crossings show too, in grey ("Other Void players went on to Stonetalon 704"). They may not be yours: a world refresh moves only the zone you're in

### Fresh camp: farm the same spot on another layer
- A hop doesn't move you: the world around you becomes the other layer's copy. So after you clear a pack, the same spot on another layer can still be full
- When a pack dies around you (five mobs close together), VoidLayer notes the spot as cleared on your layer and tells the VoidLayer players in your zone (when, on a rough grid; never anyone's position)
- **Fresh layer** in the window hops you to the layer where nobody reported clearing your spot, or reported it longest ago. A layer you cleared it on yourself in the last 10 minutes is skipped. Each other layer in the window shows "spot cleared 4m ago" when someone reported it
- Clear a camp and a Void player on such a layer can bring you over: VoidLayer asks "Hop there?" (after the fight). One click
- Not a promise: only VoidLayer players report clears, and respawn times differ. Solo for now; groups come later

### World refresh: a new layer, solo
- Now and then the game says "The world around you will refresh in 9 Minutes": it's going to move you to another layer in the zone you're in. VoidLayer counts it down under the minimap and in the window, and warns you in chat (louder if you just hopped, because that hop won't hold)
- **New layer now** in the window does it right away: solo, no group or helper needed. The game picks the layer

### Hop with one click
- **Hop** next to any other layer in your zone, or **Fresh layer**: it picks the layer where the mobs around you are most likely up, and with no reports any layer a Void player can bring you to
- A Void player on that layer sends you a quick group invite. VoidLayer accepts only that one invite, checks that your layer really changed and leaves the group again. If someone doesn't answer or you didn't move, it tries the next one
- **No clicks:** the invite you asked for is accepted on its own, and the game's tank / healer / damage window closes itself
- **One hop every 5 minutes,** the game's own limit. The window counts it down
- **Only layers you can actually get to:** a layer shows while a Void player there can bring you over. One who answers busy (in a group, in combat, or helping turned off) or doesn't answer drops out until they say they can again, and the layer leaves the list. At most 4 layers, so the window stays small
- **Works out of the box:** every Void addon player can bring others over unless they turn it off, so nobody has to post in chat or wait for a stranger to notice them. The more players run it, the more layers you can reach

### In a group, but on another layer than the leader
- Joining a group puts you on the leader's layer, but not always: someone who joined earlier, or crossed a zone line, can end up on another one, and then the group can't see each other
- VoidLayer notices: when the leader is in your zone the game itself says whether you're on their layer; otherwise it goes by the leader's VoidLayer, or by the leader standing right next to you while you can't see them. It says so in chat once and points you to **Group hop**
- **Group hop** (in a party or a raid led by someone else) leaves the group and gets you re-invited, which puts you on the leader's layer: automatic when the leader runs VoidLayer, otherwise the leader gets a whisper asking for the invite. Only you leave; never in combat or inside dungeons

### Rares on other layers
- When a Void player sees a rare, every Void player in that zone hears about it: its name, which layer, how much health it has left, how long ago, and when it dies
- **On another layer?** "Rare X is up on Layer 704. Hop there?" One click, and a Void player there brings you over. Asked only when someone there can
- **No wasted hops:** every group invite tells the game whether the inviter is on your layer. When a helper turns out to be on your layer already, VoidLayer turns the invite down at once and asks the next one, and the two of you share one layer name from then on
- **On yours?** A line in chat with where it was seen
- In the window, a rare up on a layer you can get to shows in that layer's row, by name, with its **Hop**. **Rares on your layer** lists the ones you can walk to (at most 3)

### Helping others change layer
- When a Void player on your layer asks, you send them a quick group invite. The group ends on its own after 3 minutes, and you get a line in chat each time
- **Only while you're solo, out of combat and outside dungeons,** at most once every 2 minutes and 8 times an hour
- **Help others change layer** behind the gear in the window turns it off. It's **one switch for every Void addon you have**: the Void hub's **Help Void layer hopping** does the same, and so do the boxes in VoidQuest's and VoidBounty's settings
- **`/vl stats`** shows how your hops went and how many players you brought over

### Host from your Group Finder listing (optional)
- Turn on **Host from my Group Finder listing** behind the gear, then post a Group Finder listing (Custom, a note with the word "layer", e.g. **Layer swap - whisper inv**)
- While it's up, anyone who whispers you **inv**, **layer** or **swap**, or clicks Group Invite on your listing, gets an invite onto your layer: **no addon needed on their side**
- You never leave the group, so your listing stays yours (it follows the group). A guest still with you after a minute gets a **Remove** button for you to click
- Same limits as helping: solo, out of combat, outside dungeons. Friends' and guildmates' invites are never touched

### VoidNet: one network for every Void addon
- VoidLayer, VoidSweep, VoidQuest, VoidGather, VoidBounty and VoidDungeon players of your faction find each other through **one** hidden chat channel (one per faction: you can't group with the other faction anyway). Its name and password change every hour, and it has backups
- **Every one of them can bring you over**, not only VoidLayer players: the other Void addons carry the same layer helper, so the more Void players there are, the more layers you can reach
- **Hard to break:** if someone takes the channel over, bans or kicks Void players or changes its password, everyone moves to a backup and that player is ignored for 24 hours. Nothing is shown as a list of names
- Messages go by hidden addon whispers: like any whisper, the player who gets one can see which character sent it. Only the player whose group you join sees your name in game
- **What's kept on your computer:** the Void players you heard from in the last 2 hours (names and a time, deleted after 2 hours, never shown or shared) and players marked for attacking the channel (24 hours)
- Players on an older version are still reached through the old channel until they update
- The Void **Players online** box shows **VoidNet** (every Void player online, each counted once) and **Layer helpers** under it

---

## Slash Commands

You rarely need them: click your layer under the minimap.

| Command | What it does |
|---|---|
| `/vl` | Open or close the window |
| `/vl hop` | Hop to any other layer in your zone (`/vl hop 704` for Layer 704) |
| `/vl host` | Help others change layer: on or off |
| `/vl layers` | The layers in your zone, in chat |
| `/vl net` | Check that messages to other Void players get through (and how many bounced) |
| `/vl stats` | How your hops went, and how many players you brought over |

---

## Getting Started

1. Install with the CurseForge app, or copy the `VoidLayer` folder into `World of Warcraft/_forever_/Interface/AddOns/`.
2. Restart WoW or `/reload`.
3. Your layer shows under the minimap ("Layer 512"). Click it.

---

## Good to Know

- **There's no "go to layer X" in the game.** To reach a chosen layer you join a group whose leader is on it, which is what a hop does. You can't pick a layer nobody you can reach is on.
- **Hops work within your own server group.** If leaving the group ever sends you back to your old layer, VoidLayer notices and keeps you in the group on later hops (**Stay grouped after a hop**).
- **Settings are per character,** behind the gear in the window's title bar.

---

## Compatibility

- **WoW Forever**
- Standalone: nothing else to install
- Works alongside **VoidSweep, VoidQuest, VoidGather, VoidBounty and VoidDungeon** (one shared network, VoidNet; only one of them does the work)

---

*Part of the Void addon family by Vede · MIT licensed · [Source & bug reports](https://github.com/bughatti/voidlayer) · [All Void addons](https://www.curseforge.com/members/bughatti/projects) · free M+ & raid player lookups at [voidscout.io](https://voidscout.io) · more at [tinkerline.io](https://tinkerline.io/addons/voidlayer/) · [Discord](https://discord.gg/7ZHmx7zMDh)*
