// Root-supervised diagnostic; append-only derivative, never a timing sample.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [attemptArg,outArg,...wanted]=process.argv.slice(2);assert(attemptArg&&outArg);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase64')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=x=>createHash('sha256').update(x).digest('hex');
const identity=file=>({file:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const inputs=new Map(),pin=(file,want)=>{const x=identity(file);if(want){assert.equal(x.sha256,want.sha256);if(Object.hasOwn(want,'canonicalPath'))assert.equal(want.canonicalPath,x.file);if(Object.hasOwn(want,'bytes'))assert.equal(want.bytes,fs.statSync(x.file).size);}if(inputs.has(x.file))assert.deepEqual(inputs.get(x.file),x);inputs.set(x.file,x);return x;};
const read=f=>JSON.parse(fs.readFileSync(f,'utf8'));
const report={kind:'phase64-host-signature-restored-reference-comparison',complete:false,pass:false,cases:[],scope:'Real checked sources: compare every wrapper with the unchanged result/args/back reconstruction, then recompile with old wrappers for complete module equality. Exact primitive telescope controls supplement real-source coverage. Diagnostic derivative only; no performance or universal equivalence claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
try{
  pin(import.meta.filename);pin(process.execPath);report.attempt=pin(path.join(attemptArg,'attempt.json'));const raw=read(report.attempt.file);
  for(const k of Object.keys(process.env))if(k.startsWith('BEND_'))delete process.env[k];
  process.env.BEND_TYPED_API=raw.api.file;process.env.BEND_TYPED_RUNTIME=raw.runtime.file;process.env.BEND_BASE=raw.base.file;
  const workflowFile=path.resolve(import.meta.dirname,'../../../development/workflow.mjs');pin(workflowFile);
  const {verifyAttempt}=await import(pathToFileURL(workflowFile));const attempt=await verifyAttempt(attemptArg);assert(attempt.checked&&attempt.config.strictExact);
  for(const k of ['api','runtime','base','node','bootstrapReport'])pin(attempt[k].file,attempt[k]);assert.equal(pin(process.execPath).sha256,attempt.node.sha256);
  pin(path.join(attempt.snapshot.root,'src/back/js/direct/host.bend'));
  const parentFile=path.resolve(import.meta.dirname,'../../phase63/call-arity/compare.mjs');pin(parentFile);
  const original=fs.readFileSync(attempt.api.file,'utf8'),parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};
  new Function('module','exports',parserSource)(parser,parser.exports);const parse=s=>parser.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),originalAst=parse(original);
  const referenceDirectory=path.join(root,'selfhost/build/phase64/checked-state01'),reference=await verifyAttempt(referenceDirectory);
  assert(reference.checked&&reference.config.strictExact);assert.equal(reference.api.sha256,'e61393c96ffc803a1b9ed1f0d351a9af1e68137eea57fedd53411169663ef1e8');
  report.reference={attempt:pin(path.join(referenceDirectory,'attempt.json')),api:pin(reference.api.file,reference.api),host:pin(path.join(reference.snapshot.root,'src/back/js/direct/host.bend'))};
  pin(path.join(import.meta.dirname,'host-signature-v2.derivation.json'));
  const referenceText=fs.readFileSync(reference.api.file,'utf8'),referenceAst=parse(referenceText);
  const functions=ast=>new Map(ast.body.filter(n=>n.type==='FunctionDeclaration').map(n=>[n.id.name,n]));
  const existing=functions(originalAst),available=functions(referenceAst),restored=[],seen=new Set();
  const calls=node=>{const names=new Set(),todo=[node];while(todo.length){const n=todo.pop();if(!n||typeof n!=='object')continue;if(n.type==='CallExpression'&&n.callee?.type==='Identifier')names.add(n.callee.name);for(const value of Object.values(n))if(Array.isArray(value))todo.push(...value);else if(value&&typeof value==='object')todo.push(value);}return [...names].sort();};
  const pending=['$jd_host_args$','$jd_host_args_on$','$jd_host_back$','$jd_host_back_on$'];
  while(pending.length){const name=pending.shift();if(existing.has(name)||seen.has(name))continue;seen.add(name);const n=available.get(name);assert(n,'Missing reference function '+name);const source=referenceText.slice(n.start,n.end),dependencies=calls(n);restored.push({name,source,range:[n.start,n.end],sha256:hash(source),dependencies});for(const dep of dependencies)if(!existing.has(dep)&&!seen.has(dep))pending.push(dep);}
  assert.deepEqual(restored.map(x=>x.name).sort(),['$jd_host_args$','$jd_host_args_on$','$jd_host_back$','$jd_host_back_on$'].sort(),'Unexpected old-helper closure');
  const sourceBody=(source,name)=>{const lines=source.split('\n'),start=lines.findIndex(x=>x.startsWith('def '+name+'('));assert(start>=0,name);let end=start+1;while(end<lines.length&&(!lines[end].trim()||/^\s/.test(lines[end])))end++;return lines.slice(start,end).join('\n').trim();};
  const oldBend=fs.readFileSync(report.reference.host.file,'utf8'),newBend=fs.readFileSync(path.join(attempt.snapshot.root,'src/back/js/direct/host.bend'),'utf8');
  for(const {name}of restored){const bend=name.slice(1,-1);assert.equal(sourceBody(newBend,bend),sourceBody(oldBend,bend),'Old source helper changed: '+bend);}
  const restoredHelpers='\n'+restored.map(x=>x.source).join('\n')+'\n',ast=parse(original+restoredHelpers);
  report.restoredFunctions=restored.map(({source,...row})=>row);
  const names=['run_loop','$jd_host$','$jd_host_signature$','$jd_host_signature_args$','$jd_host_signature_back$','$jd_host_result$','$jd_host_args$','$jd_host_back$','$jd_host_convert$','$jd_host_names$','$jd_host_nat_known$','$jd_emitted_arity$','$jd_live_arity$','$jd_name$','$wnf$','$j_app_type$','$atom$','$kt$'];
  for(const name of names)assert.equal(ast.body.filter(x=>x.type==='FunctionDeclaration'&&x.id.name===name).length,1,name);assert(!original.includes('phase64HostSignature'));
  const suffix=`
export const phase64HostSignature=(()=>{
 let disabled=false,stats,lastBook;
 const call=(fn,...xs)=>run_loop(fn(...xs));
 const exact=(a,b,label)=>{if(JSON.stringify(a,(_,x)=>typeof x==='bigint'?{$bigint:String(x)}:x)!==JSON.stringify(b,(_,x)=>typeof x==='bigint'?{$bigint:String(x)}:x))throw Error(label);};
 const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
 const array=xs=>{const out=[];while(xs?.$==='Con'){if(out.length>16384)throw Error('Head budget');out.push(xs.head);xs=xs.tail;}if(xs?.$!=='Nil')throw Error('Bad head list');return out;};
 const reset=()=>{stats={wrappers:0,compared:0,signatureRows:0,synthetic:0};};reset();
 function oldHost(book,d){
  const arity=call($jd_emitted_arity$,book,d),live=call($jd_live_arity$,book,d.typ,arity),marshal=call($jd_host_nat_known$,book,d.typ)!==0;
  const names=call($jd_host_names$,live,0);
  return '('+names+')=>{const r='+call($jd_host_convert$,book,call($jd_host_result$,book,d.typ,arity),true,marshal)+'(run_loop('+call($jd_name$,d.name)+'('+call($jd_host_args$,book,d.typ,arity,0,false,marshal)+')));'+call($jd_host_back$,book,d.typ,arity,0,marshal)+'return r;}';
 }
 function compareSignature(book,ty,left,at,marshal,label){
  const signature=call($jd_host_signature$,book,ty,left),heads=array(signature.heads);if(heads.length!==left)throw Error(label+' head count');
  exact(signature.result,call($jd_host_result$,book,ty,left),label+' result');
  let current=ty;
  for(const head of heads){const expected=call($wnf$,book,current);exact(head,expected,label+' head');current=call($j_app_type$,expected,call($atom$,'Absent'));}
  exact(signature.result,call($wnf$,book,current),label+' terminal WNF');
  exact(call($jd_host_signature_args$,book,signature.heads,at,marshal),call($jd_host_args$,book,ty,left,at,false,marshal),label+' args');
  exact(call($jd_host_signature_back$,book,signature.heads,at,marshal),call($jd_host_back$,book,ty,left,at,marshal),label+' back');stats.signatureRows++;
 }
 const prior=$jd_host$;
 $jd_host$=(book,d)=>{
  if(disabled)return oldHost(book,d);
  if(++stats.wrappers>10000)throw Error('Host wrapper budget');lastBook=book;
  const actual=run_loop(prior(book,d)),expected=oldHost(book,d);exact(actual,expected,'Host wrapper '+d.name);stats.compared++;
  compareSignature(book,d.typ,call($jd_emitted_arity$,book,d),0,call($jd_host_nat_known$,book,d.typ)!==0,d.name);return actual;
 };
 return {reset,disable:x=>{disabled=x;},stats:()=>({...stats}),synthetic(){
  if(!lastBook)throw Error('No real host context');const book=lastBook;
  const term=(tag,name='',id=0,quant=0,kids=[])=>call($kt$,tag,name,id,quant,list(kids));
  const scalar=term('ADT','U32'),nat=term('ADT','Nat'),absent=term('Absent'),variable=term('Var','T',73),typ=term('Typ','',0,0,[term('Qua','',0,2)]);
  const all=(id,quant,domain,body)=>term('All','x'+id,id,quant,[domain,body]);
  const rows=[['zero',scalar,0],['zero-nat',nat,0],['nonall',absent,3],['live',all(1,1,scalar,scalar),1],['borrowed',all(2,2,nat,nat),1],['erased-dependent',all(73,0,typ,all(74,1,variable,variable)),2],['erased-nat',all(1,0,typ,all(2,1,nat,nat)),2],['premature-end',all(1,1,nat,scalar),3]];
  for(const [id,ty,left]of rows)for(const at of [0,3])for(const marshal of [false,true]){compareSignature(book,ty,left,at,marshal,id);stats.synthetic++;}
  return {cases:stats.synthetic,ids:rows.map(x=>x[0])};
 }};
})();
`;
  parse(original+restoredHelpers+suffix);const apiFile=path.join(out,'diagnostic-api.mjs');fs.writeFileSync(apiFile,original+restoredHelpers+suffix,{flag:'wx'});
  report.derivative={parent:attempt.api,output:pin(apiFile),appendOnly:true,suffixSha256:hash(suffix),restoredSha256:hash(restoredHelpers),parserSha256:hash(parserSource),methodParent:pin(parentFile)};
  const module=await import(pathToFileURL(apiFile));assert.equal(module.G,undefined);const hook=module.phase64HostSignature;
  const driverFile=path.join(attempt.snapshot.root,'tools/typed-driver.mjs');pin(driverFile);const D=await import(pathToFileURL(driverFile));assert.equal(D.apiPath,attempt.api.file);pin(D.directRuntimePath);
  const fixtureRoot=path.resolve(import.meta.dirname,'../../phase63/backend-context-controls'),manifestFile=path.join(fixtureRoot,'cases.json');pin(manifestFile);
  const cases=[...read(manifestFile).cases.map(x=>({id:x.id,file:path.join(fixtureRoot,x.file)})),{id:'numeric-recurrence',file:path.join(root,'selfhost/tools/performance/phase37/fixtures-new/numeric-recurrence.bend')},{id:'test-map-set-ops',file:path.join(root,'selfhost/tools/performance/phase37/fixtures-historical/test-map-set-ops.bend')}].filter(x=>!wanted.length||wanted.includes(x.id));
  assert(cases.length&&(!wanted.length||cases.length===new Set(wanted).size));
  for(const spec of cases){const row={id:spec.id,source:pin(spec.file),pass:false};report.cases.push(row);save();
    try{
      hook.reset();hook.disable(false);const actual=await D.inspect(spec.file,{mode:'library',backend:'direct',api:module.default});
      row.observation={status:actual.status,checked:actual.checked,diagnostic:actual.diagnostic};assert.equal(actual.status,'ok',actual.diagnostic);assert.equal(actual.checked,true);
      row.synthetic=hook.synthetic();row.counts=hook.stats();assert(row.counts.wrappers>0);assert.equal(row.counts.compared,row.counts.wrappers);assert.equal(row.synthetic.cases,32);
      hook.disable(true);const old=await D.inspect(spec.file,{mode:'library',backend:'direct',api:module.default});assert.equal(old.status,'ok',old.diagnostic);assert.equal(old.checked,true);assert.equal(actual.code,old.code,'Complete module differs from unchanged old host traversal');
      for(const file of [...actual.files,...old.files])pin(file);const output=path.join(out,spec.id+'.mjs');fs.writeFileSync(output,actual.code,{flag:'wx'});row.output=pin(output);row.fullModuleEqual=true;row.pass=true;
    }catch(error){row.error=String(error.stack??error);}save();console.log(JSON.stringify({id:row.id,pass:row.pass,counts:row.counts,error:row.error}));
  }
  await verifyAttempt(attemptArg);await verifyAttempt(referenceDirectory);for(const x of inputs.values())assert.deepEqual(identity(x.file),x);report.complete=true;report.pass=report.cases.every(x=>x.pass);if(!report.pass)process.exitCode=1;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.cases.length,error:report.error}));
