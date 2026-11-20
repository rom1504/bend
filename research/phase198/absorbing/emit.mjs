// Checked Bend owns preparation, lowering, instruction selection, and ELF assembly.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {pin,verify} from '../../../selfhost/tools/build/hosted.mjs';
if(!/^Cpus_allowed_list:\s*3$/m.test(fs.readFileSync('/proc/self/status','utf8')))throw Error('CPU3 guard required');
const options=Object.fromEntries(Array.from({length:(process.argv.length-2)/2},(_,i)=>process.argv.slice(2+i*2,4+i*2)));
const out=path.resolve(options['--out']), current=path.resolve(options['--api']);
const here=path.dirname(fileURLToPath(import.meta.url));
const read=p=>JSON.parse(fs.readFileSync(p));
const roles={base:'selfhost/build/phase197/baseline-api01/report.json',candidate:current},apis={},auth={};
for(const [k,f] of Object.entries(roles)) {
  auth[k]=read(f);
  if(!auth[k].checked||!auth[k].complete||auth[k].error)throw Error(k+' authority');
  verify(auth[k].api);verify(auth[k].source);
  apis[k]=(await import(pathToFileURL(auth[k].api.file))).default;
}
const parent=read(options['--closure']);
for(const input of parent.inputs)verify(input);
const binding=parent.producer.bindingValue;
verify(binding.engine);verify(binding.base);verify(binding.carrier);
if(fs.realpathSync(binding.engine.file)!==fs.realpathSync(process.execPath))throw Error('engine pin');
const nativeReceipt=pin('selfhost/build/phase195/native45-01/report.json');
const referenceReceipt=pin('selfhost/build/phase195/references01/manifest.json');
const n1=read(nativeReceipt.file).rows, ref=read(referenceReceipt.file).cases;
const selected=options['--cases'].split(',');
if(parent.producer.source.sha256!==auth.base.source.sha256 || parent.roles[0].source.sha256!==auth.candidate.source.sha256 ||
   parent.producer.preparationIdentity.sha256!==parent.roles[0].preparationIdentity.sha256)throw Error('different preparation closure');
fs.mkdirSync(out,{recursive:false});
const report={complete:false,nativeReceipt,referenceReceipt,preparedClosure:pin(path.resolve(options['--closure'])),driver:pin(fileURLToPath(import.meta.url)),roles:{},cases:[]};
for(const [k,v] of Object.entries(roles))report.roles[k]={authority:pin(path.resolve(v)),source:auth[k].source,api:auth[k].api};
function save(){fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');}
function bytes(xs){
  const chunks=[];let c=[],count=0;
  for(;xs.$==='Con';xs=xs.tail){
    if(++count>64*1024*1024||!Number.isInteger(xs.head)||xs.head<0||xs.head>255)throw Error('invalid object bytes');
    c.push(xs.head);if(c.length===65536){chunks.push(Buffer.from(c));c=[];}
  }
  if(xs.$!=='Nil'||!count)throw Error('unterminated or empty bytes');
  if(c.length)chunks.push(Buffer.from(c));
  return Buffer.concat(chunks);
}
const base=apis.base.p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);
if(base.$!=='P86PreparationReady')throw Error(base.error);
for(const id of selected) {
  const folder=path.join(out,id);fs.mkdirSync(folder);
  let source, expected, inputs, authored={};
  if(['drain','saturate'].includes(id)){
    const template=ref.find(r=>r.id==='coverage-numeric-recurrence-256').source;
    verify(template);
    const marker='# Phase93: fixed catalog inputs';
    const original=fs.readFileSync(template.file,'utf8'), suffix=original.slice(original.indexOf(marker));
    if(!original.includes(marker)||suffix.split('2747714257').length!==2)throw Error('template');
    const prefix=pin(path.join(here,id+'.bend'));
    inputs=[256,17]; expected=id==='drain'?125:22;
    source=path.join(folder,'source.bend');
    fs.writeFileSync(source,fs.readFileSync(prefix.file,'utf8')+'\n'+suffix.replace('2747714257',String(expected)));
    authored={prefix,template};
  } else {
    const f=ref.find(r=>r.id===id);verify(f.source);source=f.source.file;
    expected=Number(f.point.expectedStdout.trim());inputs=f.point.runtimeArgs;
  }
  const text=fs.readFileSync(source,'utf8');
  const original=apis.base.p86_plan(base.seed,source,text);
  function refused(stage,reason) {
    if(!authored.prefix)throw Error(id+' '+stage+' '+reason);
    report.cases.push({id,source:pin(source),authored,inputs,expected,refusal:{stage,reason}});
    save();
  }
  if(original.$!=='P86PlanReady'){refused('frontend',original.error);continue;}
  const prep=apis.base.p169np_plan(original);
  if(prep.$!=='P169Prepared'||prep.error){refused('lowering',prep.error);continue;}
  // Same first-order prepared value across roles. Refuse accessors or exotic prototypes.
  const seen=new WeakSet(), queue=[prep];let objectCount=0;
  while(queue.length){const v=queue.pop();if(v===null||['string','number','boolean','bigint'].includes(typeof v))continue;
    if(typeof v!=='object'||Array.isArray(v))throw Error('non-data prepared value');
    if(seen.has(v))continue;seen.add(v);if(++objectCount>2000000)throw Error('prepared bound');
    if(Object.getPrototypeOf(v)!==Object.prototype&&Object.getPrototypeOf(v)!==null)throw Error('prepared record');
    for(const key of Reflect.ownKeys(v)){const d=Object.getOwnPropertyDescriptor(v,key);if(typeof key!=='string'||!Object.hasOwn(d,'value'))throw Error('accessor or symbol');queue.push(d.value);}
    Object.freeze(v);}
  const entry={id,source:pin(source),authored,inputs,expected,objectCount,products:{}};
  for(const [role,api] of Object.entries(apis)){
    const r=api.x181_prepared(prep);if(r.error)throw Error(id+' selection '+r.error);
    const seq=api.x188_many(r.chunks),s=api.x188_render(seq),o=api.x188_assemble(seq);
    if(o.error)throw Error(id+' object '+o.error);
    const asm=path.join(folder,role+'.s'),obj=path.join(folder,role+'.o');
    fs.writeFileSync(asm,s);fs.writeFileSync(obj,bytes(o.bytes));
    entry.products[role]={assembly:pin(asm),object:pin(obj)};
  }
  const published=n1.find(r=>r.id===id);
  if(published){verify(published.object);if(published.object.sha256!==entry.products.base.object.sha256)throw Error('baseline object '+id);
    entry.qualified=published.artifact;}
  entry.changed=entry.products.base.object.sha256!==entry.products.candidate.object.sha256;
  report.cases.push(entry);save();
}
for(const input of parent.inputs)verify(input);
report.complete=true;save();
