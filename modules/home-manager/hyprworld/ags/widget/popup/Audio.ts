import popup from "lib/popup";

const audio = await Service.import("audio");

export default () => Widget.Window({
    name: "audio",
    class_name: "alert",
    visible: false,
    exclusivity: "ignore",
    layer: "top",
    child: Widget.CenterBox({
        class_name: "container",
        vertical: true,
        vexpand: true,
        centerWidget: Widget.Label({
            label: Utils.merge([audio.speaker.bind("volume"), audio.speaker.bind("is_muted")], (v, m) => {
                if(m) return "\udb81\udf5f";

                if(v > 0.66) return "\udb81\udd7e";
                if(v > 0.33) return "\udb81\udd80";
                else return "\udb81\udd7f";
            })
        }),
        endWidget: Widget.LevelBar({
            class_name: "level",
            vpack: "end",
            value: audio.speaker.bind("volume")
        })
    }),
    setup: self => {
        let p = popup();
        self.hook(audio.speaker, (_, m) => m && p(self), "notify::is-muted");
        self.hook(audio.speaker, (_, v) => v && p(self), "notify::volume");
    }
});