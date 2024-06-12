# Translate

## Status

|  Locale  |  Lines  | % Done|
|----------|---------|-------|
| Template |      38 |       |
| ar       |   18/38 |   47% |
| de       |   38/38 |  100% |
| es       |   18/38 |   47% |
| fi       |   18/38 |   47% |
| fr       |   18/38 |   47% |
| hu       |   18/38 |   47% |
| it       |   18/38 |   47% |
| ja       |   18/38 |   47% |
| ko       |   18/38 |   47% |
| nl       |   18/38 |   47% |
| pl       |   17/38 |   44% |
| pt       |   18/38 |   47% |
| ro       |   18/38 |   47% |
| ru       |   18/38 |   47% |
| uk       |   18/38 |   47% |
| zh_CN    |   18/38 |   47% |
| zh_TW    |   18/38 |   47% |


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
package/contents/locale/fr/LC_MESSAGES/plasma_applet_org.chrtall.kppleMenu.mo
```

## Links

* https://develop.kde.org/docs/plasma/widget/translations-i18n/
* https://l10n.kde.org/stats/gui/trunk-kf5/team/fr/plasma-desktop/
* https://techbase.kde.org/Development/Tutorials/Localization/i18n_Build_Systems
* https://api.kde.org/frameworks/ki18n/html/prg_guide.html

> Version 8 of [Zren's i18n scripts](https://github.com/Zren/plasma-applet-lib).
