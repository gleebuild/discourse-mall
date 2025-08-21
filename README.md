
# discourse-mall

A tiny Discourse plugin that provides:

- `/mall` SSR test page
- `/mall/ok` health check
- `/mall/admin` staff-only redirect to `/admin/plugins/mall`
- `/mall-api/ping` health JSON
- `/mall-api/upload` (logged-in users) for direct uploads to Discourse (uses UploadCreator)
- Logs every hit to `/var/www/discourse/public/mall.txt`

## Install

1. Copy this folder to `plugins/discourse-mall` inside the Discourse container/app.
2. Ensure it's present (or add a git clone) in your `app.yml`, then `./launcher rebuild app`.
3. In Admin → Settings, enable **mall_enabled** (search "mall").

## Notes

- No DB migrations included to avoid bootstrap errors.
- Frontend admin page is under `/admin/plugins/mall`.
