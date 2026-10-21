// Pure name-policy controls on the checked API; no reflected IR or native programs.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [apiArg,outArg]=process.argv.slice(2);
const root=path.resolve(import.meta.dirname,'../../../../..');
const apiFile=path.resolve(apiArg),out=path.resolve(outArg);
if(!out.startsWith(root+'/selfhost/build/phase114/')||fs.existsSync(out))throw Error('Fresh Phase114 output required');
const pin=p=>{const b=fs.readFileSync(p);return {file:path.resolve(p),bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const reportFile=path.join(path.dirname(apiFile),'report.json'),checked=JSON.parse(fs.readFileSync(reportFile));
const current=pin(apiFile);
if(!checked.complete||!checked.checked||current.sha256!==checked.api.sha256||current.bytes!==checked.api.bytes)throw Error('Checked API required');
const api=(await import(pathToFileURL(apiFile))).default;
const bool=x=>{if(!['True','False'].includes(x?.$))throw Error('Expected Bool');return x.$==='True';};
const cases=[];
for(let i=0;i<8;i++){
 const name=`p114h_case_${i}_local_scratch`;
 cases.push({name,table:bool(api.p114t_table_buffer(name)),buffer:bool(api.p114t_buffer(name)),originalLocal:bool(api.p114t_local_name(name)),expected:[true,true,false]});
}
for(const name of ['scratch','p114h_case_8_local_scratch','p114h_case_0_local_scratch_extra','p114h_case_00_local_scratch','ordinary']){
 cases.push({name,table:bool(api.p114t_table_buffer(name)),buffer:bool(api.p114t_buffer(name)),originalLocal:bool(api.p114t_local_name(name)),expected:[false,name==='scratch',true]});
}
for(const row of cases)row.pass=JSON.stringify([row.table,row.buffer,row.originalLocal])===JSON.stringify(row.expected);
fs.mkdirSync(out);const result={complete:cases.every(x=>x.pass),inputs:[current,pin(reportFile),pin(import.meta.filename)],cases,scope:'Finite ordinary String inputs; exact factory spellings and original-graph namespace policy. Does not establish ownership independently of the authenticated source factories.'};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({complete:result.complete,cases:cases.length}));if(!result.complete)process.exitCode=1;
