import Hyprland from "gi://AstalHyprland";
import { bind, Variable } from "astal";

const hyprland = Hyprland.get_default();

type Props = {
  monitor: number;
};

export default function Workspaces({ monitor }: Props) {
  return (
    <box
      spacing={5}
      cssClasses={bind(hyprland, "workspaces").as(
        (workspaces: Hyprland.Workspace[]) => [
          "Workspaces",
          ...(workspaces.some(
            (workspace) => workspace.get_name() == "special:scratchpad",
          )
            ? ["special"]
            : []),
        ],
      )}
    >
      {bind(
        Variable.derive(
          [
            bind(hyprland, "workspaces"),
            bind(hyprland, "focusedWorkspace"),
            bind(hyprland, "clients"),
          ],
          (workspaces) => {
            const list = new Array<Hyprland.Workspace | undefined>(10);
            list.fill(undefined);

            workspaces
              .filter((workspace) => workspace.id >= 1 && workspace.id <= 10)
              .forEach((workspace) => (list[workspace.id - 1] = workspace));

            return list.map((workspace, index) => {
              function switchWorkspace() {
                if (workspace !== undefined) {
                  workspace.focus();
                } else {
                  hyprland.dispatch(
                    "focusworkspaceoncurrentmonitor",
                    `${index + 1}`,
                  );
                }
              }

              if (workspace === undefined) {
                return (
                  <button onClicked={switchWorkspace}>
                    <label label={""} />
                  </button>
                );
              }

              const hasClients = workspace.clients.length > 0;
              const isLocalToMonitor = workspace.monitor.id === monitor;
              const isMonitorFocus =
                workspace.monitor.active_workspace.id === workspace.id;

              const icon = isMonitorFocus ? "" : hasClients ? "" : "";

              return (
                <button onClicked={switchWorkspace}>
                  <label
                    cssClasses={isLocalToMonitor ? ["local"] : []}
                    label={icon}
                  />
                </button>
              );
            });
          },
        ),
      )}
    </box>
  );
}
