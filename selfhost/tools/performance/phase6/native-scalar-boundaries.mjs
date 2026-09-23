// Explicit boundary oracles, independent of the positive fixture's printed text.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {verifyAttempt,identity,verifyIdentity} from '../../development/workflow.mjs';
import {supervise,requireExecution} from '../../development/process.mjs';
const read=f=>JSON.parse(fs.readFileSync(f));
const [mode,attemptPath,sourcePath,directory,variant]=process.argv.slice(2),out=path.resolve(directory);
const save=(file,value)=>fs.writeFileSync(file,JSON.stringify(value,null,2)+'\n',{flag:'wx'});
if(mode==='worker') {
  const c=read(path.join(out,'config.json'));c.inputs.forEach(verifyIdentity);
  const work=path.join(out,variant+'-work');fs.mkdirSync(work);
  let result;
  if(variant==='reference') {
    const A=await import(pathToFileURL(c.referenceAdapter));
    result=await A.probe({test:{id:'phase6-native/fields-256',file:c.source.file},lane:'native',workdir:work,timeoutMs:60000,upstream:c.upstream});
  } else {
    const D=await import(pathToFileURL(c.driver));result=await D.inspect(c.source.file,{mode:'native',withReport:true});
  }
  c.inputs.forEach(verifyIdentity);
  const {code,...rest}=result;
  save(path.join(out,variant+'.json'),{result:rest,hasCode:typeof code==='string',workFiles:fs.readdirSync(work),inputsVerified:true});
  assert.equal(result.status,'error');assert.equal(result.phase,'compile');assert.equal(result.checked,true);assert.equal(result.exitCode,1);
  assert.equal(typeof code,'undefined');assert.deepEqual(fs.readdirSync(work),[]);
} else if(mode==='run') {
  const m=await verifyAttempt(path.resolve(attemptPath)),old=read(path.resolve('build/phase5/final-backends/broad-snapshot-04/snapshot.json'));
  fs.mkdirSync(out,{recursive:false});old.inputs.forEach(verifyIdentity);
  const inputs=[identity(import.meta.filename),identity(sourcePath),m.api,m.runtime,m.base,old.api,...m.snapshot.sources.map(x=>x.frozen),
    ...['bend.ts','comp.ts','base.bend'].map(n=>identity(path.join(m.config.upstream,'bend2',n)))];
  const c={source:identity(sourcePath),driver:path.join(m.snapshot.root,'tools/typed-driver.mjs'),referenceAdapter:path.join(m.snapshot.root,'tools/conformance/adapters/upstream.mjs'),upstream:m.config.upstream,inputs};
  save(path.join(out,'config.json'),c);
  const report={kind:'phase6-native-256-field-boundary',started:new Date().toISOString(),complete:false,pass:false,inputs,rows:[],
    oracle:{status:'error',phase:'compile',checked:true,exitCode:1,emittedC:false,nativeBuild:false},scope:'255 executes separately; this checked 256-field witness must stop before C emission.'};
  const flush=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');flush();
  try {
    for(const v of ['reference','baseline','candidate']) {
      const env={...process.env};for(const k of Object.keys(env))if(k.startsWith('BEND_')||k==='NODE_OPTIONS')delete env[k];
      Object.assign(env,{BEND_UPSTREAM:m.config.upstream,BEND_BASE:m.base.file,BEND_TYPED_RUNTIME:m.runtime.file,
        BEND_TYPED_API:v==='baseline'?old.api.file:m.api.file,BEND_TYPED_TRACE:'1'});
      const execution=await supervise('taskset',['-c','3',process.execPath,'--stack-size=4096','--max-old-space-size=4096',import.meta.filename,
        'worker',attemptPath,sourcePath,out,v],{directory:path.join(out,v+'-process'),env,timeoutMs:90000});
      report.rows.push({variant:v,execution,result:fs.existsSync(path.join(out,v+'.json'))?read(path.join(out,v+'.json')):null});flush();requireExecution(execution);
    }
    inputs.forEach(verifyIdentity);await verifyAttempt(path.resolve(attemptPath));old.inputs.forEach(verifyIdentity);
    report.complete=true;report.pass=true;report.inputsVerified=true;report.finished=new Date().toISOString();flush();console.log(JSON.stringify({report:path.join(out,'report.json'),pass:true}));
  } catch(error) {report.error=String(error.stack??error);report.finished=new Date().toISOString();flush();throw error;}
} else throw Error('Usage: native-scalar-boundaries.mjs run ATTEMPT SOURCE NEW_OUTPUT');
