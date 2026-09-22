// Data-graph adversaries are internal test hooks, never part of the public CLI.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';import {identity,verifyIdentity} from '../../private-compiler/common.mjs';
const [preparedArg,outArg]=process.argv.slice(2);if(!outArg)throw Error('Usage: private-combined-test.mjs PREPARED_REPORT NEW_DIRECTORY');
const preparedFile=fs.realpathSync(preparedArg),prepared=JSON.parse(fs.readFileSync(preparedFile));assert.equal(prepared.complete,true);assert.equal(prepared.proofStatus,'fixedpoint');
const api=prepared.source.file,out=path.resolve(outArg);fs.mkdirSync(out);const combined=prepared.variants.find(v=>v.id==='private-combined'),inputs=[identity(preparedFile),identity(api),identity(combined.file),identity(import.meta.filename)],source=fs.readFileSync(api,'utf8');assert.equal(identity(combined.file).sha256,combined.sha256);
const transformed={source:fs.readFileSync(combined.file,'utf8'),stats:combined.stats},file=path.join(out,'combined-test.mjs');fs.writeFileSync(file,transformed.source+'\nexport {privateStableArgs as testStable};\n');
const original=await import(pathToFileURL(api)),memo=await import(pathToFileURL(file)),list=xs=>xs.reduceRight((t,h)=>original.ctor('Con',[h,t]),original.ctor('Nil',[])),term=(tag,kids=[],name='',id=0,quant=0,removed=[])=>original.ctor('KTerm',[tag,name,id,quant,list(kids),list(removed)]),plain=t=>original.call(original.G.core_subst_stable,[t]),cached=t=>memo.testStable([t]);
const normalize=v=>v&&typeof v==='object'&&typeof v.code==='function'?{internalPartial:true,arity:v.arity,boundLength:v.bound.length}:v;
let assertions=0;const same=t=>{let a,b;try{a={value:normalize(plain(t))};}catch(e){a={error:String(e)}}try{b={value:normalize(cached(t))};}catch(e){b={error:String(e)}}assert.deepEqual(b,a);assertions++;return a;};
const zero=term('Num'),variable=term('Var'),lambda=term('Lam',[zero]),nodes=[zero,variable,lambda,term('App',[zero,zero]),term('App',[lambda,zero])];
for(const tag of ['Num','Var','App','Lam','All','Unknown'])for(const count of [0,1,2,3])for(const name of ['','x'])for(const id of [0,1])for(const quant of [0,1])for(const erased of [false,true]){const t=term(tag,Array(count).fill(zero),name,id,quant,erased?['erased-name']:[]);same(t);same(t);}
let random=7;for(let i=0;i<1500;i++){random=(Math.imul(random,1664525)+1013904223)>>>0;const a=nodes[random%nodes.length],b=nodes[(random>>>11)%nodes.length],t=term(['Num','Var','App','Lam','All'][random%5],[a,b]);nodes.push(t);same(t);same(t);}
for(const malformed of [null,undefined,0,false,'KTerm',{$:'Other',a:[]},{$:'KTerm',a:[]}])same(malformed);
const depthOutcomes=[];for(const depth of [128,512,1024]){let deep=zero;for(let i=0;i<depth;i++)deep=term('Lam',[deep]);const observed=same(deep);assert.deepEqual(observed,{value:true});same(deep);depthOutcomes.push({depth,observed});}
const bad=term('Num',[null]);assert.ok(same(bad).error);assert.ok(same(bad).error);
// False cache entries must be hits, not mistaken for absence. Immutability is
// required: this deliberately out-of-contract mutation shows the distinction.
const changed=term('Var');assert.equal(cached(changed),false);changed.a[0]='Num';assert.equal(plain(changed),true);assert.equal(cached(changed),false);assertions+=3;
// Arbitrary mutation is refused by the real JSON worker boundary, not repaired
// by a private graph cache. Public runtime/module itself remains unchanged.
inputs.forEach(verifyIdentity);const report={kind:'private-combined-stability-tests',complete:true,assertions,depthOutcomes,inputs,transformed:identity(file),stats:transformed.stats.stabilityMemo,scope:'Internal immutable graph equivalence and malformed fallback; explicit mutable-graph counterexample retained. No public ABI optimization claim.'};fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:true,assertions}));
