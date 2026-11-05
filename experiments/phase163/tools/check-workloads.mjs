import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [receipt,out]=process.argv.slice(2);
const pin=file=>({file:path.resolve(file),bytes:fs.statSync(file).size,sha256:crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const r=JSON.parse(fs.readFileSync(receipt));assert(r.complete&&r.checked);assert.deepEqual(pin(r.api.file),r.api);
fs.mkdirSync(out,{recursive:false});const api=(await import(pathToFileURL(r.api.file))).default;
const rows=[];
for(const name of ['reverse','lookup'])for(const n of [0,1,2,7]){
 const got=api['p163w_'+name](n),expected=api['p163w_'+name+'_expected'](n);assert.deepEqual(got,expected);
 const body=JSON.stringify(got)+'\n';const file=path.join(out,`${name}-${n}.json`);fs.writeFileSync(file,body,{flag:'wx'});
 rows.push({name,n,complete:true,output:pin(file)});
}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({complete:true,inputs:[pin(receipt),r.api,pin(import.meta.filename)],rows,scope:'Checked hosted real helpers against independently constructed complete records. Native execution and direct-first lowering are separate gates.'},null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,controls:rows.length}));
