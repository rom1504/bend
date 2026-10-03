// Independent renamed graph controls. Root emits checked libraries and executes.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
import {reviewBench,reviewMap,reviewMake,decodeTagged} from '../review/oracles.mjs';
const[baseArg,candidateArg,attemptArg,outArg]=process.argv.slice(2);assert(baseArg&&candidateArg&&attemptArg&&outArg,'usage: fixture-controls-v2.mjs PHASE41_FIXTURE_LIB CHECKED_FIXTURE_LIB ATTEMPT NEW_OUT');
const sha=x=>createHash('sha256').update(x).digest('hex'),identity=p=>({path:fs.realpathSync(p),sha256:sha(fs.readFileSync(p))});
const out=path.resolve(outArg);assert(!fs.existsSync(out));const attempt=await verifyAttempt(path.resolve(attemptArg));assert.equal(attempt.checked,true);
const ps=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],pm={exports:{}};new Function('module','exports',ps)(pm,pm.exports);assert.equal(pm.exports.version,'8.16.0');const parse=s=>pm.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
function walk(n,fn){if(!n||typeof n!=='object')return;fn(n);for(const[k,v]of Object.entries(n))if(!['start','end'].includes(k)){if(Array.isArray(v))v.forEach(x=>walk(x,fn));else if(v&&typeof v==='object')walk(v,fn);}}
const encoded=name=>'$R'+Array.from(name,c=>'_'+c.codePointAt(0)).join('')+'$tree';
fs.mkdirSync(out,{recursive:false});const roles=['original','candidate'],mods={},inputs=[],staticSites={};let guards,originalInput;
for(const[role,arg]of[['original',baseArg],['candidate',candidateArg]]){
 const source=fs.readFileSync(arg,'utf8'),receipt=JSON.parse(fs.readFileSync(arg+'.json'));assert.equal(receipt.complete,true);assert.equal(receipt.observation.checked,true);assert.equal(receipt.observation.status,'ok');assert.equal(receipt.output.sha256,sha(source));assert.equal(receipt.input.sha256,identity('selfhost/tools/performance/phase42/calls/fixture-renamed-v2.bend').sha256);
 for(const row of[receipt.input,receipt.compiler.api,receipt.compiler.runtime,receipt.compiler.base,receipt.compiler.driver])assert.equal(identity(row.canonicalPath??row.file).sha256,row.sha256);
 if(role==='original'){assert.equal(receipt.compiler.api.sha256,'9900abf49719575db7f7bbee32c6b16e10bcd554f9de22cde0799eb859cc6f0b');originalInput=receipt.input.sha256;}
 else{assert.equal(receipt.input.sha256,originalInput);assert.equal(receipt.attempt.sha256,identity(path.join(attemptArg,'attempt.json')).sha256);for(const key of['api','runtime','base'])assert.equal(receipt.compiler[key].sha256,attempt[key].sha256);}
 const ast=parse(source),workers=ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name.endsWith('$tree')),helperSites=[],rootAssignments=[];
 walk(ast,n=>{if(n.type==='AssignmentExpression'&&n.left.type==='MemberExpression'&&n.left.object.name==='G'&&n.left.property.value==='bench')rootAssignments.push(n);if(n.type==='ArrowFunctionExpression'&&n.body.type==='BlockStatement'&&source.slice(n.body.start,n.body.start+60).startsWith('{/* private acyclic helper */'))helperSites.push(n);});assert.equal(rootAssignments.length,1);
 const rootGuards=[];walk(rootAssignments[0].right,n=>{if(n.type==='VariableDeclarator'&&n.id.name==='$guards'&&n.init.type==='ArrayExpression')rootGuards.push(n.init.elements.map(x=>x.value));});assert.equal(rootGuards.length,1);if(role==='original')guards=rootGuards[0];else assert.deepEqual(rootGuards[0],guards,'complete closure unchanged');
 assert(guards.includes('review.map')&&guards.includes('review.pair')&&guards.includes('review.pair.at')&&guards.includes('review.key')&&guards.includes('review.flip')&&guards.includes('Bool.xor'));
 const worker=workers.find(n=>n.id.name===encoded('review.map'));assert(worker,'actual renamed map worker required');
 for(const name of['review.reference','review.partial','review.text','review.back_worker'])assert(!workers.some(n=>n.id.name===encoded(name)),'refused graph cannot have structural worker');
 if(role==='candidate')assert(helperSites.length>0,'actual renamed inline helper required');
 let diagnostic=source;const edits=[{at:worker.body.start+1,text:'++$p42Entries;'},...helperSites.map(n=>({at:n.body.start+1,text:'++$p42Entries;'}))];for(const e of edits.sort((a,b)=>b.at-a.at))diagnostic=diagnostic.slice(0,e.at)+e.text+diagnostic.slice(e.at);
 diagnostic+=`\nlet $p42Entries=0;const $p42Guards=${JSON.stringify(guards)};export function p42Counts(){return $p42Entries;}export function p42Proof(){return regionProof!==null;}function $p42Make(d,x){if(d===0)return ctor('RLeaf',[x]);return ctor('RNode',[$p42Make(d-1,(x+1)>>>0),ctor('RLeaf',[(x^91)>>>0])]);}export function p42Map(d,x,s){const t=$p42Make(d,x);if(!regionHostGuard()||!localGuard($p42Guards))throw Error('fixture diagnostic guard');const previous=regionProofOpen($p42Guards);try{return ${encoded('review.map')}(t,s);}finally{regionProofClose(previous);}}\n`;parse(diagnostic);const file=path.join(out,role+'.mjs');fs.writeFileSync(file,diagnostic,{flag:'wx'});mods[role]=await import(pathToFileURL(file));inputs.push(identity(arg),identity(arg+'.json'));staticSites[role]={workers:workers.length,helpers:helperSites.length};
}
let oracles=0,boundaries=0;
for(const depth of[0,1,2,5,8])for(const seed of[0,1,17,2147483648,4294967295]){
 for(const role of roles){assert.equal(mods[role].default.bench(depth,seed),reviewBench(depth,seed));assert.equal(mods[role].p42Proof(),false);}++oracles;
 for(const flag of[false,true]){for(const role of roles)assert.deepEqual(decodeTagged(mods[role].p42Map(depth,seed,flag),'RLeaf','RNode'),reviewMap(reviewMake(depth,seed),flag));++oracles;}
}
assert(mods.candidate.p42Counts()>0);
for(const name of guards.filter(n=>n!=='bench'))for(const mode of['binding','getter']){
 const observations=[];
 for(const role of roles){const mod=mods[role],saved=Object.getOwnPropertyDescriptor(mod.G,name),events=[],original=saved.value,wrapped={...original,code:function(...args){events.push('code');return original.code.apply(this,args);}};
 if(mode==='binding')Object.defineProperty(mod.G,name,{...saved,value:wrapped});else Object.defineProperty(mod.G,name,{configurable:true,enumerable:true,get(){events.push('get');return wrapped;}});
 const start=mod.p42Counts();let result,error;try{result=mod.default.bench(3,17);}catch(e){error=e.message;}finally{Object.defineProperty(mod.G,name,saved);}assert.equal(mod.p42Proof(),false);if(role==='candidate')assert.equal(mod.p42Counts(),start);observations.push({result,error,events});
 }assert.deepEqual(observations[0],observations[1]);++boundaries;
}
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-fixture-controls.mjs'));
const report={kind:'phase42-renamed-actual-controls',complete:true,checked:true,producer:identity(import.meta.filename),attempt:identity(path.join(attemptArg,'attempt.json')),oracle:identity('selfhost/tools/performance/phase42/review/oracles.mjs'),fixture:identity('selfhost/tools/performance/phase42/calls/fixture-renamed-v2.bend'),inputs,staticSites,guards,oracles,boundaries,entries:mods.candidate.p42Counts()};fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify(report));
