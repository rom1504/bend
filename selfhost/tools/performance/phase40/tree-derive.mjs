// Saved-output only: exact checked05 bytes; root executes all jobs.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [inputArg,tsArg,outArg]=process.argv.slice(2);
assert(inputArg&&tsArg&&outArg,'usage: tree-derive.mjs CHECKED05_TREE TS_TREE NEW_OUT');
const input=fs.realpathSync(inputArg),ts=fs.realpathSync(tsArg),out=path.resolve(outArg);
assert(!fs.existsSync(out));
const sha=x=>createHash('sha256').update(x).digest('hex');
const identity=p=>({path:fs.realpathSync(p),sha256:sha(fs.readFileSync(p))});
const source=fs.readFileSync(input,'utf8');
assert.equal(sha(source),'c0695bb8e900c1855d159b4b9533e50d6c76eb04baa344ecb74c0be62e89d0c5');
const receipt=JSON.parse(fs.readFileSync(input+'.json'));
assert.equal(receipt.complete,true);assert.equal(receipt.observation.checked,true);
assert.equal(receipt.compiler.api.sha256,'04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f');
assert.equal(receipt.output.sha256,sha(source));
const ps=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],pm={exports:{}};
new Function('module','exports',ps)(pm,pm.exports);assert.equal(pm.exports.version,'8.16.0');
const parse=s=>pm.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),ast=parse(source);
const names=['stat_out','stat_join.go','stat_join','scan','prng','key','warp_node','flow','warp_leaf.go','Bool.xor','warp_leaf','warp_zip','warp','bsort','bench'];
function spine(n){if(n.type!=='CallExpression')return null;
 if(n.callee.name==='get'&&n.arguments[0]?.name==='G'&&n.arguments[1]?.type==='Literal')return {name:n.arguments[1].value,args:[]};
 if(!['callOwned','jump'].includes(n.callee.name)||n.arguments[1]?.type!=='ArrayExpression')return null;
 const s=spine(n.arguments[0]);return s&&{name:s.name,args:[...s.args,...n.arguments[1].elements]};}
const sites=[];function walk(n){if(!n||typeof n!=='object')return;
 if(n.type==='CallExpression'){const s=spine(n);if(s&&((s.name==='flow'&&s.args.length===3)||(s.name==='warp_leaf'&&s.args.length===3)))sites.push({...s,start:n.start,end:n.end});}
 for(const [k,v]of Object.entries(n))if(!['start','end'].includes(k)){if(Array.isArray(v))v.forEach(walk);else if(v&&typeof v==='object')walk(v);}}
walk(ast);assert.equal(sites.filter(s=>s.name==='flow').length,3);assert.equal(sites.filter(s=>s.name==='warp_leaf').length,2);
function additions(variant,diagnostic){const leaf=['leaf','complete'].includes(variant);return `
// Phase40 private component model; generic public entries stay unchanged.
const $p40Names=${JSON.stringify(names)};
${diagnostic?'const $p40Counts={flow:0,leaf:0,root:0};':''}
function $p40Covered(){return regionProof!==null&&regionProofCovers($p40Names);}
function $p40Leaf(x,y,s){${diagnostic?'++$p40Counts.leaf;':''}
 const reverse=s!==(x>y);return ctor('Node',[ctor('Leaf',[reverse?y:x]),ctor('Leaf',[reverse?x:y])]);}
function $p40WarpNode(t,s){if(t.$==='Leaf')return ctor('Leaf',[t.a[0]]);
 if(t.$==='Node')return $R_119_97_114_112$tree(t.a[0],t.a[1],s);return bad('private flow prefix invariant');}
function $p40Flow(n,s,t){${diagnostic?'++$p40Counts.flow;':''}
 const frames=[];let top=0,value;
 visit:for(;;){
  if(n===0n){if(t.$==='Leaf')value=ctor('Leaf',[t.a[0]]);else if(t.$==='Node')value=ctor('Node',[t.a[0],t.a[1]]);else return bad('private flow prefix invariant');}
  else if(t.$==='Leaf')value=ctor('Leaf',[t.a[0]]);
  else if(t.$==='Node'){
   let frame=top<frames.length?frames[top]:null;if(!frame)frame=frames[top]={args:null,left:null,phase:0};
   frame.args=[n,s,t];frame.left=null;frame.phase=0;++top;
   const next=$p40WarpNode(t.a[0],s);n=n-1n;t=next;continue visit;
  }else return bad('private flow prefix invariant');
  while(top){const frame=frames[top-1];n=frame.args[0];s=frame.args[1];t=frame.args[2];
   if(t.$!=='Node'||n===0n)return bad('private flow continuation invariant');
   if(frame.phase===0){frame.left=value;frame.phase=1;const next=$p40WarpNode(t.a[1],s);n=n-1n;t=next;continue visit;}
   value=ctor('Node',[frame.left,value]);--top;
  }return value;
 }
}
${diagnostic?`
function $p40Tree(d,x,sharing,irregular){if(d===0)return ctor('Leaf',[x]);const a=$p40Tree(d-1,(x*3+1)>>>0,sharing,irregular);
 return ctor('Node',[a,sharing?a:$p40Tree(irregular&&d%2===0?0:d-1,(x*5+7)>>>0,sharing,irregular)]);}
function $p40Guard(){return regionProof===null&&regionHostGuard()&&localGuard($p40Names);}
export function privateFlowPoint(n,d,seed,s,sharing=0,irregular=0){
 assertDiagnostic(n,d,seed,s,sharing,irregular);const t=$p40Tree(d,seed,!!sharing,!!irregular);
 if($p40Guard()){const prev=regionProofOpen($p40Names);try{return ${['flow','complete'].includes(variant)?'$p40Flow(BigInt(n),s,t)':"call(get(G,'flow'),[BigInt(n),s,t])"};}finally{regionProofClose(prev);}}
 return call(get(G,'flow'),[BigInt(n),s,t]);}
function assertDiagnostic(n,d,seed,s,sharing,irregular){if(!Number.isInteger(n)||n<0||n>16||!Number.isInteger(d)||d<0||d>10||!Number.isInteger(seed)||seed<0||seed>4294967295||typeof s!=='boolean'||![0,1].includes(sharing)||![0,1].includes(irregular))throw Error('diagnostic scalar domain');}
export function privateZeroAliases(){const a=ctor('Leaf',[7]),b=ctor('Leaf',[11]),t=ctor('Node',[a,b]);if(!$p40Guard())throw Error('guard');const prev=regionProofOpen($p40Names);
 try{const r=${['flow','complete'].includes(variant)?'$p40Flow(0n,false,t)':"call(get(G,'flow'),[0n,false,t])"};return [r!==t,r.a[0]===a,r.a[1]===b];}finally{regionProofClose(prev);}}
export function privateDeepPoint(depth){if(!${['flow','complete'].includes(variant)}||!Number.isInteger(depth)||depth<0||depth>30000)throw Error('deep domain');
 const leaf=ctor('Leaf',[7]);let t=leaf;for(let i=0;i<depth;i++)t=ctor('Node',[t,leaf]);if(!$p40Guard())throw Error('deep guard');const prev=regionProofOpen($p40Names);
 try{return $p40Flow(1n,false,ctor('Node',[ctor('Node',[t,t]),ctor('Node',[t,t])]));}finally{regionProofClose(prev);}}
export function privateEntryCounts(){return {...$p40Counts};}
export function privateProofActive(){return regionProof!==null;}
`:''}
`;}
fs.mkdirSync(out,{recursive:false});
const report={kind:'phase40-tree-prototype',complete:false,checked:false,certified:false,node:process.version,
 producer:identity(import.meta.filename),parent:identity(input),typescript:identity(ts),receipts:[identity(input+'.json'),identity(ts+'.json')],parserSha256:sha(ps),dependencies:names,sites:sites.map(({name,start,end})=>({name,start,end})),modules:[]};
for(const diagnostic of [false,true])for(const variant of ['original','noise','leaf','flow','complete']){
 let text=source;const selected=sites.filter(s=>(['leaf','complete'].includes(variant)&&s.name==='warp_leaf')||(['flow','complete'].includes(variant)&&s.name==='flow'));
 for(const s of selected.sort((a,b)=>b.start-a.start)){const args=s.args.map(a=>source.slice(a.start,a.end)).join(','),old=source.slice(s.start,s.end);
  text=text.slice(0,s.start)+`($p40Covered()?${s.name==='flow'?'$p40Flow':'$p40Leaf'}(${args}):${old})`+text.slice(s.end);}
 if(diagnostic)text=text.replace('/* private finite root */','/* private finite root */++$p40Counts.root;');
 if(diagnostic||!['original','noise'].includes(variant))text+=additions(variant,diagnostic);
 parse(text);const file=path.join(out,variant+(diagnostic?'.mjs':'.clean.mjs'));fs.writeFileSync(file,text,{flag:'wx'});
 if(!diagnostic&&['original','noise'].includes(variant))assert.equal(sha(text),sha(source));
 report.modules.push({variant,counters:diagnostic,...identity(file),bytes:Buffer.byteLength(text)});
}
report.complete=true;fs.copyFileSync(import.meta.filename,path.join(out,'consumed-derive.mjs'));fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
const points=[['tree6',6,17,2741940691],['tree8',8,0,971629740],['tree9',9,123,0]];
// Expected values come from the frozen catalog, never candidate execution.
const catalog=JSON.parse(fs.readFileSync('selfhost/tools/performance/phase37/catalog.json'));
const cases=catalog.cases.filter(c=>['variation-tree-bitonic-6-17','tree-bitonic','variation-tree-bitonic-9-123'].includes(c.id)).map(c=>({id:c.id,point:c.point,modules:Object.fromEntries([...['original','noise','leaf','flow','complete'].map(v=>[v,path.join(out,v+'.clean.mjs')]),['typescript',ts]])}));
assert.equal(cases.length,3);fs.writeFileSync(path.join(out,'compare.json'),JSON.stringify({inputs:[path.join(out,'derive.json'),input,ts],cases},null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,out,sites:report.sites,modules:report.modules.length}));
