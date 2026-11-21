// Recompute semantic lowering independently for this rule; it precedes target rendering.
import fs from 'node:fs';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {pin,verify} from '../../../selfhost/tools/build/hosted.mjs';
const args=process.argv.slice(2),o=Object.fromEntries(Array.from({length:args.length/2},(_,i)=>args.slice(2*i,2*i+2)));
if(!/^Cpus_allowed_list:\s*3$/m.test(fs.readFileSync('/proc/self/status','utf8')))throw Error('requires guarded CPU');
const out=path.resolve(o['--out']);
const read=p=>JSON.parse(fs.readFileSync(p));
fs.mkdirSync(out);
const auth=read(o['--api']);
if(!auth.complete||!auth.checked)throw Error('unchecked');
verify(auth.api);verify(auth.source);
const api=(await import(pathToFileURL(auth.api.file))).default;
const b=read('selfhost/build/phase197/shared-emission-plan01.json').producer.bindingValue;
for(const x of [b.engine,b.base,b.carrier])verify(x);
const txt=p=>fs.readFileSync(p,'utf8');
const seed=api.p88_cache_prepare(b.base.file,txt(b.base.file),txt(b.carrier.file),b.stamp);
if(seed.$!=='P86PreparationReady')throw Error(seed.error);
const manifest=read('selfhost/build/phase198/p199-integrated-native45-01/programs.manifest.json');
const r={complete:false,api:auth.api,source:auth.source,method:pin(fileURLToPath(import.meta.url)),cases:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(r,null,2)+'\n');
for(const id of o['--cases'].split(',')){
  const c=manifest.cases.find(c=>c.id===id);
  verify(c.source);verify(c.products.candidate.generatedSource);
  const dir=path.join(out,id);fs.mkdirSync(dir);
  const started=performance.now();
  const plan=api.p86_plan(seed.seed,c.source.file,txt(c.source.file));
  if(plan.$!=='P86PlanReady')throw Error(plan.error);
  const native=api.x181_prepared(api.p169np_plan(plan));if(native.error)throw Error(native.error);
  const ins=api.x188_many(native.chunks);
  const asm=api.x188_render(ins),core=api.x188_assemble(ins);
  if(core.error)throw Error(core.error);
  const chunks=[];let xs=core.bytes,block=[];
  while(xs.$==='Con'){block.push(xs.head);xs=xs.tail;if(block.length===65536){chunks.push(Buffer.from(block));block=[];}}
  if(xs.$!=='Nil')throw Error('incomplete object');
  chunks.push(Buffer.from(block));
  const object=path.join(dir,'program.o');fs.writeFileSync(object,Buffer.concat(chunks));
  const a=path.join(dir,'program.s');fs.writeFileSync(a,asm);
  const obj=pin(object);
  r.cases.push({id,source:c.source,object:obj,assembly:pin(a),baseline:c.products.candidate.generatedSource,
    objectChanged:obj.sha256!==c.products.candidate.generatedSource.sha256,lowerAndEmitMs:performance.now()-started});
  if(id==='editdist'){
    const symbol='p113d_FID_'+[...'$product.row'].map(s=>s.charCodeAt(0)+'_').join('');
    const frameCount=file=>execFileSync('objdump',['-dw','--no-show-raw-insn','--disassemble='+symbol,file],{encoding:'utf8'}).split('\n').filter(s=>/^\s*[0-9a-f]+:\s+[a-z]/.test(s)&&s.includes('(%rbp)')).length;
    const before=frameCount(c.products.candidate.generatedSource.file),after=frameCount(object);
    r.cases.at(-1).firstWitness={symbol,before,after};
    save();
    if(after>=before)throw Error('hot row did not remove any frame references; inspect checked projection');
  }
  save();
}
r.complete=true;save();console.log(r.cases.map(c=>[c.id,c.objectChanged]));
