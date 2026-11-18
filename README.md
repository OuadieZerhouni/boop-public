# Boop!: Squishy Snoot Pets

A cozy, tactile toy for iPhone: boop the snoots of squishy kawaii critters, chain combos, unlock a collection of twelve friends, keep a daily streak, and play 30-second *Boop Rush* rounds.

<p align="center"><img src="icon/icon-1024.png" width="160" alt="Boop! app icon"></p>

> **Status: archived.** Boop! was submitted to the App Store in 2026 but not released, and is no longer developed. This repository is published as-is, as a reference.

- **Stack:** Flutter (Dart 3.12), iPhone-first, portrait.
- **No account, no ads, no purchases.** Works offline.
- **7 languages:** English, Arabic, German, Spanish, French, Japanese and Portuguese.
- Every critter is drawn in code (`lib/ui/critter_painter.dart`), with no image assets; sounds are synthesized WAVs.

## Run it

```bash
flutter pub get
flutter gen-l10n
flutter test
flutter run            # iOS simulator or device
```

## License

No open-source license is granted: the code, art and sound are © Ouadie Zerhouni, all rights reserved. You're welcome to read and learn from it; ask before reusing anything.

## Developer notes

The notes below were written while the app was in development. They mention internal files (planning notes, owner to-do lists) that may not be in this repository.

iOS-first Flutter game: boop a squishy critter on the nose, chain combos, unlock
twelve friends, keep a daily streak, and play 30-second Boop Rush rounds.
No ads, no IAP, no account, works offline.

| | |
| --- | --- |
| Spec (product contract, F1–F8) | [SPEC.md](SPEC.md) |
| Store listing, keywords, ASA list | [ASO.md](ASO.md) |
| Remote config schema | [docs/REMOTE_CONFIG.md](docs/REMOTE_CONFIG.md) |
| What only the owner can do | [owner-todo.md](owner-todo.md) |
| Release | [docs/RELEASE.md](docs/RELEASE.md) |

### Commands

```bash
flutter pub get
flutter gen-l10n                    # after editing lib/l10n/app_en.arb or tools/l10n/write_translations.py
flutter analyze
flutter test                        # logic, full app flows, l10n completeness, layout in 7 languages
RENDER_SCREENS=1 flutter test test/tool_render_screens_test.dart   # 1320x2868 frames -> build/shots/
RENDER_ART=1 flutter test test/tool_render_art_test.dart           # critter gallery + icon master -> tools/art/
python tools/audio/make_sounds.py   # regenerate the synthesized SFX
```

### Remote config

`https://raw.githubusercontent.com/OuadieZerhouni/app-configs/main/boop/config.json`
(public repo; privacy and support pages live next to it). Fetched at most every
6 h, never awaited; every key has a safe code default.

### Art and sound

All critters are drawn in code (`lib/ui/critter_painter.dart`) — no image
assets, crisp at any size. Sounds are synthesized WAVs; the boop is pre-rendered
in 14 semitones because iOS playback-rate changes keep pitch.
