// One paired full-source checker control, distinct from self-emission timing.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [oldArg,newArg,sourceArg,baseArg,outArg]=process.argv.slice(2);if(!outArg)throw Error('usage: signature-fullsource.mjs OLD_API NEW_API SOURCE BASE NEW_OUTPUT_DIRECTORY');
const files=[oldArg,newArg,sourceArg,baseArg].map(f=>fs.realpathSync(f)),[oldFile,newFile,source,base]=files,out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const hash=f=>createHash('sha256').update(fs.readFileSync(f)).digest('hex'),identities=Object.fromEntries([...files,import.meta.filename].map(f=>[f,hash(f)]));
const report={kind:'signature-index-fullsource-check',scope:'One paired checker-only observation on the same fully loaded book. Includes planning/checking; excludes loading from checker interval. This is not self-emission or an interleaved statistical estimate.',identities,node:process.version,args:process.execArgv,started:new Date().toISOString(),complete:false,rows:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const old=(await import(pathToFileURL(oldFile))).default,next=(await import(pathToFileURL(newFile))).default;
const nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
const started=performance.now();const loaded=old.f_load_graph(source,list([{$:'FSource',name:source,path:source,text:fs.readFileSync(source,'utf8')},{$:'FSource',name:'Base',path:base,text:fs.readFileSync(base,'utf8')}]));report.loadMs=performance.now()-started;assert.equal(loaded.error,'');console.log('loaded',report.loadMs);save();
for(const [variant,api] of [['baseline',old],['candidate',next]]){report.current=variant;save();const started=performance.now(),error=api.check_book(loaded.book);report.rows.push({variant,milliseconds:performance.now()-started,error});save();assert.equal(error,'');console.log(variant,report.rows.at(-1).milliseconds);}
assert(Object.entries(identities).every(([f,digest])=>hash(f)===digest));delete report.current;report.complete=true;report.finished=new Date().toISOString();save();console.log(JSON.stringify(report));
