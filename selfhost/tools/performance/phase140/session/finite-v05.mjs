// Execute checked Bend controls; no compiler decisions are implemented here.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [receipt,outArg]=process.argv.slice(2),out=path.resolve(outArg);
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=p=>assert.deepEqual(pin(p.file),p);
const r=JSON.parse(fs.readFileSync(receipt));assert(r.complete&&r.checked);r.inputs.forEach(verify);verify(r.api);assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase140-composed-native-finite',complete:false,inputs:[pin(import.meta.filename),pin(receipt),r.api,...r.inputs],groups:[],scope:'Finite controls, not a whole compiler theorem or native qualification.'};
try {const api=(await import(pathToFileURL(r.api.file))).default;for(const[name,count]of[['p140rw_controls',6],['p140n_controls',20],['p140cb_cut_controls',7],['p140nb_controls',14],['p140eqc_controls',40],['p140gm_controls',16],['p140lc_controls',32],['p140cat_controls',4],['p140gc_controls',7],['p140ec_controls',5],['p140spc_controls',35],['p140dr_controls',15],['p140vt_controls',25],['p140vm_controls',10]]){const rows=[];let xs=api[name]();for(let n=0;n<count+1&&xs.$==='Con';n++){rows.push(xs.head);xs=xs.tail;}assert.equal(xs.$,'Nil');assert.equal(rows.length,count);assert(rows.every(x=>x.startsWith('PASS ')||x.endsWith(':pass')),JSON.stringify(rows));report.groups.push({name,rows});}report.inputs.forEach(verify);report.complete=true;}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,error:report.error,groups:report.groups.map(g=>[g.name,g.rows.length])}));}
