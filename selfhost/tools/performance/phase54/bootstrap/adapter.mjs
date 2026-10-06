// Additive experiment only: a direct compiler already has named host fields.
// Preserve method and graph identity; only select the explicit public keys.
// No method wrapper, graph copy, positional conversion or reinterpretation.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

export const hash = bytes => createHash('sha256').update(bytes).digest('hex');
export const identity = file => ({file:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
export function verify(id) {assert.deepEqual(identity(id.file),id,'Changed input: '+id.file);}
export const list = values => values.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
export function array(xs) {
  const out=[];
  while(xs?.$==='Con') {assert.ok(out.length<100000,'List budget');out.push(xs.head);xs=xs.tail;}
  assert.equal(xs?.$,'Nil');return out;
}

export function directCompilerApi(module,required=[]) {
  assert.equal(module.backend?.kind,'direct-js');
  assert.equal(module.backend?.representation,'upstream-native');
  assert.equal(module.G,undefined,'A positional legacy image is not this experiment');
  assert.equal(module.ctor,undefined);
  const api=module.default;
  assert.ok(api&&typeof api==='object');
  for(const name of required)assert.equal(typeof api[name],'function','Missing export '+name);
  for(const [name,version] of Object.entries({compiler_term_abi:1,compiler_span_abi:3,compiler_load_abi:2,compiler_check_result_abi:2}))
    if(required.includes(name))assert.equal(api[name](),version,name);
  return required.length ? Object.fromEntries(required.map(name=>[name,api[name]])) : api;
}

export async function loadDirectCompiler(image,required=[]) {
  verify(image);
  const url=pathToFileURL(image.file);url.searchParams.set('phase54Sha256',image.sha256);
  const module=await import(url.href);
  const api=directCompilerApi(module,required);
  verify(image);
  return {api,module};
}
