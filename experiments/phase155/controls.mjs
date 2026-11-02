// Baseline/candidate differential screen; all candidate algorithms execute in checked Bend.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const a={}; for(let i=2;i<process.argv.length;i+=2) a[process.argv[i].slice(2)]=process.argv[i+1];
const root=path.resolve(import.meta.dirname,'../..');
const read=p=>JSON.parse(fs.readFileSync(p));
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=x=>{const y=pin(x.file);assert.equal(y.bytes,x.bytes);assert.equal(y.sha256,x.sha256)};
const plan=read(a.manifest), receipt=read(plan.apiReport), out=path.resolve(a.out);
assert(plan.complete&&receipt.complete&&receipt.checked); assert.deepEqual(plan.source,receipt.source);
assert(out.startsWith(root+'/selfhost/build/phase155/')&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const inputs=[pin(import.meta.filename),pin(a.manifest),pin(plan.apiReport),plan.source,receipt.api,...plan.inputs];
inputs.forEach(verify);
const report={kind:'phase155-checked-controls',complete:false,passed:false,inputs,source:plan.source,rows:[],extraChecks:[]};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
try{
 const api=(await import(pathToFileURL(receipt.api.file))).default;
 for(const c of plan.extraChecks??[]){
  const row={...c,passed:false};report.extraChecks.push(row);
  try{const raw=api[c.function](...c.arguments);row.actual=raw;const value=typeof c.expected==='boolean'?(typeof raw==='boolean'?raw:raw?.$==='True'):raw;assert.deepEqual(value,c.expected);row.passed=true;}
  catch(e){row.error=String(e.stack??e)} save();
 }
 for(const c of plan.cases){
  const row={id:c.id,title:c.title,passed:true,controls:[]};report.rows.push(row);
  for(const control of c.controls){
   const n=typeof control==='number'?control:control.n;
   const point={n,passed:false};row.controls.push(point);
   try{
    const old=api[c.old](n),next=api[c.new](n);assert.equal(typeof old,'string');
    point.old=old;point.new=next;assert.equal(next,old,'old/new result mismatch');
    const expected=typeof control==='object'?control.expected:c.expected?.[String(n)];
    if(expected!==undefined){assert.equal(old,String(expected),'independent expectation mismatch');point.independentExpected=String(expected)}
    point.passed=true;
   }catch(e){point.error=String(e.stack??e);row.passed=false;}
   save();
  }
 }
 inputs.forEach(verify);report.complete=true;report.passed=report.rows.every(x=>x.passed)&&report.extraChecks.every(x=>x.passed);
}catch(e){report.error=String(e.stack??e);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,cases:report.rows.length,failed:report.rows.filter(x=>!x.passed).map(x=>x.id),error:report.error}))}
