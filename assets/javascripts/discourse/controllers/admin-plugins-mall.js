
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";

export default class AdminPluginsMallController extends Controller {
  result = null;

  @action
  async upload() {
    const input = document.getElementById("mall-file");
    if (!input || !input.files || input.files.length === 0) {
      alert("请选择文件");
      return;
    }
    const fd = new FormData();
    fd.append("file", input.files[0]);
    try {
      const json = await ajax("/mall-api/upload", { method: "POST", data: fd, processData: false, contentType: false });
      this.set("result", json);
    } catch (e) {
      alert("上传失败: " + (e?.message || e));
    }
  }
}
