# VoidLayer Changelog

## 0.5.2 — 2026-11-21

- **The window only offers layers you can get to.** A layer is listed while a Void player there can bring you over. Someone who answers busy (in a group, in combat, just helped someone) or doesn't answer drops out until they say they can again, so Hop no longer fails one layer after another.
- **A smaller window:** at most 4 layers and 3 rares. A rare on a layer you can reach shows in that layer's row by name; **Rares on your layer** lists the ones you can walk to.
- **"Hop there?"** for a rare on another layer only asks when someone there can bring you over.

## 0.5.1 — 2026-11-17

- **Layer helping finds players faster (WoW Forever).** A layer question now reaches the Void players it asks in about a second instead of eleven, so Refresh and hops see the other layers right away. Same message rate over time, well under the game's limit.

## 0.5.0 — 2026-11-17

- **VoidNet: one hidden channel for every Void addon (WoW Forever).** VoidLayer, VoidSweep, VoidQuest, VoidGather, VoidBounty and VoidDungeon now share ONE channel instead of one each. The Void players box shows **VoidNet** (every Void addon player online, each counted once) with **Layer helpers** under it. Players on an older version are still reached through the old channel, which goes away 30 days after the last of them updates.
- **Harder to grief:** the channel name changes every hour, with backups. If someone takes the channel over, bans or kicks Void players, or changes its password, every Void addon moves to the backup and ignores that player for 24 hours (a report from others counts only when 3 different Void players saw it). Nothing is shown as a list of names.
- **Help others change layer** is one switch for every Void addon: the hub's **Help Void layer hopping**, or this window's gear. Flip it anywhere and it changes everywhere.
- **Hosting from a Group Finder listing:** list a "Layer swap" group and players without Void addons can whisper you for a hop. You stay in your listed group (the listing follows it) and anyone who stays longer than a minute gets a Remove button.
- **Zero clicks for the invite you asked for**, the role pop-up closes itself, and a small hop journal counts your hops.
- **Void windows open in front** of other windows and come forward when you click them; only one first-time pop-up shows at a time.

## 0.4.1 — 2026-11-15

- **A Hop nobody could do now says why:** how many Void players on that layer were asked, and for each, whether they were in a group or fighting, had moved off that layer, had helping others turned off, or didn't answer. A player who moved off is no longer offered for that layer.

## 0.4.0 — 2026-11-15

- **Group hop** replaces "Hop to any": in a party or a raid led by someone else, one click puts you on your group's layer (you leave and get re-invited; automatic when the leader runs VoidLayer, else the leader gets a whisper). Greyed out when you're solo or the leader, with the reason on hover.
- **Fresh layer** now also does what "Hop to any" did: it picks the layer where the mobs around you are most likely up, and when nobody reported anything, any layer a Void player can bring you to.

## 0.3.1 — 2026-11-14

- **In a group but on another layer than the leader?** VoidLayer notices (exactly, when the leader runs VoidLayer too; otherwise when the leader is right next to you but you can't see them), says so in chat and shows a **Rejoin** button. One click leaves the group and gets you re-invited, which puts you on the leader's layer: automatic with VoidLayer on the leader, otherwise the leader gets a whisper asking for the invite. Only you leave; never in combat or inside dungeons.
- **The quietest layer.** Next to "Players seen" the window now says which layer of your zone is quietest: Void players on other layers send how many players they've seen there, and the layer with the fewest wins (or "yours", when yours is). Each layer in the list shows its count too. Only layers with a Void player on them can be compared.
- **A tighter window:** the four settings moved behind the gear in the title bar, the three buttons share one row, the rares section only shows when there are rares, and the online count sits in the "Other layers" header.

## 0.3.0 — 2026-11-14

- **Fixed: two players on the same layer could see different layer names.** Tested with two players side by side on one layer: only the first number in the game's id is the layer; the second one counts up separately for every player. Layers are now named by that first number ("Layer 6832"), so everyone on a layer sees the same name, and hops, rares, zone links and the layer count all go by it. Older VoidLayer and VoidSweep versions still work with this one.
- **Fresh camp: farm the same spot on another layer.** A hop doesn't move you: the world around you becomes the other layer's copy. So when a pack dies around you (five mobs close together), VoidLayer notes the spot as cleared on your layer and tells the VoidLayer players in your zone (when, on a rough grid; never anyone's position). **Fresh layer here** in the window hops you to the layer where nobody reported clearing your spot, or reported it longest ago; a layer you cleared it on yourself in the last 10 minutes is skipped. Other layers in the window show "spot cleared 4m ago". Clear a camp and a Void player on such a layer can bring you over: "Hop there?" after the fight, one click.
- **Fixed: a player's companion pet could flip your layer** for a moment (its id points at another server). Pets are never read now.

## 0.2.0 — 2026-11-14

- **Layer names are the same for everyone.** A layer is named by its own number ("Layer 98"), so you and a guildie on one layer see the same name. They used to be letters in the order you met them, so the same layer could be "B" for you and "G" for your guildie.
- **World refresh: a new layer, solo.** When the game says "The world around you will refresh in 9 Minutes", VoidLayer counts it down under the minimap and in the window, and warns you in chat (louder if you just hopped, because that hop won't hold). **New layer now** in the window does it right away, with no group or helper needed.
- **Fixed: after a world refresh your layer kept showing the old one** for up to 3 minutes. It now reads the new one straight away.
- **Players seen on this layer:** how many players you've seen on your layer in the last 15 minutes, and how many are the other faction. You only see players on your own layer, so they're all on it. It's a minimum: the game gives addons no full count.
- **Your layer, zone to zone.** Each zone gives you its own layer number, and the game remembers yours. When you cross a zone line on your own, VoidLayer remembers your numbers: "Same layer as The Barrens 88", and a rare up next door on your number there says "walk over, no hop needed". Other players' crossings show in grey, since theirs may not be yours.
- **How many layers a zone has:** how many layers VoidLayer players have seen in your zone in the last 30 minutes.

## 0.1.6 — 2026-11-12

- **Fixed: a side of a box could be missing**, e.g. the right line of the recipes box and its buttons when the game window is an odd number of pixels wide. Every Void box now always shows all four border lines.

## 0.1.5 — 2026-11-12

- **The layer label stays where you put it**, even after a restart (it could jump back).
- **The players-here box:** its tooltip no longer covers the box while you drag it, and it opens above or below the box depending on where the box sits on screen.
- **Void hub button:** left-click opens one panel with all your Void addons by name, grouped, each with its own on/off switches (it replaces the ring of icons), with a background slider. The hub's info window now stays where you put it.

## 0.1.4

- **One network per faction.** Layer hops need a group invite, and groups can't cross factions, so players of the other faction on the old shared channel could never bring you over (and were counted as online). Horde and Alliance now each have their own channel. New `/vl net` checks that messages get through and shows bounced whispers. Older versions stay on the old channel: please update.

## 0.1.3

- **After a hop, the player who brought you over is listed on the layer you landed on,** not the one they reported earlier.
- **Says why a hop can't happen.** When the Void players on another layer can't bring anyone over right now (in a group, in combat, or with helping turned off), the layer reads **busy** and Hop says so, instead of "no Void player" while the window counts one there.

## 0.1.2

- **Hops finish properly.** The first real hop worked (joining the group moved you to the new layer within seconds), but VoidLayer waited for the exact layer the other player had reported earlier, so it never said "you're on Layer B now" and never left the group. Now any move off your layer while you're in their group counts as the hop, and wherever you land is recorded as their layer.
- **You're never left in the hop group:** VoidLayer leaves the two-person group it joined for the hop even when the other player's name shows differently, and only that group, never one you join yourself afterwards.

## 0.1.1

- **Nothing about other players is saved any more:** the short list of players who had just logged off (it kept the online count right after a reload) now lasts only for your session.
- "Hop to any layer" with nobody to bring you over now says "on another layer", not "on that layer".

## 0.1.0

- First release, for WoW Forever.
- **Your layer under the minimap** ("Layer A"); click it for the window.
- **Hop with one click:** to any other layer in your zone, or to the one a rare is on. A Void player there sends you a quick group invite, VoidLayer checks you moved and leaves the group. One hop every 5 minutes.
- **Rares on other layers:** Void players share the rares they see, with the layer, health and when it died. One on another layer of your zone asks "Hop there?".
- **Everyone helps:** every VoidLayer player can bring others over (only while solo, out of combat and outside dungeons, at most once every 2 minutes); one switch turns it off.
- **Its own network:** a hidden channel with a daily password. VoidSweep players share it. The Void **Players online** box shows how many are on it.
