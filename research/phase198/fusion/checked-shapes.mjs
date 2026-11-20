// Observe the unmodified, checked p86_plan request before any backend lowering.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';

const args = process.argv.slice(2);
if (args.length !== 2 || args[0] !== '--out') throw Error('expected --out PATH');
const out = path.resolve(args[1]);
fs.mkdirSync(out);
const read = file => JSON.parse(fs.readFileSync(file));
function bytes(pin) {
  const data = fs.readFileSync(pin.file);
  if (data.length !== pin.bytes || crypto.createHash('sha256').update(data).digest('hex') !== pin.sha256)
    throw Error('changed input '+pin.file);
  return data;
}
function list(xs) {
  const a = [];
  while (xs.$ === 'Con') { a.push(xs.head); xs=xs.tail; }
  if(xs.$ !== 'Nil') throw Error('list');
  return a;
}
function term(t) {
  return {t:t.tag,n:t.name,i:t.id,q:t.quant,k:list(t.kids).map(term)};
}
const binding=read('selfhost/build/phase197/shared-emission-plan01.json').producer.bindingValue;
const auth=read('selfhost/build/phase197/combined-api02/report.json');
if(!auth.checked||!auth.complete) throw Error('checked API');
bytes(auth.api);bytes(auth.source);bytes(binding.engine);
const api=(await import(pathToFileURL(auth.api.file))).default;
const base=api.p88_cache_prepare(binding.base.file,bytes(binding.base).toString(),bytes(binding.carrier).toString(),binding.stamp);
if(base.$!=='P86PreparationReady') throw Error('base refused');
const rows=read('selfhost/build/phase195/references01/manifest.json').cases;
const result={complete:false,api:auth.api,source:auth.source,cases:[]};
for(const id of ['coverage-expression-128','coverage-record-aggregation-256']) {
  const src=rows.find(c=>c.id===id).source;
  const plan=api.p86_plan(base.seed,src.file,bytes(src).toString());
  if(plan.$!=='P86PlanReady') throw Error('source refused '+plan.error);
  const row={id,source:src,definitions:[]};
  for(const d of list(plan.request.book)) {
    if(d.$==='KDef' && /^(bench|eval|p37\.(expr|records|aggregate)|Expr\.|U32\.(add|mul|sub)$)/.test(d.name))
      row.definitions.push({name:d.name,kind:d.kind,arity:d.arity,unsafe:d.unsafe,typ:term(d.type ?? d.typ),value:term(d.value)});
  }
  if(!row.definitions.some(d=>d.name==='bench')) throw Error('no entry: '+JSON.stringify(Object.keys(plan.request)));
  result.cases.push(row);
  fs.writeFileSync(path.join(out,'shapes.json'),JSON.stringify(result,null,2)+'\n');
}
result.complete=true;
fs.writeFileSync(path.join(out,'shapes.json'),JSON.stringify(result,null,2)+'\n');
console.log(result.cases.map(c=>[c.id,c.definitions.map(d=>d.name)]));
