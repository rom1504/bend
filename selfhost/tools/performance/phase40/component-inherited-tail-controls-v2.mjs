// V2 preserves the V1 failure and routes deferred construction through the actual foreign producer return/force path.
// The full inherited controls run unchanged separately.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseArg,outArg]=process.argv.slice(2);
assert(baseArg&&outArg,'usage: component-inherited-tail-controls-v2.mjs DERIVED NEW_OUT');
const parentControl=path.join(import.meta.dirname,'component-inherited-tail-controls-v1.mjs');
const base=fs.realpathSync(baseArg),out=path.resolve(outArg);assert(!fs.existsSync(out));
const identity=file=>({path:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex'),bytes:fs.statSync(file).size});
const inputs=new Map();function track(file,expected){const row=identity(file);if(expected){assert.equal(row.sha256,expected.sha256);if('bytes'in expected)assert.equal(row.bytes,expected.bytes);}inputs.set(row.path,row);return row;}
track(import.meta.filename);const predecessor=track(parentControl,{sha256:'beed6393dc8e8a6a335af9a895c1bcc4658b2fd55679dd209978a5774beda65c'});const manifestFile=track(path.join(base,'derive.json')),manifest=JSON.parse(fs.readFileSync(manifestFile.path));
assert.equal(manifest.kind,'phase39-actual-structural-component');assert.equal(manifest.complete,true);assert.equal(manifest.checked,true);
assert.equal(manifest.successor.parent.sha256,'37aa551f6e330a24fd5a782405e26a34caea5cf678b16a44d792147ac1388618');
for(const row of manifest.inputs)track(row.path,row);
const variants=['original','direct'],modules=[];
for(const variant of variants){const row=manifest.modules.find(r=>r.variant===variant&&r.counters);assert(row);const file=track(row.path,row);assert.equal(row.tailWorker,variant==='direct'?1:0);assert.equal(row.tailLeafSites,row.tailWorker);modules.push(await import(pathToFileURL(file.path)));}
const word=n=>Number(BigInt.asUintN(32,n));
const report={kind:'phase40-inherited-component-tail-controls-v2',predecessor,complete:false,pass:false,node:process.version,attempt:manifest.attempt,compiler:manifest.compiler,inputs:[],oracle:[],boundaries:[],admission:[]};
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
function reset(m){const gd=Object.getOwnPropertyDescriptors(m.G),saved=[];for(const d of Object.values(gd)){const f=d.value;if(f&&typeof f==='object')saved.push([f,Object.getOwnPropertyDescriptors(f)]);}return()=>{for(const [f,ds]of saved){for(const k of Reflect.ownKeys(f))if(!Object.hasOwn(ds,k))delete f[k];Object.defineProperties(f,ds);}for(const k of Reflect.ownKeys(m.G))if(!Object.hasOwn(gd,k))delete m.G[k];Object.defineProperties(m.G,gd);};}
function observe(m,action){const restore=reset(m),events=[],before=m.privateComponentCounts();let value,error;try{value=action(m,events);}catch(e){error={name:e.name,message:e.message};}finally{restore();}assert.equal(m.privateProofActive(),false);return {value,error,events,tailEntries:m.privateComponentCounts().tail-before.tail};}
function boundary(name,action){const observations=modules.map(m=>observe(m,action));report.current={name,observations};const semantic=r=>({value:r.value,error:r.error,events:r.events});assert.deepEqual(semantic(observations[1]),semantic(observations[0]),name);assert.equal(observations[1].tailEntries,0,name+': unproved tail entered');assert(observations[0].events.length,name+': inactive boundary');report.boundaries.push(report.current);delete report.current;}
try{
 for(const depth of [0,1,3,7])for(const seed of [0,17,4294967295]){
  const expected={$:'OEnd',a:[word(2n*BigInt(seed)+BigInt(depth))]},results=[];
  for(const m of modules){const before=m.privateComponentCounts(),value=m.privateComponentTailPoint(depth,seed),after=m.privateComponentCounts();assert.deepEqual(value,expected);assert.equal(m.privateProofActive(),false);if(m===modules[1]&&depth>0){assert(after.tail>before.tail);assert.strictEqual(value,m.privateComponentTailLeaf(),'tail transfer copied terminal result');}results.push(value);}
  report.oracle.push({kind:'independent-tail-value-and-terminal-alias',depth,seed,expected,results});
 }
 {const m=modules[1],depth=30000,seed=4294967295,before=m.privateComponentCounts(),value=m.privateComponentTailPoint(depth,seed),expected={$:'OEnd',a:[word(2n*BigInt(seed)+BigInt(depth))]};assert.deepEqual(value,expected);assert.strictEqual(value,m.privateComponentTailLeaf());assert.equal(m.privateProofActive(),false);const after=m.privateComponentCounts();assert(after.tail>before.tail);report.oracle.push({kind:'deep-actual-tail',depth,seed,expected,before,after});}
 {const m=modules[1],before=m.privateComponentCounts(),value=m.default.tail_check(7,17),after=m.privateComponentCounts();assert.equal(value,41);assert(after.root>before.root);assert(after.tail>before.tail);assert.equal(m.privateProofActive(),false);report.admission.push({kind:'ordinary-tail-source-entry',before,after,value});}
 for(const name of ['component.tail','component.makeA','component.score','tail_check'])for(const kind of ['wrap','getter','binding'])boundary(name+':'+kind,(m,e)=>{const f=m.G[name],code=f.code;if(kind==='binding')Object.defineProperty(m.G,name,{configurable:true,get(){e.push('G:'+name);return f;}});else if(kind==='getter')Object.defineProperty(f,'code',{configurable:true,get(){e.push('code:'+name);return code;}});else f.code=function(a){e.push('invoke:'+name);return Reflect.apply(code,this,[a]);};return m.default.tail_check(3,17);});
 for(const kind of ['tag','left','right','left-error','right-error','deferred','deferred-error'])boundary('public-tail:'+kind,(m,e)=>{const leaf={$:'AEnd',a:[7]},unused={$:'AEnd',a:[13]};let input={$:'AFork',a:[leaf,unused]};if(kind==='tag')Object.defineProperty(input,'$',{get(){e.push('tag');return 'AFork';}});if(kind==='left'||kind==='left-error')Object.defineProperty(input.a,'0',{get(){e.push('left');if(kind==='left-error')throw Error('left sentinel');return leaf;}});if(kind==='right'||kind==='right-error')Object.defineProperty(input.a,'1',{get(){e.push('right');if(kind==='right-error')throw Error('right sentinel');return unused;}});if(kind.startsWith('deferred')){
 const descriptor={build:true,name:'AFork',fields:[()=>{e.push('left');return leaf;},()=>{e.push('right');if(kind==='deferred-error')throw Error('right sentinel');return unused;}]};
 // Actual generic source calls force producer results before the tail matcher.
 // Raw build descriptors passed as matcher arguments are not forced by apply.
 m.G['component.makeA']={arity:2,code(){e.push('producer');return descriptor;},env:null,bound:[]};
 return m.default.tail_check(1,17);
 }return m.call(m.G['component.tail'],[input,17]);});
 for(const name of ['public-tail:deferred','public-tail:deferred-error']){const row=report.boundaries.find(r=>r.name===name);assert(row);for(const observation of row.observations){assert.deepEqual(observation.events,['producer','left','right']);if(name.endsWith('error')){assert.equal(observation.error?.name,'Error');assert.equal(observation.error?.message,'right sentinel');assert.equal(observation.value,undefined);}else{assert.equal(observation.error,undefined);assert.equal(observation.value,24);}}}
 for(const row of inputs.values())assert.deepEqual(identity(row.path),row);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracle:report.oracle.length,boundaries:report.boundaries.length,admission:report.admission.length,error:report.error}));
