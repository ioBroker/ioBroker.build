// To use this file in WebStorm, right click on the file name in the Project Panel (normally left) and select "Open Grunt Console"

/** @namespace __dirname */
/* jshint -W097 */// jshint strict:false
/*jslint node: true */
"use strict";

// README First:
// it must be done as admin:
// - npm install
// - grunt full (may with error, ignore it)
// - grunt default
// after that go to ioBroker.build/build/.windows-ready and start createSetup.bat

module.exports = function (grunt) {
    var fs          = require('fs');
    var http        = require('http');
    var https       = require('https');

    var srcDir      = __dirname + '/';
    var dstDir      = __dirname + '/delivery/';
    var gruntDir    = __dirname + '/build/';
    var pkg         = grunt.file.readJSON('package.json');
    var iocore      = {};//grunt.file.readJSON('io-package.json');
    srcDir          = srcDir.replace(/\\/g, '/');
    dstDir          = dstDir.replace(/\\/g, '/');
    gruntDir        = gruntDir.replace(/\\/g, '/');

    var version     = require(__dirname + '/package.json').version;

    var download = function(url, dest, cb) {
        var file = fs.createWriteStream(dest);
        var request = http.get(url, function(response) {
            response.pipe(file);
            file.on('finish', function() {
                file.close(cb);
            });
        });
    }

    //var couchDBlink = "http://apache.lauf-forum.at/couchdb/binary/win/1.6.1/setup-couchdb-1.6.1_R16B02.exe";
    var nodejslink86 = 'https://nodejs.org/dist/v4.5.0/node-v4.5.0-x86.msi';
    var nodejslink64 = 'https://nodejs.org/dist/v4.5.0/node-v4.5.0-x64.msi';

    // Project configuration.
    grunt.initConfig({
        pkg: pkg,
        curl: {
            'io-package': {
                src: 'https://github.com/ioBroker/ioBroker.<%= grunt.task.current.args[0] %>/raw/master/io-package.json',
                dest: 'tmp/ioBroker.<%= grunt.task.current.args[0] %>.io-package.json'
            },
            'iobroker': {
                src: 'https://github.com/ioBroker/ioBroker.<%= grunt.task.current.args[0] %>/archive/master.zip',
                dest: 'tmp/ioBroker.<%= grunt.task.current.args[0] %>.zip'
            }/*,
            'couchDB': {
                src: couchDBlink,
                dest: 'build/windows/couchDB/couchDBsetup.exe'
            }*/,
            'nodex86': {
                src: nodejslink86,
                dest: 'build/windows/nodejs/node.msi'
            },
            'nodex64': {
                src: nodejslink64,
                dest: 'build/windows/nodejs/node-x64.msi'
            }
        },
        clean: {
            all: [gruntDir + '.build', gruntDir + '.debian-pi-control', gruntDir + '.debian-pi-ready', gruntDir + '.windows-ready', "tmp"],
            'debian-pi-control': [gruntDir + '.debian-pi-ready/DEBIAN'],
            'debian-pi-control-sysroot': [gruntDir + '.debian-pi-ready/sysroot']
        },
        replace: {
            'debian-pi-version': {
                options: {
                    force: true,
                    patterns: [
                        {
                            match: 'version',
                            replacement: '<%= grunt.task.current.args[3] %>'
                        },
                        {
                            match: 'architecture',
                            replacement: '<%= grunt.task.current.args[2] %>'
                        },
                        {
                            match: "size",
                            replacement: '<%= grunt.task.current.args[0] %>'
                        },
                        {
                            match: "user",
                            replacement: '<%= grunt.task.current.args[1] %>'
                        },
                        {
                            match: "user",
                            replacement: '<%= grunt.task.current.args[1] %>'
                        },
                        {
                            match: /"node\-windows": "\~[\.0-9]*",/g,
                            replacement: ''
                        }
                    ]
                },
                files: [
                    {
                        expand:  true,
                        flatten: true,
                        src:     [gruntDir + 'debian/control/*'],
                        dest:    gruntDir + '.debian-pi-control/control/'
                    },
                    {
                        expand:  true,
                        flatten: true,
                        src:     [gruntDir + 'debian/redeb.sh'],
                        dest:    gruntDir + '.debian-pi-ready/'
                    },
                    {
                        expand:  true,
                        flatten: true,
                        src:     [gruntDir + 'debian/etc/init.d/iobroker.sh'],
                        dest:    gruntDir + '.debian-pi-control/'
                    }
                ]
            },
            'debian-pi-modules': {
                options: {
                    force: true,
                    patterns: [
                        {
                            match: /"node\-windows": "\~[\.0-9]*",/g,
                            replacement: ''
                        }
                    ]
                },
                files: [
                    {
                        expand:  true,
                        flatten: true,
                        src:     [gruntDir + '.debian-pi-ready/sysroot/opt/iobroker/package.json'],
                        dest:    gruntDir + '.debian-pi-ready/sysroot/opt/iobroker/'
                    }
                ]

            },
            windowsVersion: {
                options: {
                    force: true,
                    excludeBuiltins: true,
                    patterns: [
                        {
                            match: 'version',
                            replacement: '<%= grunt.task.current.args[0] %>'
                        }
                    ]
                },
                files: [
                    {
                        expand:  true,
                        flatten: true,
                        src:     [gruntDir + 'windows/ioBroker.iss'],
                        dest:    gruntDir + '.windows-ready/'
                    }
                ]
            },
            noNpm: {
                options: {
                    force: true,
                    excludeBuiltins: true,
                    patterns: [
                        {
                            match: /call npm install --production/,
                            replacement: ''
                        },
                        {
                            match: /npm install --production/g,
                            replacement: ''
                        }
                    ]
                },
                files: [
                    {
                        expand:  true,
                        flatten: true,
                        src:     [srcDir + 'tmp/data/node_modules/iobroker.js-controller/install.bat', srcDir + 'tmp/data/node_modules/iobroker.js-controller/install.sh'],
                        dest:    srcDir + 'tmp/data/node_modules/iobroker.js-controller/'
                    }
                ]

            }
        },
        copy: {
            static: {
                files: [
                    {
                        expand: true,
                        cwd: srcDir,
                        src: [
                            'cert/*',
                            'doc/*',
                            'scripts/*',
                            'www/control/**/*',
                            'www/lib/**/*',
                            'www/index.html',
                            '*.json',
                            '*.js',
                            'utils/*/**',
                            'adapter/scriptEngine/*',
                            'adapter/webServer/*',
                            'adapter/demoAdapter/*',
                            'adapter/email/*',
                            'adapter/pushover/*',
                            '!main.js',
                            '!speech.js'],
                        dest: '.build/'
                    }
                ]
            },
            'debian-pi-broker': {
                files: [
                    {
                        expand: true,
                        cwd: gruntDir + '../tmp/data/',
                        src: ['**/*', '!*.bat', '!Gruntfile.js', '!tasks/*'],
                        dest: gruntDir + '.debian-pi-ready/sysroot/opt/iobroker/'
                    }
                ]
            },
            'debian-pi': {
                files: [
                    {
                        expand: true,
                        cwd: gruntDir + '.debian-pi-control/control',
                        src: ['**/*'],
                        dest: gruntDir + '.debian-pi-ready/DEBIAN/'
                    },
                    {
                        expand: true,
                        cwd: gruntDir + '.debian-pi-control/',
                        src: ['iobroker.sh'],
                        dest: gruntDir + '.debian-pi-ready/sysroot/etc/init.d/'
                    }
                ]
            },
            'windows-broker':{
                files: [
                    {
                        expand: true,
                        cwd: gruntDir + '../tmp/data/',
                       src: ['**/*', '!node_modules/iobroker.js-controller/node_modules/**/*', '!iobroker-data', '!iobroker-data/**/*', '!install.sh', '!iobroker', '!Gruntfile.js', '!tasks/*'],
                        dest: gruntDir + '.windows-ready/data/'
                    }
                ]
            },
            windows: {
                files: [
                    {
                        expand: true,
                        cwd: gruntDir + 'windows',
                        src: ['*.js',
                            //'redis-*/**/*',
                            //'couchDB*/**/*',
                            'nodejs/**/*',
                            '*.ico', '*.bat', '*.json', '!*.sh', '!service_ioBroker.bat', '!_service_ioBroker.bat'],
                        dest: gruntDir + '.windows-ready/'
                    },
                    {
                        expand: true,
                        cwd: gruntDir + 'windows',
                        src: ['service_ioBroker.bat', '_service_ioBroker.bat', '*.cmd'],
                        dest: gruntDir + '.windows-ready/data/'
                    }
                ]
            },
            localRepository: {
                files: [
                    {
                        src: [gruntDir + 'io-repository.json'],
                        dest: './delivery/'
                    }
                ]
            },
            adapter:{
                files:
                [
                    {
                        expand: true,
                        cwd: srcDir + 'tmp/node_modules/iobroker.<%= grunt.task.current.args[0] %>/',
                        src: [
                            '**/*',
                            '!task.js',
                            '!Gruntfile.js'],
                        dest: srcDir + 'tmp/node_modules/iobroker.js-controller/adapter/<%= grunt.task.current.args[0] %>'
                    }
                ]
            }
        },
        lineending: {               // Task
            dist: {                   // Target
                options: {              // Target options
                    eol: 'lf',
                        overwrite: true
                },
                files: [
                    {
                        expand:  true,
                        flatten: true,
                        src:     [gruntDir + '.debian-pi-ready/redeb.sh']
                    },
                    {
                        expand:  true,
                        flatten: true,
                        src:     [gruntDir + '.debian-pi-control/control/*']
                    },
                    {
                        expand:  true,
                        flatten: true,
                        src:     [gruntDir + '.debian-pi-control/iobroker.sh']
                    }
                ]
            }
        },
        compress: {
            adapter: {
                options: {
                    archive: dstDir + '<%= grunt.task.current.args[1] %>'
                },
                files: [
                    {expand: true, src: ['**'],  dest: '/', cwd: srcDir + 'adapter/<%= grunt.task.current.args[0] %>/'}
                ]
            },
            'debian-pi-control': {
                options: {
                    archive: gruntDir + '.debian-pi-ready/control.tar.gz'
                },
                files: [
                    {
                        expand: true,
                        src: ['**/*'],
                        dest: '/',
                        cwd: gruntDir + '.debian-pi-control/control/'
                    }
                ]
            },
            'debian-pi-data': {
                options: {
                    archive: gruntDir + '.debian-pi-ready/data.tar.gz'
                },
                files: [
                    {
                        expand: true,
                        src: ['**/*'],
                        dest: '/',
                        cwd: gruntDir + '.debian-pi-ready/sysroot/'
                    }
                ]
            }
        },
        command: {
            makeWindowsMSI: {
                // type : 'bat',
                cmd: '"' + gruntDir + 'windows\\InnoSetup5\\ISCC.exe" "' + gruntDir + '.windows-ready\\ioBroker.iss" > "' + gruntDir + '.windows-ready\\setup.log"'
            },
            makeDebian: {
                // type : 'bat',
                cmd: 'cd ' + gruntDir + '.debian-pi-ready; sudo sh /redeb.sh && cp ioBroker* ../../delivery/'
            }
        },

        // Used for build repository
        unzip: {
            // Skip/exclude files via `router`
            unzipIo: {
                // If router returns a falsy varaible, the file will be skipped
                router: function (filepath) {
                    if (filepath.indexOf('io-addon.json') != -1 || filepath.indexOf('io-core.json') != -1 || filepath.indexOf('io-adapter.json') != -1) {
                        return filepath;
                    } else {
                        // Otherwise, skip it
                        return null;
                    }
                },
                src: [dstDir + '<%= grunt.task.current.args[0] %>'],
                dest: '.rep-work/<%= grunt.task.current.args[1] %>/'
            },
            iobroker: {
                src: ['tmp/ioBroker.<%= grunt.task.current.args[0] %>.zip'],
                dest: 'tmp/'
            },
            "iobroker-js-controller": {
                src: ['tmp/ioBroker.js-controller.zip'],
                dest: 'tmp/'
            }        },
        exec: {
            npm: {
                cmd: 'npm install --production',
                cwd: srcDir + "tmp/data/iobroker.js-controller"
            },
            "npm-adapter": {
                force: true,
                cmd: 'npm install --production',
                cwd: srcDir + "tmp/data/ioBroker.<%= grunt.task.current.args[0] %>-master"
            },
            "npm-npm-adapter": {
                force: true,
                cmd: 'npm install --prefix tmp/data iobroker.<%= grunt.task.current.args[0] %> --production',
                cwd: srcDir
            }
        }
    });

    grunt.registerTask('debian-pi-packet', function () {
        // Calculate size of directory
        var path = require('path');

        function readDirSize(item) {
            var stats = fs.lstatSync(item);
            var total = stats.size;

            if (stats.isDirectory()) {
                var list = fs.readdirSync(item);
                for (var i = 0; i < list.length; i++) {
                    total += readDirSize(path.join(item, list[i]));
                }
                return total;
            } else {
                return total;
            }
        }

        var size = 100000000;//readDirSize('tmp/ioBroker.js-controller-master');
        iocore = grunt.file.readJSON('tmp/data/node_modules/iobroker.js-controller/io-package.json');
        grunt.task.run([
            'clean:debian-pi-control',
            'replace:debian-pi-version:' + (Math.round(size / 1024) + 8) + ':pi:all:' + iocore.common.version, // Settings for debian
            'lineending',
            'copy:debian-pi',
            'replace:debian-pi-modules',
            'compress:debian-pi-data',
            'clean:debian-pi-control-sysroot'
        ]);
        if (/^linux/.test(process.platform)) {
            // This must be tested
            grunt.task.run(['makeDebian']);
        } else {
            console.log('========= Copy .debian-pi-ready directory to Raspbery PI and start "sudo bash redeb.sh" =============');
        }
    });

    grunt.registerTask('buildAllAdapters', function () {
        // Calculate size of directory
        var e = grunt.file.readJSON('tmp/ioBroker.js-controller-master/conf/sources-dist.json');
        var tasks = [];
        tasks.push('exec:npm');
        for (var adapter in e) {
            if (adapter == "js-controller") continue;
            if (adapter == "example") continue;
            if (adapter == "artnet") continue;
            if (adapter == "cul") continue;
            if (adapter == "highcharts") continue;
            if (adapter == "zwave") continue;

            if (!e[adapter].url)  {
                tasks.push('exec:npm-npm-adapter:' + adapter);
            } else {
                if (!grunt.file.exists(srcDir + 'tmp/ioBroker.' + adapter + '.zip'))
                    tasks.push('curl:iobroker:' + adapter);
                if (!grunt.file.isDir(srcDir + 'tmp/ioBroker.' + adapter + '-master'))
                    tasks.push('unzip:iobroker:' + adapter);
                if (!grunt.file.isDir(srcDir + 'tmp/ioBroker.' + adapter + '-master/node_modules'))
                    tasks.push('exec:npm-adapter:' + adapter);
                tasks.push('copy:adapter:' + adapter);
            }
        }
        grunt.task.run(tasks);
    });

    grunt.registerTask('loadIoPackage', function () {
        //iocore = grunt.file.readJSON('tmp/data/node_modules/iobroker.' + grunt.task.current.args[0] + '/io-package.json');
        grunt.task.run(['replace:windowsVersion:' + version]);
    });

    grunt.registerTask('windows-msi', function () {
        if (/^win/.test(process.platform)) {
            grunt.task.run(['replace:windowsVersion:' + version]);
            grunt.task.run([
//                'loadIoPackage:js-controller',
                'copy:windows',
                'command:makeWindowsMSI'
            ]);
            console.log('========= Please wait a little (ca 1 min). The msi file will be created in ioBroker/delivery directory after the grunt is finished.');
            console.log('========= you can start batch file .windows-ready\\createSetup.bat manually');
            // Sometimes command:makeWindowsMSI does not work, you can start batch file manually
            grunt.file.write(gruntDir + '.windows-ready\\createSetup.bat', '"' + gruntDir + 'windows\\InnoSetup5\\ISCC.exe" "' + gruntDir + '.windows-ready\\ioBroker.iss"');
        } else {
            console.log('Cannot create windows setup, while host is not windows');
        }
    });

    grunt.registerTask('create-data-dir', function () {
        if (!fs.existsSync(srcDir + 'tmp')) fs.mkdirSync(srcDir + 'tmp');
        if (!fs.existsSync(srcDir + 'tmp/data')) fs.mkdirSync(srcDir + 'tmp/data');
    });

    var gruntTasks = [
        'grunt-replace',
        'grunt-contrib-clean',
        'grunt-contrib-concat',
        'grunt-contrib-copy',
        'grunt-contrib-compress',
        'grunt-contrib-commands',
        'grunt-exec',
        'grunt-zip',
        'grunt-lineending',
        'grunt-curl'
    ];
    var i;

    for (i in gruntTasks) {
        grunt.loadNpmTasks(gruntTasks[i]);
    }

    grunt.registerTask('default', [
        'clean:all',
        ////'curl:io-package:js-controller',
        'curl:nodex86',
        'curl:nodex64',
        //'create-data-dir',
        ////'curl:couchDB',
        ////'curl:iobroker:js-controller',
        //'exec:npm-npm-adapter:js-controller',
        ////'unzip:iobroker:js-controller',
        'windows-msi'
        //'debian-pi-packet'
    ]);
    grunt.registerTask('full', [
        'clean:all',
        'curl:io-package:js-controller',
        'curl:nodex86',
        'curl:nodex64',
        //'curl:couchDB',
        'curl:iobroker:js-controller',
        'unzip:iobroker:js-controller',
        'buildAllAdapters',
        'replace:noNpm',
        'windows-msi'//,
//        'debian-pi-packet'
    ]);};