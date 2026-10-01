// Saved-JS causal ablation on checked03. Root executes; no compiler admission claim.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [inputArg,typescriptArg,outArg]=process.argv.slice(2);
assert(inputArg&&typescriptArg&&outArg,'usage: component-tree-derive.mjs CHECKED03_TREE TYPESCRIPT_TREE NEW_OUT');
const input=fs.realpathSync(inputArg),typescript=fs.realpathSync(typescriptArg),out=path.resolve(outArg);
assert(!fs.existsSync(out),'output must be new');
const hash=x=>createHash('sha256').update(x).digest('hex');
const identity=file=>({path:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const observed=[];
function verify(row){const p=row.canonicalPath??row.file??row.path;assert(p&&row.sha256);const actual=identity(p);assert.equal(actual.sha256,row.sha256,p);observed.push(actual);return actual;}
function receipt(file,kind){const receiptFile=file+'.json',r=JSON.parse(fs.readFileSync(receiptFile));observed.push(identity(receiptFile));
 assert.equal(r.kind,'bend-program-checked-emission');assert.equal(r.complete,true);assert.equal(r.compiler.kind,kind);
 assert.equal(r.observation.status,'ok');assert.equal(r.observation.checked,true);assert.equal(r.compiler.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
 assert.equal(verify(r.output).sha256,identity(file).sha256);verify(r.input);verify(r.producer);verify(r.catalog);r.verifiers.forEach(verify);
 if(kind==='checked-development-attempt'){
  assert.equal(r.observation.typeAccepted,true);assert.equal(r.compiler.api.sha256,'ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1');
  assert.equal(r.attempt.sha256,'7ae878dda1b75dce1655c62d8e7238e184319da1fa04a8a12a189f37badc8f85');verify(r.attempt);
  for(const key of ['api','runtime','base','driver'])verify(r.compiler[key]);
 }else r.compiler.sources.forEach(verify);
 return r;
}
const receiptB=receipt(input,'checked-development-attempt'),receiptT=receipt(typescript,'checked-pinned-typescript');
assert.equal(receiptB.input.sha256,receiptT.input.sha256);
const source=fs.readFileSync(input,'utf8');
assert.equal(hash(source),'6a2fa33ad65b2fedfc8afe7dfa96a427cddec5ab2a9b5587385b1325b2d9b534');
assert.equal(identity(typescript).sha256,'c24fff66dd20c4579b7912b42450f1574e4c0b7a84e5d8b2d3d1d1345ef2b159');
const names=['bench','prng','key','warp_leaf.go','warp_leaf','warp_zip','warp','warp_node','flow','bsort','stat_join.go','stat_join','scan','stat_out','Bool.xor'];
const warpCall=/(callOwned|jump)\(callOwned\(callOwned\(get\(G,"warp"\),\[(x\d+)\]\),\[(x\d+)\]\),\[(x\d+)\]\)/g;
const sites=[...source.matchAll(warpCall)];assert.equal(sites.length,4);assert.equal(sites.filter(m=>m[1]==='callOwned').length,3);
assert.equal(source.split('/* private finite root */').length,2);
const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'];
const parserModule={exports:{}};new Function('module','exports',parserSource)(parserModule,parserModule.exports);
assert.equal(parserModule.exports.version,'8.16.0');
const parse=s=>parserModule.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
function additions(variant,counters){const direct=variant!=='original',leaf=variant==='component';return `
// Manually reviewed private component; not compiler-generated admission evidence.
const $p37Names=${JSON.stringify(names)};
${counters?'const $p37Counts={root:0,zip:0,warp:0,leaf:0};':''}
function $p37Covered(){return regionProof!==null&&regionProofCovers($p37Names);}
function $p37Zip(a,b){${counters?'++$p37Counts.zip;':''}
 if(a.$==='Node'&&b.$==='Node')return {$:'Node',a:[{$:'Node',a:[a.a[0],b.a[0]]},{$:'Node',a:[a.a[1],b.a[1]]}]};return {$:'Leaf',a:[0]};}
function $p37Leaf(x,y,s){${counters?'++$p37Counts.leaf;':''}
 const reverse=s!==(x>y);return {$:'Node',a:[{$:'Leaf',a:[reverse?y:x]},{$:'Leaf',a:[reverse?x:y]}]};}
function $p37Warp(a,b,s){${counters?'++$p37Counts.warp;':''}
 const frames=[];let top=0,value;
 visit:for(;;){if(a.$==='Node'&&b.$==='Node'){
  let frame=top<frames.length?frames[top]:null;if(!frame)frame=frames[top]={a:null,b:null,left:null,phase:0};
  frame.a=a.a[1];frame.b=b.a[1];frame.left=null;frame.phase=0;++top;a=a.a[0];b=b.a[0];continue visit;
 }
 value=a.$==='Leaf'&&b.$==='Leaf'?${leaf?'$p37Leaf(a.a[0],b.a[0],s)':"callOwned(get(G,'warp_leaf'),[a.a[0],b.a[0],s])"}:{$:'Leaf',a:[0]};
 while(top){const frame=frames[top-1];if(frame.phase===0){frame.left=value;frame.phase=1;a=frame.a;b=frame.b;continue visit;}
  value=$p37Zip(frame.left,value);--top;
 }return value;}}
${counters?`
// Diagnostic owned inputs only; public foreign trees never open this proof.
function $p37Tree(depth,seed,shared){if(depth===0)return {$:'Leaf',a:[seed]};const child=$p37Tree(depth-1,(seed*3+1)>>>0,shared);
 return {$:'Node',a:[child,shared?child:$p37Tree(depth-1,(seed*5+7)>>>0,shared)]};}
function $p37FreezeTree(t){Object.freeze(t.a);Object.freeze(t);if(t.$==='Node'){$p37FreezeTree(t.a[0]);$p37FreezeTree(t.a[1]);}return t;}
function $p37Guard(){return regionProof===null&&regionHostGuard()&&localGuard($p37Names);}
export function privateWarpPoint(depthA,depthB,x,y,s,sharing=0){
 if(!Number.isInteger(depthA)||depthA<0||depthA>12||!Number.isInteger(depthB)||depthB<0||depthB>12||
 !Number.isInteger(x)||x<0||x>4294967295||!Number.isInteger(y)||y<0||y>4294967295||typeof s!=='boolean'||![0,1,2].includes(sharing))throw Error('diagnostic scalar domain');
 const a=$p37FreezeTree($p37Tree(depthA,x,sharing===1)),b=sharing===2?a:$p37FreezeTree($p37Tree(depthB,y,sharing===1));
 if($p37Guard()){const previous=regionProofOpen($p37Names);try{return ${direct?'$p37Warp(a,b,s)':"call(get(G,'warp'),[a,b,s])"};}finally{regionProofClose(previous);}}
 return call(get(G,'warp'),[a,b,s]);}
export function privateZipPoint(){const shared={$:'Leaf',a:[17]},other={$:'Leaf',a:[23]},a={$:'Node',a:[shared,other]},b={$:'Node',a:[other,shared]};let value;
 if($p37Guard()){const previous=regionProofOpen($p37Names);try{value=${direct?'$p37Zip(a,b)':"call(get(G,'warp_zip'),[a,b])"};}finally{regionProofClose(previous);}}
 else value=call(get(G,'warp_zip'),[a,b]);
 return {value,aliases:[value.a[0].a[0]===shared,value.a[0].a[1]===other,value.a[1].a[0]===other,value.a[1].a[1]===shared]};}
export function privateDeepPoint(depth){if(!${direct}||!Number.isInteger(depth)||depth<0||depth>30000)throw Error('diagnostic deep domain');
 const leaf=Object.freeze({$:'Leaf',a:Object.freeze([7])});let a=leaf;for(let i=0;i<depth;i++)a=Object.freeze({$:'Node',a:Object.freeze([a,leaf])});
 if(!$p37Guard())throw Error('diagnostic deep guard');const previous=regionProofOpen($p37Names);try{return $p37Warp(a,a,false);}finally{regionProofClose(previous);}}
export function privateEntryCounts(){return {...$p37Counts};}
export function privateProofActive(){return regionProof!==null;}
`:''}
`;}
fs.mkdirSync(out,{recursive:false});
const report={kind:'phase39-private-tree-prototype',complete:false,checked:false,certified:false,node:process.version,
 producer:identity(import.meta.filename),parent:identity(input),typescript:identity(typescript),receipts:[identity(input+'.json'),identity(typescript+'.json')],
 verifiedInputs:observed,parserSha256:hash(parserSource),dependencies:names,modules:[],
 scope:'Saved-JS rebase on checked03; original scalar proof entry retained byte-for-byte in clean variants. Four saturated warp sites get guarded direct calls. Not compiler admission evidence.'};
for(const counters of [true,false])for(const variant of ['original','warp','component']){
 let text=source;
 if(variant!=='original')text=text.replace(warpCall,(full,transfer,a,b,s)=>`($p37Covered()?$p37Warp(${a},${b},${s}):${full})`);
 if(counters)text=text.replace('/* private finite root */','/* private finite root */++$p37Counts.root;');
 if(counters||variant!=='original')text+=additions(variant,counters);
 parse(text);const file=path.join(out,variant+(counters?'.mjs':'.clean.mjs'));fs.writeFileSync(file,text,{flag:'wx'});
 if(!counters&&variant==='original')assert.equal(hash(text),hash(source));
 if(!counters)assert(!text.includes('$p37Counts'),'timed module has no counters');
 report.modules.push({variant,counters,...identity(file),bytes:Buffer.byteLength(text)});
}
for(const row of observed)assert.deepEqual(identity(row.path),row);
report.complete=true;fs.copyFileSync(import.meta.filename,path.join(out,'consumed-derive.mjs'));
fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
const config={inputs:[path.join(out,'derive.json'),input,typescript],cases:[{id:'tree-bitonic',point:{exportName:'bench',args:[8,0],expected:971629740},
 modules:Object.fromEntries([...['original','warp','component'].map(v=>[v,path.join(out,v+'.clean.mjs')]),['typescript',typescript]])}]};
fs.writeFileSync(path.join(out,'compare.json'),JSON.stringify(config,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,certified:false,out,modules:report.modules.length}));
