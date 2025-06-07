import { App } from "astal/gtk4";
import style from "./style.scss";
import Bar from "./widget/Bar";
import "./widget/VolumeIndicator";
import BrightnessIndicator from "./widget/BrightnessIndicator";
import VolumeIndicator from "./widget/VolumeIndicator";

App.start({
  css: style,
  main() {
    BrightnessIndicator();
    VolumeIndicator();
    App.get_monitors().map(Bar);
  },
});
