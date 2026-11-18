# Stream Deck — Work Profile

`work-profile.streamDeckProfile` is an importable Stream Deck profile bundle
(one "Open Website" button per Microsoft admin portal). `work-profile-source/`
is the unpacked, git-friendly version of the same bundle for future edits.

## Portals (row 1)
- Microsoft 365 admin center — https://admin.microsoft.com
- Entra admin center — https://entra.microsoft.com
- Azure Portal — https://portal.azure.com
- Intune admin center — https://intune.microsoft.com
- Defender / Security portal — https://security.microsoft.com

## Portals (row 2)
- Purview compliance — https://purview.microsoft.com
- Exchange admin center — https://admin.exchange.microsoft.com
- Teams admin center — https://admin.teams.microsoft.com

Device model is set to `20GAV9901` (Stream Deck XL, 8x4 = 32 keys). If you're
on a different Stream Deck model, change `DEVICE_MODEL` in `build.py` and
regenerate (see below) — otherwise the app may prompt to remap the layout.

## Importing
Double-click `work-profile.streamDeckProfile` on Windows (with the Stream
Deck app installed) to import it, or drag it onto the app.

## Editing / adding more buttons
Easiest path: edit `build.py` (add/edit entries in the `PORTALS` list, each a
`(title, url)` tuple), then regenerate:
```bash
python3 build.py
```
This rewrites `work-profile-source/` and `work-profile.streamDeckProfile` in
one shot — no manual zipping needed. Re-import the `.streamDeckProfile` file
in the Stream Deck app afterward to refresh.

Once imported, further tweaks (icons, colors, folders) are easiest made
directly in the Stream Deck app UI, then re-export (right-click profile >
Export) to sync changes back here.
