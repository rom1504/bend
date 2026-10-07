// Frozen checked-image differential controls; root supplies the process guard.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
const [baseArg,candArg,outArg]=process.argv.slice(2);assert(baseArg&&candArg&&outArg);
const root=path.resolve(import.meta.dirname,'../../../../../'),raw=path.join(root,'selfhost/build/phase61');
const out=path.resolve(outArg);assert(out.startsWith(raw+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const inputs=new Map(),hash=b=>createHash('sha256').update(b).digest('hex');
function pin(f,want){const b=fs.readFileSync(f),r={file:fs.realpathSync(f),bytes:b.length,sha256:hash(b)};if(want){assert.equal(r.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(r.bytes,want.bytes);}inputs.set(r.file,r);return r;}
const report={kind:'phase61-checked-batch-index-controls',complete:false,pass:false,roles:{},rows:[],inputs:[],
 scope:'Exact frozen checked B1 APIs with inert lexical probes; comparison is sequential book_put and ordinary selected-context delegation, not new public raw-getter or list-cell identity contract.'};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};save();
const Nil=()=>({$:'Nil'}),list=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),Nil());
function array(xs){const a=[];while(xs.$==='Con'){assert(a.length<20000);a.push(xs.head);xs=xs.tail;}assert.equal(xs.$,'Nil');return a;}
const term=()=>({$:'KTerm',tag:'Absent',name:'',id:0,quant:0,kids:Nil(),removed:Nil(),originBegin:0,originEnd:0});
const def=(name,arity=0,kind='Def')=>({$:'KDef',name,kind,arity,templates:0,typ:term(),value:term(),ctors:Nil(),native:false,unsafe:false});
const snapshot=x=>JSON.parse(JSON.stringify(x));
try{
 pin(import.meta.filename);pin(process.execPath);pin(new URL('../../../development/workflow.mjs',import.meta.url).pathname);
 const parserText=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],P={exports:{}};new Function('module','exports',parserText)(P,P.exports);
 report.parser={version:P.exports.version,sha256:hash(parserText)};const parse=s=>P.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
 const roles={};
 for(const [role,arg] of [['baseline',baseArg],['candidate',candArg]]){
  const directory=fs.realpathSync(arg),attempt=pin(path.join(directory,'attempt.json')),m=await verifyAttempt(directory);assert(m.checked);
  const validationPin=pin(path.join(directory,'validation-001/report.json')),v=JSON.parse(fs.readFileSync(validationPin.file));
  assert(v.complete&&v.pass);assert(v.selected.selectedComplete);assert.equal(v.selected.exactDifferences,0);assert.equal(v.selected.discrepancies,0);
  pin(v.attempt.file,v.attempt);assert.equal(v.attempt.sha256,attempt.sha256);pin(v.api.file,v.api);assert.equal(v.api.sha256,m.api.sha256);
  for(const k of ['api','runtime','base','node'])pin(m[k].file,m[k]);
  const source=pin(path.join(m.snapshot.root,'src/core/index.bend'));let text=fs.readFileSync(m.api.file,'utf8');const original=text,ast=parse(text);
  const required=['run_loop','$book_put$','$book_cached$','$lookup$','$jd_selected_context$'];
  const counters=role==='candidate'?['book_put_many','book_put_many_fast','book_put_many_legacy']:[];
  const edits=[];for(const name of [...required,...counters.map(n=>'$'+n+'$')]){
   const declarations=ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id?.name===name);assert.equal(declarations.length,1,name);
   if(counters.includes(name.slice(1,-1)))edits.push({at:declarations[0].body.start+1,text:'$p61BatchCounts.'+name.slice(1,-1)+'++;'});
  }
  for(const edit of [...edits].sort((a,b)=>b.at-a.at))text=text.slice(0,edit.at)+edit.text+text.slice(edit.at);
  const suffix='\nexport const phase61Batch={counts:{book_put_many:0,book_put_many_fast:0,book_put_many_legacy:0},put:(b,d)=>run_loop($book_put$(b,d)),cached:(b,n)=>run_loop($book_cached$(b,n)),lookup:(b,n)=>run_loop($lookup$(b,n)),selected:(b,ds)=>run_loop($jd_selected_context$(b,ds))};\nconst $p61BatchCounts=phase61Batch.counts;\n';
  text+=suffix;parse(text);const derived=path.join(out,role+'-probe.mjs');fs.writeFileSync(derived,text,{flag:'wx'});const derivedPin=pin(derived);
  const invert=text.slice(0,-suffix.length);let recovered=invert;let delta=0;
  for(const edit of [...edits].sort((a,b)=>a.at-b.at)){const at=edit.at+delta;assert.equal(recovered.slice(at,at+edit.text.length),edit.text);recovered=recovered.slice(0,at)+recovered.slice(at+edit.text.length);}
  assert.equal(recovered,original);
  const mod=await import(pathToFileURL(derived));assert.equal(mod.G,undefined);roles[role]=mod.phase61Batch;
  report.roles[role]={attempt,api:m.api,indexSource:source,validation:validationPin,derivative:derivedPin,edits,suffixSha256:hash(suffix),strictExact:m.config.strictExact};save();
 }
 const {baseline:B,candidate:C}=roles;
 const cases=[['empty',[],[],false],['empty-cache',[],[],true],['single',[],[def('a',1)],false],
 ['duplicates',[def('a',1),def('a',2),def('b',3)],[def('a',4),def('c',5),def('a',6)],true],
 ['empty-name',[def('',1),def('a',2)],[def('',3),def('b',4),def('',5)],true],
 ['collisions',[def('costarring',1),def('liquid',2)],[def('liquid',3),def('costarring',4)],true],
 ['unicode',[def('🙂',1),def('α',2)],[def('α',3),def('é',4)],true],
 ['surrogate',[def('a',1)],[def('\ud800',2),def('a',3)],true],
 ['sentinel-incoming',[def('a',1)],[def('$kernel.cache',17,'BookCache')],false],
 ['large',Array.from({length:300},(_,i)=>def('n'+i,i)),Array.from({length:300},(_,i)=>def('n'+(i%173),i+1000)),true]];
 function outcome(f){try{return {value:f()};}catch(e){return {error:{type:typeof e,name:e?.name,message:e?.message??String(e)}};}}
 for(const [id,old,ds,cached] of cases){
  const b=cached?B.cached(list(old),91):list(old),c=cached?C.cached(list(old),91):list(old);
  const beforeB=snapshot(b),beforeC=snapshot(c),beforeDs=snapshot(ds),counts={...C.counts};
  const want=outcome(()=>ds.reduce((acc,d)=>B.put(acc,d),b)),actual=outcome(()=>C.selected(c,list(ds)));
  assert.deepEqual(actual,want,id);assert.deepEqual(b,beforeB);assert.deepEqual(c,beforeC);assert.deepEqual(ds,beforeDs);
  if(actual.value&&ds.length===0)assert.equal(actual.value,c,id+' original empty identity');
  if(actual.value){const av=array(actual.value),bv=array(want.value);assert.equal(av.length,bv.length);for(let i=0;i<av.length;i++)if(av[i].kind!=='BookCache')assert.equal(av[i],bv[i],id+' retained definition alias');}
  if(actual.value)for(const name of new Set([...old,...ds].map(d=>d.name)))assert.deepEqual(C.lookup(actual.value,name),B.lookup(want.value,name),id+' lookup '+name);
  if(ds.length)assert(C.counts.book_put_many>counts.book_put_many,id+' ordinary delegation');
  report.rows.push({id,pass:true,result:actual.error??{names:array(actual.value).map(d=>d.name)},counterDelta:Object.fromEntries(Object.keys(counts).map(k=>[k,C.counts[k]-counts[k]]))});save();
 }
 // Deliberately stale: empty trie but retained declaration has target name.
 for(const name of ['stale','costarring']){
  const b=B.cached(Nil(),77),c=C.cached(Nil(),77);b.tail=list([def(name,1),def('keep',2)]);c.tail=list([def(name,1),def('keep',2)]);
  const ds=[def(name,3),def(name,4)],before=C.counts.book_put_many_legacy;
  assert.deepEqual(C.selected(c,list(ds)),ds.reduce((acc,d)=>B.put(acc,d),b));
  assert(C.counts.book_put_many_legacy>before,'stale fallback');report.rows.push({id:'stale-'+name,pass:true});save();
 }
 for(const input of inputs.values())pin(input.file,input);report.complete=true;report.pass=true;save();
}catch(error){report.error=error.stack??String(error);save();throw error;}
