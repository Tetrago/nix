import Hyprland from "gi://AstalHyprland";
import { bind, Variable } from "astal";

const hyprland = Hyprland.get_default();

type Props = {
  monitor: number;
};

export default function Workspaces({ monitor }: Props) {
  return (
    <box
      visible={bind(hyprland, "workspaces").as(
        (workspaces) => workspaces.length > 1,
      )}
      spacing={5}
      cssClasses={bind(hyprland, "workspaces").as(
        (workspaces: Hyprland.Workspace[]) => [
          "Workspaces",
          ...(workspaces.some((workspace) => workspace.get_id() < 0)
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

            return list.map((workspace) => {
              if (!workspace) {
                return <label label={"\uf4aa"} />;
              }

              const hasClients = workspace.clients.length > 0;
              const isLocalToMonitor = workspace.monitor.id === monitor;
              const isMonitorFocus =
                workspace.monitor.active_workspace.id === workspace.id;

              const icon = isMonitorFocus
                ? "\uf111"
                : hasClients
                  ? "\uf192"
                  : "\uf4aa";

              return (
                <label
                  cssClasses={isLocalToMonitor ? ["local"] : []}
                  label={icon}
                />
              );
            });
          },
        ),
      )}
    </box>
  );
}
