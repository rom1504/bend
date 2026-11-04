// Transport and exact comparison only. All compiler/probe algorithms run in Bend.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {encodeGraph,decodeGraph,writeGraph} from '../../phase154/tools/graph.mjs';
const root=path.resolve(import.meta.dirname,'../../..'),a={};
for(let i=2;i<process.argv.length;i+=2)a[process.argv[i].slice(2)]=process.argv[i+1];
const read=p=>JSON.parse(fs.readFileSync(p)),pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=x=>{const y=pin(x.file);assert.equal(y.bytes,x.bytes);assert.equal(y.sha256,x.sha256)};
const list=xs=>xs.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$:'Nil'});
function items(xs){const out=[];while(xs.$==='Con'){out.push(xs.head);xs=xs.tail}assert.equal(xs.$,'Nil');return out}
const bool=x=>typeof x==='boolean'?x:x.$==='True';
const out=path.resolve(a.out);assert(out.startsWith(root+'/selfhost/build/phase156/')&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const prep=read(a.manifest),apiReceipt=read(prep.apiReport),inputSpec=read(a.inputs);
assert(apiReceipt.complete&&apiReceipt.checked&&prep.complete);assert.deepEqual(apiReceipt.source,prep.source);
const fixturesPath=root+'/experiments/phase156/publication/fixtures.json';
const inputs=[pin(import.meta.filename),pin(root+'/experiments/phase154/tools/graph.mjs'),pin(a.manifest),pin(prep.apiReport),pin(a.inputs),pin(fixturesPath),apiReceipt.source,apiReceipt.api,...prep.inputs,inputSpec.base,...inputSpec.cases.map(c=>c.source)];
const report={kind:'phase156-semantic-transfer-controls',complete:false,passed:false,inputs,source:prep.source,rows:[],dense:[],scope:'Raw full-result comparisons, explicit independent success expectations, actual routing and original producer eligibility. Hosted clocks are diagnostics only.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
function record(name,work){const row={name,passed:false};report.rows.push(row);try{work(row);row.passed=true}catch(e){row.error=String(e.stack??e)}save()}
function snapshot(name,value){const file=out+'/'+name+'.graph.json';writeGraph(file,encodeGraph(value));return pin(file)}
try{
 inputs.forEach(verify);const api=(await import(pathToFileURL(apiReceipt.api.file))).default;
 record('uses-eleven-controls',row=>{row.actual=items(api.p156u_controls());assert.equal(row.actual.length,11);assert(row.actual.every(x=>x.endsWith(':pass')));assert(bool(api.p156u_controls_ok()))});
 for(const fixture of read(fixturesPath).cases){
  record('publication-'+fixture.name,row=>{
   const name='/phase156/'+fixture.name+'.bend';const loaded=api.f_load_graph_trace(name,list([{$:'FSource',name:name,path:name,text:fixture.source}]));
   assert.equal(loaded.result.error,'','independent parse success');const book=loaded.result.book;
   const original=api.p156cp_reference_check(book,true),candidate=api.p143cp_check(book,true);
   assert.equal(original.result.error==='',fixture.success,'independent checker success');assert.deepEqual(candidate,original);
   assert.deepEqual(api.p143cp_check(book,false),api.p156cp_reference_check(book,false));
   const independent=api.dg_check_world(book);assert.equal(independent.result.error,original.result.error,'independent legacy error');
   row.success=original.result.error==='';row.checkerError=original.result.error;row.fullResult=snapshot('fixture-'+fixture.name,{book,original,candidate});
  });
 }
 let prepared;
 record('real-Base-preparation',row=>{prepared=api.p86_prepare(inputSpec.base.file,fs.readFileSync(inputSpec.base.file,'utf8'));assert.equal(prepared.$,'P86PreparationReady',prepared.error);row.ready=true});
 if(prepared?.$==='P86PreparationReady'){
  for(const c of inputSpec.cases)record('actual-checker-'+c.name,row=>{
   const loaded=api.p156cp_load(prepared.seed,c.source.file,fs.readFileSync(c.source.file,'utf8'));
   assert.equal(loaded.$,'P156CLoadReady',loaded.error);const load=loaded.load;
   assert.equal(load.trace.result.error,'');row.suffixDefinitions=items(load.suffix).length;row.publicationRoute=bool(api.p156cp_enabled(load));
   assert.equal(row.publicationRoute,c.name==='compiler-checker','actual route expectation');
   const begin=performance.now(),original=api.p156cp_route(prepared.seed.world,load,false);row.originalDiagnosticSeconds=(performance.now()-begin)/1000;
   const next=performance.now(),candidate=api.p156cp_route(prepared.seed.world,load,true);row.candidateDiagnosticSeconds=(performance.now()-next)/1000;
   assert.equal(original.result.error,'','actual successful checking');assert.deepEqual(candidate,original);
   row.fullResult=snapshot('actual-'+c.name,{original});
  });
 }
 const capturePath=root+'/selfhost/build/phase154/capture-plan05/capture/report.json',capture=read(capturePath),prior=read(root+'/selfhost/build/phase154/controls03/report.json');
 assert(capture.complete&&prior.complete&&prior.passed);inputs.push(pin(capturePath),pin(root+'/selfhost/build/phase154/controls03/report.json'));
 for(const family of capture.rows){verify(family.graph);inputs.push(family.graph);const data=decodeGraph(read(family.graph.file));
  const names=prior.rows.filter(r=>r.family===family.name&&r.kind==='producer-complete').map(r=>r.name);
  for(const name of names){const produced=api.p154d_candidate(data.request.book,name),row={family:family.name,name,producerError:produced.error};
   if(!produced.error)row.audit=api.p156d_eligibility(produced.function);report.dense.push(row);save();}
 }
 inputs.forEach(verify);report.complete=true;report.passed=report.rows.every(r=>r.passed);
}catch(e){report.error=String(e.stack??e);process.exitCode=1}
finally{save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,rows:report.rows.length,failed:report.rows.filter(r=>!r.passed).map(r=>r.name),dense:report.dense.length,error:report.error}))}
