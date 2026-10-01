// Actual checked unary producer controls. Root owns all target execution.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [cohortArg,outArg]=process.argv.slice(2);
assert(cohortArg&&outArg,'usage: unary-compiled-controls-v2.mjs COHORT/unary NEW_OUT');
const cohort=fs.realpathSync(cohortArg),out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out);
const identity=p=>({path:fs.realpathSync(p),sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex')});
const verify=r=>{const actual=identity(r.file??r.path);assert.equal(actual.sha256,r.sha256);return actual;};
const manifestFile=path.join(cohort,'derive.json'),manifest=JSON.parse(fs.readFileSync(manifestFile));
const report={kind:'phase39-actual-unary-controls-v2',complete:false,pass:false,node:process.version,
 derivation:{parent:identity(new URL('./unary-compiled-controls.mjs',import.meta.url)),changes:'V2 observes equivalent independent alias/order scenarios in the existing two-field U32/recursive constructor domain; no compiler proof is broadened.'},
 inputs:[identity(import.meta.filename),identity(new URL('./unary-compiled-controls.mjs',import.meta.url)),identity(manifestFile)],oracles:[],structures:[],admission:[],boundaries:[],order:[]};
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
const parserModule={exports:{}};new Function('module','exports',process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'])(parserModule,parserModule.exports);
assert.equal(parserModule.exports.version,'8.16.0');const parse=s=>parserModule.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
function visit(n,f){if(!n||typeof n!=='object')return;f(n);for(const [k,v]of Object.entries(n)){
 if(k==='start'||k==='end')continue;if(Array.isArray(v)){for(const c of v)visit(c,f);}else if(v&&typeof v.type==='string')visit(v,f);}}
const decoded=n=>n?.startsWith('$R_')?n.slice(3).split('_').map(x=>String.fromCodePoint(Number(x))).join(''):null;
const names=['unary.first','unary.middle','unary.last'],pickers=names.map(n=>n.replace('unary.','unary.pick_'));
const childIndex={'unary.first':0,'unary.middle':1,'unary.last':1};
const normalize=x=>typeof x==='bigint'?{bigint:String(x)}:x===undefined?{undefined:true}:x===null||typeof x!=='object'?x:
 Array.isArray(x)?x.map(normalize):Object.fromEntries(Object.keys(x).sort().map(k=>[k,normalize(x[k])]));
function snapshot(m){const gd=Object.getOwnPropertyDescriptors(m.G),objects=[];
 for(const d of Object.values(gd)){const f=d.value;if(f&&typeof f==='object')for(const o of [f,f.code,f.bound])
  if(o&&(typeof o==='object'||typeof o==='function'))objects.push([o,Object.getOwnPropertyDescriptors(o)]);}
 return()=>{for(const [o,ds]of objects){for(const k of Reflect.ownKeys(o))if(!Object.hasOwn(ds,k))delete o[k];Object.defineProperties(o,ds);}
  for(const k of Reflect.ownKeys(m.G))if(!Object.hasOwn(gd,k))delete m.G[k];Object.defineProperties(m.G,gd);};}
function hook(o,k,descriptor,action){const old=Object.getOwnPropertyDescriptor(o,k);try{Object.defineProperty(o,k,{configurable:true,...descriptor});return action();}
 finally{if(old)Object.defineProperty(o,k,old);else delete o[k];}}
try{
 assert.equal(manifest.complete,true);report.inputs.push(verify(manifest.source));const files={},modules={};
 for(const role of ['baseline','candidate','typescript']){
  const module=verify(manifest.variants[role]),r=verify(manifest.emissions[role]),receipt=JSON.parse(fs.readFileSync(r.path));
  assert.equal(receipt.kind,'bend-program-checked-emission');assert(receipt.complete&&receipt.observation.checked);
  assert.equal(receipt.input.sha256,manifest.source.sha256);assert.equal(receipt.output.sha256,module.sha256);
  assert.deepEqual(receipt.compiler,manifest.compilers[role]);report.inputs.push(module,r);files[role]=module.path;
 }
 const source=fs.readFileSync(files.candidate,'utf8'),ast=parse(source),insertions=[],workers=[],chooserSites=[];
 const wrap=(node,prefix)=>{insertions.push({at:node.start,text:'('+prefix+',('},{at:node.end,text:'))'});};
 visit(ast,n=>{if(n.type!=='FunctionDeclaration')return;const name=decoded(n.id.name);if(!name)return;
  if(pickers.includes(name)){chooserSites.push(name);insertions.push({at:n.body.start+1,text:'$p39UnaryMark('+JSON.stringify(name)+',"choose");'});}
  const text=source.slice(n.body.start,n.body.end);if(!text.includes('/* private unary producer */'))return;
  assert(names.includes(name),'unexpected private unary worker '+name);workers.push(name);
  insertions.push({at:n.body.start+1,text:'$p39UnaryMark('+JSON.stringify(name)+',"entry");'});
  let zero=0,resume=0,returns=0;
  visit(n.body,x=>{
   if(x.type==='VariableDeclarator'&&/^\$u\d+$/.test(x.id?.name)&&x.init)
    wrap(x.init,'$p39UnaryMark('+JSON.stringify(name)+','+JSON.stringify('pre'+x.id.name.slice(2))+')');
   if(x.type==='AssignmentExpression'&&x.left.type==='Identifier'&&x.left.name==='$value'){
    const c=x.right;if(c.type==='CallExpression'&&decoded(c.callee.name)===name.replace('unary.','unary.pick_')){
     ++resume;assert(c.arguments[childIndex[name]].name==='$value','child result occupies original argument slot');
     for(let i=childIndex[name]+1;i<c.arguments.length;i++)wrap(c.arguments[i],'$p39UnaryMark('+JSON.stringify(name)+','+JSON.stringify('post'+i)+')');
    }else{++zero;wrap(c,'$p39UnaryMark('+JSON.stringify(name)+',"zero")');}
   }
   if(x.type==='ReturnStatement'&&x.argument?.name==='$value'){++returns;
    insertions.push({at:x.argument.start,text:'$p39UnaryValue('+JSON.stringify(name)+','},{at:x.argument.end,text:')'});}
  });
  assert.equal(zero,1,'one zero branch');assert.equal(resume,1,'one direct private combiner');assert.equal(returns,1,'one final value');
 });
 for(const name of names)assert(workers.includes(name),'actual unary worker missing '+name);
 for(const name of pickers)assert(chooserSites.includes(name),'actual private chooser missing '+name);
 let diagnostic=source;for(const e of insertions.sort((a,b)=>b.at-a.at))diagnostic=diagnostic.slice(0,e.at)+e.text+diagnostic.slice(e.at);
 diagnostic+='\nconst $p39UnaryEvents=[],$p39UnaryValues=Object.create(null);\n'+
  'function $p39UnaryMark(name,phase){$p39UnaryEvents.push(name+":"+phase);}\n'+
  'function $p39UnaryValue(name,value){$p39UnaryValues[name]=value;return value;}\n'+
  'export function unaryState(){return {events:$p39UnaryEvents.slice(),active:regionProof!==null};}\n'+
  'export function unaryValue(name){return $p39UnaryValues[name];}\n';
 parse(diagnostic);const diagnosticFile=path.join(out,'candidate-diagnostic.mjs');fs.writeFileSync(diagnosticFile,diagnostic,{flag:'wx'});
 const baselineFile=path.join(out,'baseline-diagnostic.mjs');fs.writeFileSync(baselineFile,fs.readFileSync(files.baseline,'utf8')+
  '\nexport function unaryState(){return {events:[],active:regionProof!==null};}\n',{flag:'wx'});
 report.diagnostic={parent:identity(files.candidate),output:identity(diagnosticFile),baseline:identity(baselineFile),workers,chooserSites,insertions,
  scope:'Counters/phase witnesses and returned-value capture only; no alternate work, new proof scope or private-entry bypass.'};
 modules.baseline=await import(pathToFileURL(baselineFile));modules.candidate=await import(pathToFileURL(diagnosticFile));modules.typescript=await import(pathToFileURL(files.typescript));
 const call=(m,name,args)=>(m.default??m)[name](...args),candidate=modules.candidate;
 const checkTree=(name,n,seed,before=0n,leaf=null,after=0n)=>{let t=candidate.unaryValue(name);assert(t,'captured actual private value');let aliases=0;
  for(let i=0;i<n;i++){assert.equal(t.$,'Step');assert.equal(t.a.length,2);const [left,right]=t.a;
   assert.equal(left.$,'Stamp');assert.equal(right.$,'Stamp');assert.equal(left.a.length,2);assert.equal(right.a.length,2);
   const stamp=(seed+i)>>>0;assert.equal(left.a[0],(stamp+Number(before&0xffffffffn))>>>0);
   assert.equal(right.a[0],name==='unary.middle'?Number(after&0xffffffffn):(stamp^7)>>>0);
   assert.equal(left.a[1],right.a[1],'shared recursive subtree survives');++aliases;t=left.a[1];}
  assert.equal(t.$,'Start');assert.deepEqual(t.a,[((seed+n)+(leaf===null?0:Number((leaf+1n)&0xffffffffn)))>>>0]);
  return {name,n,seed,aliases,distinctNodes:3*n+1,leaf:t.a[0]};};
 const oracle=(name,args,expected)=>{const values=Object.values(modules).map(m=>call(m,name,args));report.current={name,args:normalize(args),expected,values:normalize(values)};
  for(const value of values)assert.equal(value,expected);report.oracles.push(report.current);delete report.current;};
 for(const n of [0,1,2,3,7,31])for(const seed of [0,17,4294967295]){
  for(const kind of ['first','last']){oracle(kind+'_check',[n,seed],(seed+n)>>>0);report.structures.push(checkTree('unary.'+kind,n,seed));}
  oracle('middle_check',[n,2n,3n,4n,seed],(seed+n+4)>>>0);report.structures.push(checkTree('unary.middle',n,seed,2n,3n,5n));
 }
 for(const n of [0,1,2,4])for(const seed of [0,17])oracle('two_check',[n,seed],seed);
 for(const name of names){const events=candidate.unaryState().events;assert(events.includes(name+':entry'));assert(events.includes(name.replace('unary.','unary.pick_')+':choose'));
  report.admission.push({name,workerEntries:events.filter(x=>x===name+':entry').length,chooserEntries:events.filter(x=>x===name.replace('unary.','unary.pick_')+':choose').length});}
 const bends=[modules.baseline,candidate],ordinary=m=>call(m,'middle_check',[3,2n,3n,4n,17]);
 const observe=(m,action)=>{const restore=snapshot(m),events=[],before=m.unaryState();let value,error;
  try{value=action(m,events);}catch(e){error={name:e?.name??typeof e,message:e?.message??String(e)};}finally{restore();}
  const after=m.unaryState();assert.equal(after.active,false,'proof leaked');return {value:normalize(value),error,events:normalize(events),privateEvents:after.events.slice(before.events.length)};};
 const boundary=(name,action,live=false)=>{const rows=bends.map(m=>observe(m,action));report.current={name,rows};
  const comparable=x=>({value:x.value,error:x.error,events:x.events});assert.deepEqual(comparable(rows[1]),comparable(rows[0]),name);
  if(live)for(const r of rows)assert(r.events.length>0,'inactive hook '+name);report.boundaries.push(report.current);delete report.current;return rows;};
 for(const name of ['middle_check','unary.middle','unary.pick_middle','unary.bump','trail.head'])for(const mode of ['code','getter','binding'])boundary(name+':'+mode,(m,e)=>{
  const f=m.G[name],code=f.code;if(mode==='code')f.code=function(a){e.push(name);return Reflect.apply(code,this,[a]);};
  if(mode==='getter')Object.defineProperty(f,'code',{configurable:true,get(){e.push('code:'+name);return code;}});
  if(mode==='binding')Object.defineProperty(m.G,name,{configurable:true,get(){e.push('G:'+name);return f;}});return ordinary(m);
 },true);
 const MAX=281474976710655n;
 for(const [label,b,l,a,want]of [['pre',MAX,MAX,MAX,['entry','pre0']],['child',0n,MAX,MAX,['entry','pre0','pre0','zero']],
  ['post',0n,0n,MAX,['entry','pre0','pre0','zero','post2']]]){
  const rows=boundary('error-order:'+label,m=>call(m,'middle_check',[2,b,l,a,17]));for(const r of rows)assert(r.error,'expected overflow');
  const actual=rows[1].privateEvents.filter(x=>x.startsWith('unary.middle:')).map(x=>x.slice('unary.middle:'.length));
  assert.deepEqual(actual,want,'actual emitted argument phases '+label);report.order.push({label,actual,expected:want});
 }
 for(const label of ['pre','child','post'])boundary('Error-reentry:'+label,(m,e)=>{const OldError=Error;let entered=false;
  return hook(globalThis,'Error',{value:function(message){e.push(['Error',message,'proof',m.unaryState().active]);assert.equal(m.unaryState().active,false);
   if(!entered){entered=true;e.push(['nested',m.default.first_check(2,7)]);}return new OldError(message);}},()=>m.default.middle_check(2,label==='pre'?MAX:0n,label==='child'?MAX:0n,label==='post'?MAX:0n,17));
 },true);
 const force=(m,x)=>m.call({arity:0,code:()=>x,env:null,bound:[]},[]);
 for(const mode of ['raw','forged','construct','partial','extra','slot0','slot1','slot-throw','slot-reentry','slot-mutation'])boundary('entry:'+mode,(m,e)=>{
  const f=m.G.first_check,code=f.code;if(mode==='partial')return m.call(m.call(f,[3]),[17]);if(mode==='extra')return m.call(f,[3,17,0]);
  const args={length:2,0:3,1:17},slot=mode==='slot1'?'1':'0';Object.defineProperty(args,slot,{get(){e.push('slot:'+slot);
   if(mode==='slot-throw')throw Error('slot sentinel');if(mode==='slot-reentry')e.push(['nested',m.default.first_check(1,7)]);
   if(mode==='slot-mutation'){const old=m.G['unary.first'].code;m.G['unary.first'].code=function(a){e.push('changed-first');return Reflect.apply(old,this,[a]);};}
   return slot==='0'?3:17;}});
  if(mode==='raw'||mode==='forged')return force(m,Reflect.apply(code,null,[args,mode==='forged']));if(mode==='construct')return force(m,Reflect.construct(code,[args]));
  return m.call(f,{slice(){e.push('slice');return args;}});
 });
 // No baseline deep run: this checks actual explicit frames and every distinct
 // generated node/alias, rather than requiring old non-tail JS to handle depth.
 for(const kind of ['first','last']){assert.equal(candidate.default[kind+'_check'](30000,17),30017);
  report.structures.push({...checkTree('unary.'+kind,30000,17),kind:'deep-actual-worker'});}
 assert.equal(candidate.unaryState().active,false);
 for(const row of report.inputs)assert.deepEqual(identity(row.path),row);report.complete=report.pass=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,structures:report.structures.length,
 admission:report.admission.length,boundaries:report.boundaries.length,order:report.order.length,error:report.error}));
