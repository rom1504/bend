// Actual checked emission: adapters and diagnostic counters only. Root executes.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {verifyAttempt} from '../../../development/workflow.mjs';
const[baseArg,candidateArg,tsArg,attemptArg,outArg]=process.argv.slice(2);
assert(baseArg&&candidateArg&&tsArg&&attemptArg&&outArg,'usage: owned-actual-derive-v2.mjs CHECKED02_TREE SELECTED_TREE TS_TREE SELECTED_ATTEMPT NEW_OUT');
const sha=x=>createHash('sha256').update(x).digest('hex');
const identity=p=>({path:fs.realpathSync(p),sha256:sha(fs.readFileSync(p))});
const out=path.resolve(outArg);assert(!fs.existsSync(out));
const attempt=await verifyAttempt(path.resolve(attemptArg));assert.equal(attempt.checked,true);
const ps=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],pm={exports:{}};new Function('module','exports',ps)(pm,pm.exports);assert.equal(pm.exports.version,'8.16.0');
const parse=s=>pm.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
function walk(n,fn){if(!n||typeof n!=='object')return;fn(n);for(const[k,v]of Object.entries(n))if(!['start','end'].includes(k)){if(Array.isArray(v))v.forEach(x=>walk(x,fn));else if(v&&typeof v==='object')walk(v,fn);}}
const all=['bench','bsort','warp','warp_zip','warp_leaf','Bool.xor','warp_leaf.go','flow','warp_node','key','prng','scan','stat_join','stat_join.go','stat_out'];
const dependencies=all.filter(n=>n!=='bench');
const adapterParent=path.resolve('selfhost/tools/performance/phase41/tree/actual-derive-v2.mjs'),adapterSource=fs.readFileSync(adapterParent,'utf8');
const adapterStart=adapterSource.indexOf('function adapters(variant){return `')+'function adapters(variant){return `'.length,adapterEnd=adapterSource.indexOf('`;}\n',adapterStart);assert(adapterEnd>adapterStart);
let adapter=adapterSource.slice(adapterStart,adapterEnd).replace('${JSON.stringify(all)}',JSON.stringify(all)).replaceAll("${variant==='wrapper'?'$p41Entries':'0'}",'$p42WorkerEntries+$p42HelperEntries').replaceAll("${variant==='wrapper'?'$R_119_97_114_112_95_110_111_100_101$tree(t,false)':\"callOwned(callOwned(get(G,'warp_node'),[t]),[false])\"}",'$R_119_97_114_112_95_110_111_100_101$tree(t,false)');assert(!adapter.includes('${'));
const extra=`
// Invoke actual source-selected workers; no handwritten helper stand-in.
export function p42Leaf(a,b,s){if(!regionHostGuard()||!localGuard($p41All))throw Error('diagnostic guard');const previous=regionProofOpen($p41All);try{return $R_119_97_114_112$tree(ctor('Leaf',[a]),ctor('Leaf',[b]),s);}finally{regionProofClose(previous);}}
export function p42Key(x){if(!regionHostGuard()||!localGuard($p41All))throw Error('diagnostic guard');const previous=regionProofOpen($p41All);try{return $R_98_115_111_114_116$tree(0n,false,x).a[0];}finally{regionProofClose(previous);}}
export function p42HelperCounts(){return $p42HelperEntries;}
export function p42DirectCtorCounts(){return {total:$p42DirectCtorEntries,tags:{...$p42DirectCtorTags}};}
`;
fs.mkdirSync(out,{recursive:false});const modules=[],inputs=[],staticSites={};let baselineInput,baselineBase;const roleProvenance={};
for(const[variant,parentArg]of[['original',baseArg],['candidate',candidateArg]]){
 const parent=fs.realpathSync(parentArg),source=fs.readFileSync(parent,'utf8'),receipt=JSON.parse(fs.readFileSync(parent+'.json'));
 assert.equal(receipt.complete,true);assert.equal(receipt.observation.checked,true);assert.equal(receipt.observation.status,'ok');assert.equal(receipt.output.sha256,sha(source));assert.equal(receipt.compiler.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
 for(const row of[receipt.input,receipt.producer,receipt.attempt,receipt.compiler.api,receipt.compiler.runtime,receipt.compiler.base,receipt.compiler.driver,...receipt.verifiers])assert.equal(identity(row.canonicalPath??row.file).sha256,row.sha256,'consumed identity');
 if(variant==='original'){const originalAttempt=await verifyAttempt(path.dirname(receipt.attempt.canonicalPath??receipt.attempt.file));assert.equal(originalAttempt.checked,true);assert.equal(receipt.compiler.driver.sha256,identity(path.join(originalAttempt.snapshot.root,'tools/typed-driver.mjs')).sha256,'baseline own driver');for(const key of['api','runtime','base'])assert.equal(receipt.compiler[key].sha256,originalAttempt[key].sha256,'baseline own checked '+key);baselineInput=receipt.input.sha256;baselineBase=receipt.compiler.base.sha256;}
 else{assert.equal(receipt.input.sha256,baselineInput);assert.equal(receipt.compiler.base.sha256,baselineBase);assert.equal(receipt.compiler.driver.sha256,identity(path.join(attempt.snapshot.root,'tools/typed-driver.mjs')).sha256,'candidate own driver');assert.equal(receipt.attempt.sha256,identity(path.join(attemptArg,'attempt.json')).sha256);for(const key of['api','runtime','base'])assert.equal(receipt.compiler[key].sha256,attempt[key].sha256);}
 roleProvenance[variant]={attempt:receipt.attempt,api:receipt.compiler.api,runtime:receipt.compiler.runtime,base:receipt.compiler.base,driver:receipt.compiler.driver};
 const ast=parse(source),workers=ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name.endsWith('$tree')),helpers=[];
 assert.equal(workers.length,5);const worker=workers.find(n=>n.id.name==='$R_119_97_114_112_95_110_111_100_101$tree');assert(worker);
 walk(ast,n=>{if(n.type==='ArrowFunctionExpression'&&n.body.type==='BlockStatement'&&source.slice(n.body.start,n.body.start+60).startsWith('{/* private acyclic helper */'))helpers.push(n);});
 if(variant==='candidate'){assert(helpers.length>0,'actual compiler inline helper required');for(const w of workers)assert(!source.slice(w.start,w.end).includes('regionProofCovers('),'actual inherited proof lowering required');}
 const declared=new Set(workers.map(n=>n.id.name));walk(ast,n=>{if(n.type==='CallExpression'&&n.callee.name?.endsWith('$tree'))assert(declared.has(n.callee.name),'undefined worker');});
 const tagged=[];const scopes=[...workers.map(n=>n.body),...helpers.map(n=>n.body)];
 walk(ast,n=>{if(n.type==='ObjectExpression'&&scopes.some(b=>n.start>=b.start&&n.end<=b.end)){
 const tag=n.properties.find(p=>p.key?.name==='$'),args=n.properties.find(p=>p.key?.name==='a');
 if(tag?.value?.type==='Literal'&&typeof tag.value.value==='string'&&args?.value?.type==='ArrayExpression')tagged.push(n);
 }});
 if(variant==='original')assert.equal(tagged.length,0,'checked02 must precede constructor admission');else assert(tagged.length>0,'checked03 actual direct constructors required');
 staticSites[variant]={workers:workers.length,helpers:helpers.length,directConstructors:tagged.length,tags:[...new Set(tagged.map(n=>n.properties.find(p=>p.key?.name==='$').value.value))]};
 const edits=[{at:worker.body.start+1,text:'++$p42WorkerEntries;'},...helpers.map(n=>({at:n.body.start+1,text:'++$p42HelperEntries;'})),...tagged.flatMap(n=>{const tag=JSON.stringify(n.properties.find(p=>p.key?.name==='$').value.value);return[{at:n.start,text:'($p42DirectCtorEntries++,($p42DirectCtorTags['+tag+']=($p42DirectCtorTags['+tag+']||0)+1),'},{at:n.end,text:')'}];})];
 let diagnostic=source;for(const e of edits.sort((a,b)=>b.at-a.at))diagnostic=diagnostic.slice(0,e.at)+e.text+diagnostic.slice(e.at);
 diagnostic+='\nlet $p42WorkerEntries=0,$p42HelperEntries=0,$p42DirectCtorEntries=0;const $p42DirectCtorTags=Object.create(null);\n'+adapter+extra;parse(diagnostic);
 for(const[instrumented,text]of[[false,source],[true,diagnostic]]){const file=path.join(out,variant+(instrumented?'.mjs':'.clean.mjs'));fs.writeFileSync(file,text,{flag:'wx'});if(!instrumented)assert.equal(sha(text),sha(source));modules.push({variant,diagnostic:instrumented,...identity(file)});}
 inputs.push(identity(parent),identity(parent+'.json'));
}
const report={kind:'phase42-owned-constructors-actual',complete:true,checked:true,producer:identity(import.meta.filename),attempt:identity(path.join(attemptArg,'attempt.json')),typescript:identity(tsArg),adapterParent:identity(adapterParent),controlOwner:identity('selfhost/tools/performance/phase42/calls/actual-controls.mjs'),parserSha256:sha(ps),dependencies,roleProvenance,staticSites,modules,inputs};
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-actual-derive.mjs'));fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
const catalog=JSON.parse(fs.readFileSync('selfhost/tools/performance/phase37/catalog.json')),cases=catalog.cases.filter(c=>['variation-tree-bitonic-6-17','tree-bitonic','variation-tree-bitonic-9-123'].includes(c.id)).map(c=>({id:c.id,point:c.point,modules:Object.fromEntries([...['original','candidate'].map(v=>[v,path.join(out,v+'.clean.mjs')]),['typescript',fs.realpathSync(tsArg)]])}));assert.equal(cases.length,3);
fs.writeFileSync(path.join(out,'compare.json'),JSON.stringify({inputs:[path.join(out,'derive.json'),...inputs.map(x=>x.path),tsArg],cases},null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:true,out,staticSites}));
