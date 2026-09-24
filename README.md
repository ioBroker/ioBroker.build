# ioBroker.build

Windows installer Build installation packages for ioBroker.

Pre-requires:

- Node.js 22 or newer with NPM
- Windows to build .exe
- Internet connection, because the `nodejs` will be downloaded during the build.

## Build on windows:

1. download and extract to some directory: https://github.com/ioBroker/ioBroker.build/archive/master.zip, e.g. to `d:\ioBroker.build`

2. Start the console (cmd.exe) and go to `d:\ioBroker.build`:

```bash
d:
cd ioBroker.build
```

3. Install the build dependencies:

```bash
npm install
```

4. Build the installer. It will take a while:

```bash
npm run build
```

6. The result will be stored in `d:\ioBroker.build\delivery` as `iobroker-installer.exe`

### Single build steps

`npm run build` is the whole pipeline. The steps can also be called one by one:

| Script              | Description                                                                 |
|---------------------|-----------------------------------------------------------------------------|
| `npm run 0-clean`   | Remove `tmp`, `build/.windows-ready` and `delivery`                         |
| `npm run 1-version` | Write `build/.windows-ready/version.txt` with the version from package.json |
| `npm run 2-msi`     | Compile the installer with InnoSetup into `delivery`                        |
| `npm run 3-rename`  | Rename the compiled file to `delivery/iobroker-installer.exe`               |
| `npm run 4-sign`    | Sign the installer locally (requires `CERT_PASSWORD` and the certificate)   |

## InnoSetup

The compiler is **not installed** on the build machine, it is committed to this repository:

| Folder                      | Tool                                                    | Bundled version        |
|-----------------------------|---------------------------------------------------------|------------------------|
| `build/windows/InnoSetup6/` | Inno Setup, called as `ISCC.exe` (command line compiler) | 6.2.1 (2022-04-14)     |
| `build/windows/ezsign/`     | EZSignIt, used by `npm run 4-sign` only                  | 4.01                   |

So `npm install` and `npm run build` are all a Windows machine needs, and the GitHub action does not
have to install anything either.

- Download page (all versions): https://jrsoftware.org/isdl.php
- Releases and source code: https://github.com/jrsoftware/issrc
- License of the bundled copy: `build/windows/InnoSetup6/license.txt`

`ISCC.exe` reads `build/windows/ioBroker.iss` and needs these files from the same folder:

- `ISCmplr.dll` and `ISPP.dll` — the preprocessor, because the script works with `#define`/`#include`
- `Setup.e32`, `SetupLdr.e32` and the compression DLLs (`islzma*`, `is*zip`, `is*zlib`) — they are
  built into the produced .exe
- `Default.isl` and `Languages\*.isl` — the `[Languages]` section references them as `compiler:...`

The .exe files carry no version resource (`0.0.0.0`), so the version of the bundled copy is best read
from the first `<span class="ver">` entry in `build/windows/InnoSetup6/whatsnew.htm`.

### How to update InnoSetup

1. Take the current release of the **6.x** line from https://jrsoftware.org/isdl.php, e.g.
   https://github.com/jrsoftware/issrc/releases/download/is-6_7_3/innosetup-6.7.3.exe

2. Install it into a temporary folder in **portable mode**, so that it writes nothing into the
   registry and creates no uninstaller:

```bash
innosetup-6.7.3.exe /PORTABLE=1 /SILENT /DIR=d:\innosetup-new
```

3. Replace the content of `build/windows/InnoSetup6` with the content of `d:\innosetup-new`.
   The folder in the repository was copied from a *normal* installation, so it still contains
   `unins000.exe`, `unins000.dat` and `unins000.msg`. A portable installation does not create them
   and they are not needed — delete them instead of carrying them over.

4. Compile once and check that the new version is used:

```bash
npm run build
```

   `ISCC.exe` prints its copyright years on start, and `whatsnew.htm` gives the exact version.

5. Install the resulting `delivery/iobroker-installer.exe` on a test machine and click through the
   wizard. A new compiler version changes the setup program that is built into the .exe, and that is
   only really verified by running it.

6. Commit the folder with a changelog entry that names the new Inno Setup version.

Inno Setup 7 exists as well, but `ioBroker.iss` was never compiled with it. Stay on the 6.x line
until somebody has verified 7.x.

### EZSignIt

`build/windows/ezsign/` is EZSignIt 4.01 by Chris Long, obtained from
http://www.ssesetup.com/ezsignit.html. It is only used by `npm run 4-sign`, which signs a locally
built installer; the GitHub action signs the `delivery` folder with
[GermanBluefox/code-sign-action](https://github.com/GermanBluefox/code-sign-action) instead.

To update it, download the .ZIP from the author's website and replace the folder with its **complete,
unmodified** content — `build/windows/ezsign/redist.txt` allows redistribution only under that
condition, so do not delete single files from it.

## Changelog

# 3.4.0 (24.09.2026)

- (@GermanBluefox) Node.js 24 is now supported and recommended for new installations.

# 3.3.1 (01.12.2024)

- (Gaspode) Remove WinSW3.exe during deinstallation

# 3.3.0 (23.05.2024)

- (Gaspode) Make fixer after JS-Controller Upgrade optional
- (Gaspode) Offer Alpha updates (@next) of JS-Controller in expert mode
- (Gaspode) Allow JS-Controller downgrade (depending on installed version and available version in active repository)

# 3.2.0 (23.05.2024)

- (Gaspode) Execute fixer after JS-Controller Upgrade (required for JS-Controller 6)

# 3.1.0 (17.05.2024)

- (Gaspode) Update/Upgrade of JS-Controller implemented
- (Gaspode) Logging enhanced
- (Gaspode) Fixed: Checking Admin port after installation fails if Node.js was not installed when the installation started
- (Gaspode) Fixed: Set Admin port in expert mode failed in rare cases

# 3.0.1 (25.02.2024)

- (Gaspode) Cosmetic change for specific screen resolutions or scaling settings

# 3.0.0 (08.02.2024)

- (Gaspode) Changed detection of supported and recommended Node.js versions
- (Gaspode) Check for installer update at startup
- (bluefox) Corrected some texts

# 2.2.2 (17.07.2023)

- (Gaspode) Workaround for Node installation bug. In case that prefix directory is not created, the installer will create it

# 2.2.1 (30.04.2023)

- (Gaspode) Catch and handle several error conditions
- (Gaspode) Use a location for temporary files which causes less problems
- (Gaspode) Handle ampersand character properly when setting path variable

# 2.2.0 (18.04.2023)

- (Gaspode) Option added to set windows service startmode (auto, manual)
- (Gaspode) Uninstall: keep iobroker-data, but rename it to iobroker-data_backup
- (Gaspode) Allows changing the root folder for installations in expert mode
- (Gaspode) Fixed firewall rules

# 2.1.1 (30.03.2023)

- (Gaspode) Layout optimizations
- (Gaspode) Refactored and optimized code, cleanup
- (Gaspode) Support multi server installations in expert mode
- (Gaspode) Copy the installer itself to ioBroker directory and create shortcut
- (Gaspode) Recognize `stabilostick` installation folder and abort installation
- (Gaspode) Data migration for new installations implemented
- (Gaspode) Translations completed

# 2.1.0 (09.03.2023)

- (Gaspode) Implemented option to modify the Windows firewall
- (Gaspode) Ensured that the node path was set correctly when calling `npx`

# 2.0.0 (04.03.2023)

- (Gaspode) Improved look & feel, improved error handling, added several checks, implemented more options
- (Gaspode) added several languages

# 1.1.0 (21.05.2022)

- (bluefox) Initial release
