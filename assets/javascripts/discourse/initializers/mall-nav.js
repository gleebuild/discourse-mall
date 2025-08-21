import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "mall-nav",
  initialize(container) {
    withPluginApi("1.15.0", (api) => {
      const siteSettings = container.lookup("service:site-settings");
      if (!siteSettings.mall_enabled) return;

      // 左侧“更多”右侧加“商城”
      api.addNavItem("mall", {
        name: "mall",
        displayName: "商城",
        title: "商城",
        href: "/mall",
        forceActive: () => location.pathname.startsWith("/mall"),
        customFilter: () => true
      });

      // Staff 才显示“管理”按钮
      api.addDiscoveryControlButton({
        id: "mall-admin",
        label: "管理",
        icon: "wrench",
        action() { window.location.href = "/mall/admin"; },
        position: "right",
        priority: 1000,
        displayed() {
          const currentUser = api.getCurrentUser();
          return currentUser && currentUser.staff;
        },
      });
    });
  },
};
