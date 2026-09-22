import path from 'node:path';
import {types} from 'node:util';
export function validateInspectRequest(value) {
  if(!value||typeof value!=='object'||types.isProxy(value)||Object.getPrototypeOf(value)!==Object.prototype)throw Error('Private request must be a plain data record');
  const descriptors=Object.getOwnPropertyDescriptors(value),allowed=new Set(['input','mode','withReport']);
  for(const key of Reflect.ownKeys(descriptors))if(typeof key!=='string'||!allowed.has(key)||!Object.hasOwn(descriptors[key],'value'))throw Error('Unsupported private request field');
  if(typeof descriptors.input?.value!=='string'||!path.isAbsolute(descriptors.input.value)||descriptors.input.value.includes('\0'))throw Error('Private input must be an absolute path');
  if(!['parse','check','compile','library'].includes(descriptors.mode?.value))throw Error('Unsupported private request mode');
  if(descriptors.withReport&&typeof descriptors.withReport.value!=='boolean')throw Error('Private withReport must be Boolean');
  return {input:descriptors.input.value,mode:descriptors.mode.value,withReport:descriptors.withReport?.value??false};
}

export function privateNodeResourceArgs({heapMb=3072}={}) {
 if(!Number.isInteger(heapMb)||heapMb<256||heapMb>16384)throw Error('Heap must be an integer from 256 to 16384 MiB');
 return ['--stack-size=4096','--max-old-space-size='+heapMb];
}
export function validateBatchRequests(values,{timeoutMs=120000}={}) {
 if(!Array.isArray(values)||types.isProxy(values)||values.length<1||values.length>256)throw Error('Finite batch requires 1..256 data requests');
 if(!Number.isInteger(timeoutMs)||timeoutMs<1||timeoutMs>3600000)throw Error('Timeout must be 1..3600000 milliseconds');
 for(const key of Reflect.ownKeys(values))if(key!=='length'&&(typeof key!=='string'||!/^\d+$/.test(key)||Number(key)>=values.length))throw Error('Unsupported batch array field');
 return Array.from({length:values.length},(_,i)=>{
  const entry=Object.getOwnPropertyDescriptor(values,String(i));if(!entry||!Object.hasOwn(entry,'value'))throw Error('Batch entries must be data values');
  const value=entry.value;if(!value||typeof value!=='object'||types.isProxy(value)||Object.getPrototypeOf(value)!==Object.prototype)throw Error('Batch request must be a plain data record');
  const descriptors=Object.getOwnPropertyDescriptors(value),request={};let deadline=timeoutMs;
  for(const key of Reflect.ownKeys(descriptors)){
   const field=descriptors[key];if(typeof key!=='string'||!Object.hasOwn(field,'value'))throw Error('Batch request fields must be data');
   if(key==='timeoutMs')deadline=field.value;else Object.defineProperty(request,key,{value:field.value,enumerable:true});
  }
  if(!Number.isInteger(deadline)||deadline<1||deadline>3600000)throw Error('Request timeout must be 1..3600000 milliseconds');
  return {request:validateInspectRequest(request),timeoutMs:deadline};
 });
}
