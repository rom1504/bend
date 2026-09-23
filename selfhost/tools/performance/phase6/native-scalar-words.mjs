// Bounded checked native emission; no Clang or runtime timing is inferred.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {identity,verifyIdentity,verifyAttempt,validatedCache} from '../../development/workflow.mjs';
import {supervise,requireExecution} from '../../development/process.mjs';

const read=f=>JSON.parse(fs.readFileSync(f));
const write=(f,x)=>fs.writeFileSync(f,JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const [mode,attemptPath,outPath,source,resultFile]=process.argv.slice(2);
const out=path.resolve(outPath);
if(mode==='worker') {
  const c=read(path.join(out,'config.json'));c.inputs.forEach(verifyIdentity);
  const D=await import(pathToFileURL(c.driver));
  const start=performance.now(),r=await D.inspect(source,{mode:'native',withReport:true});
  const requestMs=performance.now()-start,{code,...result}=r;
  let emitted=null;
  if(typeof code==='string') {
    const file=resultFile+'.c';fs.writeFileSync(file,code,{flag:'wx'});
    emitted={...identity(file),bytes:Buffer.byteLength(code)};
  }
  c.inputs.forEach(verifyIdentity);
  write(resultFile,{...result,requestMs,emitted,inputsVerified:true,
    files:(r.files||[]).map(identity),scope:'Authoritative checked emission only; no Clang or runtime.'});
  assert.equal(r.status,'ok');assert.equal(r.phase,'compile');assert.equal(r.checked,true);assert.ok(emitted);
} else if(mode==='run') {
  const start=performance.now(),m=await verifyAttempt(path.resolve(attemptPath));
  fs.mkdirSync(out,{recursive:false});
  const driver=path.join(m.snapshot.root,'tools/typed-driver.mjs');
  const original=path.join(m.config.upstream,'tests/reg/arity_wall.bend');
  const originalText=fs.readFileSync(original,'utf8'),cases=[];
  for(const n of [32,64,128,255]) {
    const fields=Array.from({length:n},(_,i)=>'f'+i);
    let text=originalText;
    if(n!==255) text=text.replace(/^  MkR255\{.*\}$/m,'  MkR255{'+fields.map(f=>f+': U32').join(', ')+'}')
      .replace(/^    case MkR255\{.*\}:$/m,'    case MkR255{'+fields.join(', ')+'}:')
      .replace(/^  pick\(MkR255\{.*\}\)$/m,'  pick(MkR255{'+fields.map(()=>1).join(', ')+'})').replaceAll('R255','R'+n);
    const file=path.join(out,'fields-'+n+'.bend');fs.writeFileSync(file,text,{flag:'wx'});
    cases.push({n,source:identity(file)});
  }
  const cache=validatedCache(path.join(m.snapshot.root,'build/typed/cache'),m.api.file,m.base.file);
  const inputs=[identity(import.meta.filename),identity(path.join(path.resolve(attemptPath),'attempt.json')),
    identity(original),m.api,m.checkedApi,m.bootstrapReport,m.runtime,m.base,cache,identity(process.execPath),
    ...m.snapshot.sources.map(x=>x.frozen),...cases.map(x=>x.source)];
  write(path.join(out,'config.json'),{driver,inputs,cases});
  const env={...process.env};for(const k of Object.keys(env))if(k.startsWith('BEND_')||k==='NODE_OPTIONS')delete env[k];
  Object.assign(env,{BEND_TYPED_API:m.api.file,BEND_TYPED_RUNTIME:m.runtime.file,BEND_BASE:m.base.file,BEND_TYPED_TRACE:'1'});
  const report={kind:'phase6-native-inline-word-emission',started:new Date().toISOString(),complete:false,
    api:m.api,checkedParent:m.checkedApi,inputs,cases,rows:[],cpu:'3',heapMb:4096,stackKb:4096,
    scope:'Fresh checked candidate size ladder; correctness overlaps other work; elapsed times are not controlled.'};
  const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
  try {
    for(const c of cases) {
      const result=path.join(out,'fields-'+c.n+'.json'),remaining=360000-(performance.now()-start);
      assert.ok(remaining>0);
      const execution=await supervise('taskset',['-c','3',process.execPath,'--stack-size=4096','--max-old-space-size=4096',
        import.meta.filename,'worker',attemptPath,out,c.source.file,result],
        {directory:path.join(out,'process-'+c.n),env,timeoutMs:Math.min(90000,Math.floor(remaining))});
      const row={n:c.n,source:c.source,execution,result:fs.existsSync(result)?read(result):null};report.rows.push(row);save();
      requireExecution(execution);assert.equal(row.result.status,'ok');assert.equal(row.result.checked,true);
      assert.equal(row.result.inputsVerified,true);
    }
    inputs.forEach(verifyIdentity);await verifyAttempt(path.resolve(attemptPath));report.complete=true;
    report.inputsVerified=true;report.finished=new Date().toISOString();save();
    console.log(JSON.stringify({report:path.join(out,'report.json'),rows:report.rows.map(x=>({n:x.n,bytes:x.result.emitted.bytes,requestMs:x.result.requestMs}))}));
  } catch(error) {report.error=String(error.stack??error);report.finished=new Date().toISOString();save();throw error;}
} else throw Error('Usage: native-scalar-words.mjs run ATTEMPT NEW_OUTPUT | worker ATTEMPT OUTPUT SOURCE RESULT');
