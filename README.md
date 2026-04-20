# Tire Thumper

A [Project Zomboid](https://projectzomboid.com) Build 42 mod that plays rhythmic thumping sounds when you drive on a flat tire.

No HUD. No pop-up. Just that sinking feeling as the noise gets faster and louder the harder you push it.

![Tire Thumper](poster.png)

## Features

- Triggers only when pressure is genuinely low — not just slightly off
- Thump frequency increases with speed
- Volume scales with both speed and pressure severity — a barely-flat tire at low speed is a quiet warning, highway speed is a bad decision
- 6 unique audio samples, randomly selected each thump for a natural feel
- Works in multiplayer — client-side only, no server required

## Installation

### Steam Workshop
Subscribe on the [Steam Workshop page](https://steamcommunity.com/sharedfiles/filedetails/?id=3703661567) and enable the mod from the Mods menu.

### Manual
Copy the `TireThumper` folder into your Project Zomboid mods directory:
```
C:\Users\<you>\Zomboid\mods\TireThumper\
```

## How It Works

Every tick, the mod checks whether you are:
- Driving (not a passenger)
- Above 21 km/h
- On a tire below 30% of its pressure capacity

If all three are true, a thump sound plays on a timer. The interval between thumps and the volume both scale continuously with your current speed and how flat the tire is. At or below 5 PSI (when the gauge turns red), pressure severity is treated as maximum.

## Tuning

Constants at the top of `42/media/lua/client/TireThumper/TireThumper.lua` can be adjusted:

| Constant | Default | Description |
|---|---|---|
| `PRESSURE_THRESHOLD` | `0.30` | Pressure ratio below which sounds trigger |
| `MIN_SPEED_KMH` | `21` | Minimum speed for sounds to play |
| `MASTER_VOLUME` | `0.50` | Global volume scalar |
| `BLOWOUT_PSI` | `5` | PSI at which pressure severity maxes out |

## Compatibility

- **Build:** B42+
- **Multiplayer:** Yes — client-side only
- **Save-safe:** Yes — no save data, no game state changes
