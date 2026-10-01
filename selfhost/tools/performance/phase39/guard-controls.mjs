// Actual saved-output scopes and public fallback observations; no timings.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import{createHash}from'node:crypto';import{pathToFileURL}from'node:url';
const[baseArg,outArg]=process.argv.slice(2);assert(baseArg&&outArg,'guard-controls.mjs DERIVED NEW_OUT');
const base=fs.realpathSync(baseArg),out=path.resolve(outArg);assert(!fs.existsSync(out));
const identity=p=>({path:fs.realpathSync(p),sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex')});
const manifestFile=path.join(base,'derive.json'),manifest=JSON.parse(fs.readFileSync(manifestFile));
assert.equal(manifest.kind,'phase39-scalar-root-scope-prototype');assert.equal(manifest.complete,true);
fs.mkdirSync(out,{recursive:false});fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
const report={kind:'phase39-scope-prototype-controls',complete:false,pass:false,node:process.version,inputs:[import.meta.filename,manifestFile].map(identity),observations:[]};
const record=(kind,data)=>report.observations.push({kind,...data});
try{
 for(const row of manifest.inputs){assert.deepEqual(identity(row.path),row);report.inputs.push(row);}
 const variants={};
 for(const row of manifest.modules.filter(x=>x.counters)){assert.deepEqual(identity(row.path),{path:row.path,sha256:row.sha256});report.inputs.push(identity(row.path));variants[row.variant]=await import(pathToFileURL(row.path));}
 const baseline=variants.baseline;
 for(const args of [[0,0],[1,2440],[3,2240],[64,2440],[256,2240]]){
  baseline.guardReset();const expected=baseline.default['coverage.active'](...args),baseStats=baseline.guardStats();
  if(args[0]===256)assert.equal(expected,2166930202);
  for(const name of ['scope','scope-no-finite']){const m=variants[name];m.guardReset();const value=m.default['coverage.active'](...args),stats=m.guardStats();
   assert.equal(value,expected);assert.equal(stats.active,false);assert.equal(stats.opens,stats.closes);assert.equal(stats.rootEntries,1);assert.equal(stats.opens,1);assert.equal(stats.fullHost,1);
   if(args[0]>0){assert(baseStats.fullHost>stats.fullHost);assert.equal(stats.fullScalar,1);}
   if(name==='scope-no-finite')assert.equal(stats.finite,0);
   record('ordinary',{variant:name,args,expected,value,baseStats,stats});
  }
 }
 // A successful preceding call must not exempt the next public call from checks.
 for(const target of ['nearest','trace','F32.to_u32'])for(const name of ['scope','scope-no-finite']){
  const observe=m=>{m.default['coverage.active'](1,2440);m.guardReset();const f=m.G[target],old=f.code;let calls=0,active=false;
   f.code=function(a){calls++;active ||= m.guardStats().active;return Reflect.apply(old,this,[a]);};
   try{return{value:m.default['coverage.active'](2,2440),calls,active,stats:m.guardStats()};}finally{f.code=old;}};
  const a=observe(baseline),b=observe(variants[name]);assert.equal(b.value,a.value);assert.equal(b.calls,a.calls);assert(a.calls>0);assert.equal(b.active,false);assert.equal(b.stats.rootEntries,0);assert.equal(b.stats.active,false);
  record('dependency-after-success',{variant:name,target,expected:a,actual:b});
 }
 for(const hook of ['fround','number-bounce'])for(const name of ['scope','scope-no-finite']){
  const observe=m=>{m.guardReset();let calls=0,active=false,nested=false,reentered=false;
   const event=()=>{calls++;active ||= m.guardStats().active;if(!nested&&!reentered){nested=true;reentered=true;try{assert.equal(m.default['coverage.active'](0,0),0);}finally{nested=false;}}};
   let restore;
   if(hook==='fround'){const old=Math.fround;Math.fround=function(x){event();return old(x);};restore=()=>{Math.fround=old;};}
   else{const old=Object.getOwnPropertyDescriptor(Number.prototype,'bounce');Object.defineProperty(Number.prototype,'bounce',{configurable:true,get(){event();return undefined;}});restore=()=>{if(old)Object.defineProperty(Number.prototype,'bounce',old);else delete Number.prototype.bounce;};}
   try{return{value:m.default['coverage.active'](1,2440),calls,active,reentered,stats:m.guardStats()};}finally{restore();}};
  const a=observe(baseline),b=observe(variants[name]);assert.equal(b.value,a.value);assert.equal(b.calls,a.calls);assert(a.calls>0,hook+' exercised');assert.equal(b.active,false);assert.equal(b.reentered,true);assert.equal(b.stats.rootEntries,0);assert.equal(b.stats.active,false);
  record('host-hook-reentry',{variant:name,hook,expected:a,actual:b});
 }
 // This particular ray output does not execute DataView operations. Assert
 // conservative refusal explicitly, without inventing a callback witness.
 for(const name of ['scope','scope-no-finite']){
  const m=variants[name],old=DataView.prototype.getFloat32;let calls=0;
  DataView.prototype.getFloat32=function(...a){calls++;return Reflect.apply(old,this,a);};
  let value,expected,stats;try{m.guardReset();expected=baseline.default['coverage.active'](1,2440);value=m.default['coverage.active'](1,2440);stats=m.guardStats();}finally{DataView.prototype.getFloat32=old;}
  assert.equal(value,expected);assert.equal(stats.rootEntries,0);assert.equal(stats.opens,0);assert.equal(stats.active,false);assert.equal(calls,0);
  record('unused-dataview-refusal',{variant:name,expected,value,calls,stats});
 }
 for(const name of ['scope','scope-no-finite']){
  const m=variants[name],f=m.G['coverage.active'];m.guardReset();
  const raw=m.call(f.code([1,2440]),[]);assert.equal(raw,baseline.default['coverage.active'](1,2440));assert.equal(m.guardStats().rootEntries,0);
  m.guardReset();const partial=m.call(f,[1]),value=m.call(partial,[2440]);assert.equal(value,raw);assert.equal(m.guardStats().opens,1);
  m.guardReset();const a=(()=>{try{baseline.call(baseline.G['coverage.active'],[1,2440,9]);}catch(e){return{name:e.name,message:e.message};}})();
  let b;try{m.call(f,[1,2440,9]);}catch(e){b={name:e.name,message:e.message};}assert.deepEqual(b,a);assert(a);assert.equal(m.guardStats().rootEntries,0);assert.equal(m.guardStats().active,false);
  record('entry-staging',{variant:name,raw,partial:value,extraError:b,stats:m.guardStats()});
 }
 // Fault injection only after the actual new try begins validates cleanup.
 // It is diagnostic evidence, not a source-derived legal callback path.
 const parent=manifest.modules.find(x=>x.variant==='scope'&&x.counters);let text=fs.readFileSync(parent.path,'utf8');
 const marker='const $previousProof=regionProofOpen($guards);try{';const line=text.split('\n').find(l=>l.startsWith('G["coverage.active"]'));
 assert(line&&line.split(marker).length===2);const at=text.indexOf(line)+line.indexOf(marker)+marker.length;
 const injected=text.slice(0,at)+`if($p39Fault){if(!regionProofCovers(['nearest'])||regionProofCovers(['IO.print']))throw Error('wrong scope coverage');return bad('p39 injected failure');}`+text.slice(at)+`\nlet $p39Fault=false;export function guardFault(x){$p39Fault=x;}\n`;
 const faultPath=path.join(out,'fault.mjs');fs.writeFileSync(faultPath,injected,{flag:'wx'});report.fault={parent:identity(parent.path),output:identity(faultPath),scope:'Post-admission bad() fault injection; never timed.'};report.inputs.push(identity(faultPath));
 const fault=await import(pathToFileURL(faultPath)),oldError=globalThis.Error;let reentry=0,proofDuring;
 fault.guardFault(true);globalThis.Error=function(message){proofDuring=fault.guardStats().active;fault.guardFault(false);reentry++;assert.equal(fault.default['coverage.active'](0,0),0);return new oldError(message);};
 let error;try{fault.default['coverage.active'](1,2440);}catch(e){error={name:e.name,message:e.message};}finally{globalThis.Error=oldError;fault.guardFault(false);}
 assert.deepEqual(error,{name:'Error',message:'p39 injected failure'});assert.equal(proofDuring,false);assert.equal(reentry,1);assert.equal(fault.guardStats().active,false);assert.equal(fault.guardStats().opens,fault.guardStats().closes);
 record('injected-error-reentry',{error,reentry,proofDuring,stats:fault.guardStats()});
 for(const row of report.inputs)assert.deepEqual(identity(row.path),row);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,observations:report.observations.length,error:report.error}));
