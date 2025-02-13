import { bind } from "astal";
import { register } from "astal/gobject";
import { Gtk } from "astal/gtk4";
import Adw from "gi://Adw";
import Wp from "gi://AstalWp";
import Notifd from "gi://AstalNotifd";
import NotificationRow from "./NotificationRow";

const audio = Wp.get_default()!.audio;
const notifd = Notifd.get_default();

@register({ GTypeName: "SettingsWindow" })
export default class SettingsWindow extends Adw.Window {
  static instance: SettingsWindow | undefined = undefined;
  view: Adw.NavigationSplitView;
  audio: Adw.NavigationPage = this.createAudioPage();
  notifications: Adw.NavigationPage = this.createNotificationsPage();

  static show() {
    if (this.instance === undefined) {
      this.instance = new SettingsWindow();
      this.instance.present();
    }
  }

  constructor() {
    super({
      title: "Settings",
      defaultWidth: 800,
      defaultHeight: 800,
    });

    this.view = new Adw.NavigationSplitView({
      sidebarWidthFraction: 0.3,
      minSidebarWidth: 200,
      maxSidebarWidth: 300,
      sidebar: new Adw.NavigationPage({
        title: "Settings",
        child: this.createSidebar(),
      }),
      content: this.audio,
    });

    this.set_content(this.view);

    this.connect("close-request", () => {
      SettingsWindow.instance = undefined;
      this.destroy();
    });
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

    function addPage(title: string, icon: string, callback: () => void) {
      const row = new Adw.ActionRow({
        title,
        activatable: true,
      });

      row.add_prefix(
        new Gtk.Image({
          iconName: icon,
          marginEnd: 12,
        }),
      );

      row.connect("activated", callback);

      group.add(row);
    }

    addPage("Audio", "audio-speakers-symbolic", () =>
      this.switchContent(this.audio),
    );

    addPage("Noficiations", "bell-symbolic", () =>
      this.switchContent(this.notifications),
    );

    return new Gtk.ScrolledWindow({
      hscrollbarPolicy: Gtk.PolicyType.NEVER,
      child: new Adw.Clamp({ child: group }),
    });
  }

  private createAudioPage(): Adw.NavigationPage {
    const devices = new Adw.PreferencesGroup({
      title: "Devices",
    });

    function addExpanderFromEndpoints(
      title: string,
      added: string,
      removed: string,
      property: keyof Wp.Audio,
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

      audio[property].forEach((endpoint: Wp.Endpoint) => {
        const row = createRow(endpoint);
        expander.add_row(row);
        map.set(endpoint, row);
      });

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

    addExpanderFromEndpoints(
      "Speaker",
      "speaker-added",
      "speaker-removed",
      "speakers",
    );

    addExpanderFromEndpoints(
      "Microphone",
      "microphone-added",
      "microphone-removed",
      "microphones",
    );

    const options = new Adw.PreferencesGroup({ title: "Options" });

    function createActionRow(
      title: string,
      endpoint: Wp.Endpoint,
      property: keyof Wp.Audio,
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
      createActionRow(
        "Speaker",
        audio.get_default_speaker()!,
        "defaultSpeaker",
      ),
    );

    options.add(
      createActionRow(
        "Microphone",
        audio.get_default_microphone()!,
        "defaultMicrophone",
      ),
    );

    const page = new Adw.PreferencesPage();
    page.add(devices);
    page.add(options);

    const toolbar = new Adw.ToolbarView({ content: page });
    toolbar.add_top_bar(new Adw.HeaderBar());

    return new Adw.NavigationPage({ title: "Audio", child: toolbar });
  }

  private createNotificationsPage() {
    const list = new Gtk.ListBox({
      selectionMode: Gtk.SelectionMode.NONE,
      cssClasses: ["content"],
    });

    const scrolled = new Gtk.ScrolledWindow({
      hscrollbarPolicy: Gtk.PolicyType.NEVER,
      vexpand: true,
      child: list,
    });

    const bin = new Adw.Bin({
      child: scrolled,
      marginStart: 12,
      marginEnd: 12,
      marginBottom: 12,
    });

    const clearButton = new Gtk.Button({
      iconName: "edit-clear-symbolic",
      tooltipText: "Clear all notifications",
    });

    const header = new Adw.HeaderBar();
    header.pack_end(clearButton);

    const toolbar = new Adw.ToolbarView({ content: bin });
    toolbar.add_top_bar(header);

    const notifications = new Map<number, Gtk.Widget>();

    clearButton.connect("clicked", () => {
      notifications.forEach((_, id) => notifd.get_notification(id)?.dismiss());
    });

    notifd.connect("notified", (_, id) => {
      const row = new NotificationRow(notifd.get_notification(id));

      notifications.set(id, row);
      list.prepend(row);
    });

    notifd.connect("resolved", (_, id) => {
      const widget = notifications.get(id);
      if (widget !== undefined) {
        list.remove(widget);
      }

      notifications.delete(id);
    });

    return new Adw.NavigationPage({ title: "Notifications", child: toolbar });
  }
}
