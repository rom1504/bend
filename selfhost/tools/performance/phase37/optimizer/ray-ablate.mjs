// Saved checked-output ablation only; root owns derivation, controls and timing.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [candidateArg,baselineArg,tsArg,outArg]=process.argv.slice(2);
assert(candidateArg&&baselineArg&&tsArg&&outArg,'usage: ray-ablate.mjs CANDIDATE.mjs BASELINE.mjs TYPESCRIPT.mjs NEW_OUT');
const [candidate,baseline,typescript]=[candidateArg,baselineArg,tsArg].map(p=>fs.realpathSync(p)),out=path.resolve(outArg);
assert(!fs.existsSync(out));const hash=x=>createHash('sha256').update(x).digest('hex');
const identity=file=>({path:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const source=fs.readFileSync(candidate,'utf8');
assert.equal(hash(source),'46a60f5fb0094dfeea09a222d803ce7a6ffb091f50b59c2fbf28e809154c24bd','checked02 actual active ray module');
const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};
new Function('module','exports',parserSource)(parserModule,parserModule.exports);assert.equal(parserModule.exports.version,'8.16.0');
const parse=s=>parserModule.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
function visit(n,f){if(!n||typeof n!=='object')return;f(n);for(const [k,v]of Object.entries(n)){if(k==='start'||k==='end')continue;if(Array.isArray(v))for(const x of v)visit(x,f);else if(v&&typeof v.type==='string')visit(v,f);}}
function parts(text){const tree=parse(text),assignments=tree.body.filter(s=>s.type==='ExpressionStatement'&&s.expression.type==='AssignmentExpression'&&s.expression.left.object?.name==='G'),roots=[],calls=[];let host;
 visit(tree,n=>{
  if(n.type==='FunctionDeclaration'&&n.id.name==='regionHostGuard')host=n;
  if(n.type==='IfStatement'&&text.slice(n.test.start,n.test.end).includes('regionProof===null')&&text.slice(n.consequent.start,n.consequent.end).startsWith('{/* private finite root */')){
   const owner=assignments.find(s=>s.start<n.start&&s.end>n.end);assert(owner);roots.push({name:owner.expression.left.property.value,test:n.test,body:n.consequent});}
  if(n.type==='ConditionalExpression'&&n.test.type==='LogicalExpression'&&n.test.right.type==='CallExpression'&&n.test.right.callee.name==='regionProofCovers'&&n.consequent.type==='CallExpression'&&n.consequent.callee.type==='ArrowFunctionExpression'){
   const body=n.consequent.callee.body;if(text.slice(body.start,body.end).startsWith('{/* private finite selector */'))calls.push({name:n.test.right.arguments[0].elements[0].value,test:n.test,body});}
 });return {roots,calls,host};}
function edit(text,edits){for(const e of edits.sort((a,b)=>b.start-a.start))text=text.slice(0,e.start)+e.text+text.slice(e.end);return text;}
const original=parts(source);assert.equal(original.roots.length,8);assert.equal(original.calls.length,8);assert(original.roots.some(x=>x.name==='bench'));
const variants=['candidate','no-finite-roots','no-helper-roots','no-finite-calls','no-finite-both','no-dataview-guard','no-finite-both-no-dataview'];
const dataViewLines=[
 "for(const key of regionDataViewKeys)regionNumericHooks.push([regionDataViewPrototype,key,regionDataViewPrototype[key]]);\n",
 "regionNumericHooks.push([globalThis,'DataView',regionDataViewCtor],[regionDataViewCtor,'prototype',regionDataViewPrototype]);\n",
 "  if(regionGetPrototype(floatView)!==regionDataViewPrototype||regionGetPrototype(regionDataViewPrototype)!==regionDataViewParent)return false;\n",
 "  for(let i=0;i<regionDataViewKeys.length;i++)if(regionGetDescriptor(floatView,regionDataViewKeys[i]))return false;\n"];
for(const line of dataViewLines)assert.equal(source.split(line).length,2,'exact DataView guard extension line');
fs.mkdirSync(out,{recursive:false});fs.copyFileSync(import.meta.filename,path.join(out,'consumed-ablate.mjs'));
const report={kind:'phase37-ray-regression-ablation',complete:false,certified:false,node:process.version,
 inputs:[import.meta.filename,candidate,baseline,typescript].map(identity),parserSha256:hash(parserSource),modules:[],
 sourceRoots:original.roots.map(x=>x.name),sourceCalls:original.calls.map(x=>x.name),
 scope:'No new direct computation. Disable only selected finite conditions or four DataView guard-extension lines. DataView-removal variants are deliberately unsafe negative controls and cannot be promoted. Diagnostic counters are never timed.'};
for(const variant of variants){const edits=[];
 const noRoots=variant==='no-finite-roots'||variant.startsWith('no-finite-both'),noCalls=variant==='no-finite-calls'||variant.startsWith('no-finite-both');
 for(const root of original.roots)if(noRoots||(variant==='no-helper-roots'&&root.name!=='bench'))edits.push({start:root.test.start,end:root.test.end,text:'false&&('+source.slice(root.test.start,root.test.end)+')'});
 for(const call of original.calls)if(noCalls)edits.push({start:call.test.start,end:call.test.end,text:'false&&('+source.slice(call.test.start,call.test.end)+')'});
 let clean=edit(source,edits);if(variant.includes('no-dataview'))for(const line of dataViewLines)clean=clean.replace(line,'');parse(clean);
 const cleanFile=path.join(out,variant+'.clean.mjs');fs.writeFileSync(cleanFile,clean,{flag:'wx'});
 report.modules.push({variant,counters:false,unsafe:variant.includes('no-dataview'),...identity(cleanFile),bytes:Buffer.byteLength(clean)});
 // Reparse because disabling conditions changes offsets. Scalar-root markers
 // remain available even when false guards disable them. Disabled finite calls
 // are counted as zero, and do not need their own re-discovery.
 const p=parts(clean),counterEdits=[];
 for(const root of p.roots){counterEdits.push({start:root.test.start,end:root.test.end,text:'($p37Ray.attempts['+JSON.stringify(root.name)+']=($p37Ray.attempts['+JSON.stringify(root.name)+']||0)+1,('+clean.slice(root.test.start,root.test.end)+'))'});
  counterEdits.push({start:root.body.start+1,end:root.body.start+1,text:'$p37Ray.entries['+JSON.stringify(root.name)+']=($p37Ray.entries['+JSON.stringify(root.name)+']||0)+1;'});}
 for(const call of p.calls)counterEdits.push({start:call.body.start+1,end:call.body.start+1,text:'$p37Ray.calls['+JSON.stringify(call.name)+']=($p37Ray.calls['+JSON.stringify(call.name)+']||0)+1;'});
 counterEdits.push({start:p.host.body.start+1,end:p.host.body.start+1,text:'++$p37Ray.hostCalls;if(regionProof===null)++$p37Ray.fullHostCalls;'});
 let diagnostic=edit(clean,counterEdits)+'\nconst $p37Ray={attempts:Object.create(null),entries:Object.create(null),calls:Object.create(null),hostCalls:0,fullHostCalls:0};\nexport function rayStats(){return JSON.parse(JSON.stringify($p37Ray));}\n';
 parse(diagnostic);const diagFile=path.join(out,variant+'.diagnostic.mjs');fs.writeFileSync(diagFile,diagnostic,{flag:'wx'});
 report.modules.push({variant,counters:true,unsafe:variant.includes('no-dataview'),...identity(diagFile),bytes:Buffer.byteLength(diagnostic)});
}
report.complete=true;fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
const point={exportName:'coverage.active',args:[256,2240],expected:2166930202};
const config={inputs:[path.join(out,'derive.json'),candidate,baseline,typescript],cases:[{id:'variation-ray-active-256-2240',point,
 modules:Object.fromEntries([['baseline',baseline],...variants.map(v=>[v,path.join(out,v+'.clean.mjs')]),['typescript',typescript]])}]};
fs.writeFileSync(path.join(out,'compare.json'),JSON.stringify(config,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,certified:false,out,modules:report.modules.length}));
