// Same-source complete observation comparison; parser/checker/observer are Bend.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
import {pin,verify} from '../../phase147/tools/support.mjs';
const [baseline,compact,base,out,...sources]=process.argv.slice(2);fs.mkdirSync(out,{recursive:false});
const report={complete:false,inputs:[pin(import.meta.filename),pin(base)],preparation:{},rows:[],scope:'Checked hosted Bend frontend; times include complete canonical observation, exclude one-time separately measured Base preparation. Not native self-build gains.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');const variants={};
try{
 for(const [name,file] of [['baseline',baseline],['compact',compact]]){
  const r=JSON.parse(fs.readFileSync(file));assert(r.complete&&r.checked);verify(r.api);report.inputs.push(pin(file),r.api);
  const api=(await import(pathToFileURL(r.api.file))).default;const t=performance.now(),prepared=api.p163f_prepare(fs.readFileSync(base,'utf8'));
  assert.equal(prepared.$,'P86PreparationReady',JSON.stringify(prepared));report.preparation[name]=(performance.now()-t)/1000;variants[name]={api,seed:prepared.seed};save();
 }
 for(const [index,source] of sources.entries()){
  const input=pin(source),text=fs.readFileSync(source,'utf8');report.inputs.push(input);
  for(const mode of ['parse','check']){
   const row={source:input,mode,results:{},complete:false};report.rows.push(row);save();
   for(const name of index%2?['compact','baseline']:['baseline','compact']){
    const {api,seed}=variants[name],start=performance.now(),value=api['p163f_'+mode+'_prepared'](seed,text);const seconds=(performance.now()-start)/1000;
    assert.equal(typeof value,'string');const file=path.join(out,`${index}-${mode}-${name}.txt`);fs.writeFileSync(file,value,{flag:'wx'});row.results[name]={seconds,output:pin(file)};save();
   }
   const b=row.results.baseline.output,c=row.results.compact.output;row.equal=b.bytes===c.bytes&&b.sha256===c.sha256;assert(row.equal,'Complete observation mismatch '+source+' '+mode);row.complete=true;save();
  }
 }
 report.inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack??e);process.exitCode=1}finally{save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}))}
