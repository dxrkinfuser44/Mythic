# Steam support — setup

## 1. Secrets (`.env`)

```sh
cp .env.example .env
```

Fill in `.env` (repo root, gitignored). It is `#include?`d by `Mythic/Config/Steam.xcconfig`, so it must contain
**only** `KEY=value` lines — no `#` comments, no quotes, no `//`.

| Variable | Required | What it is |
|---|---|---|
| `STEAM_WEB_API_KEY` | for owned-library sync | 32-hex-char key from https://steamcommunity.com/dev/apikey |
| `STEAM_OPENID_REALM_HOST` | yes (defaults to `getmythic.app`) | Bare host name (no scheme, no slashes) shown on Steam's sign-in page. The callback `https://<host>/steam/openid/callback` is intercepted inside Mythic and never actually requested. |

Flow: `.env` → `Steam.xcconfig` build settings → `Info.plist` (`MythicSteamWebAPIKey`, `MythicSteamOpenIDRealm`) → `SteamConfig`.

Without a key, Steam sign-in and installed-game detection still work; only the owned-but-not-installed list is skipped.
Users can also paste their own key in **Settings → Steam** (stored in Keychain, overrides the bundled key).

> ⚠️ Anything in `Info.plist` ships inside the `.app` and can be read by anyone who has the build.
> For public releases prefer leaving `STEAM_WEB_API_KEY` empty and having users supply their own,
> or proxy `GetOwnedGames` through a server you control.

## 2. Build (macOS)

Open `Mythic.xcodeproj`, resolve packages, build the `Mythic` scheme (Swift 6 mode). New files are already registered; the target uses `Mythic/Config/Steam.xcconfig` as its base configuration.

## 3. Runtime behaviour

* Accounts → Steam: sign in through Steam's own OpenID page (Mythic never sees your password).
* Installed games are read from `~/Library/Application Support/Steam` and from Windows Steam inside each Wine container.
* Install / launch / uninstall are handed to the Steam client via `steam://` URLs — the Steam client must be installed
  (natively, or inside a Mythic container for Windows-only titles).

See `FUNCTION_MAP.md` for the API contract and `SECURITY_*.md` for audit results.
