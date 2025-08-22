# discourse-mall

Minimal SSR mall skeleton for Discourse 3.6+

- `/mall`         -> SSR index
- `/mall/ok`      -> plain OK
- `/mall?plain=1` -> plain OK (SSR)
- `/mall/admin`   -> admin gate (only usernames in `mall_admin_usernames`)
- `/mall-api/ping`-> JSON health check

Logs: `public/mall.txt` (newline-delimited JSON)

No client bundling hacks; no `register_asset` used.
