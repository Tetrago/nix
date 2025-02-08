import Hyprland from "gi://AstalHyprland";
import { bind, Variable } from "astal";

const hyprland = Hyprland.get_default();

export default function Workspaces(props: { monitor: number }) {
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
            bind(hyprland, "monitors"),
            bind(hyprland, "focused_workspace"),
            bind(hyprland, "clients"),
          ],
          (
            workspaces: Hyprland.Workspace[],
            monitors: Hyprland.Monitor[],
            focusedWorkspace: Hyprland.Workspace,
          ) => {
            const activeMonitor = monitors.find(
              (monitor) => monitor.get_id() === props.monitor,
            );
            const activeWorkspace = activeMonitor.get_active_workspace();

            return workspaces
              .filter((workspace) => workspace.get_id() >= 0)
              .sort((a, b) => a.get_id() - b.get_id())
              .map((workspace) => {
                const isLocalActive =
                  workspace.get_id() === activeWorkspace.get_id();
                const isGlobalActive =
                  workspace.get_id() == focusedWorkspace.get_id();
                const isLocal =
                  workspace.get_monitor().get_id() === activeMonitor.get_id();

                return (
                  <label
                    cssClasses={isLocal ? ["local"] : []}
                    label={
                      isLocalActive
                        ? "\uf111"
                        : isGlobalActive
                          ? "\uf192"
                          : "\uf4aa"
                    }
                  />
                );
              });
          },
        ),
      )}
    </box>
  );
}
