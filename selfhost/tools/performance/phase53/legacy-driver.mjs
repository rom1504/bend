// Successor plans may use this adapter when their contract requires legacy G.
// The selected compiler is still Bend; this never invokes TypeScript.
export * from '../../typed-driver.mjs';
import * as D from '../../typed-driver.mjs';
export const inspect=(input,options={})=>D.inspect(input,{...options,backend:options.backend??'js'});
export const execute=(input,options={})=>D.execute(input,{...options,backend:options.backend??'js'});
