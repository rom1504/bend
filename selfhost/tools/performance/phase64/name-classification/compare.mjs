// Root-supervised correctness diagnostic. Append-only image derivative, never timing evidence.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [attemptArg,outArg,...wanted]=process.argv.slice(2);assert(attemptArg&&outArg);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase64')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=x=>createHash('sha256').update(x).digest('hex'),read=f=>JSON.parse(fs.readFileSync(f,'utf8'));
const identity=file=>({file:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const inputs=new Map(),pin=(file,want)=>{const x=identity(file);if(want){assert.equal(x.sha256,want.sha256);if(Object.hasOwn(want,'canonicalPath'))assert.equal(x.file,want.canonicalPath);if(Object.hasOwn(want,'bytes'))assert.equal(fs.statSync(x.file).size,want.bytes);}if(inputs.has(x.file))assert.deepEqual(inputs.get(x.file),x);inputs.set(x.file,x);return x;};
const report={kind:'phase64-name-classification-differential',complete:false,pass:false,cases:[],scope:'Actual compiled classifiers versus original compiled String.contains, including adjacent multi-entry names. Actual checked source compilations use per-call oracles and complete-module comparison with old membership functions restored. Finite correctness diagnostic, no timing or universal compiler-equivalence claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
try{
 pin(import.meta.filename);pin(process.execPath);report.attempt=pin(path.join(attemptArg,'attempt.json'));const raw=read(report.attempt.file);
 for(const k of Object.keys(process.env))if(k.startsWith('BEND_'))delete process.env[k];
 process.env.BEND_TYPED_API=raw.api.file;process.env.BEND_TYPED_RUNTIME=raw.runtime.file;process.env.BEND_BASE=raw.base.file;
 const workflowFile=path.resolve(import.meta.dirname,'../../../development/workflow.mjs');pin(workflowFile);
 const {verifyAttempt}=await import(pathToFileURL(workflowFile));const attempt=await verifyAttempt(attemptArg);assert(attempt.checked&&attempt.config.strictExact);
 for(const k of ['api','runtime','base','node','bootstrapReport'])pin(attempt[k].file,attempt[k]);assert.equal(pin(process.execPath).sha256,attempt.node.sha256);
 for(const f of ['src/back/js/direct/constructors.bend','src/back/js/validate.bend'])pin(path.join(attempt.snapshot.root,f));
 const corpusFile=path.join(import.meta.dirname,'corpus.json');pin(corpusFile);const corpus=read(corpusFile);
 const original=fs.readFileSync(attempt.api.file,'utf8'),parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};
 new Function('module','exports',parserSource)(parser,parser.exports);const parse=s=>parser.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),ast=parse(original);
 const names=['run_loop','$String$contains$','$jd_native_layout_name$','$j_layout_array_name$','$jd_native_layout$','$j_layout_array_intrinsic$','$tg$'];
 for(const name of names)assert.equal(ast.body.filter(x=>x.type==='FunctionDeclaration'&&x.id.name===name).length,1,name);assert(!original.includes('phase64NameClassification'));
 const suffix=`
export const phase64NameClassification=(()=>{
 const call=(fn,...xs)=>run_loop(fn(...xs));
 let disabled=false,counts={jd_native_layout_name:0,j_layout_array_name:0};
 let guards={jd_native_layout:{calls:0,rejectedTag:0},j_layout_array_intrinsic:{calls:0,rejectedTag:0}};
 const tables={jd_native_layout_name:'|Nat|Bool|U32|F32|Char|String|Array|',j_layout_array_name:'|Array.new|Array.set|Array.get|Array.swap|Array.size|'};
 const originals={jd_native_layout_name:$jd_native_layout_name$,j_layout_array_name:$j_layout_array_name$};
 const old=(key,name)=>call($String$contains$,tables[key],'|'+name+'|');
 const check=(key,name)=>{
  if(disabled)return old(key,name);
  const actual=call(originals[key],name),expected=old(key,name);counts[key]++;
  if(actual!==expected)throw Error('Classifier mismatch '+key+' '+JSON.stringify(name));
  return actual;
 };
 $jd_native_layout_name$=name=>check('jd_native_layout_name',name);
 $j_layout_array_name$=name=>check('j_layout_array_name',name);
 const nativePredicate=$jd_native_layout$,arrayPredicate=$j_layout_array_intrinsic$;
 $jd_native_layout$=(book,term)=>{guards.jd_native_layout.calls++;if(call($tg$,term)!=='ADT')guards.jd_native_layout.rejectedTag++;return call(nativePredicate,book,term);};
 $j_layout_array_intrinsic$=(book,term)=>{guards.j_layout_array_intrinsic.calls++;if(call($tg$,term)!=='Ref')guards.j_layout_array_intrinsic.rejectedTag++;return call(arrayPredicate,book,term);};
 return {reset:()=>{counts={jd_native_layout_name:0,j_layout_array_name:0};guards={jd_native_layout:{calls:0,rejectedTag:0},j_layout_array_intrinsic:{calls:0,rejectedTag:0}};},disable:value=>{disabled=value;},counts:()=>({...counts}),guards:()=>JSON.parse(JSON.stringify(guards)),check,old};
})();
`;
 parse(original+suffix);const apiFile=path.join(out,'diagnostic-api.mjs');fs.writeFileSync(apiFile,original+suffix,{flag:'wx'});
 report.derivative={parent:attempt.api,output:pin(apiFile),appendOnly:true,suffixSha256:hash(suffix),parserSha256:hash(parserSource)};
 const module=await import(pathToFileURL(apiFile));assert.equal(module.G,undefined);const hook=module.phase64NameClassification;
 report.synthetic=[];
 for(const [key,spec]of Object.entries(corpus)){
  assert(names.includes('$'+key+'$'));assert.equal(typeof spec.table,'string');assert(spec.names.length>0);
  let accepted=0;for(const name of spec.names){assert.equal(typeof name,'string');const result=hook.check(key,name);assert.equal(result,spec.table.includes('|'+name+'|'));if(result)accepted++;}
  report.synthetic.push({helper:key,cases:spec.names.length,accepted,pass:true});
 }
 save();
 const driverFile=path.join(attempt.snapshot.root,'tools/typed-driver.mjs');pin(driverFile);const D=await import(pathToFileURL(driverFile));assert.equal(D.apiPath,attempt.api.file);pin(D.directRuntimePath);
 const specs=[{id:'numeric-recurrence',file:path.join(root,'selfhost/tools/performance/phase37/fixtures-new/numeric-recurrence.bend')},{id:'test-map-set-ops',file:path.join(root,'selfhost/tools/performance/phase37/fixtures-historical/test-map-set-ops.bend')}].filter(x=>!wanted.length||wanted.includes(x.id));
 assert(specs.length&&(!wanted.length||specs.length===new Set(wanted).size));
 for(const spec of specs){const row={id:spec.id,source:pin(spec.file),pass:false};report.cases.push(row);save();
  try{
   hook.reset();hook.disable(false);const actual=await D.inspect(spec.file,{mode:'library',backend:'direct',api:module.default});
   row.observation={status:actual.status,checked:actual.checked,diagnostic:actual.diagnostic};assert.equal(actual.status,'ok',actual.diagnostic);assert.equal(actual.checked,true);
   row.calls=hook.counts();row.tagGuards=hook.guards();for(const key of Object.keys(corpus))assert(row.calls[key]>0,'Unreached classifier '+key);
   hook.disable(true);let old;try{old=await D.inspect(spec.file,{mode:'library',backend:'direct',api:module.default});}finally{hook.disable(false);}
   assert.equal(old.status,'ok',old.diagnostic);assert.equal(old.checked,true);assert.equal(actual.code,old.code,'Complete module differs with original membership restored');
   for(const file of [...actual.files,...old.files])pin(file);const output=path.join(out,spec.id+'.mjs');fs.writeFileSync(output,actual.code,{flag:'wx'});row.output=pin(output);row.fullModuleEqual=true;row.pass=true;
  }catch(error){row.error=String(error.stack??error);}save();console.log(JSON.stringify({id:row.id,pass:row.pass,calls:row.calls,tagGuards:row.tagGuards,error:row.error}));
 }
 await verifyAttempt(attemptArg);for(const x of inputs.values())assert.deepEqual(identity(x.file),x);
 report.complete=true;report.pass=report.synthetic.every(x=>x.pass)&&report.cases.every(x=>x.pass);if(!report.pass)process.exitCode=1;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.cases.length,error:report.error}));
