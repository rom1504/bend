// Root-supervised diagnostic only. Instrumented clocks are not performance data.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [attemptArg,outArg,catalogArg,...wanted]=process.argv.slice(2);assert(attemptArg&&outArg);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase65')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=x=>createHash('sha256').update(x).digest('hex'),identity=file=>({file:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const inputs=new Map(),pin=(file,want)=>{const x=identity(file);if(want)assert.equal(x.sha256,want.sha256);if(inputs.has(x.file))assert.deepEqual(inputs.get(x.file),x);inputs.set(x.file,x);return x;};
const report={kind:'phase65-structured-closure-return-differential',complete:false,pass:false,cases:[],scope:'Actual checked B1, append-only diagnostic. Compare live-lambda return rendering, USE/REF/size/refusal semantics and entire emitted modules with the old String round trip. Synthetic transport controls include actual candidate helper with a controlled body producer. Instrumented clocks are not speed evidence.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
try{
 const read=f=>JSON.parse(fs.readFileSync(f,'utf8'));report.attempt=pin(path.join(attemptArg,'attempt.json'));const raw=read(report.attempt.file);
 for(const k of Object.keys(process.env))if(k.startsWith('BEND_'))delete process.env[k];
 process.env.BEND_TYPED_API=raw.api.file;process.env.BEND_TYPED_RUNTIME=raw.runtime.file;process.env.BEND_BASE=raw.base.file;
 const workflowFile=path.resolve(import.meta.dirname,'../../../development/workflow.mjs');pin(workflowFile);
 const {verifyAttempt}=await import(pathToFileURL(workflowFile));const attempt=await verifyAttempt(attemptArg);assert(attempt.checked&&attempt.config.strictExact);
 for(const k of ['api','runtime','base','node','bootstrapReport'])pin(attempt[k].file,attempt[k]);pin(import.meta.filename);pin(process.execPath);
 assert.equal(identity(process.execPath).sha256,attempt.node.sha256);
 const manifestFile=path.join(import.meta.dirname,'closure-candidate.json');report.candidateManifest=pin(manifestFile);const candidate=read(manifestFile);
 assert.equal(candidate.target,'selfhost/src/back/js/direct/core.bend');report.candidatePatch=pin(path.join(import.meta.dirname,'closure-candidate.patch'),{sha256:candidate.patchSha256});
 report.candidateSnapshotSource=pin(path.join(attempt.snapshot.root,'src/back/js/direct/core.bend'),{sha256:candidate.afterSha256});
 const driverFile=path.join(attempt.snapshot.root,'tools/typed-driver.mjs');pin(driverFile);
 const original=fs.readFileSync(attempt.api.file,'utf8'),parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};
 new Function('module','exports',parserSource)(parser,parser.exports);const parse=s=>parser.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),ast=parse(original);
 const names=['run_loop','$jd_doc_body_live_lambda$','$jd_doc_body$','$jd_expr$','$jd_text_raw$','$jd_text_used$','$jd_text_refs$','$jd_text_render$','$jd_text_size$','$jd_text_safe$','$jd_text_many$','$jd_text_literal$','$jd_reach_refs$','$jd_reach_names$','$book_cached$','$kt$','$atom$','$tg$','$qt$','$jd_owner$'];
 for(const n of names)assert.equal(ast.body.filter(x=>x.type==='FunctionDeclaration'&&x.id.name===n).length,1,n);assert(!original.includes('phase65ClosureMetadata'));
 const suffix=`
export const phase65ClosureMetadata=(()=>{
 let disabled=false,oracle=false,active=0,stats;
 const call=(fn,...args)=>run_loop(fn(...args)),nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
 const serialize=x=>JSON.stringify(x,(_,v)=>typeof v==='bigint'?{$bigint:String(v)}:v);
 const reset=()=>{stats={eligibleClosures:0,comparedClosures:0,compared:0,comparedCharacters:0,codepoints:0};};reset();
 const compare=(name,a,b)=>{const x=serialize(a),y=serialize(b);stats.comparedCharacters+=x.length;if(stats.comparedCharacters>134217728)throw Error('Closure diagnostic byte budget');if(x!==y)throw Error('Closure metadata differs: '+name);stats.compared++;};
 const atom=tag=>call($atom$,tag),term=(tag,id,quant,kids=[],name='')=>call($kt$,tag,name,id,quant,list(kids));
 const nameMaps=new WeakMap(),namesFor=book=>{if(!nameMaps.has(book))nameMaps.set(book,call($book_cached$,call($jd_reach_names$,book),0));return nameMaps.get(book);};
 const notes=doc=>{const out=[],todo=[doc];while(todo.length){const t=todo.pop();if(t.$==='JDTextLeaf'){let xs=t.notes;while(xs.$==='Con'){out.push(xs.head);xs=xs.tail;}if(xs.$!=='Nil')throw Error('Note list');}else if(t.$==='JDTextJoin'){todo.push(t.right,t.left);}else throw Error('JDText changed');}return out;};
 const semantic=(label,actual,old,names)=>{
  const code=call($jd_text_render$,actual),before=call($jd_text_render$,old),size=Array.from(code).length;
  compare(label+': rendered bytes',code,before);compare(label+': size',call($jd_text_size$,actual),Math.min(size,2097153));compare(label+': old size',call($jd_text_size$,old),Math.min(size,2097153));
  const ids=new Set([0,7,11,4294967295]);for(const m of code.matchAll(/\\n\\/\\*JD_USE:(\\d+)\\*\\//g)){const n=Number(m[1]);if(Number.isSafeInteger(n)&&n<=4294967295)ids.add(n);if(ids.size>100000)throw Error('Use ID budget');}
  for(const id of ids){const expected=code.includes('\\n/*JD_USE:'+id+'*/');compare(label+': use '+id,call($jd_text_used$,actual,id),expected);compare(label+': old use '+id,call($jd_text_used$,old,id),expected);}
  const refs=call($jd_text_refs$,names,actual),oldRefs=call($jd_text_refs$,names,old),scanner=call($jd_reach_refs$,names,code,false,2097152,nil);
  compare(label+': refs',refs,oldRefs);compare(label+': scanner refs',refs,scanner);
  if(size<=2097152&&call($jd_text_safe$,actual)&&call($jd_text_safe$,old))compare(label+': ordered notes',notes(actual),notes(old));
  return {codepoints:size,size:call($jd_text_size$,actual),refs,used7:call($jd_text_used$,actual,7)};
 };
 const enclosing=$jd_doc_body_live_lambda$;
 const legacy=args=>call($jd_text_raw$,'return '+call($jd_expr$,...args.slice(0,4))+';');
 $jd_doc_body_live_lambda$=(...args)=>{
  if(args[4].$!=='Nil')return enclosing(...args);
  if(call($tg$,args[2])!=='Lam'||call($tg$,args[3])!=='All'||call($qt$,args[3])===0)throw Error('Enclosing closure precondition');
  if(disabled||oracle)return legacy(args);
  if(++stats.eligibleClosures>100000)throw Error('Closure admission budget');if(active)return enclosing(...args);
  active++;try{const actual=call(enclosing,...args);oracle=true;let old;try{old=legacy(args);}finally{oracle=false;}const result=semantic('live lambda',actual,old,namesFor(args[0]));stats.comparedClosures++;stats.codepoints+=result.codepoints;return actual;}finally{active--;}
 };
 const controls=(large=false)=>{
  const defs=list(['f','g'].map(name=>({$:'KDef',name,kind:'Def',arity:0,templates:0,typ:atom('Typ'),value:atom('Typ'),ctors:nil,native:false,unsafe:false}))),names=namesFor(defs);
  const raw=text=>call($jd_text_raw$,text),join=xs=>call($jd_text_many$,list(xs)),use=id=>'\\n/*JD_USE:'+id+'*/',ref=name=>'\\n/*JD_REF:$jd$'+name+'*/';
  const cases=[['empty',()=>raw(''),[]],['uses-and-refs',()=>raw(use(7)+'x;'+ref('f')+'f();'+use(11)+'y;'+ref('g')+'g();'+ref('f')+'f();'),['g','f']],['without-newline',()=>raw('/*JD_USE:7*/x'),[]],['leading-zero',()=>raw(use('007')+'x'),[]],['unknown-ref',()=>raw(ref('missing')),null],['partial',()=>raw('x\\n/*JD_RE'),[]],['unterminated',()=>raw('x\\n/*JD_REF:$jd$f'),null],['malformed',()=>raw('x\\n/*JD_REF:bad*/'),null],['split',()=>join([raw('\\n/*JD_RE'),raw('F:$jd$f*/f();')]),['f']],['unicode',()=>raw('🧭'+use(7)),[]]];
  if(large)for(const delta of [-1,0,1])cases.push(['cap'+delta,()=>raw((delta===0?'🧭':'x')+'x'.repeat(2097152-26+delta-1)),delta>0?null:[]]);
  const rows=[],env=list([term('$JD.Owner',4294967295,0,[],'owner-witness'),term('Capture',7,0)]),t=term('Lam',17,1,[atom('Absent')]),ty=term('All',18,1,[atom('Typ'),atom('Typ')]),args=[defs,env,t,ty,nil];
  for(const [name,make,expectedRefs]of cases){const body=make(),prior=$jd_doc_body$,events=[];
   $jd_doc_body$=(...a)=>{events.push(a);return body;};
   try{const actual=call(enclosing,...args),actualEvents=[...events];events.length=0;const old=legacy(args);compare(name+': body arguments',actualEvents,events);if(events.length!==1||call($jd_owner$,events[0][1])!=='')throw Error('Owner removal/body count');compare(name+': retained capture',events[0][1],list([term('Capture',7,0)]));compare(name+': initial body arg',events[0][4],list(['$arg']));
    const result=semantic(name,actual,old,names);compare(name+': independent refs',result.refs,expectedRefs===null?{$:'None'}:{$:'Some',value:list(expectedRefs)});
    if(name==='without-newline'||name==='leading-zero')compare(name+': nonuse',result.used7,false);
    rows.push({name,pass:true,codepoints:result.codepoints,size:result.size,refs:result.refs});
   }finally{$jd_doc_body$=prior;}
  }return rows;
 };
 return {reset,disable(value){disabled=value;},stats(){return JSON.parse(JSON.stringify(stats));},controls};
})();
`;
 parse(original+suffix);const apiFile=path.join(out,'diagnostic-api.mjs');fs.writeFileSync(apiFile,original+suffix,{flag:'wx'});report.derivative={parent:attempt.api,output:pin(apiFile),suffixSha256:hash(suffix),appendOnly:true,parserSha256:hash(parserSource)};
 const module=await import(pathToFileURL(apiFile));assert(!module.G,'Expected named checked B1');const hook=module.phase65ClosureMetadata;
 report.controls=hook.controls(process.env.PHASE65_CLOSURE_LARGE==='1');save();
 const D=await import(pathToFileURL(driverFile));assert.equal(D.apiPath,attempt.api.file);pin(D.directRuntimePath);
 let cases;
 if(catalogArg){pin(catalogArg);const c=read(catalogArg);assert(Array.isArray(c.cases));cases=c.cases.map(x=>({id:x.id,file:x.source?.file??x.file}));}
 else cases=[{id:'numeric-recurrence',file:path.join(root,'selfhost/tools/performance/phase37/fixtures-new/numeric-recurrence.bend')},{id:'test-map-set-ops',file:path.join(root,'selfhost/tools/performance/phase37/fixtures-historical/test-map-set-ops.bend')},{id:'structured-closure-return',file:path.join(import.meta.dirname,'structured-closure-return.bend')},{id:'structured-erased-closure-return',file:path.join(import.meta.dirname,'structured-erased-closure-return.bend')},{id:'closures-hof',file:path.join(root,'tests/run/closures_hof.bend')},{id:'closure-owner-scope',file:path.join(root,'tests/run/js_tail_closure.bend')},{id:'erased-generic-closure',file:path.join(root,'tests/reg/closure_keep_generic.bend')}];
 if(wanted.length)cases=cases.filter(x=>wanted.includes(x.id));assert(cases.length&&cases.length<=32);
 for(const spec of cases){const file=path.resolve(catalogArg?path.dirname(catalogArg):root,spec.file),row={id:spec.id,source:pin(file),pass:false};report.cases.push(row);save();
  try{hook.reset();hook.disable(false);const actual=await D.inspect(file,{mode:'library',backend:'direct',api:module.default});row.counts=hook.stats();row.observation={status:actual.status,checked:actual.checked,diagnostic:actual.diagnostic};assert.equal(actual.status,'ok',actual.diagnostic);assert.equal(actual.checked,true);row.activated=row.counts.eligibleClosures>0;
   hook.disable(true);const old=await D.inspect(file,{mode:'library',backend:'direct',api:module.default});assert.equal(old.status,'ok',old.diagnostic);assert.equal(old.checked,true);assert.equal(actual.code,old.code,'Full module differs from original closure render/rescan');
   for(const f of [...actual.files,...old.files])pin(f);const output=path.join(out,spec.id+'.mjs');fs.writeFileSync(output,actual.code,{flag:'wx'});row.output=pin(output);row.rawOutputEqual=true;row.pass=true;
  }catch(error){row.error=String(error.stack??error);}save();console.log(JSON.stringify({id:row.id,pass:row.pass,counts:row.counts,error:row.error}));
 }
 await verifyAttempt(attemptArg);for(const x of inputs.values())assert.deepEqual(identity(x.file),x);assert(report.cases.some(x=>x.activated),'No live-lambda closure selected');report.complete=true;report.pass=report.cases.every(x=>x.pass);if(!report.pass)process.exitCode=1;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.cases.length,error:report.error}));
