#!/usr/bin/env node
// Exact-source host-unit controls; no compiler image, imported driver, or effect execution.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import vm from 'node:vm';
import {fileURLToPath} from 'node:url';

const [metadataArg,outArg]=process.argv.slice(2);
assert(metadataArg&&outArg,'usage: base-host-controls-v1.mjs candidate.json fresh-output-directory');
const metadataPath=path.resolve(metadataArg),out=path.resolve(outArg);
assert(!fs.existsSync(out),'output must be fresh');fs.mkdirSync(out,{recursive:true});
const sha=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
const hash=file=>sha(fs.readFileSync(file));
const metadata=JSON.parse(fs.readFileSync(metadataPath,'utf8'));
const pins=[{file:metadataPath,sha256:hash(metadataPath)},{file:fileURLToPath(import.meta.url),sha256:hash(fileURLToPath(import.meta.url))}];
for(const row of metadata.files){assert.equal(hash(row.candidate),row.afterSha256);pins.push({file:row.candidate,sha256:row.afterSha256});}
assert.equal(hash(metadata.patch.file),metadata.patch.sha256);pins.push(metadata.patch);
const fileByPath=p=>metadata.files.find(row=>row.path===p).candidate;
const driver=fs.readFileSync(fileByPath('selfhost/tools/typed-driver.mjs'),'utf8');
const manifest=JSON.parse(fs.readFileSync(fileByPath('selfhost/src/runtime/js/effs/manifest.json'),'utf8'));
const sourceBase=path.join(metadata.reference,'bend2/base.bend');
assert.equal(hash(sourceBase),metadata.base.sha256);pins.push({file:sourceBase,sha256:hash(sourceBase)});
assert.equal(manifest.revision,metadata.upstreamRevision);assert.equal(manifest.base.sha256,metadata.base.sha256);
assert.equal(manifest.files.length,35);assert.equal(new Set(manifest.files.map(x=>x.path)).size,35);
for(const row of manifest.files){
  const file=path.join(metadata.reference,row.upstreamPath);assert.equal(hash(file),row.sha256);assert.equal(fs.statSync(file).size,row.bytes);pins.push({file,sha256:row.sha256});
}
const project=path.join(out,'project'),effects=path.join(project,'src/runtime/js/effs'),basePath=path.join(project,'base.bend');
fs.mkdirSync(effects,{recursive:true});fs.copyFileSync(sourceBase,basePath);
const manifestPath=path.join(effects,'manifest.json');
const writeManifest=value=>fs.writeFileSync(manifestPath,JSON.stringify(value));writeManifest(manifest);
function slice(start,end){const a=driver.indexOf(start),b=driver.indexOf(end,a+start.length);assert(a>=0&&b>a);assert.equal(driver.indexOf(start,a+start.length),-1);return driver.slice(a,b);}
const resolverSource=slice('function directForeignResolver(paths) {','export async function inspect(');
const resolver=vm.runInNewContext('('+resolverSource.trim()+')',{fs,path,hash,project,basePath});
const rows=[];function check(name,fn){fn();rows.push({name,status:'pass'});}
const imported=name=>path.join(project,'effs',name);
check('new-pinned-base-35-listed-providers',()=>{
  const r=resolver(manifest.files.map(row=>imported(row.path)));assert.equal(r.inputs[0],manifestPath);
  for(const row of manifest.files)assert.equal(r.resolve(imported(row.path)),path.join(effects,row.path));
});
check('removed-poll-files-retain-original-path',()=>{
  const r=resolver(['x']);for(const name of ['tcp_poll.js','udp_poll.js'])assert.equal(r.resolve(imported(name)),imported(name));
});
check('user-provider-path-retains-original-path',()=>{
  const file=path.join(project,'user','effs','print.js');assert.equal(resolver([file]).resolve(file),file);
});
check('custom-base-comment-retains-original-path',()=>{
  fs.appendFileSync(basePath,'\n# Phase66 inert custom Base control\n');
  assert.notEqual(hash(basePath),manifest.base.sha256);const r=resolver(['x']);
  for(const row of manifest.files)assert.equal(r.resolve(imported(row.path)),imported(row.path));
  fs.copyFileSync(sourceBase,basePath);
});
check('base-decision-does-not-survive-next-request',()=>assert.equal(resolver(['x']).resolve(imported('print.js')),path.join(effects,'print.js')));
check('no-paths-do-not-read-manifest',()=>{
  fs.renameSync(manifestPath,manifestPath+'.saved');try{const r=resolver([]);assert.equal(r.inputs.length,0);assert.equal(r.resolve('x'),path.resolve('x'));}finally{fs.renameSync(manifestPath+'.saved',manifestPath);}
});
for(const [name,value] of [
  ['old-37-inventory-refused',{...manifest,files:[...manifest.files,{path:'tcp_poll.js'},{path:'udp_poll.js'}]}],
  ['duplicate-inventory-refused',{...manifest,files:[...manifest.files.slice(1),manifest.files[1]]}],
  ['invalid-provider-path-refused',{...manifest,files:manifest.files.map((row,i)=>i?row:{...row,path:'../print.js'})}],
  ['invalid-base-hash-refused',{...manifest,base:{...manifest.base,sha256:'bad'}}]
])check(name,()=>{writeManifest(value);try{assert.throws(()=>resolver(['x']),/Invalid pinned JS effect/);}finally{writeManifest(manifest);}});
const qualified=/const BASE_ANNOTATION_BASE_SHA256='([0-9a-f]{64})';/.exec(driver);assert(qualified);
const annotationSource=`const BASE_ANNOTATION_BASE_SHA256=${JSON.stringify(qualified[1])};\n`+
  slice('function withBaseAnnotationFile(info,cached,consume) {','function decodeBaseAnnotationProduct(')+
  slice('function prepareBaseAnnotations(api,cached,info) {','export async function prepareBase(')+
  '\n({withBaseAnnotationFile,prepareBaseAnnotations});';
const annotation=vm.runInNewContext(annotationSource,{});
check('unqualified-new-base-declines-before-product-dependencies',()=>{
  assert.notEqual(qualified[1],metadata.base.sha256);
  assert.equal(annotation.withBaseAnnotationFile({baseSha256:metadata.base.sha256}),null);
  assert.equal(annotation.prepareBaseAnnotations(undefined,undefined,{baseSha256:metadata.base.sha256}),false);
});
for(const pin of pins)assert.equal(hash(pin.file),pin.sha256);
const report={kind:'phase66-base-host-controls',version:1,status:'pass',scope:'exact-source host-unit controls; no compiler or provider execution',upstreamRevision:metadata.upstreamRevision,pins,providerCount:35,rows};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
process.stdout.write(JSON.stringify({status:report.status,controls:rows.length,report:path.join(out,'report.json')})+'\n');
