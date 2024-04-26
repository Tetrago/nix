import Battery from "./Battery";
import Date from "./Date";
import Tray from "./Tray";
import Workspace from "./Workspace";

const hyprland = await Service.import("hyprland");

const Expander = () => Widget.Box({ expand: true });

const start = (monitor: number) => [
    Workspace(hyprland.monitors[monitor].id),
    Expander()
];

const center = (monitor: number) => [
    Date()
];

const end = (monitor: number) => [
    Expander(),
    Battery(),
    Tray()
];

export default (monitor: number) => Widget.Window({
    monitor,
    margins: [5, 5, 0, 5],
    class_name: "bar",
    name: `bar${monitor}`,
    exclusivity: "exclusive",
    anchor: ["top", "right", "left"],
    child: Widget.CenterBox({
        css: "min-width: 2px; min-height: 2px;",
        startWidget: Widget.Box({
            hexpand: true,
            spacing: 5,
            children: start(monitor)
        }),
        centerWidget: Widget.Box({
            hpack: "center",
            spacing: 5,
            children: center(monitor)
        }),
        endWidget: Widget.Box({
            hexpand: true,
            spacing: 5,
            children: end(monitor)
        })
    })
});