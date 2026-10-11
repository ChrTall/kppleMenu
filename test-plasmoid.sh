#!/bin/bash
#  SPDX-FileCopyrightText: 2024 Christian Tallner <chrtall@gmx.de>
#
#  SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
package_dir="$script_dir/package"

usage() {
    echo "Usage: $0 [language]"
    echo "Without a language, uses the current desktop language."
    echo "Available languages:"
    printf '  %s\n' en en_US
    for catalog in "$package_dir"/translate/*.po; do
        catalog_name="${catalog##*/}"
        printf '  %s\n' "${catalog_name%.po}"
    done
}

if [[ $# -eq 1 && ( $1 == --help || $1 == -h ) ]]; then
    usage
    exit 0
fi
if [[ $# -gt 1 ]]; then
    usage >&2
    exit 1
fi

preview_language="${1:-}"
if [[ -n "$preview_language" && "$preview_language" != en && "$preview_language" != en_US ]]; then
    if [[ ! "$preview_language" =~ ^[a-z]{2,3}(_[A-Z]{2})?$ || ! -f "$package_dir/translate/$preview_language.po" ]]; then
        echo "Unknown language: $preview_language" >&2
        usage >&2
        exit 1
    fi
fi

for dependency in msgfmt python3 plasmoidviewer locale; do
    if ! command -v "$dependency" >/dev/null 2>&1; then
        echo "Required command not found: $dependency" >&2
        exit 1
    fi
done

plugin_id="$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["KPlugin"]["Id"])' "$package_dir/metadata.json")"
for catalog in "$package_dir"/translate/*.po; do
    catalog_name="${catalog##*/}"
    locale_dir="$package_dir/contents/locale/${catalog_name%.po}/LC_MESSAGES"
    mkdir -p "$locale_dir"
    msgfmt --check-format -o "$locale_dir/plasma_applet_$plugin_id.mo" "$catalog"
done

if [[ -n "$preview_language" ]]; then
    # Gettext suppresses translations in C locales, including C.UTF-8.
    # Prefer a matching locale so Qt also uses the appropriate text direction.
    preview_locale=""
    fallback_locale=""
    while IFS= read -r available_locale; do
        locale_name="${available_locale,,}"
        if [[ "$locale_name" != *.utf8 && "$locale_name" != *.utf-8 ]]; then
            continue
        fi
        if [[ "$locale_name" == c.* ]]; then
            continue
        fi
        if [[ -z "$fallback_locale" || "$locale_name" == en_us.utf8 || "$locale_name" == en_us.utf-8 ]]; then
            fallback_locale="$available_locale"
        fi
        case "$available_locale" in
            "$preview_language".*|"$preview_language"_*)
                preview_locale="$available_locale"
                break
                ;;
        esac
    done < <(locale -a)
    preview_locale="${preview_locale:-$fallback_locale}"
    if [[ -z "$preview_locale" ]]; then
        echo "Translation previews require an installed UTF-8 locale other than C.UTF-8 (for example, en_US.UTF-8)." >&2
        exit 1
    fi
    export LANG="$preview_locale"
    export LC_ALL="$preview_locale"
    # Stop untranslated strings falling back to another desktop language.
    export LANGUAGE="$preview_language:en_US"
fi

# Make package-local catalogs discoverable when loading the applet by path.
# Plasma can otherwise register them under the path rather than the plugin ID.
export XDG_DATA_DIRS="$package_dir/contents:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
export QT_LOGGING_RULES="qml.debug=true"
exec plasmoidviewer -s 800x800 -f horizontal -x 2200 -y 200 -a "$package_dir/"
