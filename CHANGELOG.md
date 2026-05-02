# Tire Thumper — Changelog

## v0.2
- **Speed-based interval**: thump rate now interpolates continuously from 2.0 s at 21 km/h down to 0.2 s at 81+ km/h, updating every tick as speed changes
- **Zoom-based volume**: sounds are silent when zoomed far out (≥ 2.0), normal when at mid zoom (1.0–2.0), and louder when zoomed in close (< 1.0)
- **Per-tier volumes**: each speed tier (Slow / Fast / Faster) has its own fixed volume rather than a random lo/hi mix
- **Camera zoom API**: discovered and integrated `getCore():getZoom(0)` for real-time zoom detection

## v0.1
- Initial release
- Rhythmic thumping sounds when driving on a flat tire
- Six randomized audio samples
- Thumping rate and volume scale with speed
