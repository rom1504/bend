#!/usr/bin/env node
// A derived default has release lineage, never a checked-bootstrap sidecar.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {verifyAttempt,runDevelopment,identity,digest} from './workflow.mjs';
import {verifyEqualityDerivation,transformEquality} from './equality.mjs';

const project=path.resolve(import.meta.dirname,'../..');
const dist=path.join(project,'dist');
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const relative=file=>path.relative(project,file).split(path.sep).join('/');
function local(name){
 assert.ok(typeof name==='string'&&!path.isAbsolute(name)&&!name.split('/').includes('..'),'Invalid release-relative path');
 return path.join(project,name);
}
const record=file=>({path:relative(file),sha256:identity(file).sha256,bytes:fs.statSync(file).size});
function check(item){const file=local(item.path);assert.equal(identity(file).sha256,item.sha256,'Changed release input: '+item.path);assert.equal(fs.statSync(file).size,item.bytes);return file;}
const hostNames=['typed-driver','compiler-abi','native-build','node-resource-args','assemble'];

export function verifyRelease(){
 const manifest=read(path.join(dist,'release.json'));
 assert.equal(manifest.kind,'bend-default-equality-release');assert.equal(manifest.version,1);assert.equal(manifest.newBootstrap,false);
 assert.equal(fs.existsSync(path.join(dist,'typed-api.mjs.bootstrap.json')),false,'A derivative must not have a bootstrap sidecar');
 assert.equal(fs.existsSync(path.join(dist,'typed-bootstrap-report.json')),false,'Stale default bootstrap report');
 for(const item of [...manifest.files,...manifest.checkout])check(item);
 const files=Object.fromEntries(manifest.files.map(x=>[x.path,x]));
 const api=files['dist/typed-api.mjs'],parent=files['dist/release-lineage/checked-api.mjs'];assert.ok(api&&parent);
 const bootstrap=read(path.join(dist,'release-lineage/checked-bootstrap.json'));
 const derivation=read(path.join(dist,'release-lineage/derivation.json'));
 assert.equal(bootstrap.stage,'upstream-bootstrap');assert.equal(bootstrap.provenance.verifiedAfterBuild,true);assert.equal(bootstrap.apiSha256,parent.sha256);
 assert.equal(derivation.kind,'bend-derived-b1-equality');assert.equal(derivation.complete,true);assert.equal(derivation.newBootstrap,false);
 assert.equal(derivation.original.api.sha256,parent.sha256);assert.equal(derivation.output.sha256,api.sha256);
 assert.equal(derivation.original.bootstrapReport.sha256,files['dist/release-lineage/checked-bootstrap.json'].sha256);
 assert.equal(derivation.toolSnapshot.sha256,files['dist/release-lineage/equality.mjs'].sha256);
 assert.equal(bootstrap.sourceSha256,manifest.sourceSha256);assert.equal(bootstrap.baseSha256,files['dist/base.bend'].sha256);
 const replay=transformEquality(fs.readFileSync(check(parent),'utf8'));
 assert.equal(digest(replay.source),api.sha256);assert.deepEqual(replay.stats,derivation.transform);
 assert.equal(manifest.checkout.find(x=>x.path==='src/runtime.mjs')?.sha256,manifest.runtimeSha256);
 return manifest;
}

export async function installAttempt(directory,derivationFile){
 directory=fs.realpathSync(directory);
 const attempt=await verifyAttempt(directory);
 const derived=verifyEqualityDerivation(derivationFile??attempt.derivationReport?.file);
 assert.equal(derived.metadata.original.api.sha256,attempt.checkedApi.sha256);
 assert.equal(derived.metadata.original.bootstrapReport.sha256,attempt.bootstrapReport.sha256);
 const bootstrap=read(attempt.bootstrapReport.file),checkout=[];
 // Prove the default source/host actually corresponds to this frozen attempt.
 for(const module of bootstrap.modules){
  const file=path.join(project,'src',module.file.replace(/^src\//,''));
  assert.equal(identity(file).sha256,module.sha256,'Current source differs: '+module.file);checkout.push(record(file));
 }
 for(const name of hostNames){const file=path.join(project,'tools',name+'.mjs');assert.equal(identity(file).sha256,identity(path.join(attempt.snapshot.root,'tools',name+'.mjs')).sha256);checkout.push(record(file));}
 for(const name of ['src/compiler.json','src/runtime.mjs']){const file=path.join(project,name);assert.equal(identity(file).sha256,identity(path.join(attempt.snapshot.root,name)).sha256);checkout.push(record(file));}
 const walk=directory=>fs.readdirSync(directory,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(directory,e.name)):[path.join(directory,e.name)]);
 for(const file of walk(path.join(project,'src/runtime/native'))){assert.equal(identity(file).sha256,identity(path.join(attempt.snapshot.root,relative(file))).sha256);checkout.push(record(file));}
 checkout.push(record(path.join(project,'cli.mjs')));
 const stage=fs.mkdtempSync(path.join(dist,'.release-'));
 try {
  const lineage=path.join(stage,'release-lineage');fs.mkdirSync(lineage);
  for(const [source,target] of [[derived.api,'typed-api.mjs'],[attempt.base.file,'base.bend'],[attempt.checkedApi.file,'release-lineage/checked-api.mjs'],[attempt.bootstrapReport.file,'release-lineage/checked-bootstrap.json'],[derived.report,'release-lineage/derivation.json'],[derived.metadata.toolSnapshot.file,'release-lineage/equality.mjs']])fs.copyFileSync(source,path.join(stage,target));
  await verifyAttempt(directory);verifyEqualityDerivation(derived.report);
  // Preserve the previous default and its authentic sidecars as history.
  const previous=[];
  for(const name of ['typed-api.mjs','typed-api.mjs.bootstrap.json','typed-bootstrap-report.json'])if(fs.existsSync(path.join(dist,name)))previous.push({name,...identity(path.join(dist,name))});
  if(previous.length&&previous[0].sha256!==derived.metadata.output.sha256){const history=path.join(dist,'release-history',previous[0].sha256);fs.mkdirSync(history,{recursive:true});for(const item of previous){const target=path.join(history,item.name);if(fs.existsSync(target))assert.equal(identity(target).sha256,item.sha256);else fs.copyFileSync(item.file,target);}}
  fs.mkdirSync(path.join(dist,'release-lineage'),{recursive:true});
  const names=['typed-api.mjs','base.bend','release-lineage/checked-api.mjs','release-lineage/checked-bootstrap.json','release-lineage/derivation.json','release-lineage/equality.mjs'];
  for(const name of names)fs.renameSync(path.join(stage,name),path.join(dist,name));
  for(const name of ['typed-api.mjs.bootstrap.json','typed-bootstrap-report.json'])fs.rmSync(path.join(dist,name),{force:true});
  const manifest={kind:'bend-default-equality-release',version:1,newBootstrap:false,installed:new Date().toISOString(),
   artifact:'equality-derived-b1',sourceSha256:bootstrap.sourceSha256,runtimeSha256:attempt.runtime.sha256,
   files:names.map(name=>record(path.join(dist,name))),checkout,
   lineage:{checkedParentSha256:attempt.checkedApi.sha256,derivationSha256:identity(derived.report).sha256,upstreamRevision:bootstrap.revision},
   provenanceScope:'Original checked bootstrap and derivation reports are preserved byte-for-byte with historical paths. Local verification checks relative installed/checkout identities and exact transformation replay; it does not create or relocate bootstrap provenance.',
   validationScope:'Installation verifies genuine checked-parent lineage and exact derivation. Release build additionally requires maintained focused validation; broad/self-host evidence is recorded separately.'};
  fs.writeFileSync(path.join(stage,'release.json'),JSON.stringify(manifest,null,2)+'\n');fs.renameSync(path.join(stage,'release.json'),path.join(dist,'release.json'));
  return verifyRelease();
 }finally{fs.rmSync(stage,{recursive:true,force:true});}
}

export async function buildRelease(configFile,output){
 output=path.resolve(output??path.join(project,'build/releases',new Date().toISOString().replace(/[:.]/g,'-')));
 fs.mkdirSync(path.dirname(output),{recursive:true});
 const config=configFile?read(fs.realpathSync(configFile)):{};
 // Resolve user configuration before writing the durable effective configuration.
 for(const name of ['project','upstream','selection'])if(config[name])config[name]=path.resolve(path.dirname(path.resolve(configFile)),config[name]);
 config.project=project;config.profile='equality';
 const effective=output+'.release-config.json';fs.writeFileSync(effective,JSON.stringify(config,null,2)+'\n',{flag:'wx'});
 const result=await runDevelopment(effective,output);
 assert.equal(result.build?.complete,true,'Checked release build failed');assert.equal(result.validation?.complete,true,'Focused release validation incomplete');assert.equal(result.validation?.pass,true,'Focused release validation failed');
 return installAttempt(output);
}

if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){
 try{
  const [mode,...args]=process.argv.slice(2);let result;
  if(mode==='--verify'&&!args.length)result=verifyRelease();
  else if(mode==='--install-attempt'&&(args.length===1||args.length===2))result=await installAttempt(...args);
  else if(mode==='--build'&&(args.length===0||args.length===2))result=await buildRelease(...args);
  else throw Error('Usage: release.mjs --build [CONFIG NEW_ATTEMPT] | --install-attempt ATTEMPT [DERIVATION] | --verify');
  console.log(JSON.stringify({complete:true,artifact:result.artifact,api:result.files.find(x=>x.path==='dist/typed-api.mjs'),sourceSha256:result.sourceSha256,newBootstrap:false}));
 }catch(error){console.error(error.stack??error);process.exitCode=1;}
}
