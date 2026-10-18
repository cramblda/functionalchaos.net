# TODO

## In-Progress

- [ ] Switch `www` DNS record to Cloudflare-proxied (uncommitted change in `.k8s/fc-prod-nginx-deployment.yaml`)
- [ ] Sculpin 4.0 alpha upgrade: done and tested locally in Docker. Waiting on David to commit and deploy

## Backlog

### Sculpin & build
- [ ] Set the build timezone to Pacific so Docker and local builds produce the same dates

### Broken or outdated
- [ ] Facebook share button (very old SDK)
- [ ] Disqus comments: check that they still load
- [ ] Remove the dead html5shim and old Google Analytics snippet
- [ ] Update front-end libraries (Bootstrap 3, jQuery 3.2.1, Font Awesome 4, highlight.js) without changing the look. With Font Awesome 6, switch the inline X logo to its built-in X icon

### Site fixes
- [ ] Home page and About page are set to `noindex` (hidden from search engines)
- [ ] Fix social share tags on posts (absolute URLs, correct title/description)
- [ ] Mt Hood post uses the draft post's header image
- [ ] Small template cleanup (favicon `//` paths, duplicate meta tag)

### Cleanup
- [ ] Remove `component-manager.php`
- [ ] Remove the skeleton draft posts (2012 draft, 2013 syntax highlight)

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
