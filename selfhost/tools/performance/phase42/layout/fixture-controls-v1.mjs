// Checked-source renamed graph admission/refusal and full observation controls.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
const[baseArg,candidateArg,attemptArg,outArg]=process.argv.slice(2);assert(baseArg&&candidateArg&&attemptArg&&outArg);assert(!fs.existsSync(outArg));
const sha=x=>createHash('sha256').update(x).digest('hex'),identity=p=>({path:fs.realpathSync(p),sha256:sha(fs.readFileSync(p))});
const fixture=path.resolve('selfhost/tools/performance/phase42/layout/fixture-flat-v3.bend'),attempt=await verifyAttempt(path.resolve(attemptArg));assert.equal(attempt.checked,true);
const natives=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],am={exports:{}};new Function('module','exports',natives)(am,am.exports);const parse=s=>am.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
function walk(n,fn){if(!n||typeof n!=='object')return;fn(n);for(const[k,v]of Object.entries(n))if(!['start','end'].includes(k)){if(Array.isArray(v))v.forEach(x=>walk(x,fn));else if(v&&typeof v==='object')walk(v,fn);}}
const positives=['bench','stat_bench'],negatives=['generic_observer_root','data_result_root','data_input_root','partial_callback_root','string_crossing_root','list_crossing_root','vector_crossing_root','mutual_backedge_root'];
const out=path.resolve(outArg);fs.mkdirSync(out);const mods={},inputs=[identity(fixture)],staticRows={},guards={};
for(const[role,arg]of[['original',baseArg],['candidate',candidateArg]]){
 const source=fs.readFileSync(arg,'utf8'),receipt=JSON.parse(fs.readFileSync(arg+'.json'));assert.equal(receipt.complete,true);assert.equal(receipt.observation.checked,true);assert.equal(receipt.observation.status,'ok');assert.equal(receipt.output.sha256,sha(source));assert.equal(receipt.input.sha256,identity(fixture).sha256);
 for(const row of[receipt.input,receipt.compiler.api,receipt.compiler.runtime,receipt.compiler.base,receipt.compiler.driver])assert.equal(identity(row.canonicalPath??row.file).sha256,row.sha256);
 if(role==='candidate'){assert.equal(receipt.attempt.sha256,identity(path.join(attemptArg,'attempt.json')).sha256);for(const key of['api','runtime','base'])assert.equal(receipt.compiler[key].sha256,attempt[key].sha256);}
 const ast=parse(source),assignments=new Map();walk(ast,n=>{if(n.type==='AssignmentExpression'&&n.left.type==='MemberExpression'&&n.left.object.name==='G')assignments.set(n.left.property.value,n);});
 const edits=[],rootCounts={};staticRows[role]={};
 for(const name of [...positives,...negatives]){const root=assignments.get(name);assert(root,'missing root '+name);const text=source.slice(root.start,root.end),flat=text.includes('/* private flat closed graph */');staticRows[role][name]={flat};assert.equal(flat,role==='candidate'&&positives.includes(name),'flat admission '+role+' '+name);
  if(positives.includes(name)){
   const gs=[];walk(root,n=>{if(n.type==='VariableDeclarator'&&n.id.name==='$guards'&&n.init.type==='ArrayExpression')gs.push(n.init.elements.map(x=>x.value));});assert.equal(gs.length,1);if(role==='original')guards[name]=gs[0];else assert.deepEqual(gs[0],guards[name]);
   walk(root,n=>{if(n.type==='BlockStatement'&&source.slice(n.start,n.start+60).startsWith('{/* private flat closed graph */')){edits.push({start:n.start+1,end:n.start+1,text:'++$p42FixtureEntries;'});rootCounts[name]=(rootCounts[name]??0)+1;}});
  }
 }
 if(role==='candidate')for(const name of positives)assert.equal(rootCounts[name],1);
 let diagnostic=source;for(const e of edits.sort((a,b)=>b.start-a.start))diagnostic=diagnostic.slice(0,e.start)+e.text+diagnostic.slice(e.end);diagnostic+='\nlet $p42FixtureEntries=0;export function p42FixtureCounts(){return $p42FixtureEntries;}export function p42FixtureProof(){return regionProof!==null;}\n';parse(diagnostic);
 const file=path.join(out,role+'.instrumented.mjs');fs.writeFileSync(file,diagnostic,{flag:'wx'});inputs.push(identity(arg),identity(arg+'.json'),identity(file));mods[role]=await import(pathToFileURL(file));
}
const leaf=v=>[v],node=(l,r)=>[l,r];function make(n,x){return n===0?leaf(x):node(make(n-1,(x+1)>>>0),leaf((x^91)>>>0));}
function map(t,flag){if(t.length===1){const x=t[0],y=(Math.imul(x,1103515245)+12345)>>>0;return flag!==(x>y)?node(leaf(y),leaf(x)):node(leaf(x),leaf(y));}return node(map(t[0],flag),map(t[1],flag));}
function score(t){return t.length===1?t[0]:(Math.imul(score(t[0]),3)+score(t[1]))>>>0;}function decode(t){assert(t&&['RLeaf','RNode'].includes(t.$));return t.$==='RLeaf'?leaf(t.a[0]):node(decode(t.a[0]),decode(t.a[1]));}
let oracles=0,boundaries=0;
for(const d of[0,1,2,4,6])for(const x of[0,17,123,4294967295])for(const name of positives){const expected=score(map(make(d,x),(x%2)===0));for(const role of Object.keys(mods)){const mod=mods[role],before=mod.p42FixtureCounts();assert.equal(mod.default[name](d,x),expected);assert.equal(mod.p42FixtureProof(),false);if(role==='candidate')assert.equal(mod.p42FixtureCounts(),before+1);}++oracles;}
for(const name of guards.bench)for(const mode of['binding','getter','throw','reentry']){
 const observations=[];for(const role of Object.keys(mods)){const mod=mods[role],saved=Object.getOwnPropertyDescriptor(mod.G,name),events=[],before=mod.p42FixtureCounts();assert(saved);let entered=false;
 const wrapped={...saved.value,code:function(...args){events.push('code');return saved.value.code.apply(this,args);}};
 if(mode==='binding')Object.defineProperty(mod.G,name,{...saved,value:wrapped});else Object.defineProperty(mod.G,name,{enumerable:true,configurable:true,get(){events.push('get');if(mode==='throw')throw Error('flat fixture sentinel');if(mode==='reentry'&&!entered){entered=true;events.push(['inner',mod.default.bench(0,17)]);}return wrapped;}});
 let value,error;try{value=mod.default.bench(2,17);}catch(e){error={name:e.name,message:e.message};}finally{Object.defineProperty(mod.G,name,saved);}assert.equal(mod.p42FixtureProof(),false);assert.equal(mod.p42FixtureCounts(),before);observations.push({value,error,events});
 }assert.deepEqual(observations[1],observations[0],name+' '+mode);++boundaries;
}
for(const role of Object.keys(mods)){const mod=mods[role],events=[],l=mod.ctor('RLeaf',[7]),r=mod.ctor('RLeaf',[11]),tree={$:'RNode',get a(){events.push('a');return[l,r];},get _0(){throw Error('private slot demanded');}};const before=mod.p42FixtureCounts();assert.deepEqual(decode(mod.default['review.map'](tree,false)),map(node(leaf(7),leaf(11)),false));assert.equal(mod.p42FixtureCounts(),before);assert(events.length>0);assert.deepEqual(mod.default['review.make'](0n,7),{$:'RLeaf',a:[7]});++boundaries;}
for(const input of inputs)assert.equal(identity(input.path).sha256,input.sha256);
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-fixture-controls-v1.mjs'));const report={kind:'phase42-flat-fixture-controls',complete:true,checked:true,producer:identity(import.meta.filename),attempt:identity(path.join(attemptArg,'attempt.json')),inputs,staticRows,guards,oracles,boundaries,scope:'Independent renamed graph scalar entries plus public full-tree and hostile boundaries; all eight unsupported roots refuse flat emission.'};fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:true,oracles,boundaries,out}));
