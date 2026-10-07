// Existing checked baseline only. Root owns the sole external resource guard.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
const [attemptArg,outArg]=process.argv.slice(2);assert(attemptArg&&outArg);
const raw=path.resolve(import.meta.dirname,'../../../../build/phase61'),out=path.resolve(outArg);assert(out.startsWith(raw+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=b=>createHash('sha256').update(b).digest('hex'),inputs=new Map();
function pin(f,want){const bytes=fs.readFileSync(f),r={file:fs.realpathSync(f),sha256:hash(bytes),bytes:bytes.length};if(want)assert.equal(r.sha256,want.sha256);if(inputs.has(r.file))assert.deepEqual(r,inputs.get(r.file));inputs.set(r.file,r);return r;}
const array=xs=>{const a=[];while(xs?.$==='Con'){assert(a.length<30000);a.push(xs.head);xs=xs.tail;}assert.equal(xs?.$,'Nil');return a;};
const list=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const digest=x=>hash(JSON.stringify(x,(_,v)=>typeof v==='bigint'?{$bigint:String(v)}:v));
const report={kind:'phase61-baseline-base-state-probe',version:2,complete:false,pass:false,scope:'Read-only existing checked baseline with private lexical projections. No candidate, no resume, no compiler-speed or semantic-equivalence claim.',inputs:[]};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};save();
try{
 pin(import.meta.filename);report.parentProducer=pin(path.join(import.meta.dirname,'base-probe-v1.mjs'));pin(process.execPath);pin(new URL('../../../development/workflow.mjs',import.meta.url).pathname);
 const directory=fs.realpathSync(attemptArg),attempt=pin(path.join(directory,'attempt.json')),m=await verifyAttempt(directory);assert(m.checked);
 for(const k of ['api','runtime','base','node'])pin(m[k].file,m[k]);assert.equal(pin(process.execPath).sha256,m.node.sha256);
 const original=fs.readFileSync(m.api.file,'utf8'),P={exports:{}};const parserText=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'];new Function('module','exports',parserText)(P,P.exports);
 const parse=s=>P.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),ast=parse(original);
 const names=['run_loop','$dg_check_world$','$dg_checking_result$','$norm_max_book$','$kw_book$','$kw_memo$','$kw_fresh$','$kw_checked$','$rw$','$sp_assembled$'];
 for(const name of names)assert.equal(ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id?.name===name).length,1,name);
 const suffix='\nexport const phase61BaseState={check:b=>run_loop($dg_check_world$(b)),result:r=>run_loop($dg_checking_result$(r)),bound:b=>run_loop($norm_max_book$(b)),world:r=>run_loop($rw$(r)),book:w=>run_loop($kw_book$(w)),memo:w=>run_loop($kw_memo$(w)),fresh:w=>run_loop($kw_fresh$(w)),checked:w=>run_loop($kw_checked$(w)),assembled:w=>run_loop($sp_assembled$(w))};\n';
 parse(original+suffix);const derivative=path.join(out,'baseline-probe.mjs');fs.writeFileSync(derivative,original+suffix,{flag:'wx'});pin(derivative);
 const mod=await import(pathToFileURL(derivative));assert.equal(mod.G,undefined);const Q=mod.phase61BaseState;
 for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];process.env.BEND_TYPED_API=m.api.file;process.env.BEND_TYPED_RUNTIME=m.runtime.file;process.env.BEND_BASE=m.base.file;
 const driverFile=pin(path.join(m.snapshot.root,'tools/typed-driver.mjs')),D=await import(pathToFileURL(driverFile.file)),api=await D.loadApi();assert.equal(D.apiPath,m.api.file);
 const text=fs.readFileSync(m.base.file,'utf8'),rawSource={$:'FSource',name:'Base',path:m.base.file,text};
 const loaded=api.f_load_graph('Base',list([api.f_source_located(rawSource,1,text.length+2)]));assert.equal(loaded.error,'');
 const defs=array(loaded.book),bound=Q.bound(loaded.book),before=digest(loaded.book),started=performance.now(),checked=Q.check(loaded.book),checkDiagnosticMs=performance.now()-started,result=Q.result(checked),world=Q.world(result);
 assert.equal(result.error,'');assert.equal(digest(loaded.book),before);
 const memo=array(Q.memo(world)),output=array(Q.checked(world)),worldDefs=array(Q.book(world)),assembled=array(Q.assembled(world)),fresh=Q.fresh(world);
 const declaredNames=new Set(),constructorNames=new Set();function defsWalk(ds){for(const d of ds){declaredNames.add(d.name);const cs=array(d.ctors);for(const c of cs)constructorNames.add(c.name);defsWalk(cs);}}defsWalk(defs);
 const references=new Set(),missing=new Set();let termNodes=0;function walk(t){termNodes++;if(t.$==='KLiteral')return;if(t.$!=='KTerm'&&t.$!=='KLambda')return;if(t.tag==='Ref'){references.add(t.name);if(!declaredNames.has(t.name))missing.add(t.name);}for(const kid of array(t.kids))walk(kid);}
 function scan(ds){for(const d of ds){walk(d.typ);walk(d.value);scan(array(d.ctors));}}scan(defs);
 const memoNames=memo.map(x=>({template:x.template,key:x.key,name:x.name,active:x.active}));
 const oldNames=new Set(defs.map(d=>d.name)),generated=worldDefs.filter(d=>d.kind!=='BookCache'&&!oldNames.has(d.name)).map(d=>d.name);
 report.selection={attempt,api:m.api,runtime:m.runtime,base:m.base,node:m.node,driver:driverFile,derivative:pin(derivative),suffixSha256:hash(suffix)};
 report.base={events:defs.length,bookSha256:before,bound,resultSha256:digest(checked),worldSha256:digest(world),checkDiagnosticMs,worldDefinitions:worldDefs.length,checkedCount:output.length,assembledCount:assembled.length,checkedMaxBound:Q.bound(list(output)),assembledMaxBound:Q.bound(list(assembled)),memoCount:memo.length,memo:memoNames,fresh,generatedNames:generated,checkedNames:output.map(d=>d.name),termNodes,refNames:[...references].sort(),unresolvedRefs:[...missing].sort(),constructorNames:[...constructorNames].sort()};
 report.noMintEvidence={memoEmpty:memo.length===0,freshUnchanged:fresh.$==='KFreshKnown'&&fresh.next===bound+1,generatedNamesEmpty:generated.length===0,closedRefs:missing.size===0,checkedIdsWithinSourceBound:Q.bound(list(output))<=bound,assembledIdsWithinSourceBound:Q.bound(list(assembled))<=bound};
 report.interpretation='All predicates would support investigating a Base-only rebase, not prove it. Declaration/output order, fresh-derived checked terms, negative lookups, constructor capture, completion state and source/memo authenticity remain obligations. Any false predicate blocks a zero-mint/closed-reference shortcut. Diagnostic elapsed time is not a clean compiler latency measurement.';
 for(const r of inputs.values())pin(r.file,r);report.complete=true;report.pass=true;save();
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};save();throw error;}
