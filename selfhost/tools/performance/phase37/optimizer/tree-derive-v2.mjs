// Saved-output hypothesis only. Root owns all execution and measurement.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [inputArg,typescriptArg,outArg]=process.argv.slice(2);
assert(inputArg&&typescriptArg&&outArg,'usage: tree-derive.mjs PHASE36_TREE.mjs TYPESCRIPT_TREE.mjs NEW_OUT');
const input=fs.realpathSync(inputArg),typescript=fs.realpathSync(typescriptArg),out=path.resolve(outArg);
assert(!fs.existsSync(out),'output must be new');
const hash=x=>createHash('sha256').update(x).digest('hex');
const identity=file=>({path:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const source=fs.readFileSync(input,'utf8');
assert.equal(hash(source),'6ba1adf3a5ba6aeae722f63dd16adef0a32ff846027d563fcd322c428cdff696','frozen Phase36 tree required');
const names=['bench','prng','key','warp_leaf.go','warp_leaf','warp_zip','warp','warp_node','flow','bsort','stat_join.go','stat_join','scan','stat_out','Bool.xor'];
const zip='jump(callOwned(get(G,"warp_zip"),[x3464]),[x3465])';
assert.equal(source.split(zip).length,2);
const leaf='jump(get(G,"warp_leaf"),[x3451,x3452,x3453,])';
assert.equal(source.split(leaf).length,2);
const warpCall=/(callOwned|jump)\(callOwned\(callOwned\(get\(G,"warp"\),\[(x\d+)\]\),\[(x\d+)\]\),\[(x\d+)\]\)/g;
assert.equal([...source.matchAll(warpCall)].length,4);
assert.equal([...source.matchAll(warpCall)].filter(m=>m[1]==='callOwned').length,3);
assert.equal([...source.matchAll(warpCall)].filter(m=>m[1]==='jump').length,1);
const rootLine=source.split('\n').find(line=>line.startsWith('G["bench"]='));
const rootMatch=rootLine.match(/^G\["bench"\]=scalarCapture\("bench",fn\(2,function\(a\)\{const x3534=a\[0\];const x3535=a\[1\];return (.*);\}\)\);$/);
assert(rootMatch,'frozen root structure');
const rootExpression=rootMatch[1];
const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'];
const parserModule={exports:{}};new Function('module','exports',parserSource)(parserModule,parserModule.exports);
assert.equal(parserModule.exports.version,'8.16.0');
const parse=s=>parserModule.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
function additions(variant,counters){
 const zipOn=variant!=='guard',warpOn=['warp','component'].includes(variant),leafOn=['finite','component'].includes(variant);
 return `
// Manually reviewed closed graph: this is NOT compiler admission evidence.
scalarCapture('Bool.xor',G['Bool.xor']);
const $p37Names=${JSON.stringify(names)};
${counters?'const $p37Counts={root:0,zip:0,warp:0,leaf:0};':''}
function $p37Covered(){return regionProofCovers($p37Names);}
function $p37Zip(a,b){${counters?'++$p37Counts.zip;':''}
 if(a.$==='Node'&&b.$==='Node')return {$:'Node',a:[{$:'Node',a:[a.a[0],b.a[0]]},{$:'Node',a:[a.a[1],b.a[1]]}]};
 return {$:'Leaf',a:[0]};}
function $p37Leaf(x,y,s){${counters?'++$p37Counts.leaf;':''}
 const reverse=s!==(x>y);return {$:'Node',a:[{$:'Leaf',a:[reverse?y:x]},{$:'Leaf',a:[reverse?x:y]}]};}
function $p37Warp(a,b,s){${counters?'++$p37Counts.warp;':''}
 const frames=[];let top=0,value;
 visit:for(;;){
  if(a.$==='Node'&&b.$==='Node'){
   let frame=top<frames.length?frames[top]:null;
   if(!frame)frame=frames[top]={a:null,b:null,left:null,phase:0};
   frame.a=a.a[1];frame.b=b.a[1];frame.left=null;frame.phase=0;++top;
   a=a.a[0];b=b.a[0];continue visit;
  }
  value=a.$==='Leaf'&&b.$==='Leaf'?${leafOn?'$p37Leaf(a.a[0],b.a[0],s)':"callOwned(get(G,'warp_leaf'),[a.a[0],b.a[0],s])"}:{$:'Leaf',a:[0]};
  while(top){const frame=frames[top-1];
   if(frame.phase===0){frame.left=value;frame.phase=1;a=frame.a;b=frame.b;continue visit;}
   value=$p37Zip(frame.left,value);--top;
  }return value;
 }
}
// A scalar diagnostic owns these trees; no public tree argument enters a proof.
function $p37Tree(depth,seed,shared){if(depth===0)return {$:'Leaf',a:[seed]};
 const child=$p37Tree(depth-1,(seed*3+1)>>>0,shared);
 return {$:'Node',a:[child,shared?child:$p37Tree(depth-1,(seed*5+7)>>>0,shared)]};}
function $p37FreezeTree(t){Object.freeze(t.a);Object.freeze(t);if(t.$==='Node'){$p37FreezeTree(t.a[0]);$p37FreezeTree(t.a[1]);}return t;}
function $p37Guard(){return regionHostGuard()&&localGuard($p37Names);}
export function privateWarpPoint(depthA,depthB,x,y,s,sharing=0){
 if(!Number.isInteger(depthA)||depthA<0||depthA>12||!Number.isInteger(depthB)||depthB<0||depthB>12||
  !Number.isInteger(x)||x<0||x>4294967295||!Number.isInteger(y)||y<0||y>4294967295||typeof s!=='boolean'||![0,1,2].includes(sharing))throw Error('diagnostic scalar domain');
 const a=$p37FreezeTree($p37Tree(depthA,x,sharing===1));
 const b=sharing===2?a:$p37FreezeTree($p37Tree(depthB,y,sharing===1));
 if(${zipOn}&&$p37Guard()){const previous=regionProofOpen($p37Names);try{return ${warpOn?"$p37Warp(a,b,s)":"call(get(G,'warp'),[a,b,s])"};}finally{regionProofClose(previous);}}
 return call(get(G,'warp'),[a,b,s]);
}
export function privateZipPoint(){
 const shared={$:'Leaf',a:[17]},other={$:'Leaf',a:[23]},a={$:'Node',a:[shared,other]},b={$:'Node',a:[other,shared]};
 let value;
 if(${zipOn}&&$p37Guard()){const previous=regionProofOpen($p37Names);try{value=$p37Zip(a,b);}finally{regionProofClose(previous);}}
 else value=call(get(G,'warp_zip'),[a,b]);
 return {value,aliases:[value.a[0].a[0]===shared,value.a[0].a[1]===other,value.a[1].a[0]===other,value.a[1].a[1]===shared]};
}
${counters?'export function privateEntryCounts(){return {...$p37Counts};}':''}
`;
}
fs.mkdirSync(out,{recursive:false});
const report={kind:'phase37-private-tree-prototype',successor:{parent:identity(path.join(import.meta.dirname,'tree-derive.mjs')),reason:'v1 expected four callOwned sites but one of the four saturated warp sites is a tail jump; v2 validates three callOwned plus one jump explicitly'},complete:false,checked:false,certified:false,node:process.version,
 producer:identity(import.meta.filename),parent:identity(input),typescript:identity(typescript),parserSha256:hash(parserSource),dependencies:names,modules:[],
 scope:'Saved-JS ablation. Hand-reviewed whole scalar bench boundary plus explicit native Bool.xor snapshot. Generic public tree functions/stages remain; private operations run only inside the guard. This does not establish compiler admission.'};
for(const counters of [true,false])for(const variant of ['original','guard','zip','finite','warp','component']){
 let text=source;
 if(['zip','finite'].includes(variant))text=text.replace(zip,`($p37Covered()?$p37Zip(x3464,x3465):${zip})`);
 if(variant==='finite')text=text.replace(leaf,`($p37Covered()?$p37Leaf(x3451,x3452,x3453):${leaf})`);
 if(['warp','component'].includes(variant))text=text.replace(warpCall,(full,transfer,a,b,s)=>`($p37Covered()?$p37Warp(${a},${b},${s}):${full})`);
 if(variant!=='original'){
  const replacement=`G["bench"]=scalarCapture("bench",fn(2,exactCode(function(a,$entered){const x3534=a[0];const x3535=a[1];
   if($entered&&regionHostGuard()&&typeof x3534==='number'&&Number.isInteger(x3534)&&x3534>=0&&x3534<=4294967295&&
    typeof x3535==='number'&&Number.isInteger(x3535)&&x3535>=0&&x3535<=4294967295&&localGuard($p37Names)){
    ${counters?'++$p37Counts.root;':''}const previous=regionProofOpen($p37Names);
    try{return force(${rootExpression});}finally{regionProofClose(previous);}
   }return ${rootExpression};})));`;
  text=text.replace(rootLine,replacement)+additions(variant,counters);
 }
 parse(text);const file=path.join(out,variant+(counters?'.mjs':'.clean.mjs'));
 fs.writeFileSync(file,text,{flag:'wx'});
 report.modules.push({variant,counters,...identity(file),bytes:Buffer.byteLength(text)});
}
assert.deepEqual(identity(input),report.parent);report.complete=true;
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-derive.mjs'));
fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
const config={inputs:[path.join(out,'derive.json'),input,typescript],cases:[{id:'tree-bitonic',point:{exportName:'bench',args:[8,0],expected:971629740},
 modules:Object.fromEntries([...['original','guard','zip','finite','warp','component'].map(v=>[v,path.join(out,v+'.clean.mjs')]),['typescript',typescript]])}]};
fs.writeFileSync(path.join(out,'compare.json'),JSON.stringify(config,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,certified:false,out,modules:report.modules.length}));
