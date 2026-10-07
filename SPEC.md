# SPEC — Boop!

> The contract the build implements and the tests verify. A feature is done
> when its acceptance criteria pass, not when it feels done.

## One line

**Boop!** is a cozy, tactile toy: boop the snoots of squishy kawaii critters,
chase boop combos, unlock a collection of twelve critters, and play a
30-second *Boop Rush*. Offline, free, with no ads and no purchases in v1.

## Why this app (niche)

`boop` is a short token people type in every language, the same shape as `owo`,
which drives the operator's OuO. Applyra, 2026-10-06:
- US T84/D42
- SA 84
- BR 84
- DE 84
- TR 84
- JP 81

No creature/pet app embodies it: the top 20 is a scatter of unrelated apps named
"Boop" (travel, budget, parenting, networking). See
`research/niche-research/niche-scout/history/2026-10-06_rotation37-next-ouo-tokens.md`.

It must differ clearly from OuO (one reactive face) and Neko (one pixel cat)
to stay clear of Apple 4.3:
- Boop is a **collection** of twelve soft-body critters.
- It has a **combo/score loop** and a **mini-game**.
- No critter is a cat.

## Audience & tone

Teens and adults who love cute things, and kids old enough to read (rated 4+,
**not** in the Kids category). They open it many times a day for 10–60 seconds:
- a fidget
- a smile
- a streak

Tone: warm, silly, never pushy. No guilt-trip copy, no timers that punish.

## Look & feel

- **Palette.**
  - Background: cream `#FFF6EC`, with a soft radial glow behind the critter.
  - Ink: cocoa `#3B2A2A`, for outlines, eyes and text.
  - Accents: heart coral `#FF6F8E`, butter `#FFD36B`, mint `#7FD8B6`, sky `#8EC9FF`, lilac `#C7A6FF`.
- **Shape language.** Everything is round. Cards and buttons use 22–28 px radii
  with a 3 px cocoa "sticker" outline and a hard offset shadow (no blur).
- **Type.**
  - Headings: Fredoka. Body: Nunito.
  - Arabic: Baloo Bhaijaan 2 for both headings and body.
  - Japanese falls back to the system font.
- **Critters** are drawn procedurally (`CustomPainter`), never as bitmaps. That
  keeps every one crisp at any size and lets the body actually deform:
  squash, stretch, wobble, breathe.
- **Light theme only**, portrait only, iPhone only (iPad runs the iPhone layout).

## Screens

| Screen | Purpose | Entry |
| --- | --- | --- |
| Boop (home) | Boop the current critter | Launch; tab 1 |
| Critters | The collection: locked and unlocked, choose who to boop | Tab 2 |
| Boop Rush | 30-second whack-a-snoot mini-game | Tab 3 |
| Settings | Sound, haptics, motion, language, links, reset | Gear icon on Boop |

## Features

### F1 — Boop the snoot

The critter sits center stage. Tapping its **nose** is a *boop*: the body
squashes and springs back, the face goes happy (`> <`), cheeks flush, a soft
squeak plays (pitched per critter), the phone ticks a light haptic, and a heart
or "+1" floats from the tap point.

**Acceptance criteria**
- [x] A tap inside the nose hit-area increments the session and lifetime boop counters by exactly 1.
- [x] A tap on the body outside the nose does **not** count. It triggers a wobble and a giggle instead.
- [x] Dragging on the body stretches it toward the finger; releasing springs it back.
- [x] Holding 0.6 s or longer is a **hug**: eyes close and hearts stream for as long as the finger is down. It does not count as a boop.
- [x] **Idle** behavior: the critter breathes, blinks at random 2–5 s intervals, and after 30 s without input gets sleepy (half-lidded, "z z z"). The next touch wakes it.
- [x] Sound and haptics obey Settings. With both off, a boop is silent and still.
- [x] Every interactive element has a Semantics label. The critter announces "<name>. Double-tap to boop."

### F2 — Boop combos

Boops less than 1.0 s apart chain into a combo. A pill above the critter shows
the count. Each boop in a combo raises the squeak's pitch slightly, capped.

**Acceptance criteria**
- [x] Two boops within 1.0 s make combo 2; a gap of more than 1.0 s resets it to 1 on the next boop.
- [x] At combo **10, 25 and 50** a tier banner pops ("Boop-a-doop!", "Snoot storm!", "Mega boop!") with a chime and a medium haptic.
- [x] Every 30th boop in a combo makes the critter sneeze ("achoo!") with confetti.
- [x] The best combo ever is saved and shown on the Critters screen.

### F3 — Collection: twelve critters

Lifetime boops unlock critters at fixed milestones. Unlocking shows a
celebration card (the new critter bounces in, confetti, chime, "Say hi to
Pip!") with **Boop them!** and **Later** buttons.

| # | Critter | Unlocks at (lifetime boops) |
| --- | --- | --- |
| 1 | Mochi (bunny) | 0 |
| 2 | Pip (chick) | 30 |
| 3 | Bao (panda) | 80 |
| 4 | Kiwi (frog) | 150 |
| 5 | Momo (baby hippo) | 250 |
| 6 | Puff (cloud lamb) | 400 |
| 7 | Nori (seal) | 600 |
| 8 | Taro (hamster) | 850 |
| 9 | Coco (puppy) | 1150 |
| 10 | Jelly (jellyfish) | 1500 |
| 11 | Sprout (leaf sprite) | 2000 |
| 12 | Star (baby dragon) | 3000 |

**Acceptance criteria**
- [x] Crossing a threshold unlocks exactly that critter once and shows the celebration once, even across restarts.
- [x] The Critters tab shows all twelve cards:
  - unlocked: the colored critter, its name and its boop count;
  - locked: a silhouette, "???" and "N more boops".
- [x] Tapping an unlocked card selects it, saves the choice and switches to the Boop tab with it. Tapping a locked card shows how many boops remain.
- [x] Each critter has its own colors, ears, nose shape and squeak pitch. No two look alike.
- [x] A progress bar shows "Next friend in N boops", or "Everyone's here!" when all twelve are unlocked.

### F4 — Daily boops & streak

A gentle daily goal (default 50 boops, remote-tunable 10–500) shown as a ring
around the boop counter. Meeting it marks the day done; consecutive days build a
streak, shown with a small flame.

**Acceptance criteria**
- [x] The ring fills with today's boops and completes at the goal. Reaching it shows "Daily boops done!" once per day.
- [x] The streak increments when the goal is met on consecutive local calendar days. It resets to 0 if a whole day passes unmet. Meeting the goal again the same day changes nothing.
- [x] Day boundaries use local time and are testable with an injected clock.

### F5 — Boop Rush (mini-game)

30 seconds, a 3×3 meadow of bushes. Critters pop up for a short time:
- **Boop** awake ones for points.
- **Don't boop** sleepy ones (eyes closed, "z"): that breaks your rush combo and costs 2 points.
- **Golden** critters are worth 5.

Pop-ups speed up over the round. The end screen shows score, best and new-best
confetti, with **Play again**.

**Acceptance criteria**
- [x] A round lasts exactly the configured duration (default 30 s, remote 15–60). The game cannot be scored after time is up.
- [x] Booping an awake critter scores +1, a golden one +5, and +1 more per 5-hit streak. Booping a sleepy one scores −2 (never below 0) and resets the streak.
- [x] A critter that is booped or times out leaves its bush. No bush ever shows two critters at once.
- [x] The best score persists. A new best is celebrated.
- [x] Rush boops also count toward lifetime boops, unlocks and the daily goal (awake critters only).
- [x] The Rush tab can be killed remotely (`features.rushEnabled`). When off, the tab shows a friendly "Rush is resting" message instead.

### F6 — Settings

Sound, Haptics, Reduce motion (also follows the iOS setting), Language (System +
7 languages), Rate Boop!, Privacy policy, Support, Reset progress (with a
confirm dialog), and the app version.

**Acceptance criteria**
- [x] Each toggle persists across restarts and takes effect immediately.
- [x] Reduce motion removes particles, confetti and the drag stretch, but keeps a simple scale pulse so a boop still reads.
- [x] Reset clears **every** saved key: boops, unlocks, streak, best scores, selected critter, celebration flags and onboarding. The app returns to the first-launch state.
- [x] A language override switches the UI immediately. Arabic lays out right-to-left.

### F7 — First run

On first launch a pointing-hand hint bobs over Mochi's nose with "Boop the
snoot!". It disappears after the first boop and never returns (unless progress
is reset).

### F8 — Remote config (GitHub JSON)

The app fetches
`https://raw.githubusercontent.com/OuadieZerhouni/app-configs/main/boop/config.json`
at most once per 6 h, caches it, and falls back to code defaults.

**Tunables:**
- announcement (localized title/body/url, dismiss-once)
- min/latest version and a soft update prompt
- `features.rushEnabled`
- `dailyGoal`
- `rush.durationSec`
- review prompt (enabled, after N unlocks)
- privacy/support URLs

**Acceptance criteria**
- [x] With no network, the app is fully functional on defaults. A malformed blob falls back without crashing (tested).
- [x] Values are clamped to their documented ranges.

## Non-goals (v1)

- No ads, purchases or accounts.
- No analytics SDK.
- No notifications.
- No widget.
- No sharing of personal data.
- No online play.
- No cats (that is Neko's job), and no pigs (culturally sensitive for the main Saudi audience).

## Data & permissions

- **Local only:** `shared_preferences` holds boop counts, unlocks, streak, best scores and settings.
- **Network:** a single HTTPS GET of the public config JSON. Nothing is sent.
- **iOS permissions:** none.
- **App Privacy answer:** "Data Not Collected".

## Monetization

None in v1. `feature_gates.dart` keeps the no-op ads and IAP interfaces so either can be added later.

## Store

- **Category:** Games › Casual (secondary: Entertainment).
- **Age rating:** 4+. No violence, gambling, user-generated content or web browsing.
- **Keyword seeds:** boop, snoot, kawaii, cute pet, squishy, fidget, virtual pet, critters, relax, boop the snoot.
- **Privacy policy and support:** `OuadieZerhouni/app-configs/boop/PRIVACY.md` and `SUPPORT.md`.
- **Full store metadata:** see `ASO.md`.
