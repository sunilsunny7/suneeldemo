const DEFAULT_METADATA_PATH = 'force-app/main/default/';
const SUPPORTED_METADATA_TYPES = new Map([
    ['aura', 'AuraDefinitionBundle'],
    ['classes', 'ApexClass'],
    ['components', 'ApexComponent'],
    ['compactLayouts', 'CompactLayout'],
    ['customPermissions', 'CustomPermission'],
    ['fields', 'CustomField'],
    ['flexipages', 'FlexiPage'],
    ['flows', 'Flow'],
    ['labels', 'CustomLabels'],
    ['layouts', 'Layout'],
    ['lwc', 'LightningComponentBundle'],
    ['listViews', 'ListView'],
    ['messageChannels', 'LightningMessageChannel'],
    ['pages', 'ApexPage'],
    ['objects', 'CustomObject'],
    ['permissionsets', 'PermissionSet'],
    ['queues', 'Queue'],
    ['quickActions', 'QuickAction'],
    ['staticresources', 'StaticResource'],
    ['tabs', 'CustomTab'],
    ['triggers', 'ApexTrigger'],
    ['validationRules', 'ValidationRule'],
    ['workflows', 'Workflow'],
    ['assignmentRules', 'AssignmentRule']
]);

class Manifest {
    constructor(version = '52.0') {
        this.comment = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>';
        this.package = {
            start: '<Package xmlns="http://soap.sforce.com/2006/04/metadata">',
            end: '</Package>'
        };
        this.types = new Map();
        this.version = version;
    }

    addMember(type, name, trust = false) {
        if (!type || !name) {
            console.error('type and name must de defined.');
            return;
        }

        if (!SUPPORTED_METADATA_TYPES.has(type) && !trust) {
            console.error(`${type} is not supported.`);
            return;
        }

        let xmlType = trust ? type : SUPPORTED_METADATA_TYPES.get(type);
        if (!this.types.has(xmlType)) {
            this.types.set(xmlType, new Set());
        }

        if (type === 'labels') {
            name = '*';
        }

        this.types.get(xmlType).add(name);
    }

    createTypes() {
        let types = [];
        this.types.forEach((members, name) => {
            let tags = ['    <types>'];
            [...members].forEach((member) => tags.push(createTag('members', member, 2)));
            tags.push(createTag('name', name, 2));
            types.push(tags.join('\n'));
            types.push('    </types>');
        });
        return types.join('\n');
    }

    toXML() {
        if (this.types.size === 0) return '';
        return [this.comment, this.package.start, this.createTypes(), createTag('version', this.version, 1), this.package.end].join('\n');
    }
}

function createTag(type, value, indentLevel = 0) {
    var tag = '';
    for (let i = 0; i < indentLevel; i++) {
        tag += '    ';
    }
    tag += `<${type}>${value}</${type}>`;
    return tag;
}

function parse(xml) {
    let manifest = new Manifest();

    xml = xml.substring(xml.indexOf('<types>'), xml.lastIndexOf('<version>'));
    xml = xml.replaceAll('<types>', '');
    xml = xml.replace(/(\r\n|\n|\r)/gm, '');
    xml = xml.trim();

    xml.split('</types>').forEach((type) => {
        type = type.trim();
        let name = type.substring(type.indexOf('<name>') + 6, type.indexOf('</name>'));
        type = type.substring(0, type.indexOf('<name>'));

        type.split('</members>').forEach((tc) => {
            let value = tc.substring(tc.indexOf('<members>') + 9, tc.length);
            if (!!value && !!name) {
                manifest.addMember(name, value, true);
            }
        });
    });

    return manifest;
}

module.exports = {
    Manifest,
    parse,
    SUPPORTED_METADATA_TYPES,
    DEFAULT_METADATA_PATH
};
