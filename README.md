functionalchaos.net
=====================

Static content to build functionalchaos.net website.

Powered by [Sculpin](http://sculpin.io)

Hosting
-------

Served from the FC home Kubernetes cluster as an unprivileged nginx image built from this repo.

| Path | Purpose |
|---|---|
| `.docker/nginx/` | Dockerfile (Sculpin build stage + nginx) and nginx config |
| `docker-compose-prod.yaml` | Builds the `fc-prod-nginx` image; `up` for a local preview on http://localhost:8888 |
| `.k8s/fc-prod-nginx-deployment.yaml` | Deployment, Service, content volume, HTTPRoute, DNSEndpoint (www) |
| `.k8s/fc-content-loader.yaml` | One-time helper for loading the content volume (below) |
| `bin/deploy.sh` | Build → tag → push to Harbor → bump manifest tag → apply → wait for rollout |

```bash
./bin/deploy.sh prod --dry-run   # preview
./bin/deploy.sh prod             # needs a clean main/master; asks you to type 'prod'
```

Prerequisites: `docker login registry.functionalchaos.net`. The cluster repo (`~/projects/fc-k8s-cluster`)
owns the `harbor-pull-secret` pull secret, and the Gateway listeners and certificate.

Note: `app/config/sculpin_site.yml` and `sculpin_kernel.yml` are gitignored but the build needs them,
so a fresh clone can't build until they're restored.

### Content not in git

`photos/` (~6.4 GB, including an old PHP gallery whose `.php` pages are not served) and `pe7700/` live on
the `fc-content` Longhorn volume, mounted at `/srv/content`. Load them once from w5 after the first deploy:

```bash
kctl-fc -n functionalchaos apply -f .k8s/fc-content-loader.yaml
kctl-fc -n functionalchaos wait --for=condition=Ready pod/fc-content-loader --timeout=120s
ssh root@w5.functionalchaos.net 'tar -C /var/www/functionalchaos.net -cf - photos pe7700' \
  | kctl-fc -n functionalchaos exec -i fc-content-loader -- tar -xf - -C /srv/content
kctl-fc -n functionalchaos exec fc-content-loader -- du -sh /srv/content/photos /srv/content/pe7700
kctl-fc -n functionalchaos delete pod fc-content-loader
```
