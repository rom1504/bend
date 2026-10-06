// Data-only join. This does not load an API or execute emitted code.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {identity,verify} from './adapter.mjs';
const [sourceFile,directFile,out]=process.argv.slice(2);
assert.ok(sourceFile&&directFile&&out&&!fs.existsSync(out));
const reports=[sourceFile,directFile].map(f=>JSON.parse(fs.readFileSync(f,'utf8')));
for(const [i,r] of reports.entries()) {
  assert.equal(r.kind,'phase54-direct-compiler-driver');assert.equal(r.complete,true);assert.equal(r.pass,true);
  assert.equal(r.role,i?'direct':'source');for(const x of r.inputs)verify(x);
  for(const x of r.copies)verify(x.after);for(const x of r.outputs||[])verify(x);verify(r.api);
}
const [a,b]=reports;assert.deepEqual(a.config,b.config);assert.deepEqual(a.emission,b.emission);
assert.deepEqual(a.observations.map(x=>x.id),b.observations.map(x=>x.id));
for(let i=0;i<a.observations.length;i++)assert.deepEqual(a.observations[i].value,b.observations[i].value,a.observations[i].id);
const result={kind:'phase54-direct-compiler-driver-comparison',pass:true,complete:true,
 producer:identity(import.meta.filename),helper:identity(new URL('./adapter.mjs',import.meta.url)),
 source:identity(sourceFile),direct:identity(directFile),observations:a.observations.length,
 scope:'Exact ordinary driver observations and JS/C emitted bytes; JS result executed. C emitted only. No compiler fixed-point claim.'};
fs.writeFileSync(out,JSON.stringify(result,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify(result));
