// Root wraps this target in the common serial resource guard.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [manifestArg,outArg,mode='js']=process.argv.slice(2);
assert(['js','emit-native'].includes(mode));
const manifest=fs.realpathSync(manifestArg),out=path.resolve(outArg);
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:createHash('sha256').update(b).digest('hex')};};
const m=JSON.parse(fs.readFileSync(manifest));
const verify=()=>{for(const p of [...m.frozenInputs,...Object.values(m.b2)])assert.deepEqual(pin(p.file),p);};
verify();fs.mkdirSync(out,{recursive:false});
const report={kind:'phase96-production-law-execution',complete:false,passed:false,manifest:pin(manifest),method:pin(import.meta.filename),mode,compiler:m.b2,rows:[]};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
try{
  process.env.BEND_TYPED_API=m.b2.api.file;
  process.env.BEND_TYPED_RUNTIME=m.b2.runtime.file;
  process.env.BEND_BASE=m.b2.base.file;
  const D=await import(pathToFileURL(m.b2.driver.file));
  const start=performance.now();
  const result=await D.inspect(mode==='js'?m.library.file:m.native.file,{mode:mode==='js'?'library':'native',backend:mode==='js'?'direct':'js',withReport:true});
  const {code,...observation}=result;report.compile={ms:performance.now()-start,...observation};save();
  assert.equal(result.status,'ok');assert.equal(typeof code,'string');
  const product=out+(mode==='js'?'/laws.mjs':'/laws.c');fs.writeFileSync(product,code,{flag:'wx'});report.product=pin(product);save();
  if(mode==='js'){
    const module=await import(pathToFileURL(product));
    for(const row of m.cases){
      const record={id:row.id,family:row.family,passed:false};report.rows.push(record);
      try{assert.equal(typeof module.default[row.exportName],'function');const text=module.default[row.exportName]();assert.equal(typeof text,'string');record.actual=JSON.parse(text);record.expected=row.expectedWire;assert.deepEqual(record.actual,record.expected);record.passed=true;}
      catch(error){record.error=error.stack??String(error);}
    }
    report.passed=report.rows.every(row=>row.passed);report.complete=true;
  }else{report.complete=true;report.passed=true;report.nativeExecutionPerformed=false;}
  verify();report.inputsUnchanged=true;
}catch(error){report.complete=false;report.passed=false;report.error=error.stack??String(error);}
save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,cases:report.rows.length,failures:report.rows.filter(x=>!x.passed).map(x=>x.id),error:report.error}));
if(!report.passed)process.exitCode=1;
