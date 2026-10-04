// Independent iterative mathematics and diagnostic worker counters; never timed.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [baseline,candidate,typescript,output,mode,deepRoot]=process.argv.slice(2);
const roots=['bench','tail_check','tree_check','scope_check','sibling_check'];
assert(output&&(!mode||(mode==='--deep'&&roots.includes(deepRoot))),
  'worker-composition-controls-v5.mjs BASELINE_MODULE CANDIDATE_MODULE TS_MODULE NEW_OUT [--deep ROOT]');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase45-worker-composition-controls',controllerVersion:5,complete:false,pass:false,
  scope:'Independent unsafe source fixture. Small checked predecessor/candidate/TypeScript agreement; deep runs select candidate only. Counters are untimed derivatives.',
  mode:mode?{deepRoot}:'small',inputs:[],modules:[],oracles:[],trees:[],activation:[],boundaries:[],unwinding:[]};
const identity=p=>{const file=fs.realpathSync(p),bytes=fs.readFileSync(file);
  return {path:file,sha256:createHash('sha256').update(bytes).digest('hex'),bytes:bytes.length};};
const pinned=new Map();
function pin(file,expected){const row=identity(file);if(expected){assert.equal(row.sha256,expected.sha256);if(expected.bytes!==undefined)assert.equal(row.bytes,expected.bytes);}
  if(pinned.has(row.path))assert.deepEqual(row,pinned.get(row.path));else{pinned.set(row.path,row);report.inputs.push(row);}return row;}
function audit(x){if(Array.isArray(x))x.forEach(audit);else if(x&&typeof x==='object'){
  const file=x.file??x.path;if(file&&x.sha256)pin(file,x);Object.values(x).forEach(audit);}}
const mask=0xffffffffn,word=n=>Number(n&mask);
function arithmetic(n,seed,side=0){const saved=[];let s=BigInt(seed);
  for(let i=0;i<n;i++){saved.push([side,s]);s=(s+BigInt(side===0?3:5))&mask;side^=1;}
  let value=(s+BigInt(side===0?0:13))&mask;
  for(let i=saved.length-1;i>=0;i--){const [which,prior]=saved[i];value=(which===0?value*3n-prior:value+prior*7n)&mask;}
  return Number(value);}
function ribbon(n,seed){const marks=[];let s=BigInt(seed),sum=0n;
  for(let i=0;i<n;i++){const mark=(i%2===0?s+1n:s^85n)&mask;marks.push(Number(mark));sum=(sum+mark)&mask;s=(s+BigInt(i%2===0?3:5))&mask;}
  const end=(s+BigInt(n%2===0?0:11))&mask;return {marks,end:Number(end),sum:word(sum+end)};}
function oracle(name,n,seed){if(name==='bench')return arithmetic(n,seed);
  if(name==='tail_check')return word(BigInt(seed)+4n*BigInt(n)+BigInt(n%2===0?0:12));
  if(name==='tree_check')return ribbon(n,seed).sum;
  if(name==='scope_check')return word(BigInt(arithmetic(n,word(BigInt(seed)+2n)))-15n);
  return word(BigInt(arithmetic(n,seed))-BigInt(arithmetic(n,word(BigInt(seed)+1n),1)));}
function readRibbon(node,limit){const marks=[];while(node?.$==='RibbonMark'){
  assert(marks.length<limit,'Unexpected/cyclic Ribbon');const values=node.a??[node.value,node.rest];assert.equal(values.length,2);
  marks.push(values[0]);node=values[1];}assert.equal(node?.$,'RibbonEnd');
  const fields=node.a??[node.value];assert.equal(fields.length,1);return {marks,end:fields[0]};}
try{
  pin(import.meta.filename);pin(process.execPath);
  const catalogFile=path.join(import.meta.dirname,'worker-composition-catalog.json'),catalogId=pin(catalogFile);
  const catalog=JSON.parse(fs.readFileSync(catalogFile,'utf8'));
  const source=pin(path.join(import.meta.dirname,catalog.cases[0].source.path),catalog.cases[0].source);
  const modules=[],texts=[];
  for(const [i,file] of [baseline,candidate,typescript].entries()){
    const module=pin(file),receipt=pin(module.path+'.json'),emission=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(emission.kind,'bend-program-checked-emission');assert.equal(emission.complete,true);
    assert.equal(emission.observation.checked,true);assert.equal(emission.observation.status,'ok');
    assert.equal(emission.input.sha256,source.sha256);assert.equal(emission.output.sha256,module.sha256);
    assert.equal(emission.catalog.sha256,catalogId.sha256);assert.equal(emission.compiler.upstreamCommit,catalog.upstreamCommit);
    assert.equal(emission.compiler.kind,i===2?'checked-pinned-typescript':'checked-development-attempt');audit(emission);
    report.modules.push({role:['baseline','candidate','typescript'][i],module,receipt,compiler:emission.compiler});
    texts.push(fs.readFileSync(module.path,'utf8'));
    modules.push(!mode||i===1?await import(pathToFileURL(module.path)):null);
  }
  for(const row of catalog.cases)assert.equal(oracle(row.point.exportName,...row.point.args),row.point.expected,'Catalog oracle '+row.id);
  const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'];
  const parserModule={exports:{}};new Function('module','exports',parserSource)(parserModule,parserModule.exports);
  const parse=text=>parserModule.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});
  function nodes(root){const result=[],pending=[root];while(pending.length){const node=pending.pop();
    if(!node||typeof node!=='object'||typeof node.type!=='string')continue;result.push(node);
    for(const value of Object.values(node))if(Array.isArray(value))pending.push(...value);else if(value&&typeof value==='object')pending.push(value);
  }return result;}
  const isId=(node,name)=>node?.type==='Identifier'&&node.name===name;
  const assignment=node=>node?.type==='ExpressionStatement'&&node.expression.type==='AssignmentExpression'?node.expression:null;
  const ast=parse(texts[1]),allNodes=nodes(ast),tailOnlyMarker='/* private tail-only component */';
  const functions=allNodes.filter(node=>node.type==='FunctionDeclaration');
  const tailOnlyWrappers=[],seenWrappers=new Set();
  for(let offset=texts[1].indexOf(tailOnlyMarker);offset!==-1;offset=texts[1].indexOf(tailOnlyMarker,offset+tailOnlyMarker.length)){
    const wrapper=functions.filter(fn=>fn.body.start<offset&&offset<fn.body.end).sort((a,b)=>(a.end-a.start)-(b.end-b.start))[0];
    assert(wrapper,'Tail-only marker must belong to a declared wrapper');assert(!seenWrappers.has(wrapper),'One tail-only marker per wrapper');seenWrappers.add(wrapper);
    assert.equal(wrapper.body.body.length,1,'Tail-only wrapper contains only its native return');
    const statement=wrapper.body.body[0],call=statement.type==='ReturnStatement'?statement.argument:null;
    assert(call?.type==='CallExpression'&&call.callee.type==='Identifier'&&/^\$native\d+$/.test(call.callee.name),'Tail-only wrapper targets a named native component');
    assert(call.arguments[0]?.type==='Literal'&&Number.isInteger(call.arguments[0].value)&&call.arguments[0].value>=0,'Native entry label is an exact nonnegative integer');
    assert.equal(call.arguments.length,wrapper.params.length+1,'Tail-only wrapper forwards each argument');
    wrapper.params.forEach((param,i)=>assert(param.type==='Identifier'&&isId(call.arguments[i+1],param.name),'Tail-only positional argument forwarding'));
    assert(!nodes(wrapper).some(node=>node.type==='Identifier'&&/^\$worker(?:Budget|\d*)$/.test(node.name)),'Tail-only wrapper has no machine or budget reference');
    const scopes=allNodes.filter(node=>node.type==='BlockStatement'&&node.body.includes(wrapper));assert.equal(scopes.length,1,'Unambiguous wrapper lexical scope');
    const declarations=scopes[0].body.filter(node=>node.type==='FunctionDeclaration');
    const native=declarations.filter(fn=>fn.id.name===call.callee.name);assert.equal(native.length,1,'Native component declared in the same lexical scope');
    assert(texts[1].slice(native[0].body.start,native[0].body.end).includes('/* private first-order native component */'),'Target is a generated native loop');
    const machine=call.callee.name.replace('$native','$worker');assert(!declarations.some(fn=>fn.id.name===machine),'Tail-only component emits no machine');
    tailOnlyWrappers.push({wrapper:wrapper.id.name,target:call.callee.name,entry:call.arguments[0].value,offset,scopeStart:scopes[0].start,arguments:wrapper.params.length});
  }
  assert(tailOnlyWrappers.length>0,'Missing proven tail-only wrappers');
  const tailSites=[];
  for(const worker of allNodes.filter(node=>node.type==='FunctionDeclaration'&&/^\$worker\d*$/.test(node.id.name)))
    for(const branch of nodes(worker.body).filter(node=>node.type==='SwitchCase')){
      if(branch.consequent.length!==1||branch.consequent[0].type!=='BlockStatement')continue;
      const block=branch.consequent[0],body=block.body,next=assignment(body.at(-2));
      if(body.at(-1)?.type!=='ContinueStatement'||!isId(next?.left,'$pc')||next.right.type!=='Literal'||!Number.isInteger(next.right.value))continue;
      const changes=body.map(assignment).filter(Boolean);
      if(changes.some(a=>a.left.type==='MemberExpression'&&isId(a.left.object,'$returns')))continue;
      const allocated=changes.some(a=>isId(a.left,'$r')&&a.right.type==='ArrayExpression');
      const reused=changes.some(a=>a.left.type==='MemberExpression'&&isId(a.left.object,'$r')&&!a.left.computed&&isId(a.left.property,'length'));
      if(!allocated&&!reused)continue;
      tailSites.push({offset:block.start+1,worker:worker.id.name,shape:allocated?'allocated-argument-vector':'reused-argument-vector',target:next.right.value});
    }
  // All pure-tail SCCs may be native-only, leaving no machine tail transfer sites.
  const nativeTailSites=[];
  for(const component of allNodes.filter(node=>node.type==='FunctionDeclaration'&&/^\$native\d+$/.test(node.id.name)))
    for(const block of nodes(component.body).filter(node=>node.type==='BlockStatement')){
      const body=block.body,next=assignment(body.at(-2));
      if(body.at(-1)?.type!=='ContinueStatement'||!isId(next?.left,'$pc')||next.right.type!=='Literal'||!Number.isInteger(next.right.value))continue;
      let cursor=body.length-3;const stores=[],captures=[];
      while(cursor>=0){const store=assignment(body[cursor]);
        if(store?.left.type!=='Identifier'||!/^\$v\d+$/.test(store.left.name)||!isId(store.right,'$next'+store.left.name.slice(2)))break;
        stores.unshift(store);cursor--;}
      const firstStore=cursor+1;
      while(cursor>=0){const statement=body[cursor],capture=statement.type==='VariableDeclaration'&&statement.kind==='const'&&statement.declarations.length===1?statement.declarations[0]:null;
        if(capture?.id.type!=='Identifier'||!/^\$next\d+$/.test(capture.id.name))break;
        captures.unshift(capture);cursor--;}
      assert(stores.length>0&&stores.length===captures.length,'Complete native tail argument capture');
      for(const store of stores){const temp='$next'+store.left.name.slice(2);assert(isId(store.right,temp));assert(captures.some(c=>c.id.name===temp));}
      nativeTailSites.push({offset:body[firstStore].start,component:component.id.name,target:next.right.value,arguments:stores.length});
    }
  assert(nativeTailSites.length>0,'Missing native proper tail transfer sites');
  const patches=[
    ['/* private contextual instances */','/* private contextual instances */++$p45Worker.contextual;'],
    ['/* private first-order continuation graph */','/* private first-order continuation graph */++$p45Worker.entries;'],
    ['/* private first-order continuation component */','/* private first-order continuation component */++$p45Worker.entries;'],
    ['/* private first-order acyclic function */','/* private first-order acyclic function */++$p45Worker.acyclic;'],
    ['$returns[$top]=','++$p45Worker.calls;$returns[$top]='],
    [';if(!$top)return $value;',';++$p45Worker.returns;if(!$top)return $value;'],
    [tailOnlyMarker,tailOnlyMarker+'++$p45Worker.tailOnly;'],
    ['let $workerBudget=32;','let $workerBudget=32;$p45WorkerBudgets.push(()=>$workerBudget);'],
    ['--$workerBudget;try{','--$workerBudget;try{++$p45Worker.native;if($p45WorkerFault!==null){const $fault=$p45WorkerFault;$p45WorkerFault=null;$fault();}'],
    ['}finally{++$workerBudget;}','}finally{++$workerBudget;++$p45Worker.restored;}']];
  assert(!texts[1].includes('$p45Worker'),'Reserved diagnostic name collision');
  let derived=texts[1];const edits=[];
  const transfers=[...tailSites.map(site=>({...site,counter:'tails'})),...nativeTailSites.map(site=>({...site,counter:'nativeTails'}))];
  for(const site of transfers.sort((a,b)=>b.offset-a.offset))derived=derived.slice(0,site.offset)+'++$p45Worker.'+site.counter+';'+derived.slice(site.offset);
  for(const [old,replacement] of patches){const count=derived.split(old).length-1;
    if(!old.startsWith('/* private first-order'))assert(count>0,'Missing worker shape '+old);
    edits.push({old,replacement,count});derived=derived.replaceAll(old,replacement);}
  assert(edits[1].count+edits[2].count>0,'Missing recursive dispatcher');
  assert.equal(edits.at(-1).count,edits.at(-2).count,'Every native entry needs its matching finally');
  const budgetScopes=edits.at(-3).count;
  derived='const $p45Worker={contextual:0,entries:0,acyclic:0,calls:0,returns:0,tails:0,nativeTails:0,tailOnly:0,native:0,restored:0},$p45WorkerBudgets=[];let $p45WorkerFault=null;\n'+derived+
    '\nexport const p45WorkerCounts=()=>({...$p45Worker});\nexport const p45WorkerBudgets=()=>$p45WorkerBudgets.map(read=>read());\nexport const p45WorkerFault=f=>{$p45WorkerFault=f;};\n';
  parse(derived);
  const derivedFile=path.join(out,'candidate-counter.mjs');fs.writeFileSync(derivedFile,derived,{flag:'wx'});
  report.derivative={module:identity(derivedFile),source:report.modules[1].module,edits,tailSites,nativeTailSites,tailOnlyWrappers,
    machineTailPolicy:'Zero machine tail sites is permitted because proven tail-only components emit native loops without machines; native transfer sites and non-tail dispatcher/finally sites remain mandatory.',
    parser:{version:parserModule.exports.version,sha256:createHash('sha256').update(parserSource).digest('hex')},performanceEvidence:false,
    faultScope:'Optional test callback injected immediately inside the native try, consumed once. Tests generated finally/reentry mechanics, not compiler admission of arbitrary source effects.'};
  const witness=await import(pathToFileURL(derivedFile));
  function budgets(){const values=witness.p45WorkerBudgets();assert.equal(values.length,budgetScopes);assert(values.every(n=>n===32),'Every lexical budget must restore to32');return values;}
  budgets();
  function observed(name,n,seed){const expected=oracle(name,n,seed),beforeBudgets=budgets(),before=witness.p45WorkerCounts();
    const value=witness.default[name](n,seed),after=witness.p45WorkerCounts();
    const counts=Object.fromEntries(Object.keys(before).map(key=>[key,after[key]-before[key]]));
    assert.equal(value,expected,name);assert.equal(counts.contextual,1,name+' contextual activation');
    assert.equal(counts.native,counts.restored,name+' native finally balance');
    if(name==='tail_check'){
      assert.equal(counts.entries,0,'Pure tail cycle must remain on native loop at every depth');
      assert(counts.nativeTails>=n,'Native proper tail transfers must cover depth');
      assert.equal(counts.tailOnly,1,'Pure tail cycle enters its unbudgeted wrapper once');
      assert.equal(counts.native,0,'Pure tail cycle consumes no native budget entries');
      assert.equal(counts.restored,0,'Pure tail cycle has no budget restorations');
    }else{
      assert(counts.native>0,name+' native recursive entry');
      if(n<=3)assert.equal(counts.entries,0,name+' shallow execution should remain native');
      if(n>=32)assert(counts.entries>=1,name+' deep execution must enter a component dispatcher');
      assert(counts.calls+counts.native>=n,'Native and dispatcher pending calls must cover depth');
      if(n>=4096)assert(counts.calls>=n-32,'Deep dispatcher must cover depth beyond native budget');
    }
    const afterBudgets=budgets();report.activation.push({name,n,seed,expected,value,counts,beforeBudgets,afterBudgets});return value;}
  if(!mode){
    for(const name of roots)for(const n of [0,1,2,3,8,31,32,33,64])for(const seed of [0,7,4294967295]){
      const expected=oracle(name,n,seed),values=modules.map(m=>m.default[name](n,seed));
      for(const value of values)assert.equal(value,expected,name+' '+n+' '+seed);
      report.oracles.push({name,n,seed,expected,values});}
    for(const name of roots){observed(name,3,7);observed(name,33,4294967295);observed(name,3,7);}
    for(const [n,seed] of [[0,7],[1,7],[2,7],[3,4294967295],[8,7]]){
      const {marks,end}=ribbon(n,seed),expected={marks,end},values=[];
      for(const m of modules){const first=m.default.tree_value(n,seed),firstValue=readRibbon(first,n+1),second=m.default.tree_value(n,seed);
        assert.notEqual(first,second,'Public data must be fresh');assert.deepEqual(firstValue,expected);
        assert.deepEqual(readRibbon(first,n+1),expected);assert.deepEqual(readRibbon(second,n+1),expected);values.push(firstValue);}
      report.trees.push({n,seed,expected,values});}
    for(const name of roots){const helper={bench:'azimuth',tail_check:'port',tree_check:'willow',scope_check:'azimuth',sibling_check:'meridian'}[name];
      const observations=[];
      for(const m of modules.slice(0,2)){const f=m.G[helper],old=f.code,events=[];let value;
        try{f.code=function(a){events.push(helper);return Reflect.apply(old,this,[a]);};value=m.default[name](3,7);}
        finally{f.code=old;}observations.push({value,events});}
      assert.deepEqual(observations[1],observations[0]);assert(observations[0].events.length);
      const f=witness.G[helper],old=f.code,before=witness.p45WorkerCounts();
      try{f.code=function(a){return Reflect.apply(old,this,[a]);};assert.equal(witness.default[name](3,7),oracle(name,3,7));}
      finally{f.code=old;}
      const after=witness.p45WorkerCounts();assert.equal(after.contextual-before.contextual,0,name+' guard refusal');
      assert.equal(after.entries-before.entries,0,name+' worker refusal');assert.equal(after.acyclic-before.acyclic,0,name+' acyclic worker refusal');
      assert.equal(after.native-before.native,0,name+' native worker refusal');
      assert.equal(after.tailOnly-before.tailOnly,0,name+' tail-only worker refusal');budgets();report.boundaries.push({name,helper,observations});}
    // Deliberate diagnostic faults exercise finally even though the source fixture is total.
    for(const reenter of [false,true]){const before=witness.p45WorkerCounts(),token=new Error('diagnostic native sentinel');let during,nested;
      witness.p45WorkerFault(()=>{during=witness.p45WorkerBudgets();assert(during.some(n=>n<32));
        if(reenter)nested=witness.default.bench(3,7);throw token;});
      assert.throws(()=>witness.default.bench(3,7),error=>error===token);
      if(reenter)assert.equal(nested,oracle('bench',3,7));const restoredBudgets=budgets(),after=witness.p45WorkerCounts();
      assert.equal(after.native-before.native,after.restored-before.restored,'Exceptional native finally balance');
      const replay=witness.default.bench(3,7);assert.equal(replay,oracle('bench',3,7));budgets();
      report.unwinding.push({kind:'diagnostic-fault',reenter,during,nested,restoredBudgets,replay,
        nativeEntries:after.native-before.native,restorations:after.restored-before.restored});}
  }else{
    for(const n of [4096,50000])for(const seed of [7,4294967295]){
      observed(deepRoot,3,7);
      const expected=oracle(deepRoot,n,seed),value=modules[1].default[deepRoot](n,seed);assert.equal(value,expected);
      observed(deepRoot,n,seed);report.oracles.push({name:deepRoot,n,seed,expected,value,role:'candidate'});
      assert.equal(modules[1].default[deepRoot](3,7),oracle(deepRoot,3,7),'Shallow result after deep execution');observed(deepRoot,3,7);}
  }
  for(const item of pinned.values())assert.deepEqual(identity(item.path),item,'Changed input');
  assert.deepEqual(identity(derivedFile),report.derivative.module);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,activation:report.activation.length,trees:report.trees.length,boundaries:report.boundaries.length,unwinding:report.unwinding.length,error:report.error}));
