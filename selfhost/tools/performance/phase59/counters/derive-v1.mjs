// Data-only producer: parse a genuine B2, insert bounded counters, never import it.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {fileURLToPath} from 'node:url';

const ROOT=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'../../../../..');
const PARENT='a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081';
const PUBLICATION='0338c3a7bb88a0564e692fb09e2b8ede6c0e24352a239525e6d8b892f5f0cf90';
const digest=b=>crypto.createHash('sha256').update(b).digest('hex');
function identity(file){const b=fs.readFileSync(file);return {file:fs.realpathSync(file),bytes:b.length,sha256:digest(b)};}
const inputs=[];
function pin(file,expected){const i=identity(file);if(expected)assert.equal(i.sha256,expected);inputs.push(i);return i;}
function selected(i){const r=pin(path.join(ROOT,i.path),i.sha256);assert.equal(r.bytes,i.bytes);return r;}
assert.equal(process.argv.length,3,'usage: node derive-v1.mjs FRESH_BUILD_PHASE59_DIRECTORY');
const out=path.resolve(process.argv[2]),allowed=path.join(ROOT,'selfhost/build/phase59')+path.sep;
assert(out.startsWith(allowed));assert(!fs.existsSync(out),'fresh output required');
let ancestor=path.dirname(out);while(!fs.existsSync(ancestor))ancestor=path.dirname(ancestor);
assert.equal(fs.realpathSync(ancestor),ancestor,'no symlink output parents');
const producer=pin(fileURLToPath(import.meta.url));
const publication=pin(path.join(ROOT,'selfhost/tools/performance/phase58/publication.json'),PUBLICATION);
const pub=JSON.parse(fs.readFileSync(publication.file));
assert.equal(pub.kind,'phase58-qualified-compiler-publication');assert.equal(pub.complete,true);
const parent=selected(pub.selected.directB2),runtime=selected(pub.selected.directRuntime);
selected(pub.selected.attempt);selected(pub.selected.source);assert.equal(parent.sha256,PARENT);
const bytes=fs.readFileSync(parent.file),source=bytes.toString('utf8');
assert.equal(Buffer.compare(bytes,Buffer.from(source)),0);
const prefix=fs.readFileSync(runtime.file,'utf8')+'\n';assert(source.startsWith(prefix));
assert(!source.includes('$phase59Counter'),'reserved diagnostic name collision');
const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'];
const M={exports:{}};new Function('module','exports',parserSource)(M,M.exports);
const parse=s=>M.exports.parse(s,{ecmaVersion:'latest',sourceType:'module',preserveParens:true});
const ast=parse(source),functions=new Map(ast.body.filter(n=>n.type==='FunctionDeclaration').map(n=>[n.id.name,n]));
function unparen(n){while(n?.type==='ParenthesizedExpression')n=n.expression;return n;}
function walk(n,fn){if(!n||typeof n!=='object')return;fn(n);for(const [k,v]of Object.entries(n)){if(k==='start'||k==='end')continue;if(Array.isArray(v))for(const x of v)walk(x,fn);else if(v&&typeof v==='object')walk(v,fn);}}
function name(s){return '$jd$'+[...s].map(c=>/[A-Za-z0-9]/.test(c)?c:'_'+c.codePointAt(0)+'_').join('');}
function params(fn){return Array.from(fn.params,p=>{assert.equal(p.type,'Identifier');return p.name;});}
const edits=new Map(),metrics=[],metricIndex=new Map(),sites=[],modified=new Set();
function metric(k){if(!metricIndex.has(k)){metricIndex.set(k,metrics.length);metrics.push(k);}return metricIndex.get(k);}
function inc(k,value='1'){return `$phase59CounterRow[${metric(k)}]+=${value};`;}
function insert(at,text,why){assert(at>=prefix.length);edits.set(at,(edits.get(at)||'')+'\nif($phase59CounterActive){'+text+'}\n');sites.push({at,why});}
function semantic(s){
 const f=functions.get(name(s));assert(f,`missing ${s}`);const ps=params(f);let body=f.body,worker=null,pc=null;
 const first=f.body.body[0];
 if(first?.type==='ReturnStatement'){
  const call=unparen(first.argument);assert.equal(call.type,'CallExpression');
  assert.equal(call.callee.type,'Identifier');assert(call.callee.name.endsWith('$scc'));
  worker=functions.get(call.callee.name);assert(worker);pc=unparen(call.arguments[0]).value;assert(Number.isInteger(pc));
  assert.deepEqual(params(worker),['$pc',...ps]);assert.equal(call.arguments.length,ps.length+1);
  call.arguments.slice(1).forEach((a,i)=>assert.equal(unparen(a).name,ps[i]));
  assert.equal(worker.body.body.length,1);const loop=worker.body.body[0];assert.equal(loop.type,'ForStatement');
  assert.equal(loop.init,null);assert.equal(loop.test,null);assert.equal(loop.update,null);assert.equal(loop.body.type,'SwitchStatement');
  assert.equal(loop.body.discriminant.name,'$pc');const c=loop.body.cases.filter(c=>c.test?.value===pc);assert.equal(c.length,1);
  assert.equal(c[0].consequent.length,1);body=c[0].consequent[0];assert.equal(body.type,'BlockStatement');
 }else if(first?.type==='ForStatement'){
  assert.equal(f.body.body.length,1);assert.equal(first.init,null);assert.equal(first.test,null);assert.equal(first.update,null);
  assert.equal(first.body.type,'BlockStatement');body=first.body;
 }
 modified.add((worker||f).id.name);
 return {source:s,function:f,body,worker:worker?.id.name||null,pc,params:ps};
}
function entry(s,extra=''){const q=semantic(s);insert(q.body.start+1,inc(s+'.entries')+extra,s+' semantic entry');return q;}
function branches(q,callee,yes,no){
 const hits=[];walk(q.body,n=>{if(n.type==='IfStatement'){let found=false;walk(n.test,x=>{if(x.type==='CallExpression'&&unparen(x.callee)?.name===name(callee))found=true;});if(found)hits.push(n);}});
 assert.equal(hits.length,1,`${q.source} branch ${callee}`);
 for(const [b,k]of [[hits[0].consequent,yes],[hits[0].alternate,no]]){assert.equal(b.type,'BlockStatement');insert(b.start+1,inc(k),q.source+' existing branch outcome');}
}

// Counters describe source-level work, never physical heap allocations.
const table=entry('jd_primitive_table');const tableTags={};
walk(table.body,n=>{if(n.type==='ObjectExpression'){const p=n.properties.find(p=>p.type==='Property'&&!p.computed&&p.key.name==='$');if(p?.value.type==='Literal')tableTags[p.value.value]=(tableTags[p.value.value]||0)+1;}});
assert.deepEqual(tableTags,{Con:90,JDPrimitive:90,Nil:1});
entry('jd_primitive_candidate_emit');entry('jd_native_known');entry('jd_primitive_find');
entry('jd_primitive_find_row',inc('primitive.lookupComparisons'));
entry('jd_primitive_telescope');entry('jd_primitive_template');

// A named wrapper counts search starts; SCC case entries count all suffix steps.
const contains=entry('String.contains',`if($a0!==""){${inc('contains.nonemptySuffixSteps')}}if($a1.startsWith("\\n/*JD_USE:")){${inc('contains.useMarkerSteps')}}else{${inc('contains.otherSteps')}}`);
assert(contains.worker);
insert(contains.function.body.start+1,`if($a1.startsWith("\\n/*JD_USE:")){${inc('contains.useMarkerQueries')}${inc('contains.useMarkerInputUtf16','$a0.length')}}else{${inc('contains.otherQueries')}${inc('contains.otherInputUtf16','$a0.length')}}`,'String.contains named search entry');
modified.add(contains.function.id.name);
entry('String.contains.if',`if($a2){${inc('contains.successfulPrefixTests')}}`);
entry('String.starts_with');
for(const s of ['jd_body_bound','jd_let_bindings','jd_ordered_lets','jd_ordered_bindings','jd_word_bind_used','jd_definition','jd_component_case'])entry(s);
entry('jd_reach_refs',inc('refs.inputUtf16','$a1.length'));
entry('jd_reach_refs_unique',`if($a1!==""){${inc('refs.nonemptySuffixSteps')}}`);
entry('jd_reach_marker',`if($a1!==""){${inc('refs.nonemptyMarkerSteps')}}`);
const done=entry('jd_reach_marker_done');
branches(done,'index_find','refs.uniqueValidatedEdges','refs.duplicateValidatedMarkers');
entry('jd_reach_definition');entry('jd_reach_follow');

entry('subst',`if($a0.$==="KTerm"&&$a0.tag==="Var"){if($a0.id===$a1){${inc('subst.matchingVars')}}else{${inc('subst.otherVars')}}}`);
entry('subst_node',`if($a0.$==="KLiteral"){${inc('subst.literalReuse')}}else{${inc('subst.nonliteralRebuildEntries')}}`);
entry('subst_terms',`if($a0.$==="Con"){${inc('subst.childListNodes')}}`);
entry('core_subst_stable');entry('core_subst_stable_terms');
for(const s of ['ka_args_after_head','tele_check_after_head'])branches(entry(s),'core_subst_stable',s+'.stableTrue',s+'.stableFalse');
for(const s of ['index_set','index_insert','index_node','index_leaf','book_put','index_put_rest','index_bucket'])entry(s);
entry('index_remove',`if($a0.$==="Con"){${inc('index.removeListVisits')}}`);
entry('index_remove_step',`if($a3){${inc('index.removedEntries')}}else{${inc('index.retainedListConstructors')}}`);
entry('index_hash',`if($a0!==""){${inc('index.hashCodepointSteps')}}`);
entry('uses_merge',`if($a0.$==="Con"){${inc('quantity.mergeLeftEntries')}if($a2){${inc('quantity.branchJoinEntries')}}else{${inc('quantity.sequenceAddEntries')}}}`);
entry('uses_get',`if($a0.$==="Con"){${inc('quantity.getListVisits')}}`);
entry('uses_del',`if($a0.$==="Con"){${inc('quantity.delListVisits')}if($a0.head.id!==$a1){${inc('quantity.retainedListConstructors')}}}`);

const suffix=`\n// Diagnostic-only API; root worker controls request/stage boundaries.
const $phase59CounterNames=${JSON.stringify(metrics)};
let $phase59CounterActive=false,$phase59CounterRow=new Float64Array(${metrics.length}),$phase59CounterStage="unassigned";
const $phase59CounterRows=new Map([["unassigned",$phase59CounterRow]]);
export function phase59CounterReset(){for(const r of $phase59CounterRows.values())r.fill(0);$phase59CounterStage="whole-request";if(!$phase59CounterRows.has($phase59CounterStage))$phase59CounterRows.set($phase59CounterStage,new Float64Array(${metrics.length}));$phase59CounterRow=$phase59CounterRows.get($phase59CounterStage);$phase59CounterActive=true;}
export function phase59CounterStage(label){if(typeof label!=="string"||label.length>80||!label.length)throw Error("bad counter stage");if(!$phase59CounterRows.has(label)){if($phase59CounterRows.size>=64)throw Error("counter stage budget");$phase59CounterRows.set(label,new Float64Array(${metrics.length}));}$phase59CounterStage=label;$phase59CounterRow=$phase59CounterRows.get(label);}
export function phase59CounterSnapshot(){const stages={};for(const [name,row]of $phase59CounterRows){const values={};for(let i=0;i<row.length;i++){if(!Number.isSafeInteger(row[i])||row[i]<0)throw Error("counter overflow");values[$phase59CounterNames[i]]=row[i];}stages[name]=values;}return {kind:"phase59-source-work-counters",diagnosticOnly:true,physicalAllocationCounts:false,active:$phase59CounterActive,currentStage:$phase59CounterStage,tableSyntaxPerCall:${JSON.stringify(tableTags)},stages};}
export function phase59CounterStop(){$phase59CounterActive=false;return phase59CounterSnapshot();}
`;
const ordered=[...edits].sort((a,b)=>a[0]-b[0]);let text=source;
for(const [at,add]of [...ordered].reverse())text=text.slice(0,at)+add+text.slice(at);
text+=suffix;const next=parse(text);
// Remove only the recorded insertions; every preexisting byte must be retained.
let inverse=text.slice(0,-suffix.length),shift=ordered.reduce((n,e)=>n+e[1].length,0);
for(const [at,add]of [...ordered].reverse()){shift-=add.length;assert.equal(inverse.slice(at+shift,at+shift+add.length),add);inverse=inverse.slice(0,at+shift)+inverse.slice(at+shift+add.length);}
assert.equal(inverse,source);assert(text.startsWith(prefix));
const nextFunctions=new Map(next.body.filter(n=>n.type==='FunctionDeclaration').map(n=>[n.id.name,n]));
const bodies=[...modified].map(n=>{const a=functions.get(n),b=nextFunctions.get(n);assert.deepEqual(params(a),params(b));return {name:n,parameters:params(a),beforeBodySha256:digest(source.slice(a.body.start,a.body.end)),afterBodySha256:digest(text.slice(b.body.start,b.body.end))};});
for(const i of inputs)assert.deepEqual(identity(i.file),i);
fs.mkdirSync(out,{recursive:true});const target=path.join(out,'api-counters.mjs');fs.writeFileSync(target,text,{flag:'wx'});
const report={kind:'phase59-b2-counter-derivation',complete:true,pass:true,diagnosticOnly:true,checkedDerivative:false,targetExecuted:false,parent,runtime,publication,producer,inputs,output:identity(target),node:identity(process.execPath),parser:{version:M.exports.version,sha256:digest(parserSource)},exactInverse:true,runtimePrefixUnchanged:true,metrics,tableSyntaxPerCall:tableTags,sites,bodies,edits:ordered.map(([at,text])=>({at,text})),suffixSha256:digest(suffix),scope:'Insertion-only semantic entry/branch counters on a private exact B2 copy. SCC case entries and self-loop entries include internal transfers. O(1) per visit, no compiler query, recursive census, result wrapping, stack capture or per-node logging. Private compiler-owned ordinary inputs only; diagnostic timings and allocation are not clean measurements. String lengths are UTF-16 units; loop visits are not exact bytes or physical allocations.'};
for(const i of inputs)assert.deepEqual(identity(i.file),i);
fs.writeFileSync(path.join(out,'derivation.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
process.stdout.write(JSON.stringify({output:report.output,receipt:identity(path.join(out,'derivation.json')),metrics:metrics.length,sites:sites.length})+'\n');
