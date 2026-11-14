# VoidLayer - Layer Hop & Finder

**Works on:** WoW Forever

**Beta:** new, and it gets better with every player who runs it: each one is someone you can hop to.

**See which layer you're on, hop to another with one click, and know when a rare is up on a layer you're not on.**

WoW Forever splits busy zones into layers: copies of the same zone with different players, rares and herbs. VoidLayer shows your layer under the minimap and moves you to another one when you want: a rare is up over there, your node was taken, the zone is crowded.

---

## Features

### Your layer, always in view
- **Under the minimap:** "Layer 98". A layer's name is its own number, so it's **the same for every player**: you and a guildie on one layer both see "Layer 98". Hover it for the full id and the other layers Void players are on in your zone. An orange dot means a rare is up on another layer. Click it for the window
- Read from the NPCs around you, so look at or target any NPC once after you arrive somewhere
- **Players seen on this layer:** every player your nameplates, target or mouseover picked up in the last 15 minutes, and how many are the other faction. You only ever see players on your own layer, so they're all on it. It's a minimum, not everyone: the game gives addons no full count

### Your layer, zone to zone
- Every zone gives you its own layer number, and the game remembers yours: walk from the Barrens into Ashenvale and back, and you're on the same "Layer 88" and "Layer 100" every time (measured)
- When you cross a zone line on your own, VoidLayer remembers which numbers are yours. The window says **"Same layer as The Barrens 88"**
- **Rares next door on your layer:** a rare up in the next zone on your number there shows in the window and in chat: walk over, no hop needed
- Other VoidLayer players' crossings show too, in grey ("Other Void players went on to Stonetalon 96"). The game keeps each player's numbers apart, so theirs may not be yours
- **How many layers a zone has:** the window shows how many layers VoidLayer players have seen in your zone in the last 30 minutes

### World refresh: a new layer, solo
- Now and then the game says "The world around you will refresh in 9 Minutes": it's going to move you to another layer in the zone you're in. VoidLayer counts it down under the minimap and in the window, and warns you in chat (louder if you just hopped, because that hop won't hold)
- **New layer now** in the window does it right away: solo, no group or helper needed. The game picks the layer

### Hop with one click
- **Hop** next to any other layer in your zone, or **Hop to any layer**
- A Void player on that layer sends you a quick group invite. VoidLayer accepts only that one invite, checks that your layer really changed and leaves the group again. If someone doesn't answer or you didn't move, it tries the next one
- **One hop every 5 minutes,** the game's own limit. The window counts it down
- A layer whose Void players can't bring anyone over right now (in a group, in combat, or with helping turned off) says **busy**; hover it for why
- **Works out of the box:** every VoidLayer player can bring others over unless they turn it off, so nobody has to post in chat or wait for a stranger to notice them. The more players run it, the more layers you can reach

### Rares on other layers
- When a Void player sees a rare, every Void player in that zone hears about it: its name, which layer, how much health it has left, how long ago, and when it dies
- **On another layer?** "Rare X is up on Layer 17. Hop there?" One click, and the player who saw it brings you over
- **On yours?** A line in chat with where it was seen
- The window lists the rares up in your zone with a **Hop** button on each

### Helping others change layer
- When a Void player on your layer asks, you send them a quick group invite. The group ends on its own after 3 minutes, and you get a line in chat each time
- **Only while you're solo, out of combat and outside dungeons,** at most once every 2 minutes and 8 times an hour
- **Help others change layer** in the window (or the Void hub's quick switches) turns it off

### Its own network
- VoidLayer players of your faction find each other through a hidden chat channel (one per faction: you can't group with the other faction anyway) with a password that changes every day, so nobody can take it over and lock players out for more than a day. Messages go by hidden addon whispers. No names are saved, and the only player who sees yours is the one whose group you join
- **VoidSweep** players are on the same network, so they help you hop and share their rares too
- The Void **Players online** box shows how many players are on the layer network right now

---

## Slash Commands

You rarely need them: click your layer under the minimap.

| Command | What it does |
|---|---|
| `/vl` | Open or close the window |
| `/vl hop` | Hop to any other layer in your zone (`/vl hop 17` for Layer 17) |
| `/vl host` | Help others change layer: on or off |
| `/vl layers` | The layers in your zone, in chat |
| `/vl net` | Check that messages to other VoidLayer players get through (and how many bounced) |

---

## Getting Started

1. Install with the CurseForge app, or copy the `VoidLayer` folder into `World of Warcraft/_forever_/Interface/AddOns/`.
2. Restart WoW or `/reload`.
3. Point at any NPC: your layer shows under the minimap ("Layer 98"). Click it.

---

## Good to Know

- **There's no "go to layer X" in the game.** To reach a chosen layer you join a group whose leader is on it, which is what a hop does. You can't pick a layer nobody you can reach is on.
- **Two layers can share a number** (on different servers). Then both show the full id ("Layer 6829-98").
- **Hops work within your own server group.** If leaving the group ever sends you back to your old layer, VoidLayer notices and keeps you in the group on later hops (**Stay grouped after a hop**).
- **Settings are per character.**

---

## Compatibility

- **WoW Forever**
- Standalone: nothing else to install
- Works alongside **VoidSweep** (one shared network; only one of them does the work)

---

*Part of the Void addon family by Vede · MIT licensed · [Source & bug reports](https://github.com/bughatti/voidlayer) · [All Void addons](https://www.curseforge.com/members/bughatti/projects) · free M+ & raid player lookups at [voidscout.io](https://voidscout.io) · more at [tinkerline.io](https://tinkerline.io/addons/voidlayer/) · [Discord](https://discord.gg/7ZHmx7zMDh)*
