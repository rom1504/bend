// Actual checked source output: counters/adapters only, clean bytes unchanged.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {verifyAttempt} from '../../../development/workflow.mjs';
const [baselineArg,candidateArg,tsArg,attemptArg,outArg]=process.argv.slice(2);
assert(baselineArg&&candidateArg&&tsArg&&attemptArg&&outArg,'usage: actual-derive-v2.mjs CHECKED06 CANDIDATE TS ATTEMPT NEW_OUT');
const sha=x=>createHash('sha256').update(x).digest('hex');
const identity=p=>({path:fs.realpathSync(p),sha256:sha(fs.readFileSync(p))});
const out=path.resolve(outArg);assert(!fs.existsSync(out));
const attempt=await verifyAttempt(path.resolve(attemptArg));assert.equal(attempt.checked,true);
const baseline=fs.realpathSync(baselineArg),candidate=fs.realpathSync(candidateArg),ts=fs.realpathSync(tsArg);
const ps=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],pm={exports:{}};
new Function('module','exports',ps)(pm,pm.exports);assert.equal(pm.exports.version,'8.16.0');
const parse=s=>pm.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
const all=['bench','bsort','warp','warp_zip','warp_leaf','Bool.xor','warp_leaf.go','flow','warp_node','key','prng','scan','stat_join','stat_join.go','stat_out'];
const names=['warp_leaf.go','Bool.xor','warp_leaf','warp_zip','warp','warp_node'];
const encoded=name=>'$R'+Array.from(name,c=>'_'+c.codePointAt(0)).join('')+'$tree';
function walk(n,fn){if(!n||typeof n!=='object')return;fn(n);for(const[k,v]of Object.entries(n))if(!['start','end'].includes(k)){if(Array.isArray(v))v.forEach(x=>walk(x,fn));else if(v&&typeof v==='object')walk(v,fn);}}
function adapters(variant){return `
const $p41All=${JSON.stringify(all)};
export function p41ProofActive(){return regionProof!==null;}
export function p41Counts(){return ${variant==='wrapper'?'$p41Entries':'0'};}
function $p41Make(d,x,shared,uneven){if(d===0)return ctor('Leaf',[x]);
 const l=$p41Make(d-1,(Math.imul(x,3)+1)>>>0,shared,uneven);
 return ctor('Node',[l,shared?l:$p41Make(uneven&&d%2===0?0:d-1,(Math.imul(x,5)+7)>>>0,shared,uneven)]);}
// Scalar diagnostic construction owns all trees; adapters are not public admission.
export function p41Flow(n,d,x,s,shared=false,uneven=false){
 assertP41(n,d,x,s);const t=$p41Make(d,x,shared,uneven);
 if(!regionHostGuard()||!localGuard($p41All))return call(get(G,'flow'),[BigInt(n),s,t]);
 const previous=regionProofOpen($p41All);try{return call(get(G,'flow'),[BigInt(n),s,t]);}finally{regionProofClose(previous);}}
function assertP41(n,d,x,s){if(!Number.isInteger(n)||n<0||n>12||!Number.isInteger(d)||d<0||d>9||!Number.isInteger(x)||x<0||x>4294967295||typeof s!=='boolean')throw Error('diagnostic scalar domain');}
export function p41Fresh(){const t=ctor('Leaf',[7]);if(!regionHostGuard()||!localGuard($p41All))throw Error('diagnostic guard');
 const previous=regionProofOpen($p41All);try{const r=${variant==='wrapper'?'$R_119_97_114_112_95_110_111_100_101$tree(t,false)':"callOwned(callOwned(get(G,'warp_node'),[t]),[false])"};return[r!==t,r.a[0]===t.a[0]];}finally{regionProofClose(previous);}}
export function p41Deep(depth){if(!Number.isInteger(depth)||depth<0||depth>30000)throw Error('diagnostic scalar domain');
 const leaf=ctor('Leaf',[7]);let t=leaf;for(let i=0;i<depth;i++)t=ctor('Node',[t,leaf]);
 const root=ctor('Node',[ctor('Node',[t,t]),leaf]);
 if(!regionHostGuard()||!localGuard($p41All))throw Error('diagnostic guard');
 const previous=regionProofOpen($p41All);try{return call(get(G,'flow'),[1n,false,root]);}finally{regionProofClose(previous);}}
export function p41ZeroAliases(){const l=ctor('Leaf',[7]),r=ctor('Leaf',[11]),t=ctor('Node',[l,r]);
 if(!regionHostGuard()||!localGuard($p41All))throw Error('diagnostic guard');
 const previous=regionProofOpen($p41All);try{const v=$R_102_108_111_119$tree(0n,false,t);return[v!==t,v.a[0]===l,v.a[1]===r];}finally{regionProofClose(previous);}}
`;}

fs.mkdirSync(out,{recursive:false});const modules=[],inputs=[];
let baselineInput;
for(const [variant,parent]of[['original',baseline],['wrapper',candidate]]){
 const source=fs.readFileSync(parent,'utf8'),receipt=JSON.parse(fs.readFileSync(parent+'.json'));
 assert.equal(receipt.complete,true);assert.equal(receipt.observation.checked,true);assert.equal(receipt.observation.status,'ok');
 assert.equal(receipt.output.sha256,sha(source));
 assert.equal(receipt.compiler.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
 if(variant==='original'){assert.equal(receipt.compiler.api.sha256,'630879d8f030241a1d2c56e97f18f88b5be2070ac45dd02304afd06b3e3c5c0a');baselineInput=receipt.input.sha256;}
 else{assert.equal(receipt.input.sha256,baselineInput);assert.equal(receipt.attempt.sha256,identity(path.join(attemptArg,'attempt.json')).sha256);for(const key of['api','runtime','base'])assert.equal(receipt.compiler[key].sha256,attempt[key].sha256);}
 assert.equal(identity(receipt.input.canonicalPath??receipt.input.file).sha256,receipt.input.sha256);
 assert.equal(identity(receipt.compiler.driver.canonicalPath??receipt.compiler.driver.file).sha256,receipt.compiler.driver.sha256);
 for(const key of['api','runtime','base'])assert.equal(identity(receipt.compiler[key].canonicalPath??receipt.compiler[key].file).sha256,receipt.compiler[key].sha256);
 const ast=parse(source),workers=ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name.endsWith('$tree'));
 const found=workers.filter(n=>n.id.name===encoded('warp_node'));assert.equal(found.length,variant==='wrapper'?1:0);
 const declared=new Set(workers.map(n=>n.id.name));assert.equal(declared.size,workers.length);
 walk(ast,n=>{if(n.type==='CallExpression'&&n.callee.name?.endsWith('$tree'))assert(declared.has(n.callee.name),'undefined worker');});
 if(found.length){const body=source.slice(found[0].body.start,found[0].body.end);assert(!body.includes('$frames'),'acyclic worker must not allocate frames');assert(!body.includes('$visit'),'acyclic worker must not loop');}
 let diagnostic=source;
 if(found.length){const at=found[0].body.start+1;diagnostic=diagnostic.slice(0,at)+'++$p41Entries;'+diagnostic.slice(at);}
 diagnostic+='\nlet $p41Entries=0;\n'+adapters(variant);parse(diagnostic);
 for(const [instrumented,text]of[[false,source],[true,diagnostic]]){
  const file=path.join(out,variant+(instrumented?'.mjs':'.clean.mjs'));fs.writeFileSync(file,text,{flag:'wx'});
  if(!instrumented)assert.equal(sha(text),sha(source));modules.push({variant,diagnostic:instrumented,...identity(file)});
 }
 inputs.push(identity(parent),identity(parent+'.json'));
}
const report={kind:'phase41-tree-actual-wrapper',complete:true,checked:true,producer:identity(import.meta.filename),attempt:identity(path.join(attemptArg,'attempt.json')),typescript:identity(ts),dependencies:names,modules,inputs};
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-actual-derive.mjs'));
fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
const catalog=JSON.parse(fs.readFileSync('selfhost/tools/performance/phase37/catalog.json'));
const cases=catalog.cases.filter(c=>['variation-tree-bitonic-6-17','tree-bitonic','variation-tree-bitonic-9-123'].includes(c.id)).map(c=>({id:c.id,point:c.point,modules:Object.fromEntries([...['original','wrapper'].map(v=>[v,path.join(out,v+'.clean.mjs')]),['typescript',ts]])}));
assert.equal(cases.length,3);fs.writeFileSync(path.join(out,'compare.json'),JSON.stringify({inputs:[path.join(out,'derive.json'),baseline,candidate,ts],cases},null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,out,modules:modules.length}));
