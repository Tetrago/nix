import popup from "lib/popup";
import brightness from "service/brightness";

export default () => Widget.Window({
    name: "brightness",
    class_name: "alert",
    visible: false,
    exclusivity: "ignore",
    layer: "overlay",
    child: Widget.CenterBox({
        class_name: "container",
        vertical: true,
        vexpand: true,
        centerWidget: Widget.Label({
            label: brightness.bind("value").as(v => {
                if(v > 0.86) return "\udb80\udce0";
                if(v > 0.71) return "\udb80\udcdf";
                if(v > 0.57) return "\udb80\udcde";
                if(v > 0.43) return "\udb80\udcdd";
                if(v > 0.29) return "\udb80\udcdc";
                if(v > 0.14) return "\udb80\udcdb";
                else return "\udb80\udcda";
            })
        }),
        endWidget: Widget.LevelBar({
            class_name: "level",
            vpack: "end",
            value: brightness.bind("value")
        })
    }),
    setup: self => {
        let p = popup();
        self.hook(brightness, (_, b) => b && p(self), "notify::value");
    }
});