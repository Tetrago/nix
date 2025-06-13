#!/usr/bin/env sh

usage() {
    cat <<EOF
flake.nix project templater.

Usage: flakey [-h] init [-e] <template>
       flakey [-h] list

Options:
    -e, --envrc     Create an .envrc file.
    -h, --help      Show additional usage information.
EOF
}

help() {
    usage
    cat <<EOF

Variables:
    TEMPLATE_DIR    = ${TEMPLATE_DIR:-NULL}
EOF
}

init() {
    [ "$1" = "-e" ] || [ "$1" = "--envrc" ] && shift
    _envrc=$?

    if [ -z "$1" ]; then
        usage
        exit 1
    fi

    if [ ! -f "$TEMPLATE_DIR/$1.nix" ]; then
        echo "Template not found."
        exit 1
    fi

    cp "$TEMPLATE_DIR/$1.nix" flake.nix

    if [ $_envrc -eq 0 ]; then
        echo "use flake" >.envrc && direnv allow
    fi
}

list() {
    echo "Templates:"

    for file in "$TEMPLATE_DIR"/*.nix; do
        file="${file%.nix}"
        printf "\t%s\n" "${file#"${TEMPLATE_DIR%/}/"}"
    done
}

if [ "$#" -eq 0 ]; then
    usage
    exit 0
fi

if [ -z "$TEMPLATE_DIR" ] || [ ! -d "$TEMPLATE_DIR" ]; then
    echo "TEMPLATE_DIR is invalid."
    exit 1
fi

while [ "$#" -gt 0 ]; do
    case "$1" in
    -h | --help)
        help
        exit 0
        ;;
    init)
        shift
        init "$@"
        exit 0
        ;;
    list)
        shift
        list
        exit 0
        ;;
    esac
done
