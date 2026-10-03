// Exact saved-output representation ablation. No compiler source change.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [sourceArg,outArg]=process.argv.slice(2);
assert(sourceArg&&outArg,'usage: derive.mjs PHASE41_TREE_MODULE NEW_OUT');
const source=fs.readFileSync(sourceArg,'utf8'),out=path.resolve(outArg);
const sha=x=>createHash('sha256').update(x).digest('hex');
assert.equal(sha(source),'64bfc698048c2ebf92c123111a5ce3fd8ccdb47b2fd8a7488243adbd1c2f6e9d','must use final Phase41 tree');
const acornSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],am={exports:{}};
new Function('module','exports',acornSource)(am,am.exports);
const parse=s=>am.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
function walk(n,fn){if(!n||typeof n!=='object')return;fn(n);for(const[k,v]of Object.entries(n))if(!['start','end'].includes(k)){if(Array.isArray(v))v.forEach(x=>walk(x,fn));else if(v&&typeof v==='object')walk(v,fn);}}
const ast=parse(source),edits=[],counts={constructors:0,slots:0};
const generatedStart=source.indexOf('G["prng"]');assert(generatedStart>0);
walk(ast,n=>{
 if(n.start<generatedStart)return;
 if(n.type==='CallExpression'&&n.callee.name==='ctor'&&['Leaf','Node','St'].includes(n.arguments[0]?.value)){
  const fields=n.arguments[1];assert.equal(fields.type,'ArrayExpression');assert(fields.elements.every(Boolean));
  edits.push({start:n.start,end:fields.start+1,text:'$p42'+n.arguments[0].value+'('});
  edits.push({start:fields.end-1,end:n.end,text:')'});++counts.constructors;
 }
 if(n.type==='MemberExpression'&&n.computed&&Number.isInteger(n.property.value)&&n.object.type==='MemberExpression'&&n.object.property.name==='a'){
  const index=n.property.value;assert(index>=0&&index<4);
  edits.push({start:n.start,end:n.end,text:'$p42slot'+index+'('+source.slice(n.object.object.start,n.object.object.end)+')'});++counts.slots;
 }
});
function apply(s,rows){rows.sort((a,b)=>b.start-a.start);let last=s.length;for(const e of rows){assert(e.end<=last,'overlap');s=s.slice(0,e.start)+e.text+s.slice(e.end);last=e.start;}return s;}
let flat=apply(source,edits);
// The generic matcher continues allocating its own argument vector. Constructors
// and fields are packed only while the preexisting closed scalar proof is open.
const helpers=`
const $p42Owned=new WeakSet(),$p42Has=$p42Owned.has.bind($p42Owned),$p42Add=$p42Owned.add.bind($p42Owned);
const $p42Own=x=>($p42Add(x),x);
function $p42Leaf(v){return regionProof!==null?$p42Own({$:'Leaf',_0:v}):ctor('Leaf',[v]);}
function $p42Node(l,r){return regionProof!==null?$p42Own({$:'Node',_0:l,_1:r}):ctor('Node',[l,r]);}
function $p42St(lo,hi,ok,mx){return regionProof!==null?$p42Own({$:'St',_0:lo,_1:hi,_2:ok,_3:mx}):ctor('St',[lo,hi,ok,mx]);}
function $p42fields(x){switch(x.$){case 'Leaf':return[x._0];case 'Node':return[x._0,x._1];case 'St':return[x._0,x._1,x._2,x._3];default:throw Error('layout invariant');}}
${Array.from({length:4},(_,i)=>`function $p42slot${i}(x){return $p42Has(x)?x._${i}:x.a[${i}];}`).join('\n')}
`;
flat=flat.replace('function fields(k,x){','function fields(k,x){\n  if($p42Has(x))return x.$===k?$p42fields(x):null;');
flat=flat.replace('function project(k,x){','function project(k,x){\n  if($p42Has(x))return $p42fields(x);');
// Scalar finite selector uses one unpack rather than individual slot expressions.
flat=flat.replaceAll('const $unpack=$p0.a;','const $unpack=$p42Has($p0)?$p42fields($p0):$p0.a;');
flat+='\n'+helpers;
const direct=flat.replace(/return \$p42Has\(x\)\?x\._([0-3]):x\.a\[\1\];/g,'return x._$1;');
assert.notEqual(direct,flat);
const worker=name=>'$R'+Array.from(name,c=>'_'+c.codePointAt(0)).join('')+'$tree';
const guards=['bench','bsort','warp','warp_zip','warp_leaf','Bool.xor','warp_leaf.go','flow','warp_node','key','prng','scan','stat_join','stat_join.go','stat_out'];
const adapter=`
export function p42ProofActive(){return regionProof!==null;}
export function p42Complete(d,x,s=false){if(!Number.isInteger(d)||d<0||d>12||!Number.isInteger(x)||x<0||x>4294967295||typeof s!=='boolean')throw Error('diagnostic domain');
 const guards=${JSON.stringify(guards)};if(!regionHostGuard()||!localGuard(guards))throw Error('diagnostic guard');
 const old=regionProofOpen(guards);try{const tree=${worker('bsort')}(BigInt(d),s,x);return {tree,stat:${worker('scan')}(tree)};}finally{regionProofClose(old);}}
`;
fs.mkdirSync(out,{recursive:false});
for(const[role,text]of[['original',source],['flat',flat],['direct',direct]]){parse(text);parse(text+adapter);fs.writeFileSync(path.join(out,role+'.clean.mjs'),text,{flag:'wx'});fs.writeFileSync(path.join(out,role+'.mjs'),text+adapter,{flag:'wx'});}
fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify({kind:'phase42-private-layout',checked:false,complete:true,input:{path:fs.realpathSync(sourceArg),sha256:sha(source)},counts,modules:['original.clean.mjs','flat.clean.mjs','original.mjs','flat.mjs','direct.clean.mjs','direct.mjs'].map(file=>({file,sha256:sha(fs.readFileSync(path.join(out,file)))})),scope:'Manual exact saved-output ablation. Closed scalar trees only; does not establish compiler-owned representation support.'},null,2)+'\n');
console.log(JSON.stringify({out,counts,complete:true,checked:false}));
