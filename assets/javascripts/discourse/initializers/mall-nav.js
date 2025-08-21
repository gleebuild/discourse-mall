
import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "mall-nav",
  initialize() {
    withPluginApi("1.45.0", (api) => {
      api.addNavigationBarItem({
        name: "mall",
        displayName: "商城",
        title: "商城",
        href: "/mall",
      });
    });
  },
};
