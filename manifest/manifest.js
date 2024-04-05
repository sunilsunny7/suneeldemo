/*
    How to use this script

    To run this script use write "node manifest/ManifestScripts/manifest.js"

    Command to alias this to use it by simply typing manifest in terminal.
    alias manifest="node manifest/ManifestScripts/manifest.js"

    Prerequisites:
    * Install Node

    Added Feature
    * Add this script to your pre-commit hook by running this command
    * git config --local core.hooksPath manifest/ManifestScripts/Hooks

*/

const util = require('util');
const exec = util.promisify(require('child_process').exec);
const fs = require('fs').promises;
const { Manifest, parse, SUPPORTED_METADATA_TYPES, DEFAULT_METADATA_PATH } = require('./xmlbuilder.js');

//  https://stackoverflow.com/questions/37763836/how-to-make-git-diff-show-the-same-result-as-githubs-pull-request-diff
//  diffQA: 'git --no-pager diff --cached --name-only Origin/QA'
const GIT_COMMANDS = {
    BRANCH_NAME: 'git rev-parse --abbrev-ref HEAD',
    CACHED_DIFF: 'git --no-pager diff --cached --name-only',
    COMPARATIVE_DIFF_WITH_QA: (fromBranch, branchName) => {
        return `git --no-pager diff --name-only origin/${fromBranch} origin/${branchName}`;
    }
};

async function main() {
    const branchName = await getBranchName();
    const comparativeDiffResult = await getDiff(GIT_COMMANDS.COMPARATIVE_DIFF_WITH_QA(await getFromBranch(branchName), branchName));
    const cachedDiff = await getDiff(GIT_COMMANDS.CACHED_DIFF);

    let manifest = new Manifest(await getApiVersion());
    [...comparativeDiffResult, ...cachedDiff].forEach((file) => {
        let pathComponents = stripFilePath(file).split('/');

        if (pathComponents[0] === 'objects' && pathComponents.length === 4 && SUPPORTED_METADATA_TYPES.has(pathComponents[2])) {
            pathComponents = [pathComponents[2], `${pathComponents[1]}.${pathComponents[3]}`];
        }

        if (pathComponents[1].includes('.')) {
            pathComponents[1] = pathComponents[1].substring(0, pathComponents[1].lastIndexOf('.'));
        }

        manifest.addMember(pathComponents[0], pathComponents[1]);
    });
    mergeIfManifestAlreadyExistsThenSave(manifest, branchName);
}

async function getApiVersion() {
    try {
        let data = await fs.readFile('./sfdx-project.json');
        return JSON.parse(Buffer.from(data).toString()).sourceApiVersion;
    } catch (error) {
        return '52.0';
    }
}

async function getBranchName() {
    const { stdout, stderr } = await exec(GIT_COMMANDS.BRANCH_NAME);
    if (stderr) throw new Error('Could not get git branch name');
    let branchName = stdout.replace(/\n|\r/g, '');
    if (!branchName.startsWith('mas') && !branchName.startsWith('dev') && !branchName.startsWith('manifest-maker')) {
        throw new Error('Manifest script was not ran, as you are not in a ticket branch please move to a EP-XXXXX or NOCT-XXXXX branch.');
    }
    return branchName;
}

async function getFromBranch(branchName) {
    try {
        let data = await fs.readFile('manifest/ManifestScripts/.env.json');
        return JSON.parse(Buffer.from(data).toString())[branchName].fromBranch;
    } catch (error) {
        return 'dev';
    }
}

async function getDiff(command) {
    const { stdout, stderr } = await exec(command);
    if (stderr) return [];
    let files = stdout.trim().split('\n');
    if (Array.isArray(files) && files.length > 0) {
        files = files.filter((f) => f.includes(DEFAULT_METADATA_PATH));
    }
    return files;
}

function stripFilePath(file) {
    return file.replace(DEFAULT_METADATA_PATH, '').replace('.xml', '');
}

async function mergeIfManifestAlreadyExistsThenSave(manifest, name) {
	console.log(name)
	name='package'
    let oldManifestData = Buffer.from('');
    try {
        oldManifestData = await fs.readFile(`manifest/${name}.xml`);
        let oldManifest = parse(Buffer.from(oldManifestData).toString());
        oldManifest.types.forEach((members, key) => {
            members.forEach((member) => manifest.addMember(key, member, true));
        });
    } catch (error) {
        console.error('no need to log if manifest does not exists');
    } finally {
        if (Buffer.compare(oldManifestData, Buffer.from(manifest.toXML())) !== 0) {
            saveToFile(manifest.toXML(), name);
        }
    }
}

async function saveToFile(data, name) {
    try {
        await fs.writeFile(`manifest/${name}.xml`, Buffer.from(data));
        await addToGit(name);
    } catch (error) {
        console.log('COULD NOT SAVE THE MANIFEST.');
        console.error(error);
    }
}

async function addToGit(fileName) {
    exec(`git add manifest/${fileName}.xml`);
}

main();
