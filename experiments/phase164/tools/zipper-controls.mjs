// Full data comparison: the host does not implement insertion or legality.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {pin,verify,items} from '../../phase147/tools/support.mjs';
const [receipt,out] = process.argv.slice(2);
const r = JSON.parse(fs.readFileSync(receipt));
assert(r.complete && r.checked); verify(r.api);
const api = (await import(pathToFileURL(r.api.file))).default;
fs.mkdirSync(out,{recursive:false});
const report = {complete:false,inputs:[pin(import.meta.filename),pin(receipt),r.api],rows:[],
  scope:'Exact full hosted constructor-data comparison against frozen current insertion; finite controls, not a theorem or native ownership proof.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const check=(name,old,value)=>{
  assert.deepStrictEqual(value,old,name);
  report.rows.push({name,sha256:crypto.createHash('sha256').update(JSON.stringify(old)).digest('hex')});
};
try {
  report.controls=items(api.p164xc_controls());
  assert.equal(report.controls.length,17);
  assert(report.controls.every(x=>x.endsWith(':pass')));
  for(let i=0;i<16;i++) check(`edge-${i}`,api.p164xc_edge(i,false),api.p164xc_edge(i,true));
  for(const seed of [0,1,7,3735928559]) for(const n of [0,1,2,7,31,64])
    for(let mode=0;mode<7;mode++) for(const legacy of [false,true])
      check(`${seed}-${n}-${mode}-${legacy}`,api.p164xc_case(seed,n,mode,legacy,false),
        api.p164xc_case(seed,n,mode,legacy,true));
  if(api.p164xw_map) {
    report.runtimeExpected=[];
    for(const mode of [0,1]) {
      for(const keys of [128,4096]) check(`workload-${keys}-${mode}`,
        api.p164xw_map(keys,mode,7,false),api.p164xw_map(keys,mode,7,true));
      const value=api.p164xw_run(4096,8,mode,false);
      assert.equal(api.p164xw_run(4096,8,mode,true),value);
      const file=path.join(out,`mode${mode}.expected`);
      fs.writeFileSync(file,String(value)+'\n',{flag:'wx'});
      report.runtimeExpected.push({keys:4096,rounds:8,mode,value,stdout:pin(file)});
    }
  }
  report.inputs.forEach(verify);report.complete=true;
} catch(error) {report.error=String(error.stack??error);process.exitCode=1;}
finally {save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));}
