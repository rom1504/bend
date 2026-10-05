// Independent, untimed array lifetime/observation controls. No source rewriting.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseline,candidate,output]=process.argv.slice(2);
assert(output,'array-view-controls-v4.mjs BASELINE_MODULE CANDIDATE_MODULE NEW_OUT');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase48-independent-array-view-controls-v4',complete:false,pass:false,inputs:[],modules:[],oracles:[],boundaries:[],
  scope:'Exact predecessor/candidate observations and untimed raw-entry/refusal witness. Two explicit historical guard observations use both ungranted ordinary executions: candidate public matches source; old public retains exactly two extra Number reads or the recorded self-restoring reflection mutation trace. No timing claim.'};
const pinned=new Map(),apply=Reflect.apply,define=Object.defineProperty,descriptor=Object.getOwnPropertyDescriptor;
const OriginalNumber=Number,OriginalArray=Array,OriginalError=Error;
const identity=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {path:file,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};};
function pin(file,want){const x=identity(file);if(want){assert.equal(x.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(x.bytes,want.bytes);}
  if(pinned.has(x.path))assert.deepEqual(x,pinned.get(x.path));else{pinned.set(x.path,x);report.inputs.push(x);}return x;}
function audit(v){if(OriginalArray.isArray(v))v.forEach(audit);else if(v&&typeof v==='object'){
  const file=v.path??v.file??v.canonicalPath;if(typeof file==='string'&&v.sha256)pin(file,v);Object.values(v).forEach(audit);}}
function expected(n,seed){const cells=[seed,seed,seed,seed];let acc=0;for(let i=0;i<n;i++){acc=(acc+cells[i%4]+1)>>>0;cells[i%4]=(acc^i)>>>0;}return {cells,acc};}
const thrown=e=>({type:typeof e,name:e?.name??null,message:e?.message??String(e)});
function scenario(m,label,ordinary=false){
  assert(!ordinary||['Number-getter-closed','reflection-self-restores'].includes(label),'Ordinary oracle is limited to the two documented historical guard boundaries');
  const events=[],restores=[],storage=[2,3,5,7];let a={array:storage},value,error,escaped,reflection;
  const log=event=>define(events,String(events.length),{configurable:true,enumerable:true,writable:true,value:event});
  const patch=(owner,key,desc)=>{const old=descriptor(owner,key);restores.push(()=>old?define(owner,key,old):delete owner[key]);define(owner,key,{configurable:true,...desc});};
  const run=(n=5)=>m.default.external(BigInt(n),a);
  const wrapNumber=(throws=false)=>{const wrapped=function(v){log(['Number',typeof v,String(v)]);if(throws)throw new OriginalError('conversion sentinel');return OriginalNumber(v);};
    // Preserve numeric static helpers so a global replacement isolates conversion.
    Object.setPrototypeOf(wrapped,OriginalNumber);patch(globalThis,'Number',{writable:true,value:wrapped});};
  try{
    if(label==='zero-malformed'){a={get array(){log('array');throw new OriginalError('zero demand');}};value=run(0);assert.equal(value,0);assert.deepEqual(events,[]);}
    else if(label==='unused-read-error'){a={get array(){log('array');throw new OriginalError('unused read');}};value=m.default.ignored_read(a);}
    else if(label==='handle-getter'){a={get array(){log('array');return storage;}};value=run();}
    else if(label==='backing-proxy'){a={array:new Proxy(storage,{get(t,k,r){log(['get',String(k)]);return Reflect.get(t,k,r);},set(t,k,v,r){log(['set',String(k),v]);return Reflect.set(t,k,v,r);}})};value=run();}
    else if(label==='changing-backing'){let reads=0;const other=[11,13];a={get array(){log(['array',++reads]);return reads<5?storage:other;}};value=run();escaped=other.slice();}
    else if(label==='malformed'){a={};value=run(1);}
    else if(label==='empty'){a={array:[]};value=run(2);escaped={length:a.array.length,nan:a.array.NaN};}
    else if(label==='aliases'||label==='distinct'){const other=label==='aliases'?storage:[11,13,17,19];value=m.default.aliases(a,{array:other});assert.equal(value,label==='aliases'?19:2);escaped=other.slice();}
    else if(label==='returned-storage'){const pair=m.default.escaped(9,3),want=expected(9,3);assert.deepEqual(pair[0].array,want.cells);assert.equal(pair[1],want.acc);
      pair[0].array[0]=41;value=m.default.external(1n,pair[0]);assert.equal(value,42);escaped=pair[0].array.slice();}
    else if(label.startsWith('Number-')){const root=label.endsWith('-public')?()=>run(3):()=>ordinary?m.call(m.G.bench.code.call(m.G.bench.env,[3,2]),[]):m.default.bench(3,2);
      if(label.includes('getter'))patch(globalThis,'Number',{get(){log('Number:get');return OriginalNumber;}});else wrapNumber(label.includes('throw'));value=root();}
    else if(label.startsWith('fill-')){
      const fill=OriginalArray.prototype.fill;let busy=false;
      patch(OriginalArray.prototype,'fill',{writable:true,value:function(...args){
        log('fill');if(label==='fill-throw')throw new OriginalError('fill sentinel');
        const filled=apply(fill,this,args);escaped=filled;
        if(label==='fill-reentry'&&!busy){busy=true;log(['nested',m.default.bench(0,5)]);busy=false;}
        if(label==='fill-replaces-Number'||label==='fill-late-resize'){
          let count=0;const wrapped=function(v){log(['late-Number',typeof v,String(v)]);count++;if(label==='fill-late-resize')filled.length=count%2===0?2:4;else if(count===1)filled.length=2;return OriginalNumber(v);};
          Object.setPrototypeOf(wrapped,OriginalNumber);patch(globalThis,'Number',{writable:true,value:wrapped});
        }
        return label==='fill-proxy'?new Proxy(filled,{get(t,k,r){log(['get',String(k)]);return Reflect.get(t,k,r);},set(t,k,v,r){log(['set',String(k),v]);return Reflect.set(t,k,v,r);}}):filled;
      }});value=m.default.bench(label==='fill-zero'?0:5,2);
    }
    else if(label==='Array-wrapper'||label==='Array-getter'){
      if(label==='Array-getter')patch(globalThis,'Array',{get(){log('Array:get');return OriginalArray;}});
      else{const wrapped=function(...args){log('Array:call');return apply(OriginalArray,this,args);};Object.setPrototypeOf(wrapped,OriginalArray);patch(globalThis,'Array',{writable:true,value:wrapped});}
      value=m.default.bench(5,2);
    }
    else if(label==='Array-numeric-setter'||label==='Object-numeric-setter'){
      const owner=label==='Array-numeric-setter'?OriginalArray.prototype:Object.prototype;
      patch(owner,'3',{set(v){log([label,typeof v]);define(this,'3',{configurable:true,enumerable:true,writable:true,value:v});}});
      value=m.default.bench(5,2);
    }
    else if(label==='reflection-self-restores'){
      const original=descriptor(Object,'getOwnPropertyDescriptor'),cell=m.G['seam.cell'],code=cell.code,bound=cell.bound;let seen=false,mutated=false;
      patch(Object,'getOwnPropertyDescriptor',{writable:true,value:function(owner,key){const result=apply(original.value,this,[owner,key]);
        if(owner===m.G&&key==='seam.cell')seen=true;
        else if(seen&&!mutated&&owner===bound&&key==='length'){mutated=true;log('reflection:mutate');
          patch(cell,'code',{writable:true,value:function(args){log('replacement:cell');return apply(code,this,[args]);}});
          define(Object,'getOwnPropertyDescriptor',original);
        }return result;}});
      const invoke=()=>ordinary?m.call(m.G.bench.code.call(m.G.bench.env,[5,2]),[]):m.default.bench(5,2);
      const first=invoke(),second=invoke();value=[first,second];reflection={seen,mutated};
    }
    else if(label.startsWith('safe-integer')){const safe=OriginalNumber.isSafeInteger;let busy=false;
      patch(OriginalNumber,'isSafeInteger',{writable:true,value:function(v){log('safe-integer');
        if(label==='safe-integer-throw')throw new OriginalError('safe integer sentinel');
        if(label==='safe-integer-reentry'&&!busy){busy=true;log(['nested',m.default.bench(0,5)]);busy=false;}return safe(v);}});value=m.default.bench(3,2);}
    else if(label.startsWith('opaque-')){
      if(label==='opaque-throw')a={get array(){log('array-before-callback');return storage;}};
      const callback={arity:1,env:null,bound:[],code:function(args){log(['callback',args[0]]);
        if(label==='opaque-throw')throw new OriginalError('callback sentinel');
        if(label==='opaque-resize')storage.length=2;else a.array=[11,13];return 10;}};
      value=m.default.opaque(a,5,callback);assert.equal(value,label==='opaque-resize'?14:24);escaped=a.array.slice();
    }
    else if(label.startsWith('native-')||label==='source-cell'){
      const name=label==='source-cell'?'seam.cell':label.includes('-set')?'Array.set':'Array.get',f=m.G[name];assert(f,'Missing '+name);
      const code=f.code;
      if(label==='native-get-global')patch(m.G,name,{get(){log(name+':global');return f;}});
      else if(label==='native-get-call')patch(code,'call',{writable:true,value:function(env,args){log(name+':call');return apply(code,env,[args]);}});
      else if(label==='native-get-code-getter')patch(f,'code',{get(){log(name+':code-get');return code;}});
      else patch(f,'code',{writable:true,value:function(args){log(name+':code');if(label==='native-get-throw')throw new OriginalError('read sentinel');return apply(code,this,[args]);}});
      value=m.default.bench(5,2);
    }else throw new OriginalError('Unknown control '+label);
  }catch(e){error=thrown(e);}
  finally{for(let i=restores.length-1;i>=0;i--)restores[i]();}
  // Snapshot after restoring hooks; no controller reads inflate hook events.
  const result={value,error,events,storage:storage.slice(),escaped:OriginalArray.isArray(escaped)?escaped.slice():escaped};
  if(['unused-read-error','malformed','Number-throw-public','fill-throw','opaque-throw','native-get-throw','safe-integer-throw'].includes(label))assert(error,label+' must throw');
  else assert.equal(error,undefined,label+' unexpected error');
  if(label==='opaque-throw')assert.deepEqual(events,[['callback',5]],'Callback must throw before storage demand');
  if(label==='reflection-self-restores')result.reflection=reflection;
  if(!['zero-malformed','malformed','empty','aliases','distinct','returned-storage','reflection-self-restores'].includes(label))assert(events.length,label+' must witness observation');
  return result;
}
try{
  pin(import.meta.filename);pin(process.execPath);fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
  report.predecessor=pin(path.join(import.meta.dirname,'array-view-controls-v3.mjs'),{sha256:'560da0cb89196d0ecfc25d2df482ceab74139e0f7b19467264ed1d68c9bd868d'});
  const historical=path.resolve(import.meta.dirname,'../../phase47/controls');
  report.parent=pin(path.join(historical,'array-view-controls-v2.mjs'),{sha256:'ff357041631f7e4d1ae3d92e69f43ef348938f06c8d052449b206f626681a485'});
  const catalogId=pin(path.join(historical,'array-view-catalog-v1.json')),catalog=JSON.parse(fs.readFileSync(catalogId.path,'utf8'));
  assert.equal(catalog.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
  const source=pin(path.join(historical,catalog.cases[0].source.path),catalog.cases[0].source),modules=[],texts=[];
  for(const [i,file]of [baseline,candidate].entries()){
    const module=pin(file),receipt=pin(module.path+'.json'),r=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(r.kind,'bend-program-checked-emission');assert.equal(r.complete,true);assert.equal(r.observation.checked,true);assert.equal(r.observation.status,'ok');
    assert.equal(r.output.sha256,module.sha256);assert.equal(r.input.sha256,source.sha256);assert.equal(r.catalog.sha256,catalogId.sha256);
    assert.equal(r.compiler.upstreamCommit,catalog.upstreamCommit);assert(['checked-development-attempt','installed-checked-release'].includes(r.compiler.kind));audit(r);
    report.modules.push({role:i?'candidate':'baseline',module,receipt,compiler:r.compiler});texts.push(fs.readFileSync(module.path,'utf8'));modules.push(await import(pathToFileURL(module.path)));
  }
  for(const n of [0,1,4,5,9,33])for(const seed of [0,1,17,4294967295]){const want=expected(n,seed).acc,values=modules.map(m=>m.default.bench(n,seed));
    for(const value of values)assert.equal(value,want);report.oracles.push({n,seed,expected:want,values});}
  const cases=['zero-malformed','unused-read-error','handle-getter','backing-proxy','changing-backing','malformed','empty','aliases','distinct','returned-storage',
    'Number-wrapper-public','Number-wrapper-closed','Number-getter-public','Number-getter-closed','Number-throw-public',
    'fill-zero','fill-proxy','fill-throw','fill-reentry','fill-replaces-Number','fill-late-resize','Array-wrapper','Array-getter','Array-numeric-setter','Object-numeric-setter','reflection-self-restores','safe-integer','safe-integer-throw','safe-integer-reentry',
    'opaque-resize','opaque-replace','opaque-throw','native-get-global','native-get-call','native-get-code-getter','native-get-code','native-get-throw','native-set-code','source-cell'];
  for(const name of cases){const observations=modules.map(m=>scenario(m,name));
    if(name==='Number-getter-closed'){
      const ordinary=modules.map(m=>scenario(m,name,true));
      assert.deepEqual(ordinary[1],ordinary[0],name+' ordinary source agreement');
      assert.deepEqual(observations[1],ordinary[0],name+' candidate public must match ordinary source');
      assert.equal(ordinary[0].value,expected(3,2).acc);assert.equal(ordinary[0].error,undefined);
      assert(ordinary[0].events.length>0);assert(ordinary[0].events.every(e=>e==='Number:get'));
      assert.deepEqual(observations[0],{...ordinary[0],events:['Number:get','Number:get',...ordinary[0].events]},name+' historical public guard adds exactly two leading reads');
      report.boundaries.push({name,observations,ordinary,oracle:'Equal baseline/candidate ungranted code execution; candidate public agrees. Historical baseline public has exactly two additional leading Number:get observations.'});
    }else if(name==='reflection-self-restores'){
      const ordinary=modules.map(m=>scenario(m,name,true));
      assert.deepEqual(ordinary[1],ordinary[0],name+' ordinary source agreement');
      assert.deepEqual(observations[1],ordinary[0],name+' candidate public must match ordinary source');
      assert.deepEqual(ordinary[0].value,[expected(5,2).acc,expected(5,2).acc]);assert.equal(ordinary[0].error,undefined);
      assert.deepEqual(ordinary[0].events,[]);assert.deepEqual(ordinary[0].reflection,{seen:false,mutated:false});
      const historicalEvents=['reflection:mutate','replacement:cell','replacement:cell','replacement:cell','replacement:cell','replacement:cell'];
      assert.deepEqual(observations[0],{...ordinary[0],events:historicalEvents,reflection:{seen:true,mutated:true}},name+' historical public mutation trace is retained exactly');
      report.boundaries.push({name,observations,ordinary,oracle:'Both ungranted ordinary executions and candidate public preserve values with zero reflection reads or mutations. Historical baseline public retains the exact self-restoring mutation plus five replacement-helper observations.'});
    }else{assert.deepEqual(observations[1],observations[0],name);report.boundaries.push({name,observations});}}
  report.correctnessPass=true;
  const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};
  new Function('module','exports',parserSource)(parserModule,parserModule.exports);
  const parse=text=>parserModule.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});
  const nodes=[],todo=[parse(texts[1])];while(todo.length){const n=todo.pop();if(!n||typeof n!=='object'||typeof n.type!=='string')continue;nodes.push(n);
    for(const x of Object.values(n))if(Array.isArray(x))todo.push(...x);else if(x&&typeof x==='object')todo.push(x);}
  const assignments=nodes.filter(n=>n.type==='AssignmentExpression'&&n.left.type==='MemberExpression'&&n.left.object.type==='Identifier'&&n.left.object.name==='G'&&n.left.computed&&n.left.property.type==='Literal');
  const marker='/* private raw array root */',roots=name=>assignments.filter(n=>n.left.property.value===name);
  report.activation={status:'pending',publicRefusals:[],entries:[],hookRefusals:[]};
  for(const name of ['external','escaped','opaque']){const rows=roots(name);assert(rows.length,'Missing public root '+name);
    assert(rows.every(n=>!texts[1].slice(n.right.start,n.right.end).includes(marker)),name+' must not acquire private raw storage');report.activation.publicRefusals.push(name);}
  const bench=roots('bench').filter(n=>texts[1].slice(n.right.start,n.right.end).includes(marker));
  if(bench.length!==1)report.activation.status='refused';assert.equal(bench.length,1,'Closed independent bench did not select raw array branch');
  const row=bench[0],body=texts[1].slice(row.right.start,row.right.end);assert.equal(body.split(marker).length-1,1);
  assert(!texts[1].includes('$p47RawEntries'));const at=row.right.start+body.indexOf(marker)+marker.length;
  const derived='let $p47RawEntries=0;\n'+texts[1].slice(0,at)+'$p47RawEntries++;'+texts[1].slice(at)+'\nexport const phase47RawEntries=()=>$p47RawEntries;\n';parse(derived);
  const file=path.join(out,'candidate-entry-counter.mjs');fs.writeFileSync(file,derived,{flag:'wx'});
  report.derivative={module:identity(file),parent:report.modules[1].module,root:'bench',insertion:at,
    parser:{version:parserModule.exports.version,sha256:createHash('sha256').update(parserSource).digest('hex')},performanceEvidence:false};
  const witness=await import(pathToFileURL(file));
  for(const n of [0,1,5,9]){const before=witness.phase47RawEntries(),value=witness.default.bench(n,3),entries=witness.phase47RawEntries()-before;
    assert.equal(value,expected(n,3).acc);if(entries!==1)report.activation.status='refused';assert.equal(entries,1,'Fresh private root must enter once');report.activation.entries.push({n,entries});}
  for(const name of cases){const before=witness.phase47RawEntries(),observation=scenario(witness,name),entries=witness.phase47RawEntries()-before;
    assert.deepEqual(observation,report.boundaries.find(x=>x.name===name).observations[1],name+' diagnostic observation');assert.equal(entries,0,name+' must refuse raw bench entry');report.activation.hookRefusals.push({name,entries});}
  assert.deepEqual(identity(file),report.derivative.module);report.activation.status='pass';
  for(const x of pinned.values())assert.deepEqual(identity(x.path),x);
  report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,(_k,v)=>typeof v==='bigint'?{$bigint:String(v)}:v,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,boundaries:report.boundaries.length,error:report.error}));
