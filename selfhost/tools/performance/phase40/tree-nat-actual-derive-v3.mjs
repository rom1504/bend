// Actual checked source output: diagnostic counters/adapters only, no optimizer rewrite.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {verifyAttempt} from '../../development/workflow.mjs';
const [baselineArg,candidateArg,typescriptArg,attemptArg,outArg]=process.argv.slice(2);
assert(baselineArg&&candidateArg&&typescriptArg&&attemptArg&&outArg,'usage: tree-nat-actual-derive-v3.mjs BASELINE CANDIDATE TYPESCRIPT ATTEMPT NEW_OUT');
const out=path.resolve(outArg);assert(!fs.existsSync(out));
const identity=file=>({path:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex'),bytes:fs.statSync(file).size});
const inputs=new Map();function track(file,expected){const actual=identity(file);if(expected){assert.equal(actual.sha256,expected.sha256);if('bytes'in expected)assert.equal(actual.bytes,expected.bytes);}
 if(inputs.has(actual.path))assert.deepEqual(actual,inputs.get(actual.path));else inputs.set(actual.path,actual);return actual;}
const pointer=row=>track(row.canonicalPath??row.file??row.path,row);
const source=track(path.join(import.meta.dirname,'../phase40/tree-nat-fixture-v3.bend'));
const attemptFile=track(path.join(attemptArg,'attempt.json')),attempt=await verifyAttempt(path.dirname(attemptFile.path));
assert.equal(attempt.checked,true);for(const key of ['api','runtime','base'])pointer(attempt[key]);for(const item of attempt.snapshot.sources)pointer(item.frozen);
const bootstrapFile=pointer(attempt.bootstrapReport),bootstrap=JSON.parse(fs.readFileSync(bootstrapFile.path));
assert.equal(bootstrap.revision,'018751270e800bc222a93dad7f257083ee53a5f7');
const frozenDriver=attempt.snapshot.sources.find(item=>path.relative(attempt.snapshot.root,item.frozen.file)==='tools/typed-driver.mjs');
assert(frozenDriver,'selected attempt has no frozen driver');const driver=pointer(frozenDriver.frozen);

const parserText=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};
new Function('module','exports',parserText)(parser,parser.exports);assert.equal(parser.exports.version,'8.16.0');
const parse=text=>parser.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});
function visit(node,fn){if(!node||typeof node!=='object')return;fn(node);for(const value of Object.values(node)){
 if(Array.isArray(value))for(const child of value)visit(child,fn);else if(value&&typeof value.type==='string')visit(value,fn);}}
function helperClosure(ast){const declarations=new Map(),calls=[];visit(ast,node=>{
 if(node.type==='FunctionDeclaration'&&node.id?.name?.endsWith('$tree'))declarations.set(node.id.name,(declarations.get(node.id.name)||0)+1);
 if(node.type==='CallExpression'&&node.callee.type==='Identifier'&&node.callee.name.endsWith('$tree'))calls.push(node.callee.name);
 });for(const [name,count]of declarations)assert.equal(count,1,'duplicate component helper '+name);
 for(const name of calls)assert.equal(declarations.get(name),1,'undefined component helper '+name);
 return{declarations:[...declarations.keys()],callTargets:[...new Set(calls)],calls:calls.length};}

function read(file,role){const module=track(file),receipt=track(file+'.json'),e=JSON.parse(fs.readFileSync(receipt.path));
 assert.equal(e.kind,'bend-program-checked-emission');assert.equal(e.complete,true);assert.equal(e.observation.checked,true);assert.equal(e.observation.status,'ok');
 assert.equal(e.input.sha256,source.sha256);pointer(e.input);assert.equal(pointer(e.output).sha256,module.sha256);pointer(e.producer);pointer(e.catalog);e.verifiers.forEach(pointer);
 assert.equal(e.compiler.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
 if(role==='typescript'){assert.equal(e.compiler.kind,'checked-pinned-typescript');e.compiler.sources.forEach(pointer);}
 else{assert.equal(e.compiler.kind,'checked-development-attempt');assert.equal(e.observation.typeAccepted,true);pointer(e.attempt);for(const key of ['api','runtime','base','driver'])pointer(e.compiler[key]);
  if(role==='original')assert.equal(e.compiler.api.sha256,'04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f');
  else{assert.equal(e.attempt.sha256,attemptFile.sha256);for(const key of ['api','runtime','base']){assert.equal(e.compiler[key].sha256,attempt[key].sha256);assert.equal(pointer(e.compiler[key]).path,pointer(attempt[key]).path);}
   assert.equal(e.compiler.sourceSha256,bootstrap.sourceSha256);assert.equal(pointer(e.compiler.driver).path,driver.path);assert.equal(e.compiler.driver.sha256,driver.sha256);}}
 return{module,receipt,compiler:e.compiler,text:fs.readFileSync(module.path,'utf8')};}
const baseline=read(baselineArg,'original'),candidate=read(candidateArg,'direct'),typescript=read(typescriptArg,'typescript');
const encoded=name=>'$R'+Array.from(name,c=>'_'+c.codePointAt(0)).join('')+'$tree';
const names=['bench','natflow.flow','natflow.turn','natflow.join','natflow.make','natflow.score','natflow.computed','computed_check','natflow.parent','parent_check','natflow.dependent','dependent_check','natflow.back','natflow.redirect','back_check'];
fs.mkdirSync(out);track(import.meta.filename);
const report={kind:'phase40-actual-nat-component',complete:false,checked:true,certified:false,producer:identity(import.meta.filename),attempt:attemptFile,compiler:candidate.compiler,
 source,typescript:typescript.module,dependencies:names,modules:[],inputs:[],scope:'Actual compiler output; clean copies unchanged. Counters count real emitted worker entries; owned-input adapters open only diagnostic proofs and still invoke the generic public function, whose actual compiled call sites choose workers.'};
for(const [variant,parent]of[['original',baseline],['direct',candidate]]){
 const ast=parse(parent.text),closure=helperClosure(ast),workers=ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id?.name?.endsWith('$tree'));
 const found=workers.filter(n=>n.id.name===encoded('natflow.flow'));
 assert.equal(found.length,variant==='direct'?1:0,'actual worker presence');
 for(const name of ['natflow.computed','natflow.parent','natflow.dependent','natflow.back'])assert(!workers.some(n=>n.id.name===encoded(name)),'refused shape became worker: '+name);
 let text=parent.text;
 if(found.length){const at=found[0].body.start+1;text=text.slice(0,at)+'++$p39Counts.component;'+text.slice(at);}
 const rootSites=text.split('/* private finite root */').length-1;
 assert(rootSites>=1,'actual source must contain finite scalar roots');
 text=text.replaceAll('/* private finite root */','/* private finite root */++$p39Counts.root;');
 text+=`
const $p39Counts={component:0,root:0};
const $p39OwnedNames=['natflow.flow','natflow.turn','natflow.join'];
function $p39Input(depth,seed,sharing){let value=Object.freeze({$:'NEnd',a:Object.freeze([(seed+depth)>>>0])});
 for(let i=depth-1;i>=0;i--){const s=(seed+i)>>>0,leaf=Object.freeze({$:'NEnd',a:Object.freeze([(s^91)>>>0])});
  value=Object.freeze({$:'NFork',a:Object.freeze([value,sharing?value:leaf])});}return value;}
export function privateComponentPoint(n,d,seed,flag,sharing=0){
 if(!Number.isInteger(n)||n<0||n>30000||!Number.isInteger(d)||d<0||d>30000||!Number.isInteger(seed)||seed<0||seed>4294967295||typeof flag!=='boolean'||![0,1].includes(sharing)||(sharing&&d>7))throw Error('diagnostic owned-input domain');
 const tree=$p39Input(d,seed,sharing);
 if(regionProof===null&&regionHostGuard()&&localGuard($p39OwnedNames)){const previous=regionProofOpen($p39OwnedNames);try{return call(get(G,'natflow.flow'),[BigInt(n),flag,tree]);}finally{regionProofClose(previous);}}
 return call(get(G,'natflow.flow'),[BigInt(n),flag,tree]);}
export function privateZeroAliases(){const a={$:'NEnd',a:[7]},b={$:'NEnd',a:[11]},tree={$:'NFork',a:[a,b]};
 if(regionProof!==null||!regionHostGuard()||!localGuard($p39OwnedNames))throw Error('diagnostic guard');const prev=regionProofOpen($p39OwnedNames);
 try{const result=call(get(G,'natflow.flow'),[0n,false,tree]);return [result!==tree,result.a[0]===a,result.a[1]===b];}finally{regionProofClose(prev);}}
export function privateComponentCounts(){return {...$p39Counts};}
export function privateProofActive(){return regionProof!==null;}
`;
 parse(text);
 for(const counters of[false,true]){const file=path.join(out,variant+(counters?'.mjs':'.clean.mjs'));fs.writeFileSync(file,counters?text:parent.text,{flag:'wx'});
  if(!counters)assert.equal(identity(file).sha256,parent.module.sha256);
  report.modules.push({variant,counters,parent:parent.module,emission:parent.receipt,workers:workers.map(n=>n.id.name),closure,rootSites,...identity(file)});}
}
for(const row of inputs.values())assert.deepEqual(identity(row.path),row);report.inputs=[...inputs.values()];report.complete=true;
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-derive.mjs'));fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,checked:true,api:report.compiler.api.sha256,modules:report.modules.length}));
