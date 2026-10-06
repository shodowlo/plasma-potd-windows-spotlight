# Windows Spotlight for Plasma

## About this fork

This fork is based on [liujed/plasma-potd-windows-spotlight](https://github.com/liujed/plasma-potd-windows-spotlight). It adds:

- a **region** setting (France, Belgium, Canada, United States, United Kingdom, Germany, Spain, Italy, Japan), France by default;
- a **Windows Spotlight wallpaper type**, with a settings page showing a preview, the title and the author;
- a **Refresh image** action, in the settings and in the desktop right-click menu;
- a **cache limit** setting: the oldest cached images are deleted beyond it;
- an **Open cache folder** button in the settings.

Two parts make up the project: the provider (`src/`) and the wallpaper type (`wallpaper/`).

## Building

```
mkdir build
cd build
cmake ..
make
```

If `cmake` cannot find `PlasmaPotdProvider` (on Kubuntu, the development package is missing), install that library into `~/.local` and add `-DCMAKE_PREFIX_PATH=$HOME/.local` to the `cmake` command.

## Installing

From the `build/` folder:

```
sudo install -m 755 bin/plasma_potd_windowsspotlightprovider.so /usr/lib/aarch64-linux-gnu/qt6/plugins/potd/
```

This path is for Ubuntu on ARM64. On other distributions it is often `/usr/lib/qt6/plugins/potd/`.

For the wallpaper type, from the project root:

```
mkdir -p ~/.local/share/plasma/wallpapers
cp -r wallpaper/org.local.windowsspotlight ~/.local/share/plasma/wallpapers/
plasmashell --replace &>/dev/null & disown
```

## Usage

1. Right-click the desktop and choose **Configure Desktop and Wallpaper**.
2. Set **Wallpaper type** to **Windows Spotlight**.
3. Choose the **Region**, then click **Apply**.

In the settings you can also:
- refresh the image (**Refresh image**);
- change how many images are kept in the cache;
- open the cache folder.

The desktop right-click menu also has **Refresh image**.

## Cache

Images are stored in `~/.cache/plasma_engine_potd/`. The oldest ones are deleted once the limit set in the settings is exceeded.

## Credits

This project is a fork of [Windows Spotlight picture-of-the-day provider](https://github.com/liujed/plasma-potd-windows-spotlight) by Jed Liu.

Adapted from the [Bing
provider](https://invent.kde.org/plasma/kdeplasma-addons/-/blob/a4c3aee27dbebdbe80421eb9257c4c7a99912b01/wallpapers/potd/plugins/providers/bingprovider.cpp)
by Weng Xuetian in the [KDE Plasma
Addons](https://invent.kde.org/plasma/kdeplasma-addons) library.

This project benefited from the [Spotlight APIv4
analysis](https://github.com/ORelio/Spotlight-Downloader/blob/master/SpotlightAPI.md#api-v4)
by [ORelio](https://github.com/ORelio) of the [Spotlight Downloader
project](https://github.com/ORelio/Spotlight-Downloader).
