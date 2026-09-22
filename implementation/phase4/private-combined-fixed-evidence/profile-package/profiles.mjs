
import {digest} from './common.mjs';
import {specializeCompiler} from './transform.mjs';
import {privateCombined} from './profile-combined.mjs';
export const reviewedProfileH="b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8";
export function specializeProfile(source,exports,profile='default') {
  if(profile==='default')return specializeCompiler(source,exports);
  if(profile!=='phase4-boolean-stable')throw Error('Unknown private optimization profile: '+profile);
  if(digest(source)!==reviewedProfileH)throw Error('Unreviewed compiler image for phase4-boolean-stable; use default or re-audit the exact source');
  const result=privateCombined(source,exports);
  return {...result,stats:{...result.stats,optimizationProfile:{name:profile,reviewedH:reviewedProfileH,scope:'Experimental private immutable image only; whole-source and broad gates must be recorded separately.'}}};
}
