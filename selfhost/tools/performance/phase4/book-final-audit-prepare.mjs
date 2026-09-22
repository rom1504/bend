// Assemble a small source-owned book-final component for emission by checked B1.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {assemble} from '../../assemble.mjs';
const [sourceRoot, outputDirectory] = process.argv.slice(2);
if (!outputDirectory) throw Error('Usage: book-final-audit-prepare.mjs SOURCE_ROOT NEW_OUTPUT');
const root = fs.realpathSync(sourceRoot), output = path.resolve(outputDirectory);
fs.mkdirSync(output, {recursive: false});
const hash = source => crypto.createHash('sha256').update(source).digest('hex');
const modules = ['term', 'index', 'normalize', 'graph'].map(name => 'src/core/' + name + '.bend');
const inputs = [];
for (const file of modules) {
  const source = fs.readFileSync(path.join(root, file));
  const target = path.join(output, 'sources', file);
  fs.mkdirSync(path.dirname(target), {recursive: true}); fs.writeFileSync(target, source);
  inputs.push({file: path.join(root, file), sha256: hash(source)});
}
const kernelFile = path.join(root, 'src/check/kernel.bend'), kernel = fs.readFileSync(kernelFile, 'utf8');
const law = kernel.match(/^law book_without:\n[\s\S]*?(?=\n\n)/m)?.[0];
const definition = kernel.match(/^def book_without\(book, name\):\n[\s\S]*?(?=\n\n)/m)?.[0];
if (!law || !definition) throw Error('Expected original book_without declaration and body');
const extra = 'src/check/audit.bend', target = path.join(output, 'sources', extra);
fs.mkdirSync(path.dirname(target), {recursive: true});
fs.writeFileSync(target, 'import Base\n' + law + '\n\n@unsafe\n' + definition + '\n');
inputs.push({file: kernelFile, sha256: hash(kernel)});
modules.push(extra);
const component = path.join(output, 'component.bend');
assemble(modules, component, {root: path.join(output, 'sources')});
fs.writeFileSync(path.join(output, 'preparation.json'), JSON.stringify({inputs, component, componentSha256: hash(fs.readFileSync(component)), tools: [import.meta.filename, path.resolve(import.meta.dirname, '../../assemble.mjs')].map(file => ({file, sha256: hash(fs.readFileSync(file))})), scope: 'Source assembly only. Compile with frozen checked B1 typed-driver --library and the frozen runtime before running book-final-audit-test.mjs.'}, null, 2) + '\n');
