
import { withPluginApi } from "discourse/lib/plugin-api";
export default {
  name: "mall-nav",
  initialize() {
    const ss = Discourse?.SiteSettings;
    if (!ss || !ss.mall_enabled) return;
    const prefix = (ss.mall_route_prefix || "mall").replace(/^\/+|\/+$/g, "");

    withPluginApi("1.8.0", (api) => {
      // connector-style mount
      const mount = () => {
        const ul = document.querySelector(".nav-pills, .navigation-container ul, .list-controls .navigation-container ul");
        if (!ul) return;
        if (!ul.querySelector("li.mall-link")) {
          const li = document.createElement("li"); li.className="nav-item mall-link";
          const a = document.createElement("a"); a.textContent="商城"; a.href=`/${prefix}`; a.setAttribute("data-auto-route","false");
          li.appendChild(a); ul.appendChild(li);
        }
        if (api.getCurrentUser()?.staff && !ul.querySelector("li.mall-admin-link")) {
          const li = document.createElement("li"); li.className="nav-item mall-admin-link";
          const a = document.createElement("a"); a.textContent="管理"; a.href=`/${prefix}/admin`; a.setAttribute("data-auto-route","false");
          li.appendChild(a); ul.appendChild(li);
        }
      };
      mount();
      api.onPageChange(()=>setTimeout(mount, 100));
    });
  },
};
