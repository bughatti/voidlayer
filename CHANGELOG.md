# VoidLayer Changelog

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
