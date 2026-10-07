# Remote config

The authoritative schema for this app's remote config blob. Read before adding
a key.

## The four-file convention

| File | Role |
| --- | --- |
| `remote_config_current.json` | Snapshot of what is **live** right now |
| `remote_config_proposed.json` | Changes staged for the next push |
| `remote_config_template.json` | Every key with a safe default and a comment |
| `remote_config_android_test.json` | Android/dev overrides |

Keeping `current` in the repo is what makes "what is live?" answerable without
opening a console — and reviewable in a diff. Validate JSON after every edit;
a malformed blob degrades to code defaults silently, which looks like the
feature never shipped.

## Rules

- **Config tunes behaviour; it never invents it.** A flag may change a number,
  a probability, or a phrase list. It must not be able to request behaviour the
  app has no code for.
- **Every key has a code default** that is safe on its own, because the very
  first launch on a new install has no fetched config yet.
- **Kill switches default to off.** A feature ships dark and is enabled
  deliberately, per platform if needed.
- Malformed values clamp or fall back; they never crash. One test per config
  section asserts this.

## Where it lives

- **Live file:** `https://raw.githubusercontent.com/OuadieZerhouni/app-configs/main/boop/config.json`
  (public repo `OuadieZerhouni/app-configs`, folder `boop/` — also holds `PRIVACY.md` and `SUPPORT.md`).
- **In this repo:** `config/remote_config_current.json` (copy of what is live) and
  `config/remote_config_template.json` (every key). `test/logic_test.dart` fails if either
  disagrees with `RemoteConfig.defaults`.
- **Fetch policy:** `RemoteConfigService` — cached in `rc.cache`, refetched at most every 6 h,
  never awaited at startup. Offline = cached copy or code defaults.
- **To change a value:** edit the file in app-configs, validate (`python -m json.tool`), push.
  Raw GitHub caches up to ~5 min; devices pick it up on their next fetch (≤ 6 h).

## Sections

### Versioning
| Key | Type | Default | Notes |
| --- | --- | --- | --- |
| `schemaVersion` | int | 1 | bump only on a breaking schema change |
| `minSupportedVersion` | semver | `1.0.0` | below this, a non-dismissible "update" banner shows |
| `latestVersion` | semver | `1.0.0` | above the installed version, a dismissible banner shows |
| `updateUrlIos` | https URL | `""` | App Store link; set once GATE-ASC-RECORD gives the id |

### `announcement`
| Key | Type | Default | Notes |
| --- | --- | --- | --- |
| `enabled` | bool | false | |
| `id` | string | `""` | **required** — dismissals are remembered per id; a new message needs a new id |
| `title`, `body` | string or `{lang: text}` | — | falls back to `en`, then any value |
| `url` | https URL | `""` | non-https is dropped |

### `features`
| Key | Type | Default | Notes |
| --- | --- | --- | --- |
| `rushEnabled` | bool | true | kill switch: false shows a "resting" card on the Rush tab |

### Gameplay
| Key | Type | Default | Clamp |
| --- | --- | --- | --- |
| `dailyGoal` | int | 50 | 10–500 |
| `rush.durationSec` | int | 30 | 15–60 |

### `reviewPrompt`
| Key | Type | Default | Clamp |
| --- | --- | --- | --- |
| `enabled` | bool | true | |
| `afterUnlocks` | int | 3 | 1–11 — asks once, after this many critters beyond the first |

### `links`
| Key | Type | Default |
| --- | --- | --- |
| `privacyPolicy` | https URL | app-configs `boop/PRIVACY.md` |
| `support` | https URL | app-configs `boop/SUPPORT.md` |

### `ads`
| Key | Type | Default | Notes |
| --- | --- | --- | --- |
| `enabled` | bool | false | **reserved** — v1 contains no ad code; the flag is read and ignored |
