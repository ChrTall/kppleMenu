#!/bin/bash
#  SPDX-FileCopyrightText: 2024 Christian Tallner <chrtall@gmx.de>
#
#  SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
package_dir="$script_dir/package"

usage() {
    echo "Usage: $0"
    echo "Compile all translation catalogs into package/contents/locale/."
}

if [[ $# -eq 1 && ( $1 == --help || $1 == -h ) ]]; then
    usage
    exit 0
fi
if [[ $# -ne 0 ]]; then
    usage >&2
    exit 1
fi

for dependency in msgfmt python3; do
    if ! command -v "$dependency" >/dev/null 2>&1; then
        echo "Required command not found: $dependency" >&2
        exit 1
    fi
done

shopt -s nullglob
catalogs=("$package_dir"/translate/*.po)
if [[ ${#catalogs[@]} -eq 0 ]]; then
    echo "No translation catalogs found in $package_dir/translate/." >&2
    exit 1
fi

plugin_id="$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["KPlugin"]["Id"])' "$package_dir/metadata.json")"
for catalog in "${catalogs[@]}"; do
    catalog_name="${catalog##*/}"
    locale_dir="$package_dir/contents/locale/${catalog_name%.po}/LC_MESSAGES"
    mkdir -p "$locale_dir"
    msgfmt --check-format -o "$locale_dir/plasma_applet_$plugin_id.mo" "$catalog"
done

echo "Compiled ${#catalogs[@]} translation catalogs into $package_dir/contents/locale/."
