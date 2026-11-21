import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
const [out,dir,...files]=process.argv.slice(2);
fs.mkdirSync(out);
const read=p=>JSON.parse(fs.readFileSync(p)), hash=b=>crypto.createHash('sha256').update(b).digest('hex');
function auth(pin){let b=fs.readFileSync(pin.file);if(b.length!==pin.bytes||hash(b)!==pin.sha256)throw Error(pin.file);return b.toString()}
let receipt=read(dir+'/report.json'),s=auth(receipt.api);
function trace(name,code){let rx=new RegExp('function \\$'+name+'\\([^\\n]*\\) \\{');if(!rx.test(s))throw Error(name);s=s.replace(rx,'$&'+code)}
trace('p205u_checked','globalThis.dec.push({name:_changed_0.name,error:_result_0.error,res:Object.keys(_result_0)});globalThis.last=_changed_0;')
trace('p205_ready','globalThis.index=_edits_0;globalThis.ctx=_context_0;')
const a=(await import('data:text/javascript;base64,'+Buffer.from(s).toString('base64'))).default;
const b=read('selfhost/build/phase197/shared-emission-plan01.json').producer.bindingValue;
const prep=a.p88_cache_prepare(b.base.file,auth(b.base),auth(b.carrier),b.stamp);
const report={api:receipt.api,rows:[]};
for(const f of files){globalThis.dec=[];globalThis.index=null;globalThis.last=null;
 const src=fs.readFileSync(f);const plan=a.p86_plan(prep.seed,path.resolve(f),src.toString());
 let names=plan.request?.names,helpers=[];while(names?.$==='Con'){if(names.head.startsWith('$p205.one.'))helpers.push(names.head);names=names.tail}
 report.rows.push({file:f,sha:hash(src),status:plan.$,error:plan.error,decisions:dec,edits:index?.$,reachableSyntheticHelpers:helpers});
 if(last)fs.writeFileSync(out+'/last-'+path.basename(f)+'.json',JSON.stringify(last,(k,v)=>k==='removed'?undefined:v));
 fs.writeFileSync(out+'/results.json',JSON.stringify(report,null,2));
}
