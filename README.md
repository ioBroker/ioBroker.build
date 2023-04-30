# ioBroker.build

Windows installer Build installation packages for ioBroker.

Pre-requires:

- Node JS with NPM
- Windows to build .exe
- Internet connection, because the **ioBroker.nodejs** will be downloaded by gulp.

#Build on windows:

1. download and extract to some directory: https://github.com/ioBroker/ioBroker.build/archive/master.zip, e.g. to _d:\ioBroker.build_

2. Start the console (cmd.exe) and go to _d:\ioBroker.build_:

```
   >d:
   >cd ioBroker.build
```

3. Install grunt-cli:

```
   >npm install
```

4. Call gulp. It will take a while:

```
   >npm run build
```

5. To finish .exe build, go to d:\ioBroker.build\build\.windows-ready and call createSetup.bat

```
   >cd build\.windows-ready
   >createSetup.bat
```

6. The result will be stored in d:\ioBroker.build\delivery as ioBrokerInstaller.VX.y.z.exe

## Changelog

# 2.2.1 (30.04.2023)
- (Gaspode) Catch and handle several error conditions
- (Gaspode) Use a location for temporary files which causes less problems
- (Gaspode) Handle ampersand character properly when setting path variable

# 2.2.0 (18.04.2023)
- (Gaspode) Option added to set windows service startmode (auto, manual)
- (Gaspode) Uninstall: keep iobroker-data, but rename it to iobroker-data_backup
- (Gaspode) Allow to change the root folder for installations in expert mode
- (Gaspode) Fixed firewall rules

# 2.1.1 (30.03.2023)

- (Gaspode) Layout optimizations
- (Gaspode) Refactored and optimzed code, cleanup
- (Gaspode) Support multi server installations in expert mode
- (Gaspode) Copy the installer itself to ioBroker directory and create shortcut
- (Gaspode) Recognize stabilostick installation folder and abort installation
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
