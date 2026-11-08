#!/usr/bin/env node
// Execute the explicit checked Bend producer/decoder; compare full transported values.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {encodeBaseArena} from '../base-cache-graph.mjs';
import {frameProducts} from './base-carrier.mjs';
import {options,authority,preparation,pin,verify,requireThat,freshDirectory,save,read,digest} from './base-artifacts.mjs';

const args=options('Usage: base-verify.mjs --carrier CARRIER_REPORT --authority CHECKED_CONSUMER_API_REPORT --out FRESH_BUILD_DIRECTORY',
  ['carrier','authority','out']);
const carrierReceipt=pin(args.carrier),carrier=read(carrierReceipt.file),selected=authority(args.authority);
requireThat(carrier.kind==='bend-prepared-base-carrier'&&carrier.version===1&&carrier.complete===true&&
  carrier.format==='p130-word-pair-v1'&&carrier.inverseByteIdentity===true,'Expected complete maintained carrier');
for(const row of [...carrier.inputs,carrier.carrier,carrier.decimalCarrier])verify(row);
const prepared=preparation(carrier.preparation.file);
requireThat(prepared.receipt.sha256===carrier.preparation.sha256&&prepared.report.frame.sha256===carrier.frame.sha256&&
  prepared.report.api.sha256===carrier.api.sha256&&prepared.report.base.sha256===carrier.base.sha256,
  'Carrier/preparation identity differs');
requireThat(selected.source.sha256===prepared.report.source.sha256&&selected.source.bytes===prepared.report.source.bytes,
  'Producer and consumer must use the same checked compiler source');
const originalStamp='p88-private-base-text-1:'+digest(JSON.stringify(carrier.sourceIdentity));
requireThat(originalStamp===carrier.originalStamp&&carrier.stamp==='p130-word-pair-v1:'+originalStamp,'Carrier stamp differs');
const out=freshDirectory(args.out),inputs=[pin(import.meta.filename),pin(new URL('./base-carrier.mjs',import.meta.url)),
  pin(new URL('./base-artifacts.mjs',import.meta.url)),pin(new URL('./hosted.mjs',import.meta.url)),
  pin(new URL('../bootstrap-config.mjs',import.meta.url)),pin(new URL('../base-cache-graph.mjs',import.meta.url)),pin(process.execPath),
  carrierReceipt,selected.receipt,selected.api,selected.source,...carrier.inputs,carrier.carrier,carrier.decimalCarrier];
const report={kind:'bend-prepared-base-verification',version:1,complete:false,carrier:carrierReceipt,
  authority:selected.receipt,consumer:selected.api,source:selected.source,inputs,nativeAdmission:false,
  scope:'Complete frame/live/P88/P130 named-value equality through checked hosted Bend entries, including source interval and all mandatory roots. Native requests and output qualification remain separate.'};
const start=performance.now();
try{
  const product=frameProducts(carrier),expected=encodeBaseArena(product.roots).bytes;
  requireThat(carrier.sourceIdentity.format==='p88-private-base-text-1'&&carrier.sourceIdentity.termAbi===1&&
    carrier.sourceIdentity.spanAbi===3&&carrier.sourceIdentity.worldVersion===3&&
    carrier.sourceIdentity.base===carrier.base.sha256&&carrier.sourceIdentity.path===carrier.base.file&&
    carrier.sourceIdentity.api===carrier.api.sha256&&carrier.sourceIdentity.cache===carrier.frame.sha256&&
    carrier.sourceIdentity.begin===product.header.sourceBegin&&carrier.sourceIdentity.end===product.header.sourceEnd&&
    carrier.sourceBegin===product.header.sourceBegin&&carrier.sourceEnd===product.header.sourceEnd,
    'Carrier source binding differs');
  const api=(await import(pathToFileURL(selected.api.file))).default;
  requireThat(typeof api.p86_prepare==='function'&&typeof api.p88_cache_prepare==='function','Consumer lacks live/cache preparation');
  const baseText=fs.readFileSync(carrier.base.file,'utf8');
  const live=api.p86_prepare(carrier.base.file,baseText);
  const seedOf=result=>{
    requireThat(result?.$==='P86PreparationReady',result?.error??'Base preparation refused');
    const s=result.seed;
    requireThat(s?.$==='P86Seed'&&s.world?.$==='KBasePreparedWorld'&&s.world.prefix===s.book&&
      s.world.state?.ready===true&&s.fresh?.ready===true&&s.ready?.ready===true,'Prepared roots/aliases refused');
    return s;
  };
  const liveSeed=seedOf(live),sourceText=JSON.stringify(liveSeed.source);
  const canonical=seed=>encodeBaseArena([seed.book,seed.world.state,seed.fresh,seed.world,seed.ready]).bytes;
  const liveBytes=canonical(liveSeed);
  requireThat(expected.equals(liveBytes),'Complete frame and live prepared values differ');
  report.comparisons=[];
  for(const [format,file,stamp] of [['p88-private-base-text-1',carrier.decimalCarrier,carrier.originalStamp],
    ['p130-word-pair-v1',carrier.carrier,carrier.stamp]]){
    const cached=seedOf(api.p88_cache_prepare(carrier.base.file,baseText,fs.readFileSync(file.file,'utf8'),stamp));
    requireThat(JSON.stringify(cached.source)===sourceText,'Live/cache source identity differs: '+format);
    const bytes=canonical(cached);requireThat(expected.equals(bytes),'Complete live/cache prepared values differ: '+format);
    report.comparisons.push({format,completeValueEquality:true,sourceEquality:true,canonicalBytes:bytes.length,canonicalSha256:digest(bytes)});
  }
  report.frameLiveEquality=true;report.sourceIdentitySha256=digest(sourceText);
  inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
report.seconds=(performance.now()-start)/1000;save(path.join(out,'report.json'),report);
console.log(JSON.stringify({complete:report.complete,report:path.join(out,'report.json'),error:report.error}));
