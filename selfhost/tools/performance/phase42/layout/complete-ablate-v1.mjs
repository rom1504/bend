// Orthogonal full-graph layout/Nat ablations. Native recursion remains identical.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [parentArg,outArg]=process.argv.slice(2);assert(parentArg&&outArg);
const parent=path.resolve(parentArg),out=path.resolve(outArg),sha=x=>createHash('sha256').update(x).digest('hex');
const identity=p=>({path:fs.realpathSync(p),sha256:sha(fs.readFileSync(p))});
const receipt=JSON.parse(fs.readFileSync(path.join(parent,'derive.json')));assert.equal(receipt.kind,'phase42-complete-private-ceiling');assert.equal(receipt.complete,true);
for(const row of receipt.modules)assert.equal(identity(path.join(parent,row.file)).sha256,row.sha256);
assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:false});
const original=fs.readFileSync(path.join(parent,'original.clean.mjs'),'utf8'),originalDiag=fs.readFileSync(path.join(parent,'original.mjs'),'utf8'),flat=fs.readFileSync(path.join(parent,'complete.clean.mjs'),'utf8'),flatDiag=fs.readFileSync(path.join(parent,'complete.mjs'),'utf8');
const graphAt=flat.indexOf('function $p42Leaf');assert(graphAt>0);const diagnosticAt=flatDiag.indexOf('export function p42ProofActive()',graphAt);assert(diagnosticAt>graphAt);
const graph=flat.slice(graphAt);
function arraysGraph(g){
 g=g.replace("return {$:'Leaf',v};","return {$:'Leaf',a:[v]};").replace("return {$:'Node',l,r};","return {$:'Node',a:[l,r]};").replace("return {$:'St',lo,hi,ok,mx};","return {$:'St',a:[lo,hi,ok,mx]};");
 const slots={v:0,l:0,r:1,lo:0,hi:1,ok:2,mx:3};return g.replace(/\.(lo|hi|ok|mx|v|l|r)\b/g,(_,slot)=>'.a['+slots[slot]+']');
}
// Diagnostic conversion alone preserves aliases from caller-owned named fixtures.
// It is never added to clean timing modules.
const arraysAdapters=`
function $p42DiagnosticAdapter(){const encodeMemo=new WeakMap(),decodeMemo=new WeakMap();
 const encode=t=>{if(encodeMemo.has(t))return encodeMemo.get(t);const x=t.$==='Leaf'?{$:'Leaf',a:[t.v]}:{$:'Node',a:[encode(t.l),encode(t.r)]};encodeMemo.set(t,x);decodeMemo.set(x,t);return x;};
 const decode=t=>{if(decodeMemo.has(t))return decodeMemo.get(t);const x=t.$==='Leaf'?{$:'Leaf',v:t.a[0]}:{$:'Node',l:decode(t.a[0]),r:decode(t.a[1])};decodeMemo.set(t,x);return x;};return{encode,decode};}
`;
const arraysClean=flat.slice(0,graphAt)+arraysGraph(graph);
let arraysDiag=flatDiag.slice(0,graphAt)+arraysGraph(flatDiag.slice(graphAt,diagnosticAt))+flatDiag.slice(diagnosticAt);
arraysDiag=arraysDiag.replace('return $p42Flow(BigInt(n),s,t);','const {encode,decode}=$p42DiagnosticAdapter();return decode($p42Flow(BigInt(n),s,encode(t)));').replace('return $p42Warp(a,b,s);','const {encode,decode}=$p42DiagnosticAdapter();return decode($p42Warp(encode(a),encode(b),s));');
arraysDiag+='\n'+arraysAdapters;
function numberGraph(g){return g.replaceAll('0n','0').replaceAll('1n','1');}
function numberModule(s,diagnostic){let result=s.slice(0,graphAt).replace('return $p42Bench(BigInt($s0),$s1);','return $p42Bench($s0,$s1);')+numberGraph(s.slice(graphAt,diagnostic?diagnosticAt:undefined));if(diagnostic)result+=s.slice(diagnosticAt).replace('$p42Bsort(BigInt(d),s,x)','$p42Bsort(d,s,x)').replace('$p42Flow(BigInt(n),s,t)','$p42Flow(n,s,t)');return result;}
const native=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],am={exports:{}};new Function('module','exports',native)(am,am.exports);const parse=s=>am.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
const variants=[['flat-bigint',flat,flatDiag],['array-bigint',arraysClean,arraysDiag],['flat-number',numberModule(flat,false),numberModule(flatDiag,true)]];
const outputs=[];for(const[variant,clean,diagnostic]of variants){assert.notEqual(clean,variant==='flat-bigint'?original:flat);const dir=path.join(out,variant);fs.mkdirSync(dir);const modules=[];for(const[file,text]of [['original.clean.mjs',original],['original.mjs',originalDiag],['complete.clean.mjs',clean],['complete.mjs',diagnostic]]){parse(text);fs.writeFileSync(path.join(dir,file),text,{flag:'wx'});modules.push({file,sha256:sha(text)});}fs.writeFileSync(path.join(dir,'derive.json'),JSON.stringify({kind:'phase42-complete-private-ceiling',complete:true,checked:false,maxDepth:12,variant,parent:identity(path.join(parent,'derive.json')),producer:identity(import.meta.filename),modules,scope:'Exact full graph ablation: array-bigint differs only representation; flat-number differs only bounded Nat representation. Native recursion/algorithm/guards are shared.'},null,2)+'\n');outputs.push({variant,dir,clean:identity(path.join(dir,'complete.clean.mjs'))});}
fs.writeFileSync(path.join(out,'ablate.json'),JSON.stringify({kind:'phase42-complete-orthogonal-ablation',complete:true,checked:false,parent:identity(path.join(parent,'derive.json')),producer:identity(import.meta.filename),outputs},null,2)+'\n');fs.copyFileSync(import.meta.filename,path.join(out,'consumed-complete-ablate-v1.mjs'));console.log(JSON.stringify({complete:true,checked:false,out,variants:outputs.map(x=>x.variant)}));
