import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
const out=process.argv[2], r=JSON.parse(fs.readFileSync(path.join(process.argv[3]??out,'api/report.json')));
assert(r.checked && r.complete);
const api=(await import(pathToFileURL(r.api.file))).default;
const ref=JSON.parse(fs.readFileSync('selfhost/build/phase198/progress-native-reproduction01/report.json'));
const [base,,carrier,stamp]=ref.compilerCommand.slice(10);
const source=path.resolve('selfhost/build/phase167/verifier-source03/compiler.bend');
const text=fs.readFileSync(source,'utf8'), read=file=>fs.readFileSync(file,'utf8');
const prep=api.p88_cache_prepare(base,read(base),read(carrier),stamp);
assert.equal(prep.$,'P86PreparationReady');
const plan=api.p86_plan(prep.seed,source,text);
assert.equal(plan.$,'P86PlanReady');
const prepared=api.x198pw_plan(plan);
assert.equal(prepared.error,'');
let c=prepared.cursor;while(c.$!=='P134Public'){assert(c.next);c=c.next;}
const unpack=list=>{const items=[];while(list.$==='Con'){items.push(list.head);list=list.tail;}assert.equal(list.$,'Nil');return items;};
let selected=0,rows=0,applies=0;
const shapes=new Map(),examples=new Map();
for(const seg of unpack(c.segments)){
  rows++; if(api.x202k_shape(seg.body))selected++;
  const body=unpack(seg.body);
  if(!body.some(s=>s.$==='N111Call'&&s.symbol==='p111_rt_apply'))continue;
  applies++;
  const signature=body.map(s=>s.$==='N111Call'?s.symbol:s.$).join('/');
  shapes.set(signature,(shapes.get(signature)??0)+1);
  if(!examples.has(signature))examples.set(signature,{name:seg.name,body});
}
const ordered=[...shapes].sort((a,b)=>b[1]-a[1]);
fs.mkdirSync(out,{recursive:true});
fs.writeFileSync(path.join(out,'census.json'),JSON.stringify({compiler:r.source,sourceSha256:createHash('sha256').update(text).digest('hex'),rows,selected,applies,shapes:ordered.slice(0,12),examples:ordered.slice(0,3).map(([s])=>examples.get(s))},null,2)+'\n');
