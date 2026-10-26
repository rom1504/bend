// Observer for existing checked Bend roots; no compiler logic or cache admission
// is reimplemented here. Valid frozen Base-only fixtures are the experiment scope.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';
import assert from 'node:assert/strict';import{pathToFileURL}from'node:url';
const ROOT=path.resolve(import.meta.dirname,'../../../..'),[apiArg,outArg]=process.argv.slice(2);
assert(apiArg&&outArg);const out=path.resolve(outArg);assert(!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase142/'));
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=p=>assert.deepEqual(pin(p.file),p),read=f=>JSON.parse(fs.readFileSync(f));
const rec=read(apiArg),selPath=ROOT+'/implementation/phase137/candidate.json',sel=read(selPath),refPath=ROOT+'/selfhost/build/phase134/reference03.json',refs=read(refPath),carrier=read(sel.preferredCarrierReceipt.file);
assert(rec.complete&&rec.checked&&sel.nativeQualified&&refs.complete);rec.inputs.forEach(verify);verify(rec.api);
const base=carrier.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);verify(base);verify(sel.preferredCarrier);
const required=['p88_cache_prepare','f_source_end','f_prefix_complete_ready_seed','f_prefix_graph_empty','f_source_path','f_source_text','f_source_located','p86_width','f_source_header','p140pl_load','p140pl_seeded'];
for(const e of required)assert(rec.exports.includes(e),'Missing export '+e);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase142-retained-base-completion-probe',complete:false,diagnostic:true,inputs:[pin(import.meta.filename),pin(apiArg),rec.api,...rec.inputs,pin(selPath),pin(refPath),pin(sel.preferredCarrierReceipt.file),base,sel.preferredCarrier,pin(process.execPath)],isolated:[],rows:[],scope:'Hosted checked Bend, valid frozen Base-only fixtures. Reuses only immutable P86Seed-derived completion, not prior current-source products. Complete FPrefixLoad/cache/flags compared with original loader. No native, invalid-input error-priority, general invalidation, promotion or clean speed claim.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
const tag=(x,t)=>{assert.equal(x?.$,t,JSON.stringify({expected:t,actual:x?.$,error:x?.error}));return x};
const time=f=>{const t=performance.now(),value=f();return{value,seconds:(performance.now()-t)/1000}};
function exact(a,b){const todo=[[a,b]],seen=new WeakMap();while(todo.length){const[x,y]=todo.pop();if(Object.is(x,y))continue;if(!x||!y||typeof x!=='object'||typeof y!=='object'){assert.deepEqual(x,y);continue;}let z=seen.get(x);if(z?.has(y))continue;if(!z){z=new WeakSet();seen.set(x,z);}z.add(y);const keys=Object.keys(x).sort();assert.deepEqual(keys,Object.keys(y).sort());for(const k of keys)todo.push([x[k],y[k]]);}}
const started=performance.now();
try{
 const api=(await import(pathToFileURL(rec.api.file))).default;
 const seedTimed=time(()=>tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(sel.preferredCarrier.file,'utf8'),sel.preferredStamp),'P86PreparationReady').seed),seed=seedTimed.value;report.seedSeconds=seedTimed.seconds;
 const complete=()=>api.f_prefix_complete_ready_seed(seed.source,'',api.f_prefix_graph_empty(),api.f_source_path(seed.source),api.f_source_text(seed.source),seed.book,seed.ready);
 const acquired=time(complete),retained=tag(acquired.value,'FPrefixCompletion');assert.equal(retained.parsed.error,'');report.completionAcquisitionSeconds=acquired.seconds;
 for(let round=0;round<5;round++){const x=time(complete);exact(x.value,retained);report.isolated.push({round,seconds:x.seconds,completeExact:true});}
 const origin=api.f_source_end(seed.source),importCheck=typeof api.p86_import_error==='function';
 report.importValidationIncluded=importCheck;report.omittedImportCheck=importCheck?null:'Original loader validates imports. Retained total excludes that check; only independently accepted frozen Base-only inputs tested. Not an exact complete-pipeline speedup.';
 for(const[name,owner,needle,replacement]of[['lexer','prng','U32.shln(x, 13n)','U32.shln(x, 12n)'],['coverage-map-churn-128','p37.map.update','U32.mul(i, 31)','U32.mul(i, 29)']]){
  const c=refs.cases.find(x=>x.name===name);assert(c);verify(c.source);report.inputs.push(c.source);
  const a=fs.readFileSync(c.source.file,'utf8');assert.equal(a.split(needle).length,2);const b=a.replace(needle,replacement),hint=origin+a.indexOf(needle);
  const bp=out+'/'+name+'-B.bend';fs.writeFileSync(bp,b);report.inputs.push(pin(bp));
  const priorTimed=time(()=>tag(api.p140pl_load(seed,c.source.file,a,{$:'None'},hint),'P140PLoadReady')),prior=priorTimed.value;
  const expected=tag(api.p140pl_load(seed,c.source.file,b,prior.cache,hint),'P140PLoadReady');
  assert.equal(expected.load.trace.result.error,'');
  const row={name,edit:{owner,needle,replacement,hint,logicalPath:c.source.file},coldParserAcquisitionSeconds:priorTimed.seconds,pairs:[]};report.rows.push(row);save();
  const fresh=()=>time(()=>api.p140pl_load(seed,c.source.file,b,prior.cache,hint));
  const reuse=()=>{
   const began=performance.now();
   const location=time(()=>{const width=api.p86_width(b,0),end=origin+width+1;assert(end<2**32);return api.f_source_located({$:'FSource',name:c.source.file,path:c.source.file,text:b},origin,end);});
   const header=time(()=>api.f_source_header(location.value));assert.equal(header.value.error,'');
   const imports=importCheck?time(()=>api.p86_import_error(header.value.imports,false)):null;if(imports)assert.equal(imports.value,'');
   const rest=time(()=>api.p140pl_seeded(seed,location.value,header.value,prior.cache,hint,retained));
   return{value:rest.value,seconds:(performance.now()-began)/1000,parts:{locationSeconds:location.seconds,headerSeconds:header.seconds,importValidationSeconds:imports?.seconds??null,retainedCompletionConsumerSeconds:rest.seconds}};
  };
  for(let round=0;round<5;round++){
   let old,next;if(round%2){next=reuse();old=fresh();}else{old=fresh();next=reuse();}
   exact(old.value,expected);exact(next.value,expected);
   row.pairs.push({round,order:round%2?'retained/original':'original/retained',originalLoaderSeconds:old.seconds,retainedLoaderSeconds:next.seconds,retainedParts:next.parts,ratio:next.seconds/old.seconds,fullLoadCacheAndFlagsExact:true});save();
  }
  console.log(JSON.stringify({name,pairs:row.pairs}));
 }
 report.inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{report.totalSeconds=(performance.now()-started)/1000;report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,totalSeconds:report.totalSeconds,error:report.error}));}
