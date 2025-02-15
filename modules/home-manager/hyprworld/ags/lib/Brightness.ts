import GObject, { register, property } from "astal/gobject";
import { monitorFile, readFileAsync } from "astal/file";
import { exec } from "astal/process";

const screen = exec("ls -1 /sys/class/backlight/") || undefined;
const maxBrightness = screen
  ? Number(exec(`cat /sys/class/backlight/${screen}/max_brightness`))
  : 0;

@register({ GTypeName: "Brightness" })
export default class Brightness extends GObject.Object {
  private static instance: Brightness;

  static get_default() {
    if (!this.instance) {
      this.instance = new Brightness();
    }

    return this.instance;
  }

  #screen = screen
    ? Number(exec(`cat /sys/class/backlight/${screen}/brightness`)) /
      maxBrightness
    : 0;

  @property(Number)
  get brightness() {
    return this.#screen;
  }

  constructor() {
    super();

    if (screen) {
      monitorFile(`/sys/class/backlight/${screen}/brightness`, async (file) => {
        const value = await readFileAsync(file);
        this.#screen = Number(value) / maxBrightness;
        this.notify("brightness");
      });
    }
  }
}
