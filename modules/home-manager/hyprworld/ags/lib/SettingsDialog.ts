import { bind } from "astal";
import { register } from "astal/gobject";
import { Gtk } from "astal/gtk4";
import Adw from "gi://Adw";
import Wp from "gi://AstalWp";

const audio = Wp.get_default()!.audio;

@register({ GTypeName: "SettingsDialog" })
export default class SettingsDialog extends Adw.Dialog {
  view: Adw.NavigationSplitView;
  audio: Adw.NavigationPage = this.createAudioPage();

  constructor() {
    super({
      title: "Settings",
      contentWidth: 800,
      contentHeight: 800,
    });

    this.view = new Adw.NavigationSplitView({
      sidebarWidthFraction: 0.3,
      minSidebarWidth: 200,
      maxSidebarWidth: 300,
    });

    this.set_child(this.view);

    this.view.set_sidebar(
      new Adw.NavigationPage({
        title: "Settings",
        child: this.createSidebar(),
      }),
    );

    this.view.set_content(this.audio);
  }

  private switchContent(page: Adw.NavigationPage) {
    if (this.view.get_content() !== page) {
      this.view.set_content(page);
    }
  }

  private createSidebar(): Gtk.Widget {
    const group = new Adw.PreferencesGroup({
      marginTop: 12,
      marginBottom: 12,
      marginStart: 12,
      marginEnd: 12,
    });

    const audioRow = new Adw.ActionRow({
      title: "Audio",
      activatable: true,
    });

    audioRow.add_prefix(
      new Gtk.Image({
        iconName: "audio-speakers-symbolic",
        marginEnd: 12,
      }),
    );

    audioRow.connect("activated", () => {
      this.switchContent(this.audio);
    });

    group.add(audioRow);

    const scrolled = new Gtk.ScrolledWindow({
      hscrollbarPolicy: Gtk.PolicyType.NEVER,
    });

    scrolled.set_child(new Adw.Clamp({ child: group }));
    return scrolled;
  }

  private createAudioPage(): Adw.NavigationPage {
    const devices = new Adw.PreferencesGroup({
      title: "Devices",
    });

    function addExpanderFromEndpoints(
      title: string,
      added: string,
      removed: string,
    ) {
      const expander = new Adw.ExpanderRow({ title });
      const buttonGroup = new Gtk.CheckButton();

      function createRow(endpoint: Wp.Endpoint) {
        const button = new Gtk.CheckButton({
          active: endpoint.get_is_default(),
          group: buttonGroup,
        });

        button.connect("toggled", () => {
          if (button.get_active()) {
            endpoint.set_is_default(true);
          }
        });

        const row = new Adw.ActionRow({
          title: endpoint.get_description(),
          activatableWidget: button,
        });

        row.add_prefix(button);
        return row;
      }

      const map = new Map();

      audio.connect(added, (_: Wp.Audio, endpoint: Wp.Endpoint) => {
        const row = createRow(endpoint);
        expander.add_row(row);
        map.set(endpoint, row);
      });

      audio.connect(removed, (_: Wp.Audio, endpoint: Wp.Endpoint) => {
        const row = map.get(endpoint);
        if (row !== undefined) {
          map.delete(endpoint);
          expander.remove(row);
        }
      });

      devices.add(expander);
    }

    addExpanderFromEndpoints("Speaker", "speaker-added", "speaker-removed");

    addExpanderFromEndpoints(
      "Microphone",
      "microphone-added",
      "microphone-removed",
    );

    const options = new Adw.PreferencesGroup({ title: "Options" });

    function createActionRow(
      title: string,
      endpoint: Wp.Endpoint,
      property: string,
    ) {
      const expander = new Adw.ExpanderRow({ title });

      const scale = new Gtk.Scale({
        orientation: Gtk.Orientation.HORIZONTAL,
        has_origin: true,
        hexpand: true,
      });

      scale.set_range(0, 100);
      scale.set_increments(10, 10);
      scale.set_value(endpoint.get_volume());

      scale.connect("value-changed", (self) => {
        const value = Math.floor(self.get_value() / 10) * 10;
        self.set_value(value);
      });

      function attach(endpoint: Wp.Endpoint) {
        bind(endpoint, "volume").subscribe((value: number) => {
          scale.set_value(value * 100);
        });
      }

      bind(audio, property).subscribe(attach);
      attach(endpoint);

      const row = new Adw.ActionRow({ title: "Level" });
      row.add_suffix(new Adw.Bin({ child: scale }));

      expander.add_row(row);
      return expander;
    }

    options.add(
      createActionRow("Speaker", audio.get_default_speaker(), "defaultSpeaker"),
    );

    options.add(
      createActionRow(
        "Microphone",
        audio.get_default_microphone(),
        "defaultMicrophone",
      ),
    );

    const page = new Adw.PreferencesPage();
    page.add(devices);
    page.add(options);

    return new Adw.NavigationPage({ title: "Audio", child: page });
  }
}
