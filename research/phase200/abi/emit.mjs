// Emit checked API code directly and keep only the object and compact receipts.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';
import {pin, verify} from '../../../selfhost/tools/build/hosted.mjs';
const [apiFile, out, ...names] = process.argv.slice(2);
if (!/^Cpus_allowed_list:\s*3$/m.test(fs.readFileSync('/proc/self/status','utf8'))) throw Error('CPU3 required');
const read = p => JSON.parse(fs.readFileSync(p));
const checked = read(apiFile), nativeFile = 'selfhost/build/phase198/p199-integrated-native45-01/programs.manifest.json';
if (!checked.complete || !checked.checked) throw Error('unchecked API');
verify(checked.api); verify(checked.source);
const api = (await import(pathToFileURL(checked.api.file))).default;
const bindingFile = 'selfhost/build/phase197/shared-emission-plan01.json';
const binding = read(bindingFile).producer.bindingValue;
for (const p of [binding.engine,binding.base,binding.carrier]) verify(p);
const text = p => fs.readFileSync(p, 'utf8');
const seed = api.p88_cache_prepare(binding.base.file,text(binding.base.file),text(binding.carrier.file),binding.stamp);
if (seed.$ !== 'P86PreparationReady') throw Error(seed.error);
const catalog = read(nativeFile);
fs.mkdirSync(out);
const report = {complete:false, method:pin(fileURLToPath(import.meta.url)), apiReceipt:pin(apiFile), api:checked.api, checkedSource:checked.source, nativeManifest:pin(nativeFile), binding:pin(bindingFile), cases:[]};
const save = () => fs.writeFileSync(path.join(out,'report.json'), JSON.stringify(report,null,2)+'\n');
for (const id of names) {
  const row = catalog.cases.find(c => c.id === id);
  verify(row.source); verify(row.products.candidate.generatedSource);
  const plan = api.p86_plan(seed.seed,row.source.file,text(row.source.file));
  if (plan.$ !== 'P86PlanReady') throw Error(plan.error);
  const lowered=api.x181_prepared(api.p169np_plan(plan));
  if (lowered.error) throw Error(lowered.error);
  const program=api.x188_assemble(api.x188_many(lowered.chunks));
  if (program.error) throw Error(program.error);
  const chunks=[]; let list=program.bytes, block=[];
  while (list.$ === 'Con') {
    block.push(list.head); list=list.tail;
    if (block.length===65536) {chunks.push(Buffer.from(block));block=[];}
  }
  if (list.$!=='Nil') throw Error('invalid byte sequence');
  chunks.push(Buffer.from(block));
  const file=path.join(out,id+'.o');
  fs.writeFileSync(file,Buffer.concat(chunks));
  const object=pin(file);
  report.cases.push({id, source:row.source,object,baseline:row.products.candidate.generatedSource,
      changed:object.sha256!==row.products.candidate.generatedSource.sha256});
  save();
}
report.complete=true;save();
