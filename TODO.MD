# TODO

## In-Progress

- [ ] Confirm Dependabot alert #14 (high) closes on its own: it should be from the old dev-branch `composer.lock`, and the new lock has no advisories
- [ ] Instant Tokens dashboard says "Token Needs Attention" (also flipped to "Needs subscription", though the subscription is active), but the token works (checked Oct 18). **Check on Dec 1, 2026:** if the warning is still there, reconnect, since the token expires around **Dec 16, 2026** if they never refresh it. Not critical: the feed hides itself if the token dies. Don't use "refresh secret": it changes the script URL

## Backlog

### On hold
- [ ] `/photos/www/` and `/pe7700/` return 404: waiting until the content is moved to the volume

## Complete

- [x] Move hosting to the home k8s cluster (Docker + k8s + `bin/deploy.sh`), deployed v0.1.1
- [x] Fix the :8080 redirect issue, deployed v0.1.2
- [x] Create AI.MD and TODO.MD
- [x] Switch `www` DNS record to Cloudflare-proxied
- [x] Deployed: Sculpin 4 + fixes, then front-end update as v1.1.0 (2026-10-18)
- [x] Upgrade to Sculpin 4.0.0-alpha3 + Icelus 4.0.0-alpha2; Docker image now PHP 8.5 + Imagick
- [x] Move every dependency off dev branches to tagged releases
- [x] Clean up `composer.json` (project name, author, removed dead scripts)
- [x] Put `sculpin_site.yml` / `sculpin_kernel.yml` in git so fresh clones build
- [x] Remove old publish scripts (`publish.sh`, `s3-publish.sh`, `s3.conf.dist`)
- [x] Add `.memsearch/` to `.gitignore`
- [x] Install Imagick locally so local builds make correct thumbnails
- [x] Add `CLAUDE.md` that loads AI.MD automatically
- [x] Fix the Instagram feed (new Instant Tokens URL, now set in `sculpin_site.yml`; feed hides itself if the token fails)
- [x] Instagram tiles are always equal squares (portrait posts were stretching the row)
- [x] Remove the X/Twitter timeline from the home page (X no longer shows it to most visitors)
- [x] Fix the X share button on posts (it shared nothing; now sends the post link and title)
- [x] New sidebar profile photo (2025 headshot, hosted on the site instead of Gravatar)
- [x] Twitter bird icons replaced with the X logo (sidebar and post share button)
- [x] Facebook share button: replaced the dead 2017 SDK with a plain share link (no scripts, no app ID)
- [x] Fix link-preview tags on posts (full URLs, real title, excerpt as description, header image)
- [x] Remove work references from `bin/deploy.sh` (repo is public)
- [x] Instant Tokens domain controls: only functionalchaos.net, www and localhost:8008 can load the token
- [x] Remove the dead html5shim and old Google Analytics snippet
- [x] Small template cleanup (favicon `//` paths, duplicate theme-color tag)
- [x] Search engines can index the home page, post archive and About (were `noindex`); added them to the sitemap
- [x] Remove unused `component-manager.php` (2017 leftover)
- [x] Mt Hood header image and the sample drafts checked: intentional, keeping them
- [x] Docker build uses Pacific time, so production dates match local builds
- [x] Disqus comments checked: they load on posts
- [x] Front-end update: Bootstrap 5.3.8, Font Awesome 7.3.1, highlight.js 11.11.2; jQuery removed; same look
- [x] Fix tag and category pages scrolling sideways on phones
- [x] Cache-busting: deploys show up right away for returning visitors (no stale CSS after a deploy)
- [x] Refresh bio text (About page, sidebar, footer): "IT leadership", MHCC teaching in past tense, LinkedIn link
- [x] Social links checked: all correct, keeping X for now
