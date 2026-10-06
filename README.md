# Windows Spotlight for Plasma

Two parts show Windows Spotlight images as wallpaper on KDE Plasma 6:

- **The provider** (`src/`): a C++ library that downloads the image.
- **The wallpaper type** (`wallpaper/`): a Plasma wallpaper type with its settings.

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
