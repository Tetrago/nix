import GLib from "gi://GLib";

const clock = Variable(GLib.DateTime.new_now_local(), {
    poll: [1000, () => GLib.DateTime.new_now_local()]
});

export const date = Utils.derive([clock], c => c.format("%B %e, %Y") || "");
export const time = Utils.derive([clock], c => c.format("%-I:%M") || "")