// Transpile immutable TypeScript; instrument ONLY generated JavaScript artifacts.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import assert from 'node:assert/strict';
const [planFile]=process.argv.slice(2),plan=JSON.parse(fs.readFileSync(planFile));
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const pin=f=>{f=fs.realpathSync(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:hash(b)}};
const verify=p=>assert.deepEqual(pin(p.file),p,p.file);
plan.inputs.forEach(verify);assert.equal(fs.realpathSync(process.execPath),plan.bun.file);
const out=plan.artifactDirectory;assert(!fs.existsSync(out));fs.mkdirSync(out);
const report={kind:'phase145-generated-upstream-diagnostic',complete:false,inputs:[pin(planFile),pin(import.meta.filename),...plan.inputs],modules:[],rules:[],scope:'Only generated/transpiled artifacts differ. Exact inverse restores clean transpiled module before appended wrappers. Source files are unchanged.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try{
 const transpiler=new Bun.Transpiler({loader:'ts',target:'bun'});
 for(const variant of ['clean','counted']){fs.mkdirSync(path.join(out,variant));fs.symlinkSync(plan.base.file,path.join(out,variant,'base.bend'));}
 for(const module of ['bend','comp']){
  const text=fs.readFileSync(plan.upstream[module].file,'utf8');
  let clean=transpiler.transformSync(text);
  if(module==='comp'){assert.equal(clean.split('"./bend.ts"').length,2);clean=clean.replace('"./bend.ts"','"./bend.mjs"');}
  const cleanFile=path.join(out,'clean',module+'.mjs');fs.writeFileSync(cleanFile,clean,{flag:'wx'});
  let altered=clean;const rules=[],wrappers=[];
  for(const name of new Set([...Object.keys(plan.counters[module]),...plan.stages[module]])){
   const declaration='function '+name+'(',exported=altered.includes('export '+declaration);
   const old=(exported?'export ':'')+declaration,replacement='function __p145original_'+name+'(';
   assert.equal(altered.split(old).length,2,'Unique generated declaration '+module+'.'+name);
   altered=altered.replace(old,replacement);rules.push({old,replacement});
   wrappers.push(`function ${name}(...args){return globalThis.__p145Observe(${JSON.stringify(module+'.'+name)},__p145original_${name},args,${JSON.stringify(plan.counters[module][name]??null)},${plan.stages[module].includes(name)});}${exported?'\nexport {'+name+'};':''}`);
  }
  const pointRules=[];
  function point(regex,make){const matches=[...altered.matchAll(regex)];assert.equal(matches.length,1,'Unique generated point '+regex);const old=matches[0][0],replacement=make(old);pointRules.push([old,replacement]);}
  if(module==='bend')point(/focus:\s*switch\s*\(tm\.\$\)\s*\{/g,old=>'globalThis.__p145Point("bend.wnf_dispatch",tm.$);\n'+old);
  else{
   point(/was = facts\(\)/g,old=>old+', globalThis.__p145Point("comp.fixedpoint_start",[FL.own.size,FL.hot.size,FL.stat.size])');
   point(/}\s*while\s*\(was !== facts\(\)\);/g,old=>old+'\n globalThis.__p145Point("comp.fixedpoint_end",[FL.own.size,FL.hot.size,FL.stat.size]);');
  }
  for(const [old,replacement] of pointRules){assert.equal(altered.split(old).length,2,'Unique generated point '+old);altered=altered.replace(old,replacement);rules.push({old,replacement});}
  const appended='\n// P145 OBSERVATION WRAPPERS\n'+wrappers.join('\n')+'\n';
  const instrumented=altered+appended;let inverse=instrumented.slice(0,-appended.length);
  for(const rule of [...rules].reverse())inverse=inverse.replace(rule.replacement,rule.old);
  assert.equal(inverse,clean,'Exact generated-source inverse');
  const countedFile=path.join(out,'counted',module+'.mjs');fs.writeFileSync(countedFile,instrumented,{flag:'wx'});
  report.modules.push({module,source:plan.upstream[module],clean:pin(cleanFile),counted:pin(countedFile),inverseExact:true});report.rules.push({module,rules,appended});
 }
 plan.inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{save();console.log(JSON.stringify({complete:report.complete,error:report.error}));}
