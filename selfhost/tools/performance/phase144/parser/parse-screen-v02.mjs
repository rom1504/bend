// Host observation only: both parsers/checkers/emitters execute checked Bend.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [oldArg,newArg,outArg]=process.argv.slice(2);
assert(oldArg&&newArg&&outArg,'OLD_CHECKED_REPORT NEW_CHECKED_REPORT FRESH_PHASE144_OUT');
const ROOT=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase144/'));
const read=f=>JSON.parse(fs.readFileSync(f));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const inputs=new Map(),add=p=>{assert.deepEqual(pin(p.file),p);inputs.set(p.file,p);return p};
const file=f=>add(pin(f));
const recs={original:read(oldArg),candidate:read(newArg)};
const required=['f_load_graph','p88_cache_prepare','p86_plan','p134e_plan','p134e_begin','p134e_next'];
for(const rec of Object.values(recs)){assert(rec.complete&&rec.checked);required.forEach(k=>assert(rec.exports.includes(k),k));rec.inputs.forEach(add);add(rec.api)}
assert(recs.original.inputs.some(p=>p.sha256==='a51a4a6d0a32e118ca75eac96fb4e64bae0fcf951b09ee859c2632f65550bd4e'));
assert(recs.candidate.exports.includes('p144pc_controls'));
const selectedPath=ROOT+'/implementation/phase143/candidate.json',selected=read(selectedPath);
const carrier=read(selected.preferredCarrierReceipt.file),base=carrier.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));
const refsPath=ROOT+'/selfhost/build/phase134/reference03.json',refs=read(refsPath);assert(base&&carrier.complete&&refs.complete);
for(const f of [import.meta.filename,process.execPath,oldArg,newArg,selectedPath,selected.preferredCarrierReceipt.file,refsPath])file(f);
add(base);add(selected.preferredCarrier);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase144-parser-prior-view-screen',complete:false,controls:[],raw:[],frontend:[],frozen:[],
 scope:'Independent checked original Phase143 and parser-view candidate. Complete external raw FResult (all definition fields, terms, spans, imports and exact first error) and P86Plan equality. No comparison of new internal scope-cache field against old five-field representation. Hosted timings only; not native reclamation, full-compiler throughput or promotion.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');
const tag=(v,t)=>{assert.equal(v?.$,t,JSON.stringify({expected:t,actual:v?.$,error:v?.error}));return v};
const list=items=>items.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const arr=v=>{const a=[];while(v?.$==='Con'){a.push(v.head);assert(a.length<100000);v=v.tail}tag(v,'Nil');return a};
const time=f=>{const t=performance.now(),value=f();return{value,seconds:(performance.now()-t)/1000}};
const median=a=>[...a].sort((x,y)=>x-y)[Math.floor(a.length/2)];
function equal(a,b){const todo=[[a,b]],seen=new WeakMap();let objects=0;while(todo.length){const[x,y]=todo.pop();if(Object.is(x,y))continue;
 assert(x!==null&&y!==null&&typeof x==='object'&&typeof y==='object','Non-data/scalar difference');
 const px=Object.getPrototypeOf(x),py=Object.getPrototypeOf(y);assert.equal(px,py);assert([Object.prototype,Array.prototype,null].includes(px));
 let ys=seen.get(x);if(ys?.has(y))continue;if(!ys){ys=new WeakSet();seen.set(x,ys)}ys.add(y);objects++;assert(objects<4000000,'Comparison bound');
 const kx=Object.keys(x).sort(),ky=Object.keys(y).sort();assert.deepEqual(kx,ky);for(const k of kx){const dx=Object.getOwnPropertyDescriptor(x,k),dy=Object.getOwnPropertyDescriptor(y,k);assert('value'in dx&&'value'in dy);todo.push([dx.value,dy.value])}}
 return{completeDataEqual:true,objects};}
// Unknown declaration names can survive raw parsing; type checking is a later stage.
const rawCases=[
 ['datatype','type Bit is Data:\n  Off{}\n  Onn{}\ndef keep() -> Bit:\n  Off{}\n',true],
 ['law-fill','type Bit is Data:\n  Off{}\nlaw early:\n  Bit\ndef middle() -> Bit:\n  Off{}\ndef early():\n  Off{}\n',true],
 ['duplicate-definition','type Bit is Data:\n  Off{}\ndef keep() -> Bit:\n  Off{}\ndef keep() -> Bit:\n  Off{}\n',false],
 ['template','type Bit is Data:\n  Off{}\ndef ident(~A: Type, x: A) -> A:\n  x\ndef use() -> Bit:\n  ident(~Bit, Off{})\n',true],
 ['template-then-parse-error','type Bit is Data:\n  Off{}\ndef ident(~A: Type, x: A) -> A:\n  x\ndef use() -> Bit:\n  ident(~Bit, Off{})\ndef broken(\n',false],
 ['constructor-duplicate','type Bit is Data:\n  Off{}\n  Off{}\n',false],
 ['first-error-spans','type Bit is Data:\n  Off{}\ndef one(\ndef two(\n',false],
 ['marked-quantified','type Box<-A: Type> is Data:\n  Boxed{value: A}\ndef take(x: +Box<Bit>) -> Bit:\n  match x:\n    case Boxed{v}: v\n',null],
 ['missing-marked-type','def wrong(x: +Unknown) -> Unknown:\n  x\n',true],
 ['unicode','type 状態 is Data:\n  良{}\ndef 状態値() -> 状態:\n  良{}\n',null]
];
const frontCases=[
 ['law-fill','import Base\nlaw early:\n  U32\ndef middle() -> U32:\n  1\ndef early():\n  3\ndef main() -> U32:\n  early\n'],
 ['template','import Base\ndef early() -> U32:\n  3\ndef ident(~A: Type, x: A) -> A:\n  x\ndef main() -> U32:\n  ident(~U32, 7)\n'],
 ['type-error-after-template','import Base\ndef ident(~A: Type, x: A) -> A:\n  x\ndef use() -> U32:\n  ident(~U32, 7)\ndef main() -> U32:\n  True{}\n'],
 ['duplicate','import Base\ndef same() -> U32:\n  1\ndef same() -> U32:\n  2\ndef main() -> U32:\n  same\n'],
 ['unfilled-law','import Base\nlaw pending:\n  U32\ndef main() -> U32:\n  0\n'],
 ['hash-collision','import Base\ndef p143CollisionlrXlHP() -> U32:\n  9\ndef main() -> U32:\n  p143CollisionlrXlHP\n'],
 ['typed-do','import Base\ndef main() -> IO(U32):\n  do IO<U32>:\n    Unit <- IO.print("ok")\n    IO.pure(U32, 0)\n']
];
const start=performance.now(),budget=()=>assert(performance.now()-start<110000,'110s soft budget; hard guard required');
function digest(api,plan){const emission=tag(api.p134e_plan(plan),'P134Planned'),hash=crypto.createHash('sha256');let bytes=0,pieces=0,cursor=api.p134e_begin(emission.plan);while(true){const step=api.p134e_next(cursor);if(step.$==='P134Done')break;tag(step,'P134Piece');assert.equal(typeof step.legacy_end,'boolean');assert.equal(typeof step.text,'string');assert(++pieces<2000000);for(const text of step.legacy_end?[step.text,'\n']:[step.text]){const b=Buffer.from(text);hash.update(b);bytes+=b.length;assert(bytes<16*1024*1024)}cursor=step.next}return{bytes,sha256:hash.digest('hex'),pieces}}
save();
try{
 const apis={};for(const [role,rec] of Object.entries(recs))apis[role]=(await import(pathToFileURL(rec.api.file))).default;
 report.controls=arr(apis.candidate.p144pc_controls());assert.equal(report.controls.length,27);assert(report.controls.every(r=>/^[^\n]+:pass$/.test(r)),JSON.stringify(report.controls));save();
 for(const [name,text,success] of rawCases){budget();const source=out+'/raw-'+name+'.bend';fs.writeFileSync(source,text);file(source);
  const values={},calls=[];for(const role of ['original','candidate']){const r=time(()=>tag(apis[role].f_load_graph('Unit',list([{$:'FSource',name:'Unit',path:source,text}])),'FResult'));values[role]=r.value;calls.push({role,seconds:r.seconds})}
  const row={name,calls,...equal(values.original,values.candidate),error:values.original.error};report.raw.push(row);save();
  if(success!==null)assert.equal(values.original.error==='',success,'Independent expected parser verdict: '+name);
 }
 const seeds={};report.basePreparation={};for(const role of ['original','candidate']){budget();const r=time(()=>tag(apis[role].p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(selected.preferredCarrier.file,'utf8'),selected.preferredStamp),'P86PreparationReady'));seeds[role]=r.value.seed;report.basePreparation[role]=r.seconds}
 for(const [name,text] of frontCases){budget();const source=out+'/front-'+name+'.bend';fs.writeFileSync(source,text);file(source);const values={},calls=[];
  for(const role of ['original','candidate']){const r=time(()=>apis[role].p86_plan(seeds[role],source,text));values[role]=r.value;calls.push({role,seconds:r.seconds})}
  report.frontend.push({name,calls,...equal(values.original,values.candidate),tag:values.original.$,error:values.original.error||'',verdict:values.original.verdict||''});save();
 }
 for(const name of ['lexer','coverage-map-churn-128','coverage-closures-256']){budget();const ref=refs.cases.find(c=>c.name===name);assert(ref);add(ref.source);add(ref.expectedQbe);const text=fs.readFileSync(ref.source.file,'utf8');const row={name,source:ref.source,rounds:[]};report.frozen.push(row);let last;
  for(let round=0;round<3;round++){const order=round%2?['candidate','original']:['original','candidate'],values={},calls=[];
   for(const role of order){budget();const r=time(()=>tag(apis[role].p86_plan(seeds[role],ref.source.file,text),'P86PlanReady'));values[role]=r.value;calls.push({role,seconds:r.seconds})}
   row.rounds.push({round,order,calls,...equal(values.original,values.candidate)});last=values;save();
  }
  row.medians=Object.fromEntries(['original','candidate'].map(role=>[role,median(row.rounds.flatMap(r=>r.calls.filter(c=>c.role===role).map(c=>c.seconds)))]));row.ratio=row.medians.candidate/row.medians.original;
  row.products={};for(const role of ['original','candidate']){budget();const r=time(()=>digest(apis[role],last[role]));assert.equal(r.value.bytes,ref.expectedQbe.bytes);assert.equal(r.value.sha256,ref.expectedQbe.sha256);row.products[role]={...r.value,seconds:r.seconds}}
  row.complete=true;save();
 }
 for(const p of inputs.values())add(p);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1}
finally{report.seconds=(performance.now()-start)/1000;report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,controls:report.controls.length,raw:report.raw.length,frontend:report.frontend.length,frozen:report.frozen.length,error:report.error}))}
