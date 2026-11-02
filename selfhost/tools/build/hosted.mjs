#!/usr/bin/env node
// IO adapter only. Checking/emission run the explicitly selected Bend API.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';

export const own=fileURLToPath(import.meta.url);
export const workspace=path.resolve(path.dirname(own),'../../..');
export const pin=file=>{file=fs.realpathSync(file);const bytes=fs.readFileSync(file);return {file,bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')};};
export function requireThat(value,message){if(!value)throw Error(message);}
export function verify(row){const got=pin(row.file);requireThat(got.bytes===row.bytes&&got.sha256===row.sha256,'Changed input: '+row.file);return got;}
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const save=(file,value)=>fs.writeFileSync(file,JSON.stringify(value,null,2)+'\n');
const list=xs=>xs.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$:'Nil'});
function* items(xs){let count=0;while(xs?.$==='Con'){requireThat(++count<=1000000,'Unbounded emitted list');yield xs.head;xs=xs.tail;}requireThat(xs?.$==='Nil','Malformed emitted list');}
export function driverInputs(root=workspace){
  const names=['typed-driver.mjs','assemble.mjs','native-build.mjs','node-resource-args.mjs','compiler-abi.mjs','base-cache-graph.mjs'];
  return [...names.map(x=>pin(path.join(root,'selfhost/tools',x))),pin(path.join(root,'selfhost/src/compiler.json'))];
}

// This adapter deliberately uses the maintained public driver without injecting
// a fake owned API. Live requests explicitly bypass Base cache reads and writes.
export async function inspectHosted({image,base,source,backend='direct',mode='compile',runtime,root=workspace}){
  [image,base,source].forEach(verify);
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
  process.env.BEND_TYPED_API=image.file;process.env.BEND_BASE=base.file;
  if(runtime){verify(runtime);process.env.BEND_TYPED_RUNTIME=runtime.file;}
  const driver=await import(pathToFileURL(path.join(root,'selfhost/tools/typed-driver.mjs')));
  requireThat(driver.apiPath===image.file&&driver.basePath===base.file,'Driver already loaded for another image/Base');
  const inputs=[...driverInputs(root),image,base,source];
  inputs.push(pin(own),pin(path.join(root,'selfhost/src/runtime.mjs')),pin(path.join(root,'selfhost/src/runtime/js/direct.mjs')),
    pin(path.join(root,'selfhost/src/runtime/native/runtime.c')));
  const result=await driver.inspect(source.file,{mode,backend,withReport:true,useBaseCache:false});
  // Inputs discovered by the Bend loader include source imports and foreign
  // providers. No source/compiler decisions are reconstructed in this shell.
  for(const file of result.files??[])if(!inputs.some(p=>p.file===fs.realpathSync(file)))inputs.push(pin(file));
  for(const row of inputs)verify(row);
  return {result,inputs,cache:{policy:'live: typed-driver Base cache disabled explicitly',read:false,written:false,files:[]}};
}

async function request(file,reportFile){
  requireThat(!fs.existsSync(reportFile),'Fresh worker report required');
  const req=read(file),inputs=[pin(own),pin(file),pin(process.execPath),...(req.inputs??[])];
  requireThat(req.kind==='bend-build-request-plan'&&req.version===1&&req.host==='js','Explicit hosted request plan required');
  requireThat(path.resolve(req.workspace)===workspace,'Workspace/adapter mismatch');
  requireThat(['js','c','qbe'].includes(req.target),'Unsupported hosted target');
  requireThat(req.imageMetadata?.targets?.includes(req.target)&&req.imageMetadata.host==='js','Image does not admit target');
  requireThat(req.imageMetadata.stage===req.stage,'Image stage differs');
  for(const row of [req.image,req.source,req.base,req.engine,...(req.carrier?[req.carrier]:[])]){verify(row);inputs.push(row);}
  requireThat(req.engine.sha256===pin(process.execPath).sha256,'Wrong JavaScript engine');
  const report={kind:'bend-hosted-request',version:1,complete:false,request:pin(file),image:req.image,source:req.source,target:req.target,stage:req.stage,mode:req.mode,inputs};
  const start=performance.now();save(reportFile,report);
  try{
    let code;
    if(req.target==='qbe'){
      requireThat(['qbe-api-v1','hosted-api-v1'].includes(req.imageMetadata.protocol),'QBE requires checked cursor API');
      const api=(await import(pathToFileURL(req.image.file))).default;
      const baseText=fs.readFileSync(req.base.file,'utf8');
      const prepared=req.mode==='cache'?api.p88_cache_prepare(req.base.file,baseText,fs.readFileSync(req.carrier.file,'utf8'),req.stamp):api.p86_prepare(req.base.file,baseText);
      if(prepared?.$==='P86PreparationError')report.observation={status:'error',phase:'base',diagnostic:prepared.error,checked:false};
      requireThat(prepared?.$==='P86PreparationReady',prepared?.error??'Base preparation refused');
      const planned=api.p86_plan(prepared.seed,req.source.file,fs.readFileSync(req.source.file,'utf8'));
      if(planned?.$==='P86PlanError')report.observation={status:'error',phase:planned.error.startsWith('check:')?'check':planned.error.startsWith('compile:')?'compile':'frontend',diagnostic:planned.error,nativeProtocolDiagnostic:planned.error,checked:false};
      requireThat(planned?.$==='P86PlanReady',planned?.error??'Source refused');
      const emission=api.p134e_plan(planned),hash=crypto.createHash('sha256');let bytes=0,pieces=0;
      const write=text=>{requireThat(typeof text==='string','Invalid compiler text');bytes+=Buffer.byteLength(text);requireThat(bytes<=256*1024**2,'QBE product exceeds 256 MiB');hash.update(text);fs.writeSync(1,text);};
      if(emission?.$==='P134Planned'){
        let cursor=api.p134e_begin(emission.plan);
        while(true){const next=api.p134e_next(cursor);if(next?.$==='P134Done')break;
          requireThat(next?.$==='P134Piece'&&typeof next.legacy_end==='boolean'&&++pieces<=1000000,'Malformed cursor');
          write(next.text);if(next.legacy_end)write('\n');cursor=next.next;
        }
      }else{
        if(emission?.$==='P111Emission'&&emission.error)report.observation={status:'error',phase:'compile',diagnostic:emission.error,nativeProtocolDiagnostic:emission.error,checked:false};
        requireThat(emission?.$==='P111Emission'&&emission.error==='',emission?.error??'Emission refused');
        for(const chunk of items(emission.chunks)){write(chunk);write('\n');pieces++;}
      }
      report.product={bytes,sha256:hash.digest('hex')};report.pieces=pieces;report.verified=true;
    }else{
      requireThat(['typed-api-v1','hosted-api-v1'].includes(req.imageMetadata.protocol),'JS/C require public typed-driver API');
      requireThat(req.mode==='live'&&!req.carrier,'JS/C do not consume a QBE prepared carrier');
      // Match the public CLI: native C mode skips direct-JS dependency analysis.
      const backend=req.backend??(req.target==='c'?'js':'direct');
      requireThat(['direct','js'].includes(backend),'Unknown JavaScript backend');
      requireThat(req.target!=='c'||backend==='js','C requests require the native driver route');
      // Runtime placement is part of this adapter contract, not an arbitrary
      // override ignored by the driver. Explicit providers must match it.
      const runtimeFile=req.target==='c'?'src/runtime/native/runtime.c':backend==='direct'?'src/runtime/js/direct.mjs':'src/runtime.mjs';
      const actual=pin(path.join(workspace,'selfhost',runtimeFile));
      requireThat(req.providers?.runtime&&req.providers.runtime.sha256===actual.sha256&&req.providers.runtime.bytes===actual.bytes,'Explicit runtime differs from driver runtime');
      inputs.push(actual);
      const got=await inspectHosted({image:req.image,base:req.base,source:req.source,backend,mode:req.target==='c'?'native':(req.operation??'compile')});
      inputs.push(...got.inputs);report.cache=got.cache;
      const {code:output,...observation}=got.result;report.observation=observation;
      requireThat(got.result.status==='ok'&&got.result.checked===true,got.result.diagnostic??got.result.reason??'Compiler refused');
      code=output;requireThat(typeof code==='string','No emitted product');
      report.product={bytes:Buffer.byteLength(code),sha256:crypto.createHash('sha256').update(code).digest('hex')};
      fs.writeSync(1,code);
    }
    for(const row of inputs)verify(row);
    report.complete=true;
  }catch(error){report.error=String(error.stack??error);process.exitCode=1;}
  report.seconds=(performance.now()-start)/1000;save(reportFile,report);
}

async function acquire(options){
  const source=pin(options.source),out=path.resolve(options.out),upstream=fs.realpathSync(options.upstream),engine=pin(options.engine);
  requireThat(!fs.existsSync(out)&&out.startsWith(workspace+'/selfhost/build/'),'Fresh build output required');
  const rootFile=path.resolve(options.exports??path.join(workspace,'selfhost/tools/build/hosted-exports.json'));
  const exportManifest=read(rootFile),exports=exportManifest.exports,tool=path.join(workspace,'selfhost/tools/stage0-library.mjs');
  requireThat(exportManifest.kind==='bend-hosted-api-exports'&&exportManifest.version===1&&Array.isArray(exports)&&exports.length>0&&exports.length<=256&&exports.every(x=>typeof x==='string'&&/^[A-Za-z_][A-Za-z0-9_.]*$/.test(x))&&exports.length===new Set(exports).size,'Invalid or duplicate API roots');
  const protocol=exportManifest.protocol??'hosted-api-v1',targets=exportManifest.targets??['js','c','qbe'];
  requireThat(['hosted-api-v1','session-api-v1','qbe-api-v1','typed-api-v1'].includes(protocol)&&Array.isArray(targets)&&targets.length>0&&targets.every(x=>['js','c','qbe'].includes(x)),'Invalid API protocol/targets');
  const text=fs.readFileSync(source.file,'utf8');
  for(const name of exports)requireThat(new RegExp('^(?:def|law) '+name.replaceAll('.','\\.')+'(?:[(:]|\\s)','m').test(text),'Missing source API: '+name);
  const inputs=[pin(own),pin(rootFile),source,engine,pin(tool),...['bend.ts','comp.ts','base.bend'].map(x=>pin(path.join(upstream,'bend2',x)))];
  const config=read(path.join(workspace,'selfhost/src/compiler.json'));
  const revision=spawnSync('git',['-C',upstream,'rev-parse','HEAD'],{encoding:'utf8'});
  const clean=spawnSync('git',['-C',upstream,'diff','--quiet','HEAD','--','bend2']);
  requireThat(revision.status===0&&revision.stdout.trim()===config.upstream&&clean.status===0,'Pinned upstream checkout differs');
  inputs.push(pin(path.join(workspace,'selfhost/src/compiler.json')));
  fs.mkdirSync(out,{recursive:true});
  const stdout=fs.openSync(path.join(out,'stdout'),'wx'),stderr=fs.openSync(path.join(out,'stderr'),'wx');
  const command=[engine.file,tool,source.file,path.join(out,'api.mjs'),...exports];
  const report={kind:'bend-checked-hosted-api',version:1,complete:false,checked:false,source,exports,inputs,command,upstream:{file:upstream,revision:config.upstream},scope:'Upstream-checked B1 acquisition only; no B2/self-hosting/default promotion.'};
  save(path.join(out,'report.json'),report);const start=performance.now();
  try{
    const env={...process.env,BEND_UPSTREAM:upstream};for(const key of ['NODE_OPTIONS','NODE_PATH','LD_PRELOAD'])delete env[key];
    const child=spawnSync(command[0],command.slice(1),{cwd:workspace,env,stdio:['ignore',stdout,stderr],timeout:120000});
    report.status=child.status;report.signal=child.signal;report.error=child.error?.message??null;
    requireThat(child.status===0&&!child.error&&!child.signal,'Checked acquisition failed; inspect captured diagnostics');
    for(const row of inputs)verify(row);
    report.api=pin(path.join(out,'api.mjs'));report.complete=true;report.checked=true;
    report.imageBinding={kind:'bend-build-image-binding',version:1,complete:true,host:'js',stage:'B1',image:report.api,
      sourceIdentity:source,checked:true,exports,protocol,targets,preparationModes:exportManifest.preparationModes??['live','cache'],
      scope:'Checked upstream-built API. Target capability is declared by exported public entries; behavioral qualification remains separate. JS/C accept live only; QBE supports live/cache.'};
  }catch(error){report.error=String(error.stack??error);process.exitCode=1;}
  finally{fs.closeSync(stdout);fs.closeSync(stderr);report.seconds=(performance.now()-start)/1000;report.stdout=pin(path.join(out,'stdout'));report.stderr=pin(path.join(out,'stderr'));save(path.join(out,'report.json'),report);}
  console.log(JSON.stringify({complete:report.complete,report:path.join(out,'report.json')}));
}

if(process.argv[1]&&path.resolve(process.argv[1])===own){
  const args=process.argv.slice(2),options={};
  try{
    if(args[0]==='acquire')args.shift();
    for(let i=0;i<args.length;i+=2){requireThat(args[i].startsWith('--')&&args[i+1],'Expected --key value');options[args[i].slice(2)]=args[i+1];}
    if(options.request)await request(options.request,path.resolve(options.report));
    else {for(const key of ['source','out','upstream','engine'])requireThat(options[key],'Missing --'+key);await acquire(options);}
  }catch(error){console.error(String(error.stack??error));process.exitCode=1;}
}
