import { bind, Variable } from "astal";
import { App, Astal, Gtk } from "astal/gtk4";
import { timeout } from "astal/time";
import Brightness from "../lib/Brightness";
import Hyprland from "gi://AstalHyprland";

const brightness = Brightness.get_default();
const hyprland = Hyprland.get_default();

export default function BrightnessIndicator() {
  const visible = new Variable(false);
  let count = 0;

  return (
    <window
      setup={() => {
        bind(brightness, "brightness").subscribe(() => {
          visible.set(true);
          ++count;

          timeout(1500, () => --count || visible.set(false));
        });
      }}
      visible={bind(visible)}
      monitor={bind(hyprland, "focusedMonitor").as(
        (monitor: Hyprland.Monitor) => monitor.get_id(),
      )}
      cssClasses={["Indicator", "Brightness"]}
      layer={Astal.Layer.OVERLAY}
      anchor={Astal.WindowAnchor.LEFT}
      marginLeft={5}
      application={App}
    >
      <box
        cssClasses={["panel"]}
        marginTop={10}
        marginEnd={10}
        marginBottom={10}
        marginStart={10}
      >
        <box orientation={Gtk.Orientation.VERTICAL} spacing={5}>
          <image marginTop={3} iconName={"display-brightness"} />
          <levelbar
            orientation={Gtk.Orientation.VERTICAL}
            inverted={true}
            widthRequest={20}
            heightRequest={400}
            value={bind(brightness, "brightness")}
          />
        </box>
      </box>
    </window>
  );
}
