const screen = await Utils.execAsync("sh -c 'ls -w1 /sys/class/backlight | head -1'")

class Brightness extends Service {
    static {
        Service.register(this, {}, { "value": ["float", "r"] });
    }

    #value = 0;
    #max = 0;

    get value() {
        return this.#value;
    }

    constructor() {
        super();

        const brightness = `/sys/class/backlight/${screen}/brightness`;
        this.#max = Number(Utils.exec(`cat /sys/class/backlight/${screen}/max_brightness`));

        Utils.monitorFile(brightness, () => this.#onChange());

        this.#onChange();
    }

    #onChange() {
        this.#value = Number(Utils.exec(`cat /sys/class/backlight/${screen}/brightness`)) / this.#max;

        this.emit("changed");
        this.notify("value");
    }
}

export default new Brightness;