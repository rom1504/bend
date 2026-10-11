// Read-only admission diagnostic on the exact checked book. No C compilation.
// ATTEMPT INPUT FRESH_OUT; run under the maintained single process-tree guard.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [attemptArg,inputArg,outArg]=process.argv.slice(2),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const pins=new Map(),pin=p=>{const expected=typeof p==='string'?null:p,file=fs.realpathSync(expected?.file??expected?.path??p),bytes=fs.readFileSync(file),r={file,sha256:createHash('sha256').update(bytes).digest('hex')};if(expected)assert.equal(r.sha256,expected.sha256);pins.set(file,r);return r;};
const report={complete:false,method:pin(import.meta.filename),attempt:pin(attemptArg),input:pin(inputArg)};
try {
  const attempt=JSON.parse(fs.readFileSync(report.attempt.file));
  assert(attempt.checked&&attempt.config.strictExact);
  report.api=pin(attempt.api);
  const code=fs.readFileSync(report.api.file,'utf8');
  const helper=String.raw`
export function inspectWorkers(book) {
  const c=(f,...a)=>run_loop(f(...a)),nil={$:'Nil'},list=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
  const array=x=>{const a=[];while(x?.$==='Con'){a.push(x.head);x=x.tail;}if(x?.$!=='Nil')throw Error('bad list');return a;};
  const names=c($nc_live_names$,book,list(['main']),nil),sigs=c($book_cached$,c($nq_signatures$,book,names),0),bangs=c($nc_bangs_book$,book);
  const workers=[...array(c($nf_candidates$,book,names,bangs,sigs)),...array(c($nq_candidates$,book,names,bangs,sigs))];
  const ready=array(c($nf_admit$,book,list(workers),nil,workers.length));
  const retried=typeof $nf_retry$==='function'?array(c($nf_retry$,book,list(workers),list(ready),c($book_cached$,c($nf_ready_signatures$,sigs,list(ready)),0))):workers;
  const final=array(c($nf_admit$,book,list(retried),list(ready),retried.length));
  return retried.map(w=>({name:w.name,originalReady:ready.includes(w.name),ready:final.includes(w.name),error:c($nc_error$,w.code),dependencies:array(w.deps),segments:array(c($nc_segs$,w.code)).length,body:c($nc_body$,w.code)}));
}
`;
  const derived=path.join(out,'observed.mjs');fs.writeFileSync(derived,code+helper,{flag:'wx'});report.derived=pin(derived);
  process.env.BEND_TYPED_API=report.api.file;
  process.env.BEND_TYPED_RUNTIME=path.resolve('selfhost/src/runtime.mjs');
  process.env.BEND_BASE=attempt.base.file;
  const driver=path.resolve('selfhost/tools/typed-driver.mjs');report.driver=pin(driver);
  const D=await import(pathToFileURL(driver)),A=await import(pathToFileURL(derived)),api=await D.loadApi();
  const wrapped={...api,nc_compile_checked(book){report.workers=A.inspectWorkers(book);throw Error('WORKERS_CAPTURED');}};
  report.observation=await D.inspect(report.input.file,{mode:'native',api:wrapped,withReport:true});
  assert(report.workers,'missing checked native capture');
  for(const p of [...pins.values()])pin(p);
  report.complete=true;
} catch(error){report.error=error.stack;process.exitCode=1;}
report.inputs=[...pins.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({complete:report.complete,error:report.error,workers:report.workers?.length}));
