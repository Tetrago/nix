import { App } from "astal/gtk4";
import style from "./style.scss";
import Bar from "./widget/Bar";
import "./widget/VolumeIndicator";
import BrightnessIndicator from "./widget/BrightnessIndicator";
import VolumeIndicator from "./widget/VolumeIndicator";
import NotificationPopup from "./widget/NotificationPopup";
import { connectNotificationLog } from "./lib/SettingsWindow";

App.start({
  css: style,
  main() {
    connectNotificationLog();

    BrightnessIndicator();
    VolumeIndicator();

    App.get_monitors().map((monitor) => {
      Bar(monitor);
      NotificationPopup(monitor);
    });
  },
});
