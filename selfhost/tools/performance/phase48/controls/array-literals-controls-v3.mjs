// Untimed loop-qualified literal-handle controls. Acyclic entries must refuse.
// Optional fourth module is
// the actual maintained Evening program, compiled by the identical candidate.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseline,candidate,output,evening]=process.argv.slice(2);
assert(output,'array-literals-controls-v3.mjs BASELINE_MODULE CANDIDATE_MODULE NEW_OUT [EVENING_MODULE]');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase48-array-literals-controls-v3',complete:false,pass:false,inputs:[],modules:[],oracles:[],boundaries:[],activation:[],metadata:[],
  scope:'Loop-qualified literal-array entry, independent F32 recurrence, retained acyclic/nullary ABI and host fallback. Optional Evening must remain ordinary. Counter derivatives are untimed.'};
const pinned=new Map(),apply=Reflect.apply,define=Object.defineProperty,descriptor=Object.getOwnPropertyDescriptor;
const N=Number,A=Array,M=Math,E=Error,round=Math.fround;
const identity=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {path:file,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};};
function pin(file,want){const x=identity(file);if(want){assert.equal(x.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(x.bytes,want.bytes);}
  if(pinned.has(x.path))assert.deepEqual(x,pinned.get(x.path));else{pinned.set(x.path,x);report.inputs.push(x);}return x;}
function audit(v){if(A.isArray(v))v.forEach(audit);else if(v&&typeof v==='object'){
  const file=v.path??v.file??v.canonicalPath;if(typeof file==='string'&&v.sha256)pin(file,v);Object.values(v).forEach(audit);}}
const convert=x=>!N.isFinite(x)||x<0||x>=4294967296?0:M.trunc(x)>>>0;
const expected=(left,right)=>convert(round(round(left+right)*round(6.25-2.25)));
const serial=x=>N.isNaN(x)?'NaN':Object.is(x,-0)?'-0':x===Infinity?'Infinity':x===-Infinity?'-Infinity':x;
function loopOracle(turns,seed){const cells=[seed,0.5];let score=0;
  for(let i=0;i<turns;i++){const old=cells[i%2];cells[i%2]=round(round(i%7)+0.25);score=round(score+round(old*0.5));}return score;}
function loopHost(m,label){const events=[],restores=[],sentinel=new E('literal loop sentinel');let value,error,sameError=false,numberCalls=0;
  const patch=(owner,key,d)=>{const old=descriptor(owner,key);restores.push(()=>old?define(owner,key,old):delete owner[key]);define(owner,key,{configurable:true,...d});};
  try{
    if(label==='helper-throw'||label==='helper-reentry'){const f=m.G['ember.step'],code=f.code;let nested=false;
      patch(f,'code',{writable:true,value:function(args){if(label==='helper-throw'){events.push('helper');throw sentinel;}
        if(!nested){nested=true;try{events.push(['reentry',m.default.glowing()]);}finally{nested=false;}}return apply(code,this,[args]);}});}
    else if(label==='swap-getter'){const f=m.G['Array.swap'];patch(m.G,'Array.swap',{get(){events.push('swap');return f;}});}
    else if(label==='Number'||label==='Number-second-throw'||label==='zero-demand'){const number=function(x){numberCalls++;events.push(['Number',serial(x)]);
      if(label==='Number-second-throw'&&numberCalls===2)throw sentinel;return N(x);};Object.setPrototypeOf(number,N);patch(globalThis,'Number',{writable:true,value:number});}
    else if(label==='fround'){const original=M.fround;patch(M,'fround',{writable:true,value:function(x){events.push(['fround',serial(x)]);return original(x);}});}
    else if(label==='DataView'){const original=DataView.prototype.setUint32;patch(DataView.prototype,'setUint32',{writable:true,value:function(...args){events.push(['float',args[1]]);return apply(original,this,args);}});}
    else if(label==='iterator'){const original=A.prototype[Symbol.iterator];patch(A.prototype,Symbol.iterator,{writable:true,value:function(){events.push('iterator');return apply(original,this,[]);}});}
    else throw new E(label);
    value=label==='zero-demand'?m.default.cycling(0,1.5):m.default.glowing();
  }catch(e){error={name:e.name,message:e.message};sameError=e===sentinel;}finally{for(let i=restores.length-1;i>=0;i--)restores[i]();}
  if(label==='helper-throw'||label==='Number-second-throw'){assert(sameError);assert.equal(value,undefined);}
  else{assert.equal(error,undefined);assert(Object.is(value,label==='zero-demand'?0:loopOracle(37,1.5)));}
  if(label==='zero-demand'){assert.equal(numberCalls,0);assert.equal(events.length,0);}
  else{assert(events.length);if(label==='Number')assert.equal(numberCalls,74);if(label==='Number-second-throw')assert.equal(numberCalls,2);}
  return {value:serial(value),error,sameError,numberCalls,events};}
function snapshot(m){const objects=[m.G];for(const d of Object.values(Object.getOwnPropertyDescriptors(m.G))){const f=d.value;
  if(f&&typeof f==='object')for(const o of [f,f.code,f.bound])if(o&&(typeof o==='object'||typeof o==='function'))objects.push(o);}
  const rows=[...new Set(objects)].map(o=>[o,Object.getOwnPropertyDescriptors(o),Object.getPrototypeOf(o)]);
  return ()=>{for(const [o,ds,proto]of rows){for(const k of Reflect.ownKeys(o))if(!Object.hasOwn(ds,k))delete o[k];Object.setPrototypeOf(o,proto);Object.defineProperties(o,ds);}};}
function observe(m,action){const restore=snapshot(m),events=[];let value,error;
  try{value=action(m,events);}catch(e){error={name:e.name,message:e.message};}finally{restore();}return {value,error,events};}
function metadata(m,name='gleam'){const f=m.G[name],c=f.code,ds=Object.getOwnPropertyDescriptors(c);
  assert.equal(f.arity,0);assert.equal(c.length,0);assert.equal(c.name,'');assert(Object.hasOwn(c,'prototype'));assert.equal(c.prototype.constructor,c);
  return {arity:f.arity,length:ds.length,name:ds.name,prototype:{writable:ds.prototype.writable,enumerable:ds.prototype.enumerable,configurable:ds.prototype.configurable},keys:Reflect.ownKeys(c).map(String),env:f.env,bound:[...f.bound]};}
function host(m,label){const events=[],restores=[],sentinel=new E('literal host sentinel');let value,error,sameError=false;
  const patch=(owner,key,d)=>{const old=descriptor(owner,key);restores.push(()=>define(owner,key,old));define(owner,key,{configurable:true,...d});};
  try{
    if(label.startsWith('float')){const original=DataView.prototype.setUint32;patch(DataView.prototype,'setUint32',{writable:true,value:function(...args){events.push(['float',args[1]]);
      if(label==='float-throw')throw sentinel;return apply(original,this,args);}});}
    else if(label==='iterator'){const original=A.prototype[Symbol.iterator];patch(A.prototype,Symbol.iterator,{writable:true,value:function(){events.push('iterator');return apply(original,this,[]);}});}
    else if(label==='fround'){const original=M.fround;patch(M,'fround',{writable:true,value:function(x){events.push(['fround',serial(x)]);return original(x);}});}
    else throw new E(label);
    value=m.default.gleam();
  }catch(e){error={name:e.name,message:e.message};sameError=e===sentinel;}finally{for(let i=restores.length-1;i>=0;i--)restores[i]();}
  if(label==='float-throw'){assert(sameError);assert.equal(events.length,1);}else{assert.equal(value,8);assert.equal(error,undefined);assert(events.length);}
  return {value,error,sameError,events};
}
try{
  pin(import.meta.filename);pin(process.execPath);fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
  const catId=pin(path.join(import.meta.dirname,'array-literals-catalog-v2.json')),cat=JSON.parse(fs.readFileSync(catId.path,'utf8'));
  assert.equal(cat.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
  const source=pin(path.join(import.meta.dirname,cat.cases[0].source.path),cat.cases[0].source),modules=[],texts=[];
  for(const [i,file]of [baseline,candidate].entries()){
    const module=pin(file),receipt=pin(module.path+'.json'),r=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(r.kind,'bend-program-checked-emission');assert.equal(r.complete,true);assert.equal(r.observation.checked,true);assert.equal(r.observation.status,'ok');
    assert.equal(r.output.sha256,module.sha256);assert.equal(r.input.sha256,source.sha256);assert.equal(r.catalog.sha256,catId.sha256);
    assert.equal(r.compiler.upstreamCommit,cat.upstreamCommit);assert(['checked-development-attempt','installed-checked-release'].includes(r.compiler.kind));audit(r);
    report.modules.push({role:i?'candidate':'baseline',module,receipt,compiler:r.compiler});texts.push(fs.readFileSync(module.path,'utf8'));modules.push(await import(pathToFileURL(module.path)));
  }
  for(const left of [0,-0,0.5,round(1/3),-2,NaN,Infinity,2**32])for(const right of [0,1.5,-3,2**-149]){
    const want=expected(left,right),values=modules.map(m=>m.default.seeded(left,right));for(const value of values)assert.equal(value,want);
    report.oracles.push({root:'seeded',left:serial(left),right:serial(right),expected:want,values});}
  for(const flag of [false,true])for(const seed of [0,-0,1.5,NaN]){const values=modules.map(m=>m.default.conditional(seed,flag));for(const value of values)assert.equal(value,flag?2:17);
    report.oracles.push({root:'conditional',flag,seed:serial(seed),expected:flag?2:17,values});}
  for(const m of modules){assert.equal(m.default.gleam(),8);assert.equal(m.default.gleam(),8);assert.equal(m.default.computed_field(2),1);
    const first=m.default.returned(2),second=m.default.returned(2);assert.notEqual(first,second);assert.equal(first.$,'ANode');assert(!Object.hasOwn(first,'array'));
    const pair=m.call(m.G['Array.size'],[null,first]);assert.equal(pair[0],first);assert.equal(pair[1],2);assert(Object.hasOwn(first,'array'));assert(!Object.hasOwn(second,'array'));}
  for(const turns of [0,1,2,5,17,128])for(const seed of [0,-0,round(1/3),1.5,-3,2**-149,NaN,Infinity,-Infinity]){
    const want=loopOracle(turns,seed),values=modules.map(m=>m.default.cycling(turns,seed));for(const value of values)assert(Object.is(value,want));
    report.oracles.push({root:'cycling',turns,seed:serial(seed),expected:serial(want),values:values.map(serial)});}
  for(const turns of [8192,50000]){const want=loopOracle(turns,3),values=modules.map(m=>m.default.cycling(turns,3));for(const value of values)assert(Object.is(value,want));
    report.oracles.push({root:'cycling',turns,seed:3,expected:serial(want),values:values.map(serial),deep:true});}
  for(const m of modules){assert.equal(m.default.glowing(),loopOracle(37,1.5));assert.equal(m.default.glowing(),loopOracle(37,1.5));
    assert.equal(m.default.loop_bench(...cat.cases[0].point.args),cat.cases[0].point.expected);}
  const glowingMeta=modules.map(m=>metadata(m,'glowing'));assert.deepEqual(glowingMeta[1],glowingMeta[0]);report.metadata.push({root:'glowing',observations:glowingMeta});
  const meta=modules.map(m=>metadata(m));assert.deepEqual(meta[1],meta[0]);report.metadata.push({root:'gleam',observations:meta});
  const specs=[],add=(name,action,refuses=true)=>specs.push({name,action,refuses});
  add('repeated-fresh-storage',(m,e)=>{const f=m.G['Array.swap'],code=f.code,handles=[];f.code=function(args){handles.push(args[1]);return apply(code,this,[args]);};
    const values=[m.default.gleam(),m.default.gleam()];assert.deepEqual(values,[8,8]);assert.equal(handles.length,4);assert.equal(handles[0],handles[1]);assert.equal(handles[2],handles[3]);assert.notEqual(handles[0],handles[2]);return {values,sameWithin:true,freshAcross:true};});
  add('helper-replacement',(m,e)=>{m.G['gleam.first'].code=()=>{e.push('helper');return 73;};assert.equal(m.default.gleam(),73);return 73;});
  add('helper-error',(m,e)=>{const token=new E('literal helper sentinel');m.G['gleam.first'].code=()=>{e.push('helper');throw token;};try{m.default.gleam();assert.fail('Expected sentinel');}catch(error){assert.equal(error,token);}return 'same-error';});
  add('helper-reentry',(m,e)=>{const f=m.G['gleam.first'],code=f.code;let active=false;f.code=function(args){if(!active){active=true;try{e.push(m.default.gleam());}finally{active=false;}}return apply(code,this,[args]);};
    const value=m.default.gleam();assert.equal(value,8);assert.deepEqual(e,[8]);return value;});
  for(const name of ['gleam','gleam.first'])for(const mode of ['global-getter','code-getter','env-getter','bound-getter','arity-getter','own-call'])add(name+':'+mode,(m,e)=>{
    const f=m.G[name],code=f.code;if(mode==='global-getter')define(m.G,name,{configurable:true,get(){e.push('G');return f;}});
    for(const key of ['code','env','bound','arity'])if(mode===key+'-getter'){const value=f[key];define(f,key,{configurable:true,get(){e.push(key);return value;}});}
    if(mode==='own-call')define(code,'call',{configurable:true,value:function(receiver,a){e.push('call');return apply(code,receiver,[a]);}});
    const value=m.default.gleam();assert.equal(value,8);assert(e.length);return value;});
  for(const args of [[],[[]],[[],true]])add('raw-code:'+args.length,(m,e)=>{const raw=apply(m.G.gleam.code,{receiver:true},args);assert.equal(raw.bounce,true);return {bounce:true,value:m.call(raw,[])};});
  add('construct-code',(m,e)=>{const raw=Reflect.construct(m.G.gleam.code,[]);assert.equal(raw.bounce,true);return {bounce:true,value:m.call(raw,[])};});
  add('missing-arguments-getter',(m,e)=>{const old=descriptor(Object.prototype,'0');let reads=0,raw;
    try{define(Object.prototype,'0',{configurable:true,get(){reads++;return undefined;}});raw=m.G.gleam.code();}
    finally{if(old)define(Object.prototype,'0',old);else delete Object.prototype[0];}
    assert.equal(reads,0);assert.equal(raw.bounce,true);return {reads,bounce:true,value:m.call(raw,[])};});
  add('overapplication',(m,e)=>{let error;try{m.call(m.G.gleam,[1]);}catch(x){error={name:x.name,message:x.message};}assert(error);return error;});
  for(const spec of specs){const observations=modules.map(m=>observe(m,spec.action));assert.deepEqual(observations[1],observations[0],spec.name);assert.equal(observations[0].error,undefined);report.boundaries.push({name:spec.name,observations});}
  for(const label of ['float','float-throw','iterator','fround']){const observations=modules.map(m=>host(m,label));assert.deepEqual(observations[1],observations[0]);report.boundaries.push({name:'host:'+label,observations});}
  const loopLabels=['helper-throw','helper-reentry','swap-getter','Number','Number-second-throw','zero-demand','fround','DataView','iterator'];
  for(const label of loopLabels){const observations=modules.map(m=>loopHost(m,label));assert.deepEqual(observations[1],observations[0]);report.boundaries.push({name:'loop:'+label,observations});}
  for(const mode of ['raw-empty','raw-array','raw-forged','construct','missing-getter','overapplication']){
    const action=m=>{let raw;
      if(mode==='raw-empty')raw=apply(m.G.glowing.code,{},[]);
      if(mode==='raw-array')raw=apply(m.G.glowing.code,{},[[]]);
      if(mode==='raw-forged')raw=apply(m.G.glowing.code,{},[[],true]);
      if(mode==='construct')raw=Reflect.construct(m.G.glowing.code,[]);
      if(mode==='missing-getter'){const old=descriptor(Object.prototype,'0');let reads=0,error;
        // Ordinary glowing evaluates its loop before returning the outer bounce.
        // A deferred Tuple forces a pending-frame push under this inherited
        // getter-only slot: that source operation throws without reading it.
        try{define(Object.prototype,'0',{configurable:true,get(){reads++;return undefined;}});raw=m.G.glowing.code();}
        catch(e){error={name:e.name,message:e.message};}
        finally{if(old)define(Object.prototype,'0',old);else delete Object.prototype[0];}
        assert.equal(reads,0);assert.deepEqual(error,{name:'TypeError',message:'Cannot set property 0 of #<Object> which has only a getter'});
        return {reads,error};}
      if(mode==='overapplication'){let error;try{m.call(m.G.glowing,[1]);}catch(e){error={name:e.name,message:e.message};}assert(error);return error;}
      assert.equal(raw.bounce,true);const value=m.call(raw,[]);assert(Object.is(value,loopOracle(37,1.5)));return {bounce:true,value};};const observations=modules.map(m=>observe(m,action));
    assert.deepEqual(observations[1],observations[0]);assert.equal(observations[0].error,undefined);report.boundaries.push({name:'glowing:'+mode,observations});specs.push({name:'glowing:'+mode,action,refuses:true});}
  report.correctnessPass=true;
  const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};
  new Function('module','exports',parserSource)(parserModule,parserModule.exports);
  const parse=text=>parserModule.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});
  function nodes(root){const todo=[root],found=[];while(todo.length){const n=todo.pop();if(!n||typeof n!=='object'||typeof n.type!=='string')continue;found.push(n);
    for(const x of Object.values(n))if(A.isArray(x))todo.push(...x);else if(x&&typeof x==='object')todo.push(x);}return found;}
  function derive(text,parent,roots,label,refusals=[]){const ast=nodes(parse(text)),marker='/* private literal array handles */',edits=[];
    for(const name of [...roots,...refusals]){const rows=ast.filter(n=>n.type==='AssignmentExpression'&&n.left.type==='MemberExpression'&&n.left.object.type==='Identifier'&&n.left.object.name==='G'&&n.left.computed&&n.left.property.type==='Literal'&&n.left.property.value===name);
      assert.equal(rows.length,1,name+' unique public definition');const row=rows[0],body=text.slice(row.right.start,row.right.end),hits=body.split(marker).length-1;
      assert.equal(hits,roots.includes(name)?1:0,name+' handle admission');if(hits)edits.push({name,at:row.right.start+body.indexOf(marker)+marker.length});}
    assert(!text.includes('$p48LiteralEntries'));let derived=text;for(const edit of [...edits].sort((a,b)=>b.at-a.at))derived=derived.slice(0,edit.at)+'++$p48LiteralEntries['+JSON.stringify(edit.name)+'];'+derived.slice(edit.at);
    derived='const $p48LiteralEntries='+JSON.stringify(Object.fromEntries(roots.map(n=>[n,0])))+';\n'+derived+'\nexport const phase48LiteralEntries=()=>({...$p48LiteralEntries});\n';parse(derived);
    const file=path.join(out,label+'-counter.mjs');fs.writeFileSync(file,derived,{flag:'wx'});const module=identity(file);
    (report.derivatives??=[]).push({module,parent,edits,performanceEvidence:false,parser:{version:parserModule.exports.version,sha256:createHash('sha256').update(parserSource).digest('hex')}});return file;}
  const roots=['cycling','glowing'],file=derive(texts[1],report.modules[1].module,roots,'candidate',['gleam','seeded','conditional','returned','computed_field']);
  const witness=await import(pathToFileURL(file));assert.deepEqual(witness.phase48LiteralEntries(),{cycling:0,glowing:0});
  for(const turns of [0,1,128,8192]){const before=witness.phase48LiteralEntries(),value=witness.default.cycling(turns,3),after=witness.phase48LiteralEntries();
    assert(Object.is(value,loopOracle(turns,3)));assert.equal(after.cycling-before.cycling,1);assert.equal(after.glowing,before.glowing);report.activation.push({root:'cycling',turns,entries:1});}
  {const before=witness.phase48LiteralEntries();assert.equal(witness.default.glowing(),loopOracle(37,1.5));assert.equal(witness.default.glowing(),loopOracle(37,1.5));
    const after=witness.phase48LiteralEntries();assert.equal(after.glowing-before.glowing,2);assert.equal(after.cycling,before.cycling);report.activation.push({root:'glowing',entries:2});}
  {const before=witness.phase48LiteralEntries();assert.equal(witness.default.gleam(),8);assert.equal(witness.default.seeded(2,3),20);assert.equal(witness.default.conditional(2,true),2);
    assert.deepEqual(witness.phase48LiteralEntries(),before);report.activation.push({refusal:'acyclic-roots',roots:['gleam','seeded','conditional']});}
  for(const label of loopLabels){const before=witness.phase48LiteralEntries(),observation=loopHost(witness,label),after=witness.phase48LiteralEntries();
    assert.deepEqual(observation,report.boundaries.find(x=>x.name==='loop:'+label).observations[1]);assert.deepEqual(after,before);report.activation.push({refusal:'loop:'+label,before,after});}
  for(const spec of specs){const before=witness.phase48LiteralEntries(),observation=observe(witness,spec.action),after=witness.phase48LiteralEntries();
    assert.deepEqual(observation,report.boundaries.find(x=>x.name===spec.name).observations[1]);if(spec.refuses)assert.deepEqual(after,before,spec.name+' ungranted entry');report.activation.push({refusal:spec.name,before,after});}
  for(const label of ['float','float-throw','iterator','fround']){const before=witness.phase48LiteralEntries(),observation=host(witness,label),after=witness.phase48LiteralEntries();
    assert.deepEqual(observation,report.boundaries.find(x=>x.name==='host:'+label).observations[1]);assert.deepEqual(after,before);report.activation.push({refusal:'host:'+label,before,after});}
  if(evening){const module=pin(evening),receipt=pin(module.path+'.json'),r=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(r.kind,'bend-program-checked-emission');assert.equal(r.complete,true);assert.equal(r.observation.checked,true);assert.equal(r.observation.status,'ok');assert.equal(r.output.sha256,module.sha256);audit(r);
    const selected=report.modules[1].compiler;for(const key of ['api','runtime','base','driver'])assert.equal(r.compiler[key].sha256,selected[key].sha256);assert.equal(r.compiler.sourceSha256,selected.sourceSha256);
    report.modules.push({role:'actual-evening',module,receipt,compiler:r.compiler});
    const real=await import(pathToFileURL(module.path));assert.equal(real.default.fpart(),8);assert.equal(real.default['main.out'](),81111);
    const efile=derive(fs.readFileSync(module.path,'utf8'),module,[],'evening',['fpart']),ew=await import(pathToFileURL(efile));assert.deepEqual(ew.phase48LiteralEntries(),{});
    assert.equal(ew.default.fpart(),8);assert.equal(ew.default['main.out'](),81111);assert.deepEqual(ew.phase48LiteralEntries(),{});report.activation.push({root:'actual-evening/fpart',entries:0,refusal:'acyclic',values:[8,81111]});}
  for(const d of report.derivatives)assert.deepEqual(identity(d.module.path),d.module);for(const x of pinned.values())assert.deepEqual(identity(x.path),x);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,(_k,v)=>typeof v==='bigint'?{$bigint:String(v)}:v,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,boundaries:report.boundaries.length,activation:report.activation.length,error:report.error}));
