# TODO

## In-Progress

- [ ] Switch `www` DNS record to Cloudflare-proxied (uncommitted change in `.k8s/fc-prod-nginx-deployment.yaml`)
- [ ] Sculpin 4.0 alpha upgrade: done and tested locally in Docker. Waiting on David to commit and deploy

- [ ] Confirm Dependabot alert #14 (high) closes on its own: it should be from the old dev-branch `composer.lock`, and the new lock has no advisories


- [ ] Instant Tokens says "Token Needs Attention" (token still valid). Waiting 24h to see if it clears on its own; reconnect only if it doesn't. Don't use "refresh secret": it changes the script URL

## Backlog

### Outdated
- [ ] Update front-end libraries (Bootstrap 3, jQuery 3.2.1, Font Awesome 4, highlight.js) without changing the look. With Font Awesome 6, switch the inline X logo to its built-in X icon

### Content
- [ ] Refresh bio text (About page, sidebar, footer)
- [ ] Review social links

### On hold
- [ ] `/photos/www/` and `/pe7700/` return 404: waiting until the content is moved to the volume

## Complete

- [x] Move hosting to the home k8s cluster (Docker + k8s + `bin/deploy.sh`), deployed v0.1.1
- [x] Fix the :8080 redirect issue, deployed v0.1.2
- [x] Create AI.MD and TODO.MD
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
