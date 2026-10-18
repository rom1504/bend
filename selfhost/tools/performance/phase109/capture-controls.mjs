// Capture admission controls; do not execute emitted programs or injected APIs.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';
import {inspect} from '../../typed-driver.mjs';
const [source,outArg]=process.argv.slice(2),out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const tests=[
 ['requires-checked-graph',{mode:'native',captureNativeFacts:true},'captureNativeFacts requires captureCheckedGraph'],
 ['requires-native',{mode:'check',captureCheckedGraph:true,captureNativeFacts:true},'captureCheckedGraph requires native mode'],
 ['rejects-injected-api',{mode:'native',captureCheckedGraph:true,captureNativeFacts:true,api:{}},'driver-owned compiler API'],
 ['rejects-nonboolean',{mode:'native',captureCheckedGraph:true,captureNativeFacts:'yes'},'captureNativeFacts requires captureCheckedGraph'],
];
const rows=[];
for(const [name,options,message] of tests){const r=await inspect(source,options);rows.push({name,result:r,pass:r.status==='error'&&r.exitCode===1&&r.diagnostic.includes(message)&&!r.nativeFacts});}
const ordinary=await inspect(source,{mode:'check'});rows.push({name:'ordinary-check',result:ordinary,pass:ordinary.status==='ok'&&ordinary.exitCode===0&&!ordinary.nativeFacts&&!ordinary.checkedGraph});
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const report={kind:'phase109-capture-admission',complete:rows.every(x=>x.pass),source:{file:path.resolve(source),sha256:sha(source)},method:{file:import.meta.filename,sha256:sha(import.meta.filename)},rows};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,cases:rows.length}));if(!report.complete)process.exitCode=1;
