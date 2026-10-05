// Independent, untimed array lifetime/observation controls. No source rewriting.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseline,candidate,output]=process.argv.slice(2);
assert(output,'array-view-controls-v1.mjs BASELINE_MODULE CANDIDATE_MODULE NEW_OUT');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase47-independent-array-view-controls',complete:false,pass:false,inputs:[],modules:[],oracles:[],boundaries:[],
  scope:'Exact predecessor/candidate selfhost values, errors, storage and post-import events. No timing or activation claim.'};
const pinned=new Map(),apply=Reflect.apply,define=Object.defineProperty,descriptor=Object.getOwnPropertyDescriptor;
const OriginalNumber=Number,OriginalArray=Array,OriginalError=Error;
const identity=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {path:file,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};};
function pin(file,want){const x=identity(file);if(want){assert.equal(x.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(x.bytes,want.bytes);}
  if(pinned.has(x.path))assert.deepEqual(x,pinned.get(x.path));else{pinned.set(x.path,x);report.inputs.push(x);}return x;}
function audit(v){if(OriginalArray.isArray(v))v.forEach(audit);else if(v&&typeof v==='object'){
  const file=v.path??v.file??v.canonicalPath;if(typeof file==='string'&&v.sha256)pin(file,v);Object.values(v).forEach(audit);}}
function expected(n,seed){const cells=[seed,seed,seed,seed];let acc=0;for(let i=0;i<n;i++){acc=(acc+cells[i%4]+1)>>>0;cells[i%4]=(acc^i)>>>0;}return {cells,acc};}
const thrown=e=>({type:typeof e,name:e?.name??null,message:e?.message??String(e)});
function scenario(m,label){
  const events=[],restores=[],storage=[2,3,5,7];let a={array:storage},value,error,escaped;
  const patch=(owner,key,desc)=>{const old=descriptor(owner,key);restores.push(()=>old?define(owner,key,old):delete owner[key]);define(owner,key,{configurable:true,...desc});};
  const run=(n=5)=>m.default.external(BigInt(n),a);
  const wrapNumber=(throws=false)=>{const wrapped=function(v){events.push(['Number',typeof v,String(v)]);if(throws)throw new OriginalError('conversion sentinel');return OriginalNumber(v);};
    // Preserve numeric static helpers so a global replacement isolates conversion.
    Object.setPrototypeOf(wrapped,OriginalNumber);patch(globalThis,'Number',{writable:true,value:wrapped});};
  try{
    if(label==='zero-malformed'){a={get array(){events.push('array');throw new OriginalError('zero demand');}};value=run(0);assert.equal(value,0);assert.deepEqual(events,[]);}
    else if(label==='unused-read-error'){a={get array(){events.push('array');throw new OriginalError('unused read');}};value=m.default.ignored_read(a);}
    else if(label==='handle-getter'){a={get array(){events.push('array');return storage;}};value=run();}
    else if(label==='backing-proxy'){a={array:new Proxy(storage,{get(t,k,r){events.push(['get',String(k)]);return Reflect.get(t,k,r);},set(t,k,v,r){events.push(['set',String(k),v]);return Reflect.set(t,k,v,r);}})};value=run();}
    else if(label==='changing-backing'){let reads=0;const other=[11,13];a={get array(){events.push(['array',++reads]);return reads<5?storage:other;}};value=run();escaped=other.slice();}
    else if(label==='malformed'){a={};value=run(1);}
    else if(label==='empty'){a={array:[]};value=run(2);escaped={length:a.array.length,nan:a.array.NaN};}
    else if(label==='aliases'||label==='distinct'){const other=label==='aliases'?storage:[11,13,17,19];value=m.default.aliases(a,{array:other});assert.equal(value,label==='aliases'?19:2);escaped=other.slice();}
    else if(label==='returned-storage'){const pair=m.default.escaped(9,3),want=expected(9,3);assert.deepEqual(pair[0].array,want.cells);assert.equal(pair[1],want.acc);
      pair[0].array[0]=41;value=m.default.external(1n,pair[0]);assert.equal(value,42);escaped=pair[0].array.slice();}
    else if(label.startsWith('Number-')){const root=label.endsWith('-public')?()=>run(3):()=>m.default.bench(3,2);
      if(label.includes('getter'))patch(globalThis,'Number',{get(){events.push('Number:get');return OriginalNumber;}});else wrapNumber(label.includes('throw'));value=root();}
    else if(label.startsWith('fill-')){
      const fill=OriginalArray.prototype.fill;let busy=false;
      patch(OriginalArray.prototype,'fill',{writable:true,value:function(...args){
        events.push('fill');if(label==='fill-throw')throw new OriginalError('fill sentinel');
        const filled=apply(fill,this,args);escaped=filled;
        if(label==='fill-reentry'&&!busy){busy=true;events.push(['nested',m.default.bench(0,5)]);busy=false;}
        if(label==='fill-replaces-Number'){
          let count=0;const wrapped=function(v){events.push(['late-Number',typeof v,String(v)]);if(++count===1)filled.length=2;return OriginalNumber(v);};
          Object.setPrototypeOf(wrapped,OriginalNumber);patch(globalThis,'Number',{writable:true,value:wrapped});
        }
        return label==='fill-proxy'?new Proxy(filled,{get(t,k,r){events.push(['get',String(k)]);return Reflect.get(t,k,r);},set(t,k,v,r){events.push(['set',String(k),v]);return Reflect.set(t,k,v,r);}}):filled;
      }});value=m.default.bench(label==='fill-zero'?0:5,2);
    }
    else if(label==='safe-integer'){const safe=OriginalNumber.isSafeInteger;patch(OriginalNumber,'isSafeInteger',{writable:true,value:function(v){events.push('safe-integer');return safe(v);}});value=m.default.bench(3,2);}
    else if(label.startsWith('opaque-')){
      if(label==='opaque-throw')a={get array(){events.push('array-before-callback');return storage;}};
      const callback={arity:1,env:null,bound:[],code:function(args){events.push(['callback',args[0]]);
        if(label==='opaque-throw')throw new OriginalError('callback sentinel');
        if(label==='opaque-resize')storage.length=2;else a.array=[11,13];return 10;}};
      value=m.default.opaque(a,5,callback);assert.equal(value,label==='opaque-resize'?14:24);escaped=a.array.slice();
    }
    else if(label.startsWith('native-')||label==='source-cell'){
      const name=label==='source-cell'?'seam.cell':label.includes('-set')?'Array.set':'Array.get',f=m.G[name];assert(f,'Missing '+name);
      const code=f.code;
      if(label==='native-get-global')patch(m.G,name,{get(){events.push(name+':global');return f;}});
      else if(label==='native-get-call')patch(code,'call',{writable:true,value:function(env,args){events.push(name+':call');return apply(code,env,[args]);}});
      else if(label==='native-get-code-getter')patch(f,'code',{get(){events.push(name+':code-get');return code;}});
      else patch(f,'code',{writable:true,value:function(args){events.push(name+':code');if(label==='native-get-throw')throw new OriginalError('read sentinel');return apply(code,this,[args]);}});
      value=m.default.bench(5,2);
    }else throw new OriginalError('Unknown control '+label);
  }catch(e){error=thrown(e);}
  finally{for(let i=restores.length-1;i>=0;i--)restores[i]();}
  // Snapshot after restoring hooks; no controller reads inflate hook events.
  const result={value,error,events,storage:storage.slice(),escaped:OriginalArray.isArray(escaped)?escaped.slice():escaped};
  if(['unused-read-error','malformed','Number-throw-public','fill-throw','opaque-throw','native-get-throw'].includes(label))assert(error,label+' must throw');
  else assert.equal(error,undefined,label+' unexpected error');
  if(label==='opaque-throw')assert.deepEqual(events,[['callback',5]],'Callback must throw before storage demand');
  if(!['zero-malformed','malformed','empty','aliases','distinct','returned-storage'].includes(label))assert(events.length,label+' must witness observation');
  return result;
}
try{
  pin(import.meta.filename);pin(process.execPath);fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
  const catalogId=pin(path.join(import.meta.dirname,'array-view-catalog-v1.json')),catalog=JSON.parse(fs.readFileSync(catalogId.path,'utf8'));
  const source=pin(path.join(import.meta.dirname,catalog.cases[0].source.path),catalog.cases[0].source),modules=[];
  for(const [i,file]of [baseline,candidate].entries()){
    const module=pin(file),receipt=pin(module.path+'.json'),r=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(r.kind,'bend-program-checked-emission');assert.equal(r.complete,true);assert.equal(r.observation.checked,true);assert.equal(r.observation.status,'ok');
    assert.equal(r.output.sha256,module.sha256);assert.equal(r.input.sha256,source.sha256);assert.equal(r.catalog.sha256,catalogId.sha256);
    assert.equal(r.compiler.upstreamCommit,catalog.upstreamCommit);assert(['checked-development-attempt','installed-checked-release'].includes(r.compiler.kind));audit(r);
    report.modules.push({role:i?'candidate':'baseline',module,receipt,compiler:r.compiler});modules.push(await import(pathToFileURL(module.path)));
  }
  for(const n of [0,1,4,5,9,33])for(const seed of [0,1,17,4294967295]){const want=expected(n,seed).acc,values=modules.map(m=>m.default.bench(n,seed));
    for(const value of values)assert.equal(value,want);report.oracles.push({n,seed,expected:want,values});}
  const cases=['zero-malformed','unused-read-error','handle-getter','backing-proxy','changing-backing','malformed','empty','aliases','distinct','returned-storage',
    'Number-wrapper-public','Number-wrapper-closed','Number-getter-public','Number-getter-closed','Number-throw-public',
    'fill-zero','fill-proxy','fill-throw','fill-reentry','fill-replaces-Number','safe-integer',
    'opaque-resize','opaque-replace','opaque-throw','native-get-global','native-get-call','native-get-code-getter','native-get-code','native-get-throw','native-set-code','source-cell'];
  for(const name of cases){const observations=modules.map(m=>scenario(m,name));assert.deepEqual(observations[1],observations[0],name);report.boundaries.push({name,observations});}
  for(const x of pinned.values())assert.deepEqual(identity(x.path),x);
  report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,(_k,v)=>typeof v==='bigint'?{$bigint:String(v)}:v,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,boundaries:report.boundaries.length,error:report.error}));
