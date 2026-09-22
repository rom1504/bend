import {preparePrivateConstants} from './constants.mjs';
import {transformPrivateProjections,transformPrivateRuntime} from './runtime.mjs';
import {transformPrivateCalls} from './calls.mjs';
export function specializeCompiler(source,hostExports) {
  const constants=preparePrivateConstants(source),projections=transformPrivateProjections(constants.source);
  const calls=transformPrivateCalls(projections.source,{exports:hostExports,mode:'combined'});
  const runtime=transformPrivateRuntime(calls.source);
  return {source:runtime.source,stats:{constants:constants.stats,projections:projections.stats,calls:calls.stats,runtime:runtime.stats}};
}
