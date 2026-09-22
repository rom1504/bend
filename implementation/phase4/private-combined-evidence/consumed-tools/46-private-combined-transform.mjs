// Compose verified post-specialization deltas once. Original prototypes remain
// unchanged; the adapter must reconstruct stable-only byte-for-byte first.
import assert from 'node:assert/strict';import {specializeCompiler} from '../../private-compiler/transform.mjs';import {privateBooleans} from './private-booleans.mjs';import {privateStableMemo} from './private-stable-memo.mjs';
export function privateCombined(source,exports){
 const base=specializeCompiler(source,exports),booleans=privateBooleans(source,exports),stable=privateStableMemo(source,exports);
 const marker='\n// Cache only complete native Boolean results at the existing call/force boundary.',at=stable.source.indexOf(marker);assert.ok(at>=0);assert.equal(stable.source.indexOf(marker,at+1),-1);const helper=stable.source.slice(at),from='call(get(G,"core_subst_stable"),[',to='privateStableArgs([';
 const apply=text=>{assert.equal(text.split(from).length-1,stable.stats.stabilityMemo.sites,'Unexpected stable-call overlap');return text.replaceAll(from,to);};
 assert.equal(apply(base.source)+helper,stable.source,'Composition does not reproduce the verified tokenized stability transform');
 const combined=apply(booleans.source)+helper;
 return {source:combined,stats:{...booleans.stats,stabilityMemo:stable.stats.stabilityMemo,composition:{specializationsPerVariant:1,referenceDeltaVerified:true,scope:'Boolean matcher and pure stability-call deltas are disjoint; original tokenized transforms and exact body guards are unchanged.'}}};
}
