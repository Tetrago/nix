import { bind, Variable } from "astal";
import AstalBattery from "gi://AstalBattery";

const battery = AstalBattery.get_default();

export default function Battery() {
  return (
    <box
      visible={bind(
        Variable.derive(
          [bind(battery, "isBattery"), bind(battery, "percentage")],
          (isBattery, value) => isBattery && value < 0.95,
        ),
      )}
      tooltipMarkup={bind(
        Variable.derive(
          [bind(battery, "percentage"), bind(battery, "charging")],
          (value, charging) =>
            `${charging ? "" : ""}${Math.floor(value * 100)}%`,
        ),
      )}
      cssClasses={bind(
        Variable.derive(
          [bind(battery, "percentage"), bind(battery, "charging")],
          (percentage: number, charging: boolean) => {
            return [
              "Battery",
              ...(charging
                ? ["charging"]
                : percentage < 0.4
                  ? ["warning"]
                  : percentage < 0.2
                    ? ["critical"]
                    : []),
            ];
          },
        ),
      )}
    >
      <levelbar value={bind(battery, "percentage")} widthRequest={100} />
    </box>
  );
}
