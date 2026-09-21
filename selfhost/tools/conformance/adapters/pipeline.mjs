// Integration boundary for independently implemented front/core/backend ports.
// These adapters must load the port, never the upstream reference compiler.
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const load=async key=>process.env[key] ? import(pathToFileURL(path.resolve(process.env[key]))) : null;
const front=await load('BEND_CONFORMANCE_FRONT');
const core=await load('BEND_CONFORMANCE_CORE');
const backend=await load('BEND_CONFORMANCE_BACKEND');
export const name='composed-port-pipeline';
export const capabilities={
  parse:typeof front?.load==='function',
  check:typeof core?.validate==='function'&&core.capabilities?.check===true,
  interpreter:typeof core?.interpret==='function',
  ...Object.fromEntries(['js','native','metal','cuda'].map(l=>[l,typeof backend?.execute==='function'&&backend.capabilities?.[l]===true])),
  modules:front?.capabilities?.modules===true,foreign:front?.capabilities?.foreign===true,
  dependentTypes:core?.capabilities?.dependentTypes===true,affine:core?.capabilities?.affine===true,
  termination:core?.capabilities?.termination===true,proofs:core?.capabilities?.proofs===true,
};
export async function probe(request) {
  if(!capabilities[request.lane]) return {status:'unsupported',reason:'Pipeline does not implement '+request.lane};
  if(!front) return {status:'unsupported',reason:'No frontend adapter configured.'};
  const parsed=await front.load(request);
  if(parsed.status!=='ok') return {...parsed,phase:parsed.phase||'parse',checked:false};
  if(request.lane==='parse') return {status:'ok',phase:'parse',checked:false,exitCode:0};
  if(!capabilities.check) return {status:'unsupported',reason:'Checked pipeline requires a core validator.'};
  const validated=await core.validate({...request,program:parsed.program});
  const {program:validatedProgram,...validationResult}=validated;
  if(validated.status!=='ok') return {...validationResult,phase:validated.phase||'check',checked:validated.phase!=='parse'&&validated.phase!=='load'};
  const checked={...request,program:validated.program??parsed.program};
  if(request.lane==='check') return {...validationResult,phase:'check',checked:true};
  const result=request.lane==='interpreter' ? await core.interpret(checked) : await backend.execute(checked);
  return {...result,checked:true};
}
