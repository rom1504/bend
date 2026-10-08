// Root-supervised diagnostic only. Instrumented clocks are not performance data.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [attemptArg,outArg,catalogArg,...wanted]=process.argv.slice(2);assert(attemptArg&&outArg);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase65')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=x=>createHash('sha256').update(x).digest('hex'),identity=file=>({file:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const inputs=new Map(),pin=(file,want)=>{const x=identity(file);if(want)assert.equal(x.sha256,want.sha256);if(inputs.has(x.file))assert.deepEqual(inputs.get(x.file),x);inputs.set(x.file,x);return x;};
const report={kind:'phase65-ordered-demand-metadata-differential',complete:false,pass:false,cases:[],scope:'Actual checked B1 helpers, append-only instrumentation. Full enclosing JDOrdered prefix/value/next and complete module comparisons with shared metadata versus original String.contains demand checks. Synthetic RHS spies qualify order and suppression only; real corpus compilation uses unchanged helpers. No runtime, B2 or speed claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
try{
 const read=f=>JSON.parse(fs.readFileSync(f,'utf8'));report.attempt=pin(path.join(attemptArg,'attempt.json'));const raw=read(report.attempt.file);
 for(const k of Object.keys(process.env))if(k.startsWith('BEND_'))delete process.env[k];
 process.env.BEND_TYPED_API=raw.api.file;process.env.BEND_TYPED_RUNTIME=raw.runtime.file;process.env.BEND_BASE=raw.base.file;
 const workflowFile=path.resolve(import.meta.dirname,'../../../development/workflow.mjs');pin(workflowFile);
 const {verifyAttempt}=await import(pathToFileURL(workflowFile));const attempt=await verifyAttempt(attemptArg);assert(attempt.checked&&attempt.config.strictExact);
 for(const k of ['api','runtime','base','node','bootstrapReport'])pin(attempt[k].file,attempt[k]);pin(import.meta.filename);pin(process.execPath);
 assert.equal(identity(process.execPath).sha256,attempt.node.sha256);
 const driverFile=path.join(attempt.snapshot.root,'tools/typed-driver.mjs');pin(driverFile);
 const original=fs.readFileSync(attempt.api.file,'utf8'),parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};
 new Function('module','exports',parserSource)(parser,parser.exports);const parse=s=>parser.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),ast=parse(original);
 const names=['run_loop','$jd_ordered_bindings_shared$','$jd_ordered_bindings_doc$','$jd_ordered_bindings$','$jd_ordered_let_body$','$jd_ordered_expr$','$j_type$','$jd_text_raw$','$jd_text_used$','$jd_text_refs$','$jd_reach_refs$','$jd_reach_names$','$book_cached$','$kt$','$atom$'];
 for(const n of names)assert.equal(ast.body.filter(x=>x.type==='FunctionDeclaration'&&x.id.name===n).length,1,n);assert(!original.includes('phase65OrderedMetadata'));
 const suffix=`
export const phase65OrderedMetadata=(()=>{
 let disabled=false,oracle=false,active=0,stats;
 const call=(fn,...args)=>run_loop(fn(...args));
 const serialize=x=>JSON.stringify(x,(_,v)=>typeof v==='bigint'?{$bigint:String(v)}:v);
 const reset=()=>{stats={consumers:0,compared:0,comparedCharacters:0,sharedGroups:0,eligibleGroups:0,eligibleBodyCodepoints:0,queries:{actual:{},oracle:{},outside:{}}};};reset();
 const compare=(name,a,b)=>{const x=serialize(a),y=serialize(b);stats.comparedCharacters+=x.length;if(stats.comparedCharacters>67108864)throw Error('Metadata diagnostic byte budget');if(x!==y)throw Error('Ordered metadata differs: '+name);stats.compared++;};
 const query=(name,prior)=>(...args)=>{const q=stats.queries[oracle?'oracle':active?'actual':'outside'];q[name]=(q[name]??0)+1;return prior(...args);};
 const shared=$jd_ordered_bindings_shared$,old=$jd_ordered_bindings$,enclosing=$jd_ordered_let_body$;
 $jd_text_raw$=query('jd_text_raw',$jd_text_raw$);$jd_text_used$=query('jd_text_used',$jd_text_used$);$jd_ordered_expr$=query('jd_ordered_expr',$jd_ordered_expr$);$j_type$=query('j_type',$j_type$);
 $jd_ordered_bindings_shared$=(...args)=>{if(disabled||oracle)return call(old,...args);if(++stats.sharedGroups>100000)throw Error('Metadata group budget');let x=args[2],n=0;while(x.$==='Con'&&n<3){n++;x=x.tail;}if(n===3){stats.eligibleGroups++;stats.eligibleBodyCodepoints+=Array.from(args[3]).length;}return shared(...args);};
 $jd_ordered_let_body$=(...args)=>{
  if(disabled||oracle||active)return call(enclosing,...args);
  stats.consumers++;active++;
  try{const actual=call(enclosing,...args);oracle=true;let expected;try{expected=call(enclosing,...args);}finally{oracle=false;}compare('full JDOrdered',actual,expected);return actual;}finally{active--;}
 };
 const controls=(large=false)=>{
  const nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil),atom=tag=>call($atom$,tag),term=(tag,id,quant,kids=[])=>call($kt$,tag,'',id,quant,list(kids));
  const use=id=>'\\n/*JD_USE:'+id+'*/',ref=name=>'\\n/*JD_REF:$jd$'+name+'*/';
  const strings=[['empty',''],['all',use(0)+use(1)+use(12)+use(4294967295)],['only-last',use(4294967295)],['duplicate',use(1).repeat(3)],['no-newline',use(1).slice(1)],['leading-zero','\\n/*JD_USE:01*/'],['id-prefix',use(12)],['escaped','const s="\\\\n/*JD_USE:1*/";'],['raw-quoted','const s="'+use(1)+'";'],['malformed','\\n/*JD_USE:x*/'+use(1)],['nested','\\n/*JD_REF:bad\\n'+use(1)],['partial','x\\n/*JD_U'],['unicode','🧭λ'+use(1)],['unknown-ref',ref('missing')+use(12)],['ref-order',ref('b')+ref('a')+ref('b')+use(1)]];
  if(large)for(const n of [2097151,2097152,2097153])strings.push(['cap-'+n,'x'.repeat(n-use(1).length)+use(1)]);
  const ids=[0,1,12,4294967295],rows=[],defs=list(['a','b'].map(name=>({$:'KDef',name,kind:'Def',arity:0,templates:0,typ:atom('Typ'),value:atom('Typ'),ctors:nil,native:false,unsafe:false}))),names=call($book_cached$,call($jd_reach_names$,defs),0);
  for(const [name,text]of strings){const doc=call($jd_text_raw$,text);for(const id of ids)compare(name+': use '+id,call($jd_text_used$,doc,id),text.includes(use(id)));compare(name+': refs',call($jd_text_refs$,names,doc),call($jd_reach_refs$,names,text,false,2097152,nil));
   for(const count of [0,1,2,4])for(const erased of [false,true]){
    const binds=ids.slice(0,count).map(id=>term('Bind',id,erased?0:1,[term('RHS',id,0)])),xs=list([...binds,atom('Absent')]);
    const previousExpr=$jd_ordered_expr$,previousType=$j_type$,events=[];
    $j_type$=(_b,_e,t)=>{events.push('type:'+t.id);return atom('Typ');};
    $jd_ordered_expr$=(_b,_e,t,_ty,_tail,next)=>{events.push('rhs:'+t.id);return {$:'JDOrdered',prefix:'effect('+t.id+');',value:'rhs'+t.id,next:next+1};};
    try{const actual=call(shared,nil,nil,xs,text,7,19),actualEvents=[...events];events.length=0;const expected=call(old,nil,nil,xs,text,7,19);compare(name+': bindings '+count+'/'+erased,actual,expected);compare(name+': events '+count+'/'+erased,actualEvents,events);const wanted=erased?[]:ids.slice(0,count).filter(id=>text.includes(use(id))).flatMap(id=>['type:'+id,'rhs:'+id]);compare(name+': independent order '+count+'/'+erased,events,wanted);rows.push({name,count,erased,pass:true});}
    finally{$jd_ordered_expr$=previousExpr;$j_type$=previousType;}
   }
  }return rows;
 };
 return {reset,disable(value){disabled=value;},stats(){return JSON.parse(JSON.stringify(stats));},controls};
})();
`;
 parse(original+suffix);const apiFile=path.join(out,'diagnostic-api.mjs');fs.writeFileSync(apiFile,original+suffix,{flag:'wx'});report.derivative={parent:attempt.api,output:pin(apiFile),suffixSha256:hash(suffix),appendOnly:true,parserSha256:hash(parserSource)};
 const module=await import(pathToFileURL(apiFile));assert(!module.G,'Expected named checked B1');const hook=module.phase65OrderedMetadata;
 report.controls=hook.controls(process.env.PHASE65_METADATA_LARGE==='1');save();
 const D=await import(pathToFileURL(driverFile));assert.equal(D.apiPath,attempt.api.file);pin(D.directRuntimePath);
 let cases;
 if(catalogArg){pin(catalogArg);const c=read(catalogArg);assert(Array.isArray(c.cases));cases=c.cases.map(x=>({id:x.id,file:x.source?.file??x.file}));}
 else cases=[{id:'numeric-recurrence',file:path.join(root,'selfhost/tools/performance/phase37/fixtures-new/numeric-recurrence.bend')},{id:'test-map-set-ops',file:path.join(root,'selfhost/tools/performance/phase37/fixtures-historical/test-map-set-ops.bend')},{id:'ordered-parallel-demand',file:path.join(import.meta.dirname,'ordered-parallel-demand.bend')}];
 if(wanted.length)cases=cases.filter(x=>wanted.includes(x.id));assert(cases.length&&cases.length<=32);
 for(const spec of cases){const file=path.resolve(catalogArg?path.dirname(catalogArg):root,spec.file),row={id:spec.id,source:pin(file),pass:false};report.cases.push(row);save();
  try{hook.reset();hook.disable(false);const actual=await D.inspect(file,{mode:'library',backend:'direct',api:module.default});row.counts=hook.stats();row.observation={status:actual.status,checked:actual.checked,diagnostic:actual.diagnostic};assert.equal(actual.status,'ok',actual.diagnostic);assert.equal(actual.checked,true);row.activated=row.counts.eligibleGroups>0;
   hook.disable(true);const old=await D.inspect(file,{mode:'library',backend:'direct',api:module.default});assert.equal(old.status,'ok',old.diagnostic);assert.equal(old.checked,true);assert.equal(actual.code,old.code,'Full module differs from original String.contains demand checks');
   for(const f of [...actual.files,...old.files])pin(f);const output=path.join(out,spec.id+'.mjs');fs.writeFileSync(output,actual.code,{flag:'wx'});row.output=pin(output);row.rawOutputEqual=true;row.pass=true;
  }catch(error){row.error=String(error.stack??error);}save();console.log(JSON.stringify({id:row.id,pass:row.pass,counts:row.counts,error:row.error}));
 }
 await verifyAttempt(attemptArg);for(const x of inputs.values())assert.deepEqual(identity(x.file),x);assert(report.cases.some(x=>x.activated),'No multi-binder ordered demand group selected');report.complete=true;report.pass=report.cases.every(x=>x.pass);if(!report.pass)process.exitCode=1;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.cases.length,error:report.error}));
