// Checked Bend parses real source and executes complete consumer batches.
// Host code authenticates, schedules and observes; it does not build the facts.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const ROOT=path.resolve(import.meta.dirname,'../../../../..');
const [apiFile,manifestFile,outArg]=process.argv.slice(2);
assert(apiFile&&manifestFile&&outArg);
const read=f=>JSON.parse(fs.readFileSync(f,'utf8'));
const pin=f=>{f=fs.realpathSync(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const inputs=new Map(),add=p=>{assert.deepEqual(pin(p.file),p);inputs.set(p.file,p);return p};
const file=f=>add(pin(f));
const out=path.resolve(outArg);assert(!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase144/'));
const rec=read(apiFile),manifest=read(manifestFile),carrierFile=ROOT+'/selfhost/build/phase130/base-carrier01/receipt.json',carrier=read(carrierFile);
assert(rec.complete&&rec.checked&&rec.status===0&&manifest.complete&&carrier.complete);
assert(rec.inputs.some(p=>p.sha256===manifest.source.sha256));
for(const f of [import.meta.filename,process.execPath,apiFile,manifestFile,carrierFile])file(f);
rec.inputs.forEach(add);add(rec.api);carrier.inputs.forEach(add);add(carrier.carrier);manifest.fixtures.forEach(x=>add(x.source));
const base=carrier.inputs.find(x=>x.file.endsWith('/bend2/base.bend'));assert(base);
const tag=(v,t)=>{assert.equal(v?.$,t,JSON.stringify({expected:t,actual:v?.$,error:v?.error}));return v};
const list=v=>{const a=[];while(v?.$==='Con'){assert(a.length<20000);a.push(v.head);v=v.tail}tag(v,'Nil');return a};
const clock=f=>{const t=performance.now(),value=f();return{value,seconds:(performance.now()-t)/1000}};
const gc=()=>clock(()=>Bun.gc(true)).seconds;
const started=performance.now();fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase144-constructor-existence-consumer-screen',complete:false,rows:[],budgetSeconds:60,
 scope:'Actual parsed compiler-prefix events under prepared Base scope. Event-error/book_put replay and complete recursive prefix-disjoint consumer, including fact construction/use/host GC. Not captured full checker execution, native teardown, or whole compilation gain.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
try{
 const api=(await import(pathToFileURL(rec.api.file))).default;
 for(const name of manifest.exports)assert.equal(typeof api[name],'function',name);
 const preparation=clock(()=>tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(carrier.carrier.file,'utf8'),carrier.stamp),'P86PreparationReady'));
 report.basePreparationSeconds=preparation.seconds;const seed=preparation.value.seed,seen=api.p144cet_seed_seen(seed);
 report.seedRows=list(seen).length;
 for(const fixture of manifest.fixtures){
  assert((performance.now()-started)/1000<55,'bounded screen budget');
  const parsed=clock(()=>tag(api.p144cet_parse(seed,fs.readFileSync(fixture.source.file,'utf8')),'FResult'));
  assert.equal(parsed.value.error,'');const book=parsed.value.book,defs=list(book);
  const row={fixture,parsedSeconds:parsed.seconds,parsedDefinitions:defs.length,
   adts:defs.filter(d=>d.kind==='ADT').map(d=>({name:d.name,children:list(d.ctors).length})),blocks:[]};report.rows.push(row);save();
  for(const consumer of ['events','disjoint']){
   const fns=consumer==='events'?{original:api.p144cet_original,indexed:api.p144cet_indexed}:{original:api.base_prefix_ctor_disjoint,indexed:api.p144ce_disjoint};
   const expected=fns.original(book,seen);assert.equal(fns.indexed(book,seen),expected);
   assert.equal(expected,consumer==='events'?'':true,'Actual extracted prefix should exercise full successful consumer, not an early rejection');
   const pilot=clock(()=>fns.original(book,seen));
   const repeats=Math.max(1,Math.min(32,Math.ceil(0.03/Math.max(pilot.seconds,0.001))));
   for(let round=0;round<4;round++){
    assert((performance.now()-started)/1000<58,'bounded screen budget');const order=round%2?['indexed','original']:['original','indexed'];
    const calls=[];
    for(const mode of order){const beforeGc=gc(),timed=clock(()=>{let value;for(let i=0;i<repeats;i++){value=fns[mode](book,seen);assert.equal(value,expected)}return value}),afterGc=gc();
     calls.push({mode,repeats,seconds:timed.seconds,afterGcSeconds:afterGc,inclusiveSeconds:timed.seconds+afterGc,beforeGcSeconds:beforeGc,output:timed.value});}
    row.blocks.push({consumer,round,order,calls});save();
   }
  }
 }
 report.complete=true;
}catch(error){report.error=String(error.stack||error);process.exitCode=1;}
finally{report.wallSeconds=(performance.now()-started)/1000;report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));}
