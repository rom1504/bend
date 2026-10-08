// Root-owned focused private-helper controls; no production or original cache writes.
// node boolean-lookup-v1.mjs CHECKED_ATTEMPT FRESH_PHASE65_OUT
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
const [attemptArg,outArg]=process.argv.slice(2);assert(attemptArg&&outArg);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase65')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=b=>createHash('sha256').update(b).digest('hex'),inputs=new Map();
const pin=(file,want)=>{const real=fs.realpathSync(file),bytes=fs.readFileSync(real),x={file:real,sha256:hash(bytes),bytes:bytes.length};if(want)assert.equal(x.sha256,want.sha256,real);if(inputs.has(real))assert.deepEqual(x,inputs.get(real));inputs.set(real,x);return x;};
const digest=x=>hash(JSON.stringify(x)),list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const array=xs=>{const a=[];while(xs?.$==='Con'){assert(a.length<65536);a.push(xs.head);xs=xs.tail;}assert.equal(xs?.$,'Nil');return a;};
const freeze=x=>{const todo=[x],seen=new Set();while(todo.length){const v=todo.pop();if(v&&typeof v==='object'&&!seen.has(v)){seen.add(v);Object.freeze(v);todo.push(...Object.values(v));}}return x;};
const report={kind:'phase65-boolean-lookup-controls',complete:false,pass:false,lookupControls:[],constructorControls:[],scope:'Exact Boolean projection versus unchanged original lookup; enclosing constructor comparison with its old projection restored, including outer demand order. Pure synthetic raw records and actual Base definitions. No clean speed or full compiler qualification claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
try{
 pin(import.meta.filename);pin(path.join(import.meta.dirname,'boolean-lookup-v1.derivation.json'));pin(new URL('../../../development/workflow.mjs',import.meta.url).pathname);pin(process.execPath);
 const metadataFile=path.resolve(import.meta.dirname,'../cache-contract/boolean-lookup-v1.json');report.candidate=pin(metadataFile);const metadata=JSON.parse(fs.readFileSync(metadataFile));assert.equal(metadata.hypothesis,'P65-008');pin(path.join(root,metadata.patch),{sha256:metadata.patchSha256});
 const attempt=await verifyAttempt(attemptArg);assert(attempt.checked&&attempt.config.strictExact);report.attempt=pin(path.join(attemptArg,'attempt.json'));
 for(const k of ['api','runtime','base','node','bootstrapReport'])pin(attempt[k].file,attempt[k]);assert.equal(pin(process.execPath).sha256,attempt.node.sha256);
 for(const [logical,entry]of Object.entries(metadata.files)){const file=path.join(attempt.snapshot.root,logical.slice('selfhost/'.length));pin(file,{sha256:entry.afterSha256});}
 const original=fs.readFileSync(attempt.api.file,'utf8'),parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],P={exports:{}};new Function('module','exports',parserSource)(P,P.exports);
 const parse=s=>P.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),ast=parse(original),names=['run_loop','$lookup$','$lookup_present$','$dk$','$dc$','$constructor_exists$','$missing$','$book_cached$','$index_hash$'];
 for(const name of names)assert.equal(ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name===name).length,1,name);assert(!original.includes('$p65Lookup'));
 const suffix='\n'+[
 'let $p65LookupOld=false,$p65LookupDepth=0,$p65LookupMissing=0;const $p65LookupTrace=[];',
 'const $p65LookupPrior=$lookup_present$,$p65LookupMissingPrior=$missing$;',
 '$missing$=(...xs)=>{$p65LookupMissing++;return $p65LookupMissingPrior(...xs);};',
 'function $p65LookupOriginal(book,name){return run_loop($dk$(run_loop($lookup$(book,name))))!=="Absent";}',
 '$lookup_present$=(book,name)=>{if($p65LookupDepth===0)$p65LookupTrace.push({book,name});$p65LookupDepth++;try{return $p65LookupOld?$p65LookupOriginal(book,name):run_loop($p65LookupPrior(book,name));}finally{$p65LookupDepth--;}};',
 'function $p65LookupRun(book,name,old,constructor){if($p65LookupDepth!==0)throw Error("Nested lookup control");$p65LookupTrace.length=0;$p65LookupMissing=0;$p65LookupOld=old;try{const value=constructor?run_loop($constructor_exists$(book,name)):(old?$p65LookupOriginal(book,name):run_loop($lookup_present$(book,name)));return {value,missing:$p65LookupMissing,trace:$p65LookupTrace.slice()};}finally{$p65LookupOld=false;}}',
 'export const phase65Lookup={run:$p65LookupRun,cached:b=>run_loop($book_cached$(b,0)),hash:n=>run_loop($index_hash$(n,2166136261)),kind:d=>run_loop($dk$(d)),children:d=>run_loop($dc$(d))};'
 ].join('\n')+'\n';
 parse(original+suffix);const derivative=path.join(out,'queries.mjs');fs.writeFileSync(derivative,original+suffix,{flag:'wx'});report.derivative={parent:attempt.api,output:pin(derivative),appendOnly:true,suffixSha256:hash(suffix),parserSha256:hash(parserSource)};
 const module=await import(pathToFileURL(derivative)),Q=module.phase65Lookup,native=module.default;assert.equal(module.G,undefined);
 const atom=()=>({$:'KTerm',tag:'Absent',name:'',id:0,quant:0,kids:list([]),removed:list([]),originBegin:0,originEnd:0});
 const def=(name,kind='Ctr',ctors=[])=>({$:'KDef',name,kind,arity:0,templates:0,typ:atom(),value:atom(),ctors:list(ctors),native:false,unsafe:false});
 const x=def('x'),y=def('y'),absent=def('x','Absent'),hashX=Q.hash('x');
 const cache=tree=>({...def('$kernel.cache','BookCache',[tree]),native:true});
 const cachedX=array(Q.cached(list([x])))[0],cachedY=array(Q.cached(list([y])))[0];
 const leaf=bucket=>({$:'KIndexLeaf',hash:hashX,bucket:list(bucket)}),node={$:'KIndexNode',hash:hashX,mask:0,left:x,right:def('','Absent')};
 const legacy={...def('legacy','IndexLeaf',[x]),arity:hashX};
 const collisionFile=pin(path.resolve(import.meta.dirname,'../../phase63/controls/base-collision-v1.json')),pair=JSON.parse(fs.readFileSync(collisionFile.file));assert.equal(Q.hash(pair.first),pair.hash);assert.equal(Q.hash(pair.second),pair.hash);
 const collisionLeaf={$:'KIndexLeaf',hash:pair.hash,bucket:list([def(pair.first),def(pair.second)])};
 const cases=[
  ['empty',[],'x',false],['missing',[y],'x',false],['Ctr',[x],'x',true],['Def',[def('x','Def')],'x',true],['ADT',[def('x','ADT')],'x',true],['BookBound',[def('x','BookBound')],'x',true],
  ['first-Absent-masks',[absent,x],'x',false],['first-live-wins',[x,absent],'x',true],['empty-name-live',[def('')],'',true],['empty-name-Absent-masks',[def('','Absent'),def('')],'',false],
  ['index-leaf-empty-name',[leaf([x])],'',true],['index-node-empty-name',[node],'',true],['index-record-other-name',[leaf([x])],'x',false],
  ['cache-hit',[cachedX],'x',true],['cache-miss-masks-tail',[cachedY,x],'x',false],['late-cache-hit',[y,cachedX],'x',true],['late-cache-miss-masks-tail',[y,cachedY,x],'x',false],
  ['first-Absent-before-cache',[absent,cachedX],'x',false],['first-live-before-cache',[x,cachedY],'x',true],['cache-first-bucket-Absent',[cache(leaf([absent,x]))],'x',false],
  ['legacy-cache-index',[cache(legacy)],'x',true],['modern-zero-mask-index',[cache(node)],'x',true],['cache-wrong-hash',[cache({...leaf([x]),hash:(hashX^1)>>>0})],'x',false],
  ['collision-first',[cache(collisionLeaf)],pair.first,true],['collision-second',[cache(collisionLeaf)],pair.second,true],['collision-absent',[cache({...collisionLeaf,bucket:list([def(pair.first)])})],pair.second,false],
  ['unicode-name',[def('a🧭b')],'a🧭b',true],['ordinary-surrogate-name',[def('a\ud800b')],'a\ud800b',true],['surrogate-miss',[def('a\ud800b')],'other',false]
 ];
 function lookupRow(id,book,name,want){const frozen=freeze(book),before=digest(frozen),old=Q.run(frozen,name,true,false),actual=Q.run(frozen,name,false,false);assert.equal(typeof old.value,'boolean');assert.equal(typeof actual.value,'boolean');assert.equal(old.value,want,id+' original');assert.equal(actual.value,old.value,id+' Boolean projection');assert.equal(digest(frozen),before,id+' immutable');if(id==='empty'||id==='missing'){assert(old.missing>0,id+' original missing allocation');assert.equal(actual.missing,0,id+' no missing allocation');}report.lookupControls.push({id,name,value:actual.value,originalMissingCalls:old.missing,candidateMissingCalls:actual.missing,pass:true});}
 for(const [id,defs,name,want]of cases)lookupRow(id,list(defs),name,want);
 function constructorRow(id,book,name,want,checkInput=true){const frozen=checkInput?freeze(book):book,before=checkInput?digest(frozen):null,old=Q.run(frozen,name,true,true),actual=Q.run(frozen,name,false,true);assert.equal(old.value,want,id+' original constructor');assert.equal(actual.value,old.value,id+' constructor projection');assert.deepEqual(actual.trace,old.trace,id+' exact outer lookup demand/order');if(checkInput)assert.equal(digest(frozen),before,id+' immutable');report.constructorControls.push({id,name,value:actual.value,lookupRequests:actual.trace.length,originalMissingCalls:old.missing,candidateMissingCalls:actual.missing,pass:true});}
 for(const [id,defs,name,want]of cases)constructorRow('outer-'+id,list([def('owner','ADT',defs)]),name,want);
 constructorRow('outer-name-is-not-constructor',list([x]),'x',false);
 constructorRow('grandchild-only',list([def('outer','ADT',[def('middle','ADT',[x])])]),'x',false);
 constructorRow('BookCache-outer-skipped',list([def('outer','BookCache',[x])]),'x',false);
 constructorRow('later-definition-after-Absent-child',list([def('outer1','ADT',[absent,x]),def('outer2','Def',[x])]),'x',true);
 constructorRow('strict-outer-demand-after-hit',list([def('outer1','ADT',[x]),def('outer2','ADT',[y]),def('outer3','BookCache',[x])]),'x',true);
 // Real pinned Base supplies ordinary names/constructors without any cache writes.
 for(const name of ['f_source_located','f_load_graph'])assert.equal(typeof native[name],'function',name);
 const source={$:'FSource',name:'Base',path:attempt.base.file,text:fs.readFileSync(attempt.base.file,'utf8')},located=native.f_source_located(source,1,source.text.length+2),loaded=native.f_load_graph('Base',list([located]));assert.equal(loaded.error,'');
 const base=freeze(loaded.book),baseBefore=digest(base),defs=array(base),probes=new Set(['phase65.missing','']);for(const d of defs){probes.add(d.name);for(const c of array(Q.children(d)))probes.add(c.name);}
 for(const name of probes){const expected=Q.run(base,name,true,true).value;constructorRow('Base:'+name,base,name,expected,false);}assert.equal(digest(base),baseBefore,'all Base probes immutable');
 report.counts={lookup:report.lookupControls.length,constructor:report.constructorControls.length,baseNames:probes.size};assert.equal(report.lookupControls.length,29);assert(probes.size>100);
 await verifyAttempt(attemptArg);for(const x of inputs.values())pin(x.file,x);report.complete=report.pass=true;
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,counts:report.counts,error:report.error}));
