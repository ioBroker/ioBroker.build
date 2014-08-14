ioBroker.build
==============

Build installation packages for ioBroker.

Prerequires:
- Node JS with NPM
- Windows to build .exe and debian to build .deb
- Internet connection, because the ioBroker.nodejs will be downloaded by grunt.

#Build on windows:
1. download and extract to some directory: https://github.com/ioBroker/ioBroker.build/archive/master.zip, e.g. d:\ioBroker.build

2. Start the console (cmd.exe) and go to d:\ioBroker.build:
<pre>
   >d:
   >cd ioBroker.build
</pre>

3. Install grunt-cli:
<pre>
   >npm install grunt-cli -g
</pre>

4. Get npm packages: 
<pre>
   >npm install
</pre>

5. Call grunt. It will take a while:
<pre>
   >grunt
</pre>

5. To finish .exe build, go to d:\ioBroker.build\build\.windows-ready and call createSetup.bat 
<pre>
   >cd build\.windows-ready
   >createSetup.bat
</pre>

6. The result will be stored in d:\ioBroker.build\delivery as ioBrokerInstaller.VX.y.z.exe

7. To build .deb, copy the directory d:\ioBroker.build\build\.debian-pi-ready to debian and call
<pre>
   #sudo sh redeb.sh
</pre>
The file ioBroker-VX.y.z.deb will be created.


#Build on Debian:
1. download and extract to some directory: https://github.com/ioBroker/ioBroker.build/archive/master.zip, e.g. /tmp/ioBroker.build
<pre>
   #cd /tmp
   #wget https://github.com/ioBroker/ioBroker.build/archive/master.zip
   #unzip master.zip
</pre>

2. Install grunt-cli:
<pre>
   #npm install grunt-cli -g
</pre>

3. Get npm packages: 
<pre>
   #npm install
</pre>

4. Call grunt. It will take a while:
<pre>
   #grunt
</pre>

5. To build .deb, go the directory build/.debian-pi-ready to debian and call
<pre>
   #cd build/.debian-pi-ready
   #sudo sh redeb.sh
</pre>
The file ioBroker-VX.y.z.deb will be created.



