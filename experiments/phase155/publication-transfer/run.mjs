// Generic input transport and exact observation only. All publication logic is Bend.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import crypto from 'node:crypto';
import{pathToFileURL}from'node:url';import{encodeGraph,writeGraph}from'../../phase154/tools/graph.mjs';
const args={};for(let i=2;i<process.argv.length;i+=2)args[process.argv[i].slice(2)]=process.argv[i+1];
const root=path.resolve(import.meta.dirname,'../../..'),read=p=>JSON.parse(fs.readFileSync(p));
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=x=>assert.deepEqual(pin(x.file),x),plan=read(args.manifest),receipt=read(plan.apiReport),out=path.resolve(args.out);
assert(plan.complete&&receipt.complete&&receipt.checked);assert.deepEqual(receipt.source,plan.source);
assert(out.startsWith(root+'/selfhost/build/phase155/')&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const inputs=[pin(import.meta.filename),pin(args.manifest),pin(plan.apiReport),receipt.api,plan.source,...plan.inputs];inputs.forEach(verify);
const report={kind:'phase155-actual-publication-transfer',complete:false,passed:false,inputs,rows:[],controls:[],
 scope:'Exact raw P155PTResult comparisons on real source-order events. Every result contains full book/index, seen history, error, processed count and admission. Clocks are hosted diagnostics, not native performance.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
const list=xs=>xs.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$:'Nil'});
const truth=v=>v===true||v?.$==='True';
try{
 const api=(await import(pathToFileURL(receipt.api.file))).default;
 for(const n of [0,1,2,3,4,5,4294967295]){const actual=api.p155pt_controls(n);assert.equal(actual,'1');report.controls.push({n,actual,passed:true});save()}
 for(const family of plan.families){
  const row={name:family.name,source:family.source,complete:false,points:[]};report.rows.push(row);save();
  const start=performance.now(),trace=api.f_load_graph_trace('Unit',list([
   {$:'FSource',name:'Base',path:plan.base.file,text:fs.readFileSync(plan.base.file,'utf8')},
   {$:'FSource',name:'Unit',path:family.source.file,text:fs.readFileSync(family.source.file,'utf8')} ]));
  row.loadSeconds=(performance.now()-start)/1000;assert.equal(trace.$,'FLoadTrace');assert.equal(trace.result.error,'');
  const events=trace.result.book;assert(truth(api.p155pt_admitted(events)),'Actual event stream outside explicit admission');
  const graphFile=out+'/'+family.name+'-input.graph.json';writeGraph(graphFile,encodeGraph(trace));row.input=pin(graphFile);save();
  for(const limit of plan.limits){
   const point={limit,passed:false};row.points.push(point);save();
   const begin=performance.now(),old=api.p155pt_05_raw_old(events,limit);point.oldSeconds=(performance.now()-begin)/1000;
   assert(truth(old.admitted));assert.equal(old.error,'','Real source event guard failed');
   const a=performance.now(),five=api.p155pt_05_raw_new(events,limit);point.new05Seconds=(performance.now()-a)/1000;assert.deepEqual(five,old,'05 complete output');
   const b=performance.now(),seven=api.p155pt_07_raw_new(events,limit);point.new07Seconds=(performance.now()-b)/1000;assert.deepEqual(seven,old,'07 complete output');
   // A single exact result capture serves both comparisons; no hash is the oracle.
   const file=out+'/'+family.name+'-'+limit+'-result.graph.json';writeGraph(file,encodeGraph(old));point.result=pin(file);
   point.processed=old.processed;point.passed=true;save();
  }
  row.complete=true;save();
 }
 inputs.forEach(verify);report.complete=report.passed=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1}
finally{save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,rows:report.rows.map(r=>({name:r.name,complete:r.complete,points:r.points.length})),error:report.error}))}
