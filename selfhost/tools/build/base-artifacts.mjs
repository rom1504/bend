// Shared identities and bounded IO for maintained Base artifact commands.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pin,verify,requireThat,workspace} from './hosted.mjs';
export {pin,verify,requireThat,workspace};
export const digest=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
export const save=(file,value)=>fs.writeFileSync(file,JSON.stringify(value,null,2)+'\n',{flag:'wx'});
export function read(file,limit=1024*1024){
  requireThat(fs.statSync(file).size<=limit,'Oversized receipt: '+file);
  return JSON.parse(fs.readFileSync(file,'utf8'));
}
export function options(usage,keys){
  if(process.argv.includes('--help')){console.log(usage);process.exit(0);}
  const args={};
  for(let i=2;i<process.argv.length;i+=2){
    const key=process.argv[i].slice(2);
    requireThat(process.argv[i].startsWith('--')&&keys.includes(key)&&process.argv[i+1]&&!args[key],usage);
    args[key]=process.argv[i+1];
  }
  for(const key of keys)requireThat(args[key],'Missing --'+key+'\n'+usage);
  return args;
}
export function freshDirectory(file){
  const out=path.resolve(file),build=path.join(workspace,'selfhost/build');
  requireThat(out.startsWith(build+'/')&&!fs.existsSync(out),'Fresh selfhost/build child required');
  let parent=path.dirname(out);
  while(!fs.existsSync(parent))parent=path.dirname(parent);
  requireThat(fs.realpathSync(parent)===parent,'Output parent must not traverse a symlink');
  fs.mkdirSync(out,{recursive:true});return out;
}
export function authority(file){
  const receipt=pin(file),report=read(receipt.file);
  requireThat(report.kind==='bend-checked-hosted-api'&&report.version===1&&report.complete===true&&report.checked===true,
    'Expected a complete checked hosted API authority');
  const api=verify(report.api),source=verify(report.source);
  requireThat(report.imageBinding?.checked===true&&report.imageBinding.image?.sha256===api.sha256&&
    report.imageBinding.sourceIdentity?.sha256===source.sha256,'Checked API/source binding differs');
  return {receipt,api,source,report};
}
export function preparation(file){
  const receipt=pin(file),report=read(receipt.file);
  requireThat(report.kind==='bend-prepared-base-frame'&&report.version===1&&report.complete===true&&
    report.fresh===true&&report.backendProducts===false,'Expected a fresh checked Base preparation');
  for(const item of [...report.inputs,report.frame])verify(item);
  const selected=authority(report.authority.file);
  requireThat(selected.receipt.sha256===report.authority.sha256&&selected.api.sha256===report.api.sha256&&
    selected.source.sha256===report.source.sha256,'Preparation authority differs');
  verify(report.base);
  return {receipt,report,selected};
}
