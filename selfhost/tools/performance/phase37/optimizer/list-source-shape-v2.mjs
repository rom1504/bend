// Read-only AST analysis: generated modules are read as bytes, never imported.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [baselineArg,candidateArg,outArg]=process.argv.slice(2);
assert(baselineArg&&candidateArg&&outArg,'Usage: list-source-shape-v2.mjs BASELINE CANDIDATE NEW_REPORT');
assert(!fs.existsSync(outArg));
const digest=x=>createHash('sha256').update(x).digest('hex');
const identity=file=>({path:fs.realpathSync(file),sha256:digest(fs.readFileSync(file)),bytes:fs.statSync(file).size});
const parser={exports:{}};
new Function('module','exports',process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'])(parser,parser.exports);
assert.equal(parser.exports.version,'8.16.0');
function walk(node,f){if(!node||typeof node!=='object')return;f(node);for(const [key,value]of Object.entries(node)){
 if(['start','end','loc'].includes(key))continue;if(Array.isArray(value))for(const child of value)walk(child,f);else if(value&&typeof value==='object')walk(value,f);}}
function normalized(node){return JSON.stringify(node,(key,value)=>['start','end','loc','raw'].includes(key)?undefined:typeof value==='bigint'?{bigint:String(value)}:value);}
const watched=['callOwned','call','jump','build','ctor','matcher','matcher1','fn','exactCode','scalarCapture','regionHostGuard','regionProofOpen','regionProofCovers','regionF32ToU32'];
function metrics(node){const calls=Object.fromEntries(watched.map(x=>[x,0])),dependencies=new Set(),selectors=[];let nodes=0,dynamicGlobals=0;
 walk(node,n=>{if(typeof n.type==='string')nodes++;
  if(n.type==='CallExpression'&&n.callee.type==='Identifier'){
   if(n.callee.name in calls)calls[n.callee.name]++;
   if(n.callee.name==='get'&&n.arguments[0]?.type==='Identifier'&&n.arguments[0].name==='G'){
    if(typeof n.arguments[1]?.value==='string')dependencies.add(n.arguments[1].value);else dynamicGlobals++;}
   if(n.callee.name==='regionProofCovers')selectors.push(n.arguments[0]?.elements?.map(x=>x.value)??null);
  }});return{nodes,calls,dependencies:[...dependencies].sort(),dynamicGlobals,selectors};}
function analyze(file){const module=identity(file),receipt=identity(file+'.json'),emission=JSON.parse(fs.readFileSync(receipt.path));
 assert(emission.complete&&emission.observation.checked);assert.equal(emission.output.sha256,module.sha256);
 const text=fs.readFileSync(file,'utf8'),tree=parser.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'}),globals={},runtime={};
 for(const statement of tree.body){
  const e=statement.type==='ExpressionStatement'?statement.expression:null;
  if(e?.type==='AssignmentExpression'&&e.left.type==='MemberExpression'&&e.left.object.name==='G'&&typeof e.left.property.value==='string'){
   globals[e.left.property.value]={...metrics(e.right),astSha256:digest(normalized(e.right)),sourceSha256:digest(text.slice(e.right.start,e.right.end))};}
  if(statement.type==='FunctionDeclaration'&&['regionHostGuard','force','apply','invokeExact','scalarGuard','localGuard','ctor','get'].includes(statement.id.name))
   runtime[statement.id.name]={...metrics(statement),astSha256:digest(normalized(statement)),sourceSha256:digest(text.slice(statement.start,statement.end))};
 }
 const reachable=new Set(),missing=new Set(),visit=name=>{if(reachable.has(name))return;if(!globals[name]){missing.add(name);return;}
  reachable.add(name);for(const next of globals[name].dependencies)visit(next);};visit('bench');
 return{module,receipt,source:emission.input,compiler:emission.compiler,moduleMetrics:metrics(tree),globals,runtime,
  reachableGlobals:[...reachable].sort(),unresolvedNamedDependencies:[...missing].sort(),
  finiteSites:Object.entries(globals).filter(([,row])=>row.selectors.length).map(([name,row])=>({name,selectors:row.selectors,reachable:reachable.has(name)}))};}
const baseline=analyze(path.resolve(baselineArg)),candidate=analyze(path.resolve(candidateArg));
assert.equal(baseline.source.sha256,candidate.source.sha256);
const comparison={reachableSetsEqual:JSON.stringify(baseline.reachableGlobals)===JSON.stringify(candidate.reachableGlobals),
 globals:candidate.reachableGlobals.map(name=>({name,sourceEqual:baseline.globals[name]?.sourceSha256===candidate.globals[name].sourceSha256,
 astEqual:baseline.globals[name]?.astSha256===candidate.globals[name].astSha256,baseline:baseline.globals[name],candidate:candidate.globals[name]})),
 runtime:Object.keys(candidate.runtime).map(name=>({name,sourceEqual:baseline.runtime[name]?.sourceSha256===candidate.runtime[name].sourceSha256,
 astEqual:baseline.runtime[name]?.astSha256===candidate.runtime[name].astSha256}))};
for(const item of[baseline,candidate])for(const row of[item.module,item.receipt])assert.deepEqual(identity(row.path),row);
const report={kind:'phase37-list-source-static-ast',complete:true,producer:identity(import.meta.filename),node:process.version,parser:parser.exports.version,
 scope:'Static syntax and literal-G dependency reachability only. No target module import, execution, allocation or profiler sample; this does not establish runtime frequency or causation.',baseline,candidate,comparison};
fs.writeFileSync(outArg,JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,reachable:candidate.reachableGlobals,allReachableSourceEqual:comparison.globals.every(x=>x.sourceEqual),
 finiteSites:candidate.finiteSites,runtime:comparison.runtime}));
