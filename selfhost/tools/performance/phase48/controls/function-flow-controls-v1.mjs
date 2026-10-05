// Untimed actual checked-source known-function controls. Root owns execution.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseline,candidate,typescript,destination]=process.argv.slice(2);
assert(destination,'function-flow-controls-v1.mjs BASELINE CANDIDATE PINNED_TS NEW_OUT');
const out=path.resolve(destination);fs.mkdirSync(out);
const report={kind:'phase48-actual-function-flow-controls-v1',complete:false,pass:false,inputs:[],modules:[],oracles:[],boundaries:[],activation:[],timingEligible:false};
const pins=new Map(),define=Object.defineProperty,desc=Object.getOwnPropertyDescriptor,apply=Reflect.apply;
function identity(file){file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};}
function pin(file,want){const x=identity(file);if(want){assert.equal(x.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(x.bytes,want.bytes);}
 if(pins.has(x.file))assert.deepEqual(x,pins.get(x.file));else{pins.set(x.file,x);report.inputs.push(x);}return x;}
function audit(v){if(!v||typeof v!=='object')return;const file=v.file??v.path??v.canonicalPath;if(typeof file==='string'&&v.sha256)pin(file,v);for(const x of Object.values(v))audit(x);}
const error=e=>({name:e?.name??null,message:e?.message??String(e)});
function value(v){if(typeof v==='bigint')return {bigint:String(v)};if(v&&typeof v==='object'&&typeof v.code==='function')return {closure:true,arity:v.arity,bound:v.bound.length};return v;}
function observe(fn){try{return {value:value(fn())};}catch(e){return {error:error(e)};}}
const positive=['sample','ordered','fresh','retained','failorder','unused'];
const negative=['returned','unknown','branched'];
const methods=m=>m.default??m;
const maxNat=281474976710655n;
try{
 pin(import.meta.filename);pin(process.execPath);
 const catalogId=pin(path.join(import.meta.dirname,'function-flow-catalog-v2.json'));
 const catalog=JSON.parse(fs.readFileSync(catalogId.file));assert.equal(catalog.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
 const source=pin(path.join(import.meta.dirname,catalog.cases[0].source.path),catalog.cases[0].source);
 const texts=[];
 for(const [role,file]of [['baseline',baseline],['candidate',candidate],['typescript',typescript]]){
  const module=pin(file),receipt=pin(module.file+'.json'),r=JSON.parse(fs.readFileSync(receipt.file));
  assert.equal(r.kind,'bend-program-checked-emission');assert.equal(r.complete,true);assert.equal(r.observation.checked,true);assert.equal(r.observation.status,'ok');
  assert.equal(r.output.sha256,module.sha256);assert.equal(r.input.sha256,source.sha256);assert.equal(r.catalog.sha256,catalogId.sha256);assert.equal(r.compiler.upstreamCommit,catalog.upstreamCommit);audit(r);
  if(role!=='typescript')assert(['checked-development-attempt','installed-checked-release'].includes(r.compiler.kind));
  report.modules.push({role,module,receipt,compiler:r.compiler});texts.push(fs.readFileSync(module.file,'utf8'));
 }
 const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};
 new Function('module','exports',parserSource)(parserModule,parserModule.exports);
 const parse=s=>parserModule.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
 report.parser={version:parserModule.exports.version,sha256:createHash('sha256').update(parserSource).digest('hex')};
 function assignments(text){const rows=[];function walk(n){if(!n||typeof n!=='object')return;
  if(n.type==='AssignmentExpression'&&n.operator==='='&&n.left.type==='MemberExpression'&&n.left.computed&&n.left.object.type==='Identifier'&&n.left.object.name==='G'&&n.left.property.type==='Literal')rows.push(n);
  for(const x of Object.values(n))if(Array.isArray(x))x.forEach(walk);else if(x&&typeof x==='object')walk(x);}
  walk(parse(text));return rows;}
 const modules=[];
 for(const [i,role]of ['baseline','candidate'].entries()){
  const text=texts[i];assert(!text.includes('$p48FunctionEntries'));const rows=assignments(text),edits=[];
  for(const root of [...positive,...negative]){
   const sites=rows.filter(n=>n.left.property.value===root);assert.equal(sites.length,1,'one complete G assignment '+root);
   const n=sites[0],body=text.slice(n.start,n.end),selected=body.includes('/* private known function flow */');
   assert.equal(selected,i===1&&positive.includes(root),'actual-source flow admission '+root);
   if(selected){const marker='/* private contextual instances */';assert.equal(body.split(marker).length-1,1);
    assert(body.includes('regionHostGuard()&&stringHostGuard()'),'full host guards required');assert(body.includes('localGuard($guards)'));
    const g=body.match(/const \$guards=(\[[^\]]*\]);/);assert(g);const names=JSON.parse(g[1].replace(/,\]$/,']'));
    if(['sample','ordered','fresh','retained','unused'].includes(root)){assert(names.includes('saffron.make'));assert(names.includes(root));}
    if(root==='ordered')assert(names.includes('saffron.sub'));
    if(root==='failorder')for(const name of ['saffron.natmake','saffron.bump','saffron.later','saffron.apply'])assert(names.includes(name));
    if(root==='unused')assert(names.includes('saffron.ignore'));
    edits.push({start:n.start,end:n.end,body:body.replace(marker,marker+`$p48FunctionEntries[${JSON.stringify(root)}]=($p48FunctionEntries[${JSON.stringify(root)}]??0)+1;`)});
    report.activation.push({root,guards:names});
   }
  }
  let counted=text;for(const e of edits.sort((a,b)=>b.start-a.start))counted=counted.slice(0,e.start)+e.body+counted.slice(e.end);
  counted='const $p48FunctionEntries=Object.create(null);\n'+counted+'\nexport const $P48Flow={count:r=>$p48FunctionEntries[r]??0,proof:()=>regionProof};\n';parse(counted);
  const file=path.join(out,role+'-counted.mjs');fs.writeFileSync(file,counted,{flag:'wx'});pin(file);modules.push(await import(pathToFileURL(file)));
 }
 const ts=await import(pathToFileURL(report.modules[2].module.file));
 const oracles={sample:n=>(n+8)>>>0,ordered:n=>(n-6)>>>0,fresh:n=>(n+1)>>>0,retained:n=>(n+1)>>>0};
 for(const n of [0,1,2,10,0x7fffffff,0xffffffff])for(const root of Object.keys(oracles)){
  const expected=oracles[root](n),rows=[];
  for(const [i,m]of modules.entries()){const before=m.$P48Flow.count(root),v=m.default[root](n),entries=m.$P48Flow.count(root)-before;
   assert.equal(v,expected);assert.equal(entries,i);assert.equal(m.$P48Flow.proof(),null);rows.push({value:v,entries});}
  assert.equal(methods(ts)[root](n),expected);report.oracles.push({root,args:[n],expected,rows});
 }
 for(const [root,args,expected]of [['failorder',[7n],16],['unused',[10,4n],18]]){
  const rows=[];for(const [i,m]of modules.entries()){const before=m.$P48Flow.count(root),v=m.default[root](...args),entries=m.$P48Flow.count(root)-before;
   assert.equal(v,expected);assert.equal(entries,i);assert.equal(m.$P48Flow.proof(),null);rows.push({value:v,entries});}
  assert.equal(methods(ts)[root](...args),expected);report.oracles.push({root,args:args.map(value),expected,rows});
 }
 function boundary(name,scenario){const rows=[];for(const [i,m]of modules.entries()){
  const before=Object.fromEntries(positive.map(r=>[r,m.$P48Flow.count(r)])),events=[],outcome=scenario(m,events);
  const entries=Object.fromEntries(positive.map(r=>[r,m.$P48Flow.count(r)-before[r]]));assert.equal(m.$P48Flow.proof(),null);
  if(i)assert(Object.values(entries).every(n=>n===0),'boundary must use unchanged generic fallback '+name);
  rows.push({outcome,events,entries});}
  assert.deepEqual(rows[1].outcome,rows[0].outcome,name);assert.deepEqual(rows[1].events,rows[0].events,name);report.boundaries.push({name,rows});}
 const restorePatch=(owner,key,descriptor,fn)=>{const old=desc(owner,key);define(owner,key,descriptor);try{return fn();}finally{old?define(owner,key,old):delete owner[key];}};
 for(const name of ['sample','saffron.make','saffron.apply'])for(const field of ['code','env','bound','arity'])for(const mode of ['replacement','getter'])boundary(`${name}.${field}.${mode}`,(m,events)=>{
  const f=m.G[name],old=desc(f,field);let replacement=old.value;
  if(field==='code')replacement=function(a){events.push(name);return apply(old.value,this,[a]);};
  if(field==='env')replacement={};if(field==='bound')replacement=[];if(field==='arity')replacement=old.value+1;
  const patch=mode==='getter'?{configurable:old.configurable,enumerable:old.enumerable,get(){events.push(name+'.'+field);return old.value;}}:{...old,value:replacement};
  return restorePatch(f,field,patch,()=>observe(()=>m.default.sample(10)));
 });
 for(const name of ['saffron.bump','saffron.later'])boundary(name+'.code',(m,events)=>{
  const f=m.G[name],old=desc(f,'code');return restorePatch(f,'code',{...old,value:function(a){events.push(name);return apply(old.value,this,[a]);}},()=>observe(()=>m.default.failorder(7n)));
 });
 for(const name of ['factory-prefix-failure','unused-actual-failure']){
  const root=name==='factory-prefix-failure'?'failorder':'unused',args=root==='failorder'?[maxNat]:[10,maxNat],rows=[];
  for(const [i,m]of modules.entries()){const before=m.$P48Flow.count(root),outcome=observe(()=>m.default[root](...args));assert(outcome.error);assert.equal(m.$P48Flow.proof(),null);rows.push({outcome,entries:m.$P48Flow.count(root)-before});}
  assert.deepEqual(rows[1].outcome,rows[0].outcome);report.boundaries.push({name,rows});
 }
 boundary('prefix-before-later-argument',(m,events)=>{const f=m.G['saffron.bump'],old=desc(f,'code');return restorePatch(f,'code',{...old,value:function(a){events.push('prefix');return apply(old.value,this,[a]);}},()=>{
  const g=m.G['saffron.later'],later=desc(g,'code');return restorePatch(g,'code',{...later,value:function(a){events.push('later');return apply(later.value,this,[a]);}},()=>{const r=observe(()=>m.default.failorder(maxNat));assert.deepEqual(events,['prefix']);return r;});});});
 boundary('Error-reentry',(m,events)=>{const old=desc(globalThis,'Error'),original=old.value;let busy=false;
  return restorePatch(globalThis,'Error',{...old,value:function(message){events.push(String(message));if(!busy){busy=true;events.push(['reentry',m.default.sample(2)]);busy=false;}return original(message);}},()=>observe(()=>m.default.failorder(maxNat)));});
 boundary('Function.prototype.call',(m,events)=>{const old=desc(Function.prototype,'call'),code=m.G.sample.code;
  return restorePatch(Function.prototype,'call',{...old,value:function(...args){if(this===code)events.push('root-call');return apply(old.value,this,args);}},()=>observe(()=>m.default.sample(10)));});
 for(const marker of ['bounce','build','code','request'])boundary('prototype-'+marker,(m,events)=>
  restorePatch(Object.prototype,marker,{configurable:true,get(){events.push(marker);return undefined;}},()=>observe(()=>m.default.sample(10))));
 for(const root of positive){const codes=modules.map(m=>m.G[root].code);
  assert.equal(codes[0].length,1);assert.equal(codes[1].length,codes[0].length);assert.equal(codes[1].name,codes[0].name);
  assert.deepEqual(Object.getOwnPropertyNames(codes[1]),Object.getOwnPropertyNames(codes[0]));
  for(const key of ['length','name','prototype']){const a=desc(codes[0],key),b=desc(codes[1],key);assert.equal(b.configurable,a.configurable);assert.equal(b.enumerable,a.enumerable);assert.equal(b.writable,a.writable);}}
 for(const mode of ['raw','raw-call','raw-new','oversaturated'])boundary(mode,(m,events)=>observe(()=>{
  const f=m.G.sample;if(mode==='oversaturated')return m.call(f,[10,20]);
  const raw=mode==='raw'?f.code([10]):mode==='raw-call'?f.code.call(f.env,[10]):new f.code([10]);
  return m.call({arity:1,code:a=>a[0],env:null,bound:[]},[raw]);
 }));
 for(const m of modules){assert.equal(m.default.branched(true),10);assert.equal(m.default.branched(false),8);
  assert.deepEqual(value(m.default.returned(10)),{closure:true,arity:1,bound:0});
  const foreign={arity:1,code:a=>(a[0]*3)>>>0,env:null,bound:[]};assert.equal(m.call(m.G.unknown,[foreign,7]),21);}
 for(const id of pins.values())assert.deepEqual(identity(id.file),id,'consumed input changed');report.complete=true;report.pass=true;
}catch(e){report.error={name:e.name,message:e.message,stack:e.stack};throw e;}finally{fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');}
console.log(JSON.stringify({complete:true,pass:true,oracles:report.oracles.length,boundaries:report.boundaries.length}));
