#!/usr/bin/env bun
// Transport adapted unchanged from phase195/selection/physical-driver-v2.mjs except
// this branch-facts fixture specification and report kind.
// Checked Bend selects and emits every instruction. This shell transports typed
// outputs and compares direct/rendered routes with a fixed independent C observer.
// Both routes are produced from the same typed selection; no third route is claimed.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {spawnSync} from 'node:child_process';
import {pin,verify,requireThat as need,workspace} from '../../../tools/build/hosted.mjs';

const own=fileURLToPath(import.meta.url),args={};
for(let i=2;i<process.argv.length;i+=2){
  const key=process.argv[i],value=process.argv[i+1];
  need(['--api','--assets','--out','--groups','--seconds','--source-manifest'].includes(key)&&value&&!Object.hasOwn(args,key),'Known unique --key value required');
  args[key]=value;
}
for(const key of ['--api','--assets','--out'])need(args[key],'Required '+key);
const specs={
  branch:{controls:'p195bf_controls',emit:'p195bf_emit',outputs:1,
    fixture:'selfhost/tests/phase195/branch-facts/controls-v3.bend',observer:'selfhost/tests/phase195/branch-facts/controls-v3.c',
    expected:'phase195 branch facts controls: checks=2106 failures=0\n',
    labels:['empty-preserves','yes-source-kill','no-source-kill','destination-kill','nested-source-kill',
      'call-clears','again-clears','result-clears','store-preserves','width-killed',
      'no-new-join-width','narrow-snapshot','known-narrow-alias','multi-call-clears','return-clears',
      'binary-source-kill','offset-source-kill','alloca-source-kill','load-source-kill','scalar-if-source-kill']},
};
const groups=(args['--groups']??'branch').split(',');
need(groups.length&&new Set(groups).size===groups.length&&groups.every(name=>Object.hasOwn(specs,name)),'Unique known control groups required');
const seconds=Number(args['--seconds']??180);
need(Number.isFinite(seconds)&&seconds>0&&seconds<=1800,'Bounded positive --seconds required');
const out=path.resolve(args['--out']);
need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'Fresh guarded output required');
fs.mkdirSync(out,{recursive:true});
fs.copyFileSync(own,out+'/driver.mjs',fs.constants.COPYFILE_EXCL);
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const same=(a,b)=>a?.bytes===b?.bytes&&a?.sha256===b?.sha256;
const began=performance.now(),elapsed=()=>(performance.now()-began)/1000;
const report={kind:'phase195-branch-facts-controls',version:1,complete:false,groups,secondsLimit:seconds,
  inputs:[pin(own),pin(out+'/driver.mjs'),pin(process.execPath),pin(path.join(workspace,'selfhost/tools/build/hosted.mjs'))],
  rows:{},jobs:[],artifacts:[],machines:[],
  scope:'Finite checked compiler-data controls and independent C machine observations through direct ELF and rendered GNU-as routes from the same typed selection. No independent third assembly route, production runtime, compiler timing, bootstrap, installed-image or general correctness claim.'};
const save=()=>{report.seconds=elapsed();fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');};
const record=file=>{const p=pin(file);report.artifacts.push(p);return p;};
const write=(name,data)=>{need(Buffer.byteLength(data)<=64*1024*1024,'Bounded output artifact');const file=path.join(out,name);fs.writeFileSync(file,data,{flag:'wx'});record(file);return file;};
const exact=(actual,wanted,label)=>need(JSON.stringify(actual)===JSON.stringify(wanted),label+' differs');
function list(xs,bound){
  const items=[];
  while(xs?.$==='Con'){need(items.length<bound,'Bounded fixture list');items.push(xs.head);xs=xs.tail;}
  need(xs?.$==='Nil','Complete fixture list');return items;
}
function objectBytes(result){
  need(result?.$==='X187ObjectResult'&&result.error==='',result?.error??'Object emitter refused');
  const chunks=[];let xs=result.bytes,chunk=[],count=0;
  while(xs?.$==='Con'){
    need(++count<=64*1024*1024&&Number.isInteger(xs.head)&&xs.head>=0&&xs.head<=255,'Bounded emitted byte list');
    chunk.push(xs.head);if(chunk.length===65536){chunks.push(Buffer.from(chunk));chunk=[];}xs=xs.tail;
  }
  need(xs?.$==='Nil'&&count>0,'Complete nonempty object byte list');
  if(chunk.length)chunks.push(Buffer.from(chunk));return Buffer.concat(chunks,count);
}
function run(label,command,expected){
  report.inputs.forEach(verify);const left=seconds-elapsed();need(left>0,'Whole control deadline exhausted');
  const started=performance.now(),env={...process.env};
  for(const name of ['LD_PRELOAD','LD_AUDIT','BENDRTS','NODE_OPTIONS','NODE_PATH'])delete env[name];
  env.LC_ALL='C';
  const result=spawnSync(command[0],command.slice(1),{cwd:workspace,env,encoding:'utf8',
    timeout:Math.max(1,Math.floor(Math.min(30,left)*1000)),maxBuffer:4*1024*1024});
  const stdout=write(label+'.stdout',result.stdout??''),stderr=write(label+'.stderr',result.stderr??'');
  const job={label,command,cwd:workspace,status:result.status,signal:result.signal,error:result.error?.message??null,
    seconds:(performance.now()-started)/1000,stdout:pin(stdout),stderr:pin(stderr)};
  report.jobs.push(job);save();
  need(result.status===0&&!result.signal&&!result.error,label+' failed');
  if(expected!==undefined)need(result.stdout===expected&&result.stderr==='',label+' independent literal output differs');
  return job;
}
save();
try{
  const affinity=fs.readFileSync('/proc/self/status','utf8').match(/^Cpus_allowed_list:\s*(.+)$/m)?.[1];
  need(affinity==='3','One outer guarded CPU3 lane required');report.cpu=3;
  need(!Object.hasOwn(process.env,'BENDRTS'),'Ambient BENDRTS must be unset');
  const authority=read(args['--api']),assets=read(args['--assets']),binding=authority.imageBinding;
  need(authority.kind==='bend-checked-hosted-api'&&authority.complete===true&&authority.checked===true&&!authority.error&&!authority.changedInputs?.length,'Complete checked API required');
  need(assets.kind==='bend-build-assets'&&assets.complete===true&&authority.upstream?.revision===assets.upstream,'Matching pinned API/assets upstream required');
  need(binding?.kind==='bend-build-image-binding'&&binding.complete&&binding.checked&&binding.host==='js'&&binding.stage==='B1'&&same(binding.image,authority.api)&&same(binding.sourceIdentity,authority.source),'Exact checked B1 image binding required');
  const preparationFile=args['--source-manifest']??path.join(path.dirname(authority.source.file),'manifest.json');
  const preparation=read(preparationFile);
  need(preparation.kind==='phase190-api-source'&&preparation.complete===true&&same(preparation.source,authority.source),'Exact Phase190 API source preparation required');
  report.authority={receipt:pin(args['--api']),source:authority.source,api:authority.api,preparation:pin(preparationFile)};
  report.inputs.push(report.authority.receipt,authority.source,authority.api,...authority.inputs,
    pin(args['--assets']),report.authority.preparation,preparation.snapshot);
  const tool=name=>{
    const expected=assets.assets?.[name];need(expected,'Pinned tool required: '+name);
    const actual=pin(path.resolve(workspace,expected.file));need(same(actual,expected),'Changed tool: '+name);
    report.inputs.push(actual);return actual.file;
  };
  const assembler=tool('assembler'),linker=tool('linker'),engine=tool('bun');
  need(same(pin(process.execPath),pin(engine)),'Pinned JavaScript engine required');
  const policy=assets.toolchains?.x86;
  need(policy?.target==='amd64_sysv'&&['assemblerFlags','linkerFlags','libraries'].every(k=>Array.isArray(policy[k])),'Pinned x86 toolchain policy required');
  report.toolchain=policy;
  const exports=['x188_many','x188_render','x188_assemble',...groups.flatMap(name=>
    [specs[name].controls,specs[name].emit,...(specs[name].validate?[specs[name].validate]:[])])];
  need(exports.every(name=>authority.exports.includes(name)),'Required checked control exports');
  for(const name of groups){
    const spec=specs[name],fixture=pin(path.join(workspace,spec.fixture)),observer=pin(path.join(workspace,spec.observer));
    need(preparation.inputs.some(item=>item.file===fixture.file&&same(item,fixture)),'Fixture absent from exact checked API: '+name);
    report.inputs.push(fixture,observer);
    report.rows[name]={complete:false,fixture,observer,expectedStdout:spec.expected,products:[],machines:[]};
    if(spec.metadata){
      const metadata=pin(path.join(workspace,spec.metadata)),contract=read(metadata.file);
      exact(contract.controls,spec.labels,name+' independent control labels');
      exact(contract.expectedStdout,spec.expected,name+' independent output contract');
      exact(contract.exports,[spec.controls,spec.emit],name+' independent exports');
      report.inputs.push(metadata);report.rows[name].metadata=metadata;
    }
    if(spec.independentAssembly){
      const source=pin(path.join(workspace,spec.independentAssembly));
      report.inputs.push(source);report.rows[name].independentAssembly=source;
    }
  }
  report.inputs.forEach(verify);save();
  const api=(await import(pathToFileURL(authority.api.file))).default;
  need(exports.every(name=>typeof api[name]==='function'),'Callable checked control exports');
  for(const name of groups){
    const spec=specs[name],row=report.rows[name];fs.mkdirSync(out+'/'+name);
    if(spec.validate){row.validation=api[spec.validate]();need(row.validation==='','Fixture verifier refused: '+name);}
    row.controls=list(api[spec.controls](),spec.labels.length+1);
    exact(row.controls,spec.labels.map(label=>label+'=1'),name+' exact control rows');
    row.controlsPassed=row.controls.length;save();
    const outputs=spec.list?list(api[spec.emit](),spec.outputs+1):[api[spec.emit]()];
    need(outputs.length===spec.outputs,'Exact typed output count: '+name);
    const direct=[],assembly=[];
    for(let i=0;i<outputs.length;i++){
      const output=outputs[i];need(output?.$==='X181Output'&&output.error==='',output?.error??name+' typed selection refused');
      const sequence=api.x188_many(output.chunks),text=api.x188_render(sequence);
      need(typeof text==='string'&&text.length>0,'Nonempty rendered typed output');
      const source=write(name+'/fixture-'+i+'.s',text);
      const object=write(name+'/direct-'+i+'.o',objectBytes(api.x188_assemble(sequence)));
      const reference=path.join(out,name,'assembly-'+i+'.o');
      run(name+'/assemble-'+i,[assembler,...policy.assemblerFlags,'-o',reference,source]);record(reference);
      direct.push(object);assembly.push(reference);
      row.products.push({assembly:pin(source),directObject:pin(object),assembledObject:pin(reference),sameTypedSequence:true});save();
    }
    const observerObject=path.join(out,name,'observer.o');
    run(name+'/observer-compile',[linker,'-std=c11','-O2','-fno-pie','-c',row.observer.file,'-o',observerObject]);record(observerObject);
    const routes=[['direct',direct],['assembly',assembly]];
    if(spec.independentAssembly){
      const source=row.independentAssembly,object=path.join(out,name,'independent.o');
      verify(source);
      run(name+'/independent-assemble',[assembler,...policy.assemblerFlags,'-o',object,source.file]);record(object);
      row.independentProduct={assembly:source,assembledObject:pin(object),sameTypedSequence:false};
      routes.push(['independent',[object]]);save();
    }
    for(const [route,objects]of routes){
      const binary=path.join(out,name,route);
      run(name+'/'+route+'-link',[linker,...policy.linkerFlags,observerObject,...objects,...policy.libraries,'-o',binary]);record(binary);
      const observation=run(name+'/'+route+'-execute',[binary],spec.expected);
      const machine={group:name,route,complete:true,binary:pin(binary),stdout:observation.stdout,stderr:observation.stderr,status:observation.status};
      row.machines.push(machine);report.machines.push(machine);save();
    }
    row.complete=true;save();
  }
  report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,groups,controls:Object.values(report.rows).reduce((n,row)=>n+(row.controlsPassed??0),0),machines:report.machines.length,error:report.error}));
