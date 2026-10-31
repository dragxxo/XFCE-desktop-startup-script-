# XFCE Desktop Startup Script for Termux

Set up an XFCE desktop environment on Android using
[Termux](https://termux.dev) and
[Termux:X11](https://github.com/termux/termux-x11). The installer
installs the required Termux packages and creates a `display` command
for launching the desktop.

> **Status:** Experimental --- use at your own risk. The installer
> updates Termux packages and may modify Android system settings through
> the selected launcher.

## Features

-   **Interactive installer** --- asks you to accept the disclaimer and
    choose a launcher script from `versions/`.
-   **Dependency setup** --- updates Termux, enables `x11-repo`, and
    installs the required packages.
-   **Dependency checks** --- checks that key commands are available
    after installation.
-   **Convenient launcher** --- links the selected version to
    `$PREFIX/bin/display`.
-   **Optional GPU and audio support** --- provided by the installed
    graphics and PulseAudio packages; available behavior depends on the
    selected launcher version.
-   **Optional Shizuku/rish integration** --- configure this manually if
    your launcher version uses it.

## Requirements

Install or prepare these manually before or after running the installer:

  --------------------------------------------------------------------------------
  Requirement                                  Notes
  -------------------------------------------- -----------------------------------
  [Termux](https://termux.dev)                 Run the installer from inside
                                               Termux.

  [Termux:X11                                  The Android APK is **not**
  app](https://github.com/termux/termux-x11)   installed by this script. Install
                                               it separately.

  Shizuku and `rish`                           Needed only if the selected
                                               launcher uses Shizuku integration.
                                               Set up Shizuku and place the `rish`
                                               executable at `~/rish`, then run
                                               `chmod +x ~/rish`. If supported by
                                               your launcher, use
                                               `--disable-shizuku` to skip this
                                               integration.

  Internet connection                          Required to update package lists
                                               and download packages.
  --------------------------------------------------------------------------------

## 🚀 One-Command Installation

Get your XFCE desktop environment up and running instantly. Copy and paste the single command below into your Termux terminal:

```bash
pkg update -y && pkg install git -y && git clone "https://github.com/dragxxo/XFCE-desktop-startup-script-.git" && cd XFCE-desktop-startup-script- && chmod +x install.sh && ./install.sh
```

```text
  _  _  ____   ___  ____    ____            _       _              
 ( \/ )(  _ \ / __)(  __)  (    \  ___  ___| |_ ___| |_ ___  _ __  
  )  (  ) _ (( (__  ) _)    ) D ( / _ \/ __| __/ _ \  _/ _ \| '_ \ 
 (_/\_)(____/ \___)(____)  (____/ \___/\___|\__\___/\__\___/| .__/ 

                                                            |_|    
```

### 📦 What this automated installer does:
1. **Validates Environment:** Ensures the script is running safely inside the native Termux app.
2. **Updates Repositories:** Syncs package managers and unlocks the crucial `x11-repo`.
3. **Installs Core Packages:** Resolves dependencies like `xfce4`, `dbus`, `mesa`, `virglrenderer-android`, and `pulseaudio`.
4. **Builds the Launcher:** Generates your global system shortcut link at `$PREFIX/bin/display`.


## Installation

Clone the project repository, then run the installer from the project
directory:

``` bash
pkg install git -y
git clone https://github.com/dragxxo/XFCE-desktop-startup-script-.git
cd XFCE-desktop-startup-script-
chmod +x install.sh
./install.sh
```

If your installer file has a different name, use that filename in the
final command.

### What the installer does

1.  Displays a disclaimer and asks you to accept it.
2.  Lists available scripts in `versions/`.
3.  Uses `advanced-display-v5.5.4.sh` by default if you press Enter.
4.  Updates and upgrades Termux packages.
5.  Enables `x11-repo`.
6.  Installs `xfce4`, `dbus`, `termux-x11-nightly`,
    `virglrenderer-android`, `mesa`, `pulseaudio`, `procps`, `grep`,
    `findutils`, and `coreutils`.
7.  Checks for the commands `xfce4-session`, `dbus-launch`,
    `termux-x11`, `virgl_test_server_android`, `pulseaudio`, `pgrep`,
    `pkill`, and `xargs`.
8.  Creates or updates the `display` launcher link in `$PREFIX/bin/`.

**Important:** The installer expects the `versions/` directory and the
default script `advanced-display-v5.5.4.sh` to exist beside the
installer. The Termux:X11 APK and Shizuku/rish setup are not installed
automatically.

## Usage

After a successful installation:

``` bash
display -s
```

Show the launcher's available options:

``` bash
display --help
```

The exact options depend on the selected launcher version. The README
for the existing launcher documents these options:

  -----------------------------------------------------------------------
  Option                              Description
  ----------------------------------- -----------------------------------
  `-s`, `--start`                     Start the desktop session

  `--no-gpu`                          Disable GPU acceleration and use
                                      software rendering, if supported

  `--no-audio`                        Disable audio output, if supported

  `--disable-shizuku`,                Skip Shizuku/rish integration, if
  `--disable-rish`                    supported

  `-vv`, `--verbose`                  Show logs in the terminal, if
                                      supported

  `-e`, `--stop`                      Stop the desktop session, if
                                      supported

  `-v`, `--version`                   Show the launcher version, if
                                      supported

  `-h`, `--help`                      Show help
  -----------------------------------------------------------------------

Example with optional features disabled:

``` bash
display -s --no-gpu --disable-shizuku
```

Use only flags listed by `display --help` for the version you selected.

## Troubleshooting

-   **Installer says it must run inside Termux:** Run it in the Termux
    app, not in a regular Android shell.
-   **Package update fails:** Check your internet connection and Termux
    package mirror, then retry.
-   **A package fails to install:** Run the installer again or install
    the missing package manually with `pkg install <package-name>`.
-   **A required command is missing:** Review the installer's
    dependency-check output and reinstall the package that provides the
    command.
-   **Termux:X11 does not open:** Confirm that the Termux:X11 Android
    APK is installed. The installer does not install the APK.
-   **Shizuku/rish errors:** Confirm Shizuku is running and `~/rish`
    exists and is executable. If the launcher supports it, try
    `--disable-shizuku`.
-   **Black screen or graphics problems:** If supported by your
    launcher, retry with `--no-gpu`.
-   **Desktop does not start:** Run `display --help` and follow the
    selected launcher's instructions. Check any log paths documented by
    that launcher.

## Project structure

``` text
.
├── install.sh
└── versions/
    └── advanced-display-v5.5.4.sh
```

Keep the launcher filename in `versions/` consistent with the default
filename configured in `install.sh`.

---

## 🌟 Support the Project

If this script saved you time setting up your mobile desktop environment, please consider giving it a star! It helps visibility and lets others find the project easily.

<p align="left">
  <a href="https://github.com/dragxxo/XFCE-desktop-startup-script-">
    <img src="https://img.shields.io/github/stars/dragxxo/XFCE-desktop-startup-script-?style=social" alt="GitHub stars" />
  </a>
</p>

Got feedback or ran into an issue? Feel free to open a thread in the **Issues** tab!


## Disclaimer

This project is experimental and provided **AS IS**, without warranty of
any kind. The installer updates Termux packages and the selected
launcher may interact with Android system settings. Review the scripts
before running them and use them at your own risk. The project author is
not responsible for damage or data loss.

## License

This program is licensed under the terms of the MIT license. Please see the [LICENSE](LICENSE) file for the full text.

