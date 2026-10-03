// Exact saved checked06 ablation; no compiler promotion. Root runs this tool.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [inputArg,tsArg,outArg]=process.argv.slice(2);
assert(inputArg&&tsArg&&outArg,'usage: derive.mjs CHECKED06_TREE TS_TREE NEW_OUT');
const sha=x=>createHash('sha256').update(x).digest('hex');
const identity=p=>({path:fs.realpathSync(p),sha256:sha(fs.readFileSync(p))});
const input=fs.realpathSync(inputArg),ts=fs.realpathSync(tsArg),out=path.resolve(outArg);
assert(!fs.existsSync(out));
const source=fs.readFileSync(input,'utf8'),receipt=JSON.parse(fs.readFileSync(input+'.json'));
assert.equal(sha(source),'3a5d3c78ebb74aba0cc5a6729547b1ea2892874f07a5c3ccb474c7cb04a2cfd9');
assert.equal(receipt.complete,true);assert.equal(receipt.observation.checked,true);
assert.equal(receipt.compiler.api.sha256,'630879d8f030241a1d2c56e97f18f88b5be2070ac45dd02304afd06b3e3c5c0a');
assert.equal(receipt.output.sha256,sha(source));
const ps=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],pm={exports:{}};
new Function('module','exports',ps)(pm,pm.exports);assert.equal(pm.exports.version,'8.16.0');
const parse=s=>pm.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
function spine(n){if(n.type!=='CallExpression')return null;
 if(n.callee.name==='get'&&n.arguments[0]?.name==='G'&&n.arguments[1]?.type==='Literal')return{name:n.arguments[1].value,args:[]};
 if(!['callOwned','jump'].includes(n.callee.name)||n.arguments[1]?.type!=='ArrayExpression')return null;
 const s=spine(n.arguments[0]);return s&&{name:s.name,args:[...s.args,...n.arguments[1].elements]};}
const sites=[];function walk(n){if(!n||typeof n!=='object')return;
 const s=spine(n);if(s?.name==='warp_node'&&s.args.length===2)sites.push({...s,start:n.start,end:n.end});
 for(const[k,v]of Object.entries(n))if(!['start','end'].includes(k)){if(Array.isArray(v))v.forEach(walk);else if(v&&typeof v==='object')walk(v);}}
walk(parse(source));assert.equal(sites.length,6);
const names=['warp_leaf.go','Bool.xor','warp_leaf','warp_zip','warp','warp_node'];
const all=['bench','bsort','warp','warp_zip','warp_leaf','Bool.xor','warp_leaf.go','flow','warp_node','key','prng','scan','stat_join','stat_join.go','stat_out'];
function helper(diagnostic){return `
const $p41Names=${JSON.stringify(names)};
${diagnostic?'let $p41Entries=0;':''}
function $p41WarpNode(t,s){${diagnostic?'++$p41Entries;':''}
 if(t.$==='Leaf')return ctor('Leaf',[t.a[0]]);
 if(t.$==='Node')return $R_119_97_114_112$tree(t.a[0],t.a[1],s);
 return bad('private component prefix invariant');}
`;}
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
 const previous=regionProofOpen($p41All);try{return $R_102_108_111_119$tree(BigInt(n),s,t);}finally{regionProofClose(previous);}}
function assertP41(n,d,x,s){if(!Number.isInteger(n)||n<0||n>12||!Number.isInteger(d)||d<0||d>9||!Number.isInteger(x)||x<0||x>4294967295||typeof s!=='boolean')throw Error('diagnostic scalar domain');}
export function p41Fresh(){const t=ctor('Leaf',[7]);if(!regionHostGuard()||!localGuard($p41All))throw Error('diagnostic guard');
 const previous=regionProofOpen($p41All);try{const r=${variant==='wrapper'?'$p41WarpNode(t,false)':"callOwned(callOwned(get(G,'warp_node'),[t]),[false])"};return[r!==t,r.a[0]===t.a[0]];}finally{regionProofClose(previous);}}
export function p41Deep(depth){if(!Number.isInteger(depth)||depth<0||depth>30000)throw Error('diagnostic scalar domain');
 const leaf=ctor('Leaf',[7]);let t=leaf;for(let i=0;i<depth;i++)t=ctor('Node',[t,leaf]);
 const root=ctor('Node',[ctor('Node',[t,t]),leaf]);
 if(!regionHostGuard()||!localGuard($p41All))throw Error('diagnostic guard');
 const previous=regionProofOpen($p41All);try{return $R_102_108_111_119$tree(1n,false,root);}finally{regionProofClose(previous);}}
export function p41ZeroAliases(){const l=ctor('Leaf',[7]),r=ctor('Leaf',[11]),t=ctor('Node',[l,r]);
 if(!regionHostGuard()||!localGuard($p41All))throw Error('diagnostic guard');
 const previous=regionProofOpen($p41All);try{const v=$R_102_108_111_119$tree(0n,false,t);return[v!==t,v.a[0]===l,v.a[1]===r];}finally{regionProofClose(previous);}}
`;}
fs.mkdirSync(out,{recursive:false});const modules=[];
for(const diagnostic of[false,true])for(const variant of['original','noise','wrapper']){
 let text=source;
 if(variant==='wrapper'){
  for(const s of [...sites].sort((a,b)=>b.start-a.start)){
   const args=s.args.map(a=>source.slice(a.start,a.end)).join(','),old=source.slice(s.start,s.end);
   text=text.slice(0,s.start)+`(regionProof!==null&&regionProofCovers($p41Names)?$p41WarpNode(${args}):${old})`+text.slice(s.end);}
  text+=helper(diagnostic);
 }
 if(diagnostic)text+=adapters(variant);
 parse(text);const file=path.join(out,variant+(diagnostic?'.mjs':'.clean.mjs'));
 fs.writeFileSync(file,text,{flag:'wx'});modules.push({variant,diagnostic,...identity(file)});
 if(!diagnostic&&variant!=='wrapper')assert.equal(sha(text),sha(source));
}
const report={kind:'phase41-tree-wrapper-ablation',complete:true,checked:false,producer:identity(import.meta.filename),parent:identity(input),typescript:identity(ts),receipt:identity(input+'.json'),parserSha256:sha(ps),sites:sites.map(({start,end})=>({start,end})),dependencies:names,modules};
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-derive.mjs'));
fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
const catalog=JSON.parse(fs.readFileSync('selfhost/tools/performance/phase37/catalog.json'));
const cases=catalog.cases.filter(c=>['variation-tree-bitonic-6-17','tree-bitonic','variation-tree-bitonic-9-123'].includes(c.id)).map(c=>({id:c.id,point:c.point,modules:Object.fromEntries([...['original','noise','wrapper'].map(v=>[v,path.join(out,v+'.clean.mjs')]),['typescript',ts]])}));
assert.equal(cases.length,3);
fs.writeFileSync(path.join(out,'compare.json'),JSON.stringify({inputs:[path.join(out,'derive.json'),input,ts],cases},null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,out,sites:sites.length,modules:modules.length}));
