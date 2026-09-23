// P5-021 cost falsifier. Instrument a copied host; do not change cache policy.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../development/workflow.mjs';
import {verifyEqualityDerivation} from '../../development/equality.mjs';

const [snapshotArgument, selectionArgument, outputArgument] = process.argv.slice(2);
if (!outputArgument) throw Error('Usage: base-cache-cost.mjs SNAPSHOT.json SELECTION.json NEW_OUTPUT');
const snapshotFile=fs.realpathSync(snapshotArgument), selectionFile=fs.realpathSync(selectionArgument);
const snapshot=JSON.parse(fs.readFileSync(snapshotFile)), output=path.resolve(outputArgument);
fs.mkdirSync(output,{recursive:false});
const sha=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
const identity=file=>({file:fs.realpathSync(file),sha256:sha(fs.readFileSync(file))});
const inputs=new Map(), capture=file=>{const row=identity(file);inputs.set(row.file,row);return row;};
const report={kind:'phase5-base-cache-cost-falsifier',complete:false,compilerExecuted:false,
  started:new Date().toISOString(),node:process.version,nodeArgs:process.execArgv,rows:[],inputs:[],
  scope:'Instrumented request cost attribution; control confirms unchanged results. No candidate or end-to-end speedup. cacheTotal includes baseIdentity and read/decode/verify; nested costs are not additive.'};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(output,'report.json'),JSON.stringify(report,null,2)+'\n');};
save();
try {
  await verifyAttempt(snapshot.attempt);
  await verifyEqualityDerivation(snapshot.derivation.file);
  for(const file of [snapshotFile,selectionFile,import.meta.filename,snapshot.derived.file,snapshot.base.file,snapshot.runtime.file])capture(file);
  const selections=JSON.parse(fs.readFileSync(selectionFile));
  const cases=selections.map(row=>({...row,file:fs.realpathSync(path.resolve(path.dirname(selectionFile),row.file))}));
  assert.equal(cases.length,21,'Use the preregistered focused development selection');
  for(const test of cases)capture(test.file);
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
  Object.assign(process.env,{BEND_TYPED_API:snapshot.derived.file,BEND_BASE:snapshot.base.file,BEND_TYPED_RUNTIME:snapshot.runtime.file});
  const outputs=new Map();
  for(const variant of ['control','instrumented']) {
    const project=path.join(output,variant),tools=path.join(project,'tools');
    fs.mkdirSync(tools,{recursive:true});
    for(const name of ['typed-driver.mjs','compiler-abi.mjs','node-resource-args.mjs','native-build.mjs','assemble.mjs']) {
      const source=path.join(snapshot.project,'tools',name);capture(source);fs.copyFileSync(source,path.join(tools,name));capture(path.join(tools,name));
    }
    const cacheSource=path.join(snapshot.project,'build/typed/cache'),cacheTarget=path.join(project,'build/typed/cache');
    fs.mkdirSync(cacheTarget,{recursive:true});
    for(const name of fs.readdirSync(cacheSource)) {
      const file=path.join(cacheSource,name);if(!fs.statSync(file).isFile())continue;
      capture(file);fs.copyFileSync(file,path.join(cacheTarget,name));capture(path.join(cacheTarget,name));
    }
    const driverFile=path.join(tools,'typed-driver.mjs');
    if(variant==='instrumented') {
      let source=fs.readFileSync(driverFile,'utf8');
      const replace=(from,to)=>{assert.equal(source.split(from).length,2,'Unique instrumentation site: '+from);source=source.replace(from,to);};
      replace("const cached=JSON.parse(fs.readFileSync(info.file,'utf8'));",
        "const text=p5Cost('readCache',()=>fs.readFileSync(info.file,'utf8'));\n    const cached=p5Cost('decodeCache',()=>JSON.parse(text));");
      replace("crypto.createHash('sha256').update(JSON.stringify(cached.book)).digest('hex')",
        "p5Cost('verifyBook',()=>crypto.createHash('sha256').update(JSON.stringify(cached.book)).digest('hex'))");
      replace('readBaseCache(baseCacheInfo(api))',"p5Cost('cacheTotal',()=>readBaseCache(p5Cost('baseIdentity',()=>baseCacheInfo(api))))");
      source += '\nconst p5Costs={};\nfunction p5Cost(name,fn){const begin=performance.now();try{return fn();}finally{p5Costs[name]=(p5Costs[name]||0)+performance.now()-begin;}}\nexport function p5CostReset(){const result={...p5Costs};for(const name of Object.keys(p5Costs))delete p5Costs[name];return result;}\n';
      fs.writeFileSync(driverFile,source);
    }
    capture(driverFile);
    const driver=await import(pathToFileURL(driverFile)),api=await driver.loadApi();
    // Warm the actual API/host route once; both caches were primed outside this experiment.
    await driver.inspect(cases[2].file,{mode:'check',api});driver.p5CostReset?.();
    report.compilerExecuted=true;
    for(let repetition=0;repetition<2;repetition++)for(const test of repetition?[...cases].reverse():cases) {
      for(const mode of ['parse','check']) {
        const begin=performance.now(),result=await driver.inspect(test.file,{mode,api}),milliseconds=performance.now()-begin;
        const costs=driver.p5CostReset?.()??null,key=test.id+'\0'+mode;
        if(result.files)for(const file of result.files)capture(file);
        if(variant==='control') {
          if(outputs.has(key))assert.deepEqual(result,outputs.get(key));else outputs.set(key,result);
        }else assert.deepEqual(result,outputs.get(key),'Instrumentation changed '+key);
        report.rows.push({variant,repetition,id:test.id,mode,milliseconds,costs,result});save();
      }
    }
  }
  for(const row of inputs.values())assert.equal(identity(row.file).sha256,row.sha256,'Input drift: '+row.file);
  await verifyAttempt(snapshot.attempt);await verifyEqualityDerivation(snapshot.derivation.file);
  const measured=report.rows.filter(row=>row.variant==='instrumented');
  const sum=fn=>measured.reduce((total,row)=>total+fn(row),0);
  const total=sum(row=>row.milliseconds),avoid=sum(row=>(row.costs.decodeCache||0)+(row.costs.verifyBook||0));
  report.summary={observations:report.rows.length,instrumentedRequestMs:total,
    costs:Object.fromEntries(['readCache','decodeCache','verifyBook','baseIdentity','cacheTotal'].map(name=>[name,sum(row=>row.costs[name]||0)])),
    avoidableDecodeVerifyMs:avoid,avoidableFraction:avoid/total,passesFivePercentFalsifier:avoid/total>=0.05};
  report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
report.finished=new Date().toISOString();save();console.log(JSON.stringify({complete:report.complete,error:report.error,summary:report.summary}));
