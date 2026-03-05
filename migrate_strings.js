const fs = require('fs');
const path = require('path');

const androidResPath = 'c:/projects/sd/sd-android/app/src/main/res';
const iosResourcesPath = 'c:/projects/sd/sd-ios/Resources';

const langMap = {
    'values': 'en',
    'values-tr': 'tr',
    'values-az': 'az',
    'values-de': 'de',
    'values-es': 'es',
    'values-fr': 'fr',
    'values-id': 'id',
    'values-kk': 'kk',
    'values-ky': 'ky',
    'values-ru': 'ru',
    'values-tk': 'tk',
    'values-uz': 'uz',
    'values-zh': 'zh'
};

function migrateStrings() {
    for (const [dir, lang] of Object.entries(langMap)) {
        const androidFile = path.join(androidResPath, dir, 'strings.xml');
        if (!fs.existsSync(androidFile)) {
            console.log(`Skipping ${androidFile} (not found)`);
            continue;
        }

        const iosDir = path.join(iosResourcesPath, `${lang}.lproj`);
        if (!fs.existsSync(iosDir)) {
            fs.mkdirSync(iosDir, { recursive: true });
        }

        const iosFile = path.join(iosDir, 'Localizable.strings');
        const content = fs.readFileSync(androidFile, 'utf8');

        // Simple XML parsing for strings
        const stringRegex = /<string name="([^"]+)">([\s\S]*?)<\/string>/g;
        let match;
        let iosStrings = '';

        while ((match = stringRegex.exec(content)) !== null) {
            let key = match[1];
            let value = match[2]
                .replace(/\\'/g, "'")
                .replace(/\\"/g, '"')
                .replace(/\\n/g, '\n')
                .replace(/&amp;/g, '&')
                .replace(/&lt;/g, '<')
                .replace(/&gt;/g, '>')
                .replace(/%([0-9]+\$)?s/g, '%@') // Convert string placeholders
                .replace(/%([0-9]+\$)?d/g, '%d') // Convert digit placeholders
                .replace(/"/g, '\\"'); // Escape quotes for iOS

            iosStrings += `"${key}" = "${value}";\n`;
        }

        fs.writeFileSync(iosFile, iosStrings, 'utf8');
        console.log(`Migrated ${lang} strings to ${iosFile}`);
    }
}

migrateStrings();
