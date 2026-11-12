# VoidLayer - Layer Hop & Finder

**Works on:** WoW Forever

**Beta:** new, and it gets better with every player who runs it: each one is someone you can hop to.

**See which layer you're on, hop to another with one click, and know when a rare is up on a layer you're not on.**

WoW Forever splits busy zones into layers: copies of the same zone with different players, rares and herbs. VoidLayer shows your layer under the minimap and moves you to another one when you want: a rare is up over there, your node was taken, the zone is crowded.

---

## Features

### Your layer, always in view
- **Under the minimap:** "Layer A", "Layer B", ... Hover it for the layer's id and the other layers Void players are on in your zone. An orange dot means a rare is up on another layer. Click it for the window
- Read from the NPCs around you, so look at or target any NPC once after you arrive somewhere

### Hop with one click
- **Hop** next to any other layer in your zone, or **Hop to any layer**
- A Void player on that layer sends you a quick group invite. VoidLayer accepts only that one invite, checks that your layer really changed and leaves the group again. If someone doesn't answer or you didn't move, it tries the next one
- **One hop every 5 minutes,** the game's own limit. The window counts it down
- A layer whose Void players can't bring anyone over right now (in a group, in combat, or with helping turned off) says **busy**; hover it for why
- **Works out of the box:** every VoidLayer player can bring others over unless they turn it off, so nobody has to post in chat or wait for a stranger to notice them. The more players run it, the more layers you can reach

### Rares on other layers
- When a Void player sees a rare, every Void player in that zone hears about it: its name, which layer, how much health it has left, how long ago, and when it dies
- **On another layer?** "Rare X is up on Layer B. Hop there?" One click, and the player who saw it brings you over
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
| `/vl hop` | Hop to any other layer in your zone (`/vl hop B` for Layer B) |
| `/vl host` | Help others change layer: on or off |
| `/vl layers` | The layers in your zone, in chat |
| `/vl net` | Check that messages to other VoidLayer players get through (and how many bounced) |

---

## Getting Started

1. Install with the CurseForge app, or copy the `VoidLayer` folder into `World of Warcraft/_forever_/Interface/AddOns/`.
2. Restart WoW or `/reload`.
3. Point at any NPC: your layer shows under the minimap. Click it.

---

## Good to Know

- **There's no "go to layer X" in the game.** The only way to another layer is to join a group whose leader is on it, which is what a hop does. You can't pick a layer nobody you can reach is on.
- **Layer letters are yours.** Layers are named A, B, C in the order you meet them in each zone, so your "Layer B" may be someone else's "Layer C". Hover a layer for its id ("7053-17"), which is the same for everyone.
- **Hops work within your own server group.** If leaving the group ever sends you back to your old layer, VoidLayer notices and keeps you in the group on later hops (**Stay grouped after a hop**).
- **Settings are per character.**

---

## Compatibility

- **WoW Forever**
- Standalone: nothing else to install
- Works alongside **VoidSweep** (one shared network; only one of them does the work)

---

*Part of the Void addon family by Vede · MIT licensed · [Source & bug reports](https://github.com/bughatti/voidlayer) · [All Void addons](https://www.curseforge.com/members/bughatti/projects) · free M+ & raid player lookups at [voidscout.io](https://voidscout.io) · more at [tinkerline.io](https://tinkerline.io/addons/voidlayer/) · [Discord](https://discord.gg/7ZHmx7zMDh)*
