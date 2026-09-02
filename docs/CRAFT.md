# Craft

`DESIGN-SYSTEM.md` says what the values are. **This file says how to decide,
and how to see.** Read it before you touch a screen. If a screen you built
looks like generic app UI, the reason is almost always in here.

---

## 0. Why this file exists

Apollo has been rebuilt twice by agents who had the tokens, the Figma frames
and the spec in front of them, and both times it came out looking like
software rather than like Apollo. Not because the values were wrong. Because
of three failures that no amount of specification prevents:

1. **Nobody looked.** Every claim about how it looked was inferred from code.
   A cloud session cannot see a simulator, kept building anyway, and shipped
   three commits in which *every serif in the app was silently rendering as
   SF Pro*. Reading the code could never have caught it.
2. **The old app was preserved instead of replaced.** Bridge functions kept
   150+ legacy views compiling. The result was the hackathon app wearing new
   tokens. A rebuild that keeps every old view is not a rebuild.
3. **Failure was silent.** `Font.custom` with a bad name returns the system
   font. No crash, no warning. Anything that can fail quietly, will.

Everything below exists to make those three impossible.

---

## 1. What Apollo is

A calm, grayscale room where your friends' small wins appear once a day, at
sunset. The photos are the only colour, the only texture, and the only thing
that should attract the eye. Every pixel of interface is in service of a
photograph and should behave like it knows that.

The feeling to design for is **the end of the day**. Not energy, not urgency,
not celebration. Quiet, earned, warm-because-of-the-photos. If a screen feels
like it wants something from the user, it is wrong.

The competition is not Instagram. It is a well-made physical object — a
Leica, a linen-bound notebook, a Braun clock. Things that are mostly nothing,
made of one material, with one perfect detail.

---

## 2. The four laws

**Subtraction beats addition.** When a screen feels wrong, the fix is almost
always removing something, not adding something. Border, background, label,
icon, divider, shadow, gradient — in that order of suspicion. A screen is
finished when removing one more thing would break it.

**Looking beats counting.** A layout that measures correctly can be
horrendous on screen. No claim about appearance is valid without a screenshot
you actually opened. "The spacing is on the grid" is not an answer to "it
looks wrong."

**One thing is the most important thing.** On every screen, name it before
you build. Everything else must visibly step back. If two things are equally
loud, neither is the subject and the screen reads as a form.

**The photo is the hero, always.** Chrome recedes. If interface and
photograph compete, the interface loses — make it quieter, smaller, or
delete it.

---

## 3. The looking protocol

Non-negotiable. This is the single highest-value rule in the file.

**A session that can run the simulator must screenshot before claiming
anything about appearance.**

For each screen you change:

1. Build, run, navigate to it (guest mode; §4.5 of CLAUDE.md).
2. Screenshot it: `xcrun simctl io booted screenshot ~/Desktop/apollo-<screen>.png`
3. **Open the image and look at it.** Then open the Figma frame beside it.
4. Compare in this order — the order in which the eye notices:
   - Overall weight: is one thing clearly the subject?
   - Vertical rhythm: do groups read as groups?
   - Left edges: does one alignment run the screen?
   - Type: does anything look bolder/lighter/wider than intended?
   - Optical detail: anything centred that looks off-centre?
5. Only then say whether it is right.

Check every screen at **375pt** (iPhone SE) and **430pt** (Pro Max), and once
with Reduce Motion on. A layout that only works at one width is not done.

**A session that cannot run the simulator** — the cloud one — must say so in
the same message, in its own line, every time it makes a visual change. It
may write code and specs. It may not say a screen looks right.

---

## 4. What "premium" actually is, mechanically

It is not gradients, glows, glass or shadows. Those are the things people add
when they don't know what premium is. It is four measurable properties:

**Hierarchy.** One element per screen is unmistakably first. It gets size,
weight, contrast and space; everything else gives some up. Flat hierarchy is
the number-one reason UI reads as generic.

**Rhythm.** Spacing is grouped, not uniform. Elements that belong together
sit 4–12 apart; groups sit 32 apart. The *ratio* between those two numbers is
what the eye reads as "considered". Uniform 16 everywhere reads as a
template, even though every value is on the grid.

**Alignment.** One left edge running the full height of a screen does more
work than any decoration. Centring is for one thing at a time — a shutter, a
countdown — never for a column of content.

**Optical correction.** The last 5% and the whole difference between "fine"
and "made". Mathematically centred is frequently not optically centred:

- A chevron or triangle centres on its optical mass, not its bounding box.
- Text in a pill needs less bottom padding than top — the descender space is
  already there. Roughly 55/45.
- A capital-letter word next to a lowercase one aligns on the cap height, not
  the box.
- Icons next to text align to the text's cap height, not its centre.
- A circle looks smaller than a square of the same size; enlarge it ~2%.
- Round-cornered shapes stacked concentrically need matched *curvature*:
  the inner radius is the outer radius minus the gap, not the same value.

If a value is not on a ladder in `DESIGN-SYSTEM.md`, the only acceptable
reason is documented optical correction. Write the reason in a comment.

---

## 5. The slop catalogue

Machine-made UI has a signature. Every item below is something an agent
reaches for by default, and every one of them is why Apollo has read as
generic. Learn them so you stop before you do them.

| The tell | Why it happens | What to do instead |
|---|---|---|
| **Everything in a card** | A rounded rect with a border and a fill feels safe | Group with whitespace and alignment. Apollo has almost no cards — a photo, a sheet, a pill, and that is it |
| **Uniform spacing** | Every gap is 16 because 16 is on the grid | Tight inside a group, 4× that between groups. The jump is the design |
| **Everything centred** | Centring never looks broken | Left-align content. Centre only a single hero object |
| **Borders as separation** | A 1px line is the obvious way to divide | Separate by background value and space. One hairline token exists for the rare case |
| **Gray soup** | Three grays used interchangeably | Each role means one thing. If two texts are the same importance, one of them is redundant |
| **Icon plus label** | Labelling feels helpful | If the icon is unambiguous, drop the label. If it isn't, drop the icon |
| **Symmetric padding** | 16 on all four sides | Optical padding is rarely symmetric. Text needs less below than above |
| **Depth as decoration** | Shadows and glows read as "premium" | Shadow means *resting on something*. In Apollo only polaroids cast one. Glass only over photos, never over ground |
| **One radius everywhere** | 12 on every corner | Radius says what a thing *is*. A print, a control, an object and a sheet are four different things |
| **Type by size alone** | Bigger = more important | Hierarchy is size **and** weight **and** colour **and** tracking, moving together |
| **Spinner for loading** | It's the default | A skeleton in the shape of the real content. The layout should not jump when data lands |
| **Generic empty state** | An SF Symbol and "Nothing here yet" | Empty states are a designed screen with a real sentence. In Apollo they get an illustration slot (§12 of the spec) |
| **Fixed heights** | Easier to match a mockup | `minHeight`. Real names are longer than "Jayden" and text scales |
| **Same curve, same duration** | One `.easeInOut(0.3)` everywhere | Name a rung. Springs for anything a finger touches |

If you have just written a view and it contains a `RoundedRectangle` with a
`.stroke` and a fill, stop and ask whether whitespace would do the job.

---

## 6. Type craft

The ladder is in `DESIGN-SYSTEM.md` §2. What the ladder cannot tell you:

- **The serif is a voice, and voices lose power with use.** Cormorant is for
  titles and headers, 20pt and up, and there should be roughly *one* per
  screen. Two serif elements on one screen halves the effect of both.
- **Weight before size.** To make something more important, try Medium before
  you try +2pt. Weight adds presence without taking space.
- **Tracking is size-specific and already in the role.** Large text needs
  negative tracking or it reads as loose; small text needs slightly positive
  or it reads as tight. Never set it at a call site.
- **Leading is inverse to size.** Tight on a 48pt title, generous on 16pt
  body. A title at 1.4 line height looks like a paragraph.
- **Numbers that change need tabular figures**, or the layout twitches as
  they tick. Already handled in the `numeral` and `countdown` roles.
- **Never centre a paragraph.** One line, sometimes. A paragraph, never.

---

## 7. Motion craft

`docs/apple-design.md` is the full reference; read it before anything
gesture-driven. The essentials:

- **Respond on touch-down, not on release.** Any delay between finger and
  feedback destroys the sense of directness. This is handled by
  `ApolloPressStyle`; do not use `.buttonStyle(.plain)`.
- **Track 1:1 during a drag**, from the point that was grabbed. Never snap to
  centre on pick-up.
- **Hand off velocity at release.** The animation continues at the speed the
  finger was moving. This seam is what separates fluid from fine.
- **Everything is interruptible.** A user must be able to grab a moving thing
  and reverse it. Never disable input during a transition.
- **Overshoot must be earned.** Bounce is right after a flick, wrong on a
  menu that merely appeared. Default to critically damped.
- **Enter and exit along the same path.** What rose from the bottom leaves
  through the bottom.
- **Motion should say what happened**, not decorate. If an animation could be
  removed without the user losing information, remove it.

The one exception to every rule above: the values listed in
`DESIGN-SYSTEM.md` §8.2 are hand-tuned against real gestures. Leave them.

---

## 8. Material craft

- **Glass only floats over photos.** Over the ground it is a lighter gray
  with extra GPU cost. The viewfinder strip, the viewer's buttons, the tab
  bar — that is the whole list.
- **Never stack glass on glass.** Legibility collapses.
- **Text on glass goes one step brighter** than it would on the ground, so it
  survives whatever photograph is behind it.
- **Bigger surfaces read as thicker.** A sheet blurs more than a chip.
- **Fade, don't rule.** Where content meets floating chrome, use a gradient
  mask, not a 1px line.
- **Materialise, don't fade in.** Glass arriving should animate blur and
  scale together so it reads as a material, not an opacity change.

---

## 9. Before you say a screen is done

Run this list. Every item is something that has actually been wrong here.

- [ ] I have opened a screenshot of it, at 375pt and 430pt.
- [ ] I can name the one most important element, and it looks it.
- [ ] Groups are visibly grouped: small gaps inside, ~4× between.
- [ ] One left edge runs the screen. Nothing is centred that isn't a hero.
- [ ] No element has a border that whitespace could replace.
- [ ] Every colour is a role from `Theme.swift`. No literals.
- [ ] Every size, gap and radius is on a ladder, or has a comment saying why.
- [ ] At most one serif element, at 20pt or above. No italic anywhere.
- [ ] Every tappable thing is ≥44pt, measured with `.frame`, and presses.
- [ ] Nothing casts a shadow except a polaroid.
- [ ] Text is `minHeight`, not fixed height, and survives Dynamic Type.
- [ ] Reduce Motion: no travel, still legible, still gives feedback.
- [ ] Loading state is a skeleton shaped like the real content.
- [ ] Empty state is a designed screen with a real sentence.
- [ ] I could remove one more thing — and I have.

---

## 10. When you are unsure

In order:

1. **Look at the Figma frame.** It is a good visual example even where it
   drifts; §12 of the spec records every deliberate departure.
2. **Ask what Apple would delete.** Not what they would add.
3. **Ask what the photo needs.** The interface is a frame around a picture.
4. **Ask Jayden, as a short question with options.** He answers those fast
   and skims prose. He is usually right when he pushes back on how something
   looks, and "the numbers say it's fine" is not an answer to "it looks
   wrong."

Do not invent a third option, a new colour, a new weight or a new curve to
resolve uncertainty. The system is small on purpose.

---

## 11. Things that are settled

Do not reopen these without being asked.

- Grayscale interface. Photos are the only colour. No second hue, ever — this
  is a product decision about ADHD reward loops, not a style preference.
- Two families: SF Pro for interface, Cormorant Garamond for titles ≥20pt.
  Two weights each. **No italic.**
- Three tabs — Camera · Feed · Find — and the app opens on Camera.
- The feed is locked until sunset. No always-open scroll.
- No leaderboards, no follower counts, no streak shaming.
- Illustrations appear in empty states only.
- Only polaroids cast shadows.
