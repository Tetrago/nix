import GObject, { register, property } from "astal/gobject";
import { exec, subprocess } from "astal/process";

@register({ GTypeName: "SystemdService" })
export class Service extends GObject.Object {
  private name: string;
  #active: boolean;

  @property(Boolean)
  get active() {
    return this.#active;
  }

  constructor(name: string) {
    super();

    this.name = name;
    this.#active = this.isActive();

    subprocess({
      cmd: ["journalctl", "--user", "-u", name, "-f", "-n", "0", "-o", "json"],
      out: () => {
        this.#active = this.isActive();
        this.notify("active");
      },
    });
  }

  private isActive() {
    try {
      exec(["systemctl", "--user", "is-active", `${this.name}.service`]);
      return true;
    } catch (err) {
      return false;
    }
  }

  start() {
    exec(["systemctl", "--user", "start", `${this.name}.service`]);
  }

  stop() {
    exec(["systemctl", "--user", "stop", `${this.name}.service`]);
  }
}

export default class Systemd {
  private static instance: Systemd;
  private services = new Map<string, Service>();

  static get_default() {
    if (!this.instance) {
      this.instance = new Systemd();
    }

    return this.instance;
  }

  service(name: string) {
    if (this.services.has(name)) {
      return this.services.get(name)!;
    }

    const service = new Service(name);
    this.services.set(name, service);
    return service;
  }
}
