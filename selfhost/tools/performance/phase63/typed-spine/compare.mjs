// Root-supervised diagnostic only; never use these clocks as performance data.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [attemptArg,outArg,catalogArg,...wanted]=process.argv.slice(2);assert(attemptArg&&outArg);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase63')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=x=>createHash('sha256').update(x).digest('hex'),identity=file=>({file:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const inputs=new Map(),pin=(file,want)=>{const x=identity(file);if(want)assert.equal(x.sha256,want.sha256);if(inputs.has(x.file))assert.deepEqual(inputs.get(x.file),x);inputs.set(x.file,x);return x;};
const report={kind:'phase63-typed-spine-exact-argument-comparison',complete:false,pass:false,cases:[],scope:'Append-only checked-B1 derivative compares every selected argument result (prefix, ordered values, next) with the old telescope walker; old-oracle recursion disables typed admission. Each source is also fully recompiled with typed arguments disabled, requiring exact full module bytes. WNF/subst/j_app_type counters count lexical function entries, not all internal SCC recursive visits. No timing or compiler correctness proof.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
try{
 const read=f=>JSON.parse(fs.readFileSync(f,'utf8'));report.attempt=pin(path.join(attemptArg,'attempt.json'));const raw=read(report.attempt.file);
 for(const k of Object.keys(process.env))if(k.startsWith('BEND_'))delete process.env[k];
 process.env.BEND_TYPED_API=raw.api.file;process.env.BEND_TYPED_RUNTIME=raw.runtime.file;process.env.BEND_BASE=raw.base.file;
 const workflowFile=path.resolve(import.meta.dirname,'../../../development/workflow.mjs');pin(workflowFile);
 const {verifyAttempt}=await import(pathToFileURL(workflowFile));const attempt=await verifyAttempt(attemptArg);assert(attempt.checked&&attempt.config.strictExact);
 for(const k of ['api','runtime','base','node','bootstrapReport'])pin(attempt[k].file,attempt[k]);pin(import.meta.filename);pin(process.execPath);
 const driverFile=path.join(attempt.snapshot.root,'tools/typed-driver.mjs');pin(driverFile);
 const original=fs.readFileSync(attempt.api.file,'utf8'),parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};
 new Function('module','exports',parserSource)(parser,parser.exports);const parse=s=>parser.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),ast=parse(original);
 const names=['run_loop','$jd_ordered_checked_args_on$','$jd_ordered_args$','$wnf$','$subst$','$j_app_type$'];
 for(const n of names)assert.equal(ast.body.filter(x=>x.type==='FunctionDeclaration'&&x.id.name===n).length,1,n);assert(!original.includes('phase63TypedSpine'));
 const suffix=`
export const phase63TypedSpine=(()=>{
 let disabled=false,oracle=false,active=0,stats;
 const reset=()=>{stats={calls:0,fast:0,fallback:0,compared:0,valueStrings:0,valueCharacters:0,queries:{outside:{},actual:{},oracle:{}}};};reset();
 const original=$jd_ordered_checked_args_on$;
 const names=[['wnf',()=> $wnf$,v=>$wnf$=v],['subst',()=> $subst$,v=>$subst$=v],['j_app_type',()=> $j_app_type$,v=>$j_app_type$=v]];
 for(const [name,get,set]of names){const prior=get();set((...xs)=>{const q=stats.queries[oracle?'oracle':active?'actual':'outside'];q[name]=(q[name]||0)+1;return prior(...xs);});}
 const fail=s=>{throw Error('Typed spine differs: '+s);};
 const compare=(a,b)=>{if(a.$!=='JDOrderedArgs'||b.$!==a.$)fail('result tag');if(a.prefix!==b.prefix)fail('prefix');if(a.next!==b.next)fail('next');let x=a.values,y=b.values,count=0;
  while(x?.$==='Con'&&y?.$==='Con'){if(typeof x.head!=='string'||x.head!==y.head)fail('argument '+count);stats.valueStrings++;stats.valueCharacters+=x.head.length;if(++count>65536||stats.valueCharacters>67108864)throw Error('Typed diagnostic size budget');x=x.tail;y=y.tail;}
  if(x?.$!=='Nil'||y?.$!=='Nil')fail('argument count');};
 $jd_ordered_checked_args_on$=(book,env,xs,ty,next,result)=>{
  if(disabled||oracle)return $jd_ordered_args$(book,env,xs,ty,next);
  if(++stats.calls>50000)throw Error('Typed diagnostic call budget');if(result.$==='Some')stats.fast++;else if(result.$==='None')stats.fallback++;else fail('admission tag');
  active++;let actual,expected;try{actual=run_loop(original(book,env,xs,ty,next,result));oracle=true;try{expected=run_loop($jd_ordered_args$(book,env,xs,ty,next));}finally{oracle=false;}compare(actual,expected);stats.compared++;return actual;}finally{active--;}
 };
 return {reset,disable(value){disabled=value;},stats(){return JSON.parse(JSON.stringify(stats));}};
})();
`;
 parse(original+suffix);const apiFile=path.join(out,'diagnostic-api.mjs');fs.writeFileSync(apiFile,original+suffix,{flag:'wx'});report.derivative={parent:attempt.api,output:pin(apiFile),suffixSha256:hash(suffix),appendOnly:true,parserSha256:hash(parserSource)};
 const module=await import(pathToFileURL(apiFile));assert(!module.G,'Expected named checked B1');const hook=module.phase63TypedSpine;
 const D=await import(pathToFileURL(driverFile));assert.equal(D.apiPath,attempt.api.file);pin(D.directRuntimePath);
 let cases;
 if(catalogArg){pin(catalogArg);const c=read(catalogArg);assert(Array.isArray(c.cases));cases=c.cases.map(x=>({id:x.id,file:x.source?.file??x.file}));}
 else cases=[{id:'numeric-recurrence',file:path.join(root,'selfhost/tools/performance/phase37/fixtures-new/numeric-recurrence.bend')},{id:'test-map-set-ops',file:path.join(root,'selfhost/tools/performance/phase37/fixtures-historical/test-map-set-ops.bend')}];
 if(wanted.length)cases=cases.filter(x=>wanted.includes(x.id));assert(cases.length&&cases.length<=32);
 for(const spec of cases){const file=path.resolve(catalogArg?path.dirname(catalogArg):root,spec.file),row={id:spec.id,source:pin(file),pass:false};report.cases.push(row);save();
  try{hook.reset();hook.disable(false);const actual=await D.inspect(file,{mode:'library',backend:'direct',api:module.default});row.counts=hook.stats();row.observation={status:actual.status,checked:actual.checked,diagnostic:actual.diagnostic};assert.equal(actual.status,'ok',actual.diagnostic);assert.equal(actual.checked,true);assert.equal(row.counts.calls,row.counts.compared);assert(row.counts.fast>0,'No admitted typed call');
   hook.disable(true);const old=await D.inspect(file,{mode:'library',backend:'direct',api:module.default});assert.equal(old.status,'ok',old.diagnostic);assert.equal(old.checked,true);assert.equal(actual.code,old.code,'Full module differs from fallback');
   for(const f of [...actual.files,...old.files])pin(f);const output=path.join(out,spec.id+'.mjs');fs.writeFileSync(output,actual.code,{flag:'wx'});row.output=pin(output);row.rawOutputEqual=true;row.pass=true;
  }catch(error){row.error=String(error.stack??error);}save();console.log(JSON.stringify({id:row.id,pass:row.pass,counts:row.counts,error:row.error}));
 }
 await verifyAttempt(attemptArg);for(const x of inputs.values())assert.deepEqual(identity(x.file),x);report.complete=true;report.pass=report.cases.every(x=>x.pass);if(!report.pass)process.exitCode=1;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.cases.length,error:report.error}));
