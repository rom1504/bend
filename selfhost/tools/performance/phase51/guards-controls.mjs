// Untimed differential guard/public-call observations. Run only after a checked recipe.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {pathToFileURL,fileURLToPath} from 'node:url';
const [receiptFile,outArg]=process.argv.slice(2);assert.ok(receiptFile&&outArg);
const out=path.resolve(outArg);assert.ok(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=b=>createHash('sha256').update(b).digest('hex');
const identity=f=>{f=f instanceof URL?fileURLToPath(f):f;return {file:path.resolve(f),bytes:fs.statSync(f).size,sha256:hash(fs.readFileSync(f))};};
const receiptIdentity=identity(receiptFile),receipt=JSON.parse(fs.readFileSync(receiptFile,'utf8'));
assert.equal(receipt.kind,'phase51-batched-string-guard');assert.equal(receipt.complete,true);
const inputs=[receiptIdentity,identity(new URL(import.meta.url)),receipt.parent,receipt.candidate,identity(process.execPath)];
for(const r of inputs.slice(2))assert.deepEqual(identity(r.file),r);
const append='\nexport const phase51StringGuard=()=>stringHostGuard();\n';
const modules=[];
for(const [role,record] of [['baseline',receipt.parent],['candidate',receipt.candidate]]){
 const source=fs.readFileSync(record.file,'utf8');assert.equal((source.match(/function stringHostGuard\(/g)||[]).length,1);
 const file=path.join(out,role+'-control.mjs');fs.writeFileSync(file,source+append,{flag:'wx'});
 modules.push({role,file,identity:identity(file),exports:await import(pathToFileURL(file).href)});
}
const get=Object.getOwnPropertyDescriptor,define=Object.defineProperty,getProto=Object.getPrototypeOf,setProto=Object.setPrototypeOf;
const StringCtor=String,StringProto=String.prototype,ObjProto=Object.prototype;
const sentinel={phase51:'guard-hook'};let events=[];
function property(object,key,descriptor){const old=get(object,key);define(object,key,descriptor);return()=>old?define(object,key,old):delete object[key];}
function parent(object,value){const old=getProto(object);setProto(object,value);return()=>setProto(object,old);}
const scenarios=[
 ['clean',true,()=>()=>{}],
 ['global-String-value',false,()=>property(globalThis,'String',{...get(globalThis,'String'),value:function(){events.push('String');throw sentinel;}})],
 ['global-String-getter',false,()=>property(globalThis,'String',{configurable:true,get(){events.push('String-get');throw sentinel;}})],
 ['constructor-extra-key',false,()=>property(StringCtor,'phase51Extra',{configurable:true,value:7})],
 ['constructor-extra-symbol',false,()=>property(StringCtor,Symbol.for('phase51-extra'),{configurable:true,value:7})],
 ['prototype-extra-key',false,()=>property(StringProto,'phase51Extra',{configurable:true,value:7})],
 ['prototype-extra-symbol',false,()=>property(StringProto,Symbol.for('phase51-extra'),{configurable:true,value:7})],
 ['prototype-method-value',false,()=>property(StringProto,'charAt',{...get(StringProto,'charAt'),value:()=>{events.push('charAt');throw sentinel;}})],
 ['prototype-method-getter',false,()=>property(StringProto,'charAt',{configurable:true,get(){events.push('charAt-get');throw sentinel;}})],
 ['prototype-symbol-value',false,()=>property(StringProto,Symbol.iterator,{...get(StringProto,Symbol.iterator),value:()=>{events.push('iterator');throw sentinel;}})],
 ['prototype-writable',false,()=>property(StringProto,'charAt',{...get(StringProto,'charAt'),writable:false})],
 ['prototype-enumerable',false,()=>property(StringProto,'charAt',{...get(StringProto,'charAt'),enumerable:true})],
 ['constructor-parent',false,()=>parent(StringCtor,null)],
 ['prototype-parent',false,()=>parent(StringProto,null)],
 ['captured-descriptor-method',true,()=>property(Object,'getOwnPropertyDescriptor',{...get(Object,'getOwnPropertyDescriptor'),value:()=>{events.push('descriptor');throw sentinel;}})],
 ['captured-batch-method',true,()=>property(Object,'getOwnPropertyDescriptors',{...get(Object,'getOwnPropertyDescriptors'),value:()=>{events.push('batch');throw sentinel;}})],
 ['captured-ownkeys-method',true,()=>property(Reflect,'ownKeys',{...get(Reflect,'ownKeys'),value:()=>{events.push('ownkeys');throw sentinel;}})],
 ['inherited-descriptor-value',true,()=>property(ObjProto,'value',{configurable:true,get(){events.push('inherited-value');throw sentinel;}})],
];
const rows=[];
for(const [name,expected,install] of scenarios){
 const observations=[];
 for(const m of modules){
  events=[];const restore=install();let guard,thrown;
  try{guard=m.exports.phase51StringGuard();}catch(error){thrown=error;}finally{restore();}
  assert.equal(thrown,undefined,name+' must inspect descriptors without invoking hooks');assert.equal(guard,expected,name);
  assert.deepEqual(events,[],name+' guard must be inert');observations.push({guard,events:[...events]});
  assert.equal(m.exports.phase51StringGuard(),true,'restored '+name);
 }
 assert.deepEqual(observations[0],observations[1]);rows.push({name,expected,observations});
}
// Actual RLE public result is a separate clean oracle; hostile direct predicates above
// isolate this guard rather than pretending that all arbitrary programs return 11.
for(const m of modules)assert.equal(m.exports.default['main.out'](),11);
for(const r of inputs)assert.deepEqual(identity(r.file),r);
for(const m of modules)assert.deepEqual(identity(m.file),m.identity);
const result={kind:'phase51-batched-string-guard-controls',complete:true,pass:true,diagnosticOnly:true,
 node:process.version,execArgv:process.execArgv,
 inputs,derivatives:modules.map(m=>({role:m.role,...m.identity})),observations:rows,guardCases:rows.length,
 cleanPublicOracles:2,scope:'Standard initialization, post-import descriptor/prototype mutations, exact direct guard booleans and zero hook invocation. No timing or universal host-equivalence claim.'};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(result,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({pass:true,cases:rows.length,report:path.join(out,'report.json')}));
