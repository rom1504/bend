// Fixed-input ablation admission/oracle only; unsafe guard removals are not valid candidates.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [baseArg,outArg]=process.argv.slice(2);assert(baseArg&&outArg,'usage: ray-ablation-controls.mjs DERIVED NEW_OUT');
const base=fs.realpathSync(baseArg),out=path.resolve(outArg);assert(!fs.existsSync(out));
const identity=file=>({path:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const manifestFile=path.join(base,'derive.json'),manifest=JSON.parse(fs.readFileSync(manifestFile));assert.equal(manifest.kind,'phase37-ray-regression-ablation');assert.equal(manifest.complete,true);
fs.mkdirSync(out,{recursive:false});fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
const report={kind:'phase37-ray-ablation-admission',complete:false,pass:false,node:process.version,inputs:[import.meta.filename,manifestFile].map(identity),observations:[]};
try{for(const row of manifest.modules.filter(x=>x.counters)){assert.deepEqual(identity(row.path),{path:row.path,sha256:row.sha256});report.inputs.push(identity(row.path));
 const m=await import(pathToFileURL(row.path)),value=m.default['coverage.active'](256,2240);assert.equal(value,2166930202,row.variant);const counts=m.rayStats();
 if(row.variant==='no-finite-roots'||row.variant.startsWith('no-finite-both'))assert.equal(Object.values(counts.entries).reduce((a,b)=>a+b,0),0);
 if(row.variant==='no-helper-roots')assert(Object.keys(counts.entries).every(k=>k==='bench'));
 if(row.variant==='no-finite-calls'||row.variant.startsWith('no-finite-both'))assert.equal(Object.values(counts.calls).reduce((a,b)=>a+b,0),0);
 report.observations.push({variant:row.variant,unsafe:row.unsafe,value,counts});}
 for(const row of report.inputs)assert.deepEqual(identity(row.path),row);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify(report));
