import assert from 'node:assert/strict';
export function controls(api, observer) {
  const nil = () => ({$:'Nil'}), list = xs => xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil());
  const term = (tag,kids=[],extra={}) => ({$:'KTerm',tag,name:'',id:0,quant:0,kids:list(kids),removed:nil(),originBegin:11,originEnd:19,...extra});
  const variable = id => term('Var',[],{id}), ref = term('Ref',[],{name:'X'}), value = term('Ref',[],{name:'replacement'});
  const lam = body => ({$:'KLambda',name:'x',id:7,quant:1,kids:list([body]),removed:nil(),originBegin:2,originEnd:8,quantityPresent:{$:'False'}});
  const app = (f,x,extra={}) => term('App',[f,x],extra);
  const literal = {$:'KLiteral',kind:'Nat',number:42,text:'',originBegin:13,originEnd:17};
  const cases = [
    ['closed-composite',term('All',[ref,literal],{id:123,quant:2}),99,1],
    ['nonmatching-var-payload',term('Var',[variable(99)],{id:8}),99,1],
    ['matching-var',variable(99),99,0],
    ['deep-matching-var',term('All',[ref,term('Ctr',[variable(99)])]),99,0],
    ['unmatched-binder-id',term('All',[ref,literal],{id:99}),99,1],
    ['lambda-quantity-absent',lam(ref),99,1],
    ['lambda-quantity-present',{...lam(ref),quantityPresent:{$:'True'}},99,1],
    ['lambda-removed-metadata',{...lam(ref),removed:list(['a','b'])},99,1],
    ['stable-app',app(ref,variable(8)),99,1],
    ['stable-spine',app(app(ref,literal),variable(8)),99,1],
    ['unrelated-id-still-beta',app(lam(ref),literal),99,0],
    ['introduced-lambda',app(variable(99),literal),99,0],
    ['app-name',app(ref,literal,{name:'noncanonical'}),99,0],
    ['app-id',app(ref,literal,{id:7}),99,0],
    ['app-quantity',app(ref,literal,{quant:2}),99,0],
    ['app-removed',app(ref,literal,{removed:list(['x'])}),99,0],
    ['app-zero-children',term('App'),99,0],
    ['app-one-child',term('App',[ref]),99,0],
    ['app-three-children',term('App',[ref,literal,variable(99)]),99,0],
    ['literal',literal,99,1],
    ['nested-ann-type-use',term('Ann',[ref,variable(99)]),99,0],
  ];
  const results=[];
  for(const [name,t,id,want] of cases){
    observer.reset(); const before=structuredClone(t), replacement=name==='introduced-lambda'?lam(variable(7)):value;
    const admitted=observer.stable(t,id);assert.equal(admitted,want,name);
    const result=api.subst(t,id,replacement);if(admitted===1)assert.deepEqual(result,t,name);
    assert.deepEqual(t,before,name+' input immutable');results.push({name,operation:'subst',admitted,exactAdmittedResult:admitted===1});
  }
  const betaCases=[
    ['beta-stable-spine',app(app(ref,literal),variable(8)),1],
    ['beta-argument-not-visited',app(ref,app(lam(ref),literal)),1],
    ['beta-spine-redex',app(app(lam(lam(ref)),literal),literal),0],
    ['beta-metadata',app(ref,literal,{quant:1}),0],
    ['beta-one-child',term('App',[ref]),0],
    ['beta-three-children',term('App',[ref,literal,literal]),0],
    ['beta-leaf',literal,1],
  ];
  for(const [name,t,want] of betaCases){observer.reset();const before=structuredClone(t),admitted=observer.betaStable(t);assert.equal(admitted,want,name);const result=api.core_beta(t);if(admitted===1)assert.deepEqual(result,t,name);assert.deepEqual(t,before);results.push({name,operation:'core_beta',admitted,exactAdmittedResult:admitted===1});}
  observer.reset(); return results;
}
