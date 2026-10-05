// Untimed, independently specified multi-array state and write-order controls.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseline,candidate,output]=process.argv.slice(2);
assert(output,'array-layout-controls-v3.mjs BASELINE_MODULE CANDIDATE_MODULE NEW_OUT');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase47-independent-array-layout-controls-v3',complete:false,pass:false,inputs:[],modules:[],oracles:[],publicStates:[],boundaries:[],
  scope:'Untimed checked selfhost differential controls with independent complete-state oracles and a separate diagnostic entry witness. Existing array-view-controls-v2 remains the host-lifetime suite.'};
const pinned=new Map(),apply=Reflect.apply,define=Object.defineProperty,descriptor=Object.getOwnPropertyDescriptor;
const OriginalNumber=Number,OriginalError=Error;
const identity=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {path:file,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};};
function pin(file,want){const x=identity(file);if(want){assert.equal(x.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(x.bytes,want.bytes);}
  if(pinned.has(x.path))assert.deepEqual(x,pinned.get(x.path));else{pinned.set(x.path,x);report.inputs.push(x);}return x;}
function audit(v){if(Array.isArray(v))v.forEach(audit);else if(v&&typeof v==='object'){
  const file=v.path??v.file??v.canonicalPath;if(typeof file==='string'&&v.sha256)pin(file,v);Object.values(v).forEach(audit);}}
const wrap=x=>x>>>0;
function fresh(k,seed){return {arrays:Array.from({length:k},(_,i)=>Array(4).fill(wrap(seed+i))),total:0};}
// Read both input cells before either write. Keep references, not copied cells,
// so the same specification also covers distinct handles sharing one backing.
function advance(state,n,flag){let {arrays,total}=state;const k=arrays.length;
  for(let i=0;i<n;i++){
    const x=arrays[0][i%arrays[0].length],y=arrays[1][(i+1)%arrays[1].length];
    total=wrap(total+x+y+(k===2?1:3));
    if(k===2){arrays[0][i%arrays[0].length]=wrap(total^i);arrays[1][(i+1)%arrays[1].length]=total;
      if(flag)arrays=[arrays[1],arrays[0]];}
    else{arrays[2][i%arrays[2].length]=total;arrays[3][(i+2)%arrays[3].length]=wrap(total^(i+1));
      arrays=flag?[arrays[3],arrays[0],arrays[1],arrays[2]]:[arrays[1],arrays[2],arrays[3],arrays[0]];}
  }return {arrays,total};
}
const snapshot=state=>({cells:state.arrays.map(a=>a.slice()),total:state.total,
  aliases:state.arrays.map(a=>state.arrays.map(b=>a===b))});
function unpack(value,k){assert.equal(value.$,'C'+k);assert.equal(value.a.length,k+1);
  const arrays=value.a.slice(0,k).map(a=>{assert(a&&Array.isArray(a.array),'Public array handle ABI');return a.array;});
  return {arrays,total:value.a[k]};}
function shared(k,kind){const storage=Array.from({length:k},(_,i)=>[3+i,5+i,7+i,11+i]);
  return {arrays:Array.from({length:k},(_,i)=>storage[kind==='all'?0:kind==='pairs'?Math.floor(i/2):i]),total:0};}
function publicState(m,k,n,flag,kind){const want=shared(k,kind),input=shared(k,kind);
  const value=m.ctor('C'+k,[...input.arrays.map(array=>({array})),0]);
  const result=unpack(m.default['external'+k](BigInt(n),flag,value),k),expected=snapshot(advance(want,n,flag));
  assert.deepEqual(snapshot(result),expected);return expected;}
function returnedState(m,k,n,flag){const want=advance(fresh(k,3),n,flag),value=m.default['returned'+k](n,3,flag);
  const result=unpack(value,k);assert.deepEqual(snapshot(result),snapshot(want));
  // The returned wrapper must remain live public storage; mutation followed by
  // a second public call is checked with the same alias-preserving model.
  result.arrays[0][0]=41;want.arrays[0][0]=41;
  const again=unpack(m.default['external'+k](3n,!flag,value),k),expected=snapshot(advance(want,3,!flag));
  assert.deepEqual(snapshot(again),expected);return expected;}
const writeExpected=x=>(wrap(x+1)%4===0?wrap(x*7):0);
const thrown=e=>({type:typeof e,name:e?.name??null,message:e?.message??String(e)});
function writeScenario(m,label){const events=[],restores=[],sentinel=new OriginalError('ordered write sentinel');let value,error,sameError=false;
  const log=x=>events.push(x),patch=(owner,key,desc)=>{const old=descriptor(owner,key);restores.push(()=>old?define(owner,key,old):delete owner[key]);define(owner,key,{configurable:true,...desc});};
  const number=function(v){log(['Number',typeof v,String(v)]);if(label==='Number-throws'&&typeof v==='number'&&v===4)throw sentinel;return OriginalNumber(v);};
  Object.setPrototypeOf(number,OriginalNumber);
  try{
    patch(globalThis,'Number',{writable:true,value:number});
    for(const [name,tag]of [['ink.index','index'],['ink.value','value'],['Array.set','store']]){
      const f=m.G[name];assert(f,'Missing source/native helper '+name);const code=f.code;
      patch(f,'code',{writable:true,value:function(args){log(tag);if(label===tag+'-throws')throw sentinel;return apply(code,this,[args]);}});
    }
    value=m.default.write_order(3);
  }catch(e){error=thrown(e);sameError=e===sentinel;}
  finally{for(let i=restores.length-1;i>=0;i--)restores[i]();}
  const operations=events.filter(x=>typeof x==='string');
  const expected=label==='index-throws'?['index']:label==='value-throws'?['index','value']:['index','value','store'];
  assert.deepEqual(operations,expected,'Index and value must each evaluate once, in order, before the native write');
  if(label==='ordered'){assert.equal(value,21);assert.equal(error,undefined);}
  else{assert(sameError,'The original ordered sentinel must propagate');assert(error);}
  const conversion=events.findIndex(x=>Array.isArray(x)&&x[0]==='Number'&&x[1]==='number'&&x[2]==='4');
  if(label==='ordered'||label==='Number-throws')assert(conversion>events.indexOf('store'),'Number(index) follows index, value and native entry');
  else assert.equal(conversion,-1,'Earlier throw must suppress index conversion');
  return {value,error,sameError,events};
}
function zeroMalformed(m,k){let demands=0;const handles=Array.from({length:k},()=>({get array(){demands++;throw new OriginalError('zero-trip storage demand');}}));
  const input=m.ctor('C'+k,[...handles,17]),result=m.default['external'+k](0n,true,input);
  assert.equal(result.$,'C'+k);assert.equal(result.a[k],17);for(let i=0;i<k;i++)assert.equal(result.a[i],handles[i]);assert.equal(demands,0);return {demands,total:17};}
try{
  pin(import.meta.filename);pin(process.execPath);fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
  const catalogId=pin(path.join(import.meta.dirname,'array-layout-catalog-v3.json')),catalog=JSON.parse(fs.readFileSync(catalogId.path,'utf8'));
  assert.equal(catalog.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
  const source=pin(path.join(import.meta.dirname,catalog.cases[0].source.path),catalog.cases[0].source),modules=[],texts=[];
  for(const [i,file]of [baseline,candidate].entries()){
    const module=pin(file),receipt=pin(module.path+'.json'),r=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(r.kind,'bend-program-checked-emission');assert.equal(r.complete,true);assert.equal(r.observation.checked,true);assert.equal(r.observation.status,'ok');
    assert.equal(r.output.sha256,module.sha256);assert.equal(r.input.sha256,source.sha256);assert.equal(r.catalog.sha256,catalogId.sha256);
    assert.equal(r.compiler.upstreamCommit,catalog.upstreamCommit);assert(['checked-development-attempt','installed-checked-release'].includes(r.compiler.kind));audit(r);
    report.modules.push({role:i?'candidate':'baseline',module,receipt,compiler:r.compiler});texts.push(fs.readFileSync(module.path,'utf8'));modules.push(await import(pathToFileURL(module.path)));
  }
  assert.equal(advance(fresh(2,3),9,true).total,catalog.cases[0].point.expected,'Independent catalog anchor');
  for(const k of [2,4])for(const n of [0,1,2,5,9,33])for(const seed of [0,3,4294967295])for(const flag of [false,true]){
    const root=k===2?'dual':'four',expected=advance(fresh(k,seed),n,flag).total,values=modules.map(m=>m.default[root](n,seed,flag));
    for(const value of values)assert.equal(value,expected);report.oracles.push({root,n,seed,flag,expected,values});
  }
  for(const x of [0,1,3,7,4294967295]){const expected=writeExpected(x),values=modules.map(m=>m.default.write_order(x));
    for(const value of values)assert.equal(value,expected);report.oracles.push({root:'write_order',x,expected,values});}
  for(const k of [2,4])for(const n of [0,1,5,9])for(const flag of [false,true]){
    const observations=modules.map(m=>returnedState(m,k,n,flag));assert.deepEqual(observations[1],observations[0]);report.publicStates.push({kind:'returned-and-mutated',k,n,flag,observations});
    for(const kind of k===2?['distinct','all']:['distinct','pairs','all']){
      const observations=modules.map(m=>publicState(m,k,n,flag,kind));assert.deepEqual(observations[1],observations[0]);report.publicStates.push({kind,k,n,flag,observations});}
  }
  for(const k of [2,4]){const observations=modules.map(m=>zeroMalformed(m,k));assert.deepEqual(observations[1],observations[0]);report.boundaries.push({name:'zero-malformed-'+k,observations});}
  const writeCases=['ordered','index-throws','value-throws','store-throws','Number-throws'];
  for(const name of writeCases){const observations=modules.map(m=>writeScenario(m,name));assert.deepEqual(observations[1],observations[0],name);report.boundaries.push({name,observations});}
  report.correctnessPass=true;
  const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};
  new Function('module','exports',parserSource)(parserModule,parserModule.exports);
  const parse=text=>parserModule.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'}),nodes=[],todo=[parse(texts[1])];
  while(todo.length){const n=todo.pop();if(!n||typeof n!=='object'||typeof n.type!=='string')continue;nodes.push(n);
    for(const x of Object.values(n))if(Array.isArray(x))todo.push(...x);else if(x&&typeof x==='object')todo.push(x);}
  const assignments=nodes.filter(n=>n.type==='AssignmentExpression'&&n.left.type==='MemberExpression'&&n.left.object.type==='Identifier'&&n.left.object.name==='G'&&n.left.computed&&n.left.property.type==='Literal');
  const marker='/* private raw array root */',roots=name=>assignments.filter(n=>n.left.property.value===name),insertions=[];
  report.activation={status:'pending',publicRefusals:[],entries:[],hookRefusals:[],statementWrite:false};
  for(const name of ['external2','external4','returned2','returned4']){const rows=roots(name);assert(rows.length,'Missing public root '+name);
    assert(rows.every(n=>!texts[1].slice(n.right.start,n.right.end).includes(marker)),name+' must not acquire private raw storage');report.activation.publicRefusals.push(name);}
  const closed=['dual','four','write_order'];
  for(const [index,name]of closed.entries()){
    const rows=roots(name).filter(n=>texts[1].slice(n.right.start,n.right.end).includes(marker));
    if(rows.length!==1)report.activation.status='refused';assert.equal(rows.length,1,'Independent '+name+' did not select raw array branch');
    const row=rows[0],body=texts[1].slice(row.right.start,row.right.end);assert.equal(body.split(marker).length-1,1);
    insertions.push({at:row.right.start+body.indexOf(marker)+marker.length,text:'$p47LayoutEntries['+index+']++;',root:name});
    if(name==='write_order'){
      // Reserved statement temporaries witness the intended printer path; the
      // entry counter remains separate because printed code can be unreachable.
      assert(body.includes('const $arraySet0=null;'),'Write-order root did not contain statement-form Array.set');
      assert(body.includes('$arraySet1[Number($arraySet2)%$arraySet1.length]=$arraySet3;'),'Statement write must retain conversion before length');
      report.activation.statementWrite=true;
    }
  }
  assert(!texts[1].includes('$p47LayoutEntries'));let derived=texts[1];
  for(const x of [...insertions].sort((a,b)=>b.at-a.at))derived=derived.slice(0,x.at)+x.text+derived.slice(x.at);
  derived='const $p47LayoutEntries=[0,0,0];\n'+derived+'\nexport const phase47LayoutEntries=()=>$p47LayoutEntries.slice();\n';parse(derived);
  const file=path.join(out,'candidate-entry-counter.mjs');fs.writeFileSync(file,derived,{flag:'wx'});
  report.derivative={module:identity(file),parent:report.modules[1].module,insertions,
    parser:{version:parserModule.exports.version,sha256:createHash('sha256').update(parserSource).digest('hex')},performanceEvidence:false};
  const witness=await import(pathToFileURL(file)),delta=before=>witness.phase47LayoutEntries().map((v,i)=>v-before[i]);
  for(const [index,k]of [2,4].entries())for(const n of [0,1,9])for(const flag of [false,true]){
    const before=witness.phase47LayoutEntries(),value=witness.default[closed[index]](n,3,flag),entries=delta(before);
    assert.equal(value,advance(fresh(k,3),n,flag).total);assert.deepEqual(entries,index===0?[1,0,0]:[0,1,0]);report.activation.entries.push({root:closed[index],n,flag,entries});}
  for(const x of [0,3,7]){const before=witness.phase47LayoutEntries(),value=witness.default.write_order(x),entries=delta(before);
    assert.equal(value,writeExpected(x));assert.deepEqual(entries,[0,0,1]);report.activation.entries.push({root:'write_order',x,entries});}
  for(const name of writeCases){const before=witness.phase47LayoutEntries(),observation=writeScenario(witness,name),entries=delta(before);
    assert.deepEqual(observation,report.boundaries.find(x=>x.name===name).observations[1]);assert.deepEqual(entries,[0,0,0]);report.activation.hookRefusals.push({name,entries});}
  for(const k of [2,4]){const before=witness.phase47LayoutEntries();returnedState(witness,k,5,true);publicState(witness,k,5,false,'all');zeroMalformed(witness,k);
    const entries=delta(before);assert.deepEqual(entries,[0,0,0]);report.activation.hookRefusals.push({name:'public-record-'+k,entries});}
  assert.deepEqual(identity(file),report.derivative.module);report.activation.status='pass';
  for(const x of pinned.values())assert.deepEqual(identity(x.path),x);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,(_k,v)=>typeof v==='bigint'?{$bigint:String(v)}:v,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,publicStates:report.publicStates.length,boundaries:report.boundaries.length,activation:report.activation?.status,error:report.error}));
