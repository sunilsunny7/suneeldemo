
const util = require('util');
const fsys = require('fs');
const exec = util.promisify(require('child_process').exec);
const fs = require('fs').promises;

const SUPPORTED_METADATA_TYPES = new Map([
    ['IntegrationProcedure', '    queries:Select id  FROM vlocity_ins__OmniScript__c WHERE vlocity_ins__IsActive__c = true AND vlocity_ins__IsProcedure__c =  true AND Name in'],
    ['DataRaptor', '    queries:select id,name from vlocity_cmt__DRBundle__c where name in ']])


async function main() {
    let oldManifestData = Buffer.from('');
    try {
   
        if (fsys.existsSync(`manifest/vlocitymerged.yaml`)) {
            console.log('here')
            const sfiMap = new Map();
            const regex = /VlocityDataPackType/
            var array = require("fs").readFileSync("manifest/vlocitymerged.yaml").toString().split(String.fromCharCode(10));
            for (let i = 0; i < array.length; i++) {
                const str=array[i];
                const trimmed=str.trim();
                if(regex.test(trimmed))
                {
                    const datapack1 = trimmed.split(':').pop();
                    const query=array[i+1].trim();
                    datapack=datapack1.trim();
                    const name=query.substring(query.indexOf("Name"),query.length);
                    if(name.includes('='))
                    {
                        const names=name.split('=').pop();
                        const finalName = names.split("'").join('');
                        if(sfiMap.has(datapack))
                        {
                            sfiMap.get(datapack).push(finalName);
                        }
                        else
                        {
                            sfiMap.set(datapack,new Array(finalName))
                        }
                    }
                    else if(name.includes('in') || name.includes('In'))
                    {    
                        let names=name.split('in').pop();
                        names = names.split("'").join('');
                        names=names.split("(").join('');
                        names=names.split(")").join('').split(',');
                        sfiMap.set(datapack,[...names]);
                    }   
                }
            }   
            let mergedString='';
            [...sfiMap.keys()].forEach(key => {
                mergedString+='  - VlocityDataPackType:'+key+'\n'
                let queryParms=' (';
                [...sfiMap.get(key)].forEach(value => {
                    const param='\''+value+'\''+','
                    queryParms+=param;
                });
                queryParms=queryParms.slice(0,-1);
                queryParms+=')';
                let query=SUPPORTED_METADATA_TYPES.get(key)+queryParms;
                
                mergedString+=query+'\n';
            });
            saveToFile(mergedString)
        }
    } catch (error) {
        console.error(error);
    } 
}

async function saveToFile(data) {
    try {
        await fs.writeFile(`manifest/sfimerged.yml`, Buffer.from(data));
        console.log(data);
        await addToGit('manifest/sfimerged.yml');
    } catch (error) {
        console.log('COULD NOT SAVE THE MANIFEST.');
        console.error(error);
    }
}

async function addToGit(fileName) {
    exec(`git add manifest/sfimerged.yml`);
}
async function mergeIfManifestAlreadyExistsThenSave(manifest, name) {

    let oldManifestData = Buffer.from('');
    try {
        if (fsys.existsSync(`manifest/feature_package.xml`)) {
            oldManifestData = await fs.readFile(`manifest/vlocitymerged.yaml`);
            let oldManifest = parse(Buffer.from(oldManifestData).toString());
            oldManifest.types.forEach((members, key) => {
                members.forEach((member) => manifest.addMember(key, member, true));
            });
        }
    } catch (error) {
        console.error(error);
    } finally {
        if (Buffer.compare(oldManifestData, Buffer.from(manifest.toXML())) !== 0) {
            saveToFile(manifest.toXML(), name);
        }
    }
}



main();
