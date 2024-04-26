const mpris = await Service.import("mpris");
const players = mpris.bind("players");

const FALLBACK_ICON = "audio-x-generic-symbolic";
const PLAY_ICON = "media-playback-start-symbolic";
const PAUSE_ICON = "media-playback-pause-symbolic";
const PREV_ICON = "media-skip-backward-symbolic";
const NEXT_ICON = "media-skip-forward-symbolic";

function lengthStr(length) {
    const min = Math.floor(length / 60);
    const sec = Math.floor(length % 60);
    const sec0 = sec < 10 ? "0" : "";

    return `${min}:${sec0}${sec}`;
}

const Player = (player) => {
    const cover = Widget.Box({
        class_name: "cover",
        vpack: "start",
        css: Utils.merge([
            player.bind("cover_path"),
            player.bind("track_cover_url")
        ], (path, url) => `background-image: url('${path || url}')`)
    });

    const title = Widget.Label({
        class_name: "title",
        wrap: false,
        truncate: 'end',
        maxWidthChars: 24,
        hpack: "start",
        label: player.bind("track_title")
    });

    const artist = Widget.Label({
        class_name: "artist",
        wrap: false,
        truncate: 'end',
        maxWidthChars: 24,
        hpack: "start",
        label: player.bind("track_artists").transform(a => a.join(", "))
    });

    const positionSlider = Widget.Slider({
        class_name: "position",
        draw_value: false,
        on_change: ({ value }) => player.position = value * player.length,
        setup: self => {
            const update = () => {
                const { length, position } = player;

                self.visible = length > 0;
                self.value = length > 0 ? position / length : 0;
            };

            self.hook(player, update);
            self.hook(player, update, "position");
            self.poll(1000, update);
        }
    });

    const positionLabel = Widget.Label({
        class_name: "position",
        hpack: "start",
        setup: self => {
            const update = (_, time) => {
                self.label = lengthStr(time || player.position);
                self.visible = player.length > 0;
            };

            self.hook(player, update, "position");
            self.poll(1000, update);
        }
    });

    const lengthLabel = Widget.Label({
        class_name: "length",
        hpack: "end",
        visible: player.bind("length").transform(l => l > 0),
        label: player.bind("length").transform(lengthStr)
    });

    const icon = Widget.Icon({
        class_name: "icon",
        hexpand: true,
        hpack: "end",
        vpack: "start",
        tooltip_text: player.identity || "",
        icon: player.bind("entry").transform(entry => {
            const name = `${entry}-symbolic`;
            return Utils.lookUpIcon(name) ? name : FALLBACK_ICON;
        })
    });

    const playPause = Widget.Button({
        class_name: "play-pause",
        on_clicked: () => player.playPause(),
        visible: player.bind("can_play"),
        child: Widget.Icon({
            icon: player.bind("play_back_status").transform(s => {
                switch(s) {
                    case "Playing": return PAUSE_ICON;
                    case "Paused":
                    case "Stopped": return PLAY_ICON;
                }
            })
        })
    });

    const prev = Widget.Button({
        on_clicked: () => player.previous(),
        visible: player.bind("can_go_prev"),
        child: Widget.Icon(PREV_ICON)
    });

    const next = Widget.Button({
        on_clicked: () => player.next(),
        visible: player.bind("can_go_next"),
        child: Widget.Icon(NEXT_ICON)
    });

    return Widget.Box(
        { class_name: "player" },
        cover,
        Widget.Box(
            {
                vertical: true,
                hexpand: true
            },
            Widget.Box([title, icon]),
            artist,
            Widget.Box({ vexpand: true }),
            positionSlider,
            Widget.CenterBox({
                start_widget: positionLabel,
                center_widget: Widget.Box({
                    spacing: 3,
                    children: [
                        prev,
                        playPause,
                        next
                    ]
                }),
                end_widget: lengthLabel
            })
        )
    );
}

export default ({ ...rest }) => Widget.Box({
    vertical: true,
    visible: players.as(p => p.length > 0),
    children: players.as(p => p.map(Player)),
    ...rest
});