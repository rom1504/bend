// Prepare the same real compiler modules for a seconds-long checked component
// build. This only assembles source and exposes existing control workers;
// compilation is an explicit, separately measurable command.
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {assemble} from '../../assemble.mjs';

const [sourceRoot, outputDir, reference = 'dist/phase1/bootstrap-api.mjs'] = process.argv.slice(2);
if (!sourceRoot || !outputDir) throw Error('usage: node index-component.mjs SOURCE_ROOT OUTPUT_DIR [CONTROL_BOOTSTRAP_API]');
const root = path.resolve(sourceRoot), output = path.resolve(outputDir);
const modules = ['term', 'index', 'normalize', 'graph'].map(name => `src/core/${name}.bend`);
const digest = text => createHash('sha256').update(text).digest('hex');
const captured = modules.map(file => ({file, source: fs.readFileSync(path.join(root, file), 'utf8')}));
fs.mkdirSync(output, {recursive: true});
for (const {file, source} of captured) {
  const target = path.join(output, 'sources', file);
  fs.mkdirSync(path.dirname(target), {recursive: true});fs.writeFileSync(target, source);
}
assemble(modules, path.join(output, 'component.bend'), {root: path.join(output, 'sources')});
fs.writeFileSync(path.join(output, 'index.bend'), captured.find(item => item.file.endsWith('/index.bend')).source);
const roots = {lookup: 2, book_cached: 2, book_context: 1, book_put: 2,
  index_hash: 2, index_set: 4, index_find: 4, missing: 0};
const original = fs.readFileSync(reference, 'utf8');
for (const name of Object.keys(roots)) {
  if (!original.includes(`function $${name}$(`)) throw Error(`missing checked reference worker ${name}`);
}
const control = original + '\nexport const rapidIndexControl = {\n' +
  Object.entries(roots).map(([name, arity]) => `  ${name}: run_lib($${name}$, ${arity}),\n`).join('') + '};\n';
fs.writeFileSync(path.join(output, 'control.mjs'), control);
const report = {scope: 'checked component preparation; no compilation or bootstrap proof',
  sourceRoot: root, modules: captured.map(({file, source}) => ({file, sha256: digest(source)})),
  componentSha256: digest(fs.readFileSync(path.join(output, 'component.bend'))),
  reference: path.resolve(reference), referenceSha256: digest(original), controlSha256: digest(control),
  apiExports: Object.keys(roots)};
fs.writeFileSync(path.join(output, 'preparation.json'), JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify(report));
