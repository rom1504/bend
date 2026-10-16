// Root-only checked-API diagnostic. No C build or native program execution.
// bun admission.mjs CHECKED_API.mjs PROGRAM.bend FRESH_OUT [root,...]
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [apiArg, sourceArg, outArg, rootArg='index_lines']=process.argv.slice(2);
assert(apiArg && sourceArg && outArg);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(root+'/selfhost/build/phase102/'));
fs.mkdirSync(out,{recursive:false});
const hash=b=>createHash('sha256').update(b).digest('hex');
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:hash(b)};};
const unlist=xs=>{const a=[];while(xs?.$==='Con'){a.push(xs.head);xs=xs.tail;}assert.equal(xs?.$,'Nil');return a;};
const report={complete:false,method:pin(import.meta.filename),api:pin(apiArg),source:pin(sourceArg),roots:rootArg.split(','),scope:'Worker admission/dependency diagnostics; checked module bytes retained as unchanged prefix. Diagnostic hooks record unsupported lowering entries and call the original functions unchanged. No performance/promotion claim.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
try {
  const original=fs.readFileSync(apiArg,'utf8');
  const names=['ns_prepare','nc_bangs_names','no_effect_definitions','ns_definitions','nf_plan_scoped','nc_body'];
  const hooks=['nf_slow_app','nf_lambda','nf_match_value','nf_parallel','nf_call_local'];
  for(const name of [...names,...hooks])assert.equal(original.split('function $'+name+'$(').length,2,name);
  let addition='\n// Phase102 diagnostic exports/hooks; original checked prefix unchanged.\n';
  addition+='export const phase102Trace={records:[],owners:new Set()};\n';
  addition+=`function p102Shape(t,depth=0) {
    if(!t||typeof t!=='object')return t;
    const s={tag:t.tag??t.$,name:t.name,id:t.id,quant:t.quant};
    if(depth<3&&t.kids){s.kids=[];let xs=t.kids;while(xs?.$==='Con'&&s.kids.length<5){s.kids.push(p102Shape(xs.head,depth+1));xs=xs.tail;}}
    return s;
  }\n`;
  for(const name of hooks) {
    addition+='const p102_original_'+name+'=$'+name+'$;\n';
    addition+='$'+name+'$=function(...args){const target=args[4];'
      +'if(target?.$==="NC_Destination"&&phase102Trace.owners.has(target.owner)&&phase102Trace.records.length<500)'
      +'phase102Trace.records.push({hook:'+JSON.stringify(name)+',owner:target.owner,tail:target.tail,value:p102Shape(args[1])});'
      +'return p102_original_'+name+'(...args);};\n';
  }
  addition+='export const phase102Workers={'+names.map(n=>n+':(...a)=>run_loop($'+n+'$(...a))').join(',')+'};\n';
  const diagnostic=out+'/diagnostic-api.mjs';fs.writeFileSync(diagnostic,original+addition,{flag:'wx'});
  report.diagnostic={...pin(diagnostic),unchangedPrefixBytes:Buffer.byteLength(original),prefixSHA256:hash(original)};
  const module=await import(pathToFileURL(diagnostic)),api=module.default,D=module.phase102Workers,T=module.phase102Trace;
  const transport=JSON.parse(fs.readFileSync(root+'/selfhost/build/phase90/runtime-accessor-transport02/transport.json'));
  report.base=pin(transport.base.file);assert.equal(report.base.sha256,transport.base.sha256);
  const prepared=api.p86_prepare(transport.base.file,fs.readFileSync(transport.base.file,'utf8'));
  assert.equal(prepared.$,'P86PreparationReady',prepared.error);
  const planned=api.p86_plan(prepared.seed,path.resolve(sourceArg),fs.readFileSync(sourceArg,'utf8'));
  assert.equal(planned.$,'P86PlanReady',planned.error);
  const request=planned.request,book=D.ns_prepare(request.book,request.names);
  const bangs=D.nc_bangs_names(book,request.names);
  const observers=D.no_effect_definitions(request.book,request.names);
  const sharing=D.ns_definitions(request.book,request.names);
  const plan=D.nf_plan_scoped(book,request.names,bangs,observers,sharing);
  const ready=new Set(unlist(plan.ready)),workers=unlist(plan.workers);
  report.permissions={observers,sharing,bangs:unlist(bangs)};
  report.workers=workers.map(w=>({name:w.name,ready:ready.has(w.name),error:w.code.error,
    codeBytes:Buffer.byteLength(D.nc_body(w.code)),segments:unlist(w.code.segments).length,
    params:unlist(w.params).map(p=>({name:p.name,kind:p.kind.$})),deps:unlist(w.deps),shape:p102ShapeForReport(w.shape)}));
  const byName=new Map(report.workers.map(w=>[w.name,w]));
  const queue=[...report.roots],closure=new Set();
  while(queue.length){const n=queue.shift();if(closure.has(n))continue;closure.add(n);const w=byName.get(n);if(w)queue.push(...w.deps);}
  report.focus=[...closure].map(n=>byName.get(n)??{name:n,absentWorker:true});
  T.owners=new Set([...closure,...[...closure].map(n=>'$product.'+n)]);
  D.nf_plan_scoped(book,request.names,bangs,observers,sharing);
  report.refusals=T.records.filter(r=>r.hook!=='nf_call_local'||(r.value===r.owner&&!r.tail));
  report.allFocusedLoweringEvents=T.records;
  for(const p of [report.method,report.api,report.source,report.base])assert.deepEqual(pin(p.file),p);
  report.complete=true;
} catch(error) {report.error=error.stack??String(error);process.exitCode=1;}
finally {save();}
function p102ShapeForReport(t){return{tag:t.tag??t.$,name:t.name,id:t.id,quant:t.quant};}
console.log(JSON.stringify({complete:report.complete,permissions:report.permissions,focus:report.focus,
  refusals:report.refusals?.slice(0,30),report:out+'/report.json',error:report.error}));
