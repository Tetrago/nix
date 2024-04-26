const $ = (label: string, name: string) => `$${label}: \\@${name};`;

const adapter = () => [
    $("fg",                    "theme_fg_color"),
    $("text",                  "theme_text_color"),
    $("bg",                    "theme_bg_color"),
    $("base",                  "theme_base_color"),
    $("selected-fg",           "theme_selected_fg_color"),
    $("selected-bg",           "theme_selected_bg_color"),
    $("insensitive-bg",        "insensitive_bg_color"),
    $("insensitive-fg",        "insensitive_fg_color"),
    $("insensitive-base",      "insensitive_base_color"),
    $("unfocused-fg",          "theme_unfocused_fg_color"),
    $("unfocused-text",        "theme_unfocused_text_color"),
    $("unfocused-bg",          "theme_unfocused_bg_color"),
    $("unfocused-base",        "theme_unfocused_base_color"),
    $("unfocused-selected-bg", "theme_unfocused_selected_bg_color"),
    $("unfocused-selected-fg", "theme_unfocused_selected_fg_color"),
    $("unfocused-insensitive", "unfocused_insensitive_color"),
    $("border",                "borders"),
    $("unfocused-border",      "unfocused_borders"),
    $("warning",               "warning_color"),
    $("error",                 "error_color"),
    $("success",               "success_color")
];

async function resetCss() {
    try {
        const vars = "/tmp/ags/vars.scss";
        await Utils.writeFile(adapter().join("\n"), vars);

        const fd = await Utils.execAsync(`fd ".scss" ${App.configDir}`);
        const files = fd.split(/\s+/).map(f => `@import '${f}';`);
        const scss = [`@import '${vars}';`, ...files].join("\n");
        const css = await Utils.execAsync(["bash", "-c", `echo "${scss}" | sass --scss --stdin`]);
        const style = css.replaceAll("\\@", "@");

        App.applyCss(style, true);
    } catch(err) {
        console.log(err)
        App.quit();
    }
}

Utils.monitorFile(App.configDir, resetCss);
await resetCss();

export {};