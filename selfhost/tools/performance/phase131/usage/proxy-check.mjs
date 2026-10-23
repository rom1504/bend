import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [manifestFile,oldFile,newFile,outArg]=process.argv.slice(2);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(root+'/selfhost/build/phase131/')&&!fs.existsSync(out));
const read=f=>JSON.parse(fs.readFileSync(f));
const pin=f=>{const file=path.resolve(f),b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const inputs=new Map();
const add=p=>{assert.deepEqual(pin(p.file),p);inputs.set(p.file,p);return p;};
const file=f=>add(pin(f));
file(manifestFile);const manifest=read(manifestFile);assert(manifest.complete&&!manifest.targetsRun);
manifest.inputs.forEach(add);add(manifest.expected);file(import.meta.filename);file(process.execPath);
const report={complete:false,rows:[],scope:'Checked compiler-query extraction and independent deterministic output oracle. Hosted execution only; diagnostic elapsed cost is not native performance.'};
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};save();
try{
  for(const [label,receiptFile] of [['original',oldFile],['summary',newFile]]){
    file(receiptFile);const receipt=read(receiptFile);assert(receipt.complete&&receipt.checked&&receipt.status===0);
    receipt.inputs.forEach(add);add(receipt.api);add(manifest.variants[label].source);
    assert(receipt.inputs.some(x=>x.file===manifest.variants[label].source.file));
    const api=(await import(pathToFileURL(receipt.api.file))).default;
    let list=api.p131u_controls(),controls=[];
    while(list?.$==='Con'){assert(controls.length<22);controls.push(list.head);list=list.tail;}
    assert.equal(list?.$,'Nil');assert.equal(controls.length,22);assert(controls.every(x=>x.endsWith(':pass')));
    const outputs=[];
    for(let mode=0;mode<3;mode++){
      const start=performance.now(),actual=String(api.p131k_case(mode)),seconds=(performance.now()-start)/1000;
      assert.equal(actual,manifest.oracle[mode]);outputs.push({mode,actual,diagnosticSeconds:seconds});
    }
    report.rows.push({label,controls,outputs,source:manifest.variants[label].source,api:receipt.api});save();
  }
  for(const p of inputs.values())add(p);report.complete=true;
}catch(error){report.error=String(error);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));}
