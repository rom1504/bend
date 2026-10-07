// Root-run demand diagnostic. Ordinary inspect owns its API; no timing claims.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [planFile,caseName,out]=process.argv.slice(2);
assert(planFile&&caseName&&out&&!fs.existsSync(out));
const hash=bytes=>createHash('sha256').update(bytes).digest('hex');
const identity=file=>({file:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const verify=item=>assert.equal(identity(item.file).sha256,item.sha256,item.file);
const plan=JSON.parse(fs.readFileSync(planFile,'utf8')),item=plan.cases.find(x=>x.id===caseName);
assert(item&&plan.kind==='phase64-state09-demand-plan'&&plan.diagnosticOnly&&!plan.productionQualified);
const report={kind:'phase64-state09-demand-worker',complete:false,pass:false,diagnosticOnly:true,
  timingClaims:false,productionQualified:false,case:caseName,plan:identity(planFile),image:plan.image,
  changes:plan.changes,affinity:fs.readFileSync('/proc/self/status','utf8').split('\n').find(x=>x.startsWith('Cpus_allowed_list:'))};
let helper;
try{
  assert.equal(report.affinity.split(':')[1].trim(),'3');
  assert.equal(fs.realpathSync(process.execPath),plan.node.file);verify(plan.node);
  const inputs=[...plan.inputs,...plan.files,...plan.copiedOriginals,item.source,...item.files,...item.emissionInputs,item.expected];
  for(const value of inputs)verify(value);
  const expected=fs.readFileSync(item.expected.file);
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
  process.env.BEND_TYPED_API=plan.image.api.file;process.env.BEND_TYPED_RUNTIME=plan.image.runtime.file;process.env.BEND_BASE=plan.image.base.file;
  helper=await import(pathToFileURL(path.join(plan.project,'tools/base-cache-graph.mjs')));
  assert.equal(typeof helper.setDemandPhase,'function');assert.equal(typeof helper.getDemandReport,'function');
  helper.setDemandPhase('driver-import');
  const D=await import(pathToFileURL(plan.image.driver.file));
  assert.equal(D.apiPath,plan.image.api.file);assert.equal(D.baseCacheGraphPath,path.join(plan.project,'tools/base-cache-graph.mjs'));
  helper.setDemandPhase('api-import');await D.loadApi();
  helper.setDemandPhase('driver');
  const result=await D.inspect(item.source.file,{mode:'library',backend:'direct'});
  helper.setDemandPhase('after-request');
  assert.equal(result.status,'ok');assert.equal(result.checked,true);assert.equal(result.backend,'direct');
  assert.equal(result.interface,'upstream-callable');
  fs.writeFileSync(out+'.mjs',result.code,{flag:'wx'});report.emittedModule=identity(out+'.mjs');
  assert.equal(Buffer.compare(Buffer.from(result.code),expected),0,'Qualified raw module changed');
  const {code,...observation}=result;report.observation=observation;
  report.output={sha256:hash(Buffer.from(code)),bytes:Buffer.byteLength(code),reference:item.expected};
  assert.deepEqual(fs.readdirSync(path.join(plan.project,'build/typed/cache')).sort(),plan.cache.map(x=>path.basename(x.file)).sort());
  for(const value of inputs)verify(value);
  assert.deepEqual(identity(planFile),report.plan);
  assert(helper.getDemandReport().decodedNodes>0,'Prepared graph was not observed');
  report.complete=report.pass=true;
}catch(error){report.error=String(error?.stack??error);process.exitCode=1;}
finally{
  if(helper){
    const demand=helper.getDemandReport();
    fs.writeFileSync(out+'.demand.json',JSON.stringify(demand,null,2)+'\n',{flag:'wx'});
    report.demand=identity(out+'.demand.json');
    report.summary={decodedNodes:demand.decodedNodes,wrappedNodes:demand.wrappedNodes,accessedNodes:demand.accessedNodes,
      phases:demand.phases.map(x=>({name:x.name,reads:x.reads,nodeCount:x.nodeCount,definitionBodies:x.definitionBodies.length})),limits:demand.limits};
  }
  fs.writeFileSync(out,JSON.stringify(report,null,2)+'\n',{flag:'wx'});
  console.log(JSON.stringify({pass:report.pass,case:caseName,summary:report.summary,error:report.error}));
}
