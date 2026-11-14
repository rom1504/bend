// Request-local transport only: every compiler decision stays in checked Bend APIs.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../../tools/build/hosted.mjs';

const args={};
for(let i=2;i<process.argv.length;i+=2){
  const key=process.argv[i]?.slice(2),value=process.argv[i+1];
  need(process.argv[i]?.startsWith('--')&&['plan','out'].includes(key)&&value&&!Object.hasOwn(args,key),'Unique --plan/--out values required');
  args[key]=value;
}
need(args.plan&&args.out,'--plan and --out required');
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const planPin=pin(args.plan),plan=read(planPin.file),out=path.resolve(args.out);
need(plan.kind==='phase195-shared-preparation-plan'&&plan.complete===true&&plan.version===1,'Frozen shared-preparation plan required');
need(plan.roles.length>=1&&plan.roles.length<=4&&plan.cases.length>=1&&plan.cases.length<=6,'Bounded batch required');
need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'Fresh guarded build root required');
const clock=()=>performance.now()/1000;
const identity=data=>({bytes:Buffer.byteLength(data),sha256:crypto.createHash('sha256').update(data).digest('hex')});
const equal=(a,b)=>a.bytes===b.bytes&&a.sha256===b.sha256;
const unique=xs=>[...new Map(xs.map(x=>[x.file,x])).values()];
const authorityFiles=new Set([plan.producer,...plan.roles].map(r=>r.receipt.file));
const inputs=unique([planPin,...plan.inputs]);
inputs.forEach(verify);
need(inputs.some(x=>x.file===fs.realpathSync(fileURLToPath(import.meta.url))&&equal(x,pin(fileURLToPath(import.meta.url)))),'Driver pin required');
const binding=plan.producer.bindingValue,engine=pin(process.execPath);
need(equal(engine,binding.engine),'Exact bound engine required');
fs.mkdirSync(out,{recursive:true});
const report={kind:'phase195-shared-preparation-emission',version:1,complete:false,inputs,
  plan:planPin,compareOrdinary:plan.compareOrdinary,preparationIdentity:plan.producer.preparationIdentity,
  cases:[],roles:[],
  scope:'Shared frontend/lowering measured separately. Each checked emitter runs its original x181_prepared, typed render and object encoder. No persistent cache, native image, independent oracle run, cold compiler timing or promotion claim.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');
const roleReports=[];
const saveRoles=()=>{for(const r of roleReports)fs.writeFileSync(r.dir+'/report.json',JSON.stringify(r.report,null,2)+'\n');};
save();

// Reject callable/accessor transport and make checked output immutable before reuse.
// This is a generic object-graph guard, not a Bend serializer or IR validator.
function freezeTransport(root){
  const todo=[root],seen=new WeakSet();let objects=0;
  while(todo.length){
    const value=todo.pop();
    if(value===null||['string','number','boolean','bigint'].includes(typeof value))continue;
    need(typeof value==='object'&&!Array.isArray(value),'First-order record transport required');
    if(seen.has(value))continue;
    seen.add(value);need(++objects<=2_000_000,'Prepared graph exceeds explicit bound');
    need(Object.getPrototypeOf(value)===Object.prototype||Object.getPrototypeOf(value)===null,'Plain prepared records required');
    for(const key of Reflect.ownKeys(value)){
      const descriptor=Object.getOwnPropertyDescriptor(value,key);
      need(typeof key==='string'&&Object.hasOwn(descriptor,'value'),'No accessor/symbol transport');
      todo.push(descriptor.value);
    }
    Object.freeze(value);
  }
  return objects;
}
function bytes(result){
  need(result?.$==='X187ObjectResult'&&result.error==='',result?.error??'Malformed object result');
  const chunks=[];let xs=result.bytes,count=0,chunk=[];
  while(xs?.$==='Con'){
    need(++count<=64*1024*1024&&Number.isInteger(xs.head)&&xs.head>=0&&xs.head<=255,'Bounded emitted byte list');
    chunk.push(xs.head);if(chunk.length===65536){chunks.push(Buffer.from(chunk));chunk=[];}xs=xs.tail;
  }
  need(xs?.$==='Nil'&&count>0,'Complete nonempty emitted byte list');
  if(chunk.length)chunks.push(Buffer.from(chunk));return Buffer.concat(chunks,count);
}
function base(api){
  const prepared=api.p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),
    fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);
  need(prepared?.$==='P86PreparationReady',prepared?.error??'Base refused');return prepared;
}
function prepare(api,seed,source){
  const planned=api.p86_plan(seed,source.file,fs.readFileSync(source.file,'utf8'));
  need(planned?.$==='P86PlanReady',planned?.error??'Source refused');
  const prepared=api.p169np_plan(planned);
  need(prepared?.$==='P169Prepared'&&prepared.error==='',prepared?.error??'Verified preparation refused');
  return prepared;
}
function emit(api,prepared){
  let t=clock();const output=api.x181_prepared(prepared);
  need(output?.$==='X181Output'&&output.error==='',output?.error??'Typed x86 selection refused');
  const sequence=api.x188_many(output.chunks),selectSeconds=clock()-t;t=clock();
  const assembly=api.x188_render(sequence);
  need(typeof assembly==='string'&&assembly.length>0&&Buffer.byteLength(assembly)<=128*1024*1024,'Bounded diagnostic assembly');
  const renderSeconds=clock()-t;t=clock();
  const object=bytes(api.x188_assemble(sequence));
  return {assembly,object,selectSeconds,renderSeconds,objectSeconds:clock()-t};
}
async function load(role){
  verify(role.receipt);const authority=read(role.receipt.file);
  need(authority.kind==='bend-checked-hosted-api'&&authority.complete===true&&authority.checked===true
    &&!authority.error&&!authority.changedInputs?.length,'Complete checked authority required');
  need(equal(authority.source,role.source)&&equal(authority.api,role.api),'Authority source/image binding differs');
  need(JSON.stringify(role.preparationIdentity)===JSON.stringify(plan.producer.preparationIdentity),'Preparation closure mismatch');
  need(JSON.stringify(role.bindingIdentity)===JSON.stringify(plan.producer.bindingIdentity),'Binding mismatch');
  const api=(await import(pathToFileURL(role.api.file))).default;
  need(['p88_cache_prepare','p86_plan','p169np_plan','x181_prepared','x188_many','x188_render','x188_assemble']
    .every(name=>authority.exports.includes(name)&&typeof api[name]==='function'),'Required checked exports');
  return api;
}
try{
  const producer=await load(plan.producer);const roles=[];
  const split=read(plan.partition.file);
  for(const role of plan.roles){
    const api=await load(role),dir=out+'/'+role.name;fs.mkdirSync(dir);
    // Exactly one emitter authority in the standard report. The pinned batch plan
    // retains every producer authority; all producer source/image pins remain inputs.
    const localInputs=unique([...inputs.filter(x=>!authorityFiles.has(x.file)),role.receipt,engine]);
    const local={campaign:'phase195',kind:'phase190-checked-native-emission',version:1,complete:false,
      target:'x86',emit:'object',inputs:localInputs,selection:'explicit',selected:plan.cases.map(c=>c.id),
      development:split.development,heldout:split.heldout,rows:[],baseSeconds:0,
      sourcePreparation:{receipt:role.manifest},sharedPreparation:{plan:planPin,producer:plan.producer.receipt,
        identity:plan.producer.preparationIdentity,chargedAt:out+'/report.json'},
      scope:report.scope};
    roleReports.push({dir,report:local});roles.push({role,api,dir,report:local});
  }
  saveRoles();let t=clock();const preparedBase=base(producer);report.baseSeconds=clock()-t;
  // Ordinary comparison follows the original per-emitter Base path independently.
  if(plan.compareOrdinary)for(const role of roles){t=clock();role.ordinaryBase=base(role.api);role.report.ordinaryBaseSeconds=clock()-t;}
  for(const c of plan.cases){
    t=clock();const prepared=prepare(producer,preparedBase.seed,c.source);
    const shared={id:c.id,source:c.source,expectedFile:c.expectedFile,prepareSeconds:clock()-t,complete:false};
    report.cases.push(shared);save();t=clock();shared.transportObjects=freezeTransport(prepared);shared.freezeSeconds=clock()-t;
    for(const role of roles){
      const row={...c,complete:false,prepareSeconds:0,sharedPrepareSeconds:shared.prepareSeconds};
      role.report.rows.push(row);saveRoles();const generated=emit(role.api,prepared);
      if(plan.compareOrdinary){
        t=clock();const ordinaryPrepared=prepare(role.api,role.ordinaryBase.seed,c.source);
        row.ordinaryPrepareSeconds=clock()-t;const ordinary=emit(role.api,ordinaryPrepared);
        need(generated.assembly===ordinary.assembly&&generated.object.equals(ordinary.object),'Shared/ordinary complete output mismatch: '+role.role.name+'/'+c.id);
        row.ordinaryComparison={complete:true,assembly:identity(ordinary.assembly),object:identity(ordinary.object),
          selectSeconds:ordinary.selectSeconds,renderSeconds:ordinary.renderSeconds,objectSeconds:ordinary.objectSeconds};
      }
      const dir=role.dir+'/'+c.id;fs.mkdirSync(dir);
      fs.writeFileSync(dir+'/program.s',generated.assembly);fs.writeFileSync(dir+'/program.o',generated.object);
      Object.assign(row,{assembly:pin(dir+'/program.s'),product:pin(dir+'/program.o'),
        selectSeconds:generated.selectSeconds,renderSeconds:generated.renderSeconds,objectSeconds:generated.objectSeconds,
        sameTypedSequence:true,verified:true,complete:true});saveRoles();
    }
    shared.complete=true;save();
  }
  inputs.forEach(verify);
  for(const role of roles){role.report.complete=true;}
  saveRoles();report.roles=roles.map(r=>({name:r.role.name,emission:pin(r.dir+'/report.json')}));report.complete=true;
}catch(error){report.error=String(error.stack??error);for(const r of roleReports){r.report.complete=false;r.report.error=report.error;}saveRoles();process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,roles:report.roles,error:report.error}));
