import path from 'node:path';
import {pathToFileURL} from 'node:url';
const api=(await import(process.env.BEND_JS_BACKEND?pathToFileURL(path.resolve(process.env.BEND_JS_BACKEND)):new URL('../../../build/js-backend.mjs',import.meta.url))).default;
import fs from 'node:fs';
import assert from 'node:assert/strict';
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const t=(tag,name='',kids=[],id=0,quant=0)=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:list([])});
const all=(name,id,a,b,q=1)=>t('All',name,[a,b],id,q);
const unit=t('ADT','Unit'),chr=t('ADT','Char'),u32=t('ADT','U32'),tree=t('ADT','Tree');
const io=a=>all('R',30,t('Typ'),all('k',31,all('v',32,a,t('ADT','IO.OP',[t('Var','R',[],30)])),t('ADT','IO.OP',[t('Var','R',[],30)])),0);
const def=(name,value,typ,arity=0)=>({$:'KDef',name,kind:'Def',arity,templates:0,typ,value,ctors:list([]),native:false,unsafe:false});
const importedTree=t('ADT','M.Tree'),importedPair=t('ADT','M.Pair');
const listType=t('ADT','List',[t('Qua','',[],0,2),u32]);
const defs=list([
 {$:'KDef',name:'M.Pair',kind:'ADT',arity:0,templates:0,typ:t('Typ'),value:t('Absent'),ctors:list([{...def('M.Tuple',t('Absent','Tuple'),all('value',1,chr,importedPair)),kind:'Ctr',arity:1}]),native:false,unsafe:false},
 def('M.tuple',t('Foreign','tuple',[t('Path','\"x.js\"')]),io(importedPair)),
 {$:'KDef',name:'M.Tree',kind:'ADT',arity:0,templates:0,typ:t('Typ'),value:t('Absent'),ctors:list([{...def('M.Leaf',t('Absent','Leaf'),all('value',1,chr,importedTree)),kind:'Ctr',arity:1}]),native:false,unsafe:false},
 def('M.give',t('Foreign','give',[t('Path','\"x.js\"')]),io(importedTree)),
 def('M.take',t('Foreign','take',[t('Path','\"x.js\"')]),all('x',2,importedTree,io(chr)),1),
 {$:'KDef',name:'Tree',kind:'ADT',arity:0,templates:0,typ:t('Typ'),value:t('Absent'),ctors:list([{...def('Leaf',t('Absent'),all('value',1,chr,tree)),kind:'Ctr',arity:1}]),native:false,unsafe:false},
 def('deep',t('Foreign','',[t('Path','\"x.js\"')]),io(listType)),
 def('opaque',t('Foreign','',[t('Path','\"x.js\"')]),io(listType)),
 def('opaque_sum',t('Foreign','',[t('Path','\"x.js\"')]),all('xs',41,listType,io(u32)),1),
 def('sum',t('Foreign','',[t('Path','\"x.js\"')]),all('xs',40,listType,io(u32)),1),
 def('give',t('Foreign','',[t('Path','"x.js"')]),io(tree)),
 def('take',t('Foreign','',[t('Path','"x.js"')]),all('x',2,tree,io(chr)),1),
 def('bump',t('Foreign','',[t('Path','"x.js"')]),io(u32)),
 def('peek',t('Foreign','',[t('Path','"x.js"')]),io(u32)),
 def('missing',t('Foreign','',[t('Path','"x.js"')]),io(u32)),
 def('invoke',t('Foreign','',[t('Path','"x.js"')]),all('f',8,all('A',10,t('Typ'),all('x',11,u32,u32),0),io(u32)),1),
]);
const sources=list([t('Source','"x.js"',[t('Text',"function tuple(){return {$:'Tuple',value:'q'}}function opaque(){let x={$:'Nil'};for(let i=0;i<50000;i++)x={$:'Con',$0:i&255,$1:x};return x}function opaque_sum(x){let n=0;while(x.$==='Con'){n+=x.$0;x=x.$1}return n}function deep(){let x={$:'Nil'};for(let i=49999;i>=0;i--)x={$:'Con',head:i,tail:x};return x}function sum(x){let n=0;while(x.$==='Con'){n+=x.head;x=x.tail}return n}let state=0;function give(){return {$:'Leaf',value:'é'}}function take(x){return x.value+'x'}function bump(){return ++state}function peek(){return state}function invoke(f){return f(7)}")])]);
fs.writeFileSync(new URL('../../../build/foreign-emitted.mjs',import.meta.url),fs.readFileSync(process.env.BEND_JS_RUNTIME?path.resolve(process.env.BEND_JS_RUNTIME):new URL('../../runtime.mjs',import.meta.url),'utf8')+'\n'+api.j_modules(defs,sources)+api.j_library(defs));
const {default:lib,G,call}=await import('../../../build/foreign-emitted.mjs?'+Date.now());
assert.deepEqual(await lib['M.tuple']().io(),{$:'M.Tuple',a:['q']});
const imported=await lib['M.give']().io();assert.equal(imported.$,'M.Leaf');assert.equal(await lib['M.take'](imported).io(),'éx');
const value=await lib.give().io();assert.deepEqual(value,{$:'Leaf',a:['é']});assert.equal(await lib.take(value).io(),'éx');assert.equal(await lib.bump().io(),1);assert.equal(await lib.peek().io(),1);
const f={arity:1,code:a=>({arity:1,code:a=>a[0]+100,bound:[]}),bound:[]};assert.equal(await lib.invoke(f).io(),107);
assert.equal(await lib.sum(await lib.deep().io()).io(),1249975000);
assert.equal(await lib.opaque_sum(await lib.opaque().io()).io(),6367960);
assert.throws(()=>lib.missing().io(),/missing JavaScript foreign implementation: missing/);
console.log('foreign imports/constructors/Char/shared state/erased closures/50000-cell list passed');
