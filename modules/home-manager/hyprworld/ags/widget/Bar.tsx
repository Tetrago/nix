import { App, Astal } from "astal/gtk4";
import { Variable } from "astal";
import Battery from "./Battery";
import Tray from "./Tray";
import Workspaces from "./Workspaces";

const time = Variable("").poll(1000, "date +%-I:%M");

export default function Bar(monitor: number) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

  return (
    <window
      visible
      cssClasses={["Bar"]}
      monitor={monitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={App}
    >
      <centerbox cssClasses={["row"]}>
        <box cssClasses={["date"]}>
          <label label={time()} />
        </box>
        <Workspaces monitor={monitor} />
        <box spacing={5}>
          <Battery />
          <Tray />
        </box>
      </centerbox>
    </window>
  );
}
