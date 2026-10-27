// Strict diagnostic only. A hash is evidence about data, not a proof certificate.
import crypto from 'node:crypto';
const identities=new WeakMap();let nextIdentity=1;
const callers=[],records=[];
const identity=value=>{if(!value||typeof value!=='object')return null;if(!identities.has(value))identities.set(value,nextIdentity++);return identities.get(value);};
function fingerprint(root){
 const completed=new WeakMap(),active=new WeakSet();let nodes=0,primitiveBytes=0;
 function primitive(value){
  const typ=typeof value;
  if(value===null)return 'null';
  if(typ==='string'){const text=JSON.stringify(value);primitiveBytes+=Buffer.byteLength(text);if(primitiveBytes>256*1024*1024)throw Error('Fingerprint scalar budget exceeded');return 'string:'+text;}
  if(typ==='boolean')return 'bool:'+value;
  if(typ==='number'&&Number.isFinite(value))return 'number:'+(Object.is(value,-0)?'-0':String(value));
  if(typ==='object')return null;
  throw Error('Unsupported diagnostic input type: '+typ);
 }
 function frame(value){
  if(++nodes>2000000)throw Error('Fingerprint object budget exceeded');
  if(Object.getOwnPropertySymbols(value).length)throw Error('Symbol property in verifier input');
  const array=Array.isArray(value),proto=Object.getPrototypeOf(value);
  if(!array && proto!==Object.prototype && proto!==null)throw Error('Non-data prototype in verifier input');
  let keys=Object.getOwnPropertyNames(value).sort();
  if(array){if(keys.length!==value.length+1 || !keys.includes('length'))throw Error('Sparse/extended array in verifier input');keys=Array.from({length:value.length},(_,i)=>String(i));}
  for(const key of keys){const d=Object.getOwnPropertyDescriptor(value,key);if(!d||!Object.hasOwn(d,'value'))throw Error('Accessor in verifier input');}
  active.add(value);return {value,keys,index:0,digest:crypto.createHash('sha256').update(array?'array:':proto===null?'null-object:':'object:')};
 }
 const p=primitive(root);if(p!==null)return {sha256:crypto.createHash('sha256').update(p).digest('hex'),nodes:0,primitiveBytes};
 const stack=[frame(root)];
 while(stack.length){
  const top=stack.at(-1);
  if(top.index===top.keys.length){const hash=top.digest.digest('hex');completed.set(top.value,hash);active.delete(top.value);stack.pop();continue;}
  const key=top.keys[top.index],value=top.value[key],p=primitive(value);
  if(p!==null){top.digest.update(JSON.stringify(key)+':'+p+';');top.index++;continue;}
  if(completed.has(value)){top.digest.update(JSON.stringify(key)+':object-hash:'+completed.get(value)+';');top.index++;continue;}
  if(active.has(value))throw Error('Cycle in verifier input');stack.push(frame(value));
 }
 return {sha256:completed.get(root),nodes,primitiveBytes};
}
globalThis.__p145scopeEnter=name=>{callers.push(name);};
globalThis.__p145scopeExit=name=>{if(callers.pop()!==name)throw Error('Diagnostic scope mismatch');};
globalThis.__p145verifyBegin=(name,args)=>{
 const row={name,callers:[...callers],arguments:args.map(value=>({identity:identity(value),before:fingerprint(value)}))};records.push(row);return row;
};
globalThis.__p145verifyEnd=(row,args)=>{
 row.arguments.forEach((arg,i)=>{arg.after=fingerprint(args[i]);arg.sameIdentity=arg.identity===identity(args[i]);arg.unchanged=arg.before.sha256===arg.after.sha256;if(!arg.unchanged||!arg.sameIdentity)throw Error('Verifier input changed during verification');});row.completed=true;
};
globalThis.__p145verifiedInputs=records;
