import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [outArg]=process.argv.slice(2),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const D=await import('../../../typed-driver.mjs');
const api=await D.loadApi();
const root=path.resolve(import.meta.dirname,'../../../../..');
const pin=p=>({file:p,sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex')});
const report={complete:false,inputs:[pin(process.env.BEND_TYPED_API),pin(D.driverPath),pin(D.basePath),pin(path.join(root,'selfhost/src/runtime/native/runtime.c'))],rows:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const flags=code=>[...code.matchAll(/^#define NATIVE_(?:SCALAR|UNSHARED)_ARRAYS ([01])$/gm)].slice(0,2).map(m=>Number(m[1]));
try {
 const cases=[
  ['array','selfhost/tools/performance/phase46/array-batch.bend',[1,1]],
  ['atomic','tests/run/array_atomic_fadd.bend',[1,0]],
  ['race','tests/run/array_redirect_race.bend',[1,0]],
  ['boxed','tests/reg/array_clone_boxed.bend',[0,0]],
  ['nested','tests/reg/array_nested.bend',[0,0]],
  ['boundary','selfhost/tools/performance/phase68/scalar-layout/fixtures/u32-boundary.bend',[1,1]],
 ];
 for(const [name,relative,expected] of cases){
  const file=path.join(root,relative);const r=await D.inspect(file,{mode:'native'});
  assert.equal(r.status,'ok',JSON.stringify(r));assert.deepEqual(flags(r.code),expected,name);
  const output=path.join(out,name+'.c');fs.writeFileSync(output,r.code);
  report.rows.push({name,source:pin(file),flags:expected,output:pin(output),pass:true});save();
 }
 // Exercise the same checked source through the untrusted raw API boundary,
 // and through the checked entry with foreign-effect permission withheld.
 const file=path.join(root,cases.at(-1)[1]);
 for(const mode of ['raw','untrusted-effects']){
  const wrapped={...api,nc_compile_checked:(book,runtime,requests)=>mode==='raw'?api.nc_compile(book,runtime,requests):api.nc_compile_checked(book,runtime,requests,false)};
  const r=await D.inspect(file,{mode:'native',api:wrapped});assert.equal(r.status,'ok',JSON.stringify(r));
  assert(!/^#define NATIVE_(SCALAR|UNSHARED)_ARRAYS 1$/m.test(r.code),mode);
  const output=path.join(out,mode+'.c');fs.writeFileSync(output,r.code);report.rows.push({name:mode,output:pin(output),pass:true});save();
 }
 report.complete=true;
} finally {save();}
console.log(JSON.stringify({complete:report.complete,rows:report.rows.length}));
