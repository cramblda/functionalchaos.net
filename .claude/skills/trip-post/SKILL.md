---
name: trip-post
description: Turn a trip journal (voice-note transcripts, notes and photos in journal/<trip>/) into a draft blog post for functionalchaos.net in David's voice, with web-ready, metadata-stripped photos. Use when David asks to write up a trip, adventure or project, or runs /trip-post <journal-folder>.
argument-hint: <journal folder, e.g. 2026-11-mt-adams>
---

# /trip-post: write a trip post from a journal

Turn `journal/$ARGUMENTS/` into a **draft** Sculpin post. David reviews it on the dev server, asks for changes, and
publishes it himself (he does all git commits and deploys).

## Ground rules

- **The site and the repo are public.** `journal/` is private (git-ignored) and stays that way. Only the finished
  post and photos prepared by `bin/prep-photos` go into `source/`.
- Never copy original photos into `source/`. Always use `bin/prep-photos`, which strips GPS/camera metadata.
- Companions: **first names only** (as in the Mt Hood post), unless David says otherwise. Leave out anything
  personal about other people that a transcript happens to capture (health details beyond the story, family
  matters, where they live, work).
- No home location, employer or work details. Don't publish the exact location of private camps or spots David asks
  to keep quiet.
- **Don't invent facts.** Times, distances, elevations, route names and who-said-what come from the journal or
  from David. Where the story needs a detail the journal doesn't have, ask, or leave an HTML comment
  `<!-- TODO: ... -->` in the draft and list it for David.
- Never commit, push, or delete anything in `journal/`.

## 1. Gather

1. If `$ARGUMENTS` is empty or `journal/$ARGUMENTS/` doesn't exist, list `journal/` and ask which trip. If
   `journal/` doesn't exist yet, explain `./bin/new-trip <name>` and stop.
2. Read `notes.md` and **every** file in `transcripts/` (Pixel Recorder exports: `.txt`; also accept `.md`). They
   are rough voice transcripts: expect filler words, mis-heard names and out-of-order recaps. Build a timeline from
   them (day by day, or by phase for a one-day trip).
3. Photos: look in `photos/` (unzip any Google Photos `.zip` into `photos/` first). For a quick visual
   overview, make a contact sheet in the scratchpad (never in the repo), e.g.
   `magick montage -label '%f' photos/*.{jpg,jpeg,JPG,heic,HEIC,png} -auto-orient -geometry 320x240+4+4 -tile 5x <scratchpad>/sheet.jpg`
   and view it. Note which photos show what, and their order in time (file names like `PXL_YYYYMMDD_HHMMSS…`
   carry the capture time).

## 2. Propose (one round of questions, then write)

Send David a short plan before writing:

- Title options (2–3) and a one-line angle for the story.
- Post date (default: the last day of the trip) and slug, e.g. `2026-11-08-mt-adams`.
- Category (existing: `adventure`, `technology`) and tags (reuse existing ones like `climbing` where they fit).
- Header photo (shown cropped to 750×400, so pick a wide shot with the subject near the middle) and the photos
  to use in the body, with where each one goes (aim for about 4–10).
- The gaps: anything the story needs that the journal doesn't say.

Combine every question into this one message, then write the draft from his answers.

## 3. Prepare photos

```bash
./bin/prep-photos <slug> journal/<trip>/photos/PXL_…jpg=summit-ridge journal/<trip>/photos/PXL_…jpg=camp-sunrise …
```

Give each photo a short descriptive name. The output lands in `source/images/post/<slug>/`.

## 4. Write the draft

Create `source/_posts/<slug>.md`:

```markdown
---
title: <Title>
author: David
draft: true
categories:
    - adventure
image:
    url: images/post/<slug>/<header>.jpg
    width: 750
    height: 400
    scale: true
tags:
    - climbing
use:
    - posts_categories
    - posts_tags
---
<Intro: one or two paragraphs that set up the trip: why this objective, who, the hook. This is the excerpt shown
on the home page.>

---more---

<The story.>

![<Alt text: what the photo shows>](/images/post/<slug>/<name>.jpg){.img-responsive}

*<Optional one-line caption.>*
```

Notes:
- `draft: true` keeps the post out of production builds. It only shows on the dev server.
- `image.url` has **no** leading slash (Icelus thumbnails it). Inline image links **do** start with `/images/…`.
- The header image is cropped automatically (`scale: true`). Don't repeat it as the first inline photo.

### David's voice

Read `source/_posts/2017-12-15-mt-hood.md` before writing. That's the reference. In short:
- First person, conversational, candid. He shares doubts, discomfort and the reasoning behind decisions
  ("that was not the well planned lowest risk possible approach that we always attempt to follow").
- Concrete practical detail climbers care about: start times, conditions, avalanche report, gear (rope length,
  pickets, boots), route choices, total ascent and time.
- Safety-minded and respectful of partners. Light humor, often at the group's own expense.
- Plain language and short sections. No hype or marketing tone, no emoji, no "In conclusion".
- Keep his phrasing from the transcripts where it's good. Clean up grammar and filler, but don't over-polish.

## 5. Review loop

1. Build to check for errors: `XDEBUG_MODE=off vendor/bin/sculpin generate --env=dev`.
2. Tell David the preview URL: `http://localhost:8008/blog/<yyyy>/<mm>/<dd>/<slug-without-date>/` (he runs
   `XDEBUG_MODE=off composer sculpin-watch`; a new post appears without a restart). List any `<!-- TODO -->`s.
3. Revise as asked. To swap or add photos, run `bin/prep-photos` again, and delete prepared photos that are no
   longer used from `source/images/post/<slug>/`.

## 6. Publish (only when David approves)

1. Remove `draft: true`. Check that no `<!-- TODO` remains: `grep -n 'TODO' source/_posts/<slug>.md`.
2. Check the photos are clean: `magick identify -format '%f %[EXIF:*]\n' source/images/post/<slug>/*.jpg` should
   print only file names.
3. Build prod to confirm it appears: `XDEBUG_MODE=off vendor/bin/sculpin generate --env=prod`.
4. Tell David what to commit (`source/_posts/<slug>.md` and `source/images/post/<slug>/`) and to deploy with
   `./bin/deploy.sh prod`. Update `TODO.MD` if the post was tracked there.
