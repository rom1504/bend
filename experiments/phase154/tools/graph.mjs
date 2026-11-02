// Identity-preserving generic JSON transport. This does not interpret Bend IR.
import fs from 'node:fs';import assert from 'node:assert/strict';
export function encodeGraph(root,{nodeLimit=1_000_000}={}){
 const ids=new Map(),queue=[],nodes=[];
 const ref=value=>{if(value===null||['string','boolean','number'].includes(typeof value)){assert(typeof value!=='number'||Number.isFinite(value));return value;}
  assert(value&&typeof value==='object'&&!ArrayBuffer.isView(value),'Unsupported transport value');
  if(!ids.has(value)){assert(queue.length<nodeLimit,'Graph node bound exceeded');ids.set(value,queue.length);queue.push(value)}
  return{ref:ids.get(value)};};
 const entry=ref(root);
 for(let i=0;i<queue.length;i++){const value=queue[i];nodes.push(Array.isArray(value)?{array:value.map(ref)}:{object:Object.entries(value).map(([k,v])=>[k,ref(v)])});}
 return{kind:'phase154-object-graph',version:1,root:entry,nodes};
}
export function decodeGraph(graph){
 assert.equal(graph.kind,'phase154-object-graph');assert.equal(graph.version,1);
 const values=graph.nodes.map(n=>Object.hasOwn(n,'array')?[]:{});
 const get=v=>{if(v===null||typeof v!=='object')return v;assert.deepEqual(Object.keys(v),['ref']);assert(Number.isInteger(v.ref)&&v.ref>=0&&v.ref<values.length);return values[v.ref];};
 for(let i=0;i<values.length;i++){const node=graph.nodes[i];if(Object.hasOwn(node,'array'))values[i].push(...node.array.map(get));
  else for(const[k,v]of node.object){assert(typeof k==='string'&&!Object.hasOwn(values[i],k));Object.defineProperty(values[i],k,{value:get(v),enumerable:true,writable:true,configurable:true});}}
 return get(graph.root);
}
export function writeGraph(file,graph,byteLimit=128*1024**2){
 const fd=fs.openSync(file,'wx');let bytes=0;
 const write=s=>{const b=Buffer.from(s);bytes+=b.length;assert(bytes<=byteLimit,'Graph byte bound exceeded');fs.writeSync(fd,b);};
 try{write('{"kind":"phase154-object-graph","version":1,"root":'+JSON.stringify(graph.root)+',"nodes":[\n');
  graph.nodes.forEach((node,i)=>write((i?',\n':'')+JSON.stringify(node)));write('\n]}\n');}finally{fs.closeSync(fd)}
 return bytes;
}
