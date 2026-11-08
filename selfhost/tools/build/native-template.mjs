#!/usr/bin/env node
// Runtime chunk decisions remain in the selected checked Bend compiler.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {pin,verify,requireThat,workspace} from './hosted.mjs';
import {runtimeArgumentConvention} from '../runtime-arguments.mjs';

const usage='Usage: native-template.mjs --authority CHECKED_B1_OR_B2_REPORT --runtime RUNTIME.c --out FRESH_BUILD_DIRECTORY [--runtime-argument-convention bend-legacy-v1|bend-rts-v1]';
if(process.argv.includes('--help')){console.log(usage);process.exit(0);}
const args={};for(let i=2;i<process.argv.length;i+=2){const key=process.argv[i].slice(2);requireThat(process.argv[i].startsWith('--')&&['authority','runtime','out','runtime-argument-convention'].includes(key)&&process.argv[i+1]&&!args[key],usage);args[key]=process.argv[i+1];}
const convention=runtimeArgumentConvention({runtimeArgumentConvention:args['runtime-argument-convention']});
for(const key of ['authority','runtime','out'])requireThat(args[key],'Missing --'+key+'\n'+usage);
const authorityPin=pin(args.authority),authority=JSON.parse(fs.readFileSync(authorityPin.file,'utf8'));
requireThat(authority.complete===true,'Incomplete producer authority');
let producer;
if(authority.kind==='bend-checked-hosted-api'){requireThat(authority.checked===true,'B1 source was not checked');producer=authority.api;}
else{requireThat(authority.kind==='bend-js-self-emission'&&authority.stage==='B2'&&authority.imageBinding?.checked===true,'Expected genuine checked B1 or emitted B2 receipt');producer=authority.image;}
const runtime=pin(args.runtime),source=verify(authority.source);verify(producer);
const out=path.resolve(args.out);requireThat(!fs.existsSync(out)&&out.startsWith(workspace+'/selfhost/build/'),'Fresh build output required');
const inputs=[pin(import.meta.filename),pin(path.join(workspace,'selfhost/tools/build/hosted.mjs')),pin(path.join(workspace,'selfhost/tools/bootstrap-config.mjs')),pin(path.join(workspace,'selfhost/tools/runtime-arguments.mjs')),pin(process.execPath),authorityPin,producer,source,runtime];
fs.mkdirSync(out,{recursive:true});
const report={kind:'bend-native-template',version:2,complete:false,producer,authority:authorityPin,source,runtime,runtimeArgumentConvention:convention,inputs,scope:'Checked Bend runtime scanner and exact chunk round-trip; declared runtime CLI, no compiler installation or runtime qualification.'};
try{
  const api=(await import(pathToFileURL(producer.file))).default;
  requireThat(typeof api.ne_runtime_prepare==='function','Producer lacks public ne_runtime_prepare');
  const text=fs.readFileSync(runtime.file,'utf8'),prepared=api.ne_runtime_prepare(text);
  requireThat(prepared?.$==='NE_Parts','Bend runtime scanner refused');
  const parts=[];let cursor=prepared.parts;
  while(cursor?.$==='Con'){requireThat(parts.length<5&&typeof cursor.head==='string','Invalid runtime parts');parts.push(cursor.head);cursor=cursor.tail;}
  requireThat(cursor?.$==='Nil'&&parts.length===5&&parts.join('')===text,'Runtime parts do not round-trip exactly');
  const output=path.join(out,'runtime-template.json');fs.writeFileSync(output,JSON.stringify({version:1,runtimeSha256:runtime.sha256,
    ...(args['runtime-argument-convention']?{runtimeArgumentConvention:convention}:{}),parts})+'\n',{flag:'wx'});
  inputs.forEach(verify);report.artifact=pin(output);report.chunks=parts.length;report.exactRoundTrip=true;report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,report:path.join(out,'report.json'),error:report.error}));
