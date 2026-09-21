// Freeze the actual compiler modules and experimental IO driver before building.
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {assemble} from '../../assemble.mjs';

const [sourceDirectory, outputDirectory, ...extra] = process.argv.slice(2);
if (!sourceDirectory || !outputDirectory || extra.length) {
  throw Error('usage: node native-bundle-prepare.mjs SELFHOST_SOURCE_ROOT NEW_OUTPUT_DIRECTORY');
}
const root = fs.realpathSync(sourceDirectory), output = path.resolve(outputDirectory);
const manifestFile = path.join(root, 'src/compiler.json');
const manifest = fs.readFileSync(manifestFile);
const modules = JSON.parse(manifest).modules;
if (!Array.isArray(modules) || !modules.length || new Set(modules).size !== modules.length) {
  throw Error('Expected a nonempty compiler module manifest without duplicates');
}
const driverRelative = 'src/driver/native-bundle.bend';
if (modules.includes(driverRelative)) throw Error('Experimental driver is already in the compiler manifest');
for (const file of modules) {
  if (typeof file !== 'string' || !file.startsWith('src/') ||
      !path.resolve(root, file).startsWith(root + path.sep)) throw Error('Unexpected compiler module path');
}
fs.mkdirSync(path.dirname(output), {recursive: true});
fs.mkdirSync(output); // Never replace a prior snapshot or experiment.
const hash = bytes => createHash('sha256').update(bytes).digest('hex');
const copy = (relative, bytes) => {
  const destination = path.join(output, relative);
  fs.mkdirSync(path.dirname(destination), {recursive: true});
  fs.writeFileSync(destination, bytes);
  return {file: relative, sha256: hash(bytes)};
};
const sources = modules.map(file => copy(file, fs.readFileSync(path.join(root, file))));
const driver = copy(driverRelative, fs.readFileSync(new URL('./native-bundle.bend', import.meta.url)));
const runtime = copy('src/runtime.mjs', fs.readFileSync(path.join(root, 'src/runtime.mjs')));
copy('src/compiler.json', manifest);
const compiler = path.join(output, 'compiler.bend');
const assembly = assemble([...modules, driverRelative], compiler, {root: output});
const report = {
  kind: 'experimental-native-closed-bundle-snapshot', preparedAt: new Date().toISOString(),
  sourceRoot: root, manifestSha256: hash(manifest), modules: sources, driver, runtime,
  assembly: {...assembly, sha256: hash(fs.readFileSync(compiler))},
  toolSha256: hash(fs.readFileSync(import.meta.filename)),
  scope: 'Actual compiler modules plus a separate main-and-Base experimental IO driver',
};
const reportFile = path.join(output, 'preparation.json');
fs.writeFileSync(reportFile, JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify({reportFile, ...report.assembly}));
