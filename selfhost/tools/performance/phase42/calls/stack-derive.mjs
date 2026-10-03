// Exact checked-JS phase pruning / lazy stack discriminator. Root executes.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';
const[input,tsArg,adapterArg,outArg]=process.argv.slice(2);assert(input&&tsArg&&adapterArg&&outArg,'usage: stack-derive.mjs CHECKED_TREE TS_TREE ACTUAL_OWNED_DERIVED NEW_OUT');
const sha=x=>createHash('sha256').update(x).digest('hex'),identity=p=>({path:fs.realpathSync(p),sha256:sha(fs.readFileSync(p))});
const source=fs.readFileSync(input,'utf8'),receipt=JSON.parse(fs.readFileSync(input+'.json'));assert.equal(receipt.complete,true);assert.equal(receipt.observation.checked,true);assert.equal(receipt.observation.status,'ok');assert.equal(receipt.output.sha256,sha(source));
for(const row of[receipt.input,receipt.producer,receipt.attempt,receipt.compiler.api,receipt.compiler.runtime,receipt.compiler.base,receipt.compiler.driver,...receipt.verifiers])assert.equal(identity(row.canonicalPath??row.file).sha256,row.sha256,'consumed identity');assert.equal(receipt.compiler.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
const adapterReceipt=JSON.parse(fs.readFileSync(path.join(adapterArg,'derive.json')));assert.equal(adapterReceipt.complete,true);assert.equal(adapterReceipt.checked,true);const clean=adapterReceipt.modules.find(m=>m.variant==='candidate'&&!m.diagnostic),diag=adapterReceipt.modules.find(m=>m.variant==='candidate'&&m.diagnostic);assert.equal(clean.sha256,sha(source),'same actual adapter parent required');assert.equal(identity(clean.path).sha256,clean.sha256);assert.equal(identity(diag.path).sha256,diag.sha256);
const diagSource=fs.readFileSync(diag.path,'utf8'),pm={exports:{}};new Function('module','exports',process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'])(pm,pm.exports);assert.equal(pm.exports.version,'8.16.0');const parse=s=>pm.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
const header=parse(diagSource).body.find(n=>n.type==='VariableDeclaration'&&n.declarations.some(d=>d.id.name==='$p42WorkerEntries'));assert(header);const adapter=diagSource.slice(header.start);
function walk(n,fn){if(!n||typeof n!=='object')return;fn(n);for(const[k,v]of Object.entries(n))if(!['start','end'].includes(k)){if(Array.isArray(v))v.forEach(x=>walk(x,fn));else if(v&&typeof v==='object')walk(v,fn);}}
function apply(text,edits){edits.sort((a,b)=>b.start-a.start);for(let i=1;i<edits.length;i++)assert(edits[i].end<=edits[i-1].start,'overlapping edits');for(const e of edits)text=text.slice(0,e.start)+e.text+text.slice(e.end);parse(text);return text;}
const workers=parse(source).body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name.endsWith('$tree')&&source.slice(n.start,n.end).includes('const $frames=[];'));assert.equal(workers.length,4);const prune=[],lazy=[],sites=[];
for(const worker of workers){const arrays=[],pushes=[],phases=[],whiles=[];
 walk(worker.body,n=>{
  if(n.type==='VariableDeclaration'&&n.declarations.some(d=>d.id.name==='$frames'))arrays.push(n);
  if(n.type==='VariableDeclaration'&&n.declarations.some(d=>d.id.name==='$saved'))pushes.push(n);
  if(n.type==='WhileStatement'&&source.slice(n.test.start,n.test.end)==='$top')whiles.push(n);
  if(n.type==='IfStatement'&&source.slice(n.test.start,n.test.end)==='$frame.phase===2')phases.push(n);
  if(n.type==='AssignmentExpression'&&n.left.type==='MemberExpression'&&n.left.property.name==='phase'&&['$frame','$saved'].includes(n.left.object.name))assert(n.right.type==='Literal'&&[0,1].includes(n.right.value),'binary worker only writes phase0/1');
  if(n.type==='ObjectExpression')for(const p of n.properties)if(p.key?.name==='phase')assert(p.value.type==='Literal'&&[0,1].includes(p.value.value),'no phase2 frame initializer');
 });
 assert.equal(arrays.length,1);assert.equal(pushes.length,1);assert.equal(phases.length,1);assert.equal(whiles.length,1);assert.equal(source.slice(arrays[0].start,arrays[0].end),'const $frames=[];');assert(phases[0].alternate);
 prune.push({start:phases[0].start,end:phases[0].end,text:source.slice(phases[0].alternate.start,phases[0].alternate.end)});
 lazy.push({start:arrays[0].start,end:arrays[0].end,text:'let $frames=null;'}, {start:pushes[0].start,end:pushes[0].start,text:'if($frames===null)$frames=[];'}, {start:whiles[0].test.start,end:whiles[0].test.end,text:'$frames!==null&&$top'});
 sites.push({worker:worker.id.name,phaseWrites:[0,1],pushes:pushes.length});
}
const out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out);const modules=[];
for(const[variant,edits]of[['original',[]],['noise',[]],['prune',prune],['lazy',lazy],['combined',[...prune,...lazy]]]){
 const text=apply(source,[...edits]);if(['original','noise'].includes(variant))assert.equal(sha(text),sha(source));const cleanFile=path.join(out,variant+'.clean.mjs');fs.writeFileSync(cleanFile,text,{flag:'wx'});modules.push({variant,diagnostic:false,...identity(cleanFile)});
 const ast=parse(text),instrument=[];let allocations=0;
 const wrapper=ast.body.find(n=>n.type==='FunctionDeclaration'&&n.id.name==='$R_119_97_114_112_95_110_111_100_101$tree');assert(wrapper);instrument.push({start:wrapper.body.start+1,end:wrapper.body.start+1,text:'++$p42WorkerEntries;'});
 walk(ast,n=>{
  if(n.type==='ArrowFunctionExpression'&&n.body.type==='BlockStatement'&&text.slice(n.body.start,n.body.start+60).startsWith('{/* private acyclic helper */'))instrument.push({start:n.body.start+1,end:n.body.start+1,text:'++$p42HelperEntries;'});
  if(n.type==='AssignmentExpression'&&n.left.name==='$frames'&&n.right.type==='ArrayExpression'){instrument.push({start:n.start,end:n.end,text:'($p42StackAllocs++,'+text.slice(n.start,n.end)+')'});++allocations;}
  if(n.type==='VariableDeclaration'&&n.declarations.some(d=>d.id.name==='$frames'&&d.init?.type==='ArrayExpression')){instrument.push({start:n.end,end:n.end,text:'++$p42StackAllocs;'});++allocations;}
 });assert.equal(allocations,4);
 const diagnostic=apply(text,instrument)+'\nlet $p42StackAllocs=0;\n'+adapter+'\nexport function p42StackAllocs(){return $p42StackAllocs;}\n';parse(diagnostic);const file=path.join(out,variant+'.mjs');fs.writeFileSync(file,diagnostic,{flag:'wx'});modules.push({variant,diagnostic:true,...identity(file)});
}
const report={kind:'phase42-stack-lazy-prune-ablation',complete:true,checked:false,parentChecked:true,producer:identity(import.meta.filename),parent:identity(input),receipt:identity(input+'.json'),adapter:identity(diag.path),adapterReceipt:identity(path.join(adapterArg,'derive.json')),dependencies:adapterReceipt.dependencies,typescript:identity(tsArg),sites,modules};fs.copyFileSync(import.meta.filename,path.join(out,'consumed-stack-derive.mjs'));fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
const catalog=JSON.parse(fs.readFileSync('selfhost/tools/performance/phase37/catalog.json')),cases=catalog.cases.filter(c=>['variation-tree-bitonic-6-17','tree-bitonic','variation-tree-bitonic-9-123'].includes(c.id)).map(c=>({id:c.id,point:c.point,modules:Object.fromEntries([...['original','noise','prune','lazy','combined'].map(v=>[v,path.join(out,v+'.clean.mjs')]),['typescript',fs.realpathSync(tsArg)]])}));assert.equal(cases.length,3);fs.writeFileSync(path.join(out,'compare.json'),JSON.stringify({inputs:[path.join(out,'derive.json'),input,tsArg],cases},null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:true,out,sites}));
