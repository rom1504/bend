#!/usr/bin/env bun
// Checked API transport only. The seven expectations are independent literals.
// No program source compilation, object emission, linking, or target execution.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../tools/build/hosted.mjs';

const own=fileURLToPath(import.meta.url),args={};
for(let i=2;i<process.argv.length;i+=2){
  const key=process.argv[i],value=process.argv[i+1];
  need(['--api','--assets','--out','--source-manifest'].includes(key)&&value&&!Object.hasOwn(args,key),'Known unique --key value required');
  args[key]=value;
}
for(const key of ['--api','--assets','--out'])need(args[key],'Required '+key);
const out=path.resolve(args['--out']);
need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'Fresh guarded output required');
fs.mkdirSync(out,{recursive:true});
fs.copyFileSync(own,out+'/driver.mjs',fs.constants.COPYFILE_EXCL);
const expected=[
  'PASS budget-small-slack-accepted',
  'PASS budget-small-slack-over-refused',
  'PASS budget-exact-limit-accepted',
  'PASS budget-limit-plus-one-refused',
  'PASS budget-linear-growth-accepted',
  'PASS budget-sixfold-growth-refused',
  'PASS budget-arithmetic-overflow-refused'];
const same=(a,b)=>a?.bytes===b?.bytes&&a?.sha256===b?.sha256;
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const started=performance.now();
const report={kind:'phase193-checked-fusion-budget-data-controls',version:1,
  complete:false,targetsRun:false,programsCompiled:false,expected,
  inputs:[pin(own),pin(out+'/driver.mjs'),pin(process.execPath),pin(path.join(workspace,'selfhost/tools/build/hosted.mjs'))],
  scope:'Seven finite profitability-boundary checks through the exact checked B1 API. Original planner/fallback composition is source-audited separately; no target execution, general semantic proof, or measured performance claim.'};
const save=()=>{report.seconds=(performance.now()-started)/1000;fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');};
save();
try{
  const affinity=fs.readFileSync('/proc/self/status','utf8').match(/^Cpus_allowed_list:\s*(.+)$/m)?.[1];
  need(affinity==='3','One outer guarded CPU3 lane required');report.cpu=3;
  const authority=read(args['--api']),assets=read(args['--assets']);
  need(authority.kind==='bend-checked-hosted-api'&&authority.complete===true&&authority.checked===true&&!authority.error&&!authority.changedInputs?.length,'Complete unchanged checked API required');
  need(assets.kind==='bend-build-assets'&&assets.complete===true&&authority.upstream?.revision===assets.upstream,'Matching pinned API/assets upstream required');
  const binding=authority.imageBinding;
  need(binding?.kind==='bend-build-image-binding'&&binding.complete&&binding.checked&&binding.host==='js'&&binding.stage==='B1'&&same(binding.image,authority.api)&&same(binding.sourceIdentity,authority.source),'Exact checked B1 binding required');
  need(authority.exports.includes('x193fb_controls'),'Checked budget control export required');
  const preparationFile=args['--source-manifest']??path.join(path.dirname(authority.source.file),'manifest.json');
  const preparation=read(preparationFile);
  need(preparation.kind==='phase190-api-source'&&preparation.complete===true&&same(preparation.source,authority.source),'Exact checked source preparation required');
  report.inputs.push(pin(args['--api']),pin(args['--assets']),pin(preparationFile),authority.source,authority.api,
    ...authority.inputs,preparation.snapshot);
  const engine=assets.assets?.bun;
  need(engine&&same(pin(process.execPath),engine),'Pinned JavaScript engine required');
  for(const relative of ['selfhost/tests/phase193/public-fusion-budget-experimental.bend',
    'selfhost/tests/phase193/public-fusion-budget-hook.bend']){
    const fixture=pin(path.join(workspace,relative));
    need(preparation.inputs.some(item=>item.file===fixture.file&&same(item,fixture)),'Budget module/hook absent from checked source: '+relative);
    report.inputs.push(fixture);
  }
  need(preparation.replacements.some(item=>item.name==='x193f_plan'),'Budget hook replacement provenance required');
  report.authority={receipt:pin(args['--api']),preparation:pin(preparationFile),source:authority.source,
    api:authority.api,parent:preparation.snapshot,replacements:preparation.replacements};
  report.inputs.forEach(verify);save();
  const api=(await import(pathToFileURL(authority.api.file))).default;
  need(typeof api.x193fb_controls==='function','Callable checked control export required');
  let list=api.x193fb_controls();const actual=[];
  while(list?.$==='Con'){
    need(actual.length<7&&typeof list.head==='string','Bounded seven-string control result required');
    actual.push(list.head);list=list.tail;
  }
  need(list?.$==='Nil','Complete finite control list required');
  report.actual=actual;save();
  need(JSON.stringify(actual)===JSON.stringify(expected),'Independent literal budget expectations differ');
  report.inputs.forEach(verify);report.controlsPassed=actual.length;report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,controls:report.controlsPassed??0,error:report.error}));
