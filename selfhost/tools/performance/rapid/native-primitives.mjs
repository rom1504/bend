/** Generated-code experiment: specialize retained scalar runtime primitives.
 * Capture native registration identity/code, keep get before argument effects,
 * guard the complete mutable function ABI, and leave tails/partial calls alone.
 * These expressions reproduce runtime semantics; they are not language folding.
 */
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {tokenizeGeneratedDefinition as tokenize} from './direct-calls.mjs';

export const primitiveExpressions=Object.freeze({
 'U32.add':[2,'Number(a+b)>>>0'], 'U32.sub':[2,'Number(a-b)>>>0'],
 'U32.mul':[2,'Math.imul(a,b)>>>0'], 'U32.div':[2,'b===0?0:Number(Math.floor(a/b))>>>0'],
 'U32.mod':[2,'b===0?a:a%b','typeof a==="number"&&typeof b==="number"'],
 'U32.is_eq':[2,'a===b'], 'U32.is_ne':[2,'a!==b'], 'U32.is_lt':[2,'a<b'],
 'U32.is_le':[2,'a<=b'], 'U32.is_gt':[2,'a>b'], 'U32.is_ge':[2,'a>=b'],
 'U32.min':[2,'a<b?a:b','typeof a==="number"&&typeof b==="number"'],
 'U32.max':[2,'a>b?a:b','typeof a==="number"&&typeof b==="number"'],
 'U32.inc':[1,'(a+1)>>>0'], 'U32.and':[2,'(a&b)>>>0'],
 'U32.or':[2,'(a|b)>>>0'], 'U32.xor':[2,'(a^b)>>>0'], 'U32.not':[1,'(~a)>>>0'],
 'U32.shl':[1,'(a<<1)>>>0'], 'U32.shr':[1,'a>>>1'],
 'U32.shln':[2,'b>=32n?0:(a<<Number(b))>>>0'], 'U32.shrn':[2,'b>=32n?0:a>>>Number(b)'],
 'U32.is_zero':[1,'a===0'],
 'String.eq':[2,'stringEq(a,b)'], 'String.append':[2,'a+b'],
 'String.is_empty':[1,'a.length===0'],
 'Bool.or':[2,'a||b','typeof a==="boolean"&&typeof b==="boolean"'], 'Bool.xor':[2,'a!==b'],
});

function assertRuntime(source){
 const required=[
  "const native=(name,n,f)=>G[name]=fn(n,a=>f(...a));",
  "const cast=type==='Nat'?x=>BigInt(x):type==='F32'?Math.fround:x=>Number(x)>>>0;",
  "const ops={add:(a,b)=>cast(a+b),sub:(a,b)=>type==='Nat'?(a>b?a-b:0n):cast(a-b),mul:(a,b)=>type==='U32'?Math.imul(a,b)>>>0:cast(a*b),div:(a,b)=>b===zero?zero:cast(type==='U32'?Math.floor(a/b):a/b),mod:(a,b)=>b===zero?zero:cast(a%b),is_eq:(a,b)=>a===b,is_ne:(a,b)=>a!==b,is_lt:(a,b)=>a<b,is_le:(a,b)=>a<=b,is_gt:(a,b)=>a>b,is_ge:(a,b)=>a>=b,min:(a,b)=>a<b?a:b,max:(a,b)=>a>b?a:b};",
  "native('U32.mod',2,(a,b)=>b===0?a:a%b);",
  "native('Bool.or',2,(a,b)=>a||b);native('Bool.xor',2,(a,b)=>a!==b);",
  "native('String.eq',2,stringEq);native('String.append',2,(a,b)=>a+b);native('String.is_empty',1,s=>s.length===0);",
  "native('U32.inc',1,n=>(n+1)>>>0);native('U32.and',2,(a,b)=>(a&b)>>>0);native('U32.or',2,(a,b)=>(a|b)>>>0);native('U32.xor',2,(a,b)=>(a^b)>>>0);native('U32.not',1,a=>(~a)>>>0);",
  "native(type+'.is_zero',1,x=>x===zero);",
  "native('U32.shl',1,a=>(a<<1)>>>0);native('U32.shr',1,a=>a>>>1);native('U32.shln',2,(a,n)=>n>=32n?0:(a<<Number(n))>>>0);native('U32.shrn',2,(a,n)=>n>=32n?0:a>>>Number(n));",
 ];
 for(const snippet of required)if(!source.includes(snippet))throw Error('Unexpected runtime primitive implementation: '+snippet.slice(0,80));
}

export function transformNativePrimitives(source){
 if(source.includes('rapidNativeRegistrations'))throw Error('Native primitive transform already applied');
 assertRuntime(source);
 const overridden=new Set([...source.matchAll(/^G\[("(?:\\.|[^"\\])*")\]=/gm)].map(m=>JSON.parse(m[1])));
 const retained=Object.entries(primitiveExpressions).filter(([name])=>!overridden.has(name));
 const entries=new Map(retained.map(([name,spec],id)=>[name,{id,spec}]));
 const stats={mode:'guarded-retained-scalar-primitives',calls:0,primitives:retained.length,byName:{},overriddenSkipped:[...overridden].filter(n=>Object.hasOwn(primitiveExpressions,n)),tailsOptimized:false};
 const rewrite=line=>{
  const ts=tokenize(line),edits=[];
  for(let i=0;i<ts.length;i++){
   if(!['call','callOwned'].includes(ts[i].text)||ts[i+1]?.text!=='('||ts[i+2]?.text!=='get'||ts[i+3]?.text!=='('||ts[i+4]?.text!=='G'||ts[i+5]?.text!==','||ts[i+7]?.text!==')'||ts[i+8]?.text!==','||ts[i+9]?.text!=='[')continue;
   let name;try{name=JSON.parse(ts[i+6].text)}catch{continue;}
   const e=entries.get(name);if(!e)continue;
   const arrayEnd=ts[i+9].close,callEnd=ts[i+1].close;if(arrayEnd+1!==callEnd)continue;
   let count=0,valid=true;
   for(let j=i+10;j<arrayEnd;){count++;if(ts[j].text==='.'&&ts[j+1]?.text==='.'){valid=false;break;}while(j<arrayEnd&&ts[j].text!==',')j=ts[j].close===undefined?j+1:ts[j].close+1;if(j<arrayEnd)j++;}
   if(!valid||count!==e.spec[0])continue;
   edits.push({start:ts[i].start,end:ts[i].end,text:'rapidNativeCall'+e.id},{start:ts[i+9].start,end:ts[i+9].end,text:''},{start:ts[arrayEnd].start,end:ts[arrayEnd].end,text:''});
   stats.calls++;stats.byName[name]=(stats.byName[name]??0)+1;
  }
  for(const e of edits.sort((a,b)=>b.start-a.start))line=line.slice(0,e.start)+e.text+line.slice(e.end);
  return line;
 };
 let result=source.split('\n').map(line=>{
  // Transform deferred bodies only: registration captures initialize later.
  if(/^G\["(?:\\.|[^"\\])*"\]=(?:fn\(\d+,function\(|matcher(?:1)?\()/.test(line)||/^function rapidPosWorker\d+\(/.test(line))return rewrite(line);
  return line;
 }).join('\n');
 result=result.replace("const native=(name,n,f)=>G[name]=fn(n,a=>f(...a));",`const rapidNativeRegistrations=Object.create(null);
const native=(name,n,f)=>{const value=fn(n,a=>f(...a));G[name]=value;rapidNativeRegistrations[name]={value,code:value.code};return value;};`);
 for(const [name,{id,spec:[arity,expression,domain]}] of entries){
  const args=arity===1?'a':'a,b';
  result+=`\nconst rapidNativeEntry${id}=rapidNativeRegistrations[${JSON.stringify(name)}];
function rapidNativeCall${id}(f,${args}){if(f===rapidNativeEntry${id}.value&&f.code===rapidNativeEntry${id}.code&&f.env===null&&f.arity===${arity}&&f.bound.length===0&&!f.io&&!f.typeName${domain?'&&('+domain+')':''})return (${expression});return call(f,[${args}]);}\n`;
 }
 return {source:result,code:result,stats};
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){
 const [input,output]=process.argv.slice(2);if(!input||!output||path.resolve(input)===path.resolve(output))throw Error('Usage: node native-primitives.mjs INPUT DISTINCT_OUTPUT');
 const r=transformNativePrimitives(fs.readFileSync(input,'utf8'));fs.mkdirSync(path.dirname(output),{recursive:true});fs.writeFileSync(output,r.source);fs.writeFileSync(output+'.transform.json',JSON.stringify(r.stats,null,2)+'\n');console.log(JSON.stringify(r.stats));
}
