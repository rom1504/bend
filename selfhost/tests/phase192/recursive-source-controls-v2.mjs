// Transport only: checked Bend owns preparation, selection, rendering and ELF.
// Six fixed ordinary programs are compared with frozen independent literals.
// Revision2 releases all per-case compiler IR before collecting and spawning children.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {spawnSync} from 'node:child_process';
import {pin,verify,requireThat as need,workspace} from '../../tools/build/hosted.mjs';

const own=fileURLToPath(import.meta.url),a={};
for(let i=2;i<process.argv.length;i+=2){
  const key=process.argv[i],value=process.argv[i+1];
  need(['--api','--binding','--assets','--out','--seconds','--source-manifest'].includes(key)&&value&&!Object.hasOwn(a,key),'Known unique --key value required');
  a[key]=value;
}
for(const key of ['--api','--binding','--assets','--out'])need(a[key],'Required '+key);
const seconds=Number(a['--seconds']??600);
need(Number.isFinite(seconds)&&seconds>0&&seconds<=1800,'Bounded whole-run deadline required');
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const same=(left,right)=>left?.bytes===right?.bytes&&left?.sha256===right?.sha256;
const out=path.resolve(a['--out']);
need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'Fresh guarded output required');
fs.mkdirSync(out,{recursive:true});
fs.copyFileSync(own,out+'/driver.mjs',fs.constants.COPYFILE_EXCL);
const began=performance.now(),elapsed=()=>(performance.now()-began)/1000;
const report={kind:'phase192-recursive-source-controls',version:2,complete:false,secondsLimit:seconds,
  memoryPolicy:'Per-case emission scope returns artifact metadata only; full Bun GC outside that scope before every native child. Compiler/API and prepared Base remain live. Process-tree guard limits are unchanged.',
  inputs:[pin(own),pin(out+'/driver.mjs'),pin(process.execPath),pin(path.join(workspace,'selfhost/tools/build/hosted.mjs'))],
  rows:[],jobs:[],artifacts:[],machines:[],hostMemory:[],
  scope:'Six frozen ordinary sources checked/prepared by Bend, selected to one typed sequence and executed through direct ELF and rendered GNU-as routes against complete independent literal outputs. Optional original H planner probes record admission evidence; absence of a probe is not admission. No timing, installed promotion, broad qualification or compiler-correctness claim.'};
const save=()=>{report.seconds=elapsed();fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');};
const record=file=>{const value=pin(file);report.artifacts.push(value);return value;};
const write=(name,data)=>{need(Buffer.byteLength(data)<=64*1024*1024,'Bounded artifact');const file=path.join(out,name);fs.writeFileSync(file,data,{flag:'wx'});record(file);return file;};
function list(values){return values.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$:'Nil'});}
function strings(xs){
  const result=[];let size=0;
  while(xs?.$==='Con'){
    need(result.length<4096&&typeof xs.head==='string','Bounded probe string list');
    size+=Buffer.byteLength(xs.head);need(size<=4*1024*1024,'Bounded probe bytes');result.push(xs.head);xs=xs.tail;
  }
  need(xs?.$==='Nil','Complete probe list');return result;
}
function bytes(result){
  need(result?.$==='X187ObjectResult'&&result.error==='',result?.error??'Object refused');
  const chunks=[];let xs=result.bytes,chunk=[],count=0;
  while(xs?.$==='Con'){
    need(++count<=64*1024*1024&&Number.isInteger(xs.head)&&xs.head>=0&&xs.head<=255,'Bounded ELF bytes');
    chunk.push(xs.head);if(chunk.length===65536){chunks.push(Buffer.from(chunk));chunk=[];}xs=xs.tail;
  }
  need(xs?.$==='Nil'&&count>0,'Complete nonempty ELF bytes');if(chunk.length)chunks.push(Buffer.from(chunk));return Buffer.concat(chunks,count);
}
function memorySnapshot(){
  const m=process.memoryUsage();
  const status=fs.readFileSync('/proc/self/status','utf8');
  const rss=status.match(/^VmRSS:\s+(\d+) kB$/m);
  return {rssBytes:rss?Number(rss[1])*1024:m.rss,heapUsedBytes:m.heapUsed,heapTotalBytes:m.heapTotal,externalBytes:m.external};
}
function collect(label){
  need(typeof globalThis.Bun?.gc==='function','Pinned Bun full-GC API required');
  const before=memorySnapshot();
  globalThis.Bun.gc(true);
  const after=memorySnapshot();
  report.hostMemory.push({label,seconds:elapsed(),before,after,fullCollection:true});save();
  return after;
}
// No prepared IR, typed sequence, rendered string or ELF byte list escapes this
// function. Returning before collect() makes the lifetime boundary explicit.
function emitCase(api,prep,c,source,probe,row){
  let tick=elapsed();
  const plan=api.p86_plan(prep.seed,source.file,fs.readFileSync(source.file,'utf8'));
  need(plan?.$==='P86PlanReady',plan?.error??'Source refused: '+c.id);
  const prepared=api.p169np_plan(plan);need(prepared?.$==='P169Prepared'&&prepared.error==='',prepared?.error??'Preparation refused: '+c.id);
  row.prepareSeconds=elapsed()-tick;row.sourceVerified=true;
  if(probe){
    row.queryNames=c.querySourceNames.flatMap(name=>[name,'$direct.'+name]);
    row.admission=strings(api.p186hp_probe(prepared.cursor,list(row.queryNames)));
    row.admissionArtifact=pin(write(c.id+'/admission.json',JSON.stringify(row.admission,null,2)+'\n'));save();
  }
  tick=elapsed();const output=api.x181_prepared(prepared);
  need(output?.$==='X181Output'&&output.error==='',output?.error??'Selection refused: '+c.id);
  const sequence=api.x188_many(output.chunks),assembly=api.x188_render(sequence);
  need(typeof assembly==='string'&&assembly.length>0,'Nonempty typed assembly');
  const sourceAssembly=write(c.id+'/program.s',assembly);
  const direct=write(c.id+'/direct.o',bytes(api.x188_assemble(sequence)));
  row.selectionSeconds=elapsed()-tick;
  row.products={assembly:pin(sourceAssembly),directObject:pin(direct),sameTypedSequence:true};
  row.emissionComplete=true;save();
  return row.products;
}
function run(label,command,expected){
  report.inputs.forEach(verify);
  const hostBeforeChild=collect(label+'/before-child');
  const left=seconds-elapsed();need(left>0,'Whole-run deadline exhausted');
  const env={...process.env};for(const key of ['LD_PRELOAD','LD_AUDIT','BENDRTS','NODE_OPTIONS','NODE_PATH'])delete env[key];env.LC_ALL='C';
  const start=performance.now(),result=spawnSync(command[0],command.slice(1),{cwd:workspace,env,encoding:'utf8',
    timeout:Math.max(1,Math.floor(Math.min(30,left)*1000)),maxBuffer:4*1024*1024});
  const stdout=write(label+'.stdout',result.stdout??''),stderr=write(label+'.stderr',result.stderr??'');
  const job={label,command,hostBeforeChild,status:result.status,signal:result.signal,error:result.error?.message??null,
    seconds:(performance.now()-start)/1000,stdout:pin(stdout),stderr:pin(stderr)};
  report.jobs.push(job);save();need(result.status===0&&!result.signal&&!result.error,label+' failed');
  if(expected!==undefined)need(result.stdout===expected&&result.stderr==='',label+' differs from independent complete stdout');return job;
}
save();
try{
  need(fs.readFileSync('/proc/self/status','utf8').match(/^Cpus_allowed_list:\s*(.+)$/m)?.[1]==='3','One outer guarded CPU3 lane required');
  need(!Object.hasOwn(process.env,'BENDRTS'),'Ambient BENDRTS must be unset');report.cpu=3;
  const authority=read(a['--api']),binding=read(a['--binding']),assets=read(a['--assets']);
  const exports=['p88_cache_prepare','p86_plan','p169np_plan','x181_prepared','x188_many','x188_render','x188_assemble'];
  need(authority.kind==='bend-checked-hosted-api'&&authority.complete===true&&authority.checked===true&&!authority.error&&!authority.changedInputs?.length,'Complete checked API required');
  need(exports.every(name=>authority.exports.includes(name)),'Checked preparation and typed-emission exports required');
  need(authority.imageBinding?.host==='js'&&authority.imageBinding?.stage==='B1'&&same(authority.imageBinding.image,authority.api)&&same(authority.imageBinding.sourceIdentity,authority.source),'Checked B1 image/source binding required');
  need(assets.kind==='bend-build-assets'&&assets.complete===true&&authority.upstream?.revision===assets.upstream,'Matching pinned assets required');
  need(binding.kind==='phase175-prepared-base'&&typeof binding.stamp==='string'&&binding.stamp&&same(binding.engine,pin(process.execPath)),'Exact prepared Base and engine required');
  const manifest=pin(a['--source-manifest']??path.join(path.dirname(authority.source.file),'manifest.json'));
  const preparation=read(manifest.file);
  need(preparation.kind==='phase190-api-source'&&preparation.complete===true&&same(preparation.source,authority.source),'Exact checked source preparation receipt required');
  report.inputs.push(pin(a['--api']),authority.source,authority.api,...authority.inputs,pin(a['--binding']),binding.base,binding.carrier,binding.engine,pin(a['--assets']),manifest,preparation.snapshot);
  report.authority={receipt:pin(a['--api']),source:authority.source,api:authority.api,preparation:manifest};
  const tool=name=>{const expected=assets.assets?.[name];need(expected,'Pinned asset required: '+name);const actual=pin(path.resolve(workspace,expected.file));need(same(actual,expected),'Changed asset: '+name);report.inputs.push(actual);return actual.file;};
  const assembler=tool('assembler'),linker=tool('linker'),runtime=tool('qbe-runtime'),engine=tool('bun');
  need(same(pin(engine),pin(process.execPath)),'Pinned Bun engine required');
  const policy=assets.toolchains?.x86;
  need(policy?.target==='amd64_sysv'&&['assemblerFlags','linkerFlags','libraries'].every(key=>Array.isArray(policy[key])),'Pinned x86 toolchain required');
  report.runtime=pin(runtime);report.toolchain=policy;
  const metadata=pin(path.join(path.dirname(own),'recursive-controls.json')),contract=read(metadata.file);
  need(contract.kind==='phase192-recursive-source-controls'&&contract.version===1&&contract.cases.length===6,'Six frozen recursive controls required');
  const oracle=pin(path.resolve(workspace,contract.oracle.file));need(same(oracle,contract.oracle),'Frozen independent oracle identity');
  report.inputs.push(metadata,oracle);report.metadata=metadata;report.oracleExecuted=false;
  const sources=contract.cases.map(row=>{
    need(/^[a-z]+$/.test(row.id)&&typeof row.expectedStdout==='string'&&row.expectedStdout.length>0,'Bounded named case and complete oracle');
    const source=pin(path.resolve(workspace,row.source));need(same(source,row),'Frozen source: '+row.id);report.inputs.push(source);return source;
  });
  need(new Set(contract.cases.map(row=>row.id)).size===6,'Unique frozen cases');
  report.inputs.forEach(verify);save();
  const api=(await import(pathToFileURL(authority.api.file))).default;
  need(exports.every(name=>typeof api[name]==='function'),'Callable checked exports');
  const probe=authority.exports.includes('p186hp_probe')&&typeof api.p186hp_probe==='function';
  report.admissionProbe=probe?'p186hp_probe':'unavailable';
  let tick=elapsed();const prep=api.p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);
  need(prep?.$==='P86PreparationReady',prep?.error??'Base refused');report.baseSeconds=elapsed()-tick;
  for(let i=0;i<contract.cases.length;i++){
    need(elapsed()<seconds,'Whole-run deadline exhausted');
    const c=contract.cases[i],source=sources[i],dir=path.join(out,c.id);fs.mkdirSync(dir);
    const row={id:c.id,source,expectedStdout:c.expectedStdout,complete:false,machines:[]};report.rows.push(row);save();
    const products=emitCase(api,prep,c,source,probe,row);
    // emitCase has returned: only pins and plain report metadata are live here.
    collect(c.id+'/after-emission');
    const direct=products.directObject.file,sourceAssembly=products.assembly.file;
    const assembled=path.join(dir,'assembly.o');
    run(c.id+'/assemble',[assembler,...policy.assemblerFlags,'-o',assembled,sourceAssembly]);record(assembled);
    row.products.assembledObject=pin(assembled);save();
    for(const [route,object] of [['direct',direct],['assembly',assembled]]){
      const binary=path.join(dir,route);
      run(c.id+'/'+route+'-link',[linker,...policy.linkerFlags,object,runtime,...policy.libraries,'-o',binary]);record(binary);
      const job=run(c.id+'/'+route+'-execute',[binary,'+RTS','--threads','1','--gpu','off','-RTS'],c.expectedStdout);
      const machine={id:c.id,route,binary:pin(binary),stdout:job.stdout,stderr:job.stderr,status:job.status,complete:true};
      row.machines.push(machine);report.machines.push(machine);save();
    }
    row.complete=true;save();
  }
  report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,cases:report.rows.length,machines:report.machines.length,error:report.error}));
