// Finite admission controls only; malformed pointer bodies are never executed.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
import {pin,verify,items} from '../../phase147/tools/support.mjs';
const [receipt,out]=process.argv.slice(2);fs.mkdirSync(out,{recursive:false});
const r=JSON.parse(fs.readFileSync(receipt));assert(r.complete&&r.checked);verify(r.api);
const a=(await import(pathToFileURL(r.api.file))).default;
const report={complete:false,inputs:[pin(import.meta.filename),pin(receipt),r.api],groups:[]};
try {
 for(const [name,count] of [['p167e_controls',30],['p167ob_controls',5],['p128bs_controls',12],['p128br_call_controls',10],['p128bl_controls',7]]){
  const rows=items(a[name]());report.groups.push({name,rows});assert.equal(rows.length,count);assert(rows.every(s=>s.endsWith(':pass')));
 }
 report.complete=true;
}catch(e){report.error=String(e.stack??e);process.exitCode=1;}
finally{fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,error:report.error}));}
