// Private compiler ablation: immutable, compiler-owned Nil/Unit singletons.
// This changes public object identity and is NEVER valid for a public library.
import {tokenizeGeneratedDefinition as tokenize} from '../rapid/direct-calls.mjs';
const ctor=`function ctor(k,a){
  if(constructorNative[k]===false)return {$:k,a};
  switch(k){
    case 'True': return true; case 'False': return false;
    case 'Zero': return 0n; case 'Succ':return checkedNat(a[0]+1n);
    case 'SNil':return '';case 'SCon':return (typeof a[0]==='string'?a[0]:String.fromCodePoint(a[0]))+a[1];
    case 'Chr':return checkedChar(a[0]);case 'U32':return unword(a[0]);case 'F32':return bitsFloat(unword(a[0]));
    case 'Tuple':return a.length===2?a:[a[0],ctor('Tuple',a.slice(1))];
    default:return {$:k,a};
  }
}`;
export function transformPrivateNullary(source){
 if(source.includes('privateNullaryNil'))throw Error('Nullary transform already applied');
 if(source.split(ctor).length!==2)throw Error('Unknown constructor runtime');
 for(const name of ['Nil','Unit']){
  const line=`constructorNative["${name}"]=true;constructorOwn["${name}"]="${name}";constructors["${name}"]=[];`;
  if(source.split('\n').filter(x=>x.startsWith(`constructorNative["${name}"]=`)).join('\n')!==line)throw Error('Unknown nullary constructor '+name);
 }
 const stats={Nil:0,Unit:0,requiresPrivateBoundary:true};
 const lines=source.split('\n').map(line=>{
  if(!/^G\["(?:\\.|[^"\\])*"\]=(?:fn\(\d+,function\(|matcher(?:1)?\()/.test(line))return line;
  const ts=tokenize(line),edits=[];
  for(let i=0;i<ts.length;i++){
   if(!['ctor','build'].includes(ts[i].text)||ts[i+1]?.text!=='(')continue;
   let name;try{name=JSON.parse(ts[i+2]?.text);}catch{continue;}
   if(!['Nil','Unit'].includes(name)||ts.slice(i+3,i+7).map(t=>t.text).join('')!==',[])')continue;
   edits.push({start:ts[i].start,end:ts[i+6].end,text:'privateNullary'+name});stats[name]++;i+=6;
  }
  for(const e of edits.reverse())line=line.slice(0,e.start)+e.text+line.slice(e.end);
  return line;
 });
 if(!stats.Nil||!stats.Unit)throw Error('No nullary calls found');
 return {source:lines.join('\n')+'\nconst privateNullaryNil=Object.freeze({$:"Nil",a:Object.freeze([])});\nconst privateNullaryUnit=Object.freeze({$:"Unit",a:Object.freeze([])});\n',stats};
}
