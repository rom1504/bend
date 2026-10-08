// Root-supervised real-source context qualification. No production edits.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [attemptArg,outArg,...wanted]=process.argv.slice(2);
assert(attemptArg&&outArg,'run.mjs CHECKED_ATTEMPT NEW_OUTPUT [CASE ...]');
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase65')+path.sep)&&!fs.existsSync(out));
fs.mkdirSync(out,{recursive:true});
const hash=x=>createHash('sha256').update(x).digest('hex');
const identity=file=>({file:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const inputs=new Map(),pin=(file,want)=>{const r=identity(file);if(want){assert.equal(r.sha256,want.sha256);if(Object.hasOwn(want,'canonicalPath'))assert.equal(want.canonicalPath,r.file);if(Object.hasOwn(want,'bytes'))assert.equal(want.bytes,fs.statSync(r.file).size);}if(inputs.has(r.file))assert.deepEqual(r,inputs.get(r.file));inputs.set(r.file,r);return r;};
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const array=xs=>{const out=[];while(xs?.$==='Con'){assert(out.length<65536);out.push(xs.head);xs=xs.tail;}assert.equal(xs?.$,'Nil');return out;};
const revive=x=>x&&typeof x==='object'?(Object.keys(x).length===1&&typeof x.bigint==='string'?BigInt(x.bigint):Array.isArray(x)?x.map(revive):Object.fromEntries(Object.entries(x).map(([k,v])=>[k,revive(v)]))):x;
const plain=x=>typeof x==='bigint'?{bigint:String(x)}:x&&typeof x==='object'?(Array.isArray(x)?x.map(plain):Object.fromEntries(Object.entries(x).map(([k,v])=>[k,plain(v)]))):x;
const valueHash=x=>hash(JSON.stringify(plain(x)));
const report={kind:'phase65-real-source-backend-context-controls',complete:false,pass:false,cases:[],scope:'Checked B1 only. Six real checked sources are compiled with explicit diagnostic library roots so type-only aliases are actually pruned. Compare old pruned-context lowering, fresh full-context lowering and saved-plan output; execute all three outputs against independent values. No timing claim or universal context-equivalence proof.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
try {
  pin(import.meta.filename);pin(path.join(import.meta.dirname,'derivation.json'));pin(path.resolve(import.meta.dirname,'../../phase63/backend-context-controls/run.mjs'));report.node=pin(process.execPath);
  report.attempt=pin(path.join(attemptArg,'attempt.json'));
  const raw=read(report.attempt.file);
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
  process.env.BEND_TYPED_API=raw.api.file;process.env.BEND_TYPED_RUNTIME=raw.runtime.file;process.env.BEND_BASE=raw.base.file;
  const workflowFile=path.resolve(import.meta.dirname,'../../../development/workflow.mjs');pin(workflowFile);
  const {verifyAttempt}=await import(pathToFileURL(workflowFile));
  const attempt=await verifyAttempt(attemptArg);assert(attempt.checked&&attempt.config.strictExact);
  for(const k of ['api','runtime','base','node','bootstrapReport'])pin(attempt[k].file,attempt[k]);
  assert.equal(fs.realpathSync(process.execPath),fs.realpathSync(attempt.node.file));
  const driverFile=path.join(attempt.snapshot.root,'tools/typed-driver.mjs');pin(driverFile);
  const D=await import(pathToFileURL(driverFile)),api=await D.loadApi();
  assert.equal(D.apiPath,attempt.api.file);pin(D.directRuntimePath);
  for(const n of ['jd_plan_selected','jd_plan_defs','jd_plan_error','jd_plan_library','jd_reach_selected','jd_reach_defs','jd_reach_error','jd_library_selected'])assert.equal(typeof api[n],'function',n);

  const original=fs.readFileSync(attempt.api.file,'utf8');
  const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};
  new Function('module','exports',parserSource)(parser,parser.exports);
  const parse=x=>parser.exports.parse(x,{ecmaVersion:'latest',sourceType:'module'}),ast=parse(original);
  const names=['jd_library_context','jd_calls_context','jd_selected_context','lookup','jd_calls_fact','jd_component','jd_may_bounce'];
  for(const n of ['run_loop',...names.map(n=>'$'+n+'$')])assert.equal(ast.body.filter(x=>x.type==='FunctionDeclaration'&&x.id.name===n).length,1,n);
  const suffix='\nexport const phase63Context={'+names.map(n=>JSON.stringify(n)+':(...xs)=>run_loop($'+n+'$(...xs))').join(',')+'};\n';
  assert(!original.includes('phase63Context'));parse(original+suffix);
  const derivativeFile=path.join(out,'diagnostic-api.mjs');fs.writeFileSync(derivativeFile,original+suffix,{flag:'wx'});
  report.derivative={parent:attempt.api,output:pin(derivativeFile),appendOnly:true,suffixSha256:hash(suffix),parserSha256:hash(parserSource)};
  const P=(await import(pathToFileURL(derivativeFile))).phase63Context;
  const manifestFile=path.resolve(import.meta.dirname,'../../phase63/backend-context-controls/cases.json');report.manifest=pin(manifestFile);
  const manifest=read(manifestFile);assert.equal(manifest.kind,'phase63-real-source-backend-context-controls');
  const cases=wanted.length?manifest.cases.filter(x=>wanted.includes(x.id)):manifest.cases;
  assert(cases.length&&(wanted.length===0||cases.length===new Set(wanted).size));
  for(const spec of cases){
    const source=pin(path.resolve(import.meta.dirname,'../../phase63/backend-context-controls',spec.file)),row={id:spec.id,source,roots:spec.roots,pass:false};report.cases.push(row);save();
    try {
      let captured;
      const diagnosticApi={...api,jd_roots:(_book,library)=>{assert(library);return list(spec.roots);},jd_plan_selected:(book,defs,roots)=>{assert(!captured);const plan=api.jd_plan_selected(book,defs,roots);captured={book,defs,roots,plan};return plan;}};
      const result=await D.inspect(source.file,{mode:'library',backend:'direct',api:diagnosticApi});
      row.observation={status:result.status,phase:result.phase,checked:result.checked,diagnostic:result.diagnostic};
      assert.equal(result.status,'ok',result.diagnostic);assert.equal(result.checked,true);assert(captured);
      for(const f of result.files??[])pin(f);
      const {book,defs,roots,plan}=captured;
      assert.equal(api.jd_plan_error(plan),'');
      const retained=api.jd_plan_defs(plan),oldReach=api.jd_reach_selected(book,defs,roots);
      assert.equal(api.jd_reach_error(oldReach),'');
      assert.deepEqual(plain(api.jd_reach_defs(oldReach)),plain(retained),'Retained definitions changed');
      const initialNames=new Set(array(defs).map(x=>x.name)),keep=array(retained),keptNames=new Set(keep.map(x=>x.name));
      const finalBook=P.jd_calls_context(P.jd_selected_context(book,retained),retained);
      row.initialDefinitions=initialNames.size;row.retainedDefinitions=keptNames.size;row.aliases=[];
      for(const name of spec.removedAliases){
        assert(initialNames.has(name),'Alias was not selected: '+name);assert(!keptNames.has(name),'Alias was not pruned: '+name);
        const a=P.lookup(plan.book,name),b=P.lookup(finalBook,name);
        const changedFields=Object.keys(a).filter(k=>valueHash(a[k])!==valueHash(b[k]));
        assert(changedFields.includes('value'),'Alias did not cross annotation contexts: '+name);
        row.aliases.push({name,changedFields,fullSha256:valueHash(a),prunedSha256:valueHash(b)});
      }
      for(const name of spec.removedValues??[]){assert(initialNames.has(name));assert(!keptNames.has(name),'Dead runtime value retained: '+name);}
      row.callFacts=keep.filter(d=>d.kind==='Def').map(d=>{
        const oldFact=P.jd_calls_fact(finalBook,d.name),newFact=P.jd_calls_fact(plan.book,d.name),oldComponent=array(P.jd_component(finalBook,d.name)),newComponent=array(P.jd_component(plan.book,d.name));
        assert.deepEqual(plain(oldFact),plain(newFact),'Call facts: '+d.name);assert.deepEqual(oldComponent,newComponent,'SCC members: '+d.name);assert.equal(P.jd_may_bounce(finalBook,d.name),P.jd_may_bounce(plan.book,d.name),'Bounce: '+d.name);
        return{name:d.name,component:newComponent,bounce:P.jd_may_bounce(plan.book,d.name)};
      });
      const outputs={old:api.jd_library_selected(book,retained),canonical:P.jd_library_context(plan.book,retained),saved:api.jd_plan_library(plan)};
      assert.equal(outputs.saved,outputs.canonical,'Saved code differs from fresh canonical lowering');
      assert.equal(outputs.old,outputs.canonical,'Full annotated context changes emitted code');
      assert(result.code.endsWith(outputs.saved));const prefix=result.code.slice(0,-outputs.saved.length);
      row.outputs=[];row.oracles=[];
      for(const [role,text]of Object.entries(outputs)){
        const file=path.join(out,spec.id+'-'+role+'.mjs');fs.writeFileSync(file,prefix+text,{flag:'wx'});row.outputs.push({role,...pin(file)});
        const module=(await import(pathToFileURL(file))).default;
        for(const point of spec.points){assert.equal(typeof module[point.name],'function',point.name);const value=module[point.name](...revive(point.args));assert.deepEqual(plain(value),point.expected,role+': '+point.name);row.oracles.push({role,name:point.name,args:point.args,expected:point.expected,actual:plain(value),pass:true});}
      }
      row.pass=true;
    }catch(error){row.error=String(error.stack??error);}
    save();console.log(JSON.stringify({id:row.id,pass:row.pass,aliases:row.aliases?.length,oracles:row.oracles?.length,error:row.error}));
  }
  await verifyAttempt(attemptArg);for(const x of inputs.values())assert.deepEqual(identity(x.file),x);
  report.complete=true;report.pass=report.cases.every(x=>x.pass);report.counts={cases:report.cases.length,oracles:report.cases.reduce((n,x)=>n+(x.oracles?.length??0),0)};
  if(!report.pass)process.exitCode=1;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,counts:report.counts,error:report.error}));
