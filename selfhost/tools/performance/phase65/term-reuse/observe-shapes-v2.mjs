// Successor diagnostic; consumed v1 observer remains unchanged.
import {makeObserver as makeOriginalObserver, symbol} from './observe.mjs';
export {symbol};
const tag=t=>t.$==='KLambda'?'Lam':t.$==='KLiteral'?'Lit':t.tag;
function children(t){return t.$==='KLiteral'?null:t.kids}
function leaf(t,id){
  if(tag(t)==='Var')return t.id!==id; // Existing substitution ignores Var payloads.
  return t.$==='KLiteral'||(tag(t)!=='App'&&children(t)?.$==='Nil');
}
export function shallowStable(t,id){
  if(leaf(t,id))return true;
  if(tag(t)==='Var')return false;
  const k=children(t);if(k?.$!=='Con'||!leaf(k.head,id))return false;
  if(k.tail?.$==='Nil')return tag(t)!=='App';
  if(k.tail?.$!=='Con'||k.tail.tail?.$!=='Nil'||!leaf(k.tail.head,id))return false;
  return tag(t)!=='App'||(t.name===''&&t.id===0&&t.quant===0&&t.removed?.$==='Nil'&&tag(k.head)!=='Lam');
}
export function makeObserver(){
  const inner=makeOriginalObserver();let enabled=false,scope='outside-api',buckets=new Map();
  function bucket(){let x=buckets.get(scope);if(!x){x={};buckets.set(scope,x)}return x}
  function count(name,n=1){const b=bucket();b[name]=(b[name]??0)+n}
  function phase(name){const old=inner.phase(name);scope=name;return old}
  function reset(){inner.reset();scope='outside-api';buckets=new Map()}
  function note(op,t,id){
    inner.note(op,t,id);if(!enabled||op!=='subst')return;
    if(tag(t)==='Var'){count('varEntries');return}
    if(leaf(t,id)){count('nonVarLeafEntries');count('nonVarLeafTag.'+tag(t));return}
    const k=children(t);if(k?.$!=='Con')return;
    let arity=0,rest=k,shape=[];while(rest?.$==='Con'&&arity<4){arity++;shape.push(tag(rest.head));rest=rest.tail}
    const arityName=arity===4?'4+':String(arity),key=tag(t)+'/'+arityName;
    const stable=inner.stable(t,id);count('compositeArity.'+key);
    if(stable===1){count('stableArity.'+key);count('stableShape.'+key+'/'+shape.join(','))}
    if(shallowStable(t,id)){
      if(stable===0)throw Error('Shallow predicate must imply full stable predicate');
      count('shallowStableParents');count('shallowStableCons',arity);count('shallowStableTag.'+tag(t));
      if(tag(t)==='App'){count('shallowStableExtraAppParents');count('shallowStableExtraAppCons',2)}
      count('shallowStableShape.'+key+'/'+shape.join(','));
    }
  }
  return {note,phase,reset,stable:inner.stable,betaStable:inner.betaStable,
    active(value){enabled=value;inner.active(value)},
    snapshot(){return {...inner.snapshot(),shallowShapes:Object.fromEntries(buckets)}}};
}
