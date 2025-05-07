## How to run:

**Method 1: Godot Debug**

1. Download Godot 4.4
2. Clone repository and open it in Godot
3. Press Run Project/F5 (in top right, looks like menu)

**Method 2: Run Binaries**

1. Clone repo
2. See ./bin/ for Linux and Windows binaries. Unfortunately, exporting to Mac required a lot of overhead that we could not figure out, and neither of us own Macs as well.

## In-game information
* Only two controls are turn left (A or left arrow) and turn right (D or right arrow)
* Camera turn speed is set in the main menu, and while we don't have concrete evidence it seems to be different per device. We settled on a default value of 6.0 which should be good. If it looks weird just play around with it

## Bugs + Wrinkles
* The way we fixed collision is that the first couple of body segments are ignored in collision. This causes the player to be able to phase through the enemy if they precisely maneuver into the aforementioned areas.
* Small ~(P < 0.03) chance that food spawns outside of map
* Food spawn area does not shrink with the storm, i.e. they can spawn out of the storm
* AI snake is only smart enough to go find food - not much else

