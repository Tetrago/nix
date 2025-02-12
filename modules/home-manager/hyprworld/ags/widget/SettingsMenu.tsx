import { Gtk } from "astal/gtk4";
import Adw from "gi://Adw";
import Gio from "gi://Gio";
import { exec } from "astal/process";
import SettingsWindow from "../lib/SettingsWindow";

interface Item {
  name: string;
  icon: string;
  callback: (parent: Gtk.Widget) => void;
}

function createMenuModelFromItems(items: Item[][]) {
  const menu = new Gio.Menu();

  items.forEach((list) => {
    const section = new Gio.Menu();

    list.forEach((value) => {
      const item = Gio.MenuItem.new(
        value.name,
        `settingsmenu.${value.name.toLowerCase().replaceAll(" ", "_")}`,
      );
      item.set_icon(Gio.ThemedIcon.new(value.icon));
      section.append_item(item);
    });

    menu.append_section(null, section);
  });

  return menu;
}

function createActionGroupFromItems(parent: Gtk.Widget, items: Item[][]) {
  const group = new Gio.SimpleActionGroup();

  items.flat().forEach((item) => {
    const action = new Gio.SimpleAction({
      name: item.name.toLowerCase().replaceAll(" ", "_"),
    });
    action.connect("activate", () => item.callback(parent));
    group.add_action(action);
  });

  return group;
}

export default function SettingsMenu() {
  const prompt = (
    parent: Gtk.Widget,
    confirmation: string,
    callback: () => void,
  ) => {
    const dialog = new Adw.AlertDialog({
      body: `Are you sure you want to ${confirmation}?`,
    });

    dialog.add_response("yes", "Yes");
    dialog.add_response("no", "No");
    dialog.set_response_appearance("yes", Adw.ResponseAppearance.SUGGESTED);

    dialog.connect("response", (_, response) => {
      if (response === "yes") {
        callback();
      }
    });

    dialog.present(parent.get_root());
  };

  const items: Item[][] = [
    [
      {
        name: "Settings",
        icon: "preferences-system",
        callback: () => SettingsWindow.show(),
      },
    ],
    [
      {
        name: "Log out",
        icon: "system-log-out",
        callback: (parent) =>
          prompt(parent, "log out", () => exec("hyprctl dispatch exit")),
      },
      {
        name: "Sleep",
        icon: "system-suspend",
        callback: (parent) =>
          prompt(parent, "sleep", () => exec("systemctl suspend")),
      },
      {
        name: "Reboot",
        icon: "system-reboot",
        callback: (parent) =>
          prompt(parent, "reboot", () => exec("systemctl reboot")),
      },
      {
        name: "Shutdown",
        icon: "system-shutdown",
        callback: (parent) =>
          prompt(parent, "shutdown", () => exec("systemctl -i poweroff")),
      },
    ],
  ];

  return (
    <box>
      <Gtk.AspectFrame ratio={1}>
        <menubutton
          setup={(self) =>
            self.insert_action_group(
              "settingsmenu",
              createActionGroupFromItems(self, items),
            )
          }
          menuModel={createMenuModelFromItems(items)}
        >
          <image iconName={"preferences-system"} />
        </menubutton>
      </Gtk.AspectFrame>
    </box>
  );
}
