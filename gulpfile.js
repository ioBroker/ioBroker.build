const gulp = require('gulp');
const axios = require('axios');
const fs = require('fs');
const path = require('path');
const version = require('./package.json').version;

function deleteFoldersRecursive(path, exceptions) {
    if (fs.existsSync(path)) {
        const files = fs.readdirSync(path);
        for (const file of files) {
            const curPath = `${path}/${file}`;
            if (exceptions && exceptions.find(e => curPath.endsWith(e))) {
                continue;
            }

            const stat = fs.statSync(curPath);
            if (stat.isDirectory()) {
                deleteFoldersRecursive(curPath);
                fs.rmdirSync(curPath);
            } else {
                fs.unlinkSync(curPath);
            }
        }
    }
}

function download(url, file) {
    const directoryName = path.dirname(file);
    if (!fs.existsSync(directoryName)) {
        fs.mkdirSync(directoryName);
    }

    return axios(url, {responseType: 'arraybuffer'})
        .then(response => fs.writeFileSync(file, response.data));
}

gulp.task('0-clean', done => {
    deleteFoldersRecursive(`${__dirname}/tmp`);
    deleteFoldersRecursive(`${__dirname}/build/.windows-ready`);
    deleteFoldersRecursive(`${__dirname}/delivery`);
    done();
});
gulp.task('3-0-replaceWindowsVersion', async () => {

    !fs.existsSync(`${__dirname}/build/.windows-ready`) && fs.mkdirSync(`${__dirname}/build/.windows-ready`);

    fs.writeFileSync(`${__dirname}/build/.windows-ready/version.txt`, `#define MyAppVersion "${version}"`);

    fs.writeFileSync(`${__dirname}/build/.windows-ready/createSetup.bat`, `"${__dirname}/build/windows/InnoSetup6/ISCC.exe" "${__dirname}/build/.windows-ready/ioBroker.iss"`);
});

gulp.task('3-1-copy', async () =>
    gulp.src([
        'build/windows/*.js',
        'build/windows/*.json',
        'build/windows/*.iss',
        '!service_ioBroker.bat',
        '!_service_ioBroker.bat'
    ])
        .pipe(gulp.dest('build/.windows-ready')));

gulp.task('3-1-copy-res', async () =>
    gulp.src([
        'build/windows/resource/*'
    ])
        .pipe(gulp.dest('build/.windows-ready/resource')));

gulp.task('3-1-copy-lang', async () =>
    gulp.src([
        'build/windows/language/*'
    ])
        .pipe(gulp.dest('build/.windows-ready/language')));

function _checkFiles(files, callback, index) {
    index = index || 0;

    if (files.find(file => !fs.existsSync(`${__dirname}/${file}`))) {
        if (index < 5) {
            setTimeout(() => _checkFiles(files, callback, index + 1), 3000);
        } else {
            callback('timeout ' + files.join(', '));
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
            'build/.windows-ready/resource/ioBroker.ico'
        ])
            .then(() => {
                // Install node modules
                const cwd = __dirname.replace(/\\/g, '/') + '/build/windows/';

                const cmd = `"${__dirname}\\build\\windows\\InnoSetup6\\ISCC.exe" "${__dirname}\\build\\windows\\ioBroker.iss"`;
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
        checkFiles([`delivery/iobroker-installer.exe`])
            .then(() => {
                // Install node modules
                if (process.env.CERT_FILE) {
                    fs.writeFileSync(`${__dirname}/ioBrokerCodeSigningCertificate.pfx`, Buffer.from(process.env.CERT_FILE, 'base64'));
                    console.log(`Saved ${Buffer.from(process.env.CERT_FILE, 'base64').length} bytes in certificate`);
                } else if (fs.existsSync(`${__dirname}/ioBrokerCodeSigningCertificate.pfx`) && !fs.existsSync(`${__dirname}/ioBrokerCodeSigningCertificate.base64.txt`)) {
                    fs.writeFileSync(`${__dirname}/ioBrokerCodeSigningCertificate.base64.txt`, fs.readFileSync(`${__dirname}/ioBrokerCodeSigningCertificate.pfx`).toString('base64'));
                } else if (!fs.existsSync(`${__dirname}/ioBrokerCodeSigningCertificate.pfx`)) {
                    throw new Error('NO cert file found');
                }

                const cmd = `${__dirname}\\build\\windows\\ezsign\\EZSignIt.exe ` +
                    `/sn "${__dirname}\\delivery\\iobroker-installer.exe" ` +
                    `/f "${__dirname}\\ioBrokerCodeSigningCertificate.pfx" ` +
                    `/p ${process.env.CERT_PASSWORD} ` +
                    `/fd sha256 ` +
                    `/nse ` +
                    `/d "ioBroker windows installer" ` +
                    `/trs2 "http://timestamp.comodoca.com/?td=sha256"`;

                console.log(`"${cmd.replace(process.env.CERT_PASSWORD, `*****${(process.env.CERT_PASSWORD || '').length + 5}`)}`);

                // System call used for update of js-controller itself,
                // because during installation npm packet will be deleted too, but some files must be loaded even during the installation process.
                const exec = require('child_process').exec;
                const child = exec(cmd);

                child.stderr.pipe(process.stderr);
                child.stdout.pipe(process.stdout);

                child.on('exit', (code /* , signal */) => {
                    // code 1 is strange error that cannot be explained. Everything is installed but error :(
                    if (code) {
                        const exitCodes = [
                            '0 = Success',
                            '1 = Invalid command-line or general program error',
                            '2 = Certificate password is incorrect',
                            '3 = Certificate could not be added / General certificate signing error',
                            '4 = Timestamp not added / Timestamp server-related error',
                            '5 = Signature Validation failed',
                        ];

                        reject(new Error(`Cannot sign: ${exitCodes[code]} (${code})`));
                    } else {
                        console.log(`"${cmd.replace(process.env.CERT_PASSWORD, `*****${(process.env.CERT_PASSWORD || '').length + 5}`)}" finished successfully.`);
                        // command succeeded
                        resolve();
                    }
                });
            })
            .catch(error => reject(error));
    });
}

gulp.task('3-3-runMSI', runMSI);
gulp.task('3-4-rename', async () => {
    if (fs.existsSync(`${__dirname}/delivery/ioBrokerInstaller.${version}.exe`) && fs.existsSync(`${__dirname}/delivery/iobroker-installer.exe`)) {
        fs.unlinkSync(`${__dirname}/delivery/iobroker-installer.exe`);
    }
    fs.renameSync(`${__dirname}/delivery/ioBrokerInstaller.${version}.exe`, `${__dirname}/delivery/iobroker-installer.exe`);
});
gulp.task('3-5-signExe-manually', signExe);

if (/^win/.test(process.platform)) {
    gulp.task('3-windows-msi', gulp.series(['3-0-replaceWindowsVersion', '3-1-copy', '3-1-copy-res', '3-1-copy-lang', '3-3-runMSI', '3-4-rename']));
} else {
    gulp.task('3-windows-msi', async () => console.warn('Cannot create windows setup, while host is not windows'));
}

gulp.task('default',  gulp.series(['0-clean', '3-windows-msi']));
