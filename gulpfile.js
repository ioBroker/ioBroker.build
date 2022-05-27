const gulp = require('gulp');
const axios = require('axios');
const fs = require('fs');
const del = require('del');
const path = require('path');
const version = require('./package.json').version;

const nodejsLink86 = 'https://nodejs.org/download/release/v14.19.3/node-v14.19.3-x86.msi';
const nodejsLink64 = 'https://nodejs.org/download/release/v14.19.3/node-v14.19.3-x64.msi';

function download(url, file) {
    const directoryName = path.dirname(file);
    if (!fs.existsSync(directoryName)) {
        fs.mkdirSync(directoryName);
    }

    return axios(url, {responseType: 'arraybuffer'})
        .then(response => fs.writeFileSync(file, response.data));
}

gulp.task('0-clean', () => del(['tmp/**/*', 'build/.windows-ready/**/*', 'delivery/**/*']));
gulp.task('1-nodex86', () => download(nodejsLink86, __dirname + '/build/windows/nodejs/node.msi'));
gulp.task('2-nodex64', () => download(nodejsLink64, __dirname + '/build/windows/nodejs/node-x64.msi'));
gulp.task('3-0-replaceWindowsVersion', async () => {
    await checkFiles(['build/windows/nodejs/node.msi', 'build/windows/nodejs/node-x64.msi']);

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

function _checkFiles(files, callback, index) {
    index = index || 0;

    if (files.find(file => !fs.existsSync(__dirname + '/' + file))) {
        if (index < 5) {
            setTimeout(() => _checkFiles(files, callback, index + 1), 3000);
        } else {
            callback('timeout ' + file);
        }
    } else {
        callback(null);
    }
}

function checkFiles(files) {
    return new Promise((resolve, reject) => _checkFiles(files, error => error ? reject(error) : resolve()));
}

function runMSI() {
    return new Promise((resolve, reject) => {
        checkFiles([
            'build/.windows-ready/ioBroker.iss',
            'build/.windows-ready/nodejs/node.msi',
            'build/.windows-ready/nodejs/node-x64.msi',
            'build/.windows-ready/ioBroker.ico'
        ])
            .then(() => {
                // Install node modules
                const cwd = __dirname.replace(/\\/g, '/') + '/build/windows/';

                const cmd = `"${__dirname}\\build\\windows\\InnoSetup6\\ISCC.exe" "${__dirname}\\build\\.windows-ready\\ioBroker.iss"`;
                console.log(`"${cmd} in ${cwd}`);

                // System call used for update of js-controller itself,
                // because during installation npm packet will be deleted too, but some files must be loaded even during the installation process.
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

function signExe() {
    return new Promise((resolve, reject) => {
        checkFiles([`delivery/ioBrokerInstaller.${version}.exe`])
            .then(() => {
                // Install node modules
                if (process.env.CERT_FILE) {
                    fs.writeFileSync(__dirname + '/ioBrokerCodeSigningCertificate.pfx', Buffer.from(process.env.CERT_FILE, 'base64'));
                    console.log('Saved ' + Buffer.from(process.env.CERT_FILE, 'base64').length  + ' bytes in certificate');
                } else if (fs.existsSync(__dirname + '/ioBrokerCodeSigningCertificate.pfx') && !fs.existsSync(__dirname + '/ioBrokerCodeSigningCertificate.base64.txt')) {
                    fs.writeFileSync(__dirname + '/ioBrokerCodeSigningCertificate.base64.txt', fs.readFileSync(__dirname + '/ioBrokerCodeSigningCertificate.pfx').toString('base64'));
                } else if (!fs.existsSync(__dirname + '/ioBrokerCodeSigningCertificate.pfx')) {
                    throw new Error('NO cert file found');
                }

                const cmd = `${__dirname}\\build\\windows\\ezsign\\EZSignIt.exe ` +
                    `/sn "${__dirname}\\delivery\\ioBrokerInstaller.${version}.exe" ` +
                    `/f "${__dirname}\\ioBrokerCodeSigningCertificate.pfx" ` +
                    `/p ${process.env.CERT_PASSWORD} ` +
                    `/fd sha256 ` +
                    `/nse ` +
                    `/d "ioBroker windows installer" ` +
                    `/trs2 "http://timestamp.comodoca.com/?td=sha256"`;

                console.log(`"${cmd.replace(process.env.CERT_PASSWORD, '*****' + (process.env.CERT_PASSWORD.lenght + 5))}`);

                // System call used for update of js-controller itself,
                // because during installation npm packet will be deleted too, but some files must be loaded even during the installation process.
                const exec = require('child_process').exec;
                const child = exec(cmd);

                child.stderr.pipe(process.stderr);
                child.stdout.pipe(process.stdout);

                child.on('exit', (code /* , signal */) => {
                    // code 1 is strange error that cannot be explained. Everything is installed but error :(
                    if (code && code !== 1) {
                        reject(new Error('Cannot sign: ' + code));
                    } else {
                        console.log(`"${cmd} finished.`);
                        // command succeeded
                        resolve();
                    }
                });
            })
            .catch(error => reject(error));
    });
}

gulp.task('3-3-runMSI', runMSI);
gulp.task('3-4-signExe', signExe);
gulp.task('3-5-rename', async () => {
    fs.renameSync(`${__dirname}/delivery/ioBrokerInstaller.${version}.exe`, `${__dirname}/delivery/ioBrokerInstaller.exe`);
});

if (/^win/.test(process.platform)) {
    gulp.task('3-windows-msi', gulp.series(['3-0-replaceWindowsVersion', '3-1-copy', '3-2-copy-nodejs', '3-3-runMSI', '3-4-signExe', '3-5-rename']));
} else {
    gulp.task('3-windows-msi', async () => console.warn('Cannot create windows setup, while host is not windows'));
}

gulp.task('default',  gulp.series(['0-clean', '1-nodex86', '2-nodex64', '3-windows-msi']));
