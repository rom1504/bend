// Root executes only after independent checked baseline/candidate fixture emissions.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
const [baselineFile,candidateFile,outArg]=process.argv.slice(2);
assert(baselineFile&&candidateFile&&outArg&&process.argv.length===5);
const out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const report={kind:'phase58-literal-field-controls',complete:false,pass:false,inputs:[],observations:[],syntax:{},scope:'Actual checked source emissions, complete own values/descriptors/order/aliases and public callable ABI; no saved kernel or performance result.'};
const sha=p=>createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const pin=p=>{p=fs.realpathSync(p);const i={file:p,sha256:sha(p),bytes:fs.statSync(p).size};report.inputs.push(i);return p;};
const special=['__proto__','constructor','prototype','default','field.name','snake_case'];
const pm={exports:{}};new Function('module','exports',process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'])(pm,pm.exports);
function walk(n,f){if(!n||typeof n!=='object')return;f(n);for(const v of Object.values(n))if(Array.isArray(v))v.forEach(x=>walk(x,f));else if(v&&typeof v==='object')walk(v,f);}
function checkObject(v,tag,keys,values){assert.equal(Object.getPrototypeOf(v),Object.prototype);assert.deepEqual(Reflect.ownKeys(v),['$',...keys]);assert.equal(v.$,tag);keys.forEach((k,i)=>{const d=Object.getOwnPropertyDescriptor(v,k);assert(d&&d.enumerable&&d.configurable&&d.writable&&!d.get&&!d.set);assert.equal(d.value,values[i]);});}
function inspectSyntax(file,role){const ast=pm.exports.parse(fs.readFileSync(file,'utf8'),{ecmaVersion:'latest',sourceType:'module'}),counts={plain:0,computed:0,protoComputed:0,protoPlain:0};walk(ast,n=>{if(n.type!=='Property')return;const key=n.key.type==='Literal'?n.key.value:n.key.type==='Identifier'?n.key.name:null;if(!special.includes(key))return;if(key==='__proto__')counts[n.computed?'protoComputed':'protoPlain']++;else counts[n.computed?'computed':'plain']++;});assert(counts.protoComputed>0);assert.equal(counts.protoPlain,0);if(role==='candidate'){assert(counts.plain>=5);assert.equal(counts.computed,0);}else{assert(counts.computed>=5);assert.equal(counts.plain,0);}report.syntax[role]=counts;}
async function readModule(file,role){
 file=pin(file);const receiptFile=pin(file+'.json'),receipt=JSON.parse(fs.readFileSync(receiptFile));
 assert.equal(receipt.kind,'bend-program-checked-emission');assert(receipt.complete&&receipt.observation.checked&&receipt.observation.typeAccepted&&receipt.observation.status==='ok');assert.equal(receipt.observation.exitCode,0);
 assert.equal(receipt.backend,'direct');assert.equal(receipt.compiler.backend,'direct');assert.equal(receipt.compiler.kind,'checked-development-attempt');assert.equal(sha(file),receipt.output.sha256);
 const producer=pin(receipt.producer.file);assert.equal(producer,fs.realpathSync(new URL('../qualification/paired-fixtures-v2.mjs',import.meta.url)));assert.equal(sha(producer),'6a2947f7a3c9fd84f7a78215c607fd5f90773e1edddf31376828d2d1f7fe0fe7');assert.equal(receipt.producer.sha256,sha(producer));
 const source=pin(receipt.input.file);assert.equal(sha(source),receipt.input.sha256);assert.equal(receipt.input.sha256,sha(new URL('./fields-v2.bend',import.meta.url)));
 const catalog=pin(receipt.catalog.file);assert.equal(sha(catalog),receipt.catalog.sha256);assert.equal(receipt.catalog.sha256,sha(new URL('./catalog-v2.json',import.meta.url)));
 const attemptFile=pin(receipt.attempt.file);assert.equal(sha(attemptFile),receipt.attempt.sha256);const attempt=await verifyAttempt(path.dirname(attemptFile));assert(attempt.checked);
 const validationFile=pin(path.join(path.dirname(attemptFile),'validation-001/report.json')),validation=JSON.parse(fs.readFileSync(validationFile));assert(validation.complete&&validation.pass&&validation.selected.selectedComplete);assert.equal(validation.selected.exactDifferences,0);assert.equal(validation.selected.discrepancies,0);assert.equal(validation.selected.candidate.tests,36);assert.equal(validation.selected.reference.tests,36);
 const validationPair=pin(validation.selected.file.file);assert.equal(sha(validationPair),validation.selected.file.sha256);assert.equal(validation.attempt.sha256,receipt.attempt.sha256);assert.equal(validation.api.sha256,attempt.api.sha256);
 assert.equal(receipt.compiler.api.sha256,attempt.api.sha256);assert.equal(receipt.compiler.runtime.sha256,attempt.runtime.sha256);assert.equal(receipt.compiler.base.sha256,attempt.base.sha256);
 const frozen=new Map(attempt.snapshot.sources.map(x=>[x.frozen.file,x.frozen.sha256]));
 for(const x of receipt.privateCopies){for(const k of ['before','after']){const q=pin(x[k].file);assert.equal(sha(q),x[k].sha256);}assert.equal(x.before.sha256,x.after.sha256);if(frozen.has(x.before.file))assert.equal(x.before.sha256,frozen.get(x.before.file));}
 for(const k of ['api','runtime','base','driver','directRuntime']){const row=receipt.compiler[k];assert(row?.sha256);const q=pin(row.file);assert.equal(sha(q),row.sha256);if(k!=='base')assert(q.includes('/build/phase58/'),'Private Phase58 image required');}
 for(const row of receipt.emissionInputs){const q=pin(row.file);assert.equal(sha(q),row.sha256);}
 assert(receipt.emissionInputs.some(x=>x.file===receipt.compiler.directRuntime.file));
 report[role]={module:{file,sha256:sha(file)},compiler:receipt.compiler,input:receipt.input,catalog:receipt.catalog,attempt:receipt.attempt,qualification:{checked:attempt.checked,strictExact:validation.strictExact,selectedTests:36,exactDifferences:0,validation:{file:validationFile,sha256:sha(validationFile)}}};inspectSyntax(file,role);return file;
}
function observe(api){assert(!api.G);const f=api.default;assert(f&&typeof f.literal==='function');let count=0;
 checkObject(f.literal(),'P58Fields',special,[1,2,3,4,5,6]);count++;
 for(const n of [0,1,17,4294967295]){checkObject(f.dynamic(n),'P58Fields',special,Array.from({length:6},(_,i)=>(n+i)>>>0));count++;}
 const natkeys=['__proto__','constructor','field.name'];for(const n of [0n,1n,37n,4294967296n]){checkObject(f.natural(n),'P58NatFields',natkeys,[n,n,n]);count++;}
 const original={$:'P58NatFields',['__proto__']:2n,constructor:3n,['field.name']:4n};const before=Object.getOwnPropertyDescriptors(original);checkObject(f.roundtrip(original),'P58NatFields',natkeys,[2n,3n,4n]);assert.deepEqual(Object.getOwnPropertyDescriptors(original),before);count++;
 const box=f.literal(),pair=f.shared(box);checkObject(pair,'P58Pair',['left','right'],[box,box]);assert.equal(pair.left,pair.right);assert.equal(pair.left,box);count++;
 let events=[];const cb=name=>n=>{events.push([name,n]);return n+10;};checkObject(f.ordered(cb('f'),cb('g'),cb('h')),'P58Fields',special,[11,12,13,4,5,6]);assert.deepEqual(events,[['f',1],['g',2],['h',3]]);count++;
 events=[];const sentinel={unique:'throw'};assert.throws(()=>f.ordered(cb('f'),n=>{events.push(['throw',n]);throw sentinel;},cb('h')),e=>e===sentinel);assert.deepEqual(events,[['f',1],['throw',2]]);count++;
 events=[];checkObject(f.ordered(n=>{events.push(['enter',n]);const v=f.dynamic(7);events.push(['exit',v.__proto__]);return v.constructor;},cb('g'),cb('h')),'P58Fields',special,[8,12,13,4,5,6]);assert.deepEqual(events,[['enter',1],['exit',7],['g',2],['h',3]]);count++;
 events=[];const partial=f.ordered(cb('f'));assert.deepEqual(events,[]);const next=partial(cb('g'));assert.deepEqual(events,[]);const v=next(cb('h'));checkObject(v,'P58Fields',special,[11,12,13,4,5,6]);assert.deepEqual(events,[['f',1],['g',2],['h',3]]);count++;
 const traced={$:'P58NatFields'};for(const [k,n] of natkeys.map((k,i)=>[k,BigInt(i+1)]))Object.defineProperty(traced,k,{enumerable:true,configurable:true,get(){events.push(k);return n;}});events=[];const got=f.roundtrip(traced);checkObject(got,'P58NatFields',natkeys,[1n,2n,3n]);const getterTrace=[...events];assert(getterTrace.length>=3);count++;
 const saved=Object.getOwnPropertyDescriptor(Object.prototype,'__proto__');let setterCalls=0;try{Object.defineProperty(Object.prototype,'__proto__',{configurable:true,get(){throw sentinel;},set(){setterCalls++;throw sentinel;}});checkObject(f.literal(),'P58Fields',special,[1,2,3,4,5,6]);assert.equal(setterCalls,0);}finally{Object.defineProperty(Object.prototype,'__proto__',saved);}count++;
 return {count,getterTrace};}
try{pin(import.meta.filename);pin(process.execPath);pin(new URL('./fields-v2.bend',import.meta.url));pin(new URL('./catalog-v2.json',import.meta.url));pin(new URL('../../../development/workflow.mjs',import.meta.url));pin(new URL('../qualification/checked-image.mjs',import.meta.url));const b=await readModule(baselineFile,'baseline'),c=await readModule(candidateFile,'candidate');assert.equal(report.baseline.input.sha256,report.candidate.input.sha256);assert.equal(report.baseline.catalog.sha256,report.candidate.catalog.sha256);const bm=await import(pathToFileURL(b)),cm=await import(pathToFileURL(c));const bo=observe(bm),co=observe(cm);assert.deepEqual(co,bo);report.observations=[{role:'baseline',...bo},{role:'candidate',...co}];for(const i of report.inputs)assert.equal(sha(i.file),i.sha256);report.complete=report.pass=true;}catch(error){report.error=String(error.stack??error);process.exitCode=1;}finally{fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:report.complete,pass:report.pass,observations:report.observations,error:report.error}));}
