// Untimed count-to-root-slot qualification. Counter derivatives are never timed.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [baseline,candidate,output]=process.argv.slice(2);
assert(output,'array-counts-controls-v1.mjs BASELINE_MODULE CANDIDATE_MODULE NEW_OUT');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase48-array-count-mapping',complete:false,pass:false,inputs:[],modules:[],oracles:[],boundaries:[],activation:[],
 scope:'Direct U32 and Nat root-count mapping, relocated slot, constant/computed unknown policy, ordinary object-count coercion. Values and host traces on untouched modules; entry counters on a separate derivative. No timing.'};
const pinned=new Map(),round=Math.fround,apply=Reflect.apply,define=Object.defineProperty,desc=Object.getOwnPropertyDescriptor;
function identity(file){file=fs.realpathSync(file);const b=fs.readFileSync(file);return{path:file,bytes:b.length,sha256:createHash('sha256').update(b).digest('hex')};}
function pin(file,want){const row=identity(file);if(want){assert.equal(row.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(row.bytes,want.bytes);}if(pinned.has(row.path))assert.deepEqual(row,pinned.get(row.path));else{pinned.set(row.path,row);report.inputs.push(row);}return row;}
function audit(x){if(Array.isArray(x))x.forEach(audit);else if(x&&typeof x==='object'){const p=x.path??x.file??x.canonicalPath;if(typeof p==='string'&&x.sha256)pin(p,x);Object.values(x).forEach(audit);}}
const scalar=x=>typeof x==='bigint'?{$bigint:String(x)}:Object.is(x,-0)?'-0':x;
function oracle(n,seed){const cells=[seed,0.5];let sum=0;for(let i=0;i<n;i++){const at=i%2,old=cells[at];cells[at]=round(round(i%7)+0.25);sum=round(sum+round(old*0.5));}return sum;}
const roots=['direct','shifted','natural','computed','constant'],cases=[];
for(const name of ['direct','shifted'])for(const n of [0,-0,1,2,37,128])for(const seed of [0,3])cases.push({name,args:name==='direct'?[n,seed]:[seed,n],expected:oracle(n,seed),entries:n===0||n===1?0:1});
for(const n of [0n,1n,2n,37n,128n])for(const seed of [0,3])cases.push({name:'natural',args:[n,seed],expected:oracle(Number(n),seed),entries:n<2n?0:1});
for(const n of [0,1,2,37])for(const seed of [0,3])cases.push({name:'computed',args:[n,seed],expected:oracle(n+1,seed),entries:1});
cases.push({name:'constant',args:[],expected:oracle(37,1.5),entries:1});
function objectCount(m,name,value,throws){const events=[],sentinel=new Error('count coercion sentinel');let result,error,sameError=false;
 const object={[Symbol.toPrimitive](hint){events.push(['coerce',hint]);if(throws)throw sentinel;return value;}};
 try{result=name==='shifted'?m.default[name](3,object):m.default[name](object,3);}catch(e){error={name:e.name,message:e.message};sameError=e===sentinel;}
 assert.equal(events.length,1,'Only the original numeric source operation may coerce');
 if(throws){assert(sameError);assert.equal(result,undefined);}else{assert.equal(error,undefined);assert(Object.is(result,oracle(value+(name==='computed'?1:0),3)));}
 return{result,error,sameError,events};}
function helper(m){const events=[],f=m.G['countwork.step'],d=desc(f,'code');let result;
 try{define(f,'code',{...d,value:function(args){events.push('step');return apply(d.value,this,[args]);}});result=m.default.direct(2,3);assert.equal(result,oracle(2,3));assert.deepEqual(events,['step','step']);}
 finally{define(f,'code',d);}return{result,events};}
function nodes(root){const found=[];function go(x){if(!x||typeof x!=='object')return;if(typeof x.type==='string')found.push(x);for(const y of Object.values(x))if(Array.isArray(y))y.forEach(go);else if(y&&typeof y==='object')go(y);}go(root);return found;}
try{
 pin(import.meta.filename);pin(process.execPath);pin(path.join(import.meta.dirname,'array-literals-controls-v3.mjs'));fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
 const catalogId=pin(path.join(import.meta.dirname,'array-counts-catalog-v1.json')),catalog=JSON.parse(fs.readFileSync(catalogId.path,'utf8'));assert.equal(catalog.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');assert.equal(catalog.cases.length,1);
 const source=pin(path.join(import.meta.dirname,catalog.cases[0].source.path),catalog.cases[0].source),modules=[],texts=[];
 for(const [role,file]of [['baseline',baseline],['candidate',candidate]]){const module=pin(file),receipt=pin(file+'.json'),r=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
  assert.equal(r.kind,'bend-program-checked-emission');assert(r.complete&&r.observation.checked&&r.observation.status==='ok');assert.equal(r.catalog.sha256,catalogId.sha256);assert.equal(r.input.sha256,source.sha256);assert.equal(r.output.sha256,module.sha256);assert.equal(r.compiler.upstreamCommit,catalog.upstreamCommit);assert(['checked-development-attempt','installed-checked-release'].includes(r.compiler.kind));audit(r);
  modules.push(await import(pathToFileURL(module.path)));texts.push(fs.readFileSync(module.path,'utf8'));report.modules.push({role,module,receipt,compiler:r.compiler});}
 for(const c of cases){const values=modules.map(m=>m.default[c.name](...c.args));for(const v of values)assert(Object.is(v,c.expected));report.oracles.push({root:c.name,args:c.args.map(scalar),expected:c.expected,values});}
 const objects=[];for(const name of ['direct','shifted','computed'])for(const value of [0,1,2])objects.push({name,value,throws:false});for(const name of ['direct','shifted','computed'])objects.push({name,value:0,throws:true});
 for(const spec of objects){const values=modules.map(m=>objectCount(m,spec.name,spec.value,spec.throws));assert.deepEqual(values[1],values[0]);report.boundaries.push({kind:'object-count',...spec,values});}
 {const values=modules.map(helper);assert.deepEqual(values[1],values[0]);report.boundaries.push({kind:'helper-replacement',values});}
 const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};new Function('module','exports',parserSource)(parser,parser.exports);
 const parse=text=>parser.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'}),text=texts[1],all=nodes(parse(text)),edits=[],marker='/* private literal array handles */';
 for(const name of roots){const matches=all.filter(n=>n.type==='AssignmentExpression'&&n.operator==='='&&n.left.type==='MemberExpression'&&n.left.computed&&n.left.object.name==='G'&&n.left.property.value===name);assert.equal(matches.length,1,name+' unique root');const rhs=matches[0].right,fragment=text.slice(rhs.start,rhs.end);assert.equal(fragment.split(marker).length,2,name+' keeps original literal admission');edits.push({name,at:rhs.start+fragment.indexOf(marker)+marker.length});}
 assert(!text.includes('$p48CountEntries'));let altered=text;for(const e of [...edits].sort((a,b)=>b.at-a.at))altered=altered.slice(0,e.at)+'++$p48CountEntries['+JSON.stringify(e.name)+'];'+altered.slice(e.at);
 altered='const $p48CountEntries='+JSON.stringify(Object.fromEntries(roots.map(n=>[n,0])))+';\n'+altered+'\nexport const phase48CountEntries=()=>({...$p48CountEntries});\n';parse(altered);
 const file=path.join(out,'candidate-counter.mjs');fs.writeFileSync(file,altered,{flag:'wx'});const derivative=pin(file),w=await import(pathToFileURL(file));report.derivative={module:derivative,parent:report.modules[1].module,edits,timingEligible:false,parserSha256:createHash('sha256').update(parserSource).digest('hex')};
 for(const c of cases){const before=w.phase48CountEntries(),value=w.default[c.name](...c.args),after=w.phase48CountEntries();assert(Object.is(value,c.expected));for(const name of roots)assert.equal(after[name]-before[name],name===c.name?c.entries:0);report.activation.push({root:c.name,args:c.args.map(scalar),entries:c.entries});}
 for(const spec of objects){const before=w.phase48CountEntries(),value=objectCount(w,spec.name,spec.value,spec.throws),after=w.phase48CountEntries();const ref=report.boundaries.find(x=>x.kind==='object-count'&&x.name===spec.name&&x.value===spec.value&&x.throws===spec.throws);assert.deepEqual(value,ref.values[1]);assert.deepEqual(after,before,'Object argument retains ordinary fallback');report.activation.push({refusal:'object-count',...spec,before,after});}
 {const before=w.phase48CountEntries(),value=helper(w),after=w.phase48CountEntries();assert.deepEqual(value,report.boundaries.find(x=>x.kind==='helper-replacement').values[1]);assert.deepEqual(after,before);report.activation.push({refusal:'helper-replacement',before,after});}
 for(const row of pinned.values())assert.deepEqual(identity(row.path),row);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,(_k,v)=>typeof v==='bigint'?{$bigint:String(v)}:v,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,boundaries:report.boundaries.length,activation:report.activation.length,error:report.error}));
