# ASO — Boop!

Measured 2026-10-06/07 with applyra (`inspect_keyword`, `check_metadata`). T = traffic
score, D = difficulty, both 0–100 **estimates**. T8 is the floor (no measurable demand).
The final volume check is Apple Search Ads (owner, behind login) — see the ASA list at
the bottom.

## Why this works: the token

`boop` is a typed token, the same pattern as OuO's `owo` (T96 × 17 countries):

| Storefront | `boop` T / D | Top-20 shape |
| --- | --- | --- |
| US | 84 / 42 | scatter of unrelated "Boop" apps (travel, budget, parenting, Betty Boop stickers, Boop: World) — **no creature app** |
| GB | 84 / 41 | same scatter |
| SA | 84 / 52 | same scatter |
| BR | 84 / 76 | |
| DE | 84 / 73 | |
| JP | 81 / 77 | |

The exact name "Boop" is taken (an unrelated app), so the store name starts with
**"Boop!"** and the word stays the first token of the title in every locale. Collisions
checked: "Boopie", "Boopy.io", "Nosey Boopers" (4 ratings), "Boop Pet" (2 ratings) — none
is an animal tap game with traction.

## Supporting keywords (measured)

| Store | Keyword | T / D | Use |
| --- | --- | --- | --- |
| US | snoot | 62 / 41 | title — SnootBooper sits at #7, otherwise open |
| US | squishy | 74 / 57 | title |
| US | kawaii | 96 / 67 | subtitle |
| US | cute games / cute game | 63 / 54, 54 / 56 | subtitle (`cute` + `game`) |
| US | cute animals | 54 / 63 | subtitle |
| US | satisfying | 68 / 66 | keywords — Antistress / Satisgame top; KEI 1.03 |
| US | relaxing games | 50 / 65 | keywords |
| US | stress relief | 48 / 76 | keywords (meditation giants hold the top; long-tail only) |
| US | fidget | 76 / 80 | keywords (hard; long-tail with "fidget pet") |
| US | squishy pet | 25 / 34 | free combo from title |
| US | boop game | 11 / 37 | free combo |
| DE | kawaii | 73 / 44 | keywords "cute" via en-GB + subtitle "Kawaii" — KEI 1.66 |
| DE | süße spiele | 68 / 51 | title "Süße" + keywords "spiele" |
| JP | 癒し | 100 / 60 | subtitle |
| JP | ぷにぷに | 100 / 61 | title — **⚠ navigational**: mostly 妖怪ウォッチ ぷにぷに seekers; small apps (ぷにコレ帳 #20) still rank, so it's a cheap long-tail, not a promise |
| BR | bichinho virtual | 63 / 42 | subtitle |
| BR | jogos fofos | 25 | title "Fofos" + keywords "jogos" |
| MX | mascota virtual | 60 / 55 | keywords "mascota,virtual" |
| MX | juegos lindos | 25 | keywords |
| SA | لعبة حيوانات | 25 / 33 | subtitle — top-20 is wild-animal sims, nothing cute |
| SA | العاب كيوت | 25 | keywords "العاب,كيوت" |
| SA | حيوانات كيوت | 8 / 20 | floor — kept only because it's the natural title phrase |
| FR | jeux mignons | 10 | weak; FR is a language-coverage locale, not a target |

Dropped on purpose: `virtual pet` (T28, owned by Tamagotchi-likes), `cute pet` (T38/D61),
`kids` anything (Kids-category rules — Boop ships as Games › Casual, 4+, not "Made for Kids").

## Metadata — every field passed `check_metadata` (valid, no warnings)

Title ≤ 30 · Subtitle ≤ 30 · Keywords ≤ 100 (UTF-16), no spaces, no repeats of title words.

### en-US (primary)
- **Name:** `Boop! Squishy Snoot Pets` (24)
- **Subtitle:** `Cute Kawaii Animal Tap Game` (27)
- **Keywords:** `satisfying,antistress,relaxing,games,fidget,stress,relief,calm,cozy,nose,critter,collect,adorable` (97)

### en-GB (indexed in SA alongside Arabic, and in many EU storefronts)
- **Name:** `Boop! Squishy Snoot Pets`
- **Subtitle:** `Kawaii Critters to Poke & Hug` (29)
- **Keywords:** `cute,animals,pet,virtual,tap,bunny,panda,dragon,hippo,jelly,mochi,fidget,relax,satisfying,games` (95)

### ar-SA
- **Name:** `Boop! حيوانات كيوت` (18)
- **Subtitle:** `لعبة حيوانات لطيفة للتسلية` (26)
- **Keywords:** `بوب,العاب,كيوت,استرخاء,توتر,ضغط,ناعم,دبدوب,باندا,ارنب,تنين,جمع,هادئة,مريحة,فيدجت,squishy,kawaii` (95)

### de-DE
- **Name:** `Boop! Süße Knuddel-Tiere` (24)
- **Subtitle:** `Kawaii Tierspiel zum Antippen` (29)
- **Keywords:** `spiele,entspannung,antistress,stress,niedlich,haustier,virtuell,sammeln,fidget,nase,squishy,cute` (96)

### ja
- **Name:** `Boop! ぷにぷに鼻タッチ` (14)
- **Subtitle:** `癒しのかわいい動物ゲーム` (12)
- **Keywords:** `癒し系,ペット,育成,暇つぶし,ストレス解消,もちもち,ふわふわ,コレクション,カワイイ,もふもふ,タップ,スクイーズ,癒やし,うさぎ,パンダ,ドラゴン,クラゲ,ゆるかわ,つんつん,ミニゲーム` (96)

### es-MX (also indexed in the US storefront — free extra English-store words)
- **Name:** `Boop! Mascotas Adorables` (24)
- **Subtitle:** `Juego kawaii de animalitos` (26)
- **Keywords:** `mascota,virtual,lindos,juegos,tiernos,antiestres,relajante,squishy,fidget,nariz,coleccion,animales` (98)

### es-ES
Same as es-MX (Spain storefront).

### fr-FR
- **Name:** `Boop! Animaux Trop Mignons` (26)
- **Subtitle:** `Jeu kawaii anti-stress` (22)
- **Keywords:** `jeux,mignon,relaxant,antistress,stress,animal,virtuel,compagnon,collection,squishy,fidget,nez,calme` (99)

### pt-BR
- **Name:** `Boop! Bichinhos Fofos` (21)
- **Subtitle:** `Bichinho virtual kawaii` (23)
- **Keywords:** `jogos,fofinhos,animais,antiestresse,relaxante,squishy,fidget,nariz,colecao,mascote,pet,calmo,jogo` (97)

## Promotional text (170, editable without review)

> Twelve squishy critters are waiting for a boop. Tap the snoot, chain combos, keep your daily streak — no ads, no purchases, just happy little noses.

## Description (en-US)

```
Boop the snoot! 👉🐾

Boop! is the tiniest, happiest game on your phone. Tap a squishy little critter right on the nose and watch it giggle, wobble and blush. Keep booping to build combos, make it sneeze, and fill your daily boop ring.

TWELVE CRITTERS TO BEFRIEND
Start with Mochi the bunny and unlock new friends as your boops add up: a chick, a panda, a frog, a baby hippo, a cloud lamb, a seal, a hamster, a puppy, a jellyfish, a leaf sprite — and one very rare baby dragon. Every critter has its own voice, its own squish and its own favourite way to be booped.

HOW TO PLAY
• Boop the nose — every boop counts
• Chain boops for a Boop-a-doop, a Snoot Storm or a MEGA BOOP
• Hold to give a hug, drag to squish
• Hit your daily goal to keep your streak going
• Try Boop Rush: 30 seconds, nine bushes, as many snoots as you can — but let the sleepy ones nap!

MADE TO FEEL GOOD
• No ads. No purchases. No account.
• Works offline
• Soft sounds and gentle haptics (both can be switched off)
• Reduce Motion support for a calmer screen
• Available in English, العربية, Deutsch, Español, Français, 日本語 and Português

A perfect little break: boop for ten seconds or ten minutes, and come back tomorrow for your streak.
```

Translate the description per locale in the same batched pass as the `.arb` files
(`tools/l10n/write_translations.py` keeps the critter names consistent).

## Store setup

- **Category:** Games › Casual (secondary: Games › Simulation — keep it out of Entertainment
  where OuO already ranks, so the two don't cannibalise)
- **Age rating:** 4+ (no ads, no web, no UGC)
- **App Privacy:** Data Not Collected (no SDKs; the only network call is a GET of a public
  JSON file)
- **Screenshots:** 6.9" set, 5 frames — see `screenshots/screens.yaml`. Frame 1 headline
  must contain the word **Boop** (OCR'd caption text helps conversion, not indexing).

## Cross-promotion

OuO ranks in SA Entertainment and #7 for `حيوانات كيوت`. After Boop ships, add one
"More from us" line in OuO's settings pointing at Boop (OuO is the owner's audience).

## ASA verification list (owner — Apple Search Ads, manual)

Check search popularity (1–5 dots) in **US, GB, SA, DE, JP, BR**:

1. `boop` — the whole bet. Expect ≥ 3 dots in US/GB.
2. `boop game`
3. `snoot`
4. `squishy`
5. `kawaii`
6. `satisfying`
7. SA: `لعبة حيوانات`, `العاب كيوت`
8. JP: `癒し`, `ぷにぷに`
9. BR: `bichinho virtual`
10. DE: `süße spiele`

If `boop` reads ≤ 2 dots in US, swap the en-US name to `Boop! Cute Squishy Pets` and move
`snoot` into the keywords field — `cute` (T54–63) then carries the title.
