// Finite boundary checks on actual checked record-aggregation modules; no timing.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [baselineFile,candidateFile,output] = process.argv.slice(2);
assert(output,'record-result-controls-v2.mjs BASELINE_MODULE CANDIDATE_MODULE NEW_OUT');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase45-record-result-controls',controllerVersion:2,complete:false,pass:false,
  activationCorrection:'Version1 required one contextual entry across the entire module. Version2 requires one bench assignment and one contextual entry inside it; other admitted public roots remain uninstrumented.',
  scope:'Actual checked-module differential boundaries plus a separately instrumented activation witness. No timing or universal conformance claim.',
  inputs:[],modules:[],oracles:[],boundaries:[],activation:[]};
const identity=p=>{const file=fs.realpathSync(p),bytes=fs.readFileSync(file);
  return {path:file,sha256:createHash('sha256').update(bytes).digest('hex'),bytes:bytes.length};};
const pinned=new Map();
function pin(file,expected) {
  const got=identity(file);if(expected){assert.equal(got.sha256,expected.sha256);if(expected.bytes!==undefined)assert.equal(got.bytes,expected.bytes);}
  if(pinned.has(got.path))assert.deepEqual(got,pinned.get(got.path));
  else {pinned.set(got.path,got);report.inputs.push(got);}return got;
}
function audit(value) {
  if(Array.isArray(value))for(const x of value)audit(x);
  else if(value&&typeof value==='object') {
    const file=value.file??value.path;if(typeof file==='string'&&value.sha256)pin(file,value);
    for(const x of Object.values(value))audit(x);
  }
}
function restorePoint(m) {
  const objects=[m.G];
  for(const d of Object.values(Object.getOwnPropertyDescriptors(m.G)))if(d.value&&typeof d.value==='object')
    for(const o of [d.value,d.value.code,d.value.bound])if(o&&(typeof o==='object'||typeof o==='function'))objects.push(o);
  const saved=[...new Set(objects)].map(o=>[o,Object.getOwnPropertyDescriptors(o),Object.getPrototypeOf(o)]);
  return ()=>{for(const [o,ds,proto] of saved){for(const k of Reflect.ownKeys(o))if(!Object.hasOwn(ds,k))delete o[k];
    Object.setPrototypeOf(o,proto);Object.defineProperties(o,ds);}};
}
function hook(object,key,descriptor,run) {
  const old=Object.getOwnPropertyDescriptor(object,key);
  try{Object.defineProperty(object,key,{configurable:true,...descriptor});return run();}
  finally{if(old)Object.defineProperty(object,key,old);else delete object[key];}
}
function observe(m,action) {
  const restore=restorePoint(m),events=[];let value,error;
  try{value=action(m,events);assert.equal(typeof value,'string');}
  catch(e){error={name:e.name,message:e.message};}
  finally{restore();}return {value,error,events};
}
const specs=[];
function boundary(name,action,options={}){specs.push({name,action,live:false,throws:false,refuses:true,...options});}
try {
  pin(import.meta.filename);pin(process.execPath);report.previousController=pin(path.join(import.meta.dirname,'record-result-controls.mjs'));
  const modules=[],texts=[];
  for(const [index,file] of [baselineFile,candidateFile].entries()) {
    const module=pin(file),receipt=pin(module.path+'.json'),emission=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(emission.kind,'bend-program-checked-emission');assert.equal(emission.complete,true);
    assert.equal(emission.observation.status,'ok');assert.equal(emission.observation.checked,true);
    assert.equal(emission.output.sha256,module.sha256);assert.equal(emission.compiler.kind,'checked-development-attempt');
    audit(emission);
    if(index)assert.equal(emission.input.sha256,report.modules[0].source.sha256);
    report.modules.push({role:index?'candidate':'baseline',module,receipt,source:emission.input,compiler:emission.compiler});
    texts.push(fs.readFileSync(module.path,'utf8'));modules.push(await import(pathToFileURL(module.path)));
  }
  const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};
  new Function('module','exports',parserSource)(parserModule,parserModule.exports);
  const parse=text=>parserModule.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});
  function nodes(root){const pending=[root],result=[];while(pending.length){const n=pending.pop();if(!n||typeof n!=='object'||typeof n.type!=='string')continue;
    result.push(n);for(const v of Object.values(n))if(Array.isArray(v))pending.push(...v);else if(v&&typeof v==='object')pending.push(v);}return result;}
  const marker='/* private contextual instances */',selected=[];
  for(const [i,text]of texts.entries()){
    const found=nodes(parse(text)).filter(n=>n.type==='AssignmentExpression'&&n.operator==='='&&n.left.type==='MemberExpression'&&n.left.computed&&
      n.left.object.type==='Identifier'&&n.left.object.name==='G'&&n.left.property.type==='Literal'&&n.left.property.value==='bench');
    assert.equal(found.length,1,'Expected one complete bench assignment');const n=found[0],body=text.slice(n.right.start,n.right.end);
    assert.equal(body.split(marker).length-1,i,'Expected selected bench contextual admission');
    selected.push({role:i?'candidate':'baseline',assignment:{start:n.start,end:n.end},rhs:{start:n.right.start,end:n.right.end},
      entryOffset:i?n.right.start+body.indexOf(marker)+marker.length:null});
  }
  assert(!texts[1].includes('$p45RecordEntries'),'Reserved diagnostic identifier');
  const offset=selected[1].entryOffset,derived=path.join(out,'candidate-counter.mjs');
  const derivativeText='let $p45RecordEntries=0;\n'+texts[1].slice(0,offset)+'++$p45RecordEntries;'+texts[1].slice(offset)+
    '\nexport const p45RecordEntries=()=>$p45RecordEntries;\n';parse(derivativeText);
  fs.writeFileSync(derived,derivativeText,{flag:'wx'});
  report.derivative={module:identity(derived),source:report.modules[1].module,selected,
    parser:{version:parserModule.exports.version,sha256:createHash('sha256').update(parserSource).digest('hex')},
    transformation:'Prefix a private numeric counter, increment inside the unique contextual branch of the complete bench assignment, export a read-only counter accessor.',performanceEvidence:false};
  const witness=await import(pathToFileURL(derived));
  const exact=[[[0,7],''],[[1,7],'部門7=7;'],[[3,7],'部門7=7;部門8=44;部門9=81;'],[[3,15],'部門0=52;部門1=89;部門15=15;']];
  for(const [args,expected] of exact) {
    const values=modules.map(m=>m.default.bench(...args));assert.deepEqual(values,[expected,expected]);
    const before=witness.p45RecordEntries(),value=witness.default.bench(...args),entries=witness.p45RecordEntries()-before;
    assert.equal(value,expected);assert.equal(entries,1,'Selected worker did not activate');
    report.oracles.push({args,expected,values});report.activation.push({name:'unmodified',args,entries,value});
  }
  for(const name of ['p37.records','p37.aggregate','p37.render','Map.set','Map.get','String.append'])
    for(const mode of ['code','global-getter','code-getter','env-getter','env-value','own-call','call-getter'])
      boundary(name+':'+mode,(m,e)=>{const f=m.G[name],code=f.code;assert.equal(typeof code,'function');
        if(mode==='code')f.code=function(a){e.push(name);return Reflect.apply(code,this,[a]);};
        if(mode==='global-getter')Object.defineProperty(m.G,name,{configurable:true,get(){e.push(name);return f;}});
        if(mode==='code-getter')Object.defineProperty(f,'code',{configurable:true,get(){e.push(name);return code;}});
        if(mode==='env-getter')Object.defineProperty(f,'env',{configurable:true,get(){e.push('env:'+name);return null;}});
        if(mode==='env-value')f.env={sentinel:true};
        const call=function(env,a){e.push('call:'+name);return Reflect.apply(code,env,[a]);};
        if(mode==='own-call')Object.defineProperty(code,'call',{configurable:true,value:call});
        if(mode==='call-getter')Object.defineProperty(code,'call',{configurable:true,get(){e.push('get-call:'+name);return call;}});
        return m.default.bench(3,7);},{live:mode!=='env-value'});
  for(const [object,key] of [[String,'fromCodePoint'],[String.prototype,'codePointAt'],[String.prototype,'slice']])
    for(const mode of ['wrapper','getter','throw'])boundary('String:'+key+':'+mode,(m,e)=>{
      const original=object[key];let hits=0,result;
      const wrapped=function(...args){hits++;if(mode==='throw')throw Error('String sentinel');return Reflect.apply(original,this,args);};
      try{result=hook(object,key,mode==='getter'?{get(){hits++;return original;}}:{value:wrapped},()=>m.default.bench(3,7));}
      catch(error){e.push(['caught',error.name,error.message]);result='caught';}
      finally{e.push(['hits',hits]);}assert(hits>0);return result;
    });
  boundary('String-prototype-bounce',(m,e)=>{let hits=0,result;
    try{result=hook(String.prototype,'bounce',{get(){hits++;return undefined;}},()=>m.default.bench(3,7));}
    finally{e.push(['hits',hits]);}assert(hits>0);return result;},{live:true});
  boundary('Function-prototype-call',(m,e)=>{const original=Function.prototype.call;let hits=0,result;
    try{result=hook(Function.prototype,'call',{value:function(...args){hits++;return Reflect.apply(original,this,args);}},()=>m.default.bench(3,7));}
    finally{e.push(['hits',hits]);}assert(hits>0);return result;},{live:true});
  boundary('helper-error-identity',(m,e)=>{const token=new Error('record helper sentinel');
    m.G['p37.records'].code=()=>{e.push('records');throw token;};
    try{m.default.bench(3,7);assert.fail('Expected helper error');}catch(error){assert.equal(error,token);e.push('same-error');}return 'caught';},{live:true});
  boundary('helper-reentry',(m,e)=>{const f=m.G['p37.records'],code=f.code;let active=false;
    f.code=function(a){if(!active){active=true;e.push(m.default.bench(0,7));active=false;}return Reflect.apply(code,this,[a]);};
    return m.default.bench(3,7);},{live:true});
  for(const reenter of [false,true])boundary('Error-constructor'+(reenter?'-reentry':''),(m,e)=>{
    const OriginalError=Error,f=m.G['p37.records'],code=f.code;let active=false;
    f.code=()=>m.call(17,[0]);
    return hook(globalThis,'Error',{value:function(...args){e.push(['Error',args[0]]);
      if(reenter&&!active){active=true;const changed=f.code;f.code=code;
        try{e.push(['reentry',m.default.bench(0,7)]);}finally{f.code=changed;active=false;}}
      return Reflect.apply(OriginalError,this,args);}},()=>m.default.bench(3,7));
  },{live:true,throws:true,refuses:!reenter});
  for(const spec of specs) {
    const observations=modules.map(m=>observe(m,spec.action));report.current={name:spec.name,observations};
    assert.deepEqual(observations[1],observations[0],spec.name);
    if(spec.throws)assert(observations[0].error,spec.name+' must throw');else assert.equal(observations[0].error,undefined,spec.name);
    if(spec.live)assert(observations[0].events.length,spec.name+' hook must be observed');
    report.boundaries.push(report.current);delete report.current;
  }
  // Derivative executions establish entry/refusal only; production comparisons above are separate.
  for(const spec of specs) {
    const before=witness.p45RecordEntries(),observation=observe(witness,spec.action),entries=witness.p45RecordEntries()-before;
    assert.deepEqual(observation,report.boundaries.find(row=>row.name===spec.name).observations[1],spec.name+' derivative behavior');
    assert.equal(entries,spec.refuses?0:1,spec.name+' entry/refusal');
    report.activation.push({name:spec.name,entries,refused:spec.refuses});
  }
  for(const item of pinned.values())assert.deepEqual(identity(item.path),item,'Input changed');
  assert.deepEqual(identity(derived),report.derivative.module,'Derivative changed');
  report.complete=report.pass=true;
} catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,boundaries:report.boundaries.length,activation:report.activation.length,error:report.error}));
