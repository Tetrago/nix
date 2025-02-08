import AstalTray from "gi://AstalTray";
import { Gdk, Gtk } from "astal/gtk4";
import { bind } from "astal";
import SettingsMenu from "./SettingsMenu";

const tray = AstalTray.get_default();

export default function Tray() {
  return (
    <box spacing={5} cssClasses={["Tray"]}>
      {bind(tray, "items").as((items) =>
        items.map((item: AstalTray.TrayItem) => (
          <Gtk.AspectFrame ratio={1}>
            <menubutton
              setup={(self) => {
                bind(item, "actionGroup").subscribe((value) =>
                  self.insert_action_group("dbusmenu", value),
                );

                self.insert_action_group("dbusmenu", item.actionGroup);
              }}
              menuModel={bind(item, "menuModel")}
              tooltipMarkup={bind(item, "tooltipMarkup")}
              onButtonPressed={(_, event) => {
                if (event.get_button() === Gdk.BUTTON_SECONDARY) {
                  item.activate(0, 0);
                }
              }}
            >
              <image
                iconName={bind(item, "gicon").as((value) => value.to_string())}
              />
            </menubutton>
          </Gtk.AspectFrame>
        )),
      )}
      <SettingsMenu />
    </box>
  );
}
