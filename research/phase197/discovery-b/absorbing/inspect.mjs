// Read-only capture in an isolated copy of a pinned checked hosted compiler.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const out=process.argv[2], root=process.cwd();
const read=f=>JSON.parse(fs.readFileSync(f,'utf8'));
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
function bytes(p) {
  const b=fs.readFileSync(p.file);
  if(sha(b)!==p.sha256) throw Error('identity '+p.file);
  return b;
}
const prior=read('selfhost/build/phase195/ctor-gate-emission-plan01.json').producer.bindingValue;
const auth=read('selfhost/build/phase197/baseline-api01/report.json');
if(!auth.complete||!auth.checked||sha(fs.readFileSync(process.execPath))!==prior.engine.sha256) throw Error('authority');
const old=bytes(auth.api).toString();
const mark='function $x185_function_copied(_symbol_0, _params_0, _setup_0, _body_0, _ids_0) {';
if(old.split(mark).length!==2) throw Error('capture boundary');
const apiFile=path.join(out,'instrumented.mjs');
fs.writeFileSync(apiFile,old.replace(mark,mark+'\n  globalThis.observe(_symbol_0,_params_0,_setup_0,_body_0);'));
const api=(await import(pathToFileURL(apiFile))).default;
const prep=api.p88_cache_prepare(prior.base.file,bytes(prior.base).toString(),bytes(prior.carrier).toString(),prior.stamp);
if(prep.$!=='P86PreparationReady') throw Error('base');
const refs=read('selfhost/build/phase195/references01/manifest.json').cases;
const result={sourceApi:auth.api,instrumentedSha:sha(fs.readFileSync(apiFile)),cases:[]};
for(const [id,reroot] of [['coverage-bst-64',false],['coverage-unicode-text-64',true]]) {
  const pin=refs.find(x=>x.id===id).source;
  let source=bytes(pin).toString(),filename=pin.file;
  if(reroot) {
    const suffix='def main() -> IO(Unit):\n';
    if(source.split(suffix).length!==2) throw Error('entry');
    source=source.split(suffix)[0]+suffix+'  p88_original_main()\n';
    filename=path.join(out,'text-search.bend');fs.writeFileSync(filename,source);
  }
  const row={id,source:pin,actualSourceSha:sha(source),reroot,workers:[]};
  globalThis.observe=(symbol,params,setup,body)=>{
    const pretty=symbol.replace(/(?:\d+_){2,}/g,m=>String.fromCharCode(...m.slice(0,-1).split('_').map(Number)));
    if(/p113d_.*(?:bst.down|occurs.go|occurs.step)/.test(pretty)) row.workers.push({pretty,params,setup,body});
  };
  const planned=api.p86_plan(prep.seed,filename,source);
  if(planned.$!=='P86PlanReady') throw Error(planned.error);
  const lower=api.p169np_plan(planned);
  if(lower.error) throw Error(lower.error);
  const selected=api.x181_prepared(lower);
  if(selected.error) throw Error(selected.error);
  const asm=api.x188_render(api.x188_many(selected.chunks));
  if(!reroot&&sha(asm)!==sha(fs.readFileSync('selfhost/build/phase195/ctor-gate-emit01/off/coverage-bst-64/program.s'))) throw Error('BST drift');
  result.cases.push({...row,asmSha:sha(asm)});
  fs.writeFileSync(path.join(out,'typed.json'),JSON.stringify(result,null,2)+'\n');
}
