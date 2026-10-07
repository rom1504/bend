// Diagnostic only. Root runs targets under its one process-tree resource guard.
// Usage: node census.mjs CHECKED_ATTEMPT SOURCE [SOURCE...] NEW_PHASE64_OUT
// This records graph shape, not timings or internal function-entry counts.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';

const [attemptArg,...rest]=process.argv.slice(2),outArg=rest.pop(),sources=rest;
assert(attemptArg&&outArg&&sources.length);
const root=path.resolve(import.meta.dirname,'../../../../..');
const out=path.resolve(outArg),raw=path.join(root,'selfhost/build/phase64');
assert(out.startsWith(raw+path.sep)&&!fs.existsSync(out));
fs.mkdirSync(out,{recursive:true});
const hash=x=>createHash('sha256').update(x).digest('hex'),inputs=new Map();
function pin(file,want){const real=fs.realpathSync(file),bytes=fs.readFileSync(real),r={file:real,sha256:hash(bytes),bytes:bytes.length};if(want)assert.equal(r.sha256,want.sha256);if(inputs.has(real))assert.deepEqual(r,inputs.get(real));inputs.set(real,r);return r;}
const report={kind:'phase64-canonical-annotation-shape-census',complete:false,pass:false,diagnosticOnly:true,productionQualified:false,generation:'checked-B1',rows:[],inputs:[],scope:'Unique retained annotation nodes at the real annotate_selected/annotate_book boundary. Exact emitted bytes versus the same uninstrumented checked image. No timing, allocation-byte, dynamic-projection-count or B2 speed claim.'};
function save(){report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');}save();
function shape(value){
  const seen=new Set(),todo=[value],constructors={},tags={},canonical=[],rejected=[];
  while(todo.length){const x=todo.pop();if(!x||typeof x!=='object'||seen.has(x))continue;seen.add(x);assert(seen.size<=2_000_000,'bounded graph census');
    constructors[x.$??'(object)']=(constructors[x.$??'(object)']??0)+1;
    if(x.$==='KTerm'){tags[x.tag]=(tags[x.tag]??0)+1;if(x.tag==='Ann'){
      const exact=x.name===''&&x.id===0&&x.quant===0&&x.originBegin===0&&x.originEnd===0&&x.removed?.$==='Nil'&&x.kids?.$==='Con'&&x.kids.tail?.$==='Con'&&x.kids.tail.tail?.$==='Nil';
      (exact?canonical:rejected).push(x);
    }}
    for(const child of Object.values(x))if(child&&typeof child==='object')todo.push(child);
  }
  const edges=new Set();for(const t of canonical){edges.add(t.kids);edges.add(t.kids.tail);}
  return {uniqueObjects:seen.size,constructors,tags,canonicalAnnotations:canonical.length,noncanonicalAnnotations:rejected.length,uniqueCanonicalChildCons:edges.size,
    model:{canonicalWrapperObjects:canonical.length,childConsObjects:edges.size,compactWrapperObjects:canonical.length,
      maximumRemovedObjects:edges.size,conditionalPayloadSlotsSaved:canonical.length*6+edges.size*2,
      assumptions:'Object/discriminator overhead, scalar/string sharing and Nil allocation excluded. Child Cons removal assumes no other references retain them; ks materialization and rebuilding can offset the saving. Retained graph size is not total allocations.'}};
}
try{
  pin(import.meta.filename);pin(process.execPath);pin(new URL('../../../development/workflow.mjs',import.meta.url).pathname);
  const dir=fs.realpathSync(attemptArg),attempt=pin(path.join(dir,'attempt.json')),m=await verifyAttempt(dir);
  assert(m.checked&&m.config.strictExact);for(const key of ['api','runtime','base','node'])pin(m[key].file,m[key]);assert.equal(pin(process.execPath).sha256,m.node.sha256);
  const driver=pin(path.join(m.snapshot.root,'tools/typed-driver.mjs'));pin(path.join(m.snapshot.root,'tools/base-cache-graph.mjs'));pin(path.join(m.snapshot.root,'src/runtime/js/direct.mjs'));
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
  process.env.BEND_TYPED_API=m.api.file;process.env.BEND_TYPED_RUNTIME=m.runtime.file;process.env.BEND_BASE=m.base.file;
  const D=await import(pathToFileURL(driver.file)),api=await D.loadApi(),module=await import(pathToFileURL(m.api.file));
  assert.equal(module.G,undefined,'Only named-layout images: no ABI conversion hypothesis');assert.equal(await D.loadApi(),api,'Preserve owned API identity');
  report.image={attempt,api:m.api,base:m.base,runtime:m.runtime,node:m.node,driver};save();
  for(const sourceArg of sources){const source=pin(sourceArg),plain=await D.inspect(source.file,{mode:'library',backend:'direct'});assert.equal(plain.status,'ok',plain.diagnostic);assert.equal(plain.checked,true);for(const f of plain.files)pin(f);
    const captures=[],originals=new Map();
    for(const name of ['annotate_selected','annotate_book'])if(typeof api[name]==='function'){
      const fn=api[name];originals.set(name,fn);api[name]=function(...args){const value=fn(...args);captures.push({api:name,input:shape(args[1]??args[0]),output:shape(value)});return value;};
    }
    let observed;try{assert.equal(await D.loadApi(),api);observed=await D.inspect(source.file,{mode:'library',backend:'direct'});}finally{for(const [name,fn]of originals)api[name]=fn;}
    assert(captures.length>0,'Real annotation entry must run');assert.deepEqual(observed,plain,'Observer must preserve the complete driver result');
    for(const f of observed.files)pin(f);report.rows.push({source,pass:true,rawBytesEqual:true,output:{sha256:hash(plain.code),bytes:Buffer.byteLength(plain.code)},captures});save();
  }
  for(const p of inputs.values())pin(p.file,p);report.inputsUnchanged=true;report.complete=report.pass=true;
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}finally{save();}
