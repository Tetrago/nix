import { Notification as Notif } from "types/service/notifications";
import Notification from "widget/notification/Notification";

const notifications = await Service.import("notifications");
const feed = notifications.bind("notifications");

const Animated = (n: Notif) => Widget.Revealer({
    transition_duration: 200,
    transition: "slide_down",
    child: Notification(n),
    setup: self => Utils.timeout(200, () => self.is_destroyed || (self.reveal_child = true))
});

const ClearButton = () => Widget.Button({
    class_name: "clear_button",
    onClicked: notifications.clear,
    sensitive: feed.as(n => n.length > 0),
    child: Widget.Label({
        label: feed.as(n => `Clear ${n.length > 0 ? "\udb80\uddb4" : "\udb81\udecc"}`)
    })
});

const Header = () => Widget.Box({
    class_name: "header",
    children: [
        Widget.Label({
            label: "Notifications",
            hexpand: true,
            xalign: 0
        }),
        ClearButton()
    ]
});

const NotificationList = () => {
    const map: Map<number, ReturnType<typeof Animated>> = new Map;
    const box = Widget.Box({
        vertical: true,
        children: notifications.notifications.map(n => {
            const w = Animated(n);
            map.set(n.id, w);
            return w;
        }),
        spacing: 8,
        visible: feed.as(n => n.length > 0)
    });

    const remove = (_: unknown, id: number) => {
        const n = map.get(id);
        if(!n) return;

        n.reveal_child = false;
        Utils.timeout(200, () => {
            n.destroy();
            map.delete(id);
        });
    };

    return box
        .hook(notifications, remove, "closed")
        .hook(notifications, (_, id: number) => {
            if(id === undefined) return;
            if(map.has(id)) remove(null, id);

            const w = Animated(notifications.getNotification(id)!);
            map.set(id, w);
            box.children = [w, ...box.children];
        }, "notified");
};

const Placeholder = () => Widget.Box({
    class_name: "placeholder",
    vertical: true,
    vpack: "center",
    hpack: "center",
    vexpand: true,
    hexpand: true,
    visible: feed.as(n => n.length === 0),
    children: [
        Widget.Label("Your inbox is empty")
    ]
});

export default () => Widget.Box({
    class_name: "notifications",
    css: "min-width: 440px",
    hpack: "end",
    vertical: true,
    children: [
        Header(),
        Widget.Scrollable({
            vexpand: true,
            hscroll: "never",
            class_name: "notification_scrollable",
            child: Widget.Box({
                class_name: "notification_list",
                vertical: true,
                children: [
                    NotificationList(),
                    Placeholder()
                ]
            })
        })
    ]
});