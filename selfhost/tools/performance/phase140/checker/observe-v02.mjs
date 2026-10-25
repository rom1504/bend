// Test-only orchestration. Source loading, freshening, checking and reuse execute
// in the independently checked Bend API. Graph equality observes every field.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [apiFile,outArg] = process.argv.slice(2);
const root=path.resolve(import.meta.dirname,'../../../../..');
const out=path.resolve(outArg);
assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase140/'));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=p=>assert.deepEqual(pin(p.file),p);
const apiReport=JSON.parse(fs.readFileSync(apiFile));assert(apiReport.complete&&apiReport.checked);
const source=apiReport.inputs.find(x=>x.file.endsWith('/compiler.bend'));
const sourceManifest=path.join(path.dirname(source.file),'manifest.json');
const manifest=JSON.parse(fs.readFileSync(sourceManifest));assert.deepEqual(manifest.source,source);
const inputs=[pin(import.meta.filename),pin(apiFile),pin(sourceManifest),apiReport.api,...apiReport.inputs,...manifest.inputs,pin(process.execPath)];
inputs.forEach(verify);fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={complete:false,kind:'phase140-checker-prefix-observation',source,api:apiReport.api,inputs,rows:[],scope:'Actual checked Bend frontend/checker/reuse plus independent full object-field equality; no native qualification or performance claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
function eq(a,b){
 const todo=[[a,b]],seen=new WeakMap();let objects=0,scalars=0;
 while(todo.length){const[x,y]=todo.pop();if(Object.is(x,y)){scalars++;continue;}
  if(x===null||y===null||typeof x!=='object'||typeof y!=='object'){assert.deepEqual(x,y);scalars++;continue;}
  let ys=seen.get(x);if(ys?.has(y))continue;if(!ys){ys=new WeakSet();seen.set(x,ys)}ys.add(y);objects++;
  const kx=Object.keys(x).sort(),ky=Object.keys(y).sort();assert.deepEqual(kx,ky);for(const k of kx)todo.push([x[k],y[k]]);
 }return{objects,scalars};
}
const list=xs=>{const a=[];while(xs.$==='Con'){a.push(xs.head);xs=xs.tail}assert.equal(xs.$,'Nil');return a};
try{
 const api=(await import(pathToFileURL(apiReport.api.file))).default;
 const rows=list(api.p140cc_controls());report.finite=rows;save();assert.equal(rows.length,15);assert(rows.every(x=>x.endsWith(':pass')));
 const header='type Bit is Data:\n  Off{}\n  Onn{}\ndef keep() -> Bit:\n  Off{}\n';
 const suffix='def edit() -> Bit:\n  Off{}\n';
 const base=header+suffix;
 const parse=text=>{const r=api.p140cc_parse(text);assert.equal(r.error,'');return r.book};
 const a=parse(base),seed=api.p140cp_seed('fixed-producer',a,2),cache=api.p140cp_saved(seed);
 const tests=[
  ['same',base,true],
  ['suffix-body',header+suffix.replace('Off{}','Onn{}'),true],
  ['suffix-invalid',header+suffix.replace('Off{}','Bit'),true],
  ['prefix-body',header.replace('  Off{}\ndef edit','  Onn{}\ndef edit').replace('def keep() -> Bit:\n  Off{}','def keep() -> Bit:\n  Onn{}')+suffix,false],
  ['header-type',header+suffix.replace('-> Bit','-> Data'),false],
  ['header-binder',header+'def edit(x: Bit) -> Bit:\n  x\n',false],
  ['suffix-insertion',base+'def extra() -> Bit:\n  Off{}\n',false],
  ['suffix-deletion',header,false],
  ['recovery',header+suffix.replace('Off{}','Onn{}'),true],
  ['revert',base,true],
 ];
 for(const[name,text,hit]of tests){
  const b=parse(text),fresh=api.dg_check_world(b),got=api.p140cp_replay('fixed-producer',b,cache);
  const row={name,expectedHit:hit,actualHit:got.reused===true,skipped:got.skipped,reason:got.reason};report.rows.push(row);
  assert.equal(row.actualHit,hit);row.equality=eq(got.checked,fresh);assert.equal(api.p140ce_checked(got.checked,fresh),true);
  row.resultEquality=eq(api.driver_program_checked(b,{$:'Nil'},got.checked),api.driver_program_checked(b,{$:'Nil'},fresh));row.complete=true;save();
 }
 // Complete-state observer must reject missing memo/checked/fresh fields,
 // independently from cache admission; in-process capability is trusted.
 const fresh=api.dg_check_world(a),world=fresh.result.world;
 report.worldKeys=Object.keys(world);report.resultKeys=Object.keys(fresh.result);
 inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e);process.exitCode=1;}finally{save();console.log(JSON.stringify({complete:report.complete,finite:report.finite,rows:report.rows,error:report.error}));}
