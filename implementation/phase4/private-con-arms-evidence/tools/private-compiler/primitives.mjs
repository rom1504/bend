// Exact runtime expressions, only used inside a sealed compiler worker.
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

export function assertRuntime(source){
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
