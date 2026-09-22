#!/usr/bin/env node
// Build a separate worker-private image. Never overwrite/promote the public API.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {identity,verifyIdentity,writeJson,digest} from './common.mjs';
import {validateProof} from './proof.mjs';
import {specializeProfile} from './profiles.mjs';
export const reviewedRuntimeSha256='26f5eee2f54b194b64f768df6ff505c67bf7a5df2159aa06caf53ecba54e910b';
export function assertSupportedRuntime(source){if(digest(source)!==reviewedRuntimeSha256)throw Error('Runtime revision has not been reviewed for private projection and argument-ownership invariants');}
export async function buildPrivateCompiler({proofFile,apiFile,runtimeFile,output,experimental=false,optimizationProfile='default'}) {
  const started=performance.now();assertSupportedRuntime(fs.readFileSync(runtimeFile));
  const validated=validateProof({proofFile,apiFile,runtimeFile,experimental});
  const out=path.resolve(output);fs.mkdirSync(out,{recursive:false});
  const dirs=['host/tools','runner','provenance'];for(const dir of dirs)fs.mkdirSync(path.join(out,dir),{recursive:true});
  const consumedTools=fs.readdirSync(import.meta.dirname).filter(name=>name.endsWith('.mjs')&&!name.endsWith('.test.mjs')).map(name=>identity(path.join(import.meta.dirname,name)));
  for(const tool of consumedTools)fs.copyFileSync(tool.file,path.join(out,'runner',path.basename(tool.file)));
  const original=fs.readFileSync(apiFile,'utf8');
  // The checked seed API defines the host boundary. Do not accept caller-provided
  // export lists, arbitrary code, or raw graph entrypoints via the request CLI.
  const initial=await import(pathToFileURL(validated.proof.initialCompiler.file));
  const exports=Object.keys(initial.default);
  if(!exports.includes('f_parse')||!exports.includes('check_book')||!exports.includes('j_library'))throw Error('Incomplete checked seed host API');
  const transformed=specializeProfile(original,exports,optimizationProfile);
  fs.writeFileSync(path.join(out,'image.mjs'),transformed.source,{flag:'wx'});
  fs.copyFileSync(runtimeFile,path.join(out,'runtime.mjs'));
  fs.copyFileSync(apiFile,path.join(out,'provenance/public-api.mjs'));
  fs.copyFileSync(proofFile,path.join(out,'provenance/proof.json'));
  fs.copyFileSync(validated.proof.sourceIdentity.file,path.join(out,'provenance/compiler.bend'));
  fs.copyFileSync(validated.proof.initialCompiler.file,path.join(out,'provenance/initial-compiler.mjs'));
  const driver=fs.readFileSync(validated.proof.driver.file,'utf8'),project=/^export const project=.*;$/gm;
  if([...driver.matchAll(project)].length!==1)throw Error('Unknown host cache project declaration');
  const rewritten=driver.replace(project,"export const project=path.resolve(import.meta.dirname,'..');");
  fs.writeFileSync(path.join(out,'host/tools/typed-driver.mjs'),rewritten,{flag:'wx'});
  for(const helper of validated.proof.hostHelpers)fs.copyFileSync(helper.file,path.join(out,'host/tools',path.basename(helper.file)));
  for(const input of [...validated.inputs,...consumedTools])verifyIdentity(input);
  const artifacts=[];
  function visit(dir){for(const entry of fs.readdirSync(dir,{withFileTypes:true})){const file=path.join(dir,entry.name);if(entry.isDirectory())visit(file);else artifacts.push({relative:path.relative(out,file),sha256:identity(file).sha256,bytes:fs.statSync(file).size});}}
  visit(out);
  const manifest={kind:'bend-private-compiler-image',version:1,complete:true,created:new Date().toISOString(),proofStatus:validated.status,
    contract:'Dedicated worker; JSON paths/modes only. No public function objects, interpreter, native mode, callbacks or user-code execution.',
    proof:{...validated.proofIdentity,complete:validated.proof.complete===true,selectedApi:validated.api,initialCompiler:validated.proof.initialCompiler,source:validated.proof.sourceIdentity},
    base:validated.proof.base,runtime:validated.runtime,originalDriver:validated.proof.driver,
    hostRewrite:{only:'project/cache root',originalSha256:digest(driver),copiedSha256:digest(rewritten)},
    exports,optimizationProfile,stats:transformed.stats,inputs:validated.inputs,tools:consumedTools,artifacts,
    node:{...identity(process.execPath),version:process.version},buildMs:performance.now()-started};
  writeJson(path.join(out,'manifest.json'),manifest);
  return {output:out,manifest:path.join(out,'manifest.json'),proofStatus:manifest.proofStatus,imageSha256:identity(path.join(out,'image.mjs')).sha256,buildMs:manifest.buildMs};
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){
 const args=process.argv.slice(2),experimental=args.includes('--experimental');
 const profileFlags=args.filter(x=>x.startsWith('--profile='));if(profileFlags.length>1)throw Error('Repeated profile option');
 const optimizationProfile=profileFlags[0]?.slice(10)??'default';
 const positional=args.filter(x=>!x.startsWith('--'));
 if(positional.length!==4||args.some(x=>x.startsWith('--')&&x!=='--experimental'&&!x.startsWith('--profile=')))throw Error('Usage: build.mjs PROOF_JSON CHECKED_H RUNTIME NEW_IMAGE_DIRECTORY [--experimental] [--profile=default|phase4-boolean-stable]');
 console.log(JSON.stringify(await buildPrivateCompiler({proofFile:positional[0],apiFile:positional[1],runtimeFile:positional[2],output:positional[3],experimental,optimizationProfile})));
}
