// Untimed controls on actual checked compiler emission. Root owns execution.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [cohortArg,outArg]=process.argv.slice(2);
assert(cohortArg&&outArg,'usage: countdown-compiled-controls-v2.mjs COHORT NEW_OUT');
const cohort=fs.realpathSync(cohortArg),out=path.resolve(outArg);
assert(!fs.existsSync(out));fs.mkdirSync(out);
const identity=p=>({path:fs.realpathSync(p),sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex')});
const verify=row=>{const actual=identity(row.file??row.path);assert.equal(actual.sha256,row.sha256);return actual;};
const manifestFile=path.join(cohort,'derive.json'),manifest=JSON.parse(fs.readFileSync(manifestFile));
const report={kind:'phase39-countdown-actual-controls-v2',complete:false,pass:false,node:process.version,
 derivation:{parent:identity(new URL('./countdown-compiled-controls.mjs',import.meta.url)),changes:'Use pinned TypeScript public wrappers, whose Nat input adapters accept BigInt and whose Nat result adapters return BigInt. Baseline/candidate assertions unchanged; preserve the failed v1 expectation.'},
 inputs:[identity(import.meta.filename),identity(new URL('./countdown-compiled-controls.mjs',import.meta.url)),identity(manifestFile)],oracles:[],admission:[],boundaries:[],diagnostics:[]};
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
const parserModule={exports:{}};
new Function('module','exports',process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'])(parserModule,parserModule.exports);
assert.equal(parserModule.exports.version,'8.16.0');
const parse=s=>parserModule.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
function visit(n,f){if(!n||typeof n!=='object')return;f(n);for(const [key,value]of Object.entries(n)){
 if(key==='start'||key==='end')continue;if(Array.isArray(value)){for(const child of value)visit(child,f);}else if(value&&typeof value.type==='string')visit(value,f);}}
function normalize(x){if(x===undefined)return {undefined:true};if(typeof x==='bigint')return {bigint:String(x)};
 if(typeof x==='number'&&(!Number.isFinite(x)||Object.is(x,-0)))return {number:String(x),negativeZero:Object.is(x,-0)};
 if(typeof x==='function')return {function:true};if(x===null||typeof x!=='object')return x;
 return Array.isArray(x)?x.map(normalize):Object.fromEntries(Object.keys(x).sort().map(k=>[k,normalize(x[k])]));}
function snapshot(m){const gd=Object.getOwnPropertyDescriptors(m.G),objects=[];
 for(const d of Object.values(gd)){const f=d.value;if(f&&typeof f==='object')for(const o of [f,f.code,f.bound])
  if(o&&(typeof o==='object'||typeof o==='function'))objects.push([o,Object.getOwnPropertyDescriptors(o)]);}
 return()=>{for(const [o,ds]of objects){for(const k of Reflect.ownKeys(o))if(!Object.hasOwn(ds,k))delete o[k];Object.defineProperties(o,ds);}
  for(const k of Reflect.ownKeys(m.G))if(!Object.hasOwn(gd,k))delete m.G[k];Object.defineProperties(m.G,gd);};}
function hook(o,k,descriptor,action){const old=Object.getOwnPropertyDescriptor(o,k);try{Object.defineProperty(o,k,{configurable:true,...descriptor});return action();}
 finally{if(old)Object.defineProperty(o,k,old);else delete o[k];}}
function delta(before,after){return after.trace.slice(before.trace.length);}
const eligible=['p39.count','p39.keep'],refused=['p39.escape','p39.observe'];
try{
 assert.equal(manifest.complete,true);report.inputs.push(verify(manifest.source));
 const files={};
 for(const role of ['baseline','candidate','typescript']){
  const module=verify(manifest.variants[role]),receiptIdentity=verify(manifest.emissions[role]);
  const receipt=JSON.parse(fs.readFileSync(receiptIdentity.path));
  assert.equal(receipt.kind,'bend-program-checked-emission');assert.equal(receipt.complete,true);
  assert.equal(receipt.observation.checked,true);assert.equal(receipt.input.sha256,manifest.source.sha256);
  assert.equal(receipt.output.sha256,module.sha256);assert.deepEqual(receipt.compiler,manifest.compilers[role]);
  report.inputs.push(module,receiptIdentity);files[role]=module.path;
 }
 const modules={};
 for(const role of ['baseline','candidate']){
  const source=fs.readFileSync(files[role],'utf8'),ast=parse(source),sites=[],insertions=[],shapes={};
  for(const statement of ast.body){const e=statement.type==='ExpressionStatement'&&statement.expression;
   if(!e||e.type!=='AssignmentExpression'||e.left.type!=='MemberExpression'||e.left.object.name!=='G'||typeof e.left.property.value!=='string')continue;
   const name=e.left.property.value;if(!eligible.includes(name)&&!refused.includes(name)&&!name.endsWith('_check'))continue;
   shapes[name]=source.slice(statement.start,statement.end);
   visit(statement,n=>{if(n.type!=='ForStatement'||n.test!==null||n.update!==null||n.body.type!=='BlockStatement')return;
    const text=source.slice(n.body.start,n.body.end);if(!text.includes('$s0')||!text.includes('$n0'))return;
    const id=sites.length;sites.push({id,name,start:n.start,end:n.end});
    insertions.push({at:n.body.start+1,text:'$p39ActualLoop('+JSON.stringify(name)+',$s0);'});
   });
  }
  for(const name of [...eligible,...refused])assert(shapes[name],'fixture definition emitted: '+name);
  if(role==='candidate'){
   for(const name of eligible){assert(shapes[name].includes('$s0=regionCounterNumber($s0);'),name+' actual public private-loop conversion');
    assert(shapes[name].includes('if($n0===0)'),name+' Number zero');assert(shapes[name].includes('$s0=$n0-1;'),name+' Number decrement');}
   for(const name of refused)assert(!shapes[name].includes('regionCounterNumber('),name+' extra predecessor use refuses narrowing');
  }else for(const name of eligible)assert(!shapes[name].includes('regionCounterNumber('),name+' baseline retains BigInt');
  let diagnostic=source;for(const edit of insertions.sort((a,b)=>b.at-a.at))diagnostic=diagnostic.slice(0,edit.at)+edit.text+diagnostic.slice(edit.at);
  diagnostic+='\nconst $p39ActualTrace=[];function $p39ActualLoop(name,value){$p39ActualTrace.push({name,kind:typeof value,value:String(value)});}\n'+
   'export function countdownActualState(){return {trace:$p39ActualTrace.slice(),active:regionProof!==null};}\n';
  parse(diagnostic);const file=path.join(out,role+'-diagnostic.mjs');fs.writeFileSync(file,diagnostic,{flag:'wx'});
  report.diagnostics.push({role,parent:identity(files[role]),output:identity(file),sites,insertions,
   scope:'Only counters at actual emitted private-loop entries. No new proof scope, alternative computation or public-to-private bypass.'});
  modules[role]=await import(pathToFileURL(file));
 }
 modules.typescript=await import(pathToFileURL(files.typescript));
 // Upstream js_lib public Nat wrappers accept BigInt through nat_host and
 // return BigInt, even though their private implementation uses Number.
 const call=(m,name,args)=>m.default?m.default[name](...args):m[name](...args);
 const oracle=(name,args,expected)=>{const values=Object.values(modules).map(m=>call(m,name,args));report.current={name,args:normalize(args),expected:normalize(expected),values:normalize(values)};
  assert.equal(values[0],expected);assert.equal(values[1],expected);assert.equal(values[2],expected);
  report.oracles.push(report.current);delete report.current;};
 for(const n of [0,1,2,7,31,64])for(const seed of [0,17,4294967295]){
  oracle('count_check',[n,seed],(seed+3*n)>>>0);oracle('observe_check',[n,seed],(seed+n*(n-1)/2)>>>0);
 }
 for(const n of [0,1,2,7,31])for(const value of [0n,17n,281474976710655n]){
  oracle('keep_check',[n,value],value);oracle('escape_check',[n,value],n===0?value:0n);
 }
 for(const name of [...eligible,...refused])for(const n of [0,1,7]){
  const args=[BigInt(n),name==='p39.count'||name==='p39.observe'?17:17n],before=modules.candidate.countdownActualState();
  const result=call(modules.candidate,name,args),after=modules.candidate.countdownActualState(),trace=delta(before,after);
  assert.equal(after.active,false,'proof leaked');
  if(eligible.includes(name)){assert.equal(trace.length,n,'nonvacuous emitted loop step count');for(const t of trace)assert.equal(t.kind,'number');}
  else for(const t of trace)assert.equal(t.kind,'bigint','escaping predecessor must remain BigInt');
  report.admission.push({name,n,result:normalize(result),trace});
 }
 const bends=[modules.baseline,modules.candidate],ordinary=m=>m.default.count_check(7,17);
 const observe=(m,action)=>{const restore=snapshot(m),events=[],before=m.countdownActualState();let value,error;
  try{value=action(m,events);}catch(e){error={name:e.name,message:e.message};}finally{restore();}
  const after=m.countdownActualState();assert.equal(after.active,false,'private proof leaked');
  return {value:normalize(value),error,events:normalize(events),trace:delta(before,after)};};
 const boundary=(name,action,{live=false,refuse=false}={})=>{const observations=bends.map(m=>observe(m,action));report.current={name,observations};
  const comparable=x=>({value:x.value,error:x.error,events:x.events});assert.deepEqual(comparable(observations[1]),comparable(observations[0]),name);
  if(live)for(const x of observations)assert(x.events.length>0,'inactive control '+name);
  if(refuse)for(const x of observations)assert.equal(x.trace.length,0,'private loop despite refusal '+name);
  report.boundaries.push(report.current);delete report.current;};
 for(const name of ['count_check','p39.count'])for(const mode of ['code','code-getter','binding-getter'])boundary(name+':'+mode,(m,e)=>{
  const f=m.G[name],code=f.code;if(mode==='code')f.code=function(a){e.push(name);return Reflect.apply(code,this,[a]);};
  if(mode==='code-getter')Object.defineProperty(f,'code',{configurable:true,get(){e.push('code:'+name);return code;}});
  if(mode==='binding-getter')Object.defineProperty(m.G,name,{configurable:true,get(){e.push('G:'+name);return f;}});
  return ordinary(m);
 },{live:true});
 const force=(m,x)=>m.call({arity:0,code:()=>x,env:null,bound:[]},[]);
 for(const mode of ['raw','forged','construct','partial','extra','slot0','slot1','slot-throw','slot-reentry','slot-mutation'])boundary('entry:'+mode,(m,e)=>{
  const f=m.G.count_check,code=f.code;if(mode==='partial')return m.call(m.call(f,[7]),[17]);if(mode==='extra')return m.call(f,[7,17,0]);
  const a={length:2,0:7,1:17},slot=mode==='slot1'?'1':'0';Object.defineProperty(a,slot,{get(){e.push('slot:'+slot);
   if(mode==='slot-throw')throw Error('slot sentinel');if(mode==='slot-reentry')e.push(['nested',m.default.count_check(2,3)]);
   if(mode==='slot-mutation'){const old=m.G['p39.count'].code;m.G['p39.count'].code=function(a){e.push('changed-count');return Reflect.apply(old,this,[a]);};}
   return slot==='0'?7:17;}});
  if(mode==='raw'||mode==='forged')return force(m,Reflect.apply(code,null,[a,mode==='forged']));
  if(mode==='construct')return force(m,Reflect.construct(code,[a]));return m.call(f,{slice(){e.push('slice');return a;}});
 });
 for(const mode of ['raw','forged','construct','staged','extra'])boundary('successor:'+mode,(m,e)=>{
  const f=m.call(m.G['p39.count'],[2n]);if(mode==='staged')return m.call(f,[17]);if(mode==='extra')return m.call(f,[17,0]);
  const a={length:2,1:17};Object.defineProperty(a,'0',{get(){e.push('predecessor');return 1n;}});
  return force(m,mode==='construct'?Reflect.construct(f.code,[a]):Reflect.apply(f.code,null,[a,mode==='forged']));
 });
 // This proves the new conversion does not call a replaced global Number.
 boundary('captured-Number',(m,e)=>{const OldNumber=Number;function Replacement(...args){e.push('Number');return Reflect.apply(OldNumber,this,args);}
  Object.setPrototypeOf(Replacement,OldNumber);Replacement.prototype=OldNumber.prototype;
  return hook(globalThis,'Number',{value:Replacement},()=>ordinary(m));});
 boundary('Error-reentry',(m,e)=>{const OldError=Error;let entered=false;
  return hook(globalThis,'Error',{value:function(message){e.push('Error');if(!entered){entered=true;e.push(['nested',m.default.count_check(1,7)]);}return new OldError(message);}},()=>m.call(m.G.count_check,[2,17,0]));
 },{live:true});
 // Canonical high values are accumulator/results, never huge trip counts.
 for(const name of ['keep_check','escape_check'])boundary('large-Nat-result:'+name,m=>m.default[name](3,281474976710655n));
 for(const row of report.inputs)assert.deepEqual(identity(row.path),row);
 report.complete=report.pass=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,admission:report.admission.length,boundaries:report.boundaries.length,error:report.error}));
