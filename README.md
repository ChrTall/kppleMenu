# Kpple Menu
The Kpple menu is a drop-down menu that is usually found on the left side of the menu bar.
The original maintainer does not seem actively maintaining the project anymore. In order to port the plasmoid to KF6 I created this fork.

## Previews

<p align="center">
    <img src="screenshots/light_kppleMenu.png" alt="light preview"> <img src="screenshots/dark_kppleMenu.png" alt="dark preview">
</p>

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

