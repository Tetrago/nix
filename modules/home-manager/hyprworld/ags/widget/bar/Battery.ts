const battery = await Service.import("battery");

const Progress = () => Widget.Box({
    class_name: "battery",
    tooltip_markup: battery.bind("percent").as(p => `${p}%`),
    child: Widget.Icon({
        class_name: "icon",
        icon: battery.bind("icon-name")
    })
});

export default () => Widget.Revealer({
    visible: battery.bind("available"),
    revealChild: battery.bind("charged").as(c => !c),
    child: Progress()
});