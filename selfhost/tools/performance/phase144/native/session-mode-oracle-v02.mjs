// Independent checked Bend session-mode oracle; no native bytes are oracle inputs.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..');
const [apiArg,planArg,outArg]=process.argv.slice(2),out=path.resolve(outArg);
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const read=f=>JSON.parse(fs.readFileSync(f,'utf8')),verify=p=>assert.deepEqual(pin(p.file),p);
assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase144/'));
const plan=read(planArg),ad=plan.sourceAdmission,original=read(ad.checkedApi.file),ar=read(apiArg);
assert(plan.complete&&ad.source.sha256==='865cff6a02da261952cac824bed0fe91882e60f1c6e4062fbe57f5804745c4ed');
assert(original.checked&&original.complete&&ar.checked&&ar.complete&&ar.status===0);
assert.deepEqual(ar.command.slice(0,2),original.command.slice(0,2));
assert.deepEqual(ar.command.slice(2,4),[ad.source.file,ar.api.file]);
assert.deepEqual(ar.command.slice(4),ar.exports);
const originalDir=path.dirname(ad.checkedApi.file),newDir=path.dirname(path.resolve(apiArg));
const snapshots=new Set(['method.py','stage0-library.mjs']);
assert.equal(ar.inputs.length,original.inputs.length);
for(const p of original.inputs){
 const file=path.dirname(p.file)===originalDir&&snapshots.has(path.basename(p.file))?path.join(newDir,path.basename(p.file)):p.file;
 assert(ar.inputs.some(q=>q.file===file&&q.bytes===p.bytes&&q.sha256===p.sha256));
}
for(const name of [...original.exports,'f_source_end','p140s_empty','p140s_named','p140g_prepare','p140r_begin_cursor','p140r_next'])assert(ar.exports.includes(name));
const fixtureFile=path.join(root,'selfhost/build/phase140/batch-smoke-plan01.json'),fixture=read(fixtureFile);
assert.deepEqual(fixture.jobs.map(j=>j.name),['seed','edit','revert','edit-again']);
assert(fixture.jobs.every((j,i)=>j.source===fixture.jobs[i%2].source&&j.hint===1784&&j.owner==='prng'&&j.mode===(i?'warm':'cold')));
const sources=[pin(fixture.jobs[0].source),pin(fixture.jobs[1].source)];
assert.equal(fixture.logical,sources[0].file);assert.notEqual(sources[0].sha256,sources[1].sha256);
const inputs=[pin(import.meta.filename),pin(process.execPath),pin(apiArg),ar.api,...ar.inputs,...original.inputs,pin(planArg),
 ad.source,ad.sourceManifest,ad.checkedApi,ad.api,pin(fixtureFile),...sources,plan.base,plan.carrier,plan.runtime];
inputs.forEach(verify);fs.mkdirSync(out);
const report={kind:'phase144-hosted-session-mode-oracle',complete:false,inputs,
 compilerSource:ad.source,originalCheckedApi:ad.checkedApi,originalApi:ad.api,
 oracleCheckedApi:pin(apiArg),oracleApi:ar.api,plan:pin(planArg),fixture:pin(fixtureFile),
 logicalPath:fixture.logical,sources,runtime:plan.runtime,runtimeRole:'Declared future native-link context; hosted oracle does not link this object.',
 mode:'phase140-cached-optimizer',rows:[],cold:{},warmProductsExact:false,
 crossModeByteIdentityClaimed:false,
 scope:'Independent hosted cold session A/B, then hosted A/B/A/B from empty state; complete products must match cold session oracles. Uses unchanged checked Bend session/registry/render exports. Session keeps its outer range pass; ordinary mode omits it. No restoration of ordinary/session byte identity, native qualification, broad incremental claim or timing comparison.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const tag=(x,t)=>{assert.equal(x?.$,t,JSON.stringify({expected:t,actual:x?.$,error:x?.error}));return x};
const started=performance.now();save();
try{
 const api=(await import(pathToFileURL(ar.api.file))).default;
 const seed=tag(api.p88_cache_prepare(plan.base.file,fs.readFileSync(plan.base.file,'utf8'),fs.readFileSync(plan.carrier.file,'utf8'),plan.stamp),'P86PreparationReady').seed;
 const begin=api.f_source_end(seed.source);assert(Number.isInteger(begin)&&begin>=0&&begin+1784<=4294967295);
 report.sourceOrigin=begin;report.hint=begin+1784;report.owner='prng';
 const empty=()=>({compiler:api.p140s_empty(),registry:{$:'P140GCache',passes:{$:'Nil'}},render:{$:'P140REmpty'},pieces:[]});
 function compile(name,index,prior){
  const t=performance.now(),source=sources[index];
  const s=tag(api.p140s_named(seed,fixture.logical,fs.readFileSync(source.file,'utf8'),prior.compiler,begin+1784,'prng'),'P140SResult');
  const emitted=tag(s.emission,'P134Planned');
  const prepared=tag(api.p140g_prepare(emitted.plan,prior.registry),'P140GPrepared');
  let cursor=api.p140r_begin_cursor(prepared.cursor,prior.render),pieces=[],bytes=0,end;
  for(let n=0;n<20000;n++){
   const x=api.p140r_next(cursor);
   if(x.$==='P140REnd'){end=x;break;}
   let text;
   if(x.$==='P140RReuse'){
    assert(Number.isInteger(x.ordinal)&&x.ordinal>=0&&x.ordinal<prior.pieces.length);text=prior.pieces[x.ordinal];
   }else{tag(x,'P140RText');assert.equal(typeof x.text,'string');assert.equal(typeof x.ending,'boolean');text=x.text+(x.ending?'\n':'');}
   bytes+=Buffer.byteLength(text);assert(bytes<=32*1024*1024);pieces.push(text);cursor=x.next;
  }
  assert(end&&bytes>0);const text=pieces.join(''),file=path.join(out,name+'.ssa');
  fs.writeFileSync(file,text,{flag:'wx'});const product=pin(file);assert.equal(product.bytes,bytes);
  const row={name,source,logicalPath:fixture.logical,product,verified:true,pieces:pieces.length,
    registryHits:prepared.hits,registryMisses:prepared.misses,renderHits:end.hits,renderMisses:end.misses,
    seconds:(performance.now()-t)/1000};report.rows.push(row);save();
  return{product,text,state:{compiler:s.cache,registry:prepared.cache,render:end.cache,pieces}};
 }
 const a=compile('cold-a',0,empty()),b=compile('cold-b',1,empty());
 assert.notEqual(a.text,b.text,'Frozen edit must alter the oracle');report.cold={a:a.product,b:b.product};save();
 let state=empty();
 for(let i=0;i<4;i++){
  const x=compile(['seed','edit','revert','edit-again'][i],i%2,state);
  assert.equal(x.text,i%2?b.text:a.text,'Hosted warm output differs from independent cold session oracle');state=x.state;
 }
 report.warmProductsExact=true;inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}
finally{report.seconds=(performance.now()-started)/1000;save();console.log(JSON.stringify({complete:report.complete,cold:report.cold,rows:report.rows.length,error:report.error}));}
