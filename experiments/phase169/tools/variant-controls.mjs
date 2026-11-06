// Finite admission controls only; malformed pointer bodies are never executed.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
import {pin,verify,items} from '../../phase147/tools/support.mjs';
const [receipt,out,mode]=process.argv.slice(2);assert(["lazy","admission","both"].includes(mode));fs.mkdirSync(out,{recursive:false});
const r=JSON.parse(fs.readFileSync(receipt));assert(r.complete&&r.checked);verify(r.api);
const a=(await import(pathToFileURL(r.api.file))).default;
const report={complete:false,inputs:[pin(import.meta.filename),pin(receipt),r.api],groups:[]};
try {
 const extra=mode==='lazy'?[['p169e_controls',16]]:mode==='admission'?[['p169q_controls',14]]:[['p169e_controls',16],['p169q_controls',14]];
 for(const [name,count] of [...extra,['p169s_controls',2],['p168tc_controls',4],['p167e_controls',30],['p167ob_controls',5],['p128bs_controls',12],['p128br_call_controls',10],['p128bl_controls',7]]){
  const rows=items(a[name]());report.groups.push({name,rows});assert.equal(rows.length,count);assert(rows.every(s=>s.endsWith(':pass')));
 }
 report.complete=true;
}catch(e){report.error=String(e.stack??e);process.exitCode=1;}
finally{fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,error:report.error}));}
