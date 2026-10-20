// Root-only transport for the checked Bend ordinary session control report.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [apiArg,outArg]=process.argv.slice(2);
if(!apiArg||!outArg||process.argv.length!==4)throw Error('Usage: scaling-report.mjs CHECKED_API FRESH_PHASE114_OUT');
const root=path.resolve(import.meta.dirname,'../../../../..'),apiFile=path.resolve(apiArg),out=path.resolve(outArg);
if(!out.startsWith(root+'/selfhost/build/phase114/')||fs.existsSync(out))throw Error('Fresh Phase114 output required');
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const verify=p=>{const q=pin(path.resolve(root,p.file));if(q.bytes!==p.bytes||q.sha256!==p.sha256)throw Error('Changed '+p.file);return q;};
const receiptFile=path.join(path.dirname(apiFile),'report.json'),receipt=JSON.parse(fs.readFileSync(receiptFile));
const entry='p114s_control_report';
if(!receipt.complete||!receipt.checked||!receipt.exports?.includes(entry)||path.resolve(receipt.api.file)!==apiFile)throw Error('Complete matching checked session-control API required');
verify(receipt.api);
const inputs=[pin(import.meta.filename),pin(apiFile),pin(receiptFile),...(receipt.inputs??[])];for(const p of inputs)verify(p);
fs.mkdirSync(out,{recursive:true});fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase114-checked-session-positive-controls',complete:false,targetExecutions:false,entry,expectedCount:18,inputs,rows:[],
 scope:'Invokes checked Bend ordinary session-control report and requires exactly eighteen PASS rows. Preserves source/API acquisition pins; no native program execution or performance claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try{
 const api=(await import(pathToFileURL(apiFile))).default;
 if(typeof api[entry]!=='function')throw Error('Checked export is not callable');
 const start=performance.now();let list=api[entry]();report.seconds=(performance.now()-start)/1000;
 for(;list?.$==='Con';list=list.tail){if(typeof list.head!=='string')throw Error('Non-string control row');report.rows.push(list.head);}
 if(list?.$!=='Nil')throw Error('Malformed control list');
 report.count=report.rows.length;report.complete=report.count===18&&report.rows.every(x=>x.startsWith('PASS '));
 for(const p of inputs)verify(p);
 console.log(JSON.stringify({complete:report.complete,count:report.count,rows:report.rows,seconds:report.seconds}));
}catch(error){report.error=String(error);throw error;}
finally{save();}
if(!report.complete)process.exitCode=1;
