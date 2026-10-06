// Data-only append: the checked API's original bytes and default export remain
// unchanged. This extra diagnostic export is not a checked compiler artifact.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {identity,verify,hash} from '../../phase54/bootstrap/adapter.mjs';

export const HOST_SHA='783230d83f94c7b4f6a0cb956a10e1974b18ea6ba672490a5cdd357b6f0b1479';
export const CORE_SHA='2bb2e2d60fa08e73532446dfc93eec2e4ac78b32350e7d305a99e2e53dd69fc9';
const helpers={selectedContext:'jd_selected_context',callgraph:'jd_calls_context',valid:'jd_calls_valid',
  definitions:'jd_definitions',exports:'jd_exports',hostExports:'jd_host_exports',failure:'jd_fail'};
export function exposeStages(api,core,host,directory) {
  verify(api);verify(core);verify(host);assert.equal(core.sha256,CORE_SHA,'Library decomposition source changed');
  assert.equal(host.sha256,HOST_SHA,'Host export decomposition source changed');
  const bytes=fs.readFileSync(api.file),source=bytes.toString('utf8');
  assert.equal(Buffer.from(source).compare(bytes),0,'API is not exact UTF-8');
  assert.ok(!source.includes('$phase55Stages'),'Diagnostic export collision');
  for(const name of [...Object.values(helpers),'jd_library_selected','jd_library_context'])
    assert.equal(source.split('function $'+name+'$(').length-1,1,'Expected unique lexical helper '+name);
  assert.equal((source.match(/^function run_loop\(/gm)||[]).length,1,'Expected shared trampoline');
  const entries=Object.entries(helpers).map(([key,name])=>
    key==='failure'?`${key}:(message)=>run_loop($${name}$(message))`:
    key==='valid'?`${key}:(book)=>run_loop($${name}$(book))`:
    `${key}:(book,defs)=>run_loop($${name}$(book,defs))`);
  const suffix='\n// Phase55 diagnostic only: expose the existing library stages.\n'+
    'export const $phase55Stages={'+entries.join(',')+'};\n';
  const target=path.join(directory,'api-stages.mjs');fs.writeFileSync(target,Buffer.concat([bytes,Buffer.from(suffix)]),{flag:'wx'});
  const actual=fs.readFileSync(target);assert.equal(actual.subarray(0,bytes.length).compare(bytes),0);
  verify(api);verify(core);verify(host);
  const receipt={kind:'phase55-append-only-api-stages',source:api,core,host,output:identity(target),
    producer:identity(import.meta.filename),originalPrefixBytes:bytes.length,suffixSha256:hash(Buffer.from(suffix)),
    helpers,scope:'Original checked API bytes/default export unchanged; extra diagnostic closures force only existing helper results.'};
  const file=path.join(directory,'api-stages.json');fs.writeFileSync(file,JSON.stringify(receipt,null,2)+'\n',{flag:'wx'});
  return {api:receipt.output,receipt:identity(file)};
}
