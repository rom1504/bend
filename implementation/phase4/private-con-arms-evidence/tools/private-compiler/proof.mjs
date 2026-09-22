// A specialization is useful only when its input is a real checked compiler.
// These are provenance consistency checks, not signatures against a malicious
// local builder. Historical reports without these identities are refused.
import fs from 'node:fs';
import path from 'node:path';
import {identity,verifyIdentity,readJson} from './common.mjs';
export function validateProof({proofFile,apiFile,runtimeFile,experimental=false}) {
  const proofIdentity=identity(proofFile),proof=readJson(proofFile);
  if(proof.complete!==true&&!experimental)throw Error('Release images require a completed fixed-point proof');
  const inputs=[proofIdentity,proof.sourceIdentity,proof.base,proof.initialCompiler,proof.driver,...(proof.hostHelpers??[])];
  if(proof.hostHelpers?.length!==4||new Set(proof.hostHelpers.map(x=>path.basename(x.file))).size!==4||!['compiler-abi.mjs','node-resource-args.mjs','native-build.mjs','assemble.mjs'].every(name=>proof.hostHelpers.some(x=>path.basename(x.file)===name)))throw Error('Proof lacks the consumed host helpers');
  for(const input of inputs)verifyIdentity(input);
  for(const helper of proof.hostHelpers)if(fs.realpathSync(path.join(path.dirname(proof.driver.canonicalPath),path.basename(helper.file)))!==helper.canonicalPath)throw Error('Proof helper is not the helper imported by its frozen driver: '+helper.file);
  if(proof.sourceSha256!==proof.sourceIdentity.sha256||path.resolve(proof.source)!==proof.sourceIdentity.file)throw Error('Proof source identity mismatch');
  const runtime=identity(runtimeFile),api=identity(apiFile);
  if(runtime.sha256!==proof.runtimeSha256)throw Error('Runtime does not match the checked proof');
  if(!fs.readFileSync(apiFile,'utf8').startsWith(fs.readFileSync(runtimeFile,'utf8')))throw Error('Checked H does not embed the exact runtime');
  const stages=proof.stages;
  if(!Array.isArray(stages)||!stages.length)throw Error('Proof has no checked stages');
  let previous=proof.initialCompiler.sha256;const verifiedStages=[];
  for(let i=0;i<stages.length;i++) {
    const stage=stages[i];
    // An incomplete final stage is permitted only after a completed selected
    // stage in an explicitly experimental build.
    if(stage.code!==0||stage.signal!==null||stage.inputsVerified!==true){if(experimental&&i>0&&proof.complete!==true)break;throw Error('Proof stage did not complete checked emission');}
    if(stage.compilerSha256!==previous)throw Error('Broken compiler chain in proof');
    const compiler=identity(stage.compiler),output=identity(stage.output);
    if(compiler.sha256!==stage.compilerSha256||output.sha256!==stage.outputSha256)throw Error('Proof stage artifact changed');
    inputs.push(compiler,output);verifiedStages.push(stage);previous=output.sha256;
  }
  const selected=verifiedStages.find(stage=>stage.code===0&&stage.signal===null&&stage.inputsVerified===true&&stage.outputSha256===api.sha256);
  if(!selected)throw Error('Input API is not a verified completed checked stage');
  if(proof.complete===true&&(stages.length<2||stages[0].outputSha256!==stages[1].outputSha256||stages.some(stage=>stage.code!==0||stage.signal!==null||stage.inputsVerified!==true||stage.outputSha256!==stages[0].outputSha256)))throw Error('Completed proof does not establish equal checked self-emissions');
  inputs.push(api,runtime);
  return {proof,proofIdentity,api,runtime,inputs,status:proof.complete===true?'fixedpoint':'checked-stage-proof-pending'};
}
