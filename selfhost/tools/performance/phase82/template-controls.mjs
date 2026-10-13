// Append-only access to real compiler helpers; algorithm bodies remain intact.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baselineFile,candidateFile,outArg]=process.argv.slice(2),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const pin=file=>({file:path.resolve(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const report={complete:false,pass:false,inputs:[pin(import.meta.filename)],rows:[],images:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try {
 const apis={};
 for(const [role,file] of [['baseline',baselineFile],['candidate',candidateFile]]){
  const source=fs.readFileSync(file,'utf8'),b1=source.includes('function $ne_program_texts$(');
  const names=role==='baseline'?{texts:['ne_program_texts',2]}:{texts:['ne_runtime_texts',2],prepare:['ne_runtime_prepare',1],prefix:['ne_runtime_prepend',2]};
  const entries=Object.entries(names).map(([key,[name,arity]])=>{
   const symbol=b1?'$'+name+'$':'$jd$'+name.replaceAll('_','_95_');assert.equal(source.split('function '+symbol+'(').length,2,symbol);
   const args=Array.from({length:arity},(_,i)=>'a'+i).join(',');
   return JSON.stringify(key)+':run_lib(('+args+')=>run_loop('+symbol+'('+args+')),'+arity+')';
  });
  const append='\nexport const controls={'+entries.join(',')+'};\n',derived=path.join(out,role+'.mjs');
  fs.writeFileSync(derived,source+append,{flag:'wx'});assert.equal(fs.readFileSync(derived,'utf8').slice(0,source.length),source);
  apis[role]=(await import(pathToFileURL(derived))).controls;
  report.images.push({role,original:pin(file),derived:pin(derived),append});report.inputs.push(pin(file));
 }
 const manifestFile='selfhost/tools/performance/phase68/runtime-template-v2/controls-inputs.json';
 const manifest=JSON.parse(fs.readFileSync(manifestFile,'utf8'));report.inputs.push(pin(manifestFile));
 const cases=manifest.cases;
 const canonical='selfhost/src/runtime/native/runtime.c';report.inputs.push(pin(canonical));
 cases.push({name:'canonical',runtime:fs.readFileSync(canonical,'utf8'),texts:['tables','spins','segments','requests']});
 for(const row of cases){
  const prepared=apis.candidate.prepare(row.runtime),texts=list(row.texts);
  for(const prefix of ['', '#define EXAMPLE 1\n', '// comment\n', manifest.marks[0]+'\n', 'λ 😀\n']){
   const expected=apis.baseline.texts(prefix+row.runtime,texts);
   const actual=apis.candidate.texts(apis.candidate.prefix(prepared,prefix),texts);
   assert.equal(actual,expected,row.name+' '+JSON.stringify(prefix));
   report.rows.push({name:row.name,prefix,representation:prepared.$,chars:actual.length,pass:true});
  }
 }
 for(const p of report.inputs)assert.deepEqual(pin(p.file),p);
 report.complete=true;report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,count:report.rows.length,error:report.error}));
