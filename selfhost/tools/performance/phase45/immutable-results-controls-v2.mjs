// Small checked-output controller. Root owns compilation and bounded execution.
// Snapshot/hook discipline follows Phase43 callbacks/string-guard-controls-v2.mjs.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [baseline, candidate, typescript, output] = process.argv.slice(2);
assert(output, 'immutable-results-controls-v2.mjs BASELINE_MANIFEST CANDIDATE_MANIFEST TS_MANIFEST NEW_OUT');
const out = path.resolve(output); fs.mkdirSync(out);
const report = {kind:'phase45-immutable-results-controls',controllerVersion:2,complete:false,pass:false,
  scope:'Eight exact checked-source observations and finite public/host mutation differentials. No timing or universal conformance claim.',
  inputs:[],compilers:[],oracles:[],boundaries:[],rootShapes:[],activation:[]};
const json = p => JSON.parse(fs.readFileSync(p,'utf8'));
const identity = p => {const file=fs.realpathSync(p), bytes=fs.readFileSync(file);
  return {path:file,sha256:createHash('sha256').update(bytes).digest('hex'),bytes:bytes.length};};
const pinned = new Map();
function pin(p, expected) {
  const actual=identity(p);
  if(expected){assert.equal(actual.sha256,expected.sha256,p);if(expected.bytes!==undefined)assert.equal(actual.bytes,expected.bytes,p);}
  if(pinned.has(actual.path))assert.deepEqual(actual,pinned.get(actual.path));
  else {pinned.set(actual.path,actual);report.inputs.push(actual);}
  return actual;
}
function relative(root, entry) {
  assert(typeof entry.path==='string'&&!path.isAbsolute(entry.path)&&!entry.path.split('/').includes('..'));
  const file=fs.realpathSync(path.join(root,entry.path));
  assert(file.startsWith(fs.realpathSync(root)+path.sep));return pin(file,entry);
}
function snapshot(m) {
  const objects=[m.G];
  for(const d of Object.values(Object.getOwnPropertyDescriptors(m.G))){const f=d.value;
    if(f&&typeof f==='object')for(const o of [f,f.code,f.bound])
      if(o&&(typeof o==='function'||typeof o==='object'))objects.push(o);}
  const saved=[...new Set(objects)].map(o=>[o,Object.getOwnPropertyDescriptors(o),Object.getPrototypeOf(o)]);
  return ()=>{for(const [o,ds,proto] of saved){for(const k of Reflect.ownKeys(o))if(!Object.hasOwn(ds,k))delete o[k];
    Object.setPrototypeOf(o,proto);Object.defineProperties(o,ds);}};
}
function hook(object,key,descriptor,run) {
  const old=Object.getOwnPropertyDescriptor(object,key);
  try {Object.defineProperty(object,key,{configurable:true,...descriptor});return run();}
  finally {if(old)Object.defineProperty(object,key,old);else delete object[key];}
}
function observe(m,action) {
  const restore=snapshot(m),events=[];let value,error;
  try {value=action(m,events);assert(['string','number','boolean'].includes(typeof value));}
  catch(e){error={name:e.name,message:e.message};}
  finally {restore();}
  return {value,error,events};
}
try {
  pin(import.meta.filename);pin(process.execPath);
  const catalogFile=path.join(import.meta.dirname,'immutable-results-catalog.json');
  const catalogIdentity=pin(catalogFile),catalog=json(catalogFile);
  assert.equal(catalog.cases.length,8);
  const source=relative(import.meta.dirname,catalog.cases[0].source),modules=[],texts=[];
  const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};
  new Function('module','exports',parserSource)(parserModule,parserModule.exports);
  const parse=s=>parserModule.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
  for(const [index,manifestArg] of [baseline,candidate,typescript].entries()) {
    const role=['baseline','candidate','typescript'][index],manifestFile=pin(manifestArg),root=path.dirname(manifestFile.path),manifest=json(manifestFile.path);
    assert.equal(manifest.kind,'bend-program-bundle');assert.equal(manifest.schemaVersion,1);assert.equal(manifest.complete,true);
    assert.equal(manifest.catalogSha256,catalogIdentity.sha256);assert.equal(manifest.upstreamCommit,catalog.upstreamCommit);
    assert.deepEqual(Object.keys(manifest.roles),[role]);assert.equal(manifest.cases.length,8);
    const prepFile=relative(root,manifest.preparation),prep=json(prepFile.path);
    assert.equal(prep.kind,'bend-program-preparation');assert.equal(prep.complete,true);assert.equal(prep.sources.length,1);
    pin(prep.catalog.file??prep.catalog.path,prep.catalog);assert.equal(prep.catalog.sha256,catalogIdentity.sha256);
    for(const row of [prep.producer,prep.worker,prep.supervisor,prep.node,...prep.verifiers])pin(row.file??row.path,row);
    const emissionFile=relative(root,prep.sources[0].emission),emission=json(emissionFile.path);
    assert.equal(emission.kind,'bend-program-checked-emission');assert.equal(emission.complete,true);
    assert.equal(emission.observation.checked,true);assert.equal(emission.observation.status,'ok');
    pin(emission.input.file??emission.input.path,emission.input);assert.equal(emission.input.sha256,source.sha256);
    assert.equal(prep.sources[0].source.sha256,source.sha256);assert.equal(emission.catalog.sha256,catalogIdentity.sha256);
    assert.deepEqual(emission.compiler,manifest.roles[role].compiler);assert.equal(emission.compiler.upstreamCommit,catalog.upstreamCommit);
    if(role==='typescript') {
      assert.equal(emission.compiler.kind,'checked-pinned-typescript');
      for(const item of emission.compiler.sources)pin(item.file??item.path,item);
    } else {
      assert.equal(emission.compiler.kind,'checked-development-attempt');
      for(const key of ['api','runtime','base','driver']){const item=emission.compiler[key];pin(item.file??item.path,item);}
      const attemptFile=pin(emission.attempt.file??emission.attempt.path,emission.attempt),attempt=json(attemptFile.path);
      assert.equal(attempt.checked,true);
      for(const key of ['api','runtime','base'])assert.equal(attempt[key].sha256,emission.compiler[key].sha256);
    }
    let module;
    for(const item of catalog.cases) {
      const matches=manifest.cases.filter(c=>c.id===item.id);assert.equal(matches.length,1);const row=matches[0];
      assert.equal(row.sourceSha256,source.sha256);assert.deepEqual(row.point,item.point);assert.deepEqual(Object.keys(row.modules),[role]);
      const current=relative(root,row.modules[role]);assert.equal(current.sha256,emission.output.sha256);
      if(module)assert.deepEqual(current,module);else module=current;
    }
    const text=fs.readFileSync(module.path,'utf8');texts.push(text);
    const assignments=role==='typescript'?[]:parse(text).body.filter(n=>n.type==='ExpressionStatement').map(n=>n.expression)
      .filter(n=>n.type==='AssignmentExpression'&&n.operator==='='&&n.left.type==='MemberExpression'&&n.left.computed&&n.left.object.name==='G');
    if(role!=='typescript')for(const name of ['bench','selected','non_scalar_input','returned_closure']) {
      const matches=assignments.filter(n=>n.left.property.value===name);assert.equal(matches.length,1,'Root assignment '+name);
      const assignment=matches[0],contextual=text.slice(assignment.start,assignment.end).includes('/* private contextual instances */');
      if(['non_scalar_input','returned_closure'].includes(name))assert.equal(contextual,false,'Generic root admission: '+name);
      report.rootShapes.push({role,name,contextual});
    }
    report.compilers.push({role,manifest:manifestFile,module,emission:emissionFile,compiler:emission.compiler});
    modules.push(await import(pathToFileURL(module.path)));
  }
  for(const item of catalog.cases) {
    const {exportName,args,expected}=item.point;
    const values=modules.map((m,index)=>{let value=m.default[exportName](...args);
      if(item.observer){assert.equal(item.observer.kind,'returned-closure');
        value=index===2?value(...item.observer.args):m.call(value,item.observer.args);}
      assert.equal(value,expected,item.id);return value;});
    report.oracles.push({id:item.id,args,expected,values});
  }
  const marker='/* private contextual instances */';assert(!texts[1].includes('$p45ImmutableEntries'));
  const markerCount=texts[1].split(marker).length-1;assert(markerCount>0,'Candidate has no contextual worker');
  const derivative='let $p45ImmutableEntries=0;\n'+texts[1].replaceAll(marker,marker+'++$p45ImmutableEntries;')+
    '\nexport const p45ImmutableEntries=()=>$p45ImmutableEntries;\n';parse(derivative);
  const derivativeFile=path.join(out,'candidate-counter.mjs');fs.writeFileSync(derivativeFile,derivative,{flag:'wx'});
  report.derivative={module:identity(derivativeFile),source:report.compilers[1].module,markerCount,
    transformation:'Add one private numeric counter and increment inside each contextual entry; keep clean observations separate.',performanceEvidence:false,
    parser:{version:parserModule.exports.version,sha256:createHash('sha256').update(parserSource).digest('hex')}};
  const witness=await import(pathToFileURL(derivativeFile));
  for(const item of catalog.cases){const before=witness.p45ImmutableEntries(),{exportName,args,expected}=item.point;
    let value=witness.default[exportName](...args);if(item.observer)value=witness.call(value,item.observer.args);
    const entries=witness.p45ImmutableEntries()-before,expectedEntries=['bench','selected'].includes(exportName)?1:0;
    assert.equal(value,expected);assert.equal(entries,expectedEntries,item.id+' actual activation');
    report.activation.push({id:item.id,value,expected,entries,expectedEntries});}
  const bends=modules.slice(0,2);
  function boundary(name,action,{live=false,throws=false}={}) {
    const observations=bends.map(m=>observe(m,action));report.current={name,observations};
    assert.deepEqual(observations[1],observations[0],name);
    if(throws)assert(observations[0].error,name+' must throw');else assert.equal(observations[0].error,undefined,name);
    if(live)assert(observations[0].events.length,name+' must observe the hook');
    report.boundaries.push(report.current);delete report.current;
  }
  for(const [root,names,args] of [['bench',['text.values','text.render','U32.show','String.append'],[3,7]],['selected',['text.maybe','Maybe.default'],[true,7]]])
    for(const name of names)for(const mode of ['code','binding','code-getter','own-call','call-getter'])
      boundary(root+':'+name+':'+mode,(m,e)=>{const f=m.G[name],code=f.code;assert.equal(typeof code,'function');
        if(mode==='code')f.code=function(a){e.push(name);return Reflect.apply(code,this,[a]);};
        if(mode==='binding')Object.defineProperty(m.G,name,{configurable:true,get(){e.push(name);return f;}});
        if(mode==='code-getter')Object.defineProperty(f,'code',{configurable:true,get(){e.push(name);return code;}});
        const call=function(env,a){e.push('call:'+name);return Reflect.apply(code,env,[a]);};
        if(mode==='own-call')Object.defineProperty(code,'call',{configurable:true,value:call});
        if(mode==='call-getter')Object.defineProperty(code,'call',{configurable:true,get(){e.push('get-call:'+name);return call;}});
        return m.default[root](...args);},{live:true});
  for(const [label,object,key] of [['String',String,'fromCodePoint'],['String.prototype',String.prototype,'codePointAt'],['String.prototype',String.prototype,'slice']])
    for(const mode of ['wrapper','getter','throw'])boundary(label+':'+key+':'+mode,(m,e)=>{
      const original=object[key];let hits=0;
      const changed=function(...a){hits++;if(mode==='throw')throw Error('String hook sentinel');return Reflect.apply(original,this,a);};
      let result;try{result=hook(object,key,mode==='getter'?{get(){hits++;return original;}}:{value:changed},()=>m.default.bench(3,7));}
      catch(error){e.push(['String-error',error.name,error.message]);return 'caught';}
      finally{e.push(['hits',hits]);}return result;
    });
  boundary('String-prototype-bounce',(m,e)=>{let hits=0,result;
    try{result=hook(String.prototype,'bounce',{get(){hits++;return undefined;}},()=>m.default.bench(3,7));}
    finally{e.push(['hits',hits]);}assert(hits>0);return result;});
  boundary('Function-prototype-call',(m,e)=>{const original=Function.prototype.call;let hits=0,result;
    try{result=hook(Function.prototype,'call',{value:function(...a){hits++;return Reflect.apply(original,this,a);}},()=>m.default.bench(3,7));}
    finally{e.push(['hits',hits]);}assert(hits>0);return result;});
  boundary('helper-error-identity',(m,e)=>{const token=new Error('helper sentinel');m.G['text.values'].code=()=>{e.push('values');throw token;};
    try{m.default.bench(3,7);assert.fail('Expected helper error');}catch(error){assert.equal(error,token);e.push('same-error');}return 'caught';},{live:true});
  boundary('helper-reentry',(m,e)=>{const code=m.G['text.render'].code;let active=false;
    m.G['text.render'].code=function(a){if(!active){active=true;e.push(m.default.selected(true,2));active=false;}return Reflect.apply(code,this,[a]);};
    return m.default.bench(3,7);},{live:true});
  boundary('retained-closure-reuse',(m,e)=>{const f=m.default.returned_closure(4294967295);
    for(const value of [1,7,1])e.push(m.call(f,[value]));assert.deepEqual(e,['0','6','0']);return 'retained';},{live:true});
  assert.equal(report.oracles.length,8);
  for(const item of pinned.values())assert.deepEqual(identity(item.path),item,'Input changed');
  assert.deepEqual(identity(derivativeFile),report.derivative.module,'Derivative changed');
  report.complete=report.pass=true;
} catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,boundaries:report.boundaries.length,activation:report.activation.length,error:report.error}));
