import fs from 'node:fs';import path from 'node:path';import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../..');
const [apiFile,sourceFile,name,out]=process.argv.slice(2);
if(fs.existsSync(out))throw Error('Fresh output');
const read=f=>JSON.parse(fs.readFileSync(f));
const a=read(apiFile),s=read(path.join(root,'selfhost/tools/native/selection.json'));
if(!a.complete||!a.checked)throw Error('Unchecked API');
const {base,cache}=read(s.admission.file).assets;
const api=(await import(pathToFileURL(a.api.file))).default;
const prep=api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(cache.carrier.file,'utf8'),cache.stamp);
const plan=api.p86_plan(prep.seed,path.resolve(sourceFile),fs.readFileSync(sourceFile,'utf8'));
if(plan.$!=='P86PlanReady')throw Error(plan.error);
let xs=api.p121c_debug(plan.request,name),rows=[];while(xs.$==='Con'){rows.push(xs.head);xs=xs.tail;}
fs.writeFileSync(out,JSON.stringify({rows},null,2)+'\n');console.log(rows.join('\n'));
