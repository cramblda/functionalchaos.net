# AI.MD — Notes & Memory for functionalchaos.net

Working notes for AI assistants (and humans) on this repo. Keep it current: add decisions, gotchas and
findings as we go. The to-do list lives in [TODO.MD](TODO.MD).

## Working agreements

- **David does all git writes**: commits, pushes, pulls, tags, branches. AI may use read-only git
  (`status`, `diff`, `log`, `show`) for diagnosis.
- **No AI-drafted upstream contributions**: the Sculpin and Icelus projects don't accept AI-generated code
  or bug reports.
- `CLAUDE.md` only contains `@AI.MD`, so Claude Code loads this file every session. Keep notes here, not
  in `CLAUDE.md`.
- Keep `TODO.MD` up to date as work moves: In-Progress → Complete, new findings → Backlog.
- `TODO.MD` should stay simple and easy for a human to read.

## What this is

Personal blog for David Cramblett at https://functionalchaos.net, built with
[Sculpin](https://sculpin.io), a PHP static site generator (Twig templates + Markdown).
It was started in May 2017 from the Sculpin blog skeleton. Most posts and content date from 2017.

## Hosting & deploy (as of 2026-10-17)

- Hosted on the FC home Kubernetes cluster (`kctl-fc`), namespace `functionalchaos`, behind Envoy Gateway
  (which terminates TLS). The image is an unprivileged nginx serving the Sculpin output on :8080.
- `.docker/nginx/Dockerfile`: multi-stage. Stage 1 is `php:8.5-cli-alpine` + Imagick + composer, which
  runs `sculpin generate --env=prod`. Stage 2 is `nginxinc/nginx-unprivileged:1.28-alpine`.
- `bin/deploy.sh prod`: build → tag → push to Harbor (`registry.functionalchaos.net`) → bump the image tag
  in `.k8s/fc-prod-nginx-deployment.yaml` → apply → wait for the rollout. **The manifest's image tag is the
  version source of truth.** Prod needs a clean master and a typed confirmation, so David runs it.
- Current deployed version: **v1.1.0** (2026-10-18: Sculpin 4 alpha, Bootstrap 5 / FA7 / highlight.js 11).
- `photos/` (~6.4 GB, includes an old PHP gallery) and `pe7700/` are **not in git**. They live on the
  `fc-content` Longhorn volume (RWO) mounted at `/srv/content`. README has the one-time load steps.
- Cluster-level pieces (pull secret, Gateway listeners, TLS cert) belong to `~/projects/fc-k8s-cluster`.
- DNS: the apex A record comes from pfSense DDNS. `www` is a CNAME that ExternalDNS creates in Cloudflare
  from the DNSEndpoint in the manifest.
- The old `w5` rsync and S3 publish scripts were removed on 2026-10-17. Those hosting paths are retired.

## Build locally

```bash
composer install
vendor/bin/sculpin generate --env=dev                 # → output_dev/ (includes drafts)
vendor/bin/sculpin generate --env=prod                # → output_prod/
XDEBUG_MODE=off composer sculpin-watch               # dev server at http://localhost:8008 (8000 is taken by symfony serve)
docker compose -f docker-compose-prod.yaml up --build # prod image preview at http://localhost:8888
```

- Local machine: PHP 8.5 (Homebrew, has Xdebug, so failures print huge stack traces; use
  `XDEBUG_MODE=off`), Composer 2.10. Docker also uses PHP 8.5. Builds are clean, with no deprecations.
- ⚠️ **Thumbnails are only correct with Imagick** (see Findings). Imagick was installed locally via pecl on
  2026-10-17. If `php -m` ever stops listing `imagick` (e.g. after a Homebrew PHP upgrade), local
  thumbnails break. Reinstall with `pecl install imagick`.
- `app/config/sculpin_site.yml` and `sculpin_kernel.yml` are now in git (they hold no secrets). Before
  2026-10-17 they were gitignored.

## Repo map

| Path | What |
|---|---|
| `app/config/sculpin_site.yml` | `site.*` vars: title, url, disqus shortname, instagram token_url |
| `app/config/sculpin_kernel.yml` | Post permalinks: `blog/:year/:month/:day/:filename/` |
| `app/SculpinKernel.php` | Registers the Icelus bundle (the `thumbnail()` Twig function → `_thumbs/`; uses Imagick, else GD) |
| `source/_layouts/` | `base` → `default` (sidebar, Instagram, footer) → `page` |
| `source/_views/post.html` | Post template: OG tags, share buttons, Disqus, prev/next nav |
| `source/_partials/` | `post_card.html` (summary card used by the archive, tag, category and post next/prev lists) and `pagination.html` (Newer/Older buttons) |
| `source/_posts/` | Posts. Two are skeleton-era drafts (2012, 2013); two are real (2017 new blog, 2017 Mt Hood) |
| `source/index.html`, `blog.html` | Home (paginated, 3 per page, uses `---more---` excerpts) and the post archive |
| `source/blog/{tags,categories}/` | Tag and category index generators |
| `source/images/site/david-cramblett.jpg` | Sidebar profile photo, 400×400 shown at 200px (see "Profile photo" below) |
| `source/js/` | `navbar.js` (mobile menu toggle), `instafeed.min.js` + `instagram-feed.js` (token from instant-tokens.com) |

## Front-end stack (since 2026-10-18)

All from cdnjs with SRI `integrity` hashes, loaded in `base.html` (highlight.js JS in `default.html`):

- **Bootstrap 5.3.8**, CSS only. There is **no jQuery and no Bootstrap JS**: the mobile menu toggle is
  `source/js/navbar.js` (about 10 lines, toggles `.show` on `#navbar`).
- **Font Awesome 7.3.1** (`fa-brands` / `fa-solid`). FA7 icons are fixed-width (1.25em) by default, so
  inline icons use `fa-width-auto`. The X icon is `fa-brands fa-x-twitter`.
- **highlight.js 11.11.2**, GitHub theme, `hljs.highlightAll()`. The 2017 vendored copy in
  `source/components/` (with its own package.json) was deleted.
- To update a library: bump the version in the URL **and** replace the `integrity` hash. Get both from
  `https://api.cdnjs.com/libraries/<name>?fields=version,sri`. With a wrong hash the browser refuses to
  load the file.

**Keeping the Bootstrap 3 look.** The top of `style.css` restores BS3's 14px Helvetica typography, heading
sizes, links underlined only on hover, 750/970/1170 containers, 30px gutters, gray `pre`/pink `code`, the
navbar-default look, and `.btn-default` / `.img-responsive` (BS5 dropped both; posts still use
`{.img-responsive}`). Gotchas:
- Breakpoint names shifted: BS3 `xs/sm/md/lg` = BS5 `(none)/md/lg/xl`, so BS3 `col-md-8` is BS5 `col-lg-8`.
- In BS5, *every* child of `.row` gets gutter padding, and columns get none outside a `.row`.
- BS5 utilities (`text-end`, `d-none`, …) use `!important`, so use responsive utilities
  (`text-center text-md-end`) instead of custom overrides.
- Verified 2026-10-18 by screenshot comparison (puppeteer at 1440/800/390px, 9 pages): desktop and tablet
  are within about 0.4% of the BS3 site. Intentional differences: highlight.js's newer GitHub colors,
  code wrapping at word boundaries on phones, and tag/category cards hiding the thumbnail on phones
  (previously 111px of sideways overflow).

**Caching (since 2026-10-18).** nginx serves CSS/JS/images with `expires 7d`, so local CSS/JS links carry
`?v={{ site.calculated_date|date('U') }}` (the build time, which changes every build). HTML (and the feed and
sitemap) get `Cache-Control: no-cache`, so browsers revalidate via ETag and pick up new stamps right
away. Before this, returning visitors kept the old `style.css` after the v1.1.0 deploy. **Any new local
CSS/JS link needs the same `?v=` stamp.**

## Profile photo

The sidebar circle uses `source/images/site/david-cramblett.jpg`, which replaced Gravatar on 2026-10-17. It
was made from David's 2025 headshot (1613×2016, sRGB, in `~/Pictures`) with a hand-picked square crop. A
plain center crop cuts off the head. David approved this framing:

This repo is **public**, so the source file's real name (it identifies David's employer) isn't recorded here.

```bash
magick ~/Pictures/<2025-headshot>.jpg \
  -crop 1600x1600+13+0 +repage -resize 400x400 -strip -interlace Plane -quality 85 \
  source/images/site/david-cramblett.jpg
```

## Sculpin upstream status (checked 2026-10-17)

- After years of inactivity, upstream is active again (mostly by beryllium, the Icelus author).
- Releases: **3.3.0** (2026-07-19), **3.3.1** (2026-07-24: PHP ≥8.1, Symfony 6.4, Twig 3),
  **4.0.0-alpha2** (2026-07-25), **4.0.0-alpha3** (2026-09-25: PHP ≥8.5, Symfony 7.4, Twig ≥3.29,
  in-browser editor, and a content-type `use` option).
- Branches: `main`, `3.3.x-dev`, `4.0.x-dev`.
- **This repo (since 2026-10-17)**: `sculpin/sculpin ^4.0@alpha` (**4.0.0-alpha3**) and
  `beryllium/icelus ^4.0@alpha` (**4.0.0-alpha2**, which drops imanee). It requires `php ^8.5`, with
  `minimum-stability: stable` + `prefer-stable`, so only these two packages are alpha and every other
  dependency is a tagged release (Symfony 7.4, Twig 3.30).
- Before that: `"dev-main as 4.0.x-dev"` with `minimum-stability: dev`, which put every package on a dev
  branch.
- Upgrade results: rendered HTML is identical to the old build. Thumbnail files are now `.jpeg` instead of
  `.jpg`, and the filenames change on their own, so nothing needs editing.

## Findings / known issues (2026-10-17 survey)

- **Icelus 4.0.0-alpha2 GD backend bugs** (still unfixed upstream on `main` as of 2026-10-17). Sculpin
  and Icelus don't accept AI-generated code or bug reports, so AI must not draft upstream issues or PRs.
  Reporting upstream is David's call.
  1. Crop mode: `GdWrapper::thumbnail()` passes the full source width/height to `imagecopyresampled`
     along with a non-zero `srcX`/`srcY` offset. It reads past the image edge, which leaves black bars:
     up to 48px on the 240×160 archive thumbs and 2 to 11px on the headers.
  2. Fit mode (`crop=false`): `ThumbnailMath::calculateResizeXY()` uses `destHeight / srcRatio` where it
     should use `destWidth / srcRatio`, and `destWidth * srcRatio` where it should use
     `destHeight * srcRatio`. The New Blog header came out 750×171 instead of 750×321.
  - The Imagick path uses native `cropThumbnailImage` / `thumbnailImage(bestfit)` and is correct, so the
    Docker image installs Imagick.
- Timezone (fixed 2026-10-17): the Dockerfile sets PHP `date.timezone = America/Los_Angeles` to match
  local PHP. Before that, Docker builds (including v0.1.x) used UTC, so dates carried `+00:00`.
- **Instagram feed**: uses Instant Tokens (a paid service: $6.95/mo or $60/yr, and David has an account).
  Their `token.js` defines `InstagramToken`, and the vendored `source/js/instafeed.min.js` is their
  Instafeed v3 fork, which calls `graph.instagram.com/v21.0` (the current Instagram API; it matched their
  CDN copy on 2026-10-17). The token URL lives in `sculpin_site.yml` → `instagram.token_url`. The section
  is hidden until photos render, so a dead token hides it. **Fixed 2026-10-17**: the site had an old URL
  (Instagram ID `4503173559711488`, which returned "Instagram User Not Found"). Re-authorizing in the
  dashboard changes **both** the Instagram ID and the `userSecret`, so always copy the whole URL. A wrong
  secret returns 403 "Invalid User Secret".
- Instant Tokens **domain controls** are on (2026-10-17). They match the browser's full origin, so entries
  need a scheme (and a port for local): `https://functionalchaos.net`, `https://www.functionalchaos.net`,
  `http://localhost:8008`. A bare `functionalchaos.net` is refused. The Docker preview on
  `localhost:8888` isn't allowed, so its feed stays hidden unless that origin is added. Browsers that strip
  the Referer also get no feed, which is harmless since it hides itself.
- Instant Tokens' dashboard **"refresh secret"** rotates the `userSecret`, which breaks the script URL until
  `sculpin_site.yml` is updated. It is *not* a token refresh, and the dashboard has no manual token refresh.
- `sculpin generate --watch` does **not** reload `app/config/*.yml`. Restart the dev server after editing
  config.
- Instagram tiles: Instagram allows portrait posts, so `img.instafeed` uses `aspect-ratio: 1/1` +
  `object-fit: cover` to keep the row square.
- **X/Twitter**: the home sidebar timeline was **removed** on 2026-10-17, along with the `home` layout that
  only existed for it (index and blog now use `default`). X only renders embedded timelines for logged-in
  viewers whose browser allows third-party cookies, and its syndication endpoint returned 429. David
  doesn't really use X. Kept: the X profile icon in the sidebar, and the post share button, which now goes
  to `x.com/intent/post?url=…&text=…`.
- **Facebook share** (fixed 2026-10-17): the dead FB JS SDK v2.11 + `FB.ui` share (which also passed a
  relative URL) was replaced with a plain `facebook.com/sharer/sharer.php?u=…` link. No SDK and no app ID,
  so `facebook.appid` was removed from `sculpin_site.yml`.
- **Post share tags** (fixed 2026-10-17, `source/_views/post.html` `head_meta`): absolute `og:url` and
  `og:image` (the post's header thumbnail), `og:title` = post title, and `og:description` + `description`
  = text before `---more---` (stripped, max 200 chars). Also `og:type=article`, `article:published_time`,
  and `twitter:card`. Check previews with Facebook's Sharing Debugger after deploys.
- Removed 2026-10-17: the googlecode html5shim (IE<9) and the Universal Analytics `analytics.js` snippet.
  UA stopped processing data in 2023, and the snippet only rendered if `google_analytics_tracking_id` was
  set, which it never was. The site has **no analytics** now. Disqus loads (seen in a headless screenshot
  2026-10-17) and should be kept.
- Live site: `/photos/www/` and `/pe7700/` return 404. Either the content volume hasn't been loaded yet, or
  there's no `index.html` (the gallery is PHP and isn't served). Unverified.
- Robots (fixed 2026-10-17): `base.html` now defaults to `index, follow`. Before that the default was
  `noindex`, which hid the home page and About. Tag pages, category pages and `404.html` override it with
  `noindex`, and `robots.txt` also disallows `/blog/tags/` and `/blog/categories/`. `sitemap.xml` lists
  the home page, `/blog/`, `/about/` and all posts.
- Not bugs: the Mt Hood post's header is `2012-12-14-a-draft-post.jpg`, which is David's Palmer lift photo,
  shared with the sample draft. The draft posts (2012 sample, 2013 syntax highlighting) are **intentional**
  samples for checking layout in dev. Drafts are skipped in prod builds, so don't delete them.

## Decisions log

<!-- Date — decision — why -->
- 2026-10-17 — Created AI.MD (this file) and TODO.MD to track context and work.
- 2026-10-17 — Go with Sculpin **4.0 alpha** (not 3.3.1 stable). David wants to try it and see how it goes.
- 2026-10-17 — Use **Imagick** in the Docker build, because Icelus 4's GD path is broken (see Findings).
- 2026-10-17 — Commit `sculpin_site.yml` / `sculpin_kernel.yml`. They hold no secrets, since the Disqus
  shortname and FB app ID are already public in the HTML.
- 2026-10-17 — Removed `publish.sh`, `s3-publish.sh` and `s3.conf.dist`. w5 and S3 hosting are retired.
- 2026-10-17 — **Keep** Instagram, Facebook share and Disqus, and fix whatever is broken.
- 2026-10-17 — **Removed** the X timeline widget. It's unreliable for visitors, and David doesn't really
  use X. The X profile icon and share button stay.
- 2026-10-17 — Keep the current visual design for now. Modernize the code underneath it.
- 2026-10-17 — Moving `photos/` and `pe7700/` onto the content volume is on hold (David's call).
