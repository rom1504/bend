// One saved-output scope ablation. Does not execute generated programs.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [moduleArg,tsArg,catalogArg,outArg]=process.argv.slice(2);
assert(moduleArg&&tsArg&&catalogArg&&outArg,'guard-derive.mjs PHASE37_RAY TS_RAY CATALOG NEW_OUT');
const input=fs.realpathSync(moduleArg),typescript=fs.realpathSync(tsArg),catalogFile=fs.realpathSync(catalogArg),out=path.resolve(outArg);
assert(!fs.existsSync(out));
const hash=x=>createHash('sha256').update(x).digest('hex');
const identity=p=>({path:fs.realpathSync(p),sha256:hash(fs.readFileSync(p))});
const source=fs.readFileSync(input,'utf8');
assert.equal(hash(source),'a4bb4434cc19e9adfbe283a2679a032ca59577c531de9d407ea627080324bfaa','final Phase37 active-ray module');
const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};
new Function('module','exports',parserSource)(parserModule,parserModule.exports);
assert.equal(parserModule.exports.version,'8.16.0');
const parse=s=>parserModule.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
function walk(n,fn){if(!n||typeof n!=='object')return;fn(n);for(const [k,v]of Object.entries(n)){if(k==='start'||k==='end')continue;if(Array.isArray(v))for(const x of v)walk(x,fn);else if(v?.type)walk(v,fn);}}
function parts(text){const ast=parse(text),all=ast.body.filter(n=>n.type==='ExpressionStatement'&&n.expression.type==='AssignmentExpression'&&n.expression.left.object?.name==='G');
 const owner=all.find(n=>n.expression.left.property.value==='coverage.active');assert(owner);
 const roots=[],finite=[],functions={};
 walk(owner,n=>{if(n.type==='IfStatement'&&text.slice(n.test.start,n.test.end).includes('$entered&&regionHostGuard()')&&text.slice(n.test.start,n.test.end).includes('localGuard($guards)'))roots.push(n);});
 assert.equal(roots.length,1,'one actual scalar root admission');
 walk(ast,n=>{if(n.type==='FunctionDeclaration')functions[n.id.name]=n;
  if(n.type==='ConditionalExpression'&&n.consequent.type==='CallExpression'&&n.consequent.callee.type==='ArrowFunctionExpression'&&text.slice(n.consequent.callee.body.start,n.consequent.callee.body.end).startsWith('{/* private finite selector */'))finite.push(n);
 });
 assert(finite.length>0);return{owner,root:roots[0],finite,functions};}
function edit(text,edits){for(const e of edits.sort((a,b)=>b.start-a.start))text=text.slice(0,e.start)+e.text+text.slice(e.end);return text;}
const original=parts(source),rootBody=original.root.consequent;
assert(!source.slice(rootBody.start,rootBody.end).includes('regionProofOpen'));
const catalog=JSON.parse(fs.readFileSync(catalogFile));
const cases=catalog.cases.filter(c=>['variation-ray-active-64-2440','variation-ray-active-256-2240'].includes(c.id));
assert.equal(cases.length,2);
fs.mkdirSync(out,{recursive:false});fs.copyFileSync(import.meta.filename,path.join(out,'consumed-derive.mjs'));
const report={kind:'phase39-scalar-root-scope-prototype',complete:false,certified:false,node:process.version,
 inputs:[import.meta.filename,input,typescript,catalogFile].map(identity),parserSha256:hash(parserSource),modules:[],
 scope:'Only existing coverage.active admission body receives existing proof open/try/finally. Full entry guard and generic fallback retained. The no-finite role disables existing selectors to separate their activation. Saved output is not a checked compiler change.'};
for(const variant of ['baseline','scope','scope-no-finite']){
 const edits=[];
 if(variant!=='baseline')edits.push({start:rootBody.start+1,end:rootBody.start+1,text:'const $previousProof=regionProofOpen($guards);try{'},{start:rootBody.end-1,end:rootBody.end-1,text:'}finally{regionProofClose($previousProof);}'});
 if(variant==='scope-no-finite')for(const n of original.finite)edits.push({start:n.test.start,end:n.test.end,text:'false&&('+source.slice(n.test.start,n.test.end)+')'});
 const clean=edit(source,edits);parse(clean);
 const file=path.join(out,variant+'.clean.mjs');fs.writeFileSync(file,clean,{flag:'wx'});report.modules.push({variant,counters:false,...identity(file)});
 const p=parts(clean),instrument=[];
 const count=(name,code)=>{const n=p.functions[name];assert(n,name);instrument.push({start:n.body.start+1,end:n.body.start+1,text:code});};
 count('regionHostGuard','++$p39Guard.host;if(regionProof===null)++$p39Guard.fullHost;');
 count('scalarGuard','++$p39Guard.scalar;if(!regionProofCovers(names))++$p39Guard.fullScalar;');
 count('regionProofOpen','++$p39Guard.opens;');count('regionProofClose','++$p39Guard.closes;');
 instrument.push({start:p.root.consequent.start+1,end:p.root.consequent.start+1,text:'++$p39Guard.rootEntries;'});
 for(const n of p.finite)instrument.push({start:n.consequent.callee.body.start+1,end:n.consequent.callee.body.start+1,text:'++$p39Guard.finite;'});
 const diagnostic=edit(clean,instrument)+'\nconst $p39Guard={host:0,fullHost:0,scalar:0,fullScalar:0,opens:0,closes:0,rootEntries:0,finite:0};\nexport function guardStats(){return {...$p39Guard,active:regionProof!==null};}\nexport function guardReset(){for(const k of Object.keys($p39Guard))$p39Guard[k]=0;}\n';
 parse(diagnostic);const diag=path.join(out,variant+'.diagnostic.mjs');fs.writeFileSync(diag,diagnostic,{flag:'wx'});report.modules.push({variant,counters:true,...identity(diag)});
}
for(const row of report.inputs)assert.deepEqual(identity(row.path),row);
report.complete=true;fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
const modules=Object.fromEntries([['baseline',path.join(out,'baseline.clean.mjs')],['scope',path.join(out,'scope.clean.mjs')],['scope-no-finite',path.join(out,'scope-no-finite.clean.mjs')],['typescript',typescript]]);
const config={inputs:[path.join(out,'derive.json'),input,typescript,catalogFile],cases:cases.map(c=>({id:c.id,point:c.point,modules}))};
fs.writeFileSync(path.join(out,'compare.json'),JSON.stringify(config,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,certified:false,out,modules:report.modules.length,cases:cases.map(c=>c.id)}));
