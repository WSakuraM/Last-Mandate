# Audio CC0 / Kenney credits (Last Mandate)

Ingest session paths under `game/assets/audio/` unless noted. Staging: `game/assets_library/staging/audio_cc0/`.

## Kenney — Interface Sounds (CC0)
- https://kenney.nl/assets/interface-sounds
- Vendor: `game/assets_library/vendor/kenney/audio/interface-sounds/`
- `click_002.ogg` → `sfx/ui/click.ogg`
- `confirmation_002.ogg` → `sfx/ui/toast.ogg`
- `pluck_001.ogg` → `dialogue/blip.ogg`

## Kenney — RPG Audio (CC0)
- https://kenney.nl/assets/rpg-audio
- Vendor: `game/assets_library/vendor/kenney/audio/rpg-audio/`
- `cloth1.ogg` → `sfx/interact/plant.ogg`
- `knifeSlice.ogg` → `sfx/interact/harvest.ogg`
- `handleCoins.ogg` → `sfx/interact/sell.ogg`
- `cloth4.ogg` → `sfx/interact/forage.ogg`
- `metalPot3.ogg` → `sfx/interact/fish.ogg`

## Kenney — Music Jingles (CC0)
- https://kenney.nl/assets/music-jingles
- Zip: `kenney_music-jingles.zip`
- `Preview.ogg` → `music/manor_soft.ogg`

## OpenGameArt — Rain (CC0)
- Primary Dark Rainy Night: https://opengameart.org/sites/default/files/Dark_Rainy_Night%28ambience%29.ogg
  - First attempt timed out; a later/complete copy landed as staging `rain.ogg` (~6.45MB) → `weather/rain.ogg`
- Alt also downloaded: Ove Melaa — Rainy (NOT loopable) → staging `Ove_Melaa_Rainy.ogg`

## OpenGameArt — Yard ambient
- Requested Birds and Wind — Ambient: **HTTP 404**
- Fallback: https://opengameart.org/sites/default/files/forest.ogg → `ambient/yard_day.ogg`

## OpenGameArt — Wind pack (CC0)
- https://opengameart.org/sites/default/files/ambient_mountains_forest_river_waterfall_wind.7z
- Extracted under staging `wind_pack/`
- `amb_wind_1.flac` → `weather/wind.flac`
- `amb_forest.flac` → `weather/snow.flac` (soft bed; prefer this for snow if importing FLAC)

## OpenGameArt — Wind OGG
- https://opengameart.org/sites/default/files/wind.ogg → `weather/wind.ogg`

## Snow OGG note
- No ffmpeg available to re-encode pack FLAC to Vorbis in this session.
- `weather/snow.ogg` currently uses a soft ambient OGG fallback from staging (`yard_birds.ogg`); authoritative soft forest bed remains `weather/snow.flac`.

## Legacy WAV
- Existing `.wav` stubs under the same folders were left in place alongside new `.ogg` files.
