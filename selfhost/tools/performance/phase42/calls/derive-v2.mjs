// Phase42 exact saved-JS discriminator. Root owns execution and timings.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [inputArg,tsArg,outArg]=process.argv.slice(2);
assert(inputArg&&tsArg&&outArg,'usage: derive.mjs PHASE41_TREE TS_TREE NEW_OUT');
const sha=x=>createHash('sha256').update(x).digest('hex');
const identity=p=>({path:fs.realpathSync(p),sha256:sha(fs.readFileSync(p))});
const input=fs.realpathSync(inputArg),ts=fs.realpathSync(tsArg),out=path.resolve(outArg);
assert(!fs.existsSync(out));
const source=fs.readFileSync(input,'utf8'),receipt=JSON.parse(fs.readFileSync(input+'.json'));
assert.equal(receipt.complete,true);assert.equal(receipt.observation.checked,true);assert.equal(receipt.observation.status,'ok');
assert.equal(receipt.compiler.api.sha256,'9900abf49719575db7f7bbee32c6b16e10bcd554f9de22cde0799eb859cc6f0b');
for(const row of [receipt.input,receipt.producer,receipt.attempt,receipt.compiler.api,receipt.compiler.runtime,receipt.compiler.base,receipt.compiler.driver,...receipt.verifiers]){assert.equal(identity(row.canonicalPath??row.file).sha256,row.sha256,'consumed identity');}
assert.equal(receipt.compiler.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');assert.equal(receipt.output.sha256,sha(source));
const ps=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],pm={exports:{}};
new Function('module','exports',ps)(pm,pm.exports);assert.equal(pm.exports.version,'8.16.0');
const parse=s=>pm.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
const ast=parse(source),workers=ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name.endsWith('$tree'));
assert.equal(workers.length,5);
function walk(n,fn){if(!n||typeof n!=='object')return;fn(n);for(const[k,v]of Object.entries(n))if(!['start','end'].includes(k)){if(Array.isArray(v))v.forEach(x=>walk(x,fn));else if(v&&typeof v==='object')walk(v,fn);}}
function spine(n){if(n.type!=='CallExpression')return null;
 if(n.callee.name==='get'&&n.arguments[0]?.name==='G'&&n.arguments[1]?.type==='Literal')return{name:n.arguments[1].value,args:[]};
 if(!['callOwned','jump'].includes(n.callee.name)||n.arguments[1]?.type!=='ArrayExpression')return null;
 const s=spine(n.arguments[0]);return s&&{name:s.name,args:[...s.args,...n.arguments[1].elements]};}
const all=['bench','bsort','warp','warp_zip','warp_leaf','Bool.xor','warp_leaf.go','flow','warp_node','key','prng','scan','stat_join','stat_join.go','stat_out'];
const dependencies=['warp_leaf.go','Bool.xor','warp_leaf','warp_zip','warp','warp_node','flow','key','prng','bsort','scan','stat_join','stat_join.go','stat_out'];
// Helpers preserve exact primitive and ctor behavior; only the owned worker may call them.
const helpers=`\nlet $p42LeafEntries=0,$p42KeyEntries=0;\nfunction $p42Leaf(a,b,s){$P42_LEAF_COUNT const flip=s!==(a>b);return flip?ctor('Node',[ctor('Leaf',[b]),ctor('Leaf',[a])]):ctor('Node',[ctor('Leaf',[a]),ctor('Leaf',[b])]);}\nfunction $p42Key(x){$P42_KEY_COUNT let a=Math.imul((x+1)>>>0,2654435761)>>>0;a=(a^((a<<13)>>>0))>>>0;a=(a^(a>>>17))>>>0;return(a^((a<<5)>>>0))>>>0;}\n`;
function transform(variant){const edits=[],counts={leaf:0,key:0,guards:0};
 function render(n){
  // Select the admitted branch before descending. Its discarded fallback may
  // itself contain nested guards; range-based deletion would overlap them.
  if((variant==='guards'||variant==='complete')&&n.type==='ConditionalExpression'&&source.slice(n.test.start,n.test.end).startsWith('regionProof!==null&&regionProofCovers(')){
   ++counts.guards;return render(n.consequent);
  }
  const sp=spine(n);
  if(sp&&((sp.name==='warp_leaf'&&sp.args.length===3)||(sp.name==='key'&&sp.args.length===1))&&['leaf','leaf-key','complete'].includes(variant)&&!(sp.name==='key'&&variant==='leaf')){
   const kind=sp.name==='key'?'key':'leaf';++counts[kind];return `$p42${kind==='key'?'Key':'Leaf'}(${sp.args.map(render).join(',')})`;
  }
  const children=[];
  for(const [key,value]of Object.entries(n))if(!['start','end'].includes(key)){
   if(Array.isArray(value)){for(const child of value)if(child&&typeof child.type==='string')children.push(child);}
   else if(value&&typeof value.type==='string')children.push(value);
  }
  children.sort((a,b)=>a.start-b.start);let at=n.start,result='';
  for(const child of children){assert(child.start>=at,'overlapping AST children');result+=source.slice(at,child.start)+render(child);at=child.end;}
  return result+source.slice(at,n.end);
 }
 for(const worker of workers)edits.push({start:worker.body.start,end:worker.body.end,text:render(worker.body)});
 let text=source;for(const e of edits.sort((a,b)=>b.start-a.start))text=text.slice(0,e.start)+e.text+text.slice(e.end);
 if(['leaf','leaf-key','complete'].includes(variant)){assert.equal(counts.leaf,1);if(variant!=='leaf')assert.equal(counts.key,1);text+=helpers;}
 return{text,counts};}
// Retain the exact Phase41 complete-value/deep/alias diagnostic adapter by derivation.
const adapterParent=path.resolve('selfhost/tools/performance/phase41/tree/actual-derive-v2.mjs');
const adapterSource=fs.readFileSync(adapterParent,'utf8');
const adapterStart=adapterSource.indexOf('function adapters(variant){return `')+'function adapters(variant){return `'.length;
const adapterEnd=adapterSource.indexOf('`;}\n',adapterStart);assert(adapterEnd>adapterStart);
let adapter=adapterSource.slice(adapterStart,adapterEnd);
adapter=adapter.replace('${JSON.stringify(all)}',JSON.stringify(all)).replaceAll("${variant==='wrapper'?'$p41Entries':'0'}",'$p42LeafEntries+$p42KeyEntries+$p42WorkerEntries').replaceAll("${variant==='wrapper'?'$R_119_97_114_112_95_110_111_100_101$tree(t,false)':\"callOwned(callOwned(get(G,'warp_node'),[t]),[false])\"}",'$R_119_97_114_112_95_110_111_100_101$tree(t,false)');
assert(!adapter.includes('${'),'unresolved adapter interpolation');
fs.mkdirSync(out,{recursive:false});const modules=[],sites={};
for(const variant of['original','noise','leaf','leaf-key','guards','complete']){
 const derived=transform(variant);sites[variant]=derived.counts;
 for(const diagnostic of[false,true]){
  let text=derived.text.replaceAll('$P42_LEAF_COUNT',diagnostic?'++$p42LeafEntries;':'').replaceAll('$P42_KEY_COUNT',diagnostic?'++$p42KeyEntries;':'');
  if(diagnostic&&!['leaf','leaf-key','complete'].includes(variant))text+='\nlet $p42LeafEntries=0,$p42KeyEntries=0;\n';
  if(!diagnostic){text=text.replace('let $p42LeafEntries=0,$p42KeyEntries=0;','');if(['original','noise'].includes(variant))assert.equal(sha(text),sha(source));}
  if(diagnostic){const worker=parse(text).body.find(n=>n.type==='FunctionDeclaration'&&n.id.name==='$R_119_97_114_112_95_110_111_100_101$tree');assert(worker);const at=worker.body.start+1;text=text.slice(0,at)+'++$p42WorkerEntries;'+text.slice(at);text+='\nlet $p42WorkerEntries=0;\n';}
  if(diagnostic)text+=adapter+`
export function p42Leaf(a,b,s){if(!regionHostGuard()||!localGuard($p41All))throw Error('diagnostic guard');const previous=regionProofOpen($p41All);try{return ${['leaf','leaf-key','complete'].includes(variant)?'$p42Leaf(a,b,s)':"callOwned(get(G,'warp_leaf'),[a,b,s])"};}finally{regionProofClose(previous);}}
export function p42Key(x){if(!regionHostGuard()||!localGuard($p41All))throw Error('diagnostic guard');const previous=regionProofOpen($p41All);try{return ${['leaf-key','complete'].includes(variant)?'$p42Key(x)':"callOwned(get(G,'key'),[x])"};}finally{regionProofClose(previous);}}
`;
  parse(text);const file=path.join(out,variant+(diagnostic?'.mjs':'.clean.mjs'));fs.writeFileSync(file,text,{flag:'wx'});modules.push({variant,diagnostic,...identity(file)});
 }
}
const report={kind:'phase42-tree-direct-calls-ablation',complete:true,checked:false,producer:identity(import.meta.filename),parent:identity(input),receipt:identity(input+'.json'),typescript:identity(ts),adapterParent:identity(adapterParent),parserSha256:sha(ps),dependencies,sites,modules};
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-derive.mjs'));fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
const catalog=JSON.parse(fs.readFileSync('selfhost/tools/performance/phase37/catalog.json'));
const cases=catalog.cases.filter(c=>['variation-tree-bitonic-6-17','tree-bitonic','variation-tree-bitonic-9-123'].includes(c.id)).map(c=>({id:c.id,point:c.point,modules:Object.fromEntries([...['original','noise','leaf','leaf-key','guards','complete'].map(v=>[v,path.join(out,v+'.clean.mjs')]),['typescript',ts]])}));assert.equal(cases.length,3);
fs.writeFileSync(path.join(out,'compare.json'),JSON.stringify({inputs:[path.join(out,'derive.json'),input,ts],cases},null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:true,out,sites}));
