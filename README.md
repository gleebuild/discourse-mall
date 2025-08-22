# discourse-mall

A tiny Mall skeleton plugin for Discourse 3.6.x that guarantees:
- `/mall`, `/mall/admin`, `/mall/*` always SSR OK instead of 404
- `/mall-api/ping` returns `{ ok: true, via: "mall" }`
- plugin settings page under **/admin/plugins/discourse-mall**
- per-request logging to `Rails.root/public/mall.txt`

No migrations. Safe to enable/disable.
