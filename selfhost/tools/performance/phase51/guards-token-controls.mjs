// Independent untimed observations for fresh same-entry String proof reuse.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {fileURLToPath,pathToFileURL} from 'node:url';
const [inputsFile,caseId,receiptFile,outArg]=process.argv.slice(2);assert.ok(inputsFile&&caseId&&receiptFile&&outArg);
const hash=b=>createHash('sha256').update(b).digest('hex');
const identity=f=>{f=f instanceof URL?fileURLToPath(f):f;return {file:path.resolve(f),bytes:fs.statSync(f).size,sha256:hash(fs.readFileSync(f))};};
const inputs=JSON.parse(fs.readFileSync(inputsFile,'utf8')),receipt=JSON.parse(fs.readFileSync(receiptFile,'utf8'));
assert.equal(receipt.kind,'phase51-same-entry-string-proof');assert.equal(receipt.complete,true);
assert.equal(inputs.roles.candidate.compiler.api.sha256,'6f9d111aa68c19f3ce45b80785621d57c4d10efb12d50164f5cb0597bc952100');
const selected=inputs.cases.filter(c=>c.id===caseId);assert.equal(selected.length,1);const c=selected[0];
assert.ok(c.point.args.length>0);assert.equal(receipt.parent.sha256,c.module.sha256);
const bindings=[identity(inputsFile),identity(receiptFile),identity(new URL(import.meta.url)),identity(process.execPath),receipt.parent,receipt.candidate];
for(const r of bindings)assert.deepEqual(identity(r.file),r);
const out=path.resolve(outArg);assert.ok(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const modules=[];
for(const [role,record] of [['baseline',receipt.parent],['candidate',receipt.candidate]]){
 let source=fs.readFileSync(record.file,'utf8');const prefix='G['+JSON.stringify(c.point.exportName)+']=';
 const lines=source.split('\n').filter(l=>l.startsWith(prefix));assert.equal(lines.length,1);
 const marker='/* private contextual instances */';assert.equal(lines[0].split(marker).length,2);
 assert.equal(source.split('function stringHostGuard(){').length,2);assert.ok(!source.includes('$phase51TokenStrings'));
 source=source.replace(lines[0],lines[0].replace(marker,marker+'$phase51TokenEntries++;'));
 source=source.replace('function stringHostGuard(){','let $phase51TokenStrings=0,$phase51TokenEntries=0;\nfunction stringHostGuard(){$phase51TokenStrings++;');
 source+='\nexport const phase51TokenProbe={G,reset(){$phase51TokenStrings=0;$phase51TokenEntries=0;},read(){return {strings:$phase51TokenStrings,entries:$phase51TokenEntries};},owned(name,args){return callOwned(get(G,name),args);}};\n';
 const file=path.join(out,role+'.mjs');fs.writeFileSync(file,source,{flag:'wx'});bindings.push(identity(file));
 modules.push({role,exports:await import(pathToFileURL(file).href)});
}
const get=Object.getOwnPropertyDescriptor,define=Object.defineProperty;
const sentinel={kind:'phase51-token-sentinel'};let events=[];
function change(object,key,descriptor){const old=get(object,key);define(object,key,descriptor);return()=>old?define(object,key,old):delete object[key];}
const scenarios=[
 {name:'clean',entries:1},
 {name:'argument-getter',entries:1,getter:true},
 {name:'argument-getter-mutates-String',entries:0,getter:true,mutate:true},
 {name:'argument-getter-reentry',entries:2,getter:true,reenter:true},
 {name:'argument-getter-throws',entries:0,getter:true,throws:true},
 {name:'String-prototype-mutated',entries:0,install(){return change(String.prototype,'charAt',{...get(String.prototype,'charAt'),value:()=>{throw sentinel;}});}},
 {name:'global-source-getter',entries:0,install(m){const g=m.phase51TokenProbe.G,old=get(g,'String.append');assert.ok(old);return change(g,'String.append',{configurable:true,get(){events.push('source');return old.value;}});}},
 {name:'source-code-getter',entries:0,install(m){const f=m.phase51TokenProbe.G['String.append'],old=get(f,'code');return change(f,'code',{configurable:true,get(){events.push('code');return old.value;}});}},
 {name:'source-call-getter',entries:0,install(m){const f=m.phase51TokenProbe.G['String.append'].code;return change(f,'call',{configurable:true,get(){events.push('call');return Function.prototype.call;}});}},
 {name:'reflection-replacement',entries:0,install(){return change(Object,'getOwnPropertyDescriptor',{...get(Object,'getOwnPropertyDescriptor'),value(...a){events.push('reflection');return get(...a);}});}},
 {name:'Number-check-replacement',entries:0,install(){const old=Number.isInteger;return change(Number,'isInteger',{...get(Number,'isInteger'),value(x){events.push('integer');return old(x);}});}},
];
const rows=[];
for(const test of scenarios){
 const observations=[];
 for(const {role,exports:m} of modules){
  events=[];const p=m.phase51TokenProbe,restores=[];let getterCount=0,beforeGetter=null;
  if(test.install)restores.push(test.install(m));
  const vector=[...c.point.args];
  if(test.getter)define(vector,'0',{configurable:true,get(){
   getterCount++;beforeGetter=p.read();events.push('argument');
   if(test.mutate)restores.push(change(String.prototype,'charAt',{...get(String.prototype,'charAt'),value:()=>{throw sentinel;}}));
   if(test.reenter){assert.deepEqual(m.default[c.point.exportName](...c.point.args),c.point.expected);events.push('nested');}
   if(test.throws)throw sentinel;return c.point.args[0];
  }});
  p.reset();let value,error;
  try{value=test.getter?p.owned(c.point.exportName,vector):m.default[c.point.exportName](...vector);}catch(e){error=e;}
  finally{for(let i=restores.length-1;i>=0;i--)restores[i]();}
  const count=p.read();assert.equal(count.entries,test.entries,test.name+' '+role);
  if(test.getter){assert.equal(getterCount,1);assert.equal(beforeGetter.strings,0,'argument read must precede String proof');}
  if(test.throws){assert.equal(error,sentinel);assert.equal(count.strings,0);}else{assert.equal(error,undefined,test.name);assert.deepEqual(value,c.point.expected);}
  if(test.name==='clean'||test.name==='argument-getter')assert.equal(count.strings,role==='baseline'?2:1);
  observations.push({role,value,error:error===sentinel?'sentinel':null,events:[...events],count,getterCount,beforeGetter});
  p.reset();assert.deepEqual(m.default[c.point.exportName](...c.point.args),c.point.expected);assert.equal(p.read().entries,1);
 }
 const a=observations[0],b=observations[1];assert.deepEqual({value:a.value,error:a.error,events:a.events},{value:b.value,error:b.error,events:b.events});
 rows.push({name:test.name,observations});
}
for(const item of bindings)assert.deepEqual(identity(item.file),item);
const report={kind:'phase51-same-entry-string-controls',complete:true,pass:true,diagnosticOnly:true,node:process.version,
 inputs:bindings,caseId,point:c.point,boundaries:rows.length,observations:rows,
 scope:'Counter derivatives only. Exact full values/event order/error identity, source/host fallback, argument getter mutation/reentry/throw, and restored permission. Internal owned-call probe adds no public ABI. No timing or universal equivalence claim.'};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({pass:true,boundaries:rows.length,report:path.join(out,'report.json')}));
