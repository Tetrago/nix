import Gtk from "gi://Gtk?version=3.0";
import Gdk from "gi://Gdk";
import Bar from "widget/bar/Bar";
import Date from "widget/system_center/SystemCenter";
import Audio from "widget/popup/Audio";
import Brightness from "widget/popup/Brightness";
import NotificationPopups from "widget/notification/NotificationPopups";
import { range } from "lib/util";

function forMonitors(widget: (monitor: number) => Gtk.Window) {
    const n = Gdk.Display.get_default()?.get_n_monitors() || 1;
    return range(n).map(widget).flat(1);
}

App.config({
    style: `${App.configDir}/style.css`,
    windows: () => [
        Date(),
        Audio(),
        Brightness(),
        ...forMonitors(Bar),
        ...forMonitors(NotificationPopups)
    ]
});