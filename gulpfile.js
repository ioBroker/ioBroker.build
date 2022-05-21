const gulp = require('gulp');
const axios = require('axios');
const fs = require('fs');
const del = require('del');
const {version} = require("./package.json");

const nodejsLink86 = 'https://nodejs.org/download/release/v14.19.2/node-v14.19.2-x86.msi';
const nodejsLink64 = 'https://nodejs.org/download/release/v14.19.2/node-v14.19.2-x64.msi';

function download(url, file) {
    return axios(url, {
        responseType: 'arraybuffer',
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/pdf'
        }
    })
        .then(response => fs.writeFileSync(file, response.data));
}

gulp.task('0-clean', () => del(['tmp/**/*', 'build/.windows-ready/**/*']));
gulp.task('1-nodex86', async () => download(nodejsLink86, __dirname + '/build/windows/nodejs/node.msi'));
gulp.task('2-nodex64', async () => download(nodejsLink64, __dirname + '/build/windows/nodejs/node-x64.msi'));
gulp.task('3-0-replaceWindowsVersion', async () => {
    const version = require('./package.json').version;
    !fs.existsSync(__dirname + '/build/.windows-ready') && fs.mkdirSync(__dirname + '/build/.windows-ready');

    let iss = fs.readFileSync(__dirname + '/build/windows/ioBroker.iss').toString('utf8');
    iss = iss.replace('@@version', version)
    fs.writeFileSync(__dirname + '/build/.windows-ready/ioBroker.iss', iss);

    fs.writeFileSync(`${__dirname}/build/.windows-ready/createSetup.bat`, `"${__dirname}/build/windows/InnoSetup6/ISCC.exe" "${__dirname}/build/.windows-ready/ioBroker.iss"`);
});

gulp.task('3-1-copy', async () =>
    gulp.src([
        'build/windows/*.js',
        'build/windows/*.ico',
        'build/windows/*.bat',
        'build/windows/*.json',
        '!service_ioBroker.bat',
        '!_service_ioBroker.bat',
        '!*.iss'
    ])
        .pipe(gulp.dest('build/.windows-ready')));

gulp.task('3-2-copy-nodejs', async () =>
    gulp.src([
        'build/windows/nodejs/**/*',
    ])
        .pipe(gulp.dest('build/.windows-ready/nodejs')));

function _checkFiles(callback, index) {
    index = index || 0;
    const files = [
        'build/.windows-ready/ioBroker.iss',
        'build/.windows-ready/nodejs/node.msi',
        'build/.windows-ready/nodejs/node-x64.msi',
        'build/.windows-ready/ioBroker.ico'
    ];

    if (files.find(file => !fs.existsSync(__dirname + '/' + file))) {
        if (index < 5) {
            setTimeout(() => _checkFiles(callback, index + 1), 3000);
        } else {
            callback('timeout');
        }
    } else {
        callback(null);
    }
}

function checkFiles() {
    return new Promise((resolve, reject) => _checkFiles(error => error ? reject(error) : resolve()));
}

function runMSI() {
    return new Promise((resolve, reject) => {
        checkFiles()
            .then(() => {
                // Install node modules
                const cwd = __dirname.replace(/\\/g, '/') + '/build/windows/';

                const cmd = `"${__dirname}\\build\\windows\\InnoSetup6\\ISCC.exe" "${__dirname}\\build\\.windows-ready\\ioBroker.iss"`;
                console.log(`"${cmd} in ${cwd}`);

                // System call used for update of js-controller itself,
                // because during installation npm packet will be deleted too, but some files must be loaded even during the install process.
                const exec = require('child_process').exec;
                const child = exec(cmd, {cwd});

                child.stderr.pipe(process.stderr);
                child.stdout.pipe(process.stdout);

                child.on('exit', (code /* , signal */) => {
                    // code 1 is strange error that cannot be explained. Everything is installed but error :(
                    if (code && code !== 1) {
                        reject(new Error('Cannot install: ' + code));
                    } else {
                        console.log(`"${cmd} in ${cwd} finished.`);
                        // command succeeded
                        resolve();
                    }
                });
            })
            .catch(error => reject(error));
    });
}

gulp.task('3-3-runMSI', runMSI);

if (/^win/.test(process.platform)) {
    gulp.task('3-windows-msi', gulp.series(['3-0-replaceWindowsVersion', '3-1-copy', '3-2-copy-nodejs', '3-3-runMSI']));
} else {
    gulp.task('3-windows-msi', async () => console.warn('Cannot create windows setup, while host is not windows'));
}

gulp.task('default',  gulp.series(['0-clean', '1-nodex86', '2-nodex64', '3-windows-msi']));
