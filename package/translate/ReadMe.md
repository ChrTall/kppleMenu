# Translate

Menu action labels follow Apple's current localized naming. See
[Apple menu label references](AppleMenuLabels.md) for the per-language wording
and the official sources used to check it.

## Status

|  Locale  | Strings | % Done|
|----------|---------|-------|
| Template |      35 |       |
| ar       |   35/35 |  100% |
| de       |   35/35 |  100% |
| es       |   35/35 |  100% |
| fi       |   35/35 |  100% |
| fr       |   35/35 |  100% |
| hu       |   35/35 |  100% |
| it       |   35/35 |  100% |
| ja       |   35/35 |  100% |
| ko       |   35/35 |  100% |
| nl       |   35/35 |  100% |
| pl       |   35/35 |  100% |
| pt       |   35/35 |  100% |
| ro       |   35/35 |  100% |
| ru       |   35/35 |  100% |
| uk       |   35/35 |  100% |
| zh_CN    |   35/35 |  100% |
| zh_TW    |   35/35 |  100% |


## New Translations

* Fill out [`template.pot`](template.pot) with your translations then open a [new issue](https://github.com/ChrTall/kppleMenu/issues/new), name the file `spanish.txt`, attach the txt file to the issue (drag and drop).

Or if you know how to make a pull request

* Copy the `template.pot` file and name it your locale's code (Eg: `en`/`de`/`fr`) with the extension `.po`. Then fill out all the `msgstr ""`.
* Your region's locale code can be found at: https://stackoverflow.com/questions/3191664/list-of-all-locales-and-their-short-codes/28357857#28357857

## Scripts

Zren's `kpac` script can easily run the `gettext` commands for you, parsing the `metadata.json` and filling out any placeholders for you. `kpac` can be [downloaded here](https://github.com/Zren/plasma-applet-lib/blob/master/kpac) and should be placed at `~/Code/plasmoid-widgetname/kpac` to edit translations at `~/Code/plasmoid-widgetname/package/translate/`.


* `python3 ./kpac i18n` will parse the `i18n()` calls in the `*.qml` files and write it to the `template.pot` file. Then it will merge any changes into the `*.po` language files. Then it converts the `*.po` files to it's binary `*.mo` version and move it to `contents/locale/...` which will bundle the translations in the `*.plasmoid` without needing the user to manually install them.
* `python3 ./kpac localetest` will convert the `.po` to the `*.mo` files then run `plasmoidviewer` (part of `plasma-sdk`).

## How it works

Since KDE Frameworks v5.37, translations can be bundled with the zipped `*.plasmoid` file downloaded from the store.

* `xgettext` extracts the messages from the source code into a `template.pot`.
* Translators copy the `template.pot` to `fr.po` to translate the French language.
* When the source code is updated, we use `msgmerge` to update the `fr.po` based on the updated `template.pot`.
* When testing or releasing the widget, we convert the `.po` files to their binary `.mo` form with `msgfmt`.

The binary `.mo` translation files are placed in `package/contents/locale/` so you may want to add `*.mo` to your `.gitignore`.

```
package/contents/locale/fr/LC_MESSAGES/plasma_applet_com.github.chrtall.kppleMenu.mo
```

## Links

* https://develop.kde.org/docs/plasma/widget/translations-i18n/
* https://l10n.kde.org/stats/gui/trunk-kf5/team/fr/plasma-desktop/
* https://techbase.kde.org/Development/Tutorials/Localization/i18n_Build_Systems
* https://api.kde.org/frameworks/ki18n/html/prg_guide.html

> Version 8 of [Zren's i18n scripts](https://github.com/Zren/plasma-applet-lib).
