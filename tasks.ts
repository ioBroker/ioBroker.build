/*!
 * Build tasks for the ioBroker windows installer (replaces the former gulpfile.js).
 *
 * Executed with `tsx` (see the scripts in package.json), so this file is type checked by
 * tsconfig.json together with the rest of the repository.
 *
 * The pipeline, in the order the default task runs it:
 *
 * - `--0-clean`    removes `tmp/`, `build/.windows-ready/` and `delivery/`. InnoSetup names the
 *                  compiled file after the version, so a leftover from an older version would be
 *                  delivered together with the current one.
 * - `--1-version`  writes `build/.windows-ready/version.txt`, which `build/windows/ioBroker.iss`
 *                  `#include`s to get `MyAppVersion` from package.json.
 * - `--2-msi`      compiles the installer with InnoSetup to `delivery/ioBrokerInstaller.<version>.exe`
 *                  (`OutputDir`/`OutputBaseFilename` in the .iss file).
 * - `--3-rename`   renames it to `delivery/iobroker-installer.exe`, the name the signing step expects.
 *
 * `--4-sign` is a manual, local step: it needs the certificate and its password, and the GitHub
 * workflow signs the whole `delivery` folder with GermanBluefox/code-sign-action instead.
 *
 * Both external tools (Inno Setup and EZSignIt) are committed under `build/windows/`, so nothing has
 * to be installed or downloaded for a build. README.md says where they come from and how to update them.
 */
import { exec } from 'node:child_process';
import { copyFileSync, existsSync, mkdirSync, readFileSync, renameSync, unlinkSync, writeFileSync } from 'node:fs';
import { deleteFoldersRecursive } from '@iobroker/build-tools';

import { version } from './package.json';

const WINDOWS_READY = `${__dirname}/build/.windows-ready`;
/** The name that the signing step and the GitHub workflow work with */
const INSTALLER_EXE = `${__dirname}/delivery/iobroker-installer.exe`;
const CERTIFICATE = `${__dirname}/ioBrokerCodeSigningCertificate.pfx`;

function clean(): void {
    deleteFoldersRecursive(`${__dirname}/tmp`);
    deleteFoldersRecursive(WINDOWS_READY);
    deleteFoldersRecursive(`${__dirname}/delivery`);
}

function writeWindowsVersion(): void {
    if (!existsSync(WINDOWS_READY)) {
        mkdirSync(WINDOWS_READY);
    }
    writeFileSync(`${WINDOWS_READY}/version.txt`, `#define MyAppVersion "${version}"`);
}

/** Wait up to 15 seconds for all the given files (relative to this directory) to show up */
async function checkFiles(files: string[]): Promise<void> {
    for (let attempt = 0; ; attempt++) {
        if (files.every(file => existsSync(`${__dirname}/${file}`))) {
            return;
        }
        if (attempt >= 5) {
            throw new Error(`timeout ${files.join(', ')}`);
        }
        await new Promise(resolve => setTimeout(resolve, 3_000));
    }
}

/** Run a command, piping its output through, and resolve with its exit code */
function execute(cmd: string, options?: { cwd?: string }): Promise<number> {
    return new Promise((resolve, reject) => {
        const child = exec(cmd, options);
        child.stdout?.pipe(process.stdout);
        child.stderr?.pipe(process.stderr);
        child.on('error', reject);
        child.on('exit', code => resolve(code || 0));
    });
}

async function runMsi(): Promise<void> {
    await checkFiles(['build/windows/ioBroker.iss', 'build/windows/resource/ioBroker.ico']);

    // The compiler is not installed on the build machine: `build/windows/InnoSetup6` is a portable
    // copy of Inno Setup (https://jrsoftware.org/isdl.php) committed to this repository. See the
    // "InnoSetup" chapter of README.md for how to update it.
    // ISCC resolves the relative `#include`s of the .iss file against its working directory
    const cwd = `${__dirname.replace(/\\/g, '/')}/build/windows/`;
    const cmd = `"${__dirname}\\build\\windows\\InnoSetup6\\ISCC.exe" "${__dirname}\\build\\windows\\ioBroker.iss"`;
    console.log(`"${cmd} in ${cwd}`);

    const code = await execute(cmd, { cwd });
    // code 1 is a strange error that cannot be explained. Everything is compiled, but error :(
    if (code && code !== 1) {
        throw new Error(`Cannot install: ${code}`);
    }
    console.log(`"${cmd} in ${cwd} finished.`);
}

function rename(): void {
    const compiled = `${__dirname}/delivery/ioBrokerInstaller.${version}.exe`;
    if (existsSync(compiled) && existsSync(INSTALLER_EXE)) {
        unlinkSync(INSTALLER_EXE);
    }
    renameSync(compiled, INSTALLER_EXE);
}

/** Hide the certificate password in a command line that is about to be logged */
function hidePassword(cmd: string): string {
    return process.env.CERT_PASSWORD ? cmd.replace(process.env.CERT_PASSWORD, '*****') : cmd;
}

async function signExe(): Promise<void> {
    await checkFiles(['delivery/iobroker-installer.exe']);

    if (process.env.CERT_FILE) {
        const certificate = Buffer.from(process.env.CERT_FILE, 'base64');
        writeFileSync(CERTIFICATE, certificate);
        console.log(`Saved ${certificate.length} bytes in certificate`);
    } else if (existsSync(CERTIFICATE) && !existsSync(`${__dirname}/ioBrokerCodeSigningCertificate.base64.txt`)) {
        // Store the base64 form too, so it can be pasted into the CERT_FILE secret
        writeFileSync(
            `${__dirname}/ioBrokerCodeSigningCertificate.base64.txt`,
            readFileSync(CERTIFICATE).toString('base64'),
        );
    } else if (!existsSync(CERTIFICATE)) {
        throw new Error('NO cert file found');
    }

    const cmd =
        `${__dirname}\\build\\windows\\ezsign\\EZSignIt.exe ` +
        `/sn "${INSTALLER_EXE.replace(/\//g, '\\')}" ` +
        `/f "${CERTIFICATE.replace(/\//g, '\\')}" ` +
        `/p ${process.env.CERT_PASSWORD} ` +
        `/fd sha256 ` +
        `/nse ` +
        `/d "ioBroker windows installer" ` +
        `/trs2 "http://timestamp.comodoca.com/?td=sha256"`;

    console.log(`"${hidePassword(cmd)}`);

    const code = await execute(cmd);
    if (code) {
        const exitCodes = [
            '0 = Success',
            '1 = Invalid command-line or general program error',
            '2 = Certificate password is incorrect',
            '3 = Certificate could not be added / General certificate signing error',
            '4 = Timestamp not added / Timestamp server-related error',
            '5 = Signature Validation failed',
        ];

        throw new Error(`Cannot sign: ${exitCodes[code]} (${code})`);
    }

    console.log(`"${hidePassword(cmd)}" finished successfully.`);

    renameSync(INSTALLER_EXE, `${__dirname}/delivery/iobroker-installer-${version}.exe`);
    copyFileSync(
        `${__dirname}/delivery/iobroker-installer-${version}.exe`,
        `${__dirname}/delivery/iobroker-latest-windows-installer.exe`,
    );
}

async function windowsMsi(): Promise<void> {
    if (!process.platform.startsWith('win')) {
        console.warn('Cannot create windows setup, while host is not windows');
        return;
    }
    writeWindowsVersion();
    await runMsi();
    rename();
}

async function main(): Promise<void> {
    const argv = process.argv;

    if (argv.includes('--0-clean')) {
        clean();
    } else if (argv.includes('--1-version')) {
        writeWindowsVersion();
    } else if (argv.includes('--2-msi')) {
        await runMsi();
    } else if (argv.includes('--3-rename')) {
        rename();
    } else if (argv.includes('--4-sign')) {
        await signExe();
    } else if (argv.includes('--windows-msi')) {
        await windowsMsi();
    } else {
        clean();
        await windowsMsi();
    }
}

main().catch((error: unknown) => {
    console.error(`Cannot build: ${error instanceof Error ? error.message : String(error)}`);
    process.exit(1);
});
