// Root-run packaging control; never compiles, installs, or mutates the real release.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [projectArg,patchArg,outArg]=process.argv.slice(2);
assert(projectArg&&patchArg&&outArg,'Usage: helper-integrity.mjs SELFHOST PATCH_JSON FRESH_OUT');
const project=fs.realpathSync(projectArg),out=path.resolve(outArg),patchFile=fs.realpathSync(patchArg);
assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=bytes=>createHash('sha256').update(bytes).digest('hex');
const identity=file=>({file:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const patch=read(patchFile),releaseTool=path.join(project,'tools/development/release.mjs');
assert.equal(identity(releaseTool).sha256,patch.after.sha256,'Reviewed packaging patch is not installed');
const {verifyRelease}=await import(pathToFileURL(releaseTool));
const report={kind:'phase63-release-graph-helper-integrity',complete:false,pass:false,
  compilerExecuted:false,installedReleaseMutated:false,producer:identity(import.meta.filename),
  patch:identity(patchFile),packager:identity(releaseTool),checks:[]};
try{
 const manifestFile=path.join(project,'dist/release.json');
 const manifest=verifyRelease(project),before=identity(manifestFile);
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
  fs.appendFileSync(helper,'\n// Phase63 integrity negative control\n');
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
 assert.equal(identity(releaseTool).sha256,patch.after.sha256);
 report.copiedFileCount=files.length;report.complete=report.pass=true;
}catch(error){report.error={message:error.message,stack:error.stack};process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,checks:report.checks.length,error:report.error?.message}));
