// Root-only actual checked-emission fixture owner; no program optimizer rewrite.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
const[baseArg,candidateArg,attemptArg,outArg]=process.argv.slice(2);
assert(baseArg&&candidateArg&&attemptArg&&outArg,'usage: phase41-wrapper-controls-v5.mjs BASELINE CANDIDATE ATTEMPT NEW_OUT');
const out=path.resolve(outArg);assert(!fs.existsSync(out));
const sha=x=>createHash('sha256').update(x).digest('hex');
const identity=p=>({path:fs.realpathSync(p),sha256:sha(fs.readFileSync(p))});
const attempt=await verifyAttempt(path.resolve(attemptArg));assert.equal(attempt.checked,true);
const fixture=identity(path.resolve(import.meta.dirname,'../../phase41/tree/wrapper-fixture-v2.bend'));
const ps=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],pm={exports:{}};
new Function('module','exports',ps)(pm,pm.exports);assert.equal(pm.exports.version,'8.16.0');
const parse=s=>pm.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
const encoded=name=>'$R'+Array.from(name,c=>'_'+c.codePointAt(0)).join('')+'$tree';
const admitted=['wrap.turn','wrap.forward'],newlyAdmitted=['wrap.scalar','wrap.nat'],refused=['wrap.empty','wrap.reference','wrap.improper','wrap.bad_first','wrap.back','wrap.bridge','wrap.back_worker'];
const roles=['original','wrapper'],mods={},inputs=[],modules=[],activationInventory={},newActivationInventory={},ordinaryNewActivation=[],newBoundaries=[],newPublicInputs=[];
fs.mkdirSync(out,{recursive:false});
for(const[role,file]of[['original',baseArg],['wrapper',candidateArg]]){
 const source=fs.readFileSync(file,'utf8'),receipt=JSON.parse(fs.readFileSync(file+'.json'));
 assert.equal(receipt.complete,true);assert.equal(receipt.observation.checked,true);assert.equal(receipt.input.sha256,fixture.sha256);assert.equal(receipt.output.sha256,sha(source));
 if(role==='original')assert.equal(receipt.compiler.api.sha256,'630879d8f030241a1d2c56e97f18f88b5be2070ac45dd02304afd06b3e3c5c0a');
 else{assert.equal(receipt.attempt.sha256,identity(path.join(attemptArg,'attempt.json')).sha256);for(const key of['api','runtime','base'])assert.equal(receipt.compiler[key].sha256,attempt[key].sha256);}
 for(const key of['api','runtime','base','driver'])assert.equal(identity(receipt.compiler[key].canonicalPath??receipt.compiler[key].file).sha256,receipt.compiler[key].sha256);
 const workers=parse(source).body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name.endsWith('$tree'));
 for(const name of admitted)assert.equal(workers.filter(n=>n.id.name===encoded(name)).length,role==='wrapper'?1:0,'admission '+name);
 for(const name of newlyAdmitted)assert.equal(workers.filter(n=>n.id.name===encoded(name)).length,role==='wrapper'?1:0,'new source14 admission '+name);
 for(const name of refused)assert(!workers.some(n=>n.id.name===encoded(name)),'refusal '+name);
 assert(workers.some(n=>n.id.name===encoded('wrap.map')),'independent proper worker');
 const all=[];function walk(n){if(!n||typeof n!=='object')return;if(n.type)all.push(n);for(const [k,v]of Object.entries(n))if(k!=='start'&&k!=='end'){if(Array.isArray(v))v.forEach(walk);else if(v&&typeof v==='object')walk(v);}}walk(parse(source));
 const selected=[];for(const name of admitted)for(const worker of workers.filter(n=>n.id.name===encoded(name)))selected.push({node:worker,key:'global:'+name});
 if(role==='wrapper'){
  for(const [root,name]of [['bench','wrap.turn'],['forward_check','wrap.forward']]){
   const owners=all.filter(n=>n.type==='AssignmentExpression'&&n.left.type==='MemberExpression'&&n.left.object.name==='G'&&n.left.property.value===root);assert.equal(owners.length,1,'exact root scope '+root);const owner=owners[0];
   const marker=source.indexOf('/* private flat closed graph */',owner.start);assert(marker>owner.start&&marker<owner.end,'selected flat scope '+root);
   const nested=all.filter(n=>n.type==='FunctionDeclaration'&&owner.start<n.start&&n.end<owner.end);
   const structural=nested.filter(n=>n.id.name===encoded(name));assert.equal(structural.length,1,'exact lexical structural '+name);assert(structural[0].start>marker);selected.push({node:structural[0],key:'lexical-tree:'+name});
   if(name==='wrap.forward'){
    const helpers=nested.filter(n=>n.id.name===encoded(name).slice(0,-5));assert.equal(helpers.length,2,'exact lexical helper '+name);
    assert.equal(helpers.filter(n=>n.start<marker).length,1);assert.equal(helpers.filter(n=>n.start>marker).length,1);
    for(const helper of helpers)selected.push({node:helper,key:(helper.start<marker?'lexical-outer:':'lexical-flat:')+name});
   }
  }
 }
 const newSelected=[];
 if(role==='wrapper'){
  for(const name of newlyAdmitted){const worker=workers.find(n=>n.id.name===encoded(name));assert.equal(worker.params.length,2);newSelected.push({node:worker,key:'global:'+name});}
  const owners=all.filter(n=>n.type==='AssignmentExpression'&&n.left.type==='MemberExpression'&&n.left.object.name==='G'&&n.left.property.value==='refusal_check');assert.equal(owners.length,1);
  const owner=owners[0],marker=source.indexOf('/* private flat closed graph */',owner.start);assert(marker>owner.start&&marker<owner.end);
  const ownerText=source.slice(owner.start,owner.end);assert(ownerText.includes('$entered&&regionHostGuard()'),'ordinary wrapper entered and full host guard');
  for(const slot of ['$s0','$s1'])assert(ownerText.includes('(typeof '+slot+'==="number"&&Number.isInteger('+slot+')&&'+slot+'>=0&&'+slot+'<=4294967295)'),'canonical ordinary U32 slot '+slot);
  assert(ownerText.includes('localGuard($guards)'));const opened=source.indexOf('regionProofOpen($guards)',owner.start),closed=source.indexOf('finally{regionProofClose($previousProof);}',marker);assert(opened>owner.start&&opened<marker&&closed>marker&&closed<owner.end,'proof lifetime encloses private flat graph');
  const guardDecl=all.filter(n=>n.type==='VariableDeclarator'&&n.id.name==='$guards'&&owner.start<n.start&&n.end<owner.end);assert.equal(guardDecl.length,1);assert.equal(guardDecl[0].init.type,'ArrayExpression');assert.deepEqual(guardDecl[0].init.elements.map(n=>n.value),['refusal_check','wrap.make','wrap.nat','wrap.scalar','wrap.map','wrap.score']);
  for(const [name,key,workerName] of [['wrap.scalar','lexical-flat:wrap.scalar',encoded('wrap.scalar').slice(0,-5)],['wrap.nat','lexical-tree:wrap.nat',encoded('wrap.nat')]]){
   const found=all.filter(n=>n.type==='FunctionDeclaration'&&n.id.name===workerName&&marker<n.start&&n.end<owner.end);assert.equal(found.length,1,'exact live newly admitted helper '+name);assert.equal(found[0].params.length,2);newSelected.push({node:found[0],key});
  }
 }
 assert.equal(newSelected.length,role==='wrapper'?4:0);newActivationInventory[role]=newSelected.map(({node,key})=>({key,name:node.id.name,start:node.start,end:node.end}));
 assert.equal(selected.length,role==='wrapper'?6:0);activationInventory[role]=selected.map(({node,key})=>({key,name:node.id.name,start:node.start,end:node.end}));
 let diagnostic=source;
 for(const {node:worker,key,isNew}of [...selected.map(x=>({...x,isNew:false})),...newSelected.map(x=>({...x,isNew:true}))].sort((a,b)=>b.node.body.start-a.node.body.start)){
  const body=source.slice(worker.body.start,worker.body.end);assert(!body.includes('$frames'));assert(!body.includes('$visit'));
  const at=worker.body.start+1;diagnostic=diagnostic.slice(0,at)+(isNew?'++$newFixtureScopeEntries[':'++$fixtureEntries;++$fixtureScopeEntries[')+JSON.stringify(key)+'];'+diagnostic.slice(at);
 }
 diagnostic+=`
let $fixtureEntries=0;
const $fixtureScopeEntries=${JSON.stringify(Object.fromEntries(selected.map(({key})=>[key,0])))};
const $newFixtureScopeEntries=${JSON.stringify(Object.fromEntries(newSelected.map(({key})=>[key,0])))};
export function newFixtureScopeCounts(){return {...$newFixtureScopeEntries};}
const $fixtureNames=['wrap.map','wrap.turn','wrap.forward'];
export function fixtureCounts(){return $fixtureEntries;}
export function fixtureScopeCounts(){return {...$fixtureScopeEntries};}
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
assert.equal(mods.wrapper.fixtureScopeCounts()['global:wrap.turn'],60,'diagnostic actual global tagged turn');
assert.equal(mods.wrapper.fixtureScopeCounts()['global:wrap.forward'],0,'diagnostic does not use forward');
for(const d of[0,1,3,5])for(const seed of[0,17,4294967295])for(const role of roles){const mod=mods[role],t=make(d,seed,false);
 const before=mod.fixtureCounts(),scopesBefore=mod.fixtureScopeCounts();assert.equal(mod.default.bench(d,seed),score(turn(t,seed%2===0)));const scopesBench=mod.fixtureScopeCounts();assert.equal(mod.default.forward_check(d,seed),score(map(t)));const scopesForward=mod.fixtureScopeCounts();const newBefore=mod.newFixtureScopeCounts();assert.equal(mod.default.refusal_check(d,seed),score(map(map(t))));const newAfter=mod.newFixtureScopeCounts();
 if(role==='wrapper'){for(const key of ['lexical-flat:wrap.scalar','lexical-tree:wrap.nat'])assert.equal(newAfter[key]-newBefore[key],1,'ordinary newly admitted live '+key);for(const key of ['global:wrap.scalar','global:wrap.nat'])assert.equal(newAfter[key],newBefore[key],'ordinary must not fake global admission');ordinaryNewActivation.push({depth:d,seed,before:newBefore,after:newAfter});}
 if(role==='wrapper'){
  assert(mod.fixtureCounts()>before,'ordinary source admission');
  assert.equal(scopesBench['lexical-tree:wrap.turn']-scopesBefore['lexical-tree:wrap.turn'],1,'ordinary actual lexical turn');
  assert.equal(scopesForward['lexical-flat:wrap.forward']-scopesBench['lexical-flat:wrap.forward'],1,'ordinary actual lexical forward helper');
  for(const name of admitted){assert.equal(scopesBench['global:'+name],scopesBefore['global:'+name]);assert.equal(scopesForward['global:'+name],scopesBench['global:'+name]);}
 }assert.equal(mod.fixtureProofActive(),false);++oracles;
}
for(const name of['wrap.map','wrap.turn']){const observations=[];
 for(const role of roles){const mod=mods[role],saved=Object.getOwnPropertyDescriptor(mod.G,name),events=[],before=mod.fixtureCounts();
  Object.defineProperty(mod.G,name,{configurable:true,enumerable:true,get(){events.push('get');return saved.value;}});
  let result;try{result=mod.default.bench(3,17);}finally{Object.defineProperty(mod.G,name,saved);}
  assert.equal(mod.fixtureCounts(),before);assert.equal(mod.fixtureProofActive(),false);observations.push({result,events});}
 assert.deepEqual(observations[0],observations[1]);++boundaries;
}

// Frozen source14 guard inventory. Instrument only exact live lexical helpers;
// mutation must refuse those helpers, including bounded callbacks and errors.
const newGuardNames=['refusal_check','wrap.make','wrap.nat','wrap.scalar','wrap.map','wrap.score'];
for(const name of newGuardNames)for(const mode of ['binding','code','getter','throw','reentry']){
 const observations=[];
 for(const role of roles){const mod=mods[role],gdesc=Object.getOwnPropertyDescriptor(mod.G,name),f=gdesc.value,cdesc=Object.getOwnPropertyDescriptor(f,'code'),code=f.code,events=[],before=mod.newFixtureScopeCounts();let value,error,once=false;
  const observe=()=>{events.push(mode+':'+name);if(mode==='throw')throw Error('new wrapper sentinel');if(mode==='reentry'&&!once){once=true;assert.equal(mod.fixtureProofActive(),false);events.push(['reentry',mod.default.refusal_check(0,1),mod.fixtureProofActive()]);}return code;};
  if(mode==='binding')Object.defineProperty(mod.G,name,{configurable:true,enumerable:true,get(){events.push('binding:'+name);return f;}});
  else if(mode==='code')Object.defineProperty(f,'code',{...cdesc,value:function(a){events.push('code:'+name);return Reflect.apply(code,this,[a]);}});
  else Object.defineProperty(f,'code',{configurable:true,enumerable:cdesc.enumerable,get:observe});
  try{value=mod.default.refusal_check(3,17);}catch(e){error={name:e.name,message:e.message};}finally{Object.defineProperty(mod.G,name,gdesc);Object.defineProperty(f,'code',cdesc);}
  assert.deepEqual(mod.newFixtureScopeCounts(),before,'newly admitted helper refusal '+name+':'+mode);assert.equal(mod.fixtureProofActive(),false);observations.push({value,error,events});
 }
 assert.deepEqual(observations[0],observations[1],'new wrapper guard parity '+name+':'+mode);newBoundaries.push({name,mode,observations});
}
function publicTree(mod,events,mode){
 const shared=mod.ctor('WLeaf',[17]),tree=mod.ctor('WNode',[shared,shared]);
 if(mode==='tag-getter')Object.defineProperty(tree,'$',{get(){events.push('tag');return 'WNode';}});
 if(mode==='field-getter')Object.defineProperty(tree.a,'0',{get(){events.push('field:0');return shared;}});
 if(mode==='field-throw')Object.defineProperty(tree.a,'0',{get(){events.push('field:0');throw Error('public field sentinel');}});
 return {tree,shared};
}
function publicObservation(mod,name,mode,events){
 const {tree,shared}=publicTree(mod,events,mode);let result,error,topology;
 try{result=mod.call(mod.G[name],[name==='wrap.scalar'?false:0n,tree]);topology={value:decode(result),sharesChildren:result.a[0]===result.a[1],aliasesInput:result===tree,aliasesChild:result.a[0]===shared};}catch(e){error={name:e.name,message:e.message};}
 const inputUnchanged=tree.a[1]===shared&&shared.a[0]===17;
 return {topology,error,inputUnchanged,events};
}
for(const name of newlyAdmitted)for(const mode of ['retained-shared','tag-getter','field-getter','field-throw']){
 const observations=[];
 for(const role of roles){const mod=mods[role],events=[],before=mod.newFixtureScopeCounts();observations.push(publicObservation(mod,name,mode,events));assert.deepEqual(mod.newFixtureScopeCounts(),before,'public input never gets private wrapper permission');assert.equal(mod.fixtureProofActive(),false);}
 assert.deepEqual(observations[0],observations[1],'public new wrapper parity '+name+':'+mode);assert.equal(observations[0].inputUnchanged,true);newPublicInputs.push({name,mode,observations});
}
assert.equal(ordinaryNewActivation.length,12);assert.equal(newBoundaries.length,30);assert.equal(newPublicInputs.length,8);

const report={kind:'phase41-wrapper-fixture-controls',complete:true,checked:true,source:fixture,attempt:identity(path.join(attemptArg,'attempt.json')),producer:identity(import.meta.filename),inputs,modules,admitted,newlyAdmitted,refused,oracles,boundaries,activationInventory,newActivationInventory,ordinaryNewActivation,newBoundaries,newPublicInputs,newGuardNames,newScopeEntries:Object.fromEntries(roles.map(role=>[role,mods[role].newFixtureScopeCounts()])),scopeEntries:Object.fromEntries(roles.map(role=>[role,mods[role].fixtureScopeCounts()]))};
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-fixture-controls.mjs'));fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify(report));
