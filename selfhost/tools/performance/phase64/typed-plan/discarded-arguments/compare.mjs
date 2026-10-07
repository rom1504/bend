// Root-supervised diagnostic only; never use these clocks as performance data.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [attemptArg,outArg,catalogArg,...wanted]=process.argv.slice(2);assert(attemptArg&&outArg);
const root=path.resolve(import.meta.dirname,'../../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase64')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=x=>createHash('sha256').update(x).digest('hex'),identity=file=>({file:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const inputs=new Map(),pin=(file,want)=>{const x=identity(file);if(want)assert.equal(x.sha256,want.sha256);if(inputs.has(x.file))assert.deepEqual(inputs.get(x.file),x);inputs.set(x.file,x);return x;};
const report={kind:'phase64-discarded-argument-rendering-differential',complete:false,pass:false,cases:[],scope:'Compare full same-component return JDText and modules with shape-only admission versus original complete jd_arguments rendering. Exact synthetic rest/type/missing projections cover empty, partial, over, erased and malformed telescopes. Instrumented lexical counts are not performance measurements.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
try{
 const read=f=>JSON.parse(fs.readFileSync(f,'utf8'));report.attempt=pin(path.join(attemptArg,'attempt.json'));const raw=read(report.attempt.file);
 for(const k of Object.keys(process.env))if(k.startsWith('BEND_'))delete process.env[k];
 process.env.BEND_TYPED_API=raw.api.file;process.env.BEND_TYPED_RUNTIME=raw.runtime.file;process.env.BEND_BASE=raw.base.file;
 const workflowFile=path.resolve(import.meta.dirname,'../../../../development/workflow.mjs');pin(workflowFile);
 const {verifyAttempt}=await import(pathToFileURL(workflowFile));const attempt=await verifyAttempt(attemptArg);assert(attempt.checked&&attempt.config.strictExact);
 for(const k of ['api','runtime','base','node','bootstrapReport'])pin(attempt[k].file,attempt[k]);pin(import.meta.filename);pin(process.execPath);
 const driverFile=path.join(attempt.snapshot.root,'tools/typed-driver.mjs');pin(driverFile);
 const original=fs.readFileSync(attempt.api.file,'utf8'),parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};
 new Function('module','exports',parserSource)(parser,parser.exports);const parse=s=>parser.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),ast=parse(original);
 const names=['run_loop','$jd_argument_shape$','$jd_argument_shape_more$','$jd_arguments$','$jd_doc_return$','$jd_expr$','$jd_ordered_expr$','$wnf$','$subst$','$j_app_type$','$kt$','$all$','$atom$','$var$'];
 for(const n of names)assert.equal(ast.body.filter(x=>x.type==='FunctionDeclaration'&&x.id.name===n).length,1,n);assert(!original.includes('phase64ArgumentShape'));
 const suffix=`
export const phase64ArgumentShape=(()=>{
 let disabled=false,oracle=false,active=0,discarded=0,stats;const contexts=[];
 const call=(fn,...args)=>run_loop(fn(...args));
 const serialize=x=>JSON.stringify(x,(_,v)=>typeof v==='bigint'?{$bigint:String(v)}:v);
 const reset=()=>{stats={returns:0,shapeCalls:0,forcedShapes:0,compared:0,comparedCharacters:0,queries:{outside:{},actual:{},oracle:{},discardedRendering:{}}};};reset();
 const compare=(name,a,b)=>{const x=serialize(a),y=serialize(b);stats.comparedCharacters+=x.length;if(stats.comparedCharacters>67108864)throw Error('Shape diagnostic byte budget');if(x!==y)throw Error('Argument shape differs: '+name);stats.compared++;};
 const query=(name,prior)=>(...args)=>{const q=stats.queries[oracle?'oracle':active?'actual':'outside'];q[name]=(q[name]??0)+1;if(discarded)stats.queries.discardedRendering[name]=(stats.queries.discardedRendering[name]??0)+1;return prior(...args);};
 $jd_expr$=query('jd_expr',$jd_expr$);$jd_ordered_expr$=query('jd_ordered_expr',$jd_ordered_expr$);$wnf$=query('wnf',$wnf$);$subst$=query('subst',$subst$);$j_app_type$=query('j_app_type',$j_app_type$);
 const shape=$jd_argument_shape$,args=$jd_arguments$,body=$jd_doc_return$;
 const oldShape=(book,xs,ty,left)=>{if(!contexts.length)throw Error('Shape called without owner environment');discarded++;try{return call(args,book,contexts.at(-1),xs,ty,left);}finally{discarded--;}};
 $jd_argument_shape$=(book,xs,ty,left)=>{if(disabled||oracle){stats.forcedShapes++;return oldShape(book,xs,ty,left);}if(++stats.shapeCalls>100000)throw Error('Shape call budget');return shape(book,xs,ty,left);};
 $jd_doc_return$=(...xs)=>{
  contexts.push(xs[1]);try{
   if(disabled||oracle||active)return call(body,...xs);
   stats.returns++;active++;let actual,expected;
   try{actual=call(body,...xs);oracle=true;try{expected=call(body,...xs);}finally{oracle=false;}compare('return JDText',actual,expected);return actual;}finally{active--;}
  }finally{contexts.pop();}
 };
 const controls=()=>{
  const nil={$:'Nil'},cons=(head,tail=nil)=>({$:'Con',head,tail}),term=(tag,name='',id=0,quant=0,kids=nil)=>call($kt$,tag,name,id,quant,kids),abs=call($atom$,'Absent'),typ=call($atom$,'Typ'),v=call($var$,'x',7),bogus=call($atom$,'UnsupportedFixture');
  const one=call($all$,1,'x',7,typ,abs),erased=call($all$,0,'e',8,typ,abs),two=call($all$,1,'x',7,typ,erased),liveTwo=call($all$,1,'x',7,typ,one),dependent=call($all$,1,'T',7,typ,v);
  const cases=[['zero-empty',nil,term('Ref','MissingAlias'),0],['zero-over',cons(v),one,0],['missing-live',nil,one,1],['missing-erased',nil,erased,1],['missing-two',nil,two,2],['exact',cons(v),one,1],['partial-erased-suffix',cons(v),two,2],['partial-live-suffix',cons(v),liveTwo,2],['over',cons(v,cons(v)),one,1],['non-All',cons(bogus),abs,1],['non-All-empty',nil,abs,2],['dependent-result',cons(typ),dependent,1]];
  const rows=[];for(const [name,xs,ty,left]of cases){const actual=call(shape,nil,xs,ty,left),expected=call(args,nil,nil,xs,ty,left),project=x=>({rest:x.rest,typ:x.typ,missing:x.missing});if(actual.$!=='JDArgs'||expected.$!=='JDArgs')throw Error('JDArgs layout changed');compare(name,project(actual),project(expected));if(actual.values.$!=='Nil')throw Error('Shape unexpectedly emitted values');rows.push({name,pass:true,missing:actual.missing});}return rows;
 };
 return {reset,disable(value){disabled=value;},stats(){return JSON.parse(JSON.stringify(stats));},controls};
})();
`;
 parse(original+suffix);const apiFile=path.join(out,'diagnostic-api.mjs');fs.writeFileSync(apiFile,original+suffix,{flag:'wx'});report.derivative={parent:attempt.api,output:pin(apiFile),suffixSha256:hash(suffix),appendOnly:true,parserSha256:hash(parserSource)};
 const module=await import(pathToFileURL(apiFile));assert(!module.G,'Expected named checked B1');const hook=module.phase64ArgumentShape;
 const D=await import(pathToFileURL(driverFile));assert.equal(D.apiPath,attempt.api.file);pin(D.directRuntimePath);
 let cases;
 if(catalogArg){pin(catalogArg);const c=read(catalogArg);assert(Array.isArray(c.cases));cases=c.cases.map(x=>({id:x.id,file:x.source?.file??x.file}));}
 else cases=[{id:'numeric-recurrence',file:path.join(root,'selfhost/tools/performance/phase37/fixtures-new/numeric-recurrence.bend')},{id:'test-map-set-ops',file:path.join(root,'selfhost/tools/performance/phase37/fixtures-historical/test-map-set-ops.bend')}];
 if(wanted.length)cases=cases.filter(x=>wanted.includes(x.id));assert(cases.length&&cases.length<=32);
 for(const spec of cases){const file=path.resolve(catalogArg?path.dirname(catalogArg):root,spec.file),row={id:spec.id,source:pin(file),pass:false};report.cases.push(row);save();
  try{hook.reset();hook.disable(false);const actual=await D.inspect(file,{mode:'library',backend:'direct',api:module.default});row.counts=hook.stats();row.observation={status:actual.status,checked:actual.checked,diagnostic:actual.diagnostic};assert.equal(actual.status,'ok',actual.diagnostic);assert.equal(actual.checked,true);assert(row.counts.compared>0,'No return consumers compared');row.activated=row.counts.shapeCalls>0;row.controls=hook.controls();
   hook.disable(true);const old=await D.inspect(file,{mode:'library',backend:'direct',api:module.default});assert.equal(old.status,'ok',old.diagnostic);assert.equal(old.checked,true);assert.equal(actual.code,old.code,'Full module differs from original complete argument rendering');
   for(const f of [...actual.files,...old.files])pin(f);const output=path.join(out,spec.id+'.mjs');fs.writeFileSync(output,actual.code,{flag:'wx'});row.output=pin(output);row.rawOutputEqual=true;row.pass=true;
  }catch(error){row.error=String(error.stack??error);}save();console.log(JSON.stringify({id:row.id,pass:row.pass,counts:row.counts,error:row.error}));
 }
 await verifyAttempt(attemptArg);for(const x of inputs.values())assert.deepEqual(identity(x.file),x);assert(report.cases.some(x=>x.activated),'No discarded argument rendering selected in any source');report.complete=true;report.pass=report.cases.every(x=>x.pass);if(!report.pass)process.exitCode=1;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.cases.length,error:report.error}));
