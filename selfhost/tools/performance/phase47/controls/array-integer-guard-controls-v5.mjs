// Additive, untimed controls for integer-only raw-array host dependencies.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseline,candidate,output]=process.argv.slice(2);
assert(output,'array-integer-guard-controls-v5.mjs BASELINE_MODULE CANDIDATE_MODULE NEW_OUT');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase47-independent-array-integer-guard-controls-v5',complete:false,pass:false,inputs:[],modules:[],oracles:[],boundaries:[],
  scope:'Typed host-guard selection, exact predecessor/candidate observations and separate entry counters. Additive to v2/v3/v4; no timing or promotion claim.'};
const pinned=new Map(),apply=Reflect.apply,define=Object.defineProperty,descriptor=Object.getOwnPropertyDescriptor;
const OriginalNumber=Number,OriginalMath=Math,OriginalArray=Array,OriginalError=Error;
const originalFloor=Math.floor,originalFround=Math.fround,originalNaN=Number.isNaN;
const identity=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {path:file,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};};
function pin(file,want){const x=identity(file);if(want){assert.equal(x.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(x.bytes,want.bytes);}
  if(pinned.has(x.path))assert.deepEqual(x,pinned.get(x.path));else{pinned.set(x.path,x);report.inputs.push(x);}return x;}
function audit(v){if(Array.isArray(v))v.forEach(audit);else if(v&&typeof v==='object'){
  const file=v.path??v.file??v.canonicalPath;if(typeof file==='string'&&v.sha256)pin(file,v);Object.values(v).forEach(audit);}}
const wrap=x=>x>>>0,divide=(a,b,extra=0)=>b===0?0:wrap(originalFloor(a/b)+extra);
function expected(turns,seed,divisor,extra=0){const cells=Array(4).fill(seed);let total=0;
  for(let i=0;i<turns;i++){total=divide(wrap(total+cells[i%4]+i+1),divisor,extra);cells[i%4]=total;}return total;}
function tree(depth,turns,seed,divisor,extra=0){return depth===0?expected(turns,seed,divisor,extra):wrap(tree(depth-1,turns,seed,divisor,extra)+tree(depth-1,turns,wrap(seed+1),divisor,extra));}
function callRoot(m,root){if(root==='plain')return m.default.plain(17,3);if(root==='binary')return m.default.binary(2n,5,17,3);
  return root==='integer'?m.default.integer(5,17,3):m.default[root](5,17,3,NaN);}
const wantRoot=(root,extra=0)=>root==='plain'?divide(17,3,extra):root==='binary'?tree(2,5,17,3,extra):expected(5,17,3,extra);
const thrown=e=>({type:typeof e,name:e?.name??null,message:e?.message??String(e)});
function scenario(m,root,name){const events=[],restores=[],sentinel=new OriginalError('integer guard sentinel');let value,error,sameError=false;
  const log=x=>events.push(x),patch=(owner,key,desc)=>{const old=descriptor(owner,key);restores.push(()=>old?define(owner,key,old):delete owner[key]);define(owner,key,{configurable:true,...desc});};
  const floatingHooks=()=>{patch(OriginalMath,'fround',{writable:true,value:function(x){log(['fround',String(x)]);return originalFround(x);}});
    patch(OriginalNumber,'isNaN',{writable:true,value:function(x){log(['isNaN',String(x)]);return originalNaN(x);}});};
  const floor=function(x){log(['floor',x]);if(name==='floor-throw')throw sentinel;return originalFloor(x)+1;};
  try{
    if(name.startsWith('isNaN-')||name.startsWith('fround-')){
      const nan=name.startsWith('isNaN-'),owner=nan?OriginalNumber:OriginalMath,key=nan?'isNaN':'fround',original=nan?originalNaN:originalFround;
      const wrapped=function(x){log([key,String(x)]);return original(x);};
      patch(owner,key,name.endsWith('-getter')?{get(){log(key+':get');return wrapped;}}:{writable:true,value:wrapped});
    }else if(name.startsWith('floor-'))patch(OriginalMath,'floor',name==='floor-getter'?{get(){log('floor:get');return floor;}}:{writable:true,value:floor});
    else if(name.startsWith('late-fill-')){const fill=OriginalArray.prototype.fill;let changed=false;
      patch(OriginalArray.prototype,'fill',{writable:true,value:function(...args){log('fill');const result=apply(fill,this,args);
        if(!changed){changed=true;if(name==='late-fill-floor')patch(OriginalMath,'floor',{writable:true,value:floor});
          else{floatingHooks();log(['nested',m.default.floating(1,5,3,NaN)]);}}
        return result;}});
    }else if(name.startsWith('callback-')){
      const storage={get array(){log('storage');return [17,19,23,29];}},callback={arity:1,env:null,bound:[],code:function(args){log(['callback',args[0]]);
        if(name==='callback-throw')throw sentinel;
        if(name==='callback-floor')patch(OriginalMath,'floor',{writable:true,value:floor});
        else{floatingHooks();log(['nested',m.default.floating(1,5,3,NaN),m.default.integer(1,5,3)]);}return 3;}};
      value=m.default.public_callback(storage,callback);
    }else throw new OriginalError('Unknown scenario '+name);
    if(!name.startsWith('callback-'))value=callRoot(m,root);
  }catch(e){error=thrown(e);sameError=e===sentinel;}
  finally{for(let i=restores.length-1;i>=0;i--)restores[i]();}
  if(name==='floor-throw'||name==='callback-throw'){assert(error);assert(sameError,'Original thrown object must propagate');}
  else{assert.equal(error,undefined);const extra=name.startsWith('floor-')||name==='late-fill-floor'||name==='callback-floor'?1:0;
    assert.equal(value,name.startsWith('callback-')?divide(17,3,extra):wantRoot(root,extra));}
  if(name.startsWith('floor-')||name==='late-fill-floor'||name==='callback-floor')assert(events.some(x=>Array.isArray(x)&&x[0]==='floor'),'Math.floor must remain observable');
  if(name==='late-fill-float')assert(events.some(x=>Array.isArray(x)&&x[0]==='nested'&&x[1]===2));
  if(name==='callback-float')assert(events.some(x=>Array.isArray(x)&&x[0]==='nested'&&x[1]===2&&x[2]===2));
  if(name==='callback-throw')assert.deepEqual(events,[['callback',3]],'Callback throws before public storage is demanded');
  if(name==='callback-floor'){assert.equal(events[0][0],'callback');assert(events.indexOf('storage')>0);assert(events.findIndex(x=>Array.isArray(x)&&x[0]==='floor')>events.indexOf('storage'));}
  // Floating hook counts are compared with the predecessor rather than guessed:
  // a retained old input guard can itself observe a hook after new-path refusal.
  return {value,error,sameError,events};
}
try{
  pin(import.meta.filename);pin(process.execPath);fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
  const catalogId=pin(path.join(import.meta.dirname,'array-integer-guard-catalog-v5.json')),catalog=JSON.parse(fs.readFileSync(catalogId.path,'utf8'));
  assert.equal(catalog.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
  const source=pin(path.join(import.meta.dirname,catalog.cases[0].source.path),catalog.cases[0].source),modules=[],texts=[];
  for(const [i,file]of [baseline,candidate].entries()){
    const module=pin(file),receipt=pin(module.path+'.json'),r=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(r.kind,'bend-program-checked-emission');assert.equal(r.complete,true);assert.equal(r.observation.checked,true);assert.equal(r.observation.status,'ok');
    assert.equal(r.output.sha256,module.sha256);assert.equal(r.input.sha256,source.sha256);assert.equal(r.catalog.sha256,catalogId.sha256);
    assert.equal(r.compiler.upstreamCommit,catalog.upstreamCommit);assert(['checked-development-attempt','installed-checked-release'].includes(r.compiler.kind));audit(r);
    report.modules.push({role:i?'candidate':'baseline',module,receipt,compiler:r.compiler});texts.push(fs.readFileSync(module.path,'utf8'));modules.push(await import(pathToFileURL(module.path)));
  }
  for(const turns of [0,1,5,9])for(const seed of [0,17,4294967295])for(const divisor of [0,1,3,4294967295]){
    const want=expected(turns,seed,divisor),values=modules.map(m=>m.default.integer(turns,seed,divisor));for(const value of values)assert.equal(value,want);
    report.oracles.push({root:'integer',turns,seed,divisor,expected:want,values});}
  for(const root of ['floating','aliased'])for(const [sampleName,sample]of [['zero',0],['quarter',1.25],['nan',NaN],['infinity',Infinity],['noncanonical',1/3]])for(const turns of [0,1,5])for(const divisor of [0,3]){
    const want=expected(turns,17,divisor),values=modules.map(m=>m.default[root](turns,17,divisor,sample));for(const value of values)assert.equal(value,want);
    report.oracles.push({root,sample:sampleName,turns,divisor,expected:want,values});}
  for(const depth of [0,1,2,3])for(const turns of [0,5])for(const seed of [0,17])for(const divisor of [0,3]){
    const want=tree(depth,turns,seed,divisor),values=modules.map(m=>m.default.binary(BigInt(depth),turns,seed,divisor));for(const value of values)assert.equal(value,want);
    report.oracles.push({root:'binary',depth,turns,seed,divisor,expected:want,values});}
  for(const numerator of [0,17,4294967295])for(const divisor of [0,1,3,4294967295]){
    const want=divide(numerator,divisor),values=modules.map(m=>m.default.plain(numerator,divisor));for(const value of values)assert.equal(value,want);
    report.oracles.push({root:'plain',numerator,divisor,expected:want,values});}
  const anchor=catalog.cases[0].point,values=modules.map(m=>m.default.bench(...anchor.args));assert.equal(expected(...anchor.args,3),anchor.expected);
  for(const value of values)assert.equal(value,anchor.expected);report.oracles.push({root:'bench',expected:anchor.expected,values});
  const floatingCases=['isNaN-replacement','isNaN-getter','fround-replacement','fround-getter'];
  const cases=[];for(const root of ['integer','floating','aliased','binary','plain'])for(const name of [...floatingCases,'floor-replacement','floor-getter','floor-throw'])cases.push({root,name});
  for(const root of ['integer','floating','aliased','binary'])for(const name of ['late-fill-floor','late-fill-float'])cases.push({root,name});
  for(const name of ['callback-floor','callback-float','callback-throw'])cases.push({root:'public_callback',name});
  for(const c of cases){const observations=modules.map(m=>scenario(m,c.root,c.name));assert.deepEqual(observations[1],observations[0],c.root+'/'+c.name);report.boundaries.push({...c,observations});}
  report.correctnessPass=true;
  const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};
  new Function('module','exports',parserSource)(parserModule,parserModule.exports);
  const parse=text=>parserModule.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});
  function nodes(root){const todo=[root],found=[];while(todo.length){const n=todo.pop();if(!n||typeof n!=='object'||typeof n.type!=='string')continue;found.push(n);
    for(const x of Object.values(n))if(Array.isArray(x))todo.push(...x);else if(x&&typeof x==='object')todo.push(x);}return found;}
  const ast=nodes(parse(texts[1])),roots=name=>ast.filter(n=>n.type==='AssignmentExpression'&&n.left.type==='MemberExpression'&&n.left.object.type==='Identifier'&&n.left.object.name==='G'&&n.left.computed&&n.left.property.type==='Literal'&&n.left.property.value===name);
  const rootNames=['integer','floating','aliased','binary'],insertions=[];report.activation={status:'pending',modes:[],entries:[],boundaries:[]};
  for(const [index,root]of rootNames.entries()){
    const marker=root==='binary'?'/* private raw array tree */':'/* private raw array root */',matches=roots(root).filter(n=>texts[1].slice(n.right.start,n.right.end).includes(marker));
    if(matches.length!==1)report.activation.status='refused';assert.equal(matches.length,1,root+' needs a selected raw branch');
    const row=matches[0],body=texts[1].slice(row.right.start,row.right.end);assert.equal(body.split(marker).length-1,1);const at=row.right.start+body.indexOf(marker);
    const guards=nodes(row.right).filter(n=>n.type==='IfStatement'&&n.consequent.start<=at&&at<n.consequent.end)
      .flatMap(n=>nodes(n.test).filter(x=>x.type==='CallExpression'&&x.callee.type==='Identifier'&&x.callee.name==='arrayViewHostGuard'));
    assert.equal(guards.length,1,'Unique fresh array host guard for '+root);const args=guards[0].arguments;
    assert(args.length===0||(args.length===1&&args[0].type==='Literal'&&typeof args[0].value==='boolean'));
    const integerOnly=args.length===1&&args[0].value;assert.equal(integerOnly,root==='integer'||root==='binary','Full F32 input guard must survive unused/aliased inputs');
    report.activation.modes.push({root,integerOnly});insertions.push({at:at+marker.length,text:'$p47IntegerGuardEntries['+index+']++;',root});
  }
  for(const root of ['plain','public_callback']){const rows=roots(root);assert(rows.length);assert(rows.every(n=>!texts[1].slice(n.right.start,n.right.end).includes('/* private raw array')));}
  assert(!texts[1].includes('$p47IntegerGuardEntries'));let derived=texts[1];for(const x of [...insertions].sort((a,b)=>b.at-a.at))derived=derived.slice(0,x.at)+x.text+derived.slice(x.at);
  derived='const $p47IntegerGuardEntries=[0,0,0,0];\n'+derived+'\nexport const phase47IntegerGuardEntries=()=>$p47IntegerGuardEntries.slice();\n';parse(derived);
  const file=path.join(out,'candidate-integer-guard-counter.mjs');fs.writeFileSync(file,derived,{flag:'wx'});
  report.derivative={module:identity(file),parent:report.modules[1].module,insertions,
    parser:{version:parserModule.exports.version,sha256:createHash('sha256').update(parserSource).digest('hex')},performanceEvidence:false};
  const witness=await import(pathToFileURL(file)),delta=before=>witness.phase47IntegerGuardEntries().map((x,i)=>x-before[i]);
  for(const [index,root]of rootNames.entries()){const before=witness.phase47IntegerGuardEntries(),value=callRoot(witness,root),entries=delta(before),want=[0,0,0,0];want[index]=1;
    assert.equal(value,wantRoot(root));assert.deepEqual(entries,want);report.activation.entries.push({root,entries});}
  for(const root of ['floating','aliased']){const before=witness.phase47IntegerGuardEntries(),value=witness.default[root](5,17,3,1/3),entries=delta(before);
    assert.equal(value,expected(5,17,3));assert.deepEqual(entries.slice(1),[0,0,0]);assert(entries[0]===0||entries[0]===1,'A generic fallback may call the independent integer root');report.activation.entries.push({root,sample:'noncanonical',entries});}
  for(const c of cases){const before=witness.phase47IntegerGuardEntries(),observation=scenario(witness,c.root,c.name),entries=delta(before),want=[0,0,0,0];
    if(floatingCases.includes(c.name)&&(c.root==='integer'||c.root==='binary'))want[rootNames.indexOf(c.root)]=1;
    assert.deepEqual(observation,report.boundaries.find(x=>x.root===c.root&&x.name===c.name).observations[1]);
    if(c.name==='callback-float'){
      assert.deepEqual(entries.slice(1),[0,0,0]);assert(entries[0]===1||entries[0]===2,'Explicit integer reentry, plus at most one floating fallback integer call');
    }else if(floatingCases.includes(c.name)&&(c.root==='floating'||c.root==='aliased')){
      assert.deepEqual(entries.slice(1),[0,0,0]);assert(entries[0]===0||entries[0]===1,'The F32 entry refuses; its ordinary integer child may still enter');
    }else assert.deepEqual(entries,want,c.root+'/'+c.name+' entry permission');
    report.activation.boundaries.push({...c,entries});}
  assert.deepEqual(identity(file),report.derivative.module);report.activation.status='pass';
  for(const x of pinned.values())assert.deepEqual(identity(x.path),x);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,(_k,v)=>typeof v==='bigint'?{$bigint:String(v)}:v,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,boundaries:report.boundaries.length,activation:report.activation?.status,error:report.error}));
