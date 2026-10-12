// Root-only checked Bend analysis query. Never emits C or runs a native target.
// node query-plans-v1.mjs CHECKED_API INPUT_BEND FRESH_PHASE70_OUT [CANONICAL_DEF ...]
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {fileURLToPath,pathToFileURL} from 'node:url';
const [apiArg,inputArg,outArg,...requested]=process.argv.slice(2);
assert(apiArg&&inputArg&&outArg,'CHECKED_API INPUT_BEND FRESH_PHASE70_OUT [CANONICAL_DEF ...]');
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'../../../../..');
const api=fs.realpathSync(apiArg),input=fs.realpathSync(inputArg),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase70')+path.sep)&&!fs.existsSync(out),'fresh Phase70 output required');
const wanted=requested.length?requested:['Map.bit.go','String.cmp'];
assert(wanted.length<=16&&new Set(wanted).size===wanted.length,'at most 16 distinct exact names');
const hash=bytes=>createHash('sha256').update(bytes).digest('hex');
const pin=file=>{const bytes=fs.readFileSync(file);return{file:fs.realpathSync(file),sha256:hash(bytes),bytes:bytes.length};};
const driver=path.join(root,'selfhost/tools/typed-driver.mjs');
const base=path.join(root,'selfhost/dist/base.bend');
const runtime=path.join(root,'selfhost/src/runtime.mjs');
const nativeRuntime=path.join(root,'selfhost/src/runtime/native/runtime.c');
const original=fs.readFileSync(api),source=original.toString('utf8');
for(const name of ['no_observer_plan','lookup','dk','nd_arity','tg','nm','ix','qt','ks','rm'])
  assert(source.includes('function $'+name+'$('),'missing compiled Bend helper '+name);
const suffix=String.raw`
export function phase70QueryObserverPlans(book,names,onProgress,onResult) {
  const c=(f,...args)=>run_loop(f(...args));
  function check(ok,msg){if(!ok)throw Error(msg);}
  function array(xs){const out=[];while(xs?.$==='Con'){out.push(xs.head);xs=xs.tail;check(out.length<=20000,'query list budget');}check(xs?.$==='Nil','malformed compiler list');return out;}
  function uint(x){check(Number.isInteger(x)&&x>=0&&x<=4294967295,'invalid U32 field');return x;}
  function text(x){check(typeof x==='string','invalid string field');return x;}
  for(const name of names) {
    const definition=c($lookup$,book,name);
    check(c($dk$,definition)==='Def','missing exact requested definition '+name);
    const arity=c($nd_arity$,book,name);
    for(const permission of [false,true]) {
      onProgress({name,permission});
      const started=performance.now();
      const p=c($no_observer_plan$,book,name,permission);
      const elapsedMs=performance.now()-started;
      const s=p.schema,a=p.analysis;
      let remaining=150000;
      function term(t,depth=0){check(--remaining>=0&&depth<=512,'query term serialization budget');return{tag:c($tg$,t),name:c($nm$,t),id:c($ix$,t),quant:c($qt$,t),kids:array(c($ks$,t)).map(k=>term(k,depth+1)),removed:array(c($rm$,t))};}
      function layout(l){return{key:text(l.key),ctor:text(l.ctor),storage:text(l.storage),width:uint(l.width)};}
      function spec(x){return{layout:layout(x.layout),owner:text(x.owner),fields:array(x.fields).map(text)};}
      const record={requested:name,permission,arity,elapsedMs,owner:text(p.owner),error:text(p.error),
        schema:{params:array(s.params).map(x=>term(x)),roots:array(s.roots).map(uint),wrapper:term(s.wrapper),result:uint(s.result),observation:text(s.observation),specs:array(s.specs).map(spec),fresh:uint(s.fresh),error:text(s.error)},
        analysis:{body:term(a.body),fresh:uint(a.fresh),fuel:uint(a.fuel),error:text(a.error)}};
      record.visitedNodes=150000-remaining;
      record.accepted=record.error===''&&record.schema.error===''&&record.analysis.error==='';
      check(record.owner===name,'plan owner changed');
      onResult(record);
      check(permission||!record.accepted,'false permission unexpectedly accepted');
    }
  }
}
`;
fs.mkdirSync(out,{recursive:true});
const derived=path.join(out,'query-api.mjs'),derivedBytes=Buffer.concat([original,Buffer.from(suffix)]);
fs.writeFileSync(derived,derivedBytes,{flag:'wx'});
const inputs=[],remember=file=>{const p=pin(file),old=inputs.find(x=>x.file===p.file);if(old)assert.deepEqual(p,old);else inputs.push(p);return p;};
for(const file of [api,input,driver,fileURLToPath(import.meta.url),base,runtime,nativeRuntime,
  ...['assemble.mjs','native-build.mjs','node-resource-args.mjs','compiler-abi.mjs','base-cache-graph.mjs'].map(n=>path.join(root,'selfhost/tools',n)),path.join(root,'selfhost/src/compiler.json')])remember(file);
const report={kind:'phase70-bend-observer-plan-query-v1',complete:false,names:wanted,inputs,records:[],nativeEmissionCalls:0,rawEntryCalls:0,checkedEntryCalls:0,
  boundary:'Analysis diagnostics only: true is explicitly supplied after checked entry, not a production effect or bang admission certificate.',
  derivation:{original:inputs[0],output:pin(derived),append:suffix,originalPrefixByteIdentical:derivedBytes.subarray(0,original.length).equals(original)}};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const stop='PHASE70_BEND_OBSERVER_PLAN_QUERY_COMPLETE';
try {
  process.env.BEND_TYPED_API=api;process.env.BEND_BASE=base;process.env.BEND_TYPED_RUNTIME=runtime;
  const A=await import(pathToFileURL(derived));
  assert.equal(typeof A.default.nc_compile_checked,'function','checked native entry required');
  const capture=(book,nativeText,foreignText,effectsSafe)=>{
    report.checkedEntryCalls++;
    assert.equal(report.checkedEntryCalls,1,'multiple checked captures');
    assert.equal(hash(Buffer.from(nativeText)),remember(nativeRuntime).sha256,'runtime read changed');
    report.entry={effectsSafe,foreignTextSha256:hash(Buffer.from(foreignText)),nativeTextSha256:hash(Buffer.from(nativeText))};
    A.phase70QueryObserverPlans(book,wanted,progress=>{report.running=progress;save();},record=>{report.records.push(record);delete report.running;save();});
    throw Error(stop);
  };
  const wrapped={...A.default,nc_compile:()=>{report.rawEntryCalls++;throw Error('unexpected raw native entry');},nc_compile_checked:capture};
  if(A.default.nc_foreign_source)wrapped.nc_foreign_source=(book,scope,file,text,parsed)=>{
    let resolved=path.resolve(file);
    if(path.dirname(resolved)===path.join(path.dirname(base),'effs'))resolved=path.join(root,'selfhost/src/runtime/native/effs',path.basename(resolved));
    assert.equal(hash(Buffer.from(text)),remember(resolved).sha256,'foreign source read changed');
    return A.default.nc_foreign_source(book,scope,file,text,parsed);
  };
  const D=await import(pathToFileURL(driver));
  const graph=D.discoverSources(wrapped,input);for(const file of graph.files)remember(file);save();
  report.observation=await D.inspect(input,{mode:'native',api:wrapped,withReport:true});
  assert.equal(report.checkedEntryCalls,1,'checked book not captured');
  assert.equal(report.rawEntryCalls,0);
  assert.equal(report.records.length,wanted.length*2,'incomplete Bend query set');
  assert(String(report.observation.diagnostic??report.observation.reason??'').includes(stop),JSON.stringify(report.observation));
  for(const old of inputs)assert.deepEqual(pin(old.file),old);
  assert(fs.readFileSync(derived).equals(derivedBytes),'derived API changed');
  report.inputsUnchanged=true;report.complete=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
save();
console.log(JSON.stringify({complete:report.complete,records:report.records.map(r=>({name:r.requested,permission:r.permission,accepted:r.accepted,error:r.error,elapsedMs:r.elapsedMs})),error:report.error}));
