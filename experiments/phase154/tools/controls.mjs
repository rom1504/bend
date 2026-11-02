// Independent original/candidate comparisons; host transports values only.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import crypto from 'node:crypto';import{pathToFileURL}from'node:url';
import{decodeGraph}from'./graph.mjs';
const a={};for(let i=2;i<process.argv.length;i+=2)a[process.argv[i].slice(2)]=process.argv[i+1];
for(const k of ['api','capture','out'])assert(a[k]);
const root=path.resolve(import.meta.dirname,'../../..'),out=path.resolve(a.out);assert(out.startsWith(root+'/selfhost/build/phase154/')&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const read=p=>JSON.parse(fs.readFileSync(p)),pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=p=>{const x=pin(p.file);assert.equal(x.sha256,p.sha256);assert.equal(x.bytes,p.bytes)};
const list=xs=>xs.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$:'Nil'});
const inputs=[pin(import.meta.filename),pin(path.join(import.meta.dirname,'graph.mjs')),pin(a.api),pin(a.capture)];
const report={kind:'phase154-controls',version:1,complete:false,passed:false,inputs,rows:[],scope:'Full original/numeric producer structures, scalar transforms, independent original verifier and complete QBE text. No candidate-generated machine code executed.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
try{
 const receipt=read(a.api);assert(receipt.complete&&receipt.checked);inputs.push(receipt.source,receipt.api);inputs.forEach(verify);report.source=receipt.source;report.api=receipt.api;
 const api=(await import(pathToFileURL(receipt.api.file))).default,capture=read(a.capture);assert(capture.complete);
 function scalar(name,fn,expected){const original=api.p113k_function(fn),candidate=api.p154c_decode_function(api.p154k_function(api.p154c_function(fn)));if(expected)assert.deepEqual(original,expected,name+' fixed expectation');assert.deepEqual(candidate,original,name+' scalar equality');return{original,candidate};}
 const historical=path.join(root,'selfhost/tests/phase148/control-fixtures.json');inputs.push(pin(historical));
 for(const c of read(historical).cases){scalar(c.name,c.function,c.expectedOptimized);report.rows.push({name:c.name,kind:'fixed-scalar',passed:true});}
 const extra=path.join(root,'selfhost/tests/phase154/scalar-controls.json');
 if(fs.existsSync(extra)){inputs.push(pin(extra));const d=read(extra);for(const c of d.cases){scalar(c.name,c.function,c.expectedOptimized);report.rows.push({name:c.name,kind:'extra-scalar',passed:true});}}
 for(const family of capture.rows){verify(family.graph);verify(family.headers);inputs.push(family.graph,family.headers);const data=decodeGraph(read(family.graph.file)),headers=read(family.headers.file);
  const segments=list(headers.segments),constructors=list(headers.constructors),functions=list(headers.functions??headers.directHeaders);
  const ids={$:'N111Ids',functions:api.p113e_originals(segments,api.missing()),constructors:api.ns_ctor_index(constructors,api.missing())};
  const render={$:'N111Ids',functions:api.p111q_function_ids(segments,0,api.missing()),constructors:api.p111q_constructor_ids(constructors,0,api.missing())};
  const readyAll=functions;
  const extraNames=family.name==='compiler-verifier-slice'?['p111v_value','p111v_counted_call']:['Map.ins.splice.bit','Map.pop.lo'];
  const observed=[...data.selectedOwners,...extraNames.filter(n=>!data.selectedOwners.some(o=>o.name===n)).map((name,i)=>({name,reachIndex:'extra'+i}))];
  for(const owner of observed){const row={family:family.name,name:owner.name,kind:'producer-complete',complete:false};report.rows.push(row);save();
   const old=api.p113d_candidate(data.request.book,owner.name),next=api.p154d_candidate(data.request.book,owner.name);
   assert.equal(old.$,'P113DCandidate');assert.equal(next.$,'P154DCandidate');assert.equal(next.error,old.error,owner.name+' exact producer error');assert.deepEqual(next.calls,old.calls,owner.name+' exact dependencies');
   const decoded=api.p154c_decode_function(next.function);assert.deepEqual(decoded,old.function,owner.name+' exact raw producer structure');row.producerExact=true;
   if(old.error){row.refused=old.error;row.complete=true;save();continue;}
   const of=api.p113k_function(old.function),nf=api.p154c_decode_function(api.p154k_function(next.function));assert.deepEqual(nf,of,owner.name+' exact optimized structure');row.scalarExact=true;
   const retained=[];for(let xs=readyAll;xs.$==='Con';xs=xs.tail){if(xs.head.name===of.name)break;retained.push(xs.head);}
   const ready=api.p113e_signatures(list(retained),api.missing());
   const originalError=api.p113e_function(of,ids,ready),candidateError=api.p113e_function(nf,ids,ready);assert.equal(candidateError,originalError);row.verifierError=originalError;
   if(originalError){row.complete=true;save();continue;}
   const text=api.p113e_private(of,render),nt=api.p113e_private(nf,render);assert.equal(nt,text);assert(!text.includes('INVALID_'));assert(text.length);
   const file=out+'/'+family.name+'-'+owner.reachIndex+'.ssa';fs.writeFileSync(file,text,{flag:'wx'});row.oracle=pin(file);row.outputExact=true;row.complete=true;save();
  }
 }
 inputs.forEach(verify);report.complete=report.passed=true;
}catch(e){report.error=String(e.stack??e);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,rows:report.rows.length,error:report.error}))}
