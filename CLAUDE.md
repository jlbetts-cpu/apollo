# Working on Apollo

Read this before changing anything.

Apollo is Jayden's app. He is a product designer who drives the look and
feel through Claude Code — a session on his Mac that builds and runs it, and
a cloud session that does the design work. This file is how both know what
the other already decided.

---

## 1. Keep the Mac and the cloud in sync

Two sessions, one repo. Before editing, pull; when done, push. That is the
whole rule, and `./start.sh` / `./save.sh "what changed"` do it in one
command each so nobody has to think about git.

The branch is `main`. Nothing else matters.

---

## 2. Never commit `Config.swift`

`Apollo/Core/Network/Config.swift` holds the Supabase URL and anon key. It is
gitignored on purpose. `setup.sh` recreates it on a fresh clone by pulling it
out of git history (it was committed once, early, in `1297cf7`).

Do not `git add -f` it, do not paste its contents into a commit message, and
do not print the key in terminal output the human might screenshot.

Related, and worth fixing when there's appetite: because it *was* committed
once, the key is still reachable in history, and this repo is public. Rotating
the Supabase anon key and confirming RLS is enabled on every table — not just
`notifications` and `photo_captions`, the only two covered by
`supabase/migrations/` — is real outstanding work, not a hypothetical.

---

## 3. You cannot build this anywhere but a Mac

Apollo is a native SwiftUI iOS app. It needs macOS and Xcode. There is no
Linux or web fallback, no simulator you can shell into, no `swift build` that
will tell you the truth about a SwiftUI view.

**A consequence that matters:** an agent running in a cloud container can edit
this code but cannot compile it. If you are in that situation, say so plainly
rather than implying a change is verified. The polish pass in
`2ebc96c`/`0d1112c` was written that way and shipped one real build error
(a nested type named `Body` shadowing `ButtonStyle.Body`) that only Xcode caught.

---

## 4. The design system

**`docs/DESIGN-SYSTEM.md` is the source of truth.** Read it before building
or restyling any screen. It was measured from the Figma `Claude` section and
then simplified on purpose — where it departs from Figma, §12 says why, and
those are decisions, not oversights. If a screen needs something the doc
doesn't have, add it to the doc first.

The short version of its rules:

- **Type is a role, never a size.** `.apolloText(.name)` — eleven roles in
  `ApolloType.swift`. No `.font(.system(size:))`, no `.tracking()`, no
  `.bold()` in feature code. The `goudy*` / `sfPro` helpers are bridges for
  screens not yet rebuilt; do not use them in new code.
- **Colour is a role on an 11-step gray ramp.** Four surfaces (ground ·
  sunken · surface · raised), one hairline. There is no second hue.
- **Spacing is on the 4pt grid** (`ApolloSpace`), the screen margin is 20,
  radius follows what the thing *is* (`ApolloRadius`: photo 3 · control 10 ·
  object 20 · viewfinder 40 · capsule).
- **Glass is for floating chrome over photos only** (`.apolloGlass()`),
  never on the ground. Nothing casts a shadow except polaroids in a stack.
- **Shared components in `Components/Shared/`** are composed, not restyled.

The files, in short:

**`Apollo/Components/Theme.swift`** — every colour in the app, 44 tokens. There
are no raw `Color(red:green:blue:)` literals left in feature code, and adding
one back is a regression. If you need a colour that doesn't exist, add a named
token here rather than inlining it. `Color.black` and `.white` are still fine
for photo scrims and text over images — those are not chrome.

**`Apollo/Components/ApolloMotion.swift`** — the motion ladder:
`press` (0.10) · `state` (0.16) · `move` (spring) · `pop` (spring, looser) ·
`reveal` (0.30), plus one `reduced` curve for Reduce Motion. Name a rung; do
not invent a duration. Use `.apolloAnimation(_:value:)` over `.animation(_:value:)`
so Reduce Motion is handled for free.

**But some values are hand-tuned and must NOT be flattened into the ladder:**
the photo viewer's `snapSpring` and drag springs, the shutter's
`spring(response: 0.1)`, the camera's drag-to-dismiss, the capture review's
keyboard follow, the focus reticle, the feed skeleton's 1.5s shimmer, and the
whole polaroid develop choreography in `Features/Develop/`. These were tuned
against real gestures. Leave them.

**`Apollo/Components/ApolloPressStyle.swift`** — press feedback. Every button
gets a variant: `.apollo` (default), `.apolloIcon` (small glyphs),
`.apolloRow` (full-width rows — dims, never scales), `.apolloTab`,
`.apolloPrimary` (the commit action on a screen), `.apolloSilent`,
`.apolloMedia`. **Do not use `.buttonStyle(.plain)`** — that was the original
state of all 63 buttons and it is why the app felt dead to the touch.

**`Apollo/Components/ApolloHaptics.swift`** — `tap` · `select` · `commit` ·
`success` · `warning` · `failure`. Describe the event, don't pick a generator.
Most buttons already fire one via their press style, so only add an explicit
call for something the button itself isn't (a completed upload, a failed
request, a gesture with no button behind it).

---

## 4.5 Guest mode

`Look around as a guest` on the sign-in screen puts the whole app on the
mock repositories — no account, no network. Use it for all UI work; it is
faster and it never touches real data. `ApolloRepositories` is the one
place that decides mock vs Supabase; screens call it instead of
constructing `SupabaseXRepository` directly. Guest mode is not persisted:
relaunching returns to onboarding.

---

## 5. Warnings that are not your fault

The build prints **11 "Skipping duplicate build file" warnings** for the
notification files. They are listed both in the synchronized folder group and
explicitly in `project.pbxproj`, from when that feature was added. Xcode skips
the duplicate and carries on. Don't chase them, and don't let them mask a real
error further down the list.

If Xcode reports **"Build input files cannot be found"** for a file that
plainly exists, it's a stale build cache — usually because files changed on
disk (a `git pull`) while Xcode had the project open. Quit Xcode, then:

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/Apollo-*
```

---

## 6. How to talk to Jayden

Short. Lead with what changed and the thing that proves it. **Anything not
done goes first, on its own line** — a careful paragraph explaining a deferral
reads exactly like one explaining a fix, and he skims.

He is a designer, not an engineer, and says so. Don't hand him git incantations
to memorise; run the command yourself or point at `start.sh` / `save.sh`. When
something needs a decision, ask it as a short question with options, not as a
paragraph of context.

He is usually right when he pushes back on how something looks. "The number
says it's fine" is not an answer to "it looks wrong."
