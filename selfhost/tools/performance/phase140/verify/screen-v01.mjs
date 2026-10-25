// Observer only: all semantic verification and reuse decisions run in checked Bend.
import fs from 'node:fs'; import path from 'node:path'; import crypto from 'node:crypto';
import assert from 'node:assert/strict'; import {pathToFileURL} from 'node:url';
const ROOT=path.resolve(import.meta.dirname,'../../../../..');
const [apiArg,outArg]=process.argv.slice(2),out=path.resolve(outArg);
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=p=>assert.deepEqual(pin(p.file),p),read=f=>JSON.parse(fs.readFileSync(f));
const rec=read(apiArg),sel=read(ROOT+'/implementation/phase137/candidate.json'),refs=read(ROOT+'/selfhost/build/phase134/reference03.json');
assert(rec.complete&&rec.checked&&sel.nativeQualified&&refs.complete);rec.inputs.forEach(verify);verify(rec.api);
const carrier=read(sel.preferredCarrierReceipt.file),base=carrier.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);verify(base);verify(sel.preferredCarrier);
assert(!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase140/'));fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase140-verifier-reuse-screen',complete:false,inputs:[pin(import.meta.filename),pin(apiArg),rec.api,...rec.inputs,pin(ROOT+'/implementation/phase137/candidate.json'),pin(ROOT+'/selfhost/build/phase134/reference03.json'),base,sel.preferredCarrier,pin(process.execPath)],rows:[],scope:'Hosted checked Bend verifier comparison on actual independent fresh A/B raw-lowered programs. Parsing/preparation/lowering and acquisition separately paid; no full build/native speed claim. Timings include exact-context/body comparison and global/static-image checks.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
const timer=f=>{const t=performance.now(),value=f();return{value,seconds:(performance.now()-t)/1000}};
const tag=(v,t)=>{assert.equal(v?.$,t,JSON.stringify({expected:t,actual:v?.$,error:v?.error}));return v};
const arr=l=>{const a=[];while(l.$==='Con'){a.push(l.head);l=l.tail;}tag(l,'Nil');return a};
const same=(a,b)=>{const todo=[[a,b]],seen=new WeakMap();while(todo.length){const[x,y]=todo.pop();if(Object.is(x,y))continue;if(!x||!y||typeof x!=='object'||typeof y!=='object'){assert.deepEqual(x,y);continue;}let q=seen.get(x);if(q?.has(y))continue;if(!q){q=new WeakSet();seen.set(x,q);}q.add(y);const k=Object.keys(x).sort();assert.deepEqual(k,Object.keys(y).sort());for(const n of k)todo.push([x[n],y[n]]);}};
try{
 const api=(await import(pathToFileURL(rec.api.file))).default;
 const seed=tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(sel.preferredCarrier.file,'utf8'),sel.preferredStamp),'P86PreparationReady').seed;
 const lower=(file,text)=>timer(()=>{const plan=tag(api.p86_plan(seed,file,text),'P86PlanReady');assert.equal(api.p111_runtime_admission(plan.request),'');const raw=tag(api.p128raw_lower_request(plan.request),'P128RawLowering');assert.equal(raw.lowered.error,'');return{program:raw.lowered.program,certificate:api.p113a_certificate(plan.request)}});
 for(const [name,needle,replacement]of[['lexer','U32.shln(x, 13n)','U32.shln(x, 12n)'],['coverage-map-churn-128','U32.mul(i, 31)','U32.mul(i, 29)']]){
  const c=refs.cases.find(c=>c.name===name);assert(c);verify(c.source);report.inputs.push(c.source);const a=fs.readFileSync(c.source.file,'utf8');assert.equal(a.split(needle).length,2);const b=a.replace(needle,replacement);fs.writeFileSync(out+'/'+name+'-B.bend',b);report.inputs.push(pin(out+'/'+name+'-B.bend'));
  const pa=lower(c.source.file,a),pb=lower(c.source.file,b),seeded=timer(()=>api.p140v_check(pa.value.program,{$:'P140VEmpty'}));assert.equal(seeded.value.error,'');const cache=seeded.value.cache,pairs=[];
  for(let round=0;round<3;round++){
   let fresh,warm; if(round%2){warm=timer(()=>api.p140v_check(pb.value.program,cache));fresh=timer(()=>api.p113d_verify(pb.value.program));}else{fresh=timer(()=>api.p113d_verify(pb.value.program));warm=timer(()=>api.p140v_check(pb.value.program,cache));}
   assert.equal(fresh.value,'');assert.equal(warm.value.error,fresh.value);pairs.push({round,order:round%2?'warm/fresh':'fresh/warm',freshSeconds:fresh.seconds,warmSeconds:warm.seconds,ratio:warm.seconds/fresh.seconds,counts:arr(warm.value.counts)});
  }
  const opened=api.p140v_open(pb.value.program,cache);same(opened.boundary,api.p114s_open(pb.value.program));
  const array={$:'P113AProgram',original:pb.value.program,certificate:pb.value.certificate};
  assert.equal(api.p140v_array(array,cache).error,api.p113a_verify(array));
  const raw=pb.value.program.original.program,head=tag(raw.segments,'Con').head;
  const invalid={...pb.value.program,original:{...pb.value.program.original,program:{...raw,segments:{...raw.segments,head:{...head,body:{$:'Con',head:{$:'N111Return',value:{$:'N111Local',name:'p140_missing'}},tail:{$:'Nil'}}}}}}};
  const badFresh=api.p113d_verify(invalid),badWarm=api.p140v_check(invalid,cache);assert.notEqual(badFresh,'');assert.equal(badWarm.error,badFresh);assert.equal(badWarm.cache.$,'P140VEmpty');same(api.p140v_open(invalid,cache).boundary,api.p114s_open(invalid));
  const row={name,edit:{needle,replacement,compilerInputPath:c.source.file},prepareASeconds:pa.seconds,prepareBSeconds:pb.seconds,seedVerificationSeconds:seeded.seconds,pairs,openFullStateExact:true,invalidBodyFreshError:badFresh,invalidBodyWarmError:badWarm.error,invalidCacheCleared:true};report.rows.push(row);save();console.log(JSON.stringify(row));
 }
 report.inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,error:report.error}));}
