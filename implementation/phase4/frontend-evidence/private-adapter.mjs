// Loaded in a conformance worker. Only JSON observations leave that worker;
// private compiler function objects and graphs never cross this boundary.
import path from 'node:path';
import {inspect,loadApi,apiPath,basePath,runtimePath,driverPath,compilerAbiPath,nodeResourceArgsPath} from './host/tools/typed-driver.mjs';
export const name='phase4-data-only-frontend';
export const capabilities={parse:true,check:true,interpreter:false,js:false,native:false,metal:false,cuda:false,
  modules:true,foreign:true,dependentTypes:true,affine:true,termination:true,proofs:true};
export const artifacts={compiler:apiPath,base:basePath,runtime:runtimePath,driver:driverPath,compilerAbi:compilerAbiPath,nodeResources:nodeResourceArgsPath,
  nativeBuild:path.join(path.dirname(driverPath),'native-build.mjs'),assemble:path.join(path.dirname(driverPath),'assemble.mjs')};
export const persistentLanes=['parse','check'];
async function observe({test,lane},api) {
  if(!persistentLanes.includes(lane))throw Error('This private boundary only accepts parse/check');
  const result=await inspect(test.file,{api,mode:lane});
  if(Object.hasOwn(result,'code'))throw Error('Unexpected code in frontend result');
  return result;
}
export const probe=request=>observe(request,null);
export async function createPersistentSession(){const api=await loadApi();return {probe:request=>observe(request,api)};}
