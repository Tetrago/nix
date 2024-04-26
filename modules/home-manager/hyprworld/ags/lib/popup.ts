import GLib from "gi://GLib";

export default () => {
    let id: number|null = null;

    return self => {
        self.visible = true;

        if(id) GLib.source_remove(id);
        id = Utils.timeout(1500, () => self.visible = false);
    }
};