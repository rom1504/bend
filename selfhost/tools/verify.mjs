#!/usr/bin/env node
// Component gates use the maintained checked acquisition path. This is B1
// validation, separate from self-hosting and whole-upstream compatibility.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {spawnSync} from 'node:child_process';
import {assemble} from './assemble.mjs';
import {nodeResourceArgs} from './node-resource-args.mjs';
import {pin,verify as verifyPin} from './build/hosted.mjs';
const root=path.resolve(import.meta.dirname,'..');
const usage='Usage: node tools/verify.mjs --out FRESH_BUILD_DIRECTORY --upstream PINNED_CHECKOUT (--engine JS_ENGINE | --api-receipt CHECKED_B1_REPORT)\nRun checked B1 component gates. Use the build-retention guard for this compiler job.';
if(process.argv.includes('--help')){console.log(usage);process.exit(0);}
const options={};
for(let i=2;i<process.argv.length;i+=2){const key=process.argv[i].slice(2);if(!process.argv[i].startsWith('--')||!['out','upstream','engine','api-receipt'].includes(key)||!process.argv[i+1]||options[key])throw Error(usage);options[key]=process.argv[i+1];}
for(const key of ['out','upstream'])if(!options[key])throw Error('Missing --'+key+'\n'+usage);
if(Boolean(options.engine)===Boolean(options['api-receipt']))throw Error('Choose exactly one --engine or --api-receipt\n'+usage);
const manifest=JSON.parse(fs.readFileSync(path.join(root,'src/compiler.json'),'utf8'));
const upstream=fs.realpathSync(options.upstream),engine=options.engine?fs.realpathSync(options.engine):null,dir=path.resolve(options.out);
if(fs.existsSync(dir)||!dir.startsWith(path.join(root,'build')+path.sep))throw Error('Use a fresh output directory inside selfhost/build');
const source=path.join(dir,'compiler.bend'),authorityFile=options['api-receipt']?fs.realpathSync(options['api-receipt']):path.join(dir,'acquisition/report.json');
const results=[];
const digest=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
const captured=[...manifest.modules,'src/compiler.json','tools/build/source.py','tools/assemble.mjs','tools/build/hosted.mjs','tools/build/hosted-exports.json','tools/stage0-library.mjs','tools/verify.mjs','tools/node-resource-args.mjs'].map(file=>({file,bytes:fs.readFileSync(path.join(root,file))}));
const authorityInputs=[];let completed=false;
const cleanEnv={...process.env};for(const key of Object.keys(cleanEnv))if(key.startsWith('BEND_')||key==='NODE_OPTIONS')delete cleanEnv[key];
function run(name,args,{env={},required=false}={}) {
  for(const file of args.filter(arg=>arg.endsWith('.mjs')&&!path.isAbsolute(arg)&&fs.existsSync(path.join(root,arg))))if(!captured.some(row=>row.file===file))captured.push({file,bytes:fs.readFileSync(path.join(root,file))});
  const start=performance.now();
  const child=spawnSync(process.execPath,[...nodeResourceArgs(),...args],{cwd:root,encoding:'utf8',timeout:150000,maxBuffer:16*1024*1024,env:{...cleanEnv,...env}});
  const result={name,pass:!child.error&&child.status===0,exitCode:child.status,seconds:(performance.now()-start)/1000,stdout:child.stdout,stderr:child.stderr,error:child.error?.message};
  results.push(result);
  process.stdout.write(`${result.pass?'PASS':'FAIL'} ${name}\n`);
  if(!result.pass){process.exitCode=1;if(required)throw Error(child.error?.message||child.stderr||child.stdout||name);}
}
try{
  const revision=spawnSync('git',['-C',upstream,'rev-parse','HEAD'],{encoding:'utf8'});
  if(revision.status!==0||revision.stdout.trim()!==manifest.upstream)throw Error('BEND_UPSTREAM must point to the pinned checkout '+manifest.upstream);
  fs.mkdirSync(dir,{recursive:true});
  assemble(manifest.modules,source,{root});
  const roots=['check_book','check','infer','annotate_book','kp_show','specialize_book','specialized_book','specialized_error','strong','wnf','compare','exact_prefix','check_from_exact_prefix','reach_book','lookup','book_cached','book_context','book_put','f_source_header','f_complete_source','f_source_completed','f_load_graph','f_load_graph_seed','f_fresh_term','f_fresh_defs','check_book_diagnostic','diagnostic_render','diagnostic_result_locate','dg_render','diagnostic_locate','f_load_origins','f_load_origins_for','nc_ctor_identity','nc_ctor_display','nc_ctor_encode','nc_ctor_owned'];
  const publicExports=JSON.parse(fs.readFileSync(path.join(root,'tools/build/hosted-exports.json'),'utf8'));
  const exportsFile=path.join(dir,'component-exports.json');
  fs.writeFileSync(exportsFile,JSON.stringify({...publicExports,exports:[...new Set([...publicExports.exports,...roots])]},null,2)+'\n',{flag:'wx'});
  if(!options['api-receipt'])run('maintained checked B1 acquisition',['tools/build/hosted.mjs','acquire','--source',source,'--out',path.join(dir,'acquisition'),'--upstream',upstream,'--engine',engine,'--exports',exportsFile],{required:true});
  const authority=JSON.parse(fs.readFileSync(authorityFile,'utf8')),wantedExports=JSON.parse(fs.readFileSync(exportsFile,'utf8')).exports;
  if(authority.kind!=='bend-checked-hosted-api'||authority.complete!==true||authority.checked!==true||authority.upstream?.revision!==manifest.upstream||fs.realpathSync(authority.upstream.file)!==upstream||!authority.inputs?.length||JSON.stringify(authority.exports)!==JSON.stringify(wantedExports))throw Error('Invalid checked acquisition authority or component roots');
  const currentSource=pin(source);
  if(authority.source.sha256!==currentSource.sha256||authority.source.bytes!==currentSource.bytes||authority.imageBinding?.stage!=='B1'||authority.imageBinding?.host!=='js'||authority.imageBinding?.checked!==true||authority.imageBinding?.image?.sha256!==authority.api?.sha256||authority.imageBinding?.image?.bytes!==authority.api?.bytes||authority.imageBinding?.sourceIdentity?.sha256!==currentSource.sha256||authority.imageBinding?.sourceIdentity?.bytes!==currentSource.bytes)throw Error('Checked API differs from current assembled source or image binding');
  authorityInputs.push(pin(authorityFile),authority.api,authority.source,...authority.inputs);authorityInputs.forEach(verifyPin);
  const api=authority.api.file,env={BEND_UPSTREAM:upstream,BEND_BASE:path.join(upstream,'bend2/base.bend'),BEND_KERNEL_API:api,BEND_ANNOTATE_API:api,BEND_PRETTY_API:api,BEND_TEMPLATE_API:api,BEND_NORMALIZE_API:api,BEND_PREFIX_API:api,BEND_REACH_API:api,BEND_INDEX_API:api,BEND_FRONT_API:api,BEND_DIAGNOSTIC_API:api,BEND_NATIVE_IDENTITY_API:api};
  run('dependent checker and annotation',['tests/kernel.mjs'],{env});
  run('structured diagnostic rendering and legacy fallback',['tests/diagnostic.mjs'],{env});
  run('diagnostic source parity against pinned upstream',['tests/diagnostic-source.mjs'],{env});
  run('final-core source provenance',['tests/frontend/origins.mjs'],{env});
  run('native constructor identity and provenance',['tests/native-identity.mjs'],{env});
  run('persistent book index',['tests/index.mjs'],{env});
  run('dependency closure',['tests/reach.mjs'],{env});
  run('validated prefix reuse',['tests/prefix.mjs'],{env});
  run('contextually completed source handoff',['tests/frontend/completed-source.mjs'],{env});
  run('seeded loader equivalence',['tests/frontend/seed-cache.mjs'],{env});
  run('stack-safe binder freshening',['tests/frontend/fresh-work.mjs'],{env});
  run('stack-safe declaration freshening',['tests/frontend/fresh-book.mjs'],{env});
  // Main-only reporting was retired; full-closure verdicts are covered by CLI/conformance gates.
  run('term readback',['tests/pretty.mjs'],{env});
  run('normalization and conversion',['tests/normalize.mjs'],{env});
  run('template specialization',['tests/specialize.mjs'],{env});
  run('JavaScript primitive ABI',['src/runtime/js/test.mjs']);
  run('conformance harness and host ABI safeguards',['--test','tests/conformance/inventory.test.mjs','tests/conformance/judge.test.mjs','tests/conformance/abi.test.mjs','tests/conformance/selection.test.mjs','tests/conformance/targeted.test.mjs','tests/conformance/native-adapter.test.mjs','tests/conformance/selfhost-provenance.test.mjs','tests/conformance/bootstrap-provenance.test.mjs','tests/node-resource-args.test.mjs','tests/native-build.test.mjs']);
  completed=true;
} catch(error){process.stderr.write(error.message+'\n');process.exitCode=1}
finally{
  const changedInputs=captured.filter(({file,bytes})=>!fs.existsSync(path.join(root,file))||digest(fs.readFileSync(path.join(root,file)))!==digest(bytes)).map(({file})=>file);
  if(changedInputs.length)process.exitCode=1;
  for(const row of authorityInputs)try{verifyPin(row);}catch{changedInputs.push(row.file);process.exitCode=1;}
  const reportFile=path.join(dir,'report.json');
  fs.mkdirSync(path.dirname(reportFile),{recursive:true});
  fs.writeFileSync(reportFile,JSON.stringify({kind:'bend-component-verification',version:2,complete:completed,upstream:manifest.upstream,node:process.version,generated:new Date().toISOString(),scope:'checked B1 component verification, not whole-language conformance or self-hosting',pass:completed&&process.exitCode!==1,acquisition:authorityFile,reusedCheckedAcquisition:Boolean(options['api-receipt']),authorityInputs,changedInputs,inputs:captured.map(({file,bytes})=>({file,sha256:digest(bytes)})),results},null,2)+'\n',{flag:'wx'});
}
