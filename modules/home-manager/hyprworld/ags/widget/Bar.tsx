import { App, Astal, Gdk } from "astal/gtk4";
import { Variable } from "astal";
import Battery from "./Battery";
import Caffeine from "./Caffeine";
import Tray from "./Tray";
import Workspaces from "./Workspaces";
import { getHyprlandID } from "../lib/lib";

const time = Variable("").poll(1000, "date +%-I:%M");

export default function Bar(monitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

  return (
    <window
      visible
      cssClasses={["Bar"]}
      gdkmonitor={monitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={App}
    >
      <centerbox cssClasses={["row"]}>
        <box cssClasses={["date"]}>
          <label label={time()} />
        </box>
        <Workspaces monitor={getHyprlandID(monitor)} />
        <box spacing={5}>
          <Battery />
          <Caffeine />
          <Tray />
        </box>
      </centerbox>
    </window>
  );
}
