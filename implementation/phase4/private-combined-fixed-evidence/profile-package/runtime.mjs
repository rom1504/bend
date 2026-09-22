// PRIVATE image only. No objects/functions can cross the inspect transport.
// Exact application borrows immutable argument arrays instead of copying them.
export function transformPrivateRuntime(source) {
 if(!source.includes('// privateImageMarker:'))throw Error('Private runtime requires an isolated image');
 const original='const fn=(arity,code,env=null,bound=[])=>({arity,code,env,bound});';
 if(source.split(original).length!==2)throw Error('Unexpected fn allocation');
 source=source.replace(original,`class PrivateFunction{constructor(arity,code,env,bound){this.arity=arity;this.code=code;this.env=env;this.bound=bound;}}\nconst fn=(arity,code,env=null,bound=[])=>new PrivateFunction(arity,code,env,bound);`);
 const entry='function apply(f,args){';if(source.split(entry).length!==2)throw Error('Unexpected apply entry');
 source=source.replace(entry,entry+`\n  // Only internally allocated, nonescaping function values qualify. Other\n  // runtime values retain the original type/IO/partial/overapplication paths.\n  if(f instanceof PrivateFunction&&f.bound.length===0&&args.length===f.arity)return f.code.call(f.env,args);`);
 return {source,stats:{privateExactApply:true,skipArgumentCopy:true,brand:'private class',partialAndOverapplication:'original'}};
}
export function transformPrivateProjections(source) {
 let count=0;const names=[];
 source=source.replace(/^G\[("(?:\\.|[^"\\])*")\]=fn\(1,function\(a\)\{return project\("(KTerm|KDef)",a\[0\]\)\.slice\(\)\[(\d+)\];\}\);$/gm,(line,name,ctor,slot)=>{
  if(Number(slot)>=(ctor==='KTerm'?6:9))throw Error('Unexpected record slot');
  count++;names.push(JSON.parse(name));return `G[${name}]=fn(1,function(a){return a[0].a[${slot}];});`;
 });
 if(!count)throw Error('No private projection accessors found');
 return {source,stats:{accessors:count,names,invariant:'KTerm/KDef are immutable positional ADTs built by compiler/ABI encoder; no host graphs accepted by transport'}};
}
