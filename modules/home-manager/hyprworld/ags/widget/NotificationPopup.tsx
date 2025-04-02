import { timeout } from "astal";
import { App, Astal, Gdk, Gtk, hook } from "astal/gtk4";
import Hyprland from "gi://AstalHyprland";
import Notifd from "gi://AstalNotifd";
import Notification from "./Notification";
import { getHyprlandID } from "../lib/lib";

const hyprland = Hyprland.get_default();
const notifd = Notifd.get_default();

export default function NotificationPopup(monitor: Gdk.Monitor) {
  const monitorId = getHyprlandID(monitor);

  return (
    <window
      namespace={"notification-popup"}
      gdkmonitor={monitor}
      anchor={Astal.WindowAnchor.TOP}
      application={App}
      cssClasses={["Notification"]}
      setup={(self) => {
        hyprland.message(
          `keyword layerrule animation slide top, ${self.namespace}`,
        );

        const queue: number[] = [];
        let processing: number | undefined = undefined;

        function dismiss() {
          self.set_visible(false);
          self.set_child(null);
          processing = undefined;

          if (queue.length > 0) {
            timeout(300, process);
          }
        }

        function process() {
          if (processing !== undefined || queue.length === 0) return;
          processing = queue.shift();

          const content = (
            <box orientation={Gtk.Orientation.VERTICAL}>
              {Notification({
                notification: notifd.get_notification(processing!),
              })}
              <box vexpand />
            </box>
          );

          content.measure(Gtk.Orientation.VERTICAL, -1);
          content.measure(Gtk.Orientation.HORIZONTAL, -1);

          self.set_child(content);
          self.set_visible(true);

          timeout(5000, dismiss);
        }

        hook(self, notifd, "notified", (_, id: number) => {
          if (hyprland.get_focused_monitor().get_id() === monitorId) {
            queue.push(id);

            if (queue.length === 1) {
              process();
            }
          }
        });

        hook(self, notifd, "resolved", (_, id: number) => {
          if (processing === id) {
            dismiss();
          }
        });
      }}
    ></window>
  );
}
