// Root-run same-image optional-product presence ablation; no API injection or priming.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [planFile,roleName,caseName,out]=process.argv.slice(2);
assert.ok(planFile&&roleName&&caseName&&out&&!fs.existsSync(out));
const hash=bytes=>createHash('sha256').update(bytes).digest('hex');
const identity=file=>({file:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const verify=item=>assert.equal(identity(item.file).sha256,item.sha256,item.file);
const plan=JSON.parse(fs.readFileSync(planFile,'utf8')),role=plan.roles[roleName],item=plan.cases.find(x=>x.id===caseName);
assert.ok(role&&item&&plan.diagnosticOnly&&!plan.productionQualified);
const report={kind:'phase65-base-annotation-presence-ablation-worker',complete:false,pass:false,
    diagnosticOnly:true,productionQualified:false,role:roleName,case:caseName,plan:identity(planFile),image:role.image,
    changes:role.changes,affinity:fs.readFileSync('/proc/self/status','utf8').split('\n').find(x=>x.startsWith('Cpus_allowed_list:'))};
try {
  assert.equal(report.affinity.split(':')[1].trim(),'3');
  assert.equal(fs.realpathSync(process.execPath),plan.node.file);verify(plan.node);
  for(const value of [...plan.inputs,...role.files,item.source,...item.files,...item.emissionInputs,item.expected])verify(value);
  function inventory(directory){const found=[];for(const name of fs.readdirSync(directory)){const file=path.join(directory,name),stat=fs.lstatSync(file);assert(!stat.isSymbolicLink());if(stat.isDirectory())found.push(...inventory(file));else{assert(stat.isFile());found.push(fs.realpathSync(file));}}return found.sort();}
  function verifyInventory(){
    assert.deepEqual(inventory(role.project),role.files.map(x=>fs.realpathSync(x.file)).sort(),'Cloned project membership changed');
    assert.equal(role.products.directory,path.join(role.project,'build/typed/base-products'));
    assert.equal(fs.existsSync(role.products.directory),role.products.exists,'Product directory presence changed');
    assert.deepEqual(role.products.exists?fs.readdirSync(role.products.directory).sort():[],role.products.files.map(x=>path.basename(x.file)).sort(),'Product inventory changed');
    for(const file of role.products.files)verify(file);
  }
  verifyInventory();report.products=role.products;
  const expected=fs.readFileSync(item.expected.file);
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
  process.env.BEND_TYPED_API=role.image.api.file;process.env.BEND_TYPED_RUNTIME=role.image.runtime.file;process.env.BEND_BASE=role.image.base.file;
  const imported=performance.now();const D=await import(pathToFileURL(role.image.driver.file));report.hostImportMs=performance.now()-imported;
  assert.equal(D.baseAnnotationDirectory,role.products.directory);
  assert.equal(D.apiPath,role.image.api.file);assert.equal(D.baseCacheGraphPath,path.join(role.project,'tools/base-cache-graph.mjs'));
  const apiStart=performance.now();await D.loadApi();report.apiLoadMs=performance.now()-apiStart;
  const begin=performance.now();const result=await D.inspect(item.source.file,{mode:'library',backend:'direct'});report.firstRequestMs=performance.now()-begin;
  report.importApiAndFirstMs=report.hostImportMs+report.apiLoadMs+report.firstRequestMs;
  assert.equal(result.status,'ok');assert.equal(result.checked,true);assert.equal(result.backend,'direct');
  assert.equal(result.interface,'upstream-callable');
  fs.writeFileSync(out+'.mjs',result.code,{flag:'wx'});
  report.emittedModule=identity(out+'.mjs');
  assert.equal(Buffer.compare(Buffer.from(result.code),expected),0,'Qualified raw module changed');
  const {code,...observation}=result;report.observation=observation;
  report.output={sha256:hash(Buffer.from(code)),bytes:Buffer.byteLength(code),reference:item.expected};
  verifyInventory();
  assert.deepEqual(fs.readdirSync(path.join(role.project,'build/typed/cache')).sort(),role.cache.map(x=>path.basename(x.file)).sort());
  for(const value of [...plan.inputs,...role.files,item.source,...item.files,...item.emissionInputs,item.expected])verify(value);
  assert.deepEqual(identity(planFile),report.plan);report.complete=report.pass=true;
} catch(error){report.error=String(error?.stack??error);process.exitCode=1}
finally{report.maxRssKiB=process.resourceUsage().maxRSS;fs.writeFileSync(out,JSON.stringify(report,null,2)+'\n',{flag:'wx'});
  console.log(JSON.stringify({pass:report.pass,role:roleName,case:caseName,firstRequestMs:report.firstRequestMs,error:report.error}));}
