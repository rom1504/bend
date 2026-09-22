// Assemble an actual compiler-source subset, without inventing host algorithms.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [baselineArgument,outputArgument]=process.argv.slice(2);if(!outputArgument)throw Error('Usage: private-component.mjs FROZEN_BASELINE NEW_DIRECTORY');
const root=fs.realpathSync(baselineArgument),out=path.resolve(outputArgument);fs.mkdirSync(out,{recursive:false});
const manifest=JSON.parse(fs.readFileSync(path.join(root,'manifest.json'))),modules=['src/core/term.bend','src/core/index.bend','src/core/normalize.bend','src/core/graph.bend'],sha=p=>createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const files=[...modules,'tools/assemble.mjs'];for(const file of files)assert.equal(sha(path.join(root,file)),manifest.files[file].sha256);
const {assemble}=await import(pathToFileURL(path.join(root,'tools/assemble.mjs')));const source=path.join(out,'core.bend'),assembled=assemble(modules,source,{root});
for(const file of files)assert.equal(sha(path.join(root,file)),manifest.files[file].sha256);
fs.writeFileSync(path.join(out,'component.json'),JSON.stringify({kind:'actual-compiler-source-subset',baseline:root,manifestSha256:sha(path.join(root,'manifest.json')),files:files.map(file=>({file:path.join(root,file),sha256:sha(path.join(root,file))})),source,sourceSha256:sha(source),assembled},null,2)+'\n');console.log(JSON.stringify(assembled));
