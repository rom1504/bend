// Untimed exact-entry host-hook diagnostic; the raw ordinary root is the anchor.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseline,candidate,output]=process.argv.slice(2);
assert(output,'exact-entry-host-hooks-controls-v1.mjs BASELINE_NULLARY_MODULE CANDIDATE_NULLARY_MODULE NEW_OUT');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase45-exact-entry-host-hooks',complete:false,pass:false,inputs:[],modules:[],observations:[],
  scope:'Supported post-import hooks, with an ordinary raw root call as semantic anchor. Historical runtime preflight hook observations are recorded, not required to survive a repair. No timing claim.'};
const identity=file=>{file=fs.realpathSync(file);const bytes=fs.readFileSync(file);return {path:file,bytes:bytes.length,sha256:createHash('sha256').update(bytes).digest('hex')};};
const pinned=new Map();
function pin(file,want){const row=identity(file);if(want){assert.equal(row.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(row.bytes,want.bytes);}if(pinned.has(row.path))assert.deepEqual(row,pinned.get(row.path));else{pinned.set(row.path,row);report.inputs.push(row);}return row;}
function audit(v){if(Array.isArray(v))v.forEach(audit);else if(v&&typeof v==='object'){const file=v.path??v.file??v.canonicalPath;if(typeof file==='string'&&v.sha256)pin(file,v);Object.values(v).forEach(audit);}}
// Keep the controller's own observation/restoration outside modified hooks.
const apply=Reflect.apply,descriptor=Object.getOwnPropertyDescriptor,define=Object.defineProperty;
const modes=[
  ['Reflect.apply',Reflect,'apply'],
  ['Object.getPrototypeOf',Object,'getPrototypeOf'],
  ['Object.getOwnPropertyDescriptor',Object,'getOwnPropertyDescriptor'],
  ['Object.hasOwn',Object,'hasOwn'],
  ['WeakSet.has',WeakSet.prototype,'has'],
  ['Reflect.apply getter',Reflect,'apply'],
];
function observe(m,mode,ordinary){
  const [label,owner,key]=mode,original=descriptor(owner,key),helper=descriptor(m.G,'demand.left');
  const root=m.G.bench,code=root.code,env=root.env,events=[];let inBody=false,value,error;
  assert(original&&Object.hasOwn(original,'value'));assert(helper&&Object.hasOwn(helper,'value'));
  try{
    // This getter separates root entry from ordinary source/helper execution.
    // It also forces any private graph to refuse, independently of hook choice.
    define(m.G,'demand.left',{configurable:helper.configurable,enumerable:helper.enumerable,get(){inBody=true;events.push('source:left');return helper.value;}});
    if(label==='Reflect.apply getter')define(owner,key,{configurable:original.configurable,enumerable:original.enumerable,get(){if(!inBody)events.push(label);return original.value;}});
    else define(owner,key,{...original,value:function(...args){
      const isRoot=label==='Reflect.apply'?args[0]===code:
        label==='Object.getPrototypeOf'?args[0]===code:
        label==='Object.getOwnPropertyDescriptor'?args[0]===code&&args[1]==='call':
        label==='WeakSet.has'?args[0]===code:args[1]==='value';
      if(!inBody&&isRoot)events.push(label);
      return apply(original.value,this,args);
    }});
    // Invoke the original source body directly in the anchor lane, then demand
    // its tail message. This bypasses only the runtime's exact-entry preflight.
    value=ordinary?m.call(code.call(env,[]),[]):m.default.bench();
  }catch(e){error={name:e.name,message:e.message};}
  finally{define(owner,key,original);define(m.G,'demand.left',helper);}
  return {value,error,events};
}
try{
  pin(import.meta.filename);pin(process.execPath);
  const catalogId=pin(path.join(import.meta.dirname,'nullary-demand21-catalog-v2.json')),catalog=JSON.parse(fs.readFileSync(catalogId.path,'utf8'));
  assert.equal(catalog.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
  const source=pin(path.join(import.meta.dirname,catalog.cases[0].source.path),catalog.cases[0].source),modules=[];
  for(const [i,file]of [baseline,candidate].entries()){
    const module=pin(file),receipt=pin(module.path+'.json'),r=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(r.kind,'bend-program-checked-emission');assert.equal(r.complete,true);assert.equal(r.observation.checked,true);assert.equal(r.observation.status,'ok');
    assert.equal(r.output.sha256,module.sha256);assert.equal(r.input.sha256,source.sha256);assert.equal(r.catalog.sha256,catalogId.sha256);
    assert.equal(r.compiler.kind,'checked-development-attempt');assert.equal(r.compiler.upstreamCommit,catalog.upstreamCommit);audit(r);
    report.modules.push({role:i?'candidate':'baseline',module,receipt,compiler:r.compiler});modules.push(await import(pathToFileURL(module.path)));
  }
  for(const m of modules)assert.equal(m.default.bench(),81);
  let agreement=true;
  for(const mode of modes){
    const ordinary=observe(modules[0],mode,true),old=observe(modules[0],mode,false),current=observe(modules[1],mode,false);
    for(const observation of [ordinary,old,current]){assert.equal(observation.error,undefined);assert.equal(observation.value,81);}
    assert.deepEqual(ordinary.events,['source:left','source:left'],'Ordinary body has no root preflight hook');
    const equal=(a,b)=>JSON.stringify(a)===JSON.stringify(b),candidateMatchesOrdinary=equal(current,ordinary);
    report.observations.push({mode:mode[0],ordinary,baseline:old,candidate:current,baselineMatchesOrdinary:equal(old,ordinary),candidateMatchesOrdinary,historicalDifferentialEqual:equal(old,current)});
    agreement&&=candidateMatchesOrdinary;
  }
  for(const row of pinned.values())assert.deepEqual(identity(row.path),row);
  report.complete=true;report.pass=agreement;report.inputsUnchanged=true;if(!agreement)process.exitCode=1;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,observations:report.observations.length,error:report.error}));
