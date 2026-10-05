// Untimed typed-array effect, value and private-entry controls.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseline,candidate,output]=process.argv.slice(2);
assert(output,'array-effects-controls-v3.mjs BASELINE_MODULE CANDIDATE_MODULE NEW_OUT');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase48-array-effects-controls-v3',complete:false,pass:false,inputs:[],modules:[],oracles:[],boundaries:[],activation:[],
  scope:'Finite independent typed-array oracles, original/candidate observation equality, untimed private-entry counters. No benchmark or universal conformance claim.'};
const pinned=new Map(),apply=Reflect.apply,define=Object.defineProperty,descriptor=Object.getOwnPropertyDescriptor;
const N=Number,A=Array,M=Math,E=Error,round=Math.fround;
const identity=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {path:file,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};};
function pin(file,want){const x=identity(file);if(want){assert.equal(x.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(x.bytes,want.bytes);}
  if(pinned.has(x.path))assert.deepEqual(x,pinned.get(x.path));else{pinned.set(x.path,x);report.inputs.push(x);}return x;}
function audit(v){if(A.isArray(v))v.forEach(audit);else if(v&&typeof v==='object'){
  const file=v.path??v.file??v.canonicalPath;if(typeof file==='string'&&v.sha256)pin(file,v);Object.values(v).forEach(audit);}}
const serial=v=>typeof v==='number'?(N.isNaN(v)?'NaN':Object.is(v,-0)?'-0':v===Infinity?'Infinity':v===-Infinity?'-Infinity':v):v;
function floatOracle(turns,seed){const cells=A(4).fill(seed);let score=seed;
  for(let i=0;i<turns;i++){const at=i%4,next=(i+1)%4,old=cells[at];cells[at]=round(score+0.25);
    const value=round(round(old*0.5)+cells[next]);cells[next]=value;score=round(round(score+value)+round(4));}return score;}
function integerOracle(turns,seed){const cells=A(4).fill(seed);let score=seed;
  for(let i=0;i<turns;i++){const at=i%4,old=cells[at];cells[at]=(score+1)>>>0;score=(((score+old)>>>0)+4)>>>0;}return score;}
const convert=x=>!N.isFinite(x)||x<0||x>=4294967296?0:M.trunc(x)>>>0;
const thrown=e=>({name:e?.name??null,message:e?.message??String(e)});
function ordered(m,label){const events=[],restores=[],sentinel=new E('array effect sentinel');let value,error,sameError=false,conversions=0;
  const patch=(owner,key,d)=>{const old=descriptor(owner,key);restores.push(()=>old?define(owner,key,old):delete owner[key]);define(owner,key,{configurable:true,...d});};
  const number=function(x){events.push(['Number',typeof x,String(x)]);if(typeof x==='number'){
    conversions++;if(label==='second-conversion-throw'&&conversions===2)throw sentinel;}return N(x);};
  Object.setPrototypeOf(number,N);
  try{patch(globalThis,'Number',{writable:true,value:number});
    for(const [name,tag] of [['source.index','index'],['source.value','value'],['Array.swap','swap']]){
      const f=m.G[name],code=f.code;patch(f,'code',{writable:true,value:function(args){events.push(tag);if(label===tag+'-throw')throw sentinel;return apply(code,this,[args]);}});}
    value=m.default.ordered(1,7.25);
  }catch(e){error=thrown(e);sameError=e===sentinel;}finally{for(let i=restores.length-1;i>=0;i--)restores[i]();}
  const tags=events.filter(x=>typeof x==='string'),wanted=label==='index-throw'?['index']:label==='value-throw'?['index','value']:['index','value','swap'];
  assert.deepEqual(tags,wanted);assert.equal(conversions,label==='ordered'||label==='second-conversion-throw'?2:0);
  if(label==='ordered'){assert.equal(value,3);assert.equal(error,undefined);}else{assert(sameError);assert(error);}
  if(conversions)assert(events.findIndex(x=>A.isArray(x)&&x[1]==='number')>events.indexOf('swap'));
  return {value:serial(value),error,sameError,events};
}
function hostile(m,label){const events=[],restores=[],sentinel=new E('late fill helper sentinel');let value,error,sameError=false;
  const patch=(owner,key,d)=>{const old=descriptor(owner,key);restores.push(()=>define(owner,key,old));define(owner,key,{configurable:true,...d});};
  const wrap=(owner,key)=>{const original=owner[key];patch(owner,key,{writable:true,value:function(...args){events.push([key,...args.map(serial)]);return apply(original,this,args);}});};
  try{
    if(label==='fround'||label==='trunc')wrap(M,label);
    else if(label==='isNaN'||label==='isFinite')wrap(N,label);
    else if(label==='DataView')wrap(DataView.prototype,'getFloat32');
    else if(label==='late-fill-fround'||label==='late-fill-helper'){const fill=A.prototype.fill;let changed=false;
      patch(A.prototype,'fill',{writable:true,value:function(...args){events.push(['fill']);const result=apply(fill,this,args);
        if(!changed){changed=true;if(label==='late-fill-fround')wrap(M,'fround');else patch(m.G['wash.step'],'code',{writable:true,value:function(){events.push(['helper']);throw sentinel;}});}return result;}});}
    else throw new E(label);
    value=m.default.converted(3,2);
  }catch(e){error=thrown(e);sameError=e===sentinel;}finally{for(let i=restores.length-1;i>=0;i--)restores[i]();}
  if(label==='late-fill-helper'){assert(sameError);assert(events.some(x=>x[0]==='helper'));assert.equal(value,undefined);}else{assert.equal(error,undefined);assert.equal(value,24);}
  return {value,error,sameError,events};
}
function publicSwap(m,label){const events=[],restores=[];let reads=0,conversions=0;const initial=[1.25,-0,3.5,NaN],second=[8,9,10,11];
  const handle=label==='getter'?{get array(){events.push('storage');reads++;return reads<=2?initial:second;}}:{array:initial};
  const number=function(x){events.push(['Number',x]);conversions++;return conversions===1?0:1;};Object.setPrototypeOf(number,N);
  const old=descriptor(globalThis,'Number');define(globalThis,'Number',{configurable:true,writable:true,value:number});
  try{const result=m.default.external(handle,3,7.5);assert(A.isArray(result));assert.equal(result[0],handle);assert.equal(result[1],1.25);
    assert.equal(conversions,2);assert.equal(initial[1],label==='getter'?-0:7.5);if(label==='getter')assert.equal(second[1],7.5);
    return {sameHandle:true,old:serial(result[1]),initial:initial.map(serial),second:second.map(serial),events};
  }finally{define(globalThis,'Number',old);}
}
try{
  pin(import.meta.filename);pin(process.execPath);fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
  const catId=pin(path.join(import.meta.dirname,'array-effects-catalog-v2.json')),cat=JSON.parse(fs.readFileSync(catId.path,'utf8'));
  assert.equal(cat.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
  const source=pin(path.join(import.meta.dirname,cat.cases[0].source.path),cat.cases[0].source),modules=[],texts=[];
  for(const [i,file]of [baseline,candidate].entries()){
    const module=pin(file),receipt=pin(module.path+'.json'),r=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(r.kind,'bend-program-checked-emission');assert.equal(r.complete,true);assert.equal(r.observation.checked,true);assert.equal(r.observation.status,'ok');
    assert.equal(r.output.sha256,module.sha256);assert.equal(r.input.sha256,source.sha256);assert.equal(r.catalog.sha256,catId.sha256);
    assert.equal(r.compiler.upstreamCommit,cat.upstreamCommit);assert(['checked-development-attempt','installed-checked-release'].includes(r.compiler.kind));audit(r);
    report.modules.push({role:i?'candidate':'baseline',module,receipt,compiler:r.compiler});texts.push(fs.readFileSync(module.path,'utf8'));modules.push(await import(pathToFileURL(module.path)));
  }
  for(const turns of [0,1,2,5,17])for(const seed of [0,-0,round(1/3),2,-3.5,2**-149,2**32,NaN,Infinity,-Infinity]){
    const expected=floatOracle(turns,seed),values=modules.map(m=>m.default.floating(turns,seed));for(const value of values)assert(Object.is(value,expected));
    report.oracles.push({root:'floating',turns,seed:serial(seed),expected:serial(expected),values:values.map(serial)});
    const wanted=convert(expected),converted=modules.map(m=>m.default.converted(turns,seed));for(const value of converted)assert.equal(value,wanted);
    report.oracles.push({root:'converted',turns,seed:serial(seed),expected:wanted,values:converted});}
  for(const turns of [0,1,2,5,17])for(const seed of [0,2,4294967295]){
    const expected=integerOracle(turns,seed),values=modules.map(m=>m.default.integer(turns,seed));for(const value of values)assert.equal(value,expected);
    report.oracles.push({root:'integer',turns,seed,expected,values});}
  const point=cat.cases[0].point;assert.equal(convert(floatOracle(...point.args)),point.expected);
  for(const m of modules)assert.equal(m.default.bench(...point.args),point.expected);
  for(const label of ['ordered','index-throw','value-throw','swap-throw','second-conversion-throw']){
    const observations=modules.map(m=>ordered(m,label));assert.deepEqual(observations[1],observations[0]);report.boundaries.push({kind:'ordered',label,observations});}
  for(const label of ['fround','trunc','isNaN','isFinite','DataView','late-fill-fround','late-fill-helper']){
    const observations=modules.map(m=>hostile(m,label));assert.deepEqual(observations[1],observations[0]);report.boundaries.push({kind:'host',label,observations});}
  for(const label of ['plain','getter']){const observations=modules.map(m=>publicSwap(m,label));assert.deepEqual(observations[1],observations[0]);report.boundaries.push({kind:'public',label,observations});}
  report.correctnessPass=true;
  const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};
  new Function('module','exports',parserSource)(parserModule,parserModule.exports);
  const parse=text=>parserModule.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});
  function nodes(root){const todo=[root],found=[];while(todo.length){const n=todo.pop();if(!n||typeof n!=='object'||typeof n.type!=='string')continue;found.push(n);
    for(const x of Object.values(n))if(A.isArray(x))todo.push(...x);else if(x&&typeof x==='object')todo.push(x);}return found;}
  const ast=nodes(parse(texts[1])),roots=name=>ast.filter(n=>n.type==='AssignmentExpression'&&n.left.type==='MemberExpression'&&n.left.object.type==='Identifier'&&n.left.object.name==='G'&&n.left.computed&&n.left.property.type==='Literal'&&n.left.property.value===name);
  const marker='/* private raw array root */',rootNames=['floating','integer','converted'],insertions=[];
  for(const [index,root]of rootNames.entries()){
    const matches=roots(root).filter(n=>texts[1].slice(n.right.start,n.right.end).includes(marker));assert.equal(matches.length,1,root+' actual selected raw entry');
    const row=matches[0],body=texts[1].slice(row.right.start,row.right.end);assert.equal(body.split(marker).length-1,1);const at=row.right.start+body.indexOf(marker);
    const guards=nodes(row.right).filter(n=>n.type==='IfStatement'&&n.consequent.start<=at&&at<n.consequent.end)
      .flatMap(n=>nodes(n.test).filter(x=>x.type==='CallExpression'&&x.callee.type==='Identifier'&&x.callee.name==='arrayViewHostGuard'));
    assert.equal(guards.length,1);const args=guards[0].arguments;
    assert(args.length===0||(args.length===1&&args[0].type==='Literal'&&typeof args[0].value==='boolean'));
    assert.equal(args.length===1&&args[0].value,root==='integer','F32 effects require full fresh host guard');
    insertions.push({at:at+marker.length,text:'$p48EffectEntries['+index+']++;',root});}
  assert(roots('external').every(n=>!texts[1].slice(n.right.start,n.right.end).includes(marker)),'Public arrays must refuse raw entry');
  assert(!texts[1].includes('$p48EffectEntries'));let derived=texts[1];for(const x of [...insertions].sort((a,b)=>b.at-a.at))derived=derived.slice(0,x.at)+x.text+derived.slice(x.at);
  derived='const $p48EffectEntries=[0,0,0];\n'+derived+'\nexport const phase48EffectEntries=()=>$p48EffectEntries.slice();\n';parse(derived);
  const file=path.join(out,'candidate-effect-counter.mjs');fs.writeFileSync(file,derived,{flag:'wx'});
  report.derivative={module:identity(file),parent:report.modules[1].module,insertions,parser:{version:parserModule.exports.version,sha256:createHash('sha256').update(parserSource).digest('hex')},performanceEvidence:false};
  const witness=await import(pathToFileURL(file)),delta=before=>witness.phase48EffectEntries().map((x,i)=>x-before[i]);
  for(const [index,root]of rootNames.entries())for(const turns of [0,1,5]){const before=witness.phase48EffectEntries(),value=witness.default[root](turns,2),entries=delta(before),want=[0,0,0];want[index]=1;
    assert.deepEqual(entries,want);assert(Object.is(value,root==='integer'?integerOracle(turns,2):root==='converted'?convert(floatOracle(turns,2)):floatOracle(turns,2)));
    report.activation.push({root,turns,entries});}
  for(const label of ['fround','trunc','isNaN','isFinite','DataView','late-fill-fround','late-fill-helper']){
    const before=witness.phase48EffectEntries(),observation=hostile(witness,label),entries=delta(before);assert.deepEqual(entries,[0,0,0]);
    assert.deepEqual(observation,report.boundaries.find(x=>x.kind==='host'&&x.label===label).observations[1]);report.activation.push({host:label,entries});}
  assert.deepEqual(identity(file),report.derivative.module);for(const x of pinned.values())assert.deepEqual(identity(x.path),x);
  report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,(_k,v)=>typeof v==='bigint'?{$bigint:String(v)}:v,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,boundaries:report.boundaries.length,activation:report.activation.length,error:report.error}));
