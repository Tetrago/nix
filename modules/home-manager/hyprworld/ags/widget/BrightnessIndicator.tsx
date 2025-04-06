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
      namespace={"brightness-indicator"}
      setup={(self) => {
        hyprland.message(
          `keyword layerrule animation slide left, ${self.namespace}`,
        );

        hyprland.message(`keyword layerrule dimaround, ${self.namespace}`);

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
      marginLeft={10}
      application={App}
    >
      <box orientation={Gtk.Orientation.VERTICAL} spacing={5}>
        <image marginTop={3} iconName={"weather-clear"} />
        <levelbar
          orientation={Gtk.Orientation.VERTICAL}
          inverted={true}
          widthRequest={20}
          heightRequest={400}
          value={bind(brightness, "brightness")}
        />
      </box>
    </window>
  );
}
