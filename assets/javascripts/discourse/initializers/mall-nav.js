// discourse-mall nav injection
import { apiInitializer } from "discourse/lib/api";

export default apiInitializer("1.1.0", (api) => {
  try {
    api.addNavigationBarItem?.({
      name: "mall",
      displayName: I18n.t("mall.nav_title"),
      href: "/mall",
    });
  } catch(e) {
    // keep silent if API changes
  }
});
