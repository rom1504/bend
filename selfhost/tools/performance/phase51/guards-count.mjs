// Counter-only copied-module probe; timings from these derivatives are not evidence.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {fileURLToPath,pathToFileURL} from 'node:url';
const [inputsFile,selected,outArg]=process.argv.slice(2);assert.ok(inputsFile&&selected&&outArg);
const hash=b=>createHash('sha256').update(b).digest('hex');
const identity=f=>{f=f instanceof URL?fileURLToPath(f):f;return {file:path.resolve(f),bytes:fs.statSync(f).size,sha256:hash(fs.readFileSync(f))};};
const inputs=JSON.parse(fs.readFileSync(inputsFile,'utf8'));
assert.equal(inputs.roles.candidate.compiler.api.sha256,'6f9d111aa68c19f3ce45b80785621d57c4d10efb12d50164f5cb0597bc952100');
const requested=selected.split(',');assert.equal(new Set(requested).size,requested.length);
const out=path.resolve(outArg);assert.ok(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const bindings=[identity(inputsFile),identity(new URL(import.meta.url)),identity(process.execPath)];
const rows=[];const get=Object.getOwnPropertyDescriptor,define=Object.defineProperty;
for(const id of requested){
 const matches=inputs.cases.filter(c=>c.id===id);assert.equal(matches.length,1);const c=matches[0];
 assert.deepEqual(identity(c.module.file),c.module);bindings.push(c.module);
 const source=fs.readFileSync(c.module.file,'utf8'),prefix='G['+JSON.stringify(c.point.exportName)+']=';
 const lines=source.split('\n').filter(l=>l.startsWith(prefix));assert.equal(lines.length,1);
 const marker='/* private contextual instances */return ';assert.equal(lines[0].split(marker).length,2);
 const opening='function stringHostGuard(){';assert.equal(source.split(opening).length,2);
 assert.ok(!source.includes('$phase51StringCalls')&&!source.includes('$phase51RootEntries'));
 let changed=source.replace(lines[0],lines[0].replace(marker,'/* private contextual instances */$phase51RootEntries++;return '));
 changed=changed.replace(opening,'let $phase51StringCalls=0,$phase51RootEntries=0;\n'+opening+'$phase51StringCalls++;');
 changed+='\nexport const phase51GuardCounts={reset(){ $phase51StringCalls=0;$phase51RootEntries=0; },read(){return {stringCalls:$phase51StringCalls,rootEntries:$phase51RootEntries};},owned(name,args){return callOwned(get(G,name),args);}};\n';
 const file=path.join(out,id+'.mjs');fs.writeFileSync(file,changed,{flag:'wx'});const derivative=identity(file);bindings.push(derivative);
 const m=await import(pathToFileURL(file).href),probe=m.phase51GuardCounts;
 probe.reset();const value=m.default[c.point.exportName](...c.point.args);assert.deepEqual(value,c.point.expected);
 const clean=probe.read();assert.equal(clean.rootEntries,1,'clean selected contextual entry');
 let accessorMutation=null;
 if(c.point.args.length){
  const old=get(String.prototype,'charAt'),vector=[...c.point.args];let getterCalls=0,before;
  define(vector,'0',{configurable:true,get(){getterCalls++;before=probe.read();define(String.prototype,'charAt',{...old,value:function(){throw Error('unexpected charAt demand');}});return c.point.args[0];}});
  probe.reset();let observed,error;
  try{observed=probe.owned(c.point.exportName,vector);}catch(e){error=e;}finally{define(String.prototype,'charAt',old);}
  assert.equal(error,undefined,'charAt mutation must not introduce an observed demand in this point');
  assert.deepEqual(observed,c.point.expected);assert.equal(getterCalls,1);assert.equal(before.stringCalls,0);
  const after=probe.read();assert.equal(after.rootEntries,0,'mutated String must refuse selected entry');
  accessorMutation={getterCalls,before,after,oraclePassed:true};
  probe.reset();assert.deepEqual(m.default[c.point.exportName](...c.point.args),c.point.expected);
  assert.equal(probe.read().rootEntries,1,'restored selected entry');
 }
 rows.push({id,point:c.point,module:c.module,derivative,clean,accessorMutation});
}
for(const item of bindings)assert.deepEqual(identity(item.file),item);
const report={kind:'phase51-string-guard-counter',complete:true,pass:true,diagnosticOnly:true,node:process.version,
 inputs:bindings,cases:rows,scope:'Actual String-guard counts and selected-root entries on exact finite oracles. Diagnostic owned-call accessor vector tests getter ordering and refusal; this internal probe is stronger than ordinary public wrappers, not a public ABI expansion. No guard removed and no timing claim.'};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({pass:true,cases:rows.length,report:path.join(out,'report.json')}));
