#!/usr/bin/env node
// IO wrapper only. Loading, checking and prepared-state construction run in Bend.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {driverInputs} from './hosted.mjs';
import {options,authority,pin,verify,requireThat,freshDirectory,save,workspace} from './base-artifacts.mjs';

const args=options('Usage: base-prepare.mjs --authority CHECKED_API_REPORT --base EXACT_BASE --out FRESH_BUILD_DIRECTORY',
  ['authority','base','out']);
const selected=authority(args.authority),base=pin(args.base);
requireThat(base.bytes>0&&base.bytes<=16*1024*1024,'Base exceeds bounded reader');
const out=freshDirectory(args.out),cacheDirectory=path.join(out,'cache');
const inputs=[pin(import.meta.filename),pin(new URL('./base-artifacts.mjs',import.meta.url)),
  pin(new URL('./hosted.mjs',import.meta.url)),pin(process.execPath),...driverInputs(),
  pin(path.join(workspace,'selfhost/tools/runtime-arguments.mjs')),selected.receipt,selected.api,selected.source,base];
const report={kind:'bend-prepared-base-frame',version:1,complete:false,fresh:true,backendProducts:false,
  authority:selected.receipt,api:selected.api,source:selected.source,base,inputs,cacheDirectory,
  scope:'Bend-produced checked Base and mandatory preparation; fresh private frame4 transport, no old cache or optional annotation sidecar.'};
const start=performance.now();
try{
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
  process.env.BEND_TYPED_API=selected.api.file;process.env.BEND_BASE=base.file;
  const driver=await import(pathToFileURL(path.join(workspace,'selfhost/tools/typed-driver.mjs')));
  requireThat(driver.apiPath===selected.api.file&&driver.basePath===base.file,'Driver image/Base binding differs');
  const cached=await driver.prepareBase(undefined,{backendProducts:false,cacheDirectory,fresh:true});
  requireThat(cached.compilerSha256===selected.api.sha256&&cached.baseSha256===base.sha256&&cached.sourcePath===base.file,
    'Produced Base identity differs');
  requireThat(cached.checkedPrefixState?.ready===true&&cached.freshPrefixState?.ready===true&&
    cached.frontendReadyState?.ready===true&&cached.preparedWorld?.state?.ready===true,'Incomplete prepared Base products');
  const files=fs.readdirSync(cacheDirectory);
  requireThat(files.length===1&&files[0].endsWith('-frame4.json'),'Expected exactly one fresh frame4 artifact');
  report.frame=pin(path.join(cacheDirectory,files[0]));
  requireThat(report.frame.bytes<=128*1024*1024,'Prepared frame exceeds bounded codec');
  report.sourceBegin=cached.sourceBegin;report.sourceEnd=cached.sourceEnd;
  inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
report.seconds=(performance.now()-start)/1000;save(path.join(out,'report.json'),report);
console.log(JSON.stringify({complete:report.complete,report:path.join(out,'report.json'),frame:report.frame,error:report.error}));
