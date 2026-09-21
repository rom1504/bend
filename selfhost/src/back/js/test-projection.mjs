// Proven record projections retain generic ABI ownership and evaluation order.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
import {loadApi,project} from '../../../tools/typed-driver.mjs';
const api=await loadApi(),list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const t=(tag,name='',kids=[],id=0,quant=0)=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:list([])});
const v=id=>t('Var','',[],id),lam=(id,body)=>t('Lam','',[body],id,2),all=(id,a,b,q=2)=>t('All','',[a,b],id,q),ref=n=>t('Ref',n),app=(a,b)=>t('App','',[a,b]);
const nat=t('ADT','Nat'),record=t('ADT','Record'),fnType=all(8,nat,nat);
const def=(name,value,typ,kind='Def',ctors=[])=>({$:'KDef',name,kind,arity:0,templates:0,typ,value,ctors:list(ctors),native:false,unsafe:false});
const tel=all(1,nat,all(2,fnType,all(3,nat,record)));
const ctor={...def('R',t('Absent'),tel,'Ctr'),arity:3};
const datatype=def('Record',t('Absent'),t('Typ'),'ADT',[ctor]);
const mat=arm=>t('Mat','R',[arm,t('Efq')]);
const select=index=>mat(lam(1,lam(2,lam(3,v(index)))));
const erasedRecord=t('ADT','Erased'),erasedCtor={...def('E',t('Absent'),all(11,nat,all(12,nat,erasedRecord),0),'Ctr'),arity:2};
const defs=list([datatype,def('Erased',t('Absent'),t('Typ'),'ADT',[erasedCtor]),
 def('first',select(1),all(9,record,nat)),def('functionField',select(2),all(9,record,fnType)),def('last',select(3),all(9,record,nat)),
 // Eta-short arm applies f to the final constructor field; it is not a projection.
 def('short',mat(lam(1,lam(2,v(2)))),all(9,record,nat)),
 def('effect',mat(lam(1,lam(2,lam(3,app(ref('tick'),v(1)))))),all(9,record,nat)),
 def('erased',t('Mat','E',[lam(11,lam(12,v(12))),t('Efq')]),all(9,erasedRecord,nat))]);
const directory=path.join(project,'build/projection-tests');fs.mkdirSync(directory,{recursive:true});
const output=path.join(directory,'program.mjs'),runtime=fs.readFileSync(path.join(project,'src/runtime.mjs'),'utf8');
fs.writeFileSync(output,runtime+'\n'+api.j_library(defs));
const {default:a,G}=await import(pathToFileURL(output));
for(const n of ['first','functionField','last'])assert.equal(G[n].arity,1,n+' must have a direct worker');
for(const n of ['first','functionField','last'])assert.match(G[n].code.toString(),/return project\(/);
for(const n of ['short','effect','erased'])assert.doesNotMatch(G[n].code.toString(),/return project\(/,n+' must preserve its generic matcher body');
const calls=[];const f={arity:1,code:args=>{calls.push(args[0]);return args[0]+1n},env:null,bound:[]};
const x={$:'R',a:[7n,f,9n]};
assert.equal(a.first(x),7n);assert.equal(a.last(x),9n);assert.equal(a.functionField(x),f);
assert.equal(a.functionField(x,10n),11n);assert.equal(a.short(x),10n);assert.deepEqual(calls,[10n,9n]);
let ticks=0;G.tick={arity:1,code:args=>{ticks++;return args[0]},env:null,bound:[]};
assert.equal(a.effect(x),7n);assert.equal(a.effect(x),7n);assert.equal(ticks,2);
const reads=[],fields=[7n,f,9n].map((value,i)=>({value,i}));const observed=[];
for(const {value,i} of fields)Object.defineProperty(observed,i,{get(){reads.push(i);return value},enumerable:true});
assert.equal(a.last({$:'R',a:observed}),9n);assert.deepEqual(reads,[0,1,2],'retain field-vector read order');
assert.equal(a.erased({$:'E',a:[null,13n]}),13n);
assert.deepEqual(x.a,[7n,f,9n],'projection must not mutate the field vector');
console.log('record workers, function fields, oversaturation, eta-short/effect/erasure fallbacks and field read order passed');
