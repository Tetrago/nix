import { register } from "astal/gobject";
import { Gtk } from "astal/gtk4";
import Adw from "gi://Adw";
import Notifd from "gi://AstalNotifd";
import { fileExists, isIcon } from "../lib/lib";

@register({ GTypeName: "NotificationRow" })
export default class NotificationRow extends Adw.ActionRow {
  constructor(notification: Notifd.Notification) {
    super({
      title: notification.summary,
      activatable: true,
    });

    if (notification.image) {
      if (fileExists(notification.image)) {
        this.add_prefix(
          new Gtk.Image({
            file: notification.image,
            overflow: Gtk.Overflow.HIDDEN,
          }),
        );
      } else if (isIcon(notification.image)) {
        this.add_prefix(
          new Gtk.Image({
            iconName: notification.image,
            iconSize: Gtk.IconSize.LARGE,
            halign: Gtk.Align.CENTER,
            valign: Gtk.Align.CENTER,
          }),
        );
      }
    }

    this.add_suffix(
      new Gtk.Label({
        label: new Date(notification.time).toLocaleTimeString(),
        cssClasses: ["dim-label"],
        valign: Gtk.Align.CENTER,
      }),
    );

    const dismissButton = new Gtk.Button({
      iconName: "window-close-symbolic",
      valign: Gtk.Align.CENTER,
      cssClasses: ["flat", "circular", "dismiss-button"],
      visible: false,
    });

    const controller = new Gtk.EventControllerMotion();
    controller.connect("enter", () => dismissButton.set_visible(true));
    controller.connect("leave", () => dismissButton.set_visible(false));
    this.add_controller(controller);

    dismissButton.connect("clicked", () => {
      this.unparent();
      notification.dismiss();
    });

    this.add_suffix(dismissButton);

    if (notification.urgency === Notifd.Urgency.CRITICAL) {
      this.add_css_class("error");
    }

    if (notification.body) {
      this.set_subtitle(notification.body);
    }
  }
}
