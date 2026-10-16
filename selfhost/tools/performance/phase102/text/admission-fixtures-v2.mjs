// Offline fixture preparation only: decode a pinned already-checked Base cache.
// No compiler module is imported. Root executes the candidate guard separately.
// node admission-fixtures.mjs NEW_OUTPUT_DIRECTORY
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {decodeBaseArena} from '../../../base-cache-graph.mjs';
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const root=path.resolve(import.meta.dirname,'../../../../..');
const out=path.resolve(process.argv[2]??'');
assert(process.argv[2], 'Provide a fresh fixture directory');
const receiptPath=path.join(root,'selfhost/tools/performance/phase88/base/carrier01/receipt.json');
const receipt=JSON.parse(fs.readFileSync(receiptPath,'utf8'));
const input=fs.readFileSync(receipt.inputPins.cache.file);
assert.equal(hash(input),receipt.inputPins.cache.sha256);
const cut=input.indexOf(10),h=JSON.parse(input.subarray(0,cut));
assert.equal(h.format,'bend-base-cache-frame-4');
const opts={range:{begin:h.sourceBegin,end:h.sourceEnd},termAbi:h.termAbi};
const first=decodeBaseArena(input.subarray(cut+1,cut+1+h.segments[0]),{...opts,rootKinds:['defs']});
const all=decodeBaseArena(input.subarray(cut+1+h.segments[0]),{...opts,base:first,rootKinds:['checked','fresh','world','frontend']});
const list=x=>{const r=[];while(x.$==='Con'){r.push(x.head);x=x.tail;}assert.equal(x.$,'Nil');return r;};
const def=list(first.roots[0]).find(d=>d.name==='String.append');assert(def);
const child=(n,i)=>list(n.kids)[i];
const at=(n,steps)=>steps.reduce(child,n);
const clone=x=>structuredClone(x);
const cases=[];
const add=(name,expected,mutate)=>{const value=clone(def.value);mutate?.(value);cases.push({name,expected,value});};
add('canonical-pinned-base',true);
const checkedDef=list(all.roots[2].checked).find(d=>d.name==='String.append');assert(checkedDef);
cases.push({name:'checked-pinned-base',expected:true,value:clone(checkedDef.value)});
add('alpha-renamed-and-renumbered',true,body=>{
  const walk=n=>{if(n.$==='KLambda'||n.tag==='Var'){n.name='alpha_'+n.name;n.id+=10000;}
    for(const k of list(n.kids))walk(k);n.originBegin=0;n.originEnd=0;};walk(body);
});
add('nil-returns-constant',false,b=>Object.assign(at(b,[0,0]),{tag:'Ctr',name:'SNil',id:0}));
add('different-recursive-function',false,b=>at(b,[1,0,0,0,0,1,0,0]).name='String.reverse');
add('head-is-tail-variable',false,b=>{const n=at(b,[1,0,0,0,0,0]);n.name='t';n.id=at(b,[1,0,0]).id;});
add('recursion-uses-right',false,b=>{const n=at(b,[1,0,0,0,0,1,0,1]);n.name='b';n.id=at(b,[1,0,0,0]).id;});
add('right-is-tail-variable',false,b=>{const n=at(b,[1,0,0,0,0,1,1]);n.name='t';n.id=at(b,[1,0,0]).id;});
add('different-result-constructor',false,b=>at(b,[1,0,0,0,0]).name='OtherCons');
add('duplicable-tail-binder',false,b=>at(b,[1,0,0]).quant=2);
add('removed-effect-marker',false,b=>at(b,[1,0,0,0]).removed={$:'Con',head:'effect',tail:{$:'Nil'}});
add('effect-instead-of-recursion',false,b=>at(b,[1,0,0,0,0,1]).tag='Par');
add('nonempty-fallback',false,b=>Object.assign(at(b,[1,1]),{tag:'Ctr',name:'SNil',quant:1}));
add('binder-id-collision',false,b=>{const hnode=at(b,[1,0]),tnode=at(b,[1,0,0]);tnode.id=hnode.id;at(b,[1,0,0,0,0,1,0,1]).id=hnode.id;});
add('extra-constructor-child',false,b=>{const node=at(b,[1,0,0,0,0]);node.kids.tail.tail={$:'Con',head:clone(at(b,[0,0])),tail:{$:'Nil'}};});
add('wrong-root-quantity',false,b=>b.quant=2);
add('wrong-application-quantity',false,b=>at(b,[1,0,0,0,0,1]).quant=3);
add('reference-extra-payload',false,b=>at(b,[1,0,0,0,0,1,0,0]).kids={$:'Con',head:clone(at(b,[0,0])),tail:{$:'Nil'}});
fs.mkdirSync(out,{recursive:false});
fs.writeFileSync(path.join(out,'body-cases.json'),JSON.stringify(cases,null,2)+'\n');
fs.writeFileSync(path.join(out,'canonical-definition.json'),JSON.stringify(def,null,2)+'\n');
const report={complete:true,offline:true,sourceCache:receipt.inputPins.cache,method:{file:import.meta.filename,sha256:hash(fs.readFileSync(import.meta.filename))},fixtureCount:cases.length,positive:cases.filter(c=>c.expected).length,negative:cases.filter(c=>!c.expected).length,preparedWorldDecoded:all.roots[2].$,
  scope:'Recorded KTerm candidates, not executed guard results. Test nx_append_body against every expected result; separately nx_append_allowed requires checked=true and canonical Base owners/signature.'};
fs.writeFileSync(path.join(out,'preparation.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report));
