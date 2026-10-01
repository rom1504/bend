// Bind instrumentation to actual checked output; no target execution.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import{createHash}from'node:crypto';
import{verifyAttempt}from'../../development/workflow.mjs';
const[attemptArg,moduleArg,baselineArg,outArg]=process.argv.slice(2);
assert(attemptArg&&moduleArg&&baselineArg&&outArg,'guard-checked-derive.mjs ATTEMPT CANDIDATE_RAY BASELINE_RAY NEW_OUT');
const out=path.resolve(outArg);assert(!fs.existsSync(out));
const hash=x=>createHash('sha256').update(x).digest('hex');
const identity=p=>({path:fs.realpathSync(p),sha256:hash(fs.readFileSync(p))});
const inputs=new Map();
function verify(file,row){const actual=identity(file);if(row){assert.equal(actual.sha256,row.sha256);if(row.canonicalPath)assert.equal(actual.path,row.canonicalPath);}if(inputs.has(actual.path))assert.deepEqual(actual,inputs.get(actual.path));inputs.set(actual.path,actual);return actual;}
const attemptFile=path.join(fs.realpathSync(attemptArg),'attempt.json'),attempt=await verifyAttempt(path.dirname(attemptFile));
verify(import.meta.filename);verify(attemptFile);
const candidate=fs.realpathSync(moduleArg),baseline=fs.realpathSync(baselineArg),receiptFile=candidate+'.json';
verify(receiptFile);const receipt=JSON.parse(fs.readFileSync(receiptFile));
assert.equal(receipt.kind,'bend-program-checked-emission');assert.equal(receipt.complete,true);
assert.equal(receipt.observation.checked,true);assert.equal(receipt.observation.status,'ok');assert.equal(receipt.observation.phase,'compile');assert.equal(receipt.observation.exitCode,0);
assert.equal(receipt.compiler.kind,'checked-development-attempt');assert.equal(receipt.compiler.artifact,attempt.artifactKind);
assert.equal(receipt.compiler.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
assert.equal(verify(attemptFile,receipt.attempt).path,receipt.attempt.canonicalPath);
for(const key of ['api','runtime','base']){assert.equal(receipt.compiler[key].sha256,attempt[key].sha256);assert.equal(verify(receipt.compiler[key].file,receipt.compiler[key]).path,verify(attempt[key].file,attempt[key]).path);}
const bootstrap=JSON.parse(fs.readFileSync(attempt.bootstrapReport.file));verify(attempt.bootstrapReport.file,attempt.bootstrapReport);
assert.equal(receipt.compiler.sourceSha256,bootstrap.sourceSha256);
assert.equal(verify(receipt.compiler.driver.file,receipt.compiler.driver).path,fs.realpathSync(path.join(attempt.snapshot.root,'tools/typed-driver.mjs')));
verify(receipt.input.file,receipt.input);assert.equal(receipt.input.sha256,'5ba03ffff01fc0825ecf7ec0d9fb5f5030fcc07c3d83582ad790394cbcf55955');
verify(receipt.producer.file,receipt.producer);for(const row of receipt.verifiers)verify(row.file,row);verify(receipt.catalog.file,receipt.catalog);
assert.equal(verify(candidate,receipt.output).path,receipt.output.canonicalPath);
assert.equal(verify(baseline).sha256,'a4bb4434cc19e9adfbe283a2679a032ca59577c531de9d407ea627080324bfaa');
const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};
new Function('module','exports',parserSource)(parserModule,parserModule.exports);assert.equal(parserModule.exports.version,'8.16.0');
const parse=s=>parserModule.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
function walk(n,f){if(!n||typeof n!=='object')return;f(n);for(const[k,v]of Object.entries(n)){if(k==='start'||k==='end')continue;if(Array.isArray(v))for(const x of v)walk(x,f);else if(v?.type)walk(v,f);}}
function parts(text){const ast=parse(text),owner=ast.body.find(n=>n.type==='ExpressionStatement'&&n.expression.type==='AssignmentExpression'&&n.expression.left.object?.name==='G'&&n.expression.left.property.value==='coverage.active');assert(owner);
 const roots=[],finite=[],functions={},guards=[],scopes=[];
 walk(owner,n=>{if(n.type==='IfStatement'&&text.slice(n.test.start,n.test.end).includes('$entered&&regionHostGuard()')&&text.slice(n.test.start,n.test.end).includes('localGuard($guards)'))roots.push(n);
  if(n.type==='VariableDeclarator'&&n.id.name==='$guards')guards.push(n.init.elements.map(x=>x.value));
  if(n.type==='TryStatement'&&text.slice(n.finalizer?.start,n.finalizer?.end).includes('regionProofClose($previousProof)'))scopes.push(n);});
 assert.equal(roots.length,1);assert.equal(guards.length,1);
 walk(ast,n=>{if(n.type==='FunctionDeclaration')functions[n.id.name]=n;
  if(n.type==='ConditionalExpression'&&n.consequent.type==='CallExpression'&&n.consequent.callee.type==='ArrowFunctionExpression'&&text.slice(n.consequent.callee.body.start,n.consequent.callee.body.end).startsWith('{/* private finite selector */'))finite.push(n);});
 return{root:roots[0],guards:guards[0],scopes,finite,functions};}
function edit(text,edits){for(const e of edits.sort((a,b)=>b.start-a.start))text=text.slice(0,e.start)+e.text+text.slice(e.end);return text;}
const original=fs.readFileSync(baseline,'utf8'),selected=fs.readFileSync(candidate,'utf8'),b=parts(original),c=parts(selected);
assert.equal(b.scopes.length,0);assert.equal(c.scopes.length,1,'actual compiler must emit the scope');
assert.deepEqual(c.guards,b.guards,'complete unchanged dependency closure');
assert.equal(selected.slice(c.root.test.start,c.root.test.end),original.slice(b.root.test.start,b.root.test.end),'entry guard is unchanged');
assert(c.scopes[0].start>c.root.consequent.start&&c.scopes[0].end<c.root.consequent.end);
fs.mkdirSync(out,{recursive:false});fs.copyFileSync(import.meta.filename,path.join(out,'consumed-derive.mjs'));
const report={kind:'phase39-checked-scalar-root-scope',complete:false,certified:false,node:process.version,attempt:verify(attemptFile),api:verify(attempt.api.file),receipt:verify(receiptFile),parserSha256:hash(parserSource),
 scope:'Clean candidate is actual checked compiler output. Only separate diagnostic copies add counters; no scope is injected or selector disabled. Source proof independently uses existing j_tree_scope.',guardNames:c.guards,modules:[]};
for(const[variant,text]of[['baseline',original],['scope',selected]]){
 const clean=path.join(out,variant+'.clean.mjs');fs.writeFileSync(clean,text,{flag:'wx'});report.modules.push({variant,counters:false,...verify(clean)});
 const p=parts(text),edits=[];
 const count=(name,code)=>{const n=p.functions[name];assert(n);edits.push({start:n.body.start+1,end:n.body.start+1,text:code});};
 count('regionHostGuard','++$p39Guard.host;if(regionProof===null)++$p39Guard.fullHost;');
 count('scalarGuard','++$p39Guard.scalar;if(!regionProofCovers(names))++$p39Guard.fullScalar;');
 count('regionProofOpen','++$p39Guard.opens;');count('regionProofClose','++$p39Guard.closes;');
 edits.push({start:p.root.consequent.start+1,end:p.root.consequent.start+1,text:'++$p39Guard.rootEntries;'});
 for(const n of p.finite)edits.push({start:n.consequent.callee.body.start+1,end:n.consequent.callee.body.start+1,text:'++$p39Guard.finite;'});
 const diagnostic=edit(text,edits)+'\nconst $p39Guard={host:0,fullHost:0,scalar:0,fullScalar:0,opens:0,closes:0,rootEntries:0,finite:0};\nexport function guardStats(){return {...$p39Guard,active:regionProof!==null};}\nexport function guardReset(){for(const k of Object.keys($p39Guard))$p39Guard[k]=0;}\n';
 parse(diagnostic);const diag=path.join(out,variant+'.diagnostic.mjs');fs.writeFileSync(diag,diagnostic,{flag:'wx'});report.modules.push({variant,counters:true,...verify(diag)});
}
for(const row of inputs.values())assert.deepEqual(identity(row.path),row);report.inputs=[...inputs.values()];report.complete=true;
fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,out,guardNames:report.guardNames.length,api:report.api.sha256}));
