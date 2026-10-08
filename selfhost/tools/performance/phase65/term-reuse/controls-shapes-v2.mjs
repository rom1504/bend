import assert from 'node:assert/strict';
import {controls as originalControls} from './controls.mjs';
import {shallowStable} from './observe-shapes-v2.mjs';
export function controls(api,observer){
  const results=originalControls(api,observer),nil=()=>({$:'Nil'});
  const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil());
  const term=(tag,xs=[],extra={})=>({$:'KTerm',tag,name:'',id:0,quant:0,kids:list(xs),removed:nil(),originBegin:3,originEnd:9,...extra});
  const ref=term('Ref',[],{name:'f'}),v=term('Var',[],{id:8}),lit={$:'KLiteral',kind:'Nat',number:3,text:'',originBegin:2,originEnd:8};
  const cases=[
    ['shallow-nonmatching-var-payload',term('Var',[term('App',[ref,lit])],{id:8}),true],
    ['shallow-matching-var',term('Var',[],{id:99}),false],
    ['shallow-one-child',term('Typ',[ref]),true],
    ['shallow-two-children',term('All',[v,ref],{id:99,quant:2}),true],
    ['shallow-three-children',term('ADT',[ref,lit,v]),false],
    ['shallow-nested-child',term('All',[ref,term('Typ',[ref])]),false],
    ['shallow-canonical-app',term('App',[ref,v]),true],
    ['shallow-app-name',term('App',[ref,v],{name:'old'}),false],
    ['shallow-app-removed',term('App',[ref,v],{removed:list(['x'])}),false],
    ['shallow-app-lambda-head',term('App',[term('Lam'),lit]),false],
    ['shallow-app-zero-children',term('App'),false],
    ['shallow-app-one-child',term('App',[ref]),false],
  ];
  for(const [name,t,want]of cases){const before=structuredClone(t),admitted=shallowStable(t,99);assert.equal(admitted,want,name);if(admitted){assert.equal(observer.stable(t,99),1);assert.deepEqual(api.subst(t,99,lit),t,name)}assert.deepEqual(t,before);results.push({name,operation:'shallow-subst',admitted})}
  observer.reset();return results;
}
