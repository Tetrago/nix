import { GLib, timeout } from "astal";
import { Gtk } from "astal/gtk4";
import Pango from "gi://Pango";
import Notifd from "gi://AstalNotifd";

const isIcon = (icon: string) => new Gtk.IconTheme().has_icon(icon);

const fileExists = (path: string) => GLib.file_test(path, GLib.FileTest.EXISTS);

function urgency(notification: Notifd.Notification) {
  switch (notification.urgency) {
    case Notifd.Urgency.LOW:
      return "low";
    case Notifd.Urgency.CRITICAL:
      return "critical";
    case Notifd.Urgency.NORMAL:
    default:
      return "normal";
  }
}

type Props = {
  notification: Notifd.Notification;
};

export default function Notification({ notification }: Props) {
  return (
    <box
      name={notification.id.toString()}
      cssClasses={["notification", urgency(notification)]}
    >
      <box
        cssClasses={["content"]}
        orientation={Gtk.Orientation.VERTICAL}
        hexpand
      >
        <box cssClasses={["title"]}>
          {notification.image && fileExists(notification.image) && (
            <box valign={Gtk.Align.START} cssClasses={["image"]}>
              <image file={notification.image} overflow={Gtk.Overflow.HIDDEN} />
            </box>
          )}
          {notification.image && isIcon(notification.image) && (
            <box cssClasses={["icon-image"]} valign={Gtk.Align.START}>
              <image
                iconName={notification.image}
                iconSize={Gtk.IconSize.LARGE}
                halign={Gtk.Align.CENTER}
                valign={Gtk.Align.CENTER}
              />
            </box>
          )}
          <label
            ellipsize={Pango.EllipsizeMode.END}
            maxWidthChars={30}
            cssClasses={["summary"]}
            halign={Gtk.Align.START}
            xalign={0}
            label={notification.summary}
          />
        </box>
        <label
          cssClasses={["body"]}
          wrap
          vexpand
          yalign={0}
          xalign={0}
          label={notification.body || ""}
        />
      </box>
      <button
        vexpand
        cssClasses={["dismiss"]}
        onClicked={() => notification.dismiss()}
      >
        <image
          iconName={"window-close-symbolic"}
          iconSize={Gtk.IconSize.LARGE}
        />
      </button>
    </box>
  );
}
