import { range } from "lib/util";

const hyprland = await Service.import("hyprland");

export default (monitorID: number) => Widget.Box({
    class_name: "workspace",
    children: range(10).map(i => i + 1).map(i => Widget.Label({
        class_name: "indicator",
        attribute: i,
        vpack: "center",
        label: `${i}`,
        setup: self => self.hook(hyprland, () => {
            self.toggleClassName("active", hyprland.active.monitor.id === monitorID && hyprland.monitors.some(m => m.id == monitorID && m.activeWorkspace.id === i));
            self.toggleClassName("occupied", hyprland.workspaces.some(w => w.monitorID === monitorID && w.id === i));
            self.toggleClassName("present", hyprland.workspaces.some(w => w.monitorID !== monitorID && w.id === i));
        })
    })),
    setup: self => {
        self.hook(hyprland, () => {
            self.toggleClassName("special", hyprland.workspaces.some(w => w.name === "special"))
            self.toggleClassName("active", hyprland.active.monitor.id === monitorID);

            self.children.map(indicator => {
                indicator.visible = hyprland.workspaces.some(w => w.id >= indicator.attribute);
            });
        });
    }
});