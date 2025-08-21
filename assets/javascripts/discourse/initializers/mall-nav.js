import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "mall-nav",
  initialize() {
    withPluginApi("1.3.0", (api) => {
      // Add "商城" to top nav
      api.decorateWidget("header-buttons:after", () => {
        const h = require("virtual-dom/h");
        return h("a.header-btn.mf-mall", { attributes: { href: "/mall" }, className: "btn" }, "商城");
      });

      // Add "管理" for staff
      api.decorateWidget("header-buttons:after", (helper) => {
        const currentUser = helper.getCurrentUser && helper.getCurrentUser();
        if (!currentUser || !currentUser.staff) return;
        const h = require("virtual-dom/h");
        return h("a.header-btn.mf-mall-admin", { attributes: { href: "/mall/admin" }, className: "btn" }, "管理");
      });
    });
  },
};
