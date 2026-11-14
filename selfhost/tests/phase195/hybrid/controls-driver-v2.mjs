#!/usr/bin/env bun
// Checked Bend computes all assertions. This driver only authenticates inputs,
// transports the bounded list and compares its exact independently pinned rows.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../../tools/build/hosted.mjs';

const own=fileURLToPath(import.meta.url),args={};
for(let i=2;i<process.argv.length;i+=2){
  const key=process.argv[i],value=process.argv[i+1];
  need(['--api','--assets','--out','--source-manifest','--seconds'].includes(key)&&value&&!Object.hasOwn(args,key),'Known unique --key value required');
  args[key]=value;
}
for(const key of ['--api','--assets','--out','--source-manifest'])need(args[key],'Required '+key);
const seconds=Number(args['--seconds']??60);
need(Number.isFinite(seconds)&&seconds>0&&seconds<=300,'Bounded positive seconds required');
const out=path.resolve(args['--out']);
need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'Fresh outer-guarded output required');
fs.mkdirSync(out,{recursive:true});
fs.copyFileSync(own,out+'/driver.mjs',fs.constants.COPYFILE_EXCL);
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const same=(a,b)=>a?.bytes===b?.bytes&&a?.sha256===b?.sha256;
const began=performance.now(),elapsed=()=>(performance.now()-began)/1000;
const report={kind:'phase195-hybrid-checked-controls',version:2,complete:false,
  inputs:[pin(own),pin(out+'/driver.mjs'),pin(process.execPath),pin(path.join(workspace,'selfhost/tools/build/hosted.mjs'))],
  secondsLimit:seconds,rows:[],artifacts:[],targetsRun:[],
  scope:'Exactly18 checked compiler-data assertions, including5 installed-home assertions. No target execution, machine qualification, performance or general correctness claim. The outer job guard enforces the execution deadline.'};
const save=()=>{report.seconds=elapsed();fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');};
save();
try{
  need(fs.readFileSync('/proc/self/status','utf8').match(/^Cpus_allowed_list:\s*(.+)$/m)?.[1]==='3','One outer guarded CPU3 lane required');
  report.cpu=3;
  for(const name of ['BENDRTS','LD_PRELOAD','LD_AUDIT','NODE_OPTIONS','NODE_PATH'])need(!Object.hasOwn(process.env,name),'Ambient '+name+' must be unset');
  const contractFile=path.join(path.dirname(own),'controls-contract-v2.json');
  const contract=read(contractFile),authority=read(args['--api']),assets=read(args['--assets']);
  const preparation=read(args['--source-manifest']),binding=authority.imageBinding;
  need(contract.kind==='phase195-hybrid-controls-contract'&&contract.version===2&&contract.assertions===18&&contract.labels.length===18&&new Set(contract.labels).size===18,'Exact18-label contract required');
  need(contract.installedHomeAssertions.length===5&&contract.analysisAssertions.length===13,'Exact assertion categories required');
  need(JSON.stringify(contract.expectedRows)===JSON.stringify(contract.labels.map(s=>s+'=1')),'Literal expected rows required');
  need(authority.kind==='bend-checked-hosted-api'&&authority.complete===true&&authority.checked===true&&!authority.error&&!authority.changedInputs?.length,'Complete checked API required');
  need(binding?.kind==='bend-build-image-binding'&&binding.complete&&binding.checked&&binding.host==='js'&&binding.stage==='B1'&&same(binding.image,authority.api)&&same(binding.sourceIdentity,authority.source),'Exact checked B1 image binding required');
  need(assets.kind==='bend-build-assets'&&assets.complete===true&&authority.upstream?.revision===assets.upstream,'Matching pinned assets required');
  const engine=assets.assets?.bun;need(engine&&same(pin(process.execPath),engine),'Pinned JavaScript engine required');
  need(preparation.kind==='phase190-api-source'&&preparation.complete===true&&same(preparation.source,authority.source)&&same(preparation.snapshot,contract.snapshot),'Exact checked-source preparation and baseline required');
  need(preparation.replacements?.length===1&&preparation.replacements[0].name===contract.requiredReplacement&&preparation.replacements[0].replacementSha256===contract.replacementSha256,'Exact reviewed sole override required');
  need(preparation.sourceConstantOverrides?.length===0,'Original allocator constants required');
  for(const item of [contract.fixture,contract.overlay]){
    verify(item);
    need(preparation.inputs.some(x=>x.file===item.file&&same(x,item)),'Reviewed fixture/prototype absent from checked source');
  }
  need(authority.exports.includes(contract.export),'Checked control export required');
  report.authority={receipt:pin(args['--api']),api:authority.api,source:authority.source,preparation:pin(args['--source-manifest'])};
  report.contract=pin(contractFile);
  report.inputs.push(report.contract,pin(args['--assets']),report.authority.receipt,authority.api,authority.source,
    report.authority.preparation,contract.snapshot,contract.fixture,contract.overlay,...authority.inputs);
  report.inputs.forEach(verify);save();
  const api=(await import(pathToFileURL(authority.api.file))).default;
  need(typeof api[contract.export]==='function','Callable checked control export required');
  need(elapsed()<seconds,'Control deadline exhausted before evaluation');
  let list=api[contract.export]();
  while(list?.$==='Con'){
    need(report.rows.length<18&&typeof list.head==='string','Bounded string assertion list required');
    report.rows.push(list.head);list=list.tail;
  }
  need(list?.$==='Nil','Complete assertion list required');
  fs.writeFileSync(out+'/rows.json',JSON.stringify(report.rows,null,2)+'\n',{flag:'wx'});
  report.artifacts.push(pin(out+'/rows.json'));save();
  need(JSON.stringify(report.rows)===JSON.stringify(contract.expectedRows),'Exact18 control rows differ');
  need(elapsed()<seconds,'Control deadline exhausted');
  report.inputs.forEach(verify);
  report.assertionsPassed=18;report.installedHomeAssertionsPassed=5;report.analysisAssertionsPassed=13;
  report.complete=true;
}catch(error){report.error=String(error?.stack??error);process.exitCode=1;}
save();
console.log(JSON.stringify({complete:report.complete,assertionsPassed:report.assertionsPassed??0,report:out+'/report.json',error:report.error??null}));
