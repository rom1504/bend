// Root-only actual checked-emission fixture owner; no program optimizer rewrite.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
const[baseArg,candidateArg,attemptArg,outArg]=process.argv.slice(2);
assert(baseArg&&candidateArg&&attemptArg&&outArg,'usage: fixture-controls.mjs BASELINE CANDIDATE ATTEMPT NEW_OUT');
const out=path.resolve(outArg);assert(!fs.existsSync(out));
const sha=x=>createHash('sha256').update(x).digest('hex');
const identity=p=>({path:fs.realpathSync(p),sha256:sha(fs.readFileSync(p))});
const attempt=await verifyAttempt(path.resolve(attemptArg));assert.equal(attempt.checked,true);
const fixture=identity(path.join(import.meta.dirname,'wrapper-fixture.bend'));
const ps=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],pm={exports:{}};
new Function('module','exports',ps)(pm,pm.exports);assert.equal(pm.exports.version,'8.16.0');
const parse=s=>pm.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
const encoded=name=>'$R'+Array.from(name,c=>'_'+c.codePointAt(0)).join('')+'$tree';
const admitted=['wrap.turn','wrap.forward'],refused=['wrap.empty','wrap.scalar','wrap.nat','wrap.reference','wrap.improper','wrap.bad_first','wrap.back','wrap.bridge','wrap.back_worker'];
const roles=['original','wrapper'],mods={},inputs=[],modules=[];
fs.mkdirSync(out,{recursive:false});
for(const[role,file]of[['original',baseArg],['wrapper',candidateArg]]){
 const source=fs.readFileSync(file,'utf8'),receipt=JSON.parse(fs.readFileSync(file+'.json'));
 assert.equal(receipt.complete,true);assert.equal(receipt.observation.checked,true);assert.equal(receipt.input.sha256,fixture.sha256);assert.equal(receipt.output.sha256,sha(source));
 if(role==='original')assert.equal(receipt.compiler.api.sha256,'630879d8f030241a1d2c56e97f18f88b5be2070ac45dd02304afd06b3e3c5c0a');
 else{assert.equal(receipt.attempt.sha256,identity(path.join(attemptArg,'attempt.json')).sha256);for(const key of['api','runtime','base'])assert.equal(receipt.compiler[key].sha256,attempt[key].sha256);}
 for(const key of['api','runtime','base','driver'])assert.equal(identity(receipt.compiler[key].canonicalPath??receipt.compiler[key].file).sha256,receipt.compiler[key].sha256);
 const workers=parse(source).body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name.endsWith('$tree'));
 for(const name of admitted)assert.equal(workers.filter(n=>n.id.name===encoded(name)).length,role==='wrapper'?1:0,'admission '+name);
 for(const name of refused)assert(!workers.some(n=>n.id.name===encoded(name)),'refusal '+name);
 assert(workers.some(n=>n.id.name===encoded('wrap.map')),'independent proper worker');
 let diagnostic=source;
 for(const worker of workers.filter(n=>admitted.includes(n.id.name===encoded('wrap.turn')?'wrap.turn':n.id.name===encoded('wrap.forward')?'wrap.forward':'')).sort((a,b)=>b.body.start-a.body.start)){
  const body=source.slice(worker.body.start,worker.body.end);assert(!body.includes('$frames'));assert(!body.includes('$visit'));
  const at=worker.body.start+1;diagnostic=diagnostic.slice(0,at)+'++$fixtureEntries;'+diagnostic.slice(at);
 }
 diagnostic+=`
let $fixtureEntries=0;
const $fixtureNames=['wrap.map','wrap.turn','wrap.forward'];
export function fixtureCounts(){return $fixtureEntries;}
export function fixtureProofActive(){return regionProof!==null;}
export function fixturePoint(depth,seed,flag,sharing){
 if(!Number.isInteger(depth)||depth<0||depth>6||!Number.isInteger(seed)||seed<0||seed>4294967295||typeof flag!=='boolean'||typeof sharing!=='boolean')throw Error('diagnostic domain');
 let tree=ctor('WLeaf',[(seed+depth)>>>0]);for(let i=depth-1;i>=0;--i)tree=ctor('WNode',[tree,sharing?tree:ctor('WLeaf',[((seed+i)^91)>>>0])]);
 if(regionProof!==null||!regionHostGuard()||!localGuard($fixtureNames))throw Error('diagnostic guard');
 const previous=regionProofOpen($fixtureNames);try{return ${role==='wrapper'?encoded('wrap.turn')+'(tree,flag)':"call(get(G,'wrap.turn'),[tree,flag])"};}finally{regionProofClose(previous);}}
`;
 parse(diagnostic);const clean=path.join(out,role+'.clean.mjs'),diag=path.join(out,role+'.mjs');
 fs.writeFileSync(clean,source,{flag:'wx'});fs.writeFileSync(diag,diagnostic,{flag:'wx'});
 assert.equal(identity(clean).sha256,sha(source));modules.push(identity(clean),identity(diag));inputs.push(identity(file),identity(file+'.json'));
 mods[role]=await import(pathToFileURL(diag));
}
const leaf=x=>[x],node=(l,r)=>[l,r];
function make(d,s,sharing){let t=leaf((s+d)>>>0);for(let i=d-1;i>=0;--i)t=node(t,sharing?t:leaf(((s+i)^91)>>>0));return t;}
function map(t){return t.length===1?leaf((t[0]+7)>>>0):node(map(t[0]),map(t[1]));}
function turn(t,flag){return t.length===1?leaf(t[0]):map(flag?node(t[1],t[0]):t);}
function decode(t){assert(['WLeaf','WNode'].includes(t.$));return t.$==='WLeaf'?leaf(t.a[0]):node(decode(t.a[0]),decode(t.a[1]));}
function score(t){return t.length===1?t[0]:Number((BigInt(score(t[0]))*3n+BigInt(score(t[1])))&0xffffffffn);}
let oracles=0,boundaries=0;
for(const d of[0,1,2,4,6])for(const seed of[0,17,4294967295])for(const flag of[false,true])for(const sharing of[false,true]){
 const expected=turn(make(d,seed,sharing),flag);
 for(const role of roles){assert.deepEqual(decode(mods[role].fixturePoint(d,seed,flag,sharing)),expected);assert.equal(mods[role].fixtureProofActive(),false);}
 ++oracles;
}
for(const d of[0,1,3,5])for(const seed of[0,17,4294967295])for(const role of roles){const mod=mods[role],t=make(d,seed,false);
 const before=mod.fixtureCounts();assert.equal(mod.default.bench(d,seed),score(turn(t,seed%2===0)));assert.equal(mod.default.forward_check(d,seed),score(map(t)));assert.equal(mod.default.refusal_check(d,seed),score(map(t)));
 if(role==='wrapper')assert(mod.fixtureCounts()>before,'ordinary source admission');assert.equal(mod.fixtureProofActive(),false);++oracles;
}
for(const name of['wrap.map','wrap.turn']){const observations=[];
 for(const role of roles){const mod=mods[role],saved=Object.getOwnPropertyDescriptor(mod.G,name),events=[],before=mod.fixtureCounts();
  Object.defineProperty(mod.G,name,{configurable:true,enumerable:true,get(){events.push('get');return saved.value;}});
  let result;try{result=mod.default.bench(3,17);}finally{Object.defineProperty(mod.G,name,saved);}
  assert.equal(mod.fixtureCounts(),before);assert.equal(mod.fixtureProofActive(),false);observations.push({result,events});}
 assert.deepEqual(observations[0],observations[1]);++boundaries;
}
const report={kind:'phase41-wrapper-fixture-controls',complete:true,checked:true,source:fixture,attempt:identity(path.join(attemptArg,'attempt.json')),producer:identity(import.meta.filename),inputs,modules,admitted,refused,oracles,boundaries};
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-fixture-controls.mjs'));fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify(report));
