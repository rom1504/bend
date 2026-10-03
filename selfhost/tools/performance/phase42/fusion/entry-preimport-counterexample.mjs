// Public-only pre-import Math hook + dependency mutation/reentry counterexample.
// No timing and no inspection/export of the private proof state.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [derivedArg,outArg]=process.argv.slice(2);assert(derivedArg&&outArg);
const derived=fs.realpathSync(derivedArg),out=path.resolve(outArg);assert(!fs.existsSync(out));
const identity=p=>({path:fs.realpathSync(p),bytes:fs.statSync(p).size,sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex')});
const manifestPath=path.join(derived,'derive.json'),manifest=JSON.parse(fs.readFileSync(manifestPath));
assert.equal(manifest.kind,'phase42-fusion-entry-rejection');assert.equal(manifest.complete,true);
const inputs=[identity(import.meta.filename),identity(manifestPath),manifest.parent,manifest.producer,...manifest.modules.map(({role,...id})=>id)];for(const id of inputs)assert.deepEqual(identity(id.path),id);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'consumed-counterexample.mjs'));
const report={kind:'phase42-fusion-no-scope-preimport-counterexample',complete:false,rejectionProved:false,inputs,observations:[],scope:'Public exports and G dependency descriptors only; exact source Math.imul snapshot captured before import. Not timing or a source compiler candidate.'};
const descriptor=Object.getOwnPropertyDescriptor(Math,'imul'),nativeImul=descriptor.value;
try{
 for(const row of manifest.modules){const events=[];let module,busy=false;
  function hookedImul(a,b){if(module&&!busy){busy=true;const f=module.G.dbl,old=f.code;f.code=function(args){events.push('changed-dbl');return Reflect.apply(old,this,[args]);};try{events.push(['nested',module.default.bench(1,7)]);}finally{f.code=old;busy=false;}}return Reflect.apply(nativeImul,Math,[a,b]);}
  Object.defineProperty(Math,'imul',{...descriptor,value:hookedImul});
  module=await import(pathToFileURL(row.path));const value=module.default.bench(1,7);
  report.observations.push({role:row.role,value,events});Object.defineProperty(Math,'imul',descriptor);
 }
 const [original,candidate]=report.observations;assert.equal(original.value,14);assert.equal(candidate.value,14);
 assert.equal(original.events.filter(x=>x==='changed-dbl').length,0,'original scope did not cover reentry');
 assert(candidate.events.some(x=>x==='changed-dbl'),'no-scope did not expose changed dependency');
 assert.notDeepEqual(candidate.events,original.events,'failure-order/event witness inactive');
 for(const id of inputs)assert.deepEqual(identity(id.path),id);report.complete=true;report.rejectionProved=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
finally{Object.defineProperty(Math,'imul',descriptor);fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});}
console.log(JSON.stringify({complete:report.complete,rejectionProved:report.rejectionProved,observations:report.observations,error:report.error}));
