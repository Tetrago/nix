import { bind } from "astal";
import Systemd from "../lib/Systemd";

const systemd = Systemd.get_default();
const hypridle = systemd.service("hypridle");

export default function Caffeine() {
  return (
    <button
      onClicked={() => {
        if (hypridle.active) {
          hypridle.stop();
        } else {
          hypridle.start();
        }
      }}
      cssClasses={bind(hypridle, "active").as((active) => [
        "Caffeine",
        ...(active ? [] : ["active"]),
      ])}
    >
      <image iconName={"lock-symbolic"} />
    </button>
  );
}
