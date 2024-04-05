const fs = require('fs').promises;
const ENVIRONMENT_FILE_NAME = 'manifest/ManifestScripts/.env.json';

async function main() {
    const argumentMap = {};
    process.argv.forEach((arg, index) => {
        if (index % 2 === 0) {
            argumentMap[arg] = process.argv[index + 1];
        }
    });

    upsertEnvironmentVariables(argumentMap['-t'], argumentMap['-f']);
}

async function upsertEnvironmentVariables(toBranch, fromBranch) {
    fromBranch = fromBranch.split('/').reverse()[0];
    let environment = {};
    environment[toBranch] = {
        fromBranch: fromBranch,
        branchedDate: new Date().getTime()
    };
    mergeIfManifestAlreadyExistsThenSave(environment);
}

async function mergeIfManifestAlreadyExistsThenSave(environment) {
    try {
        let oldEnvironmentData = await fs.readFile(ENVIRONMENT_FILE_NAME);
        let oldEnvironment = JSON.parse(Buffer.from(oldEnvironmentData).toString());

        const FILTER_TIME = new Date().getTime() - 60 * 60 * 24 * 100;
        Object.keys(oldEnvironment).forEach((key) => {
            if (new Date(oldEnvironment[key].branchedDate).getTime() > FILTER_TIME) {
                environment[key] = oldEnvironment[key];
            }
        });
    } catch (error) {
        //console.error('no need to log if manifest does not exists');
    } finally {
        saveToFile(JSON.stringify(environment, undefined, '\t'));
    }
}

async function saveToFile(data) {
    try {
        await fs.writeFile(ENVIRONMENT_FILE_NAME, Buffer.from(data));
    } catch (error) {
        console.log('Could not save the environment JSON.');
        console.error(error);
    }
}

main();
