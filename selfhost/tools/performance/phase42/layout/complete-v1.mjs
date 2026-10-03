// Bounded architecture ceiling: direct private graph, same Bend algorithm,
// BigInt Nat, named fields, native recursion. Not a compiler source proposal.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [sourceArg,outArg]=process.argv.slice(2);assert(sourceArg&&outArg);
const source=fs.readFileSync(sourceArg,'utf8'),out=path.resolve(outArg);
const sha=x=>createHash('sha256').update(x).digest('hex');
assert.equal(sha(source),'64bfc698048c2ebf92c123111a5ce3fd8ccdb47b2fd8a7488243adbd1c2f6e9d');
assert(!fs.existsSync(out));
const guards=['bench','bsort','warp','warp_zip','warp_leaf','Bool.xor','warp_leaf.go','flow','warp_node','key','prng','scan','stat_join','stat_join.go','stat_out'];
const graph=`
function $p42Leaf(v){return {$:'Leaf',v};}
function $p42Node(l,r){return {$:'Node',l,r};}
function $p42Key(x){x=Math.imul((x+1)>>>0,2654435761)>>>0;const b=(x^(x<<13))>>>0;const d=(b^(b>>>17))>>>0;return(d^(d<<5))>>>0;}
function $p42WarpLeaf(x,y,s){return (s!==(x>y))?$p42Node($p42Leaf(y),$p42Leaf(x)):$p42Node($p42Leaf(x),$p42Leaf(y));}
function $p42WarpZip(wa,wb){return wa.$==='Node'&&wb.$==='Node'?$p42Node($p42Node(wa.l,wb.l),$p42Node(wa.r,wb.r)):$p42Leaf(0);}
function $p42Warp(a,b,s){if(a.$==='Leaf'&&b.$==='Leaf')return $p42WarpLeaf(a.v,b.v,s);if(a.$==='Node'&&b.$==='Node'){const wa=$p42Warp(a.l,b.l,s),wb=$p42Warp(a.r,b.r,s);return $p42WarpZip(wa,wb);}return $p42Leaf(0);}
function $p42WarpNode(t,s){return t.$==='Leaf'?$p42Leaf(t.v):$p42Warp(t.l,t.r,s);}
function $p42Flow(d,s,w){if(w.$==='Leaf')return $p42Leaf(w.v);if(d===0n)return $p42Node(w.l,w.r);const p=d-1n;const fa=$p42Flow(p,s,$p42WarpNode(w.l,s)),fb=$p42Flow(p,s,$p42WarpNode(w.r,s));return $p42Node(fa,fb);}
function $p42Bsort(d,s,x){if(d===0n)return $p42Leaf($p42Key(x));const p=d-1n;const sa=$p42Bsort(p,false,(((x<<1)>>>0)+1)>>>0),sb=$p42Bsort(p,true,(x<<1)>>>0);return $p42Flow(p,s,$p42Warp(sa,sb,s));}
function $p42Stat(lo,hi,ok,mx){return {$:'St',lo,hi,ok,mx};}
function $p42StatJoin(a,b){return $p42Stat(a.lo,b.hi,a.hi<=b.lo?(a.ok&b.ok)>>>0:0,(Math.imul(a.mx,2654435761)+b.mx)>>>0);}
function $p42Scan(t){if(t.$==='Leaf')return $p42Stat(t.v,t.v,1,t.v);const l=$p42Scan(t.l),r=$p42Scan(t.r);return $p42StatJoin(l,r);}
function $p42StatOut(s){return (((Math.imul(s.mx,2654435761)>>>0)^((s.hi+Math.imul(s.lo,340573321))>>>0))+Math.imul(s.ok,2246822519))>>>0;}
function $p42Bench(d,x){return $p42StatOut($p42Scan($p42Bsort(d,false,x)));}
`;
const rootAt=source.indexOf('G["bench"]=');assert(rootAt>0);
const tryAt=source.indexOf('try{const x3534=$s0;const x3535=$s1;return ',rootAt),finallyAt=source.indexOf('}finally{regionProofClose($previousProof);}',tryAt);assert(tryAt>rootAt&&finallyAt>tryAt);
let complete=source.slice(0,tryAt)+'try{return $p42Bench(BigInt($s0),$s1);'+source.slice(finallyAt);
const rootGuard=complete.indexOf('if($entered&&regionHostGuard()',rootAt);assert(rootGuard>0);
complete=complete.slice(0,rootGuard)+complete.slice(rootGuard).replace('if($entered&&regionHostGuard()','if($s0<=12&&$entered&&regionHostGuard()');
complete+='\n'+graph;
const worker=name=>'$R'+Array.from(name,c=>'_'+c.codePointAt(0)).join('')+'$tree';
function diagnostic(role){return `
export function p42ProofActive(){return regionProof!==null;}
export function p42Complete(d,x,s=false){if(!Number.isInteger(d)||d<0||d>12||!Number.isInteger(x)||x<0||x>4294967295||typeof s!=='boolean')throw Error('diagnostic domain');const guards=${JSON.stringify(guards)};if(!regionHostGuard()||!localGuard(guards))throw Error('diagnostic guard');const old=regionProofOpen(guards);try{const tree=${role==='complete'?'$p42Bsort':' '+worker('bsort')}(BigInt(d),s,x);return {tree,stat:${role==='complete'?'$p42Scan':worker('scan')}(tree)};}finally{regionProofClose(old);}}
${role==='complete'?`export function p42FlowOwned(n,t,s){return $p42Flow(BigInt(n),s,t);}export function p42WarpOwned(a,b,s){return $p42Warp(a,b,s);}`:''}
`}
const native=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],am={exports:{}};new Function('module','exports',native)(am,am.exports);
const parse=s=>am.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
// Private graph has no runtime dispatch, membership, or region proof operations.
assert(!/callOwned|invokeExact|regionProof|WeakSet|ctor\(|build\(|get\(G/.test(graph));
fs.mkdirSync(out,{recursive:false});
const modules=[];for(const[role,text]of[['original',source],['complete',complete]])for(const[diagnosticFlag,suffix]of[[false,'.clean.mjs'],[true,'.mjs']]){const data=text+(diagnosticFlag?diagnostic(role):'');parse(data);const file=role+suffix;fs.writeFileSync(path.join(out,file),data,{flag:'wx'});modules.push({file,sha256:sha(data)});}
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-complete-v1.mjs'));
fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify({kind:'phase42-complete-private-ceiling',checked:false,complete:true,input:{path:fs.realpathSync(sourceArg),sha256:sha(source)},producer:{path:fs.realpathSync(import.meta.filename),sha256:sha(fs.readFileSync(import.meta.filename))},modules,maxDepth:12,scope:'Manual private whole graph with named objects and native recursion. Existing closed scalar entry guards and public fallback retained. Same Bend algorithm; BigInt Nat. No compiler ownership/deep-stack proof.'},null,2)+'\n');console.log(JSON.stringify({out,complete:true,checked:false,maxDepth:12}));
