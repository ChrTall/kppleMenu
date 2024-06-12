# Kpple Menu
The Kpple menu is a drop-down menu that is usually found on the left side of the menu bar.
The original maintainer does not seem actively maintaining the project anymore. In order to port the plasmoid to KF6 I created this fork.

## Previews

<p align="center">
    <img src="screenshots/light_kppleMenu.png" alt="light preview"> <img src="screenshots/dark_kppleMenu.png" alt="dark preview">
</p>

## Usage

Menu entries can be configured via the settings, if you tick the advanced settings checkbox.
Simply click on the entries to check if the configured command is working.
The commands should work on all Distributions with KDE Plasma 6, but might have to be adjusted manually.

### Keyboard Navigation

A global shortcut to expand the applet can be configured under settings -> Keyboard Shortcuts.
You can navigate through the menu with either tab and back-tab or arrow keys.
Selected Entries can be executed by pressing the return, enter or space key.
If the menu is expanded you can quickly:
- Lock the Screen, by pressing ctrl + alt + q
- Log out, by pressing shift + alt + q

## Missing Translations

If you are using a language, other than English or German some entries do not have a translation yet.
Feel free to create a PR after editing the corresponding `.po` file for your language under `package/translate`.

## How to install Kpple menu on KDE Plasma ?

The recommended installation method is via the KDE store.


#### You can also use another install method ( by git ) :1

Open a terminal and follow the steps below.
There is no guarantee that i18n works, when using this method.

```bash
git clone https://github.com/chrtall/kppleMenu.git
kpackagetool6 --type "Plasma/Applet" -i  kppleMenu/package
```

## License

GNU GPL v2.0

