// Offline assembly only. Root separately checks/emits/runs the returned source.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {assemble} from '../../../assemble.mjs';
const [variant,outputArg]=process.argv.slice(2);
assert(['baseline','candidate'].includes(variant)&&outputArg,'Usage: assemble-controls.mjs baseline|candidate NEW_OUTPUT.bend');
const here=import.meta.dirname,root=path.resolve(here,'../../../../..'),project=path.join(root,'selfhost');
const output=path.resolve(outputArg);assert(!fs.existsSync(output));assert(!fs.existsSync(output+'.map.json'));
const manifestPath=path.join(project,'src/compiler.json'),manifest=JSON.parse(fs.readFileSync(manifestPath));
const bridge=path.join(here,`bridge.${variant}.bend`),entry=path.join(here,'lowering-controls.bend');
const modules=manifest.modules.map(m=>m==='src/back/native/bridge.bend'?bridge:m);
const pin=file=>({file:path.resolve(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex'),bytes:fs.statSync(file).size});
const inputs=[manifestPath,...modules.map(m=>path.isAbsolute(m)?m:path.join(project,m)),entry,import.meta.filename].map(pin);
const result=assemble([...modules,entry],output,{root:project});
for(const p of inputs)assert.deepEqual(pin(p.file),p);
fs.writeFileSync(output+'.receipt.json',JSON.stringify({kind:'phase89-lowering-source-assembly',variant,complete:true,inputs,output:pin(output),assembly:result},null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify(result));
