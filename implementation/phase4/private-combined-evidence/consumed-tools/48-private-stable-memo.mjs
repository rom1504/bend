// Experimental private-image-only cache for a proven context-free Boolean fact.
// The public runtime and ordinary generated libraries are never transformed.
import {createHash} from 'node:crypto';import {specializeCompiler} from '../../private-compiler/transform.mjs';import {tokenize} from '../../private-compiler/tokens.mjs';
const sha=x=>createHash('sha256').update(x).digest('hex');
const reviewed=Object.freeze({
 core_subst_stable:'b278517ed757a9777aa2644d0ccc4e4d41315a72329460a747e2e0b5a8c034f1',
 core_subst_stable_terms:'b57c645888b293214e53ccd29f865a613790bc7501197bbd79c8346b7a6157d4',
 core_subst_stable_app:'73229cd8b9bfc195190c14350472461518924be0f2ce2ce23c5c038dad1aa673',
 core_subst_stable_app_kids:'f852fda0fce3cd3b6812aac55944d20dcfdce935a8bd2c5960cea9b448bd6b17',
 core_subst_stable_app_tail:'8a3fe6071ff380c6c299fae9f162f51aa10d643b0511b4dd5023127f468f4f6a',
 core_subst_stable_app_last:'d707d0198c8974c721c399489da5e20540d666e783ec3f371ac7386f346bff7a',
});
export function privateStableMemo(source,exports){
 for(const [name,expected] of Object.entries(reviewed)){const lines=source.split('\n').filter(l=>l.startsWith('G['+JSON.stringify(name)+']='));if(lines.length!==1||sha(lines[0])!==expected)throw Error('Unreviewed pure stability worker: '+name);}
 const result=specializeCompiler(source,exports);let sites=0;
 let transformed=result.source.split('\n').map(line=>{
 if(!/^G\[|^function privateWorker/.test(line))return line;
 const ts=tokenize(line),edits=[];
 for(let i=0;i<ts.length;i++){
  if(!['call','jump'].includes(ts[i].text)||ts.slice(i+1,i+10).map(t=>t.text).join(' ')!=='( get ( G , "core_subst_stable" ) , [')continue;
  if(ts[i].text==='jump')throw Error('Stability cache does not transform tail calls');
  const end=ts[i+9].close;if(end+1!==ts[i+1].close)throw Error('Unexpected stability call shape');
  // Require exactly one argument, optionally followed by its emitted comma.
  let j=i+10;if(j===end)throw Error('Missing stability argument');while(j<end&&ts[j].text!==',')j=ts[j].close===undefined?j+1:ts[j].close+1;
  if(j<end&&j+1!==end)throw Error('Overapplied stability call');
  edits.push({start:ts[i].start,end:ts[i+9].start,text:'privateStableArgs('});
 }
 sites+=edits.length;for(const e of edits.reverse())line=line.slice(0,e.start)+e.text+line.slice(e.end);return line;
 }).join('\n');
 if(sites!==5)throw Error('Unexpected stability call-site count: '+sites);
 transformed+=`\n// Cache only complete native Boolean results at the existing call/force boundary.\nconst privateStableCache=new WeakMap();\nfunction privateStableArgs(args){const value=args[0],key=value!==null&&typeof value==='object'&&value.$==='KTerm'&&Array.isArray(value.a)&&value.a.length===6;if(key&&privateStableCache.has(value))return privateStableCache.get(value);const result=call(get(G,"core_subst_stable"),args);if(key&&typeof result==='boolean')privateStableCache.set(value,result);return result;}\n`;
 return {source:transformed,stats:{...result.stats,stabilityMemo:{sites,reviewedWorkers:reviewed,scope:'Private immutable KTerm graphs only; no context/book dependency; original call/force on misses; no tail rewrite.'}}};
}
