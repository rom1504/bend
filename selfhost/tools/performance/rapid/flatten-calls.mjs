/** Closed-world diagnostic only: the caller explicitly promises that global
 * function objects, their code/env/arity/bound, and G bindings are immutable
 * during execution. This deliberately does NOT preserve the public mutable-G
 * extension mechanism. The compiler emitter requires a separate static proof.
 * No stage is flattened past saturation: that would postpone body effects.
 */
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {globalArities,tokenizeGeneratedDefinition as tokens} from './direct-calls.mjs';

export function transformFlattenCalls(source,{arities={},assumeImmutableGlobals=false}={}){
  if(!assumeImmutableGlobals)throw Error('Flattening requires explicit assumeImmutableGlobals: true');
  const stats={sites:0,partialStagesRemoved:0,byName:{},assumption:'immutable global bindings and function objects during execution'};
  const code=source.split('\n').map(line=>{
    if(!/^G\[|^if\(!Object\.hasOwn\(G,/.test(line))return line;
    const ts=tokens(line),cache=new Map(),candidates=[];
    const argsAt=(start,end)=>{
      const args=[];
      for(let i=start+1;i<end;){
        const begin=i;if(ts[i].text==='.'&&ts[i+1]?.text==='.')return null;
        while(i<end&&ts[i].text!==',')i=ts[i].close===undefined?i+1:ts[i].close+1;
        if(i===begin)return null;
        args.push([ts[begin].start,ts[i-1].end]);if(i<end)i++;
      }
      return args;
    };
    const parse=(start,end)=>{
      const key=start+':'+end;if(cache.has(key))return cache.get(key);
      cache.set(key,null);
      if(ts[start]?.text==='get'&&end===start+6&&ts.slice(start+1,start+5).map(x=>x.text).join(' ')==='( G , '+ts[start+4].text&&ts[start+5]?.text===')'){
        let name;try{name=JSON.parse(ts[start+4].text)}catch{return null;}
        const r={name,args:[],stages:0,get:[ts[start].start,ts[end-1].end]};cache.set(key,r);return r;
      }
      if(!['call','jump'].includes(ts[start]?.text)||ts[start+1]?.text!=='('||ts[start+1].close!==end-1)return null;
      let comma=start+2;
      while(comma<end&&ts[comma].text!==',')comma=ts[comma].close===undefined?comma+1:ts[comma].close+1;
      if(ts[comma+1]?.text!=='['||ts[comma+1].close!==end-2)return null;
      const prior=parse(start+2,comma),args=argsAt(comma+1,end-2);
      if(!prior||!args||prior.kind==='jump')return null;
      const arity=arities[prior.name];
      // An earlier exact application would already have run its function body.
      if(!Number.isInteger(arity)||prior.args.length>=arity||prior.args.length+args.length>arity)return null;
      const r={...prior,args:[...prior.args,...args],stages:prior.stages+1,kind:ts[start].text};cache.set(key,r);return r;
    };
    for(let i=0;i<ts.length;i++)if(['call','jump'].includes(ts[i].text)&&ts[i+1]?.text==='('){
      const parsed=parse(i,ts[i+1].close+1);
      if(parsed?.stages>1)candidates.push({start:ts[i].start,end:ts[ts[i+1].close].end,...parsed});
    }
    candidates.sort((a,b)=>a.start-b.start||b.end-a.end);
    function render(start,end){
      let out='',at=start;
      for(const c of candidates){
        if(c.start<at||c.end>end)continue;
        out+=line.slice(at,c.start)+c.kind+'('+line.slice(...c.get)+',['+c.args.map(([a,b])=>render(a,b)).join(',')+'])';
        at=c.end;stats.sites++;stats.partialStagesRemoved+=c.stages-1;stats.byName[c.name]=(stats.byName[c.name]??0)+1;
      }
      return out+line.slice(at,end);
    }
    return render(0,line.length);
  }).join('\n');
  return {source:code,stats};
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){
  const [input,output,flag]=process.argv.slice(2);
  if(!input||!output||flag!=='--immutable-globals')throw Error('Usage: node flatten-calls.mjs INPUT OUTPUT --immutable-globals');
  if(path.resolve(input)===path.resolve(output))throw Error('Refusing to overwrite original');
  const api=await import(pathToFileURL(path.resolve(input)).href);
  const result=transformFlattenCalls(fs.readFileSync(input,'utf8'),{arities:globalArities(api.G),assumeImmutableGlobals:true});
  fs.mkdirSync(path.dirname(output),{recursive:true});fs.writeFileSync(output,result.source);fs.writeFileSync(output+'.transform.json',JSON.stringify(result.stats,null,2)+'\n');console.log(JSON.stringify(result.stats));
}
