// Leading-lambda reuse must never memoize a computed global initializer.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
const api=(await import(process.env.BEND_JS_BACKEND?pathToFileURL(path.resolve(process.env.BEND_JS_BACKEND)):new URL('../../../build/js-backend.mjs',import.meta.url))).default;
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const t=(tag,name='',kids=[],id=0,quant=0)=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:list([])});
const nat=t('ADT','Nat'),typ=t('All','x',[nat,nat],10,1),lam=t('Lam','x',[t('Var','x',[],10)],10,1);
const def=(name,value,typ)=>({$:'KDef',name,kind:'Def',arity:0,templates:0,typ,value,ctors:list([]),native:false,unsafe:false});
const defs=list([
 def('direct',lam,typ),def('annotated',t('Ann','',[lam,typ]),typ),
 def('computed',t('Let','',[t('Bind','capture',[t('Ref','tick')],11,1),t('Lam','x',[t('Var','capture',[],11)],10,1)]),typ),
 def('rewritten',t('Rwt','',[t('Absent'),t('Absent'),lam]),typ),
 def('matched',t('Mat','Succ',[lam,t('Lam','z',[t('Ctr','Zero')],12,1)]),typ),
 def('computedMatcher',t('Let','',[t('Bind','capture',[t('Ref','tick')],16,1),t('Mat','Succ',[t('Lam','p',[t('Var','capture',[],16)],17,1),t('Lam','z',[t('Ctr','Zero')],18,1)])]),typ),
 def('matchedTick',t('Mat','Succ',[t('Lam','p',[t('App','',[t('Ref','tick'),t('Var','p',[],14)])],14,1),t('Lam','z',[t('Ctr','Zero')],15,1)]),typ),
 def('value',t('Ctr','Zero'),nat)
]);
const directory=new URL('../../../build/js-initializers/',import.meta.url);fs.mkdirSync(directory,{recursive:true});const target=new URL('program.mjs',directory);
const runtime=fs.readFileSync(process.env.BEND_JS_RUNTIME?path.resolve(process.env.BEND_JS_RUNTIME):new URL('../../runtime.mjs',import.meta.url),'utf8');fs.writeFileSync(target,runtime+'\n'+api.j_library(defs));
const {G,call,default:library}=await import(target.href+'?'+Date.now());
if(process.env.BEND_EXPECT_CACHED_LAM){assert.equal(G.direct.arity,1);assert.equal(G.annotated.arity,1);}
for(const name of ['computed','computedMatcher','rewritten','value'])assert.equal(G[name].arity,0,name+' must retain its initializer thunk');
let ticks=0;G.tick={arity:0,code:()=>++ticks,env:null,bound:[]};
assert.equal(call(library.computed(),[0]),1);assert.equal(call(library.computed(),[0]),2);assert.equal(ticks,2);
assert.equal(library.direct(7),7);assert.equal(library.annotated(8),8);assert.equal(library.rewritten(9),9);
assert.equal(G.matched.arity,1);assert.equal(G.matchedTick.arity,1);
assert.equal(library.computedMatcher(3n),3);assert.equal(library.computedMatcher(3n),4);assert.equal(ticks,4,'computed matcher initializer must run on every reference');
let arms=0;G.tick={arity:1,code:args=>{arms++;return args[0]},env:null,bound:[]};
assert.equal(library.matchedTick(4n),3n);assert.equal(library.matchedTick(5n),4n);assert.equal(arms,2,'cached matcher must evaluate its arm on every call');
assert.equal(library.matchedTick(0n),0n);assert.equal(arms,2,'unselected arm must stay delayed');
G.tick={arity:1,code:()=>17n,env:null,bound:[]};assert.equal(library.matchedTick(4n),17n,'forward/global references stay delayed');
console.log('pure Lam/Mat wrappers cached; delayed arms, forward references and Let/Rwt/value reevaluation preserved');
