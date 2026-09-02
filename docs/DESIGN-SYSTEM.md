# Apollo Design System

> One calm, grayscale world. The only colour is your own photos.

This is the source of truth for how Apollo looks, moves and feels. Every
value in `Apollo/Components/` traces back to a line here, and every screen
is assembled from the components in §10. If a screen needs something this
file doesn't have, add it here first, then build it — never the other way
round.

It was written against the `Claude` section of the Figma file
(`V5Wzqyca2nwllAtzeHjLnm`, node `13646:7423`) on 2026-09-02, with six
screens measured to the pixel, and then **simplified**: where the mockups
drifted (four serif families, thirteen near-black surface values, margins
of 19/20/24/25/29/30/35), this file picks one value and says why. Where it
departs from Figma it says so in §12.

---

## 0. The three laws

**Premium is subtraction.** When a screen feels wrong, remove something
before adding something. Every element has to earn its place against the
photo it sits next to.

**Nothing is random.** Every size, gap, radius, duration and weight comes
from a ladder in this file. A value that isn't on a ladder is a bug, even
if it looks fine.

**Counting is not looking.** A layout that measures correctly can still be
wrong. After every change, run it in the simulator and look — at the feed
with real photos, at the camera with a real viewfinder, at 375pt (SE) and
430pt (Pro Max) widths, and with Reduce Motion on.

---

## 1. Colour

### 1.1 The ramp

Eleven steps of neutral gray. This is the Figma `Colours` page verbatim.
There is no second hue. There will never be a second hue in the interface —
that is the product's central design decision (see the case study: ADHD
brains and saturated-colour reward loops). Photos supply all the colour.

| Step | Hex | Swift |
|---|---|---|
| 50 | `#F3F3F3` | `Color.apolloGray50` |
| 100 | `#E6E6E6` | `Color.apolloGray100` |
| 200 | `#CECECE` | `Color.apolloGray200` |
| 300 | `#B5B5B5` | `Color.apolloGray300` |
| 400 | `#9C9C9C` | `Color.apolloGray400` |
| 500 | `#838383` | `Color.apolloGray500` |
| 600 | `#6B6B6B` | `Color.apolloGray600` |
| 700 | `#525252` | `Color.apolloGray700` |
| 800 | `#393939` | `Color.apolloGray800` |
| 900 | `#212121` | `Color.apolloGray900` |
| 950 | `#080808` | `Color.apolloGray950` |

### 1.2 Roles — use these, not the steps

Text and icons take a role. The role picks the step.

| Role | Step | Use |
|---|---|---|
| `apolloPrimaryText` | 50 | Headlines, primary actions, the wins numeral |
| `apolloText` | 100 | Names, titles, body that must be read |
| `apolloTextSoft` | 200 | Orb labels, captions on glass, secondary names |
| `apolloCaption` | 300 | Captions, quotes, long secondary copy |
| `apolloSecondary` | 500 | Timestamps, "& 12 others", section labels, placeholder |
| `apolloTertiary` | 600 | Handles, sub-labels, disabled glyphs |
| `apolloMeta` | 700 | Meta that should almost disappear (time · streak) |
| `apolloFaint` | 800 | Hints, hairline glyphs |

### 1.3 Surfaces — four, not thirteen

The codebase had thirteen distinct near-blacks (`08 0a 0e 0f 11 14 18 1a 1c
1e 21 22 25`). Four are enough, and each has a job:

| Surface | Hex | Job |
|---|---|---|
| `apolloGround` | `#080808` (950) | The app. Every screen's background. |
| `apolloSunken` | `#0F0F0F` | Text-entry wells, the unread-row wash. Sits *below* the ground. |
| `apolloSurface` | `#141414` | Skeletons, thumbnails' empty state, quiet chips. |
| `apolloRaised` | `#212121` (900) | Sheets, pills, the search field, anything that floats *above* the ground. |

Separation between surfaces is by **value and hairline only**. Never by
shadow (§7).

### 1.4 Hairlines

One hairline token: `apolloHairline` = gray 200 at 20% opacity, 0.5pt.
Over the ground it reads as ~`#303030`; over glass it reads as a bright
edge catching light, which is exactly what the Figma `#CECECE @ 0.2px`
border was doing. One token, both jobs.

### 1.5 The exceptions

- `Color.black` and `.white` are still allowed for **photo scrims and text
  over photos**. Those are not chrome.
- `apolloFlashAuto` (`#E8A800`) is the one warm value in the app, and it is
  only ever the flash-auto glyph in the camera. It is a hardware state, not
  a brand colour.
- `apolloDanger` is retired from prose. Destructive actions are stated in
  words ("Delete win") in gray 700; the confirmation alert is where the
  system's red lives.

---

## 2. Typography

### 2.1 Two families

**SF Pro** — every piece of UI text. It ships with the OS, it has optical
sizes and tracking tables already tuned, and it is what the rest of the
phone is set in.

**Cormorant Garamond** — titles and headers only: anything 20pt and up.
Names, rows, captions, buttons — everything below 20pt — is SF Pro. This is
the voice of the app used sparingly, which is what makes it a voice. The mockups used four serifs (Cormorant Garamond, EB
Garamond, Libre Baskerville, Goudy Bookletter 1911) for what is one job;
Cormorant is the one used on the primary screen (the locked feed), the
most refined at display sizes, and — with lining and tabular numerals
enabled — it handles the countdown that Libre Baskerville was brought in
for. Bundled as two variable fonts in `Resources/Fonts/`, OFL licensed.

### 2.2 Weights — two per family

| Family | Weights | Why not more |
|---|---|---|
| SF Pro | Regular 400 · Medium 500 | Semibold made numerals shout. Medium at 20pt reads as confident, not loud. |
| Cormorant Garamond | Regular 400 · SemiBold 600 | Regular for ≥36pt where the strokes have room; SemiBold from 20–35. **No italic anywhere in the app.** |

### 2.3 The scale

Tracking is size-specific (Apple, *The Details of UI Typography*): large
text tightens, small text opens. These values are set in the role — never
add `.tracking()` at a call site.

| Role | Family | Size | Weight | Tracking | Leading | Use |
|---|---|---|---|---|---|---|
| `display` | Cormorant | 48 | Regular | -0.96 (-2%) | 1.0 | "Find." "Sign in." — one per screen, top-left |
| `title` | Cormorant | 24 | SemiBold | -0.48 | 1.1 | "Add a win", the viewer's name, sheet titles |
| `heading` | Cormorant | 20 | SemiBold | -0.30 | 1.15 | Album titles, the Full / Classic / New toggle |
| `name` | SF Pro | 16 | Medium | -0.32 | 1.2 | Every person's name in a row or header |
| `nameSmall` | SF Pro | 12 | Medium | 0 | 1.2 | Orb labels |
| `body` | SF Pro | 16 | Regular | -0.32 | 1.3 | Captions ("didn't want to. did it anyway."), search placeholder, buttons |
| `bodyMedium` | SF Pro | 16 | Medium | -0.32 | 1.3 | The photo-viewer title, primary pill labels |
| `caption` | SF Pro | 12 | Regular | -0.24 | 1.3 | "12 Wins", timestamps, sunset time, "& 12 others" |
| `label` | SF Pro | 10 | Regular | +0.5 | 1.0 | **UPPERCASE** section labels: TODAY · YESTERDAY · YOUR PEOPLE |
| `numeral` | SF Pro | 20 | Medium | 0 | 1.0 | Wins count in a post header. Tabular figures. |
| `countdown` | Cormorant | 40 | Regular | 0 | 1.0 | The sunset clock. Lining + tabular figures so digits don't jitter. |

Eleven roles. The codebase had 48 size/weight combinations. Anything not
in this table is a bug.

### 2.4 Rules

- **Never `.font(.system(size:))` or `.font(.custom(...))` in a feature
  file.** Roles only: `.apolloText(.name)` — it sets font, tracking, case
  and leading together. (`Font.apollo(.name)` exists for the rare place
  that needs only the font.)
- **Never `.tracking()` in a feature file.** The role owns it.
- **Never `.bold()`, `.italic()`, `.fontWeight()` in a feature file.** There
  is no italic in the app. *You* is marked by the `+` badge on its orb, not
  by a slant.
- Section labels are uppercase in the *role*, not in the string. Write
  `"Your people"`; the role renders `YOUR PEOPLE`.
- The wordmark `Apollo.` is an image asset, never typeset.

---

## 3. Spacing & layout

### 3.1 The grid

Everything sits on 4pt. Tokens: `2 4 8 12 16 20 24 32 40 48 64`.
`ApolloSpace.xs … .xxxl` in code. A value between rungs is a bug.

### 3.2 The screen

| Measure | Value | Why |
|---|---|---|
| Screen margin | **20** | Figma drifted 19–35 across screens. 20 is what the header, search field and rows already use. Photo grids are the one thing that bleeds to 0. |
| Header top | 64 from screen top (= status bar + 16) | Wordmark or `display` title sits here on every root screen. |
| Header height | 50 | Room for a 48pt wordmark or 44pt icon buttons. |
| Header → first content | 32 | |
| Section label → its content | 12 | Label is small; it belongs to what follows. |
| Content → next section label | 32 | |
| Row height | 44 minimum | Also the tap-target floor. |
| Row: avatar → text | 10 | |
| Row: text → trailing control | flexible, ≥ 16 | |
| Between pills in a row | 8 | |
| Bottom safe padding above home indicator | 16 | |

### 3.3 Photos

- The feed's two-column grid: left column 55.5% (223/402), gutter **2**,
  right column stacks 1 wide + 2 half tiles. Tiles bleed to the screen
  edge. Radius 3 on every tile (§4).
- The single-post view: photo inset **16** on both sides, radius 20.
- The viewfinder: full width, 681pt tall on a 874 screen (≈ 4:5 + chrome),
  bottom corners radius 40, top corners square under the status bar.

---

## 4. Radius

Radius follows what the thing *is*, not how big it is.

| Token | Value | What it is |
|---|---|---|
| `photo` | 12 | A photo in a grid, a thumbnail, a tiny print. Figma drew 3; on a 223pt tile that is a razor edge. |
| `control` | 14 | Anything you press that isn't a capsule: glass buttons, the search field, album cards, chips. The portfolio's control rung. |
| `object` | 20 | A physical thing: a polaroid, a single-post photo. The portfolio's card rung. |
| `surface` | 28 | The biggest surfaces: sheets, the photo viewer. The portfolio's top rung. |
| `viewfinder` | 48 | The camera's bottom corners only. It is the environment, and it leaves the ladder. |
| `capsule` | ∞ | Text buttons (Accept · Invite), avatars, the shutter, the reaction bar. |

---

## 5. Avatars, orbs and targets

### 5.1 Avatar ladder

| Token | Size | Where |
|---|---|---|
| `stack` | 16 | Overlapping reactor stack, −2 overlap, 1pt ground-coloured ring so they separate |
| `comment` | 24 | Comment rows |
| `post` | 32 | Post header (Figma 33 → 32 on the grid) |
| `row` | 44 | Every list row, the "Your people" strip |
| `orb` | 48 | The floating friends on the locked feed (Figma 46.9 → 48) |
| `profile` | 64 | Profile header |
| `hero` | 96 | Own profile, edit state |

Avatars are always circles. An avatar with no image shows `apolloSurface`
— never initials, never a glyph.

### 5.2 Tap targets

44×44 minimum, **measured** with `.frame(minWidth:minHeight:)` and
`.contentShape`, not assumed from the glyph. A 24pt icon in a 44pt frame is
the standard icon button (§10.3). The one exception is the 16pt reactor
stack, which is part of a 44pt row.

---

## 6. Iconography

Lucide, 24pt, 1.5pt stroke, rendered as template images tinted by role.
The set already in `Assets.xcassets` (bell, camera-flip, chevron-down,
message-circle-plus, smile-plus, sun, bolt, photo-stack, qr-code, settings,
share, x) is the vocabulary. Add a Lucide glyph rather than an SF Symbol so
the stroke weight matches; use an SF Symbol only for something Lucide
lacks, and match it to `.light` weight.

---

## 7. Materials, depth and shadow

### 7.1 The rule

**Chrome separates by value, hairline and translucency. Never by shadow.**
The only things that cast a shadow are *objects*: the polaroid stacks in
Find (they are prints lying on a table) and the three thumbnails beside
the shutter. A shadow is information — it says "this is sitting on
something". Nothing else in the app is sitting on anything.

Polaroid shadow: `black @ 15%, y 4, blur 6` for the front print; `black @
15%, x 4, y 4, blur 16` for the one behind it. These are the Figma values
and they are correct.

### 7.2 Glass

Glass is for **floating chrome over photos** and nowhere else: the
viewfinder's control strip, the photo viewer's close/share buttons, the
tab bar. It is never used on the ground (§1.3) — a glass surface over
`#080808` is just a lighter gray with extra GPU work.

`.apolloGlass(.control)` gives:

- iOS 26+: the system `glassEffect` in the control shape. This is the
  Liquid Glass Jayden asked for, and using the real thing is the only way
  it refracts, catches light and morphs the way the OS does.
- iOS 17–18: `.ultraThinMaterial` + `apolloHairline` at 0.5pt in the same
  shape. Looks like the Figma `backdrop-blur 8 · rgba(8,8,8,.01) · #CECECE
  0.2px`.
- Reduce Transparency on: `apolloRaised` solid + hairline.

Vibrancy: text on glass is `apolloTextSoft` (200), one step brighter than
it would be on the ground, so it survives whatever photo is behind it.

### 7.3 Scrims

Over a photo, text needs a scrim, not a heavier weight. The feed's bottom
fade is `apolloGround @ 0 → apolloGround` over 128pt. The photo viewer's
caption strip is the same gradient, 91pt. Both are hand-tuned to the
photo sizes they sit on; do not move them onto the spacing grid.

---

## 8. Motion

Read `docs/apple-design.md` (Jayden's Apple reference) before touching
anything that moves. The short version: respond on press-down, springs
for anything a finger can touch, always interruptible, hand off velocity,
enter and exit along the same path.

### 8.1 The ladder

| Rung | Value | Use |
|---|---|---|
| `press` | easeOut 0.10s | Tap acknowledgement — scale and dim on press-down |
| `state` | easeOut 0.16s | A control changing colour, opacity, selection |
| `move` | spring response 0.34 · damping 0.88 | Something moving or resizing: rows, banners, sheets settling |
| `pop` | spring response 0.28 · damping 0.68 | Something arriving with intent: reaction picker, a count ticking up, a pill |
| `reveal` | easeInOut 0.30s | Content dissolving: skeleton → loaded, phase changes |
| `settle` | spring response 0.40 · damping 1.00 | Apple's default for a repositioned object. Critically damped, no overshoot. |
| `throw` | spring response 0.40 · damping 0.80 | After a flick or drag release *only* — the small overshoot is earned by the momentum. |
| `sheet` | spring response 0.30 · damping 0.80 | Sheets and drawers. |
| `reduced` | easeInOut 0.20s | The one curve under Reduce Motion. |

Use `.apolloAnimation(_:value:)` so `reduced` is substituted for free.

### 8.2 Hand-tuned, not on the ladder — leave them

The photo viewer's `snapSpring`; the shutter's `spring(response: 0.1)`;
the camera drag-to-dismiss; the capture review's keyboard follow; the
focus reticle's 0.15; the feed skeleton's 1.5s shimmer; the polaroid
develop choreography; the sunset glow's 640ms (§8.4). These were tuned
against real gestures or real photos and the ladder would make them
worse.

### 8.3 Gesture rules

- **Press feedback is on press-down.** `ApolloPressStyle` does this. No
  button in the app uses `.plain`.
- **Drags track 1:1** from the grab point, never snapping to centre.
- **Release hands off velocity.** Use `throw`, seeded with the gesture's
  predicted end translation.
- **Anything mid-flight can be grabbed.** Never disable a view while it
  animates.
- **Enter and exit along the same axis.** A sheet that rose from the
  bottom leaves through the bottom.

### 8.4 The signature choreographies

**Sunset unlock.** The one moment the whole product is built around.
At T−0:

1. The ground glow behind the countdown swells: core `gray300 → gray50`
   over **640ms easeInOut** (hand-tuned; matches the portfolio's sky
   cross-fade and reads as light arriving, not a UI transition).
2. The countdown's last second ticks to `0:00:00` with `numericText`, then
   the digits cross-fade (`reveal`) to the single word *Unlocked* in the
   `title` role.
3. Haptic: `success`, on the same frame as the word lands.
4. After 400ms, the locked hero compresses upward (`settle`) while the
   first post rises into its place (`move`), and each orb flies to its
   owner's post header via `matchedGeometryEffect` — the friends who were
   floating become the people whose wins you're about to see.
5. Under Reduce Motion: glow swells (opacity only), word cross-fades,
   hero cross-fades to feed. No travel.

**Orb float.** Each orb drifts on its own sine: amplitude **6pt**, period
**8–12s** (never near 5s — Apple flags ~0.2Hz oscillation as vestibular),
phase offset per orb from its index. Under Reduce Motion they are still.
Tapping an orb: `pop` scale to 1.06 and back, `select` haptic, opens that
person's profile.

**Polaroid tilt.** A stack of three thumbnails beside the shutter sits at
`−12° · 4° · 17°` (Figma). Album stacks in Find sit at `2.3° · 0° · 0°`
with the back print at 50% opacity, middle at 80%. Picking a print up
(drag) rotates it toward the drag direction by up to 6° with Apple's
rotation spring (`damping 0.8 · response 0.4`); releasing uses `throw`.

**Shutter.** Press-down: inner disc scales 60 → 54 on `spring(0.1)` (hand-
tuned, keep). Fire: `commit` haptic on the same frame as the capture,
then the viewfinder dims 8% for 80ms — a shutter, not a flash.

**Develop.** The polaroid develop choreography in `Features/Develop/` is
hand-tuned and stays as it is.

### 8.5 Feedback

`ApolloHaptics`: `tap` (light impact) · `select` (selection tick) ·
`commit` (medium impact) · `success` · `warning` · `failure`. Describe the
event; the vocabulary picks the generator. Most buttons already fire one
through their press style. Add an explicit call only for a moment with no
button behind it: the sunset unlock, a finished upload, a failed request,
a snap point in a drag.

Visual, haptic and (if any) sound fire on the **same frame**. A haptic
that lands 100ms after the pixel is worse than none.

---

## 9. Reduce Motion, Transparency, Contrast

Three independent switches, all honoured:

- **Reduce Motion** → every rung becomes `reduced`; transitions become
  opacity; orbs stop; the sunset unlock cross-fades.
- **Reduce Transparency** → glass becomes `apolloRaised` solid + hairline.
- **Increase Contrast** → `apolloSecondary` text lifts one step to 400;
  hairlines go to 40% opacity.

Dynamic Type: every role is built `relativeTo:` a text style so the OS
scales it. Layouts use `minHeight`, never fixed heights, so scaled text
has room. (This is the single biggest gap in the current code and the
rebuild closes it screen by screen.)

---

## 10. Components

Each lives in `Apollo/Components/Shared/`. A feature file composes these;
it does not restyle them.

### 10.1 `ApolloScreenHeader`
The top row of every root screen. Left: the wordmark image (Feed, Camera)
or a `display` title (Find, Sign in). Right: up to two icon buttons, 12
apart. Height 50, top 64, margins 20.

### 10.2 `ApolloSectionLabel`
`label` role, uppercase, `apolloSecondary`, 12 below it to content, 32
above it from the previous block.

### 10.3 `ApolloIconButton`
24pt Lucide glyph in a 44×44 target, `apolloIcon` press style. Tinted
`apolloPrimaryText` on the ground, `apolloTextSoft` on glass. Pass
`.glass` to wrap it in the control-shape material.

### 10.4 `ApolloAvatar(size:)`
Circle, sizes from §5.1, `apolloSurface` when empty. `ring: true` adds the
1pt ground-coloured ring used in stacks.

### 10.5 `ApolloPill`
Text button. Two looks: `.solid` (`apolloPrimaryText` ground, `apolloRaised`
text — "Accept") and `.quiet` (`apolloRaised` ground, `apolloPrimaryText`
text — "Invite"). `bodyMedium`, padding 10 × 5, capsule, `apollo` press
style. Never a third look.

### 10.6 `ApolloChip`
Selectable toggle in a row: Full · Classic · New. `heading` role,
padding 10 × 5, `control` radius, hairline border; selected state draws a
2pt border in `apolloTextSoft`. `apolloTab` press style.

### 10.7 `ApolloPolaroid`
A photo in a 5pt `apolloGround` frame, `object` radius, with the small
`Apollo.` wordmark bottom-right at 80% opacity. This is what a photo looks
like whenever it is shown *whole* — the Find albums, the "Classic" viewer
mode, the develop screen.

### 10.8 `ApolloReactionRow`
The 16pt stack + "Darius & 12 others reacted" (`name` + `caption`) on the
left; comment and react icon buttons on the right. This is one component
because the mockups drew it four slightly different ways.

### 10.9 `ApolloPostHeader`
`ApolloAvatar(.post)`, `name`, `caption` handle or "12 Wins", trailing
`···`. Height 44.

### 10.10 `ApolloSearchField`
`apolloRaised` ground, `apolloHairline`, `control` radius, height 44,
search glyph 18pt + `body` placeholder in `apolloSecondary`.

### 10.11 `ApolloOrb`
`ApolloAvatar(.orb)` + `nameSmall` label 4 below, centred. Optional
`+` badge (11pt) at the avatar's bottom-right for your own orb. Floats per
§8.4.

### 10.12 `ApolloCountdown`
`countdown` role with lining tabular figures; colons in `apolloSecondary`,
digits in `apolloText`. "Wins unlock @ sunset" in `caption` above,
"7:42 PM" in `caption` below. Ticks every second with `numericText`.

---

## 11. Screens

The app is three surfaces plus the things that open over them. North is
not in scope for this pass.

### 11.1 Structure

Tab bar, three items, glass: **Camera · Feed · Find**. The app opens on
**Camera** — the case study's whole thesis is that capturing has to be the
easiest thing to do, so it is the first thing you see. Feed is the reward;
Find is the people.

The Profile lives behind your own avatar (Find → *You*), not as a tab.
Notifications live behind the bell on Feed.

### 11.2 Camera

Full-screen viewfinder, bottom corners `viewfinder` radius, rule-of-thirds
grid at `apolloHairline`. Wordmark top-left at 64; a chevron-down icon
button top-right closes it (it is presented as a cover). Under the
viewfinder, one glass strip, margins 20, height 49: flash toggle (left),
`title` "Add a win ^" (centre, opens the win picker), flip (right). Below:
the shutter (80 ring, 66 disc, `apolloText`) centred, and the three-print
thumbnail stack (37×39 each, `photo` radius, tilts per §8.4) at the right
margin, which opens the day's captures.

Flash states: off (`apolloTertiary`), on (`apolloText`), auto
(`apolloFlashAuto`).

### 11.3 Feed — locked

Wordmark + bell. Then the hero, 478pt tall: a radial ground glow anchored
bottom-centre (`gray300 100% → gray500 75% → gray600 50% → gray800 25% →
ground 0`), blurred 2pt. Over it, `ApolloCountdown` centred, and six
`ApolloOrb`s scattered on a loose ring around it (positions from Figma,
with ±6pt float). A hairline closes the hero.

Below, `ApolloSectionLabel` "Yesterday", then yesterday's posts as in
§11.4 — so the screen is never empty, and the reward is always visible
one scroll down.

### 11.4 Feed — unlocked

`ApolloSectionLabel` "Today", then posts. Each post: `ApolloPostHeader`,
the two-column photo grid (§3.3), caption in `body` at margin 24 with the
comment/react buttons on its right, `ApolloReactionRow`. Posts are
separated by 32, no rule.

A post with a single photo shows it inset 16 at `object` radius — the
"Morning Run" screen — with the caption and buttons directly under it.

### 11.5 Post — full

Tap any photo. The photo fills the screen to 766pt with `object` radius;
the owner's `title` name top-left, a glass close button top-right. Under
it: `ApolloChip` row Full · Classic · New (Full = as shot; Classic = inside
an `ApolloPolaroid`; New = the warm grade), the caption in `bodyMedium`
with its time in `caption` beneath, react and share glass buttons on the
right. Swipe down to dismiss along the same axis it rose.

### 11.6 Find

`display` "Find." + QR and settings icon buttons. `ApolloSearchField`.
Then, each under its `ApolloSectionLabel` with the §3.2 rhythm:
**Requests** (row: avatar 44, `name`, `caption` source, `ApolloPill`
Accept + an × icon button), **Your people** (horizontal strip of avatar
44 + `name` below, *You* first in italic), **Albums** (two-up
`ApolloPolaroid` stacks 155×205 at 24 apart, `heading` title + `caption`
date range under each), **Invite friends** (rows with a quiet Invite
pill).

### 11.7 Sheets

All sheets: `apolloRaised` ground via `presentationBackground`, `object`
radius, no drag indicator (the drag pill is drawn by the sheet itself at
`apolloGray800`, 36×5, top 8). Detents from the content, not from a fixed
fraction.

---

## 12. Decisions and departures from Figma

Logged so the next person knows they were choices, not accidents.

| Figma | System | Why |
|---|---|---|
| 4 serif families | Cormorant Garamond | One voice. Lining numerals cover the countdown. |
| SF Pro Semibold on numerals | Medium | Semibold made "12" the loudest thing on the screen. |
| Orb labels at 10pt serif | 12pt SF Pro Medium | Serif is for ≥20pt only (Jayden, 2026-09-02). |
| Names in Cormorant SemiBold 16 | SF Pro Medium 16 | Same rule. Serif is a voice, not a body face. |
| Photo tiles at radius 3 | 12 | Read as prints, not razor edges. Portfolio feel. |
| Controls at radius 10 | 14 | Portfolio's control rung. |
| Viewfinder corners 40 | 48 | "A bit more curve for the camera." |
| Margins 19 / 24 / 25 / 29 / 30 / 35 | 20 | One margin. Grids bleed to 0. |
| 13 near-black surfaces | 4 | Ground · Sunken · Surface · Raised. |
| Avatars 33 / 46.9 | 32 / 48 | On the grid. |
| Search field border `#6B6B6B` 1pt | `apolloHairline` 0.5pt | One hairline everywhere. |
| Hairline `#CECECE` 0.2px on glass | `apolloHairline` 0.5pt | 0.2px cannot be drawn on a 2× or 3× screen; 0.5pt is one device pixel. |
| Camera-thumb border `#D9D9D9` | none | A third gray that was on no ramp. |

### Decisions taken 2026-09-02

Asked and answered by Jayden. These are settled.

1. **No leaderboards.** The unlocked feed is chronological. The reward is
   seeing your people, not ranking them; the Figma note's Most Wins /
   Biggest Wins / Athletic Freak sections are not built. If a spotlight is
   ever wanted it is one quiet polaroid, no numbers, no ordering.
2. **Illustrations live in empty states only.** Empty feed, no wins yet, no
   friends yet. Ink on the ground, one colour, so the grayscale rule holds.
   Until the art exists the slots are designed and left empty — no
   placeholder glyphs.
3. **Three tabs: Camera · Feed · Find.** The app opens on Camera. Home is
   gone. Profile lives behind your own avatar in Find; notifications behind
   the bell on Feed.

---

## 13. Build status

What the spec describes versus what the code does, so the next session
starts from the truth. Update this table when you land a screen.

| Piece | Spec | Code | Notes |
|---|---|---|---|
| Colour ramp, surfaces, roles | §1 | ✅ `Theme.swift` | Legacy names kept as aliases |
| Type roles, Cormorant bundled | §2 | ✅ `ApolloType.swift` | `goudy*` / `sfPro` bridge onto it |
| Spacing / radius / avatar ladders | §3–5 | ✅ `ApolloLayout.swift` | |
| Glass | §7.2 | ✅ `ApolloMaterial.swift` | Real Liquid Glass behind `#if compiler(>=6.2)` |
| Motion ladder + Apple springs | §8.1 | ✅ `ApolloMotion.swift` | |
| Press feedback, haptics | §8.3, §8.5 | ✅ | Every button; 63 sites |
| Shared components | §10 | ✅ 12 in `Components/Shared/` | |
| Three tabs, camera first | §11.1 | ✅ `RootTabView.swift` | Profile reachable from Find's header avatar for now |
| Sunset clock | §11.3 | ✅ `Core/Sunset/SunsetClock.swift` | NOAA, coarse location, 7:42 PM fallback |
| Feed — locked hero, orbs, countdown | §11.3 | ✅ `FeedLockedHero.swift` | Orbs = you + yesterday's authors; long-press to unlock in guest |
| Feed — lock gating, unlock haptic | §8.4 (1–3) | ✅ `FeedView.swift` | |
| Unlock: orbs fly to post headers | §8.4 (4) | ⬜ | Needs `matchedGeometryEffect` between hero and `PostCard` |
| Unlock: glow swell 640ms | §8.4 (1) | ⬜ | Hero currently settles out; the swell is next |
| Feed — post card on the new components | §11.4 | ⬜ | `PostCard` still uses the pre-system views |
| Single-post "Morning Run" layout | §11.4 | ⬜ | |
| Post — full viewer, Full · Classic · New | §11.5 | ⬜ | `ApolloChip` + `ApolloPolaroid` exist; viewer not rewired |
| Camera — spec layout (strip, thumbnail stack) | §11.2 | ⬜ | Only the wordmark swap landed |
| Find — header + search | §11.6 | ✅ | |
| Find — Requests / Your people / Albums / Invite on components | §11.6 | ⬜ | No friends-list or albums API yet |
| Empty-state illustrations | §12 (2) | ⬜ | Slots not yet designed; art doesn't exist |
| Dynamic Type on rebuilt screens | §9 | ◐ | Roles scale; legacy screens still fixed |
| Guest mode | CLAUDE §4.5 | ✅ | Whole app on mocks |
