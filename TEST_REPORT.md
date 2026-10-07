# Test drive — Boop! 1.0.0 · 2026-10-07 12:58
iPhone 17 Pro · iOS 26.5 · build FAILED in 14s · commit e93e1c2 · seams: none (app has no trace seam)

PASS 0 · FAIL 1 · BLOCKED 31 · SKIP 0   (of 31 criteria + F0)

| Criterion | Verdict | Evidence | Note |
| --- | --- | --- | --- |
| F0 builds for the simulator | **FAIL** | test-drive/20261007-1258/F0-build.log | expected a build; Xcode 27 refuses IPHONEOS_DEPLOYMENT_TARGET 13.0 (floor 15.0) |
| F1–F8 (31 criteria) | BLOCKED | | F0 failed |

## Regressions
None (no previous report).

## Findings
- Boop was scaffolded from factory 1652235, before the template moved to 15.0 and gained `test/ios_deployment_target_test.dart` (TRAPS.md § Deployment target below Xcode's floor).

## Next for /build
| F0 builds for the simulator | **FAIL** | test-drive/20261007-1258/F0-build.log | expected a build; Xcode 27 refuses IPHONEOS_DEPLOYMENT_TARGET 13.0 (floor 15.0) |
