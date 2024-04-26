import { time } from "lib/clock";

export default () => Widget.Button({
    class_name: "date",
    on_clicked: () => App.toggleWindow("system_center"),
    child: Widget.Label({
        class_name: "time",
        justification: "center",
        label: time.bind()
    }),
    setup: self => {
        let open = false;

        self.hook(App, (_, window, visible) => {
            if(window !== "system_center") return;

            if(open && !visible) {
                open = false;
                self.toggleClassName("active", false);
            }

            if(!open && visible) {
                open = true;
                self.toggleClassName("active", true);
            }
        });
    }
});