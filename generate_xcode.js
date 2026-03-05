const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const projectName = 'SDiOS';
const orgName = 'com.subtracker';

function genUUID() {
    return crypto.randomBytes(12).toString('hex').toUpperCase();
}

function getFilesRecursively(dir, fileList = []) {
    const files = fs.readdirSync(dir);
    for (const file of files) {
        if (file === '.git' || file === 'SDiOS.xcodeproj' || file === 'generate_xcode.js' || file === 'node_modules' || file === 'migrate_strings.js') continue;
        const filePath = path.join(dir, file);
        if (fs.statSync(filePath).isDirectory()) {
            if (filePath.endsWith('.lproj')) {
                fileList.push(filePath);
            } else {
                getFilesRecursively(filePath, fileList);
            }
        } else if (filePath.endsWith('.swift') || filePath.endsWith('.strings') || filePath === 'Info.plist') {
            fileList.push(filePath);
        }
    }
    return fileList;
}

const allFiles = getFilesRecursively('.');

let pbxBuildFile = '';
let pbxFileReference = '';
let pbxGroup = '';
let pbxSourcesBuildPhase = '';
let pbxResourcesBuildPhase = '';
let pbxVariantGroup = '';

const rootGroupId = genUUID();
const appGroupId = genUUID();
const productsGroupId = genUUID();
const sourcesPhaseId = genUUID();
const resourcesPhaseId = genUUID();
const mainTargetId = genUUID();
const productRefId = genUUID();

const groups = {
    '.': { id: appGroupId, children: [], name: projectName, path: '""' }
};

function getGroupPath(filePath) {
    if (filePath === 'Info.plist') return '.';
    const defaultGroup = '.';
    const relativePart = path.relative('.', path.dirname(filePath));
    return relativePart === '' ? defaultGroup : relativePart;
}

function createGroups(filePath) {
    if (filePath === 'Info.plist') return appGroupId;
    const parts = getGroupPath(filePath).split(path.sep);
    let currentPath = '.';
    for (let i = 0; i < parts.length; i++) {
        if (parts[i] === '.') continue;
        const parentPath = currentPath;
        currentPath = currentPath === '.' ? parts[i] : path.join(currentPath, parts[i]);
        if (!groups[currentPath]) {
            groups[currentPath] = {
                id: genUUID(),
                children: [],
                name: parts[i],
                path: parts[i]
            };
            groups[parentPath].children.push(groups[currentPath].id);
        }
    }
    return groups[currentPath].id;
}

let stringsFiles = [];
let localizableVariantId = genUUID();

for (const filePath of allFiles) {
    const ext = path.extname(filePath);
    const fileName = path.basename(filePath);

    if (ext === '.strings') {
        const lang = path.basename(path.dirname(filePath)).replace('.lproj', '');
        const fileRefId = genUUID();
        // Set path to en.lproj/Localizable.strings (relative to VariantGroup's path)
        const relPath = path.relative('Resources', filePath).replace(/\\/g, '/');
        pbxFileReference += `\t\t${fileRefId} /* ${lang} */ = {isa = PBXFileReference; lastKnownFileType = text.plist.strings; name = ${lang}; path = ${relPath}; sourceTree = "<group>"; };\n`;
        stringsFiles.push(fileRefId);
        continue;
    }

    const fileRefId = genUUID();
    const buildFileId = genUUID();
    const groupId = createGroups(filePath);

    groups[getGroupPath(filePath)].children.push(fileRefId);

    if (ext === '.swift') {
        pbxFileReference += `\t\t${fileRefId} /* ${fileName} */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ${fileName}; sourceTree = "<group>"; };\n`;
        pbxBuildFile += `\t\t${buildFileId} /* ${fileName} in Sources */ = {isa = PBXBuildFile; fileRef = ${fileRefId} /* ${fileName} */; };\n`;
        pbxSourcesBuildPhase += `\t\t\t\t${buildFileId} /* ${fileName} in Sources */,\n`;
    } else if (fileName === 'Info.plist') {
        pbxFileReference += `\t\t${fileRefId} /* ${fileName} */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = ${fileName}; sourceTree = "<group>"; };\n`;
    }
}

if (stringsFiles.length > 0) {
    const buildFileId = genUUID();
    pbxVariantGroup += `\t\t${localizableVariantId} /* Localizable.strings */ = {\n\t\t\tisa = PBXVariantGroup;\n\t\t\tchildren = (\n`;
    for (const ref of stringsFiles) {
        pbxVariantGroup += `\t\t\t\t${ref} /* ${ref} */,\n`;
    }
    // Set path to Resources so it resolves Resources/en.lproj/Localizable.strings
    pbxVariantGroup += `\t\t\t);\n\t\t\tname = Localizable.strings;\n\t\t\tpath = Resources;\n\t\t\tsourceTree = "<group>";\n\t\t};\n`;
    groups['.'].children.push(localizableVariantId);
    pbxBuildFile += `\t\t${buildFileId} /* Localizable.strings in Resources */ = {isa = PBXBuildFile; fileRef = ${localizableVariantId} /* Localizable.strings */; };\n`;
    pbxResourcesBuildPhase += `\t\t\t\t${buildFileId} /* Localizable.strings in Resources */,\n`;
}

pbxFileReference += `\t\t${productRefId} /* ${projectName}.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = ${projectName}.app; sourceTree = BUILT_PRODUCTS_DIR; };\n`;

for (const [groupPath, groupInfo] of Object.entries(groups)) {
    pbxGroup += `\t\t${groupInfo.id} /* ${groupInfo.name} */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n`;
    for (const childId of groupInfo.children) {
        pbxGroup += `\t\t\t\t${childId},\n`;
    }
    pbxGroup += `\t\t\t);\n\t\t\tname = ${groupInfo.name};\n\t\t\tpath = ${groupInfo.path};\n\t\t\tsourceTree = "<group>";\n\t\t};\n`;
}

pbxGroup += `\t\t${productsGroupId} /* Products */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t${productRefId} /* ${projectName}.app */,\n\t\t\t);\n\t\t\tname = Products;\n\t\t\tsourceTree = "<group>";\n\t\t};\n`;

pbxGroup += `\t\t${rootGroupId} = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t${appGroupId} /* ${projectName} */,\n\t\t\t\t${productsGroupId} /* Products */,\n\t\t\t);\n\t\t\tsourceTree = "<group>";\n\t\t};\n`;

const pbxprojContent = `// !$*UTF8*$!
{
\tarchiveVersion = 1;
\tclasses = {
\t};
\tobjectVersion = 56;
\tobjects = {

/* Begin PBXBuildFile section */
${pbxBuildFile}
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
${pbxFileReference}
/* End PBXFileReference section */

/* Begin PBXGroup section */
${pbxGroup}
/* End PBXGroup section */

/* Begin PBXVariantGroup section */
${pbxVariantGroup}
/* End PBXVariantGroup section */

/* Begin PBXNativeTarget section */
\t\t${mainTargetId} /* ${projectName} */ = {
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = BuildConfigListA /* Build configuration list for PBXNativeTarget "${projectName}" */;
\t\t\tbuildPhases = (
\t\t\t\t${sourcesPhaseId} /* Sources */,
\t\t\t\t${resourcesPhaseId} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = ${projectName};
\t\t\tproductName = ${projectName};
\t\t\tproductReference = ${productRefId} /* ${projectName}.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\tProjectObjectId /* Project object */ = {
\t\t\tisa = PBXProject;
\t\t\tattributes = {
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastUpgradeCheck = 1500;
\t\t\t\tTargetAttributes = {
\t\t\t\t\t${mainTargetId} = {
\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;
\t\t\t\t\t};
\t\t\t\t};
\t\t\t};
\t\t\tbuildConfigurationList = BuildConfigListB /* Build configuration list for PBXProject "${projectName}" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = tr;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ttr,
\t\t\t\ten,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = ${rootGroupId};
\t\t\tproductRefGroup = ${productsGroupId} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t${mainTargetId} /* ${projectName} */,
\t\t\t);
\t\t};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
\t\t${resourcesPhaseId} /* Resources */ = {
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
${pbxResourcesBuildPhase}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t${sourcesPhaseId} /* Sources */ = {
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
${pbxSourcesBuildPhase}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
\t\tBuildConfigAppDebug /* Debug */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tINFOPLIST_FILE = "Info.plist";
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.0;
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = "${orgName}.${projectName}";
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t\tWRAPPER_EXTENSION = app;
\t\t\t};
\t\t\tname = Debug;
\t\t};
\t\tBuildConfigAppRelease /* Release */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tINFOPLIST_FILE = "Info.plist";
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.0;
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = "${orgName}.${projectName}";
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t\tWRAPPER_EXTENSION = app;
\t\t\t};
\t\t\tname = Release;
\t\t};
\t\tBuildConfigProjDebug /* Debug */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu11;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t};
\t\t\tname = Debug;
\t\t};
\t\tBuildConfigProjRelease /* Release */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tENABLE_NS_ASSERTIONS = NO;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu11;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t};
\t\t\tname = Release;
\t\t};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\tBuildConfigListA /* Build configuration list for PBXNativeTarget "${projectName}" */ = {
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\tBuildConfigAppDebug /* Debug */,
\t\t\t\tBuildConfigAppRelease /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t};
\t\tBuildConfigListB /* Build configuration list for PBXProject "${projectName}" */ = {
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\tBuildConfigProjDebug /* Debug */,
\t\t\t\tBuildConfigProjRelease /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t};
/* End XCConfigurationList section */

\t};
\trootObject = ProjectObjectId /* Project object */;
}
`;

fs.writeFileSync('SDiOS.xcodeproj/project.pbxproj', pbxprojContent);
console.log('Successfully written SDiOS.xcodeproj/project.pbxproj');
