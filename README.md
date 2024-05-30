# ioBroker.build

Windows installer Build installation packages for ioBroker.

Pre-requires:

- Node.js with NPM
- Windows to build .exe
- Internet connection, because the `nodejs` will be downloaded by gulp.

#Build on windows:

1. download and extract to some directory: https://github.com/ioBroker/ioBroker.build/archive/master.zip, e.g. to `d:\ioBroker.build`

2. Start the console (cmd.exe) and go to `d:\ioBroker.build`:

```
   >d:
   >cd ioBroker.build
```

3. Install gulp-cli:

```
   >npm install
```

4. Call gulp. It will take a while:

```
   >npm run build
```

6. The result will be stored in `d:\ioBroker.build\delivery` as `ioBrokerInstaller.VX.y.z.exe`

## Changelog

### **WORK IN PROGRESS**

- (Gaspode) Make fixer after JS-Controller Upgrade optional
- (Gaspode) Offer Alpha and Beta updates (@next) of JS-Controller in expert mode
- (Gaspode) Allow JS-Controller downgrade to current version in expert mode

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
