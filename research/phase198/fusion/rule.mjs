// Observe the plan and emit each accepted complete program with the checked Bend compiler.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {pin,verify} from '../../../selfhost/tools/build/hosted.mjs';

const args=process.argv.slice(2);
const options=Object.fromEntries(Array.from({length:args.length/2},(_,i)=>args.slice(i*2,i*2+2)));
const out=path.resolve(options['--out']), here=path.dirname(fileURLToPath(import.meta.url));
if(!/^Cpus_allowed_list:\s*3$/m.test(fs.readFileSync('/proc/self/status','utf8'))) throw Error('requires CPU3');
fs.mkdirSync(out);
const read=p=>JSON.parse(fs.readFileSync(p));
const auth=read(options['--api']);
if(!auth.complete || !auth.checked || auth.error) throw Error('checked image required');
verify(auth.source);verify(auth.api);
const api=(await import(pathToFileURL(auth.api.file))).default;
const library=read('selfhost/build/phase197/shared-emission-plan01.json').producer.bindingValue;
for(const v of [library.engine,library.base,library.carrier])verify(v);
const readText=p=>fs.readFileSync(p,'utf8');
const base=api.p88_cache_prepare(library.base.file,readText(library.base.file),readText(library.carrier.file),library.stamp);
if(base.$!=='P86PreparationReady') throw Error(base.error);
const refs=read('selfhost/build/phase195/references01/manifest.json').cases;
const expr=refs.find(c=>c.id==='coverage-expression-128').source;
verify(expr);
const marker='# Phase93:';
const original=readText(expr.file);
const scaffold=marker+original.split(marker)[1];
const report={complete:false,api:auth.api,source:auth.source,method:pin(fileURLToPath(import.meta.url)),
  base:library.base,carrier:library.carrier,cases:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const once=(s,a,b)=>{if(s.split(a).length!==2)throw Error('non-unique control '+a);return s.replace(a,b)};
const program=(id)=>{
  if(id==='heldout')return readText(path.join(here,'heldout.bend'))+'\n'+once(scaffold,
    'U32.is_eq(value, 3393903617)','U32.is_eq(value, 1249245991)');
  if(id==='right-square')return once(original,'Mul{e, Add{Lit{U32.mod(seed, 5)}, Lit{1}}}','Mul{e, e}')
    .replace('op: Nat, e: Expr','op: Nat, +e: Expr');
  if(id==='misfold')return once(original,'U32.sub(eval(a), eval(b))','U32.sub(eval(b), eval(a))');
  if(id==='emitted-key')return once(original,'U32.mod(seed, 3)), p37.expr','U32.mod(U32.mul(seed, 3), 5)), p37.expr');
  if(id==='unknown-helper')return once(original,'Lit{U32.mod(seed, 5)}','Lit{p37.scalar(seed)}')
    .replace('def p37.expr.pick','def p37.scalar(seed: U32) -> U32:\n  U32.mod(seed, 5)\n\ndef p37.expr.pick');
  const ref=refs.find(c=>c.id===id);if(!ref)throw Error(id);verify(ref.source);return readText(ref.source.file);
};
for(const id of options['--cases'].split(',')){
  const dir=path.join(out,id);fs.mkdirSync(dir);
  const ref=refs.find(c=>c.id===id);
  const file=ref?ref.source.file:path.join(dir,'main.bend');
  if(!ref)fs.writeFileSync(file,program(id));
  const started=performance.now();
  const plan=api.p86_plan(base.seed,file,readText(file));
  if(plan.$!=='P86PlanReady')throw Error(id+' source error '+plan.error);
  const selection=api.p198e_inspect(plan.request,'bench');
  const row={id,source:pin(file),plan:selection.$,preparationMs:performance.now()-started};
  report.cases.push(row);save();
  const accepted=['coverage-expression-128','coverage-expression-32','heldout','emitted-key'].includes(id);
  if(accepted !== (selection.$==='P198EReady'))throw Error(id+' unexpected '+selection.$);
  if(!accepted || options['--emit']!=='yes')continue;
  const before=performance.now();
  const prepared=api.p169np_plan(plan);
  const machine=api.x181_prepared(prepared);if(machine.error)throw Error(machine.error);
  const insns=api.x188_many(machine.chunks);
  const asm=api.x188_render(insns);
  // Verify the actual word-algebra worker survives final independent admission and selection.
  const encoded=[...'$p198.algebra.bench'].map(c=>c.codePointAt(0)).join('_')+'_';
  const publicID=[...'$direct.bench'].map(c=>c.codePointAt(0)).join('_')+'_';
  const lines=asm.split('\n');
  const findBlock=tail=>{
    const start=lines.findIndex(l=>l.trim().endsWith('FID_'+tail+':'));
    if(start<0)return null;
    const symbol=lines[start].trim().slice(0,-1);
    const stop=lines.findIndex((l,i)=>i>start && l.includes('.size '+symbol+','));
    return {symbol,lines:lines.slice(start,stop<0?lines.findIndex((l,i)=>i>start && l.includes('.globl ')):stop)};
  };
  const worker=findBlock(encoded),dispatcher=findBlock(publicID);
  row.hasWorker=!!worker;
  row.workerCalled=!!worker && !!dispatcher && dispatcher.lines.some(l=>l.includes(worker.symbol) && /\b(callq?|jmpq?)\s/.test(l));
  row.workerFunction=worker?.symbol;row.entries=dispatcher?.lines.filter(l=>/\b(callq?|jmpq?)\s/.test(l));
  save();
  if(!row.workerCalled)throw Error('word-algebra worker missing from public direct call');
  const code=api.x188_assemble(insns);if(code.error)throw Error(code.error);
  const chunks=[];let tail=code.bytes,parts=[];
  while(tail.$==='Con'){
    parts.push(tail.head);tail=tail.tail;
    if(parts.length===65536){chunks.push(Buffer.from(parts));parts=[];}
  }
  if(tail.$!=='Nil')throw Error('object list');
  chunks.push(Buffer.from(parts));
  const obj=path.join(dir,'program.o');fs.writeFileSync(obj,Buffer.concat(chunks));row.object=pin(obj);
  const assembly=path.join(dir,'program.s');fs.writeFileSync(assembly,asm);row.assembly=pin(assembly);
  row.selectionAndEmissionMs=performance.now()-before;save();
}
report.complete=true;save();console.log(report.cases.map(c=>[c.id,c.plan,c.hasWorker]));
