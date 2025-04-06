import { bind, Variable } from "astal";
import { App, Astal, Gtk } from "astal/gtk4";
import { timeout } from "astal/time";
import Wp from "gi://AstalWp";
import Hyprland from "gi://AstalHyprland";

const audio = Wp.get_default().audio;
const hyprland = Hyprland.get_default();

export default function VolumeIndicator() {
  const visible = new Variable(false);

  return (
    <window
      namespace={"volume-indicator"}
      setup={(self) => {
        hyprland.message(
          `keyword layerrule animation slide right, ${self.namespace}`,
        );

        hyprland.message(`keyword layerrule dimaround, ${self.namespace}`);
      }}
      visible={bind(visible)}
      monitor={bind(hyprland, "focusedMonitor").as(
        (monitor: Hyprland.Monitor) => monitor.get_id(),
      )}
      cssClasses={["Indicator"]}
      layer={Astal.Layer.OVERLAY}
      anchor={Astal.WindowAnchor.RIGHT}
      marginRight={10}
      application={App}
    >
      {bind(audio, "defaultSpeaker").as((endpoint: Wp.Endpoint) => {
        let count = 0;

        const variable = Variable.derive(
          [bind(endpoint, "volume"), bind(endpoint, "mute")],
          () => {
            visible.set(true);
            ++count;

            timeout(1500, () => --count || visible.set(false));
          },
        );

        return (
          <box
            onDestroy={() => variable.drop()}
            cssClasses={bind(endpoint, "mute").as((muted: boolean) =>
              muted ? ["muted"] : [],
            )}
            orientation={Gtk.Orientation.VERTICAL}
            spacing={5}
          >
            <image
              marginTop={3}
              iconName={bind(
                Variable.derive(
                  [bind(endpoint, "volume"), bind(endpoint, "mute")],
                  (volume: number, muted: boolean) =>
                    muted
                      ? "audio-volume-muted"
                      : volume > 0.66
                        ? "audio-volume-high"
                        : volume > 0.33
                          ? "audio-volume-medium"
                          : "audio-volume-low",
                ),
              )}
            />
            <levelbar
              orientation={Gtk.Orientation.VERTICAL}
              inverted={true}
              widthRequest={20}
              heightRequest={400}
              value={bind(endpoint, "volume")}
            />
          </box>
        );
      })}
    </window>
  );
}
