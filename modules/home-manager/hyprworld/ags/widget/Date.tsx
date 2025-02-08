import { Gtk } from "astal/gtk4";
import { Variable } from "astal";

const time = Variable("").poll(1000, "date +%-I:%M");

export default function Date() {
  const revealed = new Variable(false);

  return (
    <overlay
      onHoverEnter={() => revealed.set(true)}
      onHoverLeave={() => revealed.set(false)}
      cssClasses={["Date"]}
    >
      <box cssClasses={["time"]}>
        <label label={time()} />
      </box>
      <revealer
        type="overlay measure"
        revealChild={revealed()}
        transitionType={Gtk.RevealerTransitionType.SLIDE_RIGHT}
        cssClasses={["extra"]}
      >
        <label label={"hi"} />
      </revealer>
    </overlay>
  );
}
