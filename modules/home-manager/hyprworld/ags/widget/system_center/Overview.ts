import Media from "widget/media/Media";
import { date, time } from "lib/clock";

const Wrap = (widget) =>
  Widget.Box({
    class_name: "zone",
    children: [widget],
  });

const pendingAction = Variable<{ label: string; command: string } | null>(null);

const Action = (icon, label, command) =>
  Widget.Button({
    class_name: "button",
    onClicked: () => (pendingAction.value = { label, command }),
    child: Widget.Label(icon),
  });

const QuickMenu = () =>
  Widget.Box({
    hpack: "center",
    children: [
      Widget.Overlay({
        child: Widget.Box({
          class_name: "quick_menu",
          spacing: 20,
          children: [
            Action("\udb80\udf3e", "Lock", "loginctl lock-session"),
            Action("\udb80\udf43", "Logout", "hyprctl dispatch exit"),
            Action("\udb81\udf09", "Reboot", "systemctl reboot"),
            Action("\udb81\udc25", "Shutdown", "systemctl -i poweroff"),
          ],
        }),
        pass_through: false,
        overlays: pendingAction.bind().as((a) =>
          a
            ? [
                Widget.Box({
                  class_name: "quick_menu",
                  children: [
                    Widget.Button({
                      class_name: "button",
                      onClicked: () => (pendingAction.value = null),
                      child: Widget.Label("\udb81\udf3a"),
                    }),
                    Widget.Box({
                      hexpand: true,
                      hpack: "center",
                      children: [Widget.Label(`${a.label}?`)],
                    }),
                    Widget.Button({
                      class_name: "button",
                      onClicked: () => {
                        App.closeWindow("system_center");
                        Utils.exec(a.command);
                      },
                      child: Widget.Label("\udb80\udd2c"),
                    }),
                  ],
                }),
              ]
            : [],
        ),
      }),
    ],
    setup: (self) => {
      self.hook(App, (_, window, visible) => {
        if (window === "system_center" && !visible) pendingAction.value = null;
      });
    },
  });

const Clock = () =>
  Widget.Box({
    class_name: "clock",
    vertical: true,
    children: [
      Widget.Label({
        class_name: "time",
        justification: "center",
        label: time.bind(),
      }),
      Widget.Label({
        class_name: "date",
        justification: "center",
        label: date.bind(),
      }),
    ],
  });

const Calendar = () =>
  Widget.Calendar({
    class_name: "calendar",
    hexpand: true,
    hpack: "center",
  });

const MediaContainer = () =>
  Widget.Box({
    class_name: "media_container",
    children: [Media({ spacing: 10 })],
  });

export default () =>
  Widget.Box({
    class_name: "overview",
    vertical: true,
    vexpand: false,
    vpack: "start",
    spacing: 10,
    children: [Clock(), Wrap(Calendar()), QuickMenu(), MediaContainer()],
  });
