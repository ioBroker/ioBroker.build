# ioBroker.build

Windows installer Build installation packages for ioBroker.

Pre-requires:
- Node JS with NPM
- Windows to build .exe and debian to build .deb
- Internet connection, because the **ioBroker.nodejs** will be downloaded by grunt.

#Build on windows:
1. download and extract to some directory: https://github.com/ioBroker/ioBroker.build/archive/master.zip, e.g. to *d:\ioBroker.build*

2. Start the console (cmd.exe) and go to *d:\ioBroker.build*:
```
   >d:
   >cd ioBroker.build
```

3. Install grunt-cli:
```
   >npm install grunt-cli -g
```

4. Get npm packages: 
```
   >npm install
```

5. Call grunt. It will take a while:
```
   >grunt
```

5. To finish .exe build, go to d:\ioBroker.build\build\.windows-ready and call createSetup.bat 
```
   >cd build\.windows-ready
   >createSetup.bat
```

6. The result will be stored in d:\ioBroker.build\delivery as ioBrokerInstaller.VX.y.z.exe




