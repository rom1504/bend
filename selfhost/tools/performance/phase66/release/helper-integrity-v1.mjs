// Root-run packaging control; never compiles, installs, or mutates the real release.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [projectArg,attemptArg,outArg]=process.argv.slice(2);
assert(projectArg&&attemptArg&&outArg,'Usage: helper-integrity-v1.mjs SELFHOST CHECKED_ATTEMPT_JSON FRESH_OUT');
const project=fs.realpathSync(projectArg),out=path.resolve(outArg),attemptFile=fs.realpathSync(attemptArg);
assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=bytes=>createHash('sha256').update(bytes).digest('hex');
const identity=file=>({file:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const attempt=read(attemptFile),releaseTool=path.join(project,'tools/development/release.mjs');
const verify=item=>{const got=identity(item.file);assert.equal(got.sha256,item.sha256);return got;};
assert.equal(attempt.checked,true);assert.equal(attempt.artifactKind,'derived-b1');assert.equal(attempt.config.strictExact,true);
const validationFile=path.join(path.dirname(attemptFile),'validation-001/report.json'),validation=read(validationFile);
assert.equal(validation.complete,true);assert.equal(validation.pass,true);assert.equal(validation.strictExact,true);
assert.deepEqual(verify(validation.attempt),identity(attemptFile));
assert.equal(verify(validation.api).sha256,verify(attempt.api).sha256);
assert.equal(validation.selected.selectedComplete,true);assert.equal(validation.selected.exactDifferences,0);assert.equal(validation.selected.discrepancies,0);
for(const role of ['candidate','reference'])assert.equal(validation.selected[role].statuses.pass,36);
const frozenTool=path.join(attempt.snapshot.root,'tools/development/release.mjs');
const sources=attempt.snapshot.sources.filter(row=>fs.realpathSync(row.frozen.file)===fs.realpathSync(frozenTool));
assert.equal(sources.length,1);
const expectedTool=verify(sources[0].frozen);
assert.equal(identity(releaseTool).sha256,expectedTool.sha256,'Selected checked packager is not installed');
const {verifyRelease}=await import(pathToFileURL(releaseTool));
const report={kind:'phase66-release-graph-helper-integrity',complete:false,pass:false,
  compilerExecuted:false,installedReleaseMutated:false,producer:identity(import.meta.filename),
  attempt:identity(attemptFile),validation:identity(validationFile),frozenPackager:expectedTool,packager:identity(releaseTool),checks:[]};
try{
 const manifestFile=path.join(project,'dist/release.json');
 const manifest=verifyRelease(project),before=identity(manifestFile);
 const api=manifest.files.find(row=>row.path==='dist/typed-api.mjs');assert(api);
 assert.equal(api.sha256,attempt.api.sha256);
 assert.equal(identity(path.join(project,'dist/typed-api.mjs')).sha256,attempt.api.sha256);
 const checkedApi=manifest.files.find(row=>row.path==='dist/release-lineage/checked-api.mjs');assert(checkedApi);
 assert.equal(checkedApi.sha256,verify(attempt.checkedApi).sha256);
 const checkedBootstrap=manifest.files.find(row=>row.path==='dist/release-lineage/checked-bootstrap.json');assert(checkedBootstrap);
 assert.equal(checkedBootstrap.sha256,verify(attempt.bootstrapReport).sha256);
 const helperRelative='tools/base-cache-graph.mjs';
 const entry=manifest.checkout.find(x=>x.path===helperRelative);assert(entry);
 const bootstrap=read(path.join(project,'dist/release-lineage/checked-bootstrap.json'));
 const checked=bootstrap.provenance.inputs.filter(x=>x.role==='host-tool'&&path.basename(x.file)==='base-cache-graph.mjs');
 assert.equal(checked.length,1);assert.equal(entry.sha256,checked[0].sha256);
 report.release=before;report.helper=identity(path.join(project,helperRelative));
 report.checks.push({name:'installed-helper-bound-to-checked-provenance',pass:true});
 const copy=path.join(out,'copy');fs.mkdirSync(copy);
 const files=[...new Set([...manifest.files,...manifest.checkout].map(x=>x.path).concat('dist/release.json'))];
 for(const name of files){
  assert(!path.isAbsolute(name)&&!name.split('/').includes('..'));
  const dest=path.join(copy,name);fs.mkdirSync(path.dirname(dest),{recursive:true});
  fs.copyFileSync(path.join(project,name),dest,fs.constants.COPYFILE_EXCL);
 }
 verifyRelease(copy);report.checks.push({name:'copied-inventory-verifies',pass:true});
 const helper=path.join(copy,helperRelative),bytes=fs.readFileSync(helper);
 try{
  fs.appendFileSync(helper,'\n// Phase66 integrity negative control\n');
  assert.throws(()=>verifyRelease(copy),/Changed release input: tools\/base-cache-graph\.mjs/);
  report.checks.push({name:'tampered-helper-rejected',pass:true});
 }finally{fs.writeFileSync(helper,bytes);}
 try{
  fs.unlinkSync(helper);
  assert.throws(()=>verifyRelease(copy),/ENOENT/);
  report.checks.push({name:'missing-helper-rejected',pass:true});
 }finally{fs.writeFileSync(helper,bytes);}
 const copiedManifest=path.join(copy,'dist/release.json'),manifestBytes=fs.readFileSync(copiedManifest);
 try{
  const unbound=read(copiedManifest);unbound.checkout=unbound.checkout.filter(x=>x.path!==helperRelative);
  fs.writeFileSync(copiedManifest,JSON.stringify(unbound));
  assert.throws(()=>verifyRelease(copy),/Unbound checked graph helper/);
  report.checks.push({name:'helper-omitted-from-inventory-rejected',pass:true});
 }finally{fs.writeFileSync(copiedManifest,manifestBytes);}
 verifyRelease(copy);assert.deepEqual(identity(manifestFile),before);
 assert.deepEqual(identity(path.join(project,helperRelative)),report.helper);
 assert.equal(identity(releaseTool).sha256,expectedTool.sha256);
 assert.deepEqual(identity(attemptFile),report.attempt);assert.deepEqual(identity(validationFile),report.validation);
 assert.deepEqual(identity(frozenTool),report.frozenPackager);
 report.copiedFileCount=files.length;report.complete=report.pass=true;
}catch(error){report.error={message:error.message,stack:error.stack};process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,checks:report.checks.length,error:report.error?.message}));
