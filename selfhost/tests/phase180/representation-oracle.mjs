// Independent structural representation bridge. No compiler operation executes
// here: only the canonical App record changes shape. Other keys are preserved.
import crypto from 'node:crypto';

const MAX_NODES=2_000_000,MAX_EDGES=8_000_000;
const need=(ok,message)=>{if(!ok)throw Error(message);};
const object=x=>x!==null&&typeof x==='object';
const nil=()=>({$:'Nil'});
const con=(head,tail)=>({$:'Con',head,tail});
function keys(value){
  const out=Reflect.ownKeys(value);
  need(out.every(k=>typeof k==='string'),'symbol key outside finite value ABI');
  for(const key of out){
    const d=Object.getOwnPropertyDescriptor(value,key);
    need(Object.hasOwn(d,'value'),'accessor outside finite value ABI');
    need(d.enumerable||(Array.isArray(value)&&key==='length'),'nonenumerable value key');
  }
  return out.filter(k=>!(Array.isArray(value)&&k==='length')).sort();
}
function shape(value,wanted){
  return object(value)&&!Array.isArray(value)&&JSON.stringify(keys(value))===JSON.stringify([...wanted].sort());
}
const TERM_KEYS=['$','tag','name','id','quant','kids','removed','originBegin','originEnd'];
const APPLY_KEYS=['$','function','argument','originBegin','originEnd'];
const u32=n=>Number.isSafeInteger(n)&&!Object.is(n,-0)&&n>=0&&n<=0xffffffff;
function applyFields(value){
  need(shape(value,APPLY_KEYS),'invalid KApply keys');
  need(object(value.function)&&object(value.argument),'invalid KApply children');
  need(u32(value.originBegin)&&u32(value.originEnd),'invalid KApply span scalars');
}
function canonicalPair(value){
  if(value.$!=='KTerm'||!shape(value,TERM_KEYS)||value.tag!=='App'||value.name!==''||!Object.is(value.id,0)||!Object.is(value.quant,0))return null;
  const a=value.kids,b=a?.tail,c=b?.tail;
  if(!shape(value.removed,['$'])||value.removed.$!=='Nil'||
    !shape(a,['$','head','tail'])||a.$!=='Con'||
    !shape(b,['$','head','tail'])||b.$!=='Con'||
    !shape(c,['$'])||c.$!=='Nil'||!object(a.head)||!object(b.head)||!u32(value.originBegin)||!u32(value.originEnd))return null;
  return [a.head,b.head];
}
function rewrite(root,mode){
  const memo=new WeakMap(),pending=[];let nodes=0,edges=0;
  const visit=value=>{
    if(!object(value)){
      need(['undefined','boolean','number','string','bigint'].includes(typeof value)||value===null,'unsupported scalar');
      return value;
    }
    if(memo.has(value))return memo.get(value);
    need(++nodes<=MAX_NODES,'finite projection node bound');
    const result=Array.isArray(value)?new Array(value.length):{};
    memo.set(value,result);pending.push([value,result]);return result;
  };
  const output=visit(root);
  while(pending.length){
    const [value,result]=pending.pop();let fields;
    if(mode==='expand'&&value.$==='KApply'){
      applyFields(value);
      fields={tag:'App',name:'',id:0,quant:0,
        originBegin:value.originBegin,originEnd:value.originEnd};
      Object.assign(result,{$:'KTerm',...fields,kids:con(visit(value.function),con(visit(value.argument),nil())),removed:nil()});
      edges+=10;
    }else{
      const pair=mode==='compact'?canonicalPair(value):null;
      if(pair){
        Object.assign(result,{$:'KApply',function:visit(pair[0]),argument:visit(pair[1]),originBegin:value.originBegin,originEnd:value.originEnd});
        edges+=4;
      }else for(const key of keys(value)){
        Object.defineProperty(result,key,{value:visit(value[key]),enumerable:true,writable:true,configurable:true});edges++;
      }
    }
    need(edges<=MAX_EDGES,'finite projection edge bound');
  }
  return output;
}
export const expand=value=>rewrite(value,'expand');
export const compact=value=>rewrite(value,'compact');
export const clone=value=>rewrite(value,'clone');

// Sharing choices may differ between implementations. Every scalar and own key
// must still agree; aliases in input snapshots are checked by fingerprint below.
export function exact(left,right){
  const pending=[[left,right]],seen=new WeakMap();let count=0;
  while(pending.length){
    need(++count<=MAX_EDGES,'finite comparison bound');
    const [a,b]=pending.pop();if(Object.is(a,b))continue;
    need(object(a)&&object(b),'different scalar '+String(a)+' / '+String(b));
    need(Array.isArray(a)===Array.isArray(b),'different array/object shape');
    if(Array.isArray(a))need(a.length===b.length,'different array length');
    let partners=seen.get(a);if(partners?.has(b))continue;
    if(!partners){partners=new WeakSet();seen.set(a,partners);}partners.add(b);
    const ak=keys(a),bk=keys(b);need(JSON.stringify(ak)===JSON.stringify(bk),'different keys');
    for(const key of ak)pending.push([a[key],b[key]]);
  }
  return count;
}

// Includes alias topology as well as keys/scalars. Used for retained inputs and
// case provenance, not to require identical allocation/sharing in output values.
export function fingerprint(root){
  const ids=new WeakMap(),pending=[],records=[];let edges=0;
  const encode=value=>{
    if(object(value)){
      if(ids.has(value))return ['ref',ids.get(value)];
      need(pending.length<MAX_NODES,'finite fingerprint node bound');
      const id=pending.length;ids.set(value,id);pending.push(value);return ['ref',id];
    }
    if(value===null)return ['null'];
    const kind=typeof value;
    need(['undefined','boolean','number','string','bigint'].includes(kind),'unsupported fingerprint scalar');
    return [kind,kind==='number'?(Object.is(value,-0)?'-0':String(value)):kind==='undefined'?'':String(value)];
  };
  const first=encode(root);
  for(let i=0;i<pending.length;i++){
    const value=pending[i],fields=[];
    for(const key of keys(value)){need(++edges<=MAX_EDGES,'finite fingerprint edge bound');fields.push([key,encode(value[key])]);}
    records.push([Array.isArray(value)?['array',value.length]:['object'],fields]);
  }
  return crypto.createHash('sha256').update(JSON.stringify([first,records])).digest('hex');
}
