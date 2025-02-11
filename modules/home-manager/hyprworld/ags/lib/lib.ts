import { GLib } from "astal";
import { Gtk } from "astal/gtk4";

export const fileExists = (path: string) =>
  GLib.file_test(path, GLib.FileTest.EXISTS);
export const isIcon = (icon: string) => new Gtk.IconTheme().has_icon(icon);
