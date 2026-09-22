// Experimental pair-keyed wnf memo. This is not a public graph API optimizer.
import {createHash} from 'node:crypto';import {specializeCompiler} from '../../private-compiler/transform.mjs';import {privateStableMemo} from './private-stable-memo.mjs';
const reviewedH='b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8';
export function privateWnfMemo(source,exports,{stable=false}={}){
 if(createHash('sha256').update(source).digest('hex')!==reviewedH)throw Error('Unreviewed compiler image for private wnf memo');
 const result=stable?privateStableMemo(source,exports):specializeCompiler(source,exports),line=source.split('\n').find(l=>l.startsWith('G["wnf"]=fn(2,function(a){'));
 const vars=/^G\["wnf"\]=fn\(2,function\(a\)\{const (x\d+)=a\[0\];const (x\d+)=a\[1\];/.exec(line??'');if(!vars)throw Error('Unreviewed wnf worker shape');
 const prefix=new RegExp('^function privateWorker(\\d+)\\(privateArg0,privateArg1\\)\\{const '+vars[1]+'=privateArg0;const '+vars[2]+'=privateArg1;','m'),m=prefix.exec(result.source);if(!m)throw Error('Missing specialized wnf worker');const id=m[1],original=`function privateCall${id}(privateArg0,privateArg1){return force(privateWorker${id}(privateArg0,privateArg1));}`;
 if(result.source.split(original).length!==2)throw Error('Ambiguous specialized wnf force boundary');
 const replacement=`function privateCall${id}(privateArg0,privateArg1){const key=privateArg0!==null&&typeof privateArg0==='object'&&privateArg1!==null&&typeof privateArg1==='object'&&privateArg1.$==='KTerm'&&Array.isArray(privateArg1.a)&&privateArg1.a.length===6;let cache=key?privateWnfCache.get(privateArg0):null;if(cache&&cache.has(privateArg1))return cache.get(privateArg1);const result=force(privateWorker${id}(privateArg0,privateArg1));if(key&&result!==null&&typeof result==='object'&&result.$==='KTerm'&&Array.isArray(result.a)&&result.a.length===6){if(!cache){cache=new WeakMap();privateWnfCache.set(privateArg0,cache);}cache.set(privateArg1,result);}return result;}`;
 return {source:result.source.replace(original,replacement)+'\nconst privateWnfCache=new WeakMap();\n',stats:{...result.stats,wnfMemo:{worker:Number(id),reviewedH,stable,scope:'Completed immutable KTerm result keyed by both book and term identities; existing non-tail force boundary; tail workers unchanged; no g_wnf or freshening cache.'}}};
}
