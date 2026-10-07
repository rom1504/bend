// Root-supervised diagnostic qualification of actual checked reach helpers.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
import {identity,verify,hash,list,array} from '../../phase54/bootstrap/adapter.mjs';
const [baselineArg,candidateArg,outArg]=process.argv.slice(2);assert(baselineArg&&candidateArg&&outArg);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);assert(out.startsWith(path.join(root,'selfhost/build/phase63')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const inputs=new Map(),pin=(file,want)=>{const r=identity(file);if(want)assert.equal(r.sha256,want.sha256);assert(!inputs.has(r.file)||inputs.get(r.file).sha256===r.sha256);inputs.set(r.file,r);return r;};
const term=(tag,name='')=>({$:'KTerm',tag,name,id:0,quant:0,kids:list([]),removed:list([]),originBegin:0,originEnd:0});
const def=(name,kind='Def',templates=0)=>({$:'KDef',name,kind,arity:0,templates,typ:term('Typ'),value:term('Typ'),ctors:list([]),native:false,unsafe:false});
const encoded=name=>'$jd$'+Array.from(name,c=>/[a-zA-Z0-9]/.test(c)?c:'_'+c.codePointAt(0)+'_').join('');
const marker=name=>'\n/*JD_REF:'+encoded(name)+'*/';
const length=text=>Array.from(text).length;
const report={kind:'phase63-single-lowering-plan-reach-controls',complete:false,pass:false,roles:{},scanner:[],graphs:[],scope:'Actual checked scanner/worklist/filter functions. Scanner inputs are explicit metadata strings; both roles use the installed dedup oracle. Graph tests supply metadata through the actual String jd_definition or JDText jd_doc_definition + jd_text_raw entry identified in each image (candidate must use JDText), preserving per-definition call counts and restoring the emitter afterward. Candidate additionally uses jd_plan_visit and verifies saved definition text ordering. This qualifies logical reach/budget/one-lowering behavior, not the real emitter, full/pruned alias-context equivalence, frontend, B2 emission or program execution. Those remain separate gates.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
const scan=[];
function sc(name,text,expected,{line=false,fuel=length(text),prior=[]}={}){scan.push({name,text,line,fuel,prior,expected});}
sc('empty-zero','',[]);sc('text-exact-fuel','abc',[]);sc('text-one-short','abc',null,{fuel:2});
sc('one-reference',marker('a'),['a']);sc('same-reference-repeated',marker('a').repeat(5),['a','a','a','a','a']);
sc('interleaved-first-occurrence-order',marker('b')+marker('a')+marker('b')+marker('λ'),['λ','b','a','b']);
sc('same-reference-many',marker('a').repeat(512),Array(512).fill('a'));
sc('prior-list-verbatim',marker('a').repeat(2),['a','a'],{prior:['a','sentinel']});
sc('physical-start-enabled',marker('a').slice(1),['a'],{line:true});sc('physical-start-disabled',marker('a').slice(1),[]);
sc('quoted-lookalike','const s="\\n/*JD_REF:'+encoded('a')+'*/";',[]);
sc('inline-lookalike','x/*JD_REF:'+encoded('a')+'*/',[]);sc('indented-lookalike','\n /*JD_REF:'+encoded('a')+'*/',[]);
sc('unicode-text-codepoint-fuel','🧭'+marker('λ'),['λ']);
sc('marker-exact-fuel',marker('a'),['a']);sc('marker-one-short',marker('a'),null,{fuel:length(marker('a'))-1});
sc('prefix-one-short','/*JD_REF:',null,{line:true,fuel:8});sc('unterminated-marker','\n/*JD_REF:'+encoded('a'),null);
sc('unknown-target',marker('missing'),null);sc('duplicate-then-unknown',marker('a').repeat(3)+marker('missing'),null);
sc('duplicate-then-malformed',marker('a').repeat(3)+'\n/*JD_REF:'+encoded('a')+'*x',null);
sc('duplicate-still-scans-whole-text',marker('a').repeat(3),null,{fuel:length(marker('a'))*3-1});
const graphs=[];
function gr(name,rows,roots,options={}){graphs.push({name,rows,roots,...options});}
gr('empty',[],[],{left:0,fuel:0});gr('empty-roots-keeps-metadata',[['unused',[]],['type-row',[], 'ADT']],[],{left:0,fuel:0});
gr('single-leaf',[['a',[]]],['a']);gr('self-cycle',[['a',['a']]],['a']);gr('mutual-cycle',[['b',['a']],['a',['b']]],['a']);
gr('original-definition-order',[['leaf',[]],['unused',[]],['b',['leaf']],['root',['b','leaf']],['type-row',[],'ADT']],['root']);
gr('duplicate-roots',[['a',[]]],['a','a','a']);gr('duplicate-targets',[['a',['b','b','b']],['b',[]]],['a']);
gr('duplicate-targets-tight-candidate',[['a',['b','b','b']],['b',[]]],['a'],{left:2,fuel:2,baselineError:'direct reachability edge budget'});
gr('many-duplicate-targets-tight',[['a',Array(512).fill('b')],['b',[]]],['a'],{left:2,fuel:2,baselineError:'direct reachability edge budget'});
gr('per-definition-reset',[['root',['b','c']],['b',['leaf']],['c',['leaf']],['leaf',[]]],['root'],{left:4,fuel:5});
gr('distinct-edges-one-short',[['root',['b','c']],['b',['leaf']],['c',['leaf']],['leaf',[]]],['root'],{left:4,fuel:4,error:'direct reachability edge budget'});
gr('zero-visit-fuel',[['a',[]]],['a'],{left:1,fuel:0,error:'direct reachability edge budget'});
gr('zero-definition-budget',[['a',[]]],['a'],{left:0,fuel:1,error:'direct reachability definition budget'});
gr('definition-budget-one-short',[['a',['b']],['b',[]]],['a'],{left:1,fuel:2,error:'direct reachability definition budget'});
gr('missing-root',[['a',[]]],['missing'],{left:2,fuel:2,error:'direct reachability missing emitted definition'});
gr('non-definition-root',[['type-row',[],'ADT']],['type-row'],{left:1,fuel:1,error:'direct reachability missing emitted definition'});
gr('unspecialized-root',[['a',[],'Def',1]],['a'],{left:1,fuel:1,error:'direct reachability missing emitted definition'});
gr('unknown-emitted-target',[['a',['missing']]],['a'],{left:1,fuel:2,error:'direct reachability metadata refused'});
gr('duplicate-then-invalid-emitted-target',[['a',['b','b','missing']],['b',[]]],['a'],{left:2,fuel:8,error:'direct reachability metadata refused'});
gr('unreachable-invalid-body',[['a',[]],['unused',['missing']]],['a']);
function closure(spec){const rows=new Map(spec.rows.map(r=>[r[0],r])),seen=new Set(),pending=[...spec.roots];while(pending.length){const n=pending.pop();if(seen.has(n))continue;assert(rows.has(n));seen.add(n);pending.push(...rows.get(n)[1]);}return {visited:[...seen].sort(),names:spec.rows.filter(r=>r[2]&&r[2]!=='Def'||seen.has(r[0])).map(r=>r[0])};}
try{
 const parent=pin(new URL('../../phase58/qualification/reach-controls.mjs',import.meta.url));assert.equal(parent.sha256,'3487ac217e35977e81f8afaeaeb5582bb3fc4525e78d8ac8fddedd26d0afc61c');report.parent=parent;
 for(const f of [import.meta.filename,process.execPath,new URL('../../../development/workflow.mjs',import.meta.url),new URL('../../phase54/bootstrap/adapter.mjs',import.meta.url)])pin(f);
 const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};new Function('module','exports',parserSource)(parser,parser.exports);
 const parse=s=>parser.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
 for(const [role,directory]of [['baseline',baselineArg],['candidate',candidateArg]]){
  const attempt=await verifyAttempt(directory);assert(attempt.checked&&attempt.config.strictExact);const attemptId=pin(path.join(directory,'attempt.json'));
  for(const k of ['api','runtime','base','node','bootstrapReport'])pin(attempt[k].file,attempt[k]);assert.equal(identity(process.execPath).sha256,attempt.node.sha256);
  const validation=pin(path.join(directory,'validation-001/report.json')),v=JSON.parse(fs.readFileSync(validation.file));assert(v.complete&&v.pass&&v.strictExact&&v.selected.exactDifferences===0);assert.equal(v.attempt.sha256,attemptId.sha256);assert.equal(v.api.sha256,attempt.api.sha256);
  const original=fs.readFileSync(attempt.api.file,'utf8'),ast=parse(original);
  const definitionName=role==='candidate'?'$jd_plan_definition$':'$jd_reach_definition$';
  const selected=ast.body.find(x=>x.type==='FunctionDeclaration'&&x.id.name===definitionName);assert(selected,definitionName);
  const body=original.slice(selected.start,selected.end),structured=body.includes('$jd_doc_definition$(');
  assert.notEqual(structured,body.includes('$jd_definition$('),'exactly one real metadata entry');if(role==='candidate')assert(structured);
  const names=['run_loop','$book_cached$','$jd_reach_names$','$jd_reach_refs$','$jd_reach_visit$','$jd_reach_defs$','$jd_reach_error$','$jd_reach_definition$','$missing$',...(structured?['$jd_doc_definition$','$jd_text_raw$']:['$jd_definition$']),...(role==='candidate'?['$jd_plan_visit$','$jd_plan_defs$','$jd_plan_error$','$jd_plan_definitions$']:[])];
  for(const n of names)assert.equal(ast.body.filter(x=>x.type==='FunctionDeclaration'&&x.id.name===n).length,1,n);assert(!original.includes('phase61Reach'));
  const emitter=structured?'$jd_doc_definition$':'$jd_definition$';
  assert(original.slice(selected.start,selected.end).includes(emitter+'('),'actual reach path must call selected emitter');
  const value=structured?'run_loop($jd_text_raw$(texts[d.name]))':'texts[d.name]';
  const suffix=`\nexport const phase61ReachRefs=(defs,text,line,fuel,prior)=>run_loop($jd_reach_refs$(run_loop($book_cached$(run_loop($jd_reach_names$(defs)),0)),text,line,fuel,prior));
export const phase61ReachVisit=(defs,roots,left,fuel,texts)=>{
 const previous=${emitter},calls=[];
 ${emitter}=(_book,d)=>{if(!Object.hasOwn(texts,d.name))throw Error('Missing diagnostic metadata');calls.push(d.name);return ${value};};
 try{const book=run_loop($book_cached$(defs,0)),names=run_loop($book_cached$(run_loop($jd_reach_names$(defs)),0));
 ${role==='candidate'?"const r=run_loop($jd_plan_visit$(book,names,defs,roots,run_loop($missing$()),left,fuel));return{defs:run_loop($jd_plan_defs$(r)),error:run_loop($jd_plan_error$(r)),calls,text:r.error?'':run_loop($jd_plan_definitions$(r.defs,r.texts))};":"const r=run_loop($jd_reach_visit$(book,names,defs,roots,run_loop($missing$()),left,fuel));return{defs:run_loop($jd_reach_defs$(r)),error:run_loop($jd_reach_error$(r)),calls};"}}
 finally{${emitter}=previous;}
};\n`;
  parse(original+suffix);const file=path.join(out,role+'-diagnostic.mjs');fs.writeFileSync(file,original+suffix,{flag:'wx'});const derivative=pin(file);assert(fs.readFileSync(file).subarray(0,Buffer.byteLength(original)).equals(fs.readFileSync(attempt.api.file)));
  report.roles[role]={attempt:attemptId,validation,api:attempt.api,derivative,suffixSha256:hash(suffix),parser:{version:parser.exports.version,sha256:hash(parserSource)},productionAbiChanged:false,metadataHook:emitter,scannerPolicy:'distinct targets in reverse first-occurrence order; prior list unchanged'};
  const api=await import(pathToFileURL(file));const defs=list(['a','b','λ'].map(n=>def(n)));
  for(const s of scan){const got=api.phase61ReachRefs(defs,s.text,s.line,s.fuel,list(s.prior)),expected=s.expected===null?null:[...new Set([...s.expected].reverse())].reverse().concat(s.prior);const value=got.$==='None'?null:array(got.value);assert.deepEqual(value,expected,role+': '+s.name);report.scanner.push({role,name:s.name,inputSha256:hash(s.text),codepoints:length(s.text),fuel:s.fuel,expected,value});}
  for(const s of graphs){const ds=list(s.rows.map(r=>def(r[0],r[2],r[3]))),before=JSON.stringify(ds),texts=Object.fromEntries(s.rows.map(r=>[r[0],r[1].map(marker).join('')]));const got=api.phase61ReachVisit(ds,list(s.roots),s.left??64,s.fuel??4096,texts),error=s.error??'';assert.equal(got.error,error,role+': '+s.name);const returned=array(got.defs).map(d=>d.name);if(error)assert.deepEqual(returned,[]);else{const expected=closure(s);assert.deepEqual(returned,expected.names,role+': '+s.name);assert.deepEqual([...got.calls].sort(),expected.visited);assert.equal(new Set(got.calls).size,got.calls.length);if(role==='candidate')assert.equal(got.text,s.rows.filter(r=>(r[2]??'Def')==='Def'&&expected.names.includes(r[0])).map(r=>texts[r[0]]).join(''),role+': '+s.name+': saved output follows original definition order');}assert.equal(JSON.stringify(ds),before);report.graphs.push({role,name:s.name,left:s.left??64,fuel:s.fuel??4096,error,returned,emitterCalls:got.calls});}
  await verifyAttempt(directory);save();
 }
 assert.equal(scan.length,22);assert.equal(graphs.length,21);
 for(const r of inputs.values())verify(r);report.inputsUnchanged=true;report.complete=report.pass=true;report.counts={scannerPerRole:scan.length,graphPerRole:graphs.length,roles:2};
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,counts:report.counts,error:report.error?.message}));
