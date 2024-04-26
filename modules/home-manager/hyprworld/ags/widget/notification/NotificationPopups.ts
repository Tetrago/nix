import Notification from "./Notification";

const notifications = await Service.import("notifications");

const Animated = (id: number) => {
    const n = notifications.getNotification(id)!;
    const widget = Notification(n);

    const inner = Widget.Revealer({
        transition: "slide_left",
        transitionDuration: 200,
        child: widget
    });

    const outer = Widget.Revealer({
        transition: "slide_down",
        transitionDuration: 200,
        child: inner
    });

    const box = Widget.Box({
        hpack: "end",
        child: outer
    });

    Utils.idle(() => {
        outer.reveal_child = true;
        Utils.timeout(200, () => inner.reveal_child = true);
    });

    return Object.assign(box, {
        dismiss: () => {
            inner.reveal_child = false;
            Utils.timeout(200, () => {
                outer.reveal_child = false;
                Utils.timeout(200, () => {
                    box.destroy();
                });
            });
        }
    });
};

const PopupList = () => {
    const map: Map<number, ReturnType<typeof Animated>> = new Map;
    const box = Widget.Box({
        hpack: "end",
        vertical: true,
        spacing: 8,
        css: "min-width: 440px;"
    });

    const remove = (_: unknown, id: number) => {
        map.get(id)?.dismiss();
        map.delete(id);
    };

    return box
        .hook(notifications, (_, id: number) => {
            if(id === undefined) return;

            if(map.has(id)) remove(null, id);
            if(notifications.dnd) return;

            const w = Animated(id);
            map.set(id, w);
            box.children = [w, ...box.children];
        }, "notified")
        .hook(notifications, remove, "dismissed")
        .hook(notifications, remove, "closed");
};

export default (monitor: number) => Widget.Window({
    monitor,
    name: `notifications${monitor}`,
    margins: [10],
    anchor: ["top", "right"],
    class_name: "notifications",
    child: Widget.Box({
        css: "padding: 2px;",
        child: PopupList()
    })
});