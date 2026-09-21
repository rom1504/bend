// Rapid experiment only: transplant Bend-generated module workers into a frozen
// compiler API. This tests compiler implementation changes without rebuilding the
// whole compiler. It does not establish a bootstrap fixed point.
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const sha256 = source => createHash('sha256').update(source).digest('hex');

export function componentCapsule(baseSource, componentSource, moduleSource) {
  const names = [...moduleSource.matchAll(/^(?:@unsafe\s+)?def\s+([^\s(:]+)/gm)].map(m => m[1]);
  if (!names.length || new Set(names).size !== names.length) throw Error('invalid module definitions');
  if (!baseSource.includes('export {G,call,list,ctor};')) throw Error('expected positional self-emitted API');
  const previousNames = [...baseSource.matchAll(/^\/\/ RAPID COMPONENT CAPSULE: (.*)$/gm)]
    .flatMap(match => match[1].split(', '));
  for (const name of names) if (previousNames.includes(name)) {
    throw Error(`overlapping component capsule worker ${name}`);
  }
  // A capsule must preserve constructor field order, ownership, and native
  // representation. Compare all constructor metadata common to both APIs.
  const metadata = text => new Map(text.split('\n').filter(line =>
    /^(?:constructors|constructorOwn|constructorNative)\[/.test(line)).map(line =>
    [line.slice(0, line.indexOf('=')), line]));
  const baseMetadata = metadata(baseSource);
  for (const [key, line] of metadata(componentSource)) {
    if (!baseMetadata.has(key) || baseMetadata.get(key) !== line) {
      throw Error(`incompatible constructor metadata ${key}`);
    }
  }
  const definitions = new Map();
  for (const line of componentSource.split('\n')) {
    const m = /^G\["([^"]+)"\]=/.exec(line);
    if (m && names.includes(m[1])) {
      if (definitions.has(m[1])) throw Error(`duplicate generated worker ${m[1]}`);
      definitions.set(m[1], line);
    }
  }
  for (const name of names) if (!definitions.has(name)) throw Error(`missing generated worker ${name}`);
  // New workers may refer to existing compiler workers or other workers in the
  // capsule, but cannot silently depend on a component-only helper we omitted.
  const globals = new Set([...baseSource.matchAll(/G\["([^"]+)"\]=/g)].map(match => match[1]));
  for (const match of baseSource.matchAll(/native\(['"]([^'"]+)['"]/g)) globals.add(match[1]);
  for (const name of names) globals.add(name);
  for (const [name, definition] of definitions) {
    for (const reference of definition.matchAll(/get\(G,"([^"]+)"\)/g)) {
      if (!globals.has(reference[1])) throw Error(`missing capsule dependency ${name} -> ${reference[1]}`);
    }
  }
  const source = baseSource + '\n// RAPID COMPONENT CAPSULE: ' + names.join(', ') + '\n' +
    names.map(name => definitions.get(name)).join('\n') + '\n';
  return {source, stats: {kind: 'bend-generated-component-capsule', names, previousNames,
    baseSha256: sha256(baseSource), componentSha256: sha256(componentSource),
    moduleSha256: sha256(moduleSource), outputSha256: sha256(source),
    wholeCompilerFixedPoint: false}};
}

if (process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href) {
  const [base, component, module, output] = process.argv.slice(2);
  if (!base || !component || !module || !output) {
    throw Error('usage: node component-capsule.mjs BASE_API COMPONENT_API MODULE_SOURCE OUTPUT');
  }
  const result = componentCapsule(...[base, component, module].map(file => fs.readFileSync(file, 'utf8')));
  fs.mkdirSync(path.dirname(output), {recursive: true});
  fs.writeFileSync(output, result.source);
  fs.writeFileSync(output + '.capsule.json', JSON.stringify(result.stats, null, 2) + '\n');
  console.log(JSON.stringify(result.stats));
}
