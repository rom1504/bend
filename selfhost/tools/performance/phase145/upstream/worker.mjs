// Measurement/observation only. Original Bend code performs every compiler operation.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
const [planFile,caseName,variant,outArg]=process.argv.slice(2),plan=JSON.parse(fs.readFileSync(planFile)),out=path.resolve(outArg),fixture=plan.cases.find(c=>c.name===caseName);
assert(fixture&&['original','clean','counted'].includes(variant));assert(!fs.existsSync(out));fs.mkdirSync(out);
const hash=b=>crypto.createHash('sha256').update(b).digest('hex'),pin=f=>{f=fs.realpathSync(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:hash(b)}};
const verify=p=>assert.deepEqual(pin(p.file),p,p.file),timings={},counts={},stages={},stack=[],seen=new Map();let phase=null;
const report={kind:'phase145-upstream-operation-observation',complete:false,caseName,variant,fixture,timings,counts,stages,inputs:[pin(planFile),pin(import.meta.filename),...plan.inputs],scope:'Fresh process. Source Base loaded and checked every request. Parse is nested in load; erasure is fused into checking (Def.e), not a separate timed pass. C emission is not QBE emission. Counted clocks are diagnostic and cannot replace clean timings.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
function observe(name,fn,args,termIndex,timed){
 if(!phase)return fn(...args);
 const key=phase+':'+name,r=counts[key]??={calls:0};r.calls++;
 if(termIndex!==null){const value=args[termIndex];if(value&&typeof value==='object'){
  const objects=seen.get(key)||new WeakSet();seen.set(key,objects);const duplicate=objects.has(value);objects.add(value);
  r.distinctObjectEntries=(r.distinctObjectEntries||0)+(duplicate?0:1);r.revisitedObjectEntries=(r.revisitedObjectEntries||0)+(duplicate?1:0);
  const tag=typeof value.$==='string'?value.$:'untagged';r.tags??={};r.tags[tag]=(r.tags[tag]||0)+1;
 }}
 if(name==='bend.def_check'){r.names??={};r.names[args[1]]=(r.names[args[1]]||0)+1;}
 if(name==='comp.file_push'){r.utf16Units=(r.utf16Units||0)+args[1].length;}
 if(name==='comp.memo'){const hit=args[0].get(args[1])!==undefined;r[hit?'hits':'misses']=(r[hit?'hits':'misses']||0)+1;}
 if(!timed)return fn(...args);
 const frame={start:performance.now(),children:0};stack.push(frame);
 try{return fn(...args)}finally{const ms=performance.now()-frame.start;assert.equal(stack.pop(),frame);if(stack.length)stack.at(-1).children+=ms;const s=stages[key]??={calls:0,inclusiveSeconds:0,exclusiveOfOtherObservedStagesSeconds:0};s.calls++;s.inclusiveSeconds+=ms/1000;s.exclusiveOfOtherObservedStagesSeconds+=(ms-frame.children)/1000;}
}
globalThis.__p145Observe=observe;
globalThis.__p145Point=(name,value)=>{
 if(!phase)return;
 const r=counts[phase+':'+name]??={calls:0};r.calls++;
 if(typeof value==='string'){r.tags??={};r.tags[value]=(r.tags[value]||0)+1;}
 else{r.values??=[];assert(r.values.length<1000,'Bounded fact rounds');r.values.push(value);}
};
async function timed(name,f){phase=name;const start=performance.now();try{return await f()}finally{timings[name]=(performance.now()-start)/1000;phase=null;save()}}
function summary(book){const es=Object.entries(book.tlds);return{events:book.order.length,orderedEventsSha256:hash(JSON.stringify(book.order)),definitions:es.filter(([,d])=>d.$==='Def').length,datatypes:es.filter(([,d])=>d.$==='ADT').length,constructors:Object.keys(book.ctrs).length,erasedBodies:es.filter(([,d])=>d.$==='Def'&&d.e!==undefined).length,holes:book.hols,namesAndKindsSha256:hash(JSON.stringify(es.map(([n,d])=>[n,d.$,d.n,d.x,d.b??false,d.e!==undefined])))}}
const started=performance.now();
try{
 plan.inputs.forEach(verify);assert.equal(fs.realpathSync(process.execPath),plan.bun.file);
 let sources;
 if(variant==='original')sources=plan.upstream;
 else{const genFile=plan.artifactDirectory+'/report.json',gen=JSON.parse(fs.readFileSync(genFile));assert(gen.complete);gen.inputs.forEach(verify);report.inputs.push(pin(genFile));sources=Object.fromEntries(gen.modules.map(m=>[m.module,m[variant]]));Object.values(sources).forEach(p=>{verify(p);report.inputs.push(p)});}
 const B=await timed('imports',()=>import(pathToFileURL(sources.bend.file))),C=await timed('compilerImport',()=>import(pathToFileURL(sources.comp.file)));
 assert.equal(fs.realpathSync(B.BASE_BEND),plan.base.file);
 const book=B.book_nil();await timed('load',()=>B.book_load(book,fixture.source.file,'',new Map()));report.loaded=summary(book);save();
 if(fixture.mode==='compile'){
  await timed('check',()=>B.book_valid(book));assert.equal(book.hols,0);report.checked=summary(book);save();
  const code=await timed('emit',()=>C.compile_book(book));assert(Buffer.byteLength(code)<=64*1024*1024,'Bounded C text');
  const start=performance.now();fs.writeFileSync(out+'/program.c',code,{flag:'wx'});report.product=pin(out+'/program.c');timings.outputWriteAndHash=(performance.now()-start)/1000;
 }
 if(variant!=='original'){
  const oldFile=path.join(plan.out,caseName+'-original/report.json'),old=JSON.parse(fs.readFileSync(oldFile));assert(old.complete&&old.variant==='original');report.oracle=pin(oldFile);
  assert.deepEqual(report.loaded,old.loaded);assert.deepEqual(report.checked,old.checked);
  if(fixture.mode==='compile'){verify(old.product);assert(fs.readFileSync(report.product.file).equals(fs.readFileSync(old.product.file)),'Complete original C output must match');report.exactOriginalC=true;}
 }
 plan.inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{phase=null;report.seconds=(performance.now()-started)/1000;report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,caseName,variant,timings,error:report.error}));}
