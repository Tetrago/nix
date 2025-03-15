import { GLib } from "astal";
import { Gdk, Gtk } from "astal/gtk4";
import { exec } from "astal/process";

export const fileExists = (path: string) =>
  GLib.file_test(path, GLib.FileTest.EXISTS);
export const isIcon = (icon: string) => new Gtk.IconTheme().has_icon(icon);

interface Monitor {
  id: number;
  name: string;
}

export const getHyprlandID = (monitor: Gdk.Monitor) =>
  JSON.parse(exec(["hyprctl", "monitors", "-j"])).find(
    (m: Monitor) => m.name === monitor.connector,
  ).id;
