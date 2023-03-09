# ioBroker.build

Windows installer Build installation packages for ioBroker.

Pre-requires:
- Node JS with NPM
- Windows to build .exe
- Internet connection, because the **ioBroker.nodejs** will be downloaded by gulp.

#Build on windows:
1. download and extract to some directory: https://github.com/ioBroker/ioBroker.build/archive/master.zip, e.g. to *d:\ioBroker.build*

2. Start the console (cmd.exe) and go to *d:\ioBroker.build*:
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
# 2.1.0 (09.03.2023)
* (Gaspode) Implemented option to modify the Windows firewall
* (Gaspode) Ensured that the node path was set correctly when calling `npx`

# 2.0.0 (04.03.2023)
* (Gaspode) Improved look & feel, improved error handling, added several checks, implemented more options
* (Gaspode) added several languages

# 1.1.0 (21.05.2022)
* (bluefox) Initial release 

