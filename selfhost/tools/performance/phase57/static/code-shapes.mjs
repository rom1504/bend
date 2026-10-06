#!/usr/bin/env node
// Parses saved JavaScript as data. Never imports or evaluates a compiler image.
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {fileURLToPath} from 'node:url';
const [repoArg,outArg]=process.argv.slice(2);
assert(repoArg&&outArg,'usage: node code-shapes.mjs REPO FRESH_OUTPUT_JSON');
const repo=path.resolve(repoArg),out=path.resolve(outArg);
assert(!fs.existsSync(out));
assert(out.startsWith(path.join(repo,'selfhost/tools/performance/phase57/static')+path.sep),'Phase57 static output only');
const hash=x=>createHash('sha256').update(x).digest('hex');
const id=p=>{p=path.resolve(p);const b=fs.readFileSync(p);return {path:p,sha256:hash(b),bytes:b.length};};
const inputs=[];
const read=p=>{const x=id(p);inputs.push(x);return fs.readFileSync(x.path,'utf8');};
const base=path.join(repo,'selfhost/build/phase56');
const attempt=JSON.parse(read(path.join(base,'checked-string01/attempt.json')));
const derivation=JSON.parse(read(path.join(base,'checked-string01/equality/api.mjs.derivation.json')));
const emission=JSON.parse(read(path.join(base,'bootstrap-string01-plan/full/report.json')));
assert(emission.complete&&emission.pass&&derivation.complete);
const pin=ref=>{const p=ref.file??ref.path;const s=read(p);assert.equal(hash(Buffer.from(s)),ref.sha256);return s;};
assert.equal(emission.subject.source.sha256,'5356ec9963db7b300e8cbdf5474328b72150f582df96b01aeea29d6a07868244');
const same=(a,b)=>{assert.equal(path.resolve(a.file??a.path),path.resolve(b.file??b.path));assert.equal(a.sha256,b.sha256);};
same(attempt.checkedApi,derivation.original.api);same(attempt.api,derivation.output);
same(attempt.api,emission.generator.api);same(emission.subject.source,derivation.original.source);
const attemptPin=inputs.find(x=>x.path===path.join(base,'checked-string01/attempt.json'));
same(attemptPin,emission.subject.attempt);same(attemptPin,emission.generator.attempt);
same(attempt.bootstrapReport,derivation.original.bootstrapReport);same(attempt.bootstrapReport,emission.subject.bootstrap);same(attempt.bootstrapReport,emission.generator.bootstrap);
pin(attempt.bootstrapReport);pin(emission.subject.source);
const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'];
assert(parserSource);const box={exports:{}};box.module={exports:box.exports};vm.runInNewContext(parserSource,box);
const acorn=box.exports;assert.equal(typeof acorn.parse,'function');
const decode=(name,direct)=>direct?name.slice(4).replace(/_(\d+)_/g,(_,n)=>String.fromCodePoint(+n)):
 name.slice(1,-1).replace(/\$(\d{3})|\$/g,(_,n)=>n?String.fromCharCode(+n):'.');
function nodes(root,fn){const stack=[root];while(stack.length){const n=stack.pop();if(!n||typeof n!=='object')continue;if(n.type)fn(n);for(const [k,v] of Object.entries(n)){if(k==='loc')continue;if(Array.isArray(v)){for(const x of v)if(x&&typeof x==='object')stack.push(x);}else if(v&&typeof v==='object')stack.push(v);}}}
function measure(node,generated){
 const m={calls:{},generatedCalls:0,arrows:0,functionExpressions:0,objects:0,arrays:0,ifs:0,conditionals:0,loops:0,switches:0,continues:0,consts:0,orderedHolds:0,unitObjects:0};
 nodes(node,n=>{
  if(n.type==='CallExpression'&&n.callee.type==='Identifier'){const name=n.callee.name;m.calls[name]=(m.calls[name]??0)+1;if(generated.has(name))m.generatedCalls++;}
  if(n.type==='ArrowFunctionExpression')m.arrows++;
  if(n.type==='FunctionExpression')m.functionExpressions++;
  if(n.type==='ObjectExpression'){m.objects++;if(n.properties.some(p=>p.type==='Property'&&(p.key.name??p.key.value)==='$'&&p.value.value==='Unit'))m.unitObjects++;}
  if(n.type==='ArrayExpression')m.arrays++;
  if(n.type==='IfStatement')m.ifs++;
  if(n.type==='ConditionalExpression')m.conditionals++;
  if(['ForStatement','WhileStatement','DoWhileStatement','ForOfStatement','ForInStatement'].includes(n.type))m.loops++;
  if(n.type==='SwitchStatement')m.switches++;
  if(n.type==='ContinueStatement')m.continues++;
  if(n.type==='VariableDeclaration'&&n.kind==='const'){m.consts+=n.declarations.length;m.orderedHolds+=n.declarations.filter(d=>d.id.type==='Identifier'&&/^\$ord\d+$/.test(d.id.name)).length;}
 });return m;
}
function inventory(role,reference,direct){
 const text=pin(reference),comments=[];
 const ast=acorn.parse(text,{ecmaVersion:'latest',sourceType:'module',locations:true,onComment:(block,value,start,end)=>comments.push({value,start,end})});
 const defs=ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name.startsWith(direct?'$jd$':'$'));
 const generated=new Set(defs.map(n=>n.id.name)),functions={};
 for(const n of defs){const name=decode(n.id.name,direct);assert(!functions[name],name);const encoded=direct?'$jd$'+[...name].map(c=>/[A-Za-z0-9]/.test(c)?c:'_'+c.codePointAt(0)+'_').join(''):'$'+name.replace(/\W/g,c=>c==='.'?'$':'$'+String(c.charCodeAt(0)).padStart(3,'0'))+'$';assert.equal(encoded,n.id.name);functions[name]={identifier:n.id.name,line:n.loc.start.line,bytes:Buffer.byteLength(text.slice(n.start,n.end)),sha256:hash(text.slice(n.start,n.end)),params:n.params.length,...measure(n.body,generated)};}
 const exp=ast.body.filter(n=>n.type==='ExportDefaultDeclaration');assert.equal(exp.length,1);assert.equal(exp[0].declaration.type,'ObjectExpression');
 const exportNames=exp[0].declaration.properties.map(p=>{assert.equal(p.type,'Property');return p.key.value??p.key.name;});assert.equal(new Set(exportNames).size,exportNames.length);
 const metadata=comments.filter(c=>/^JD_(USE|REF):/.test(c.value));
 const pcGroups=new Map();
 for(const n of defs){const pc=n.body.body.find(s=>s.type==='VariableDeclaration'&&s.declarations.some(d=>d.id.name==='$pc'));if(!pc)continue;const tail=n.body.body.filter(s=>s.start>=pc.end).map(s=>text.slice(s.start,s.end)).join('');const h=hash(tail);if(!pcGroups.has(h))pcGroups.set(h,[]);pcGroups.get(h).push(decode(n.id.name,direct));}
 return {role,identity:id(reference.file??reference.path),generatedFunctionCount:defs.length,generatedFunctionBytes:Object.values(functions).reduce((n,f)=>n+f.bytes,0),defaultExportBytes:Buffer.byteLength(text.slice(exp[0].start,exp[0].end)),exportNames,metadataComments:metadata.length,metadataCommentBytes:metadata.reduce((n,c)=>n+Buffer.byteLength(text.slice(c.start,c.end)),0),all:measure(ast,generated),functions,identicalPcTails:[...pcGroups.values()].filter(g=>g.length>1)};
}
const roles=[inventory('rawChecked',attempt.checkedApi,false),inventory('derivedB1',attempt.api,false),inventory('directB2',emission.module,true)];
const common=Object.keys(roles[0].functions).filter(n=>roles.every(r=>r.functions[n]));
const tool=id(fileURLToPath(import.meta.url));inputs.push(tool);
for(const input of inputs)assert.deepEqual(id(input.path),input,'input changed');
const result={kind:'phase57-static-compiler-code-shapes',complete:true,scope:'Syntax inventory only; generated modules never imported or executed. Counts include duplicated SCC bodies, dead definitions and wrappers; no dynamic frequency or optimization attribution.',node:id(process.execPath),parser:{version:acorn.version,sha256:hash(parserSource)},inputs,subject:emission.subject.source,derivation:{version:derivation.transform.version,equalityReplacements:derivation.transform.replacements,choices:derivation.transform.choices.sites,tailChoices:derivation.transform.tailChoices.sites,deferredGeneratedCalls:derivation.transform.tailChoices.deferredGeneratedCalls},roles,commonFunctions:common.length};
fs.mkdirSync(path.dirname(out),{recursive:true});fs.writeFileSync(out,JSON.stringify(result,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({output:id(out),commonFunctions:common.length,roles:roles.map(r=>({role:r.role,bytes:r.identity.bytes,functions:r.generatedFunctionCount,exports:r.exportNames.length,metadata:r.metadataCommentBytes}))}));
