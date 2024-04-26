import Notifications from "./Notifications";
import Overview from "./Overview";

export default () => Widget.Window({
    name: "system_center",
    class_name: "system_center",
    margins: [20],
    anchor: ["top", "right", "bottom", "left"],
    setup: w => w.keybind("Escape", () => App.closeWindow("system_center")),
    visible: false,
    keymode: "on-demand",
    layer: "top",
    child: Widget.CenterBox({
        vertical: false,
        center_widget: Overview(),
        end_widget: Notifications()
    })
});