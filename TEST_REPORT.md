# Test drive — Boop! 1.0.0+1 · 2026-10-07 13:05
iPhone 17 Pro Max · iOS 26.5 · build 49s · commit e2f3fff · seams: none (no trace seam; timers read from long-lived states)

PASS 21 · FAIL 0 · BLOCKED 8 · SKIP 2   (of 31 criteria) — F0 builds: PASS

| Criterion | Verdict | Evidence | Note |
| --- | --- | --- | --- |
| F0 builds for the simulator | PASS | test-drive/20261007-1259/F7-first-launch.png | 49 s build after e2f3fff (deployment target 15.0) |
| F1-c1 A tap inside the nose hit-area increments the session and lifetime boop counters by exactly 1 | PASS | test-drive/20261007-1259/F1-c1-after-nose-tap.png | 0→1 boop, Today 0/50→1/50; hint gone (F7) |
| F1-c2 A tap on the body outside the nose does not count; wobble and giggle | PASS | test-drive/20261007-1259/F1-c2-after-body-tap.png | tilt + giggle face + sparkles, count stays 1; the giggle sound is covered by criteria_test F1 c2 |
| F1-c3 Dragging stretches toward the finger; releasing springs it back | PASS | test-drive/20261007-1259/F1-c3-during-drag.png | body sheared right mid-drag; upright after release ({E}/F1-c3-after-release.png) |
| F1-c4 Holding 0.6 s or longer is a hug: eyes closed, hearts stream; not a boop | PASS | test-drive/20261007-1259/F1-c4-hug-held-3s.png | ~4 s into a 6 s hold: hug eyes, hearts still streaming, count unchanged |
| F1-c5 Idle: breathes, blinks, sleepy after 30 s; next touch wakes it | PASS | test-drive/20261007-1259/F1-c5-idle-36s.png | half-lidded + z z z at 36 s; awake after a body touch ({E}/F1-c5-woken.png). Blink cadence and breathing are sub-second, so the widget test covers them |
| F1-c6 Sound and haptics obey Settings; both off = silent and still | SKIP |  | simulator has no haptics and audio is not capturable; criteria_test F1 c6 asserts both |
| F1-c7 Every interactive element has a Semantics label; critter announces its name | BLOCKED |  | VoiceOver cannot be driven through the simulator MCP; criteria_test F1 c7 runs labeledTapTargetGuideline on every tab, Rush mid-round and Settings |
| F2-c1 Two boops within 1.0 s make combo 2; a longer gap resets it | PASS | test-drive/20261007-1259/F2-after-10-taps.png | burst of 10 → Combo ×10; after the >1 s pause the next burst read ×20, not ×30 ({E}/F3-c1-unlock-pip.png) |
| F2-c2 At combo 10, 25 and 50 a tier banner pops with chime and medium haptic | PASS | test-drive/20261007-1259/F2-after-10-taps.png | "Boop-a-doop!" at 10; chime + haptic not observable on a simulator (criteria_test F2) |
| F2-c3 Every 30th boop in a combo makes the critter sneeze with confetti | PASS | test-drive/20261007-1259/F2-c3-sneeze-at-30.png | "Achoo!", surprised face, confetti at Combo ×30 |
| F2-c4 The best combo ever is saved and shown on the Critters screen | PASS | test-drive/20261007-1259/F3-c2-critters-tab.png | "Best combo ×30" |
| F3-c1 Crossing a threshold unlocks exactly that critter once; celebration once, even across restarts | PASS | test-drive/20261007-1259/F3-c1-unlock-pip.png | "Say hi to Pip!" at 30; not shown again after relaunch ({E}/F3-c1-relaunch-no-recelebration.png) |
| F3-c2 Critters tab: unlocked = colour, name, count; locked = silhouette, ???, N more boops | PASS | test-drive/20261007-1259/F3-c2-critters-tab.png | Mochi 60 boops, Pip No boops yet, ??? 20 / 90 more boops; all 12 cards asserted in app_flow_test |
| F3-c3 Tapping an unlocked card selects + saves + switches to Boop; locked shows boops remaining | PASS | test-drive/20261007-1259/F3-c3-pick-pip.png | locked: "Boop 20 more times to meet this friend." ({E}/F3-c3-locked-card-tap.png); Pip still selected after relaunch ({E}/F5-c5-relaunch-boop-tab.png) |
| F3-c4 Each critter has its own colours, ears, nose shape and squeak pitch | BLOCKED |  | only 2 of 12 reachable without 3000 boops (Mochi and Pip differ visibly); logic_test checks look + pitch uniqueness across all 12 |
| F3-c5 Progress bar "Next friend in N boops" or "Everyone's here!" | PASS | test-drive/20261007-1259/F3-c3-pick-pip.png | "Next friend in 20 boops" with a partly filled bar; "Everyone's here!" needs 3000 boops (criteria_test F3 c5) |
| F4-c1 The ring fills with today's boops and completes at the goal; "Daily boops done!" once a day | PASS | test-drive/20261007-1259/F2-c3-sneeze-at-30.png | ring complete + toast at 50; partly filled at 10 ({E}/F2-after-10-taps.png) |
| F4-c2 Streak increments on consecutive days, resets after an unmet day | BLOCKED |  | no clock seam in the build, and changing the simulator date does not move the app's clock reliably; "1-day streak" observed; logic_test daily goal & streak |
| F4-c3 Day boundaries use local time and are testable with an injected clock | BLOCKED |  | code-level criterion; logic_test uses explicit local times across month/DST boundaries |
| F5-c1 A round lasts exactly the configured duration; no scoring after time is up | PASS | test-drive/20261007-1259/F5-c1-results-33s.png | timer read 24 s at ~6 s ({E}/F5-mid-round-6s.png); results by 33 s. Remote duration: criteria_test F5 c1 |
| F5-c2 Scoring: +1 awake, +5 golden, streak bonus, −2 sleepy floored at 0 | BLOCKED |  | choosing a critter kind needs reactions under the 1.6 s popup life; +1 for an awake boop observed; logic_test scoring |
| F5-c3 A booped or timed-out critter leaves its bush; never two critters per bush | BLOCKED |  | needs frame-accurate observation; logic_test + criteria_test F5 c3 replay whole rounds |
| F5-c4 The best score persists; a new best is celebrated | PASS | test-drive/20261007-1259/F5-c1-results-33s.png | "New best!"; Best 1 after relaunch ({E}/F5-c4-best-after-relaunch.png) |
| F5-c5 Rush boops count toward lifetime boops, unlocks and the daily goal (awake only) | PASS | test-drive/20261007-1259/F5-c5-relaunch-boop-tab.png | 60 → 61 lifetime after a 1-point round |
| F5-c6 The Rush tab can be killed remotely; shows "Rush is resting" | BLOCKED |  | needs editing the live hosted config (affects real installs); app_flow_test kill-switch test |
| F6-c1 Each toggle persists across restarts and takes effect immediately | PASS | test-drive/20261007-1259/F6-c1-after-relaunch.png | Sound off + Reduce motion on survived terminate/launch ({E}/F6-c1-toggled.png); haptics persistence in criteria_test F6 c1 |
| F6-c2 Reduce motion removes particles, confetti and stretch; keeps a scale pulse | PASS | test-drive/20261007-1259/F6-c2-reduced-boop.png | boop shows "+1" and the happy face, no hearts or sparkles |
| F6-c3 Reset clears every saved key; back to first-launch state | PASS | test-drive/20261007-1259/F6-c3-after-reset-home.png | confirm dialog ({E}/F6-c3-reset-confirm.png) → Mochi, 0 boops, hint back, streak gone; language kept |
| F6-c4 A language override switches the UI immediately; Arabic lays out RTL | PASS | test-drive/20261007-1259/F6-c4-arabic-settings.png | whole UI mirrored, back arrow trailing; home + tabs mirrored ({E}/F6-c4-arabic-home.png) |
| F8-c1 With no network the app is fully functional on defaults; malformed blob falls back | SKIP |  | the simulator shares the Mac's network (no airplane mode); criteria_test F8 c1 + logic_test cover the fallback |
| F8-c2 Values are clamped to their documented ranges | BLOCKED |  | needs a hosted config with out-of-range values; logic_test clamping |

## Regressions
None. The previous report (b26919b) failed at F0 and blocked everything else; F0 now passes.

## Findings
- The simulator was shared: another session was driving its own app on the iPhone 17 Pro, so this drive moved to a dedicated iPhone 17 Pro Max. One tap from this run, at (275, 640), landed on the iPhone 17 Pro, inside the other session's piglet app, before every touch was pinned to a device.
- The today label stops at the goal ("Today 50/50" with 60 boops today, test-drive/20261007-1259/F5-c5-relaunch-boop-tab.png). This is the code's choice (`math.min(today, goal)`) and the SPEC says nothing either way. Noting it only.
- The BLOCKED rows are criteria a simulator cannot reach: timing under a second, a clock change, VoiceOver, editing the live config. Each names the automated test that asserts it.

## Next for /build
Nothing — no FAIL rows.
