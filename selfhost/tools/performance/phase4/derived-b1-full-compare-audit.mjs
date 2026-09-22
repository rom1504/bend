// Independent audit and durable byte archive; never starts a compiler.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {gzipSync, gunzipSync} from 'node:zlib';
import {pathToFileURL} from 'node:url';
import {identity, verifyIdentity, digest} from '../../private-compiler/common.mjs';

const ORDER = ['control', 'candidate', 'candidate', 'control'];
const SHAS = {control:'0653f21e7e227bf7bf7e3ad777630da64d520534753900636a571ed57a43f810',candidate:'e95e119847307aa215765fcbea63d3b9e4a2bba625f3d30a915f298eb6ed9821',source:'34c6ef63931e522a96a4203f8bbd8e103d3a27636cce5dd42d9ec57a8587d122',expected:'b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8'};
export function validateComparisonStructure(report) {
  assert.equal(report.kind, 'phase4-derived-b1-full-comparison');
  assert.equal(report.newBootstrap, false); assert.deepEqual(report.planned, ORDER);
  assert.equal(report.cpu, 2); assert.equal(report.timeoutMs, 900000);
  assert.equal(report.hardDeadline, '2026-09-22T20:09:00.000Z');
  assert.ok(Number.isFinite(Date.parse(report.started)) && Number.isFinite(Date.parse(report.finished)), 'Finished snapshot required; do not archive an active writer');
  assert.ok(Array.isArray(report.rows) && report.rows.length <= 4);
  for (const [index, row] of report.rows.entries()) {
    assert.equal(row.index, index); assert.equal(row.variant, ORDER[index]); assert.equal(row.repetition, Math.floor(index / 2));
    assert.equal(typeof row.passed, 'boolean');
    if (row.passed) {
      assert.equal(row.execution.status, 0); assert.equal(row.execution.signal, null); assert.equal(row.execution.timedOut, false); assert.ok(!row.execution.error && !row.error);
      assert.equal(row.inputsUnchanged, true);
      for (const number of [row.processMs, row.observation.requestMs, row.observation.maxRssKiB]) assert.ok(Number.isFinite(number) && number > 0);
      assert.equal(row.observation.apiSha256, SHAS[row.variant]);
      assert.equal(row.observation.result.status, 'ok'); assert.equal(row.observation.result.phase, 'compile'); assert.equal(row.observation.result.checked, true);
    }
  }
  if (report.complete) { assert.equal(report.rows.length, 4); assert.ok(report.rows.every(row => row.passed)); assert.equal(report.inputsUnchanged, true); assert.ok(!report.error); }
  else assert.ok(report.error || report.rows.some(row => !row.passed), 'Incomplete finished report must retain its failure');
  return {experimentComplete: report.complete === true, attempted: report.rows.length, successful: report.rows.filter(row => row.passed).length, unattempted: ORDER.slice(report.rows.length)};
}
export function auditAndArchive(directory, output) {
  const root = fs.realpathSync(directory), out = path.resolve(output);
  fs.mkdirSync(out); fs.mkdirSync(path.join(out, 'objects'));
  const audit = {kind:'phase4-derived-b1-full-comparison-independent-audit', complete:false, newBootstrap:false, started:new Date().toISOString(), errors:[], files:[], objects:[], external:[]};
  const observed = new Map(), objects = new Map();
  const capture = file => { const item=identity(file), old=observed.get(item.file); if(old)assert.deepEqual(item,old);else observed.set(item.file,item); return item; };
  const read = file => {capture(file);return JSON.parse(fs.readFileSync(file));};
  const archive = file => {
    const item=capture(file); if(audit.files.some(row=>row.file===item.file))return;
    const bytes=fs.readFileSync(item.file);assert.equal(digest(bytes),item.sha256);
    if(!objects.has(item.sha256)) {
      const compressed=gzipSync(bytes,{level:6,mtime:0}), object='objects/'+item.sha256+'.gz';
      fs.writeFileSync(path.join(out,object),compressed);
      const restored=gunzipSync(fs.readFileSync(path.join(out,object)));assert.deepEqual(restored,bytes);
      objects.set(item.sha256,{object,sha256:item.sha256,bytes:bytes.length,gzipBytes:compressed.length,gzipSha256:digest(compressed)});
    }
    audit.files.push({...item,bytes:bytes.length,object:objects.get(item.sha256).object});
  };
  const visit=dir=>{for(const e of fs.readdirSync(dir,{withFileTypes:true})){const f=path.join(dir,e.name);if(path.resolve(f)===out)continue;assert.ok(!e.isSymbolicLink(),'Archive tree symlink not allowed');if(e.isDirectory())visit(f);else if(e.isFile())archive(f);else throw Error('Nonregular archive input '+f);}};
  try {
    const reportFile=path.join(root,'report.json'); archive(reportFile); const report=read(reportFile);
    audit.observations=validateComparisonStructure(report); audit.report=capture(reportFile);
    for(const item of report.inputs){verifyIdentity(item);capture(item.file);}
    assert.equal(report.source.sha256,SHAS.source);verifyIdentity(report.source);
    assert.equal(report.expected.sha256,SHAS.expected);verifyIdentity(report.expected);
    assert.equal(report.variants.length,2);
    for(const variant of report.variants){assert.equal(variant.sha256,SHAS[variant.id]);verifyIdentity(variant);}
    const expected=fs.readFileSync(report.expected.file), fixedConfigs=[];
    for(const row of report.rows){
      if(!row.command)continue;
      assert.deepEqual(row.command.slice(0,3),['taskset','-c','2']);
      assert.deepEqual(row.command.slice(4,6),['--stack-size=4096','--max-old-space-size=12288']);
      assert.equal(row.command.length,10);
      const config=read(row.command[7]),request=read(row.command[8]);
      assert.deepEqual(request,{input:report.source.file,mode:'library'});
      assert.equal(capture(config.api).sha256,SHAS[row.variant]);
      for(const [file,before]of Object.entries(config.identities)){const actual=capture(file);assert.deepEqual({path:actual.canonicalPath,sha256:actual.sha256},before);}
      fixedConfigs.push(config);
      for(const log of row.logs??[]){verifyIdentity(log);capture(log.file);}
      if(!row.passed)continue;
      const result=read(row.command[9]);assert.deepEqual(result,row.observation);
      assert.equal(result.node.version,'v24.18.0');assert.deepEqual(result.node.args,['--stack-size=4096','--max-old-space-size=12288']);
      assert.match(result.affinity,/^Cpus_allowed_list:\s+2$/);
      verifyIdentity(row.emitted);assert.equal(row.emitted.sha256,SHAS.expected);
      assert.equal(result.emitted.file,row.emitted.file);assert.equal(result.emitted.sha256,row.emitted.sha256);
      assert.deepEqual(fs.readFileSync(capture(row.emitted.file).file),expected);
      assert.equal(result.emitted.bytes,expected.length);
      if(audit.firstResult)assert.deepEqual(result.result,audit.firstResult);else audit.firstResult=result.result;
    }
    for(const config of fixedConfigs.slice(1))for(const key of ['host','runtime','base','identities'])assert.deepEqual(config[key],fixedConfigs[0][key]);
    const cacheFiles=report.inputs.filter(item=>/\/cache\/base-.*\.json$/.test(item.file));
    assert.equal(cacheFiles.length,2); const caches=cacheFiles.map(item=>read(item.file));
    assert.deepEqual(caches[0].book,caches[1].book);
    for(const cache of caches){assert.equal(cache.version,2);assert.equal(cache.validatedBy,'check_book');assert.equal(digest(JSON.stringify(cache.book)),cache.bookSha256);assert.equal(cache.bookSha256,report.decodedBasePayloadSha256);}
    assert.deepEqual(caches.map(cache=>cache.compilerSha256).sort(),[SHAS.control,SHAS.candidate].sort());
    audit.decodedBasePayloadSha256=report.decodedBasePayloadSha256;
    audit.rows=report.rows.map(row=>({index:row.index,variant:row.variant,passed:row.passed,processMs:row.processMs,requestMs:row.observation?.requestMs,maxRssKiB:row.observation?.maxRssKiB,execution:row.execution,error:row.error}));
    audit.pairs=[];
    for(let repetition=0;repetition<2;repetition++){
      const rows=report.rows.filter(row=>row.repetition===repetition&&row.passed);
      if(rows.length!==2)continue;
      const control=rows.find(row=>row.variant==='control'),candidate=rows.find(row=>row.variant==='candidate');
      audit.pairs.push({repetition,requestReductionPercent:100*(1-candidate.observation.requestMs/control.observation.requestMs),processReductionPercent:100*(1-candidate.processMs/control.processMs)});
    }
    if(report.complete){assert.deepEqual(report.pairs,audit.pairs);assert.equal(report.materialGate,audit.pairs.every(pair=>pair.requestReductionPercent>5&&pair.processReductionPercent>5));audit.materialGate=report.materialGate;}
    visit(root);
    for(const item of report.inputs){if(item.file===process.execPath||item.canonicalPath===fs.realpathSync(process.execPath))audit.external.push({...item,reason:'Node executable identified, not embedded'});else archive(item.file);}
    archive(import.meta.filename);archive(new URL('../../private-compiler/common.mjs',import.meta.url));
    for(const item of observed.values())verifyIdentity(item);
    audit.inputsUnchanged=true;audit.complete=true;
    fs.copyFileSync(reportFile,path.join(out,'comparison.json'));
  }catch(error){audit.errors.push(error.stack);try{visit(root);}catch(archiveError){audit.errors.push(archiveError.stack);}}
  audit.objects=[...objects.values()];audit.gzipBytes=audit.objects.reduce((n,o)=>n+o.gzipBytes,0);audit.finished=new Date().toISOString();
  fs.writeFileSync(path.join(out,'audit.json'),JSON.stringify(audit,null,2)+'\n');
  fs.writeFileSync(path.join(out,'README.md'),'# Controlled B1 full-source comparison archive\n\n`audit.json` distinguishes successful archival/audit (`complete`) from the experiment completing all four observations (`observations.experimentComplete`). `comparison.json` preserves the original report. Incomplete or failed attempts remain recorded; no survivor-only performance conclusion is implied.\n\nEach `files` row maps its historical absolute path to a content-addressed gzip object. Every object was decompressed and compared with its original bytes. Node is an identified external prerequisite. Source, actual APIs/H outputs, runtime, Base caches, commands and consumed tools are preserved. Restoring bytes does not rewrite historical paths, create a new bootstrap, or make the old proof relocatable.\n');
  return audit;
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){const [input,out]=process.argv.slice(2);if(!out)throw Error('Usage: derived-b1-full-compare-audit.mjs FINISHED_COMPARISON_DIRECTORY NEW_ARCHIVE');const report=auditAndArchive(input,out);console.log(JSON.stringify({complete:report.complete,observations:report.observations,files:report.files.length,gzipBytes:report.gzipBytes,errors:report.errors}));if(!report.complete)process.exitCode=1;}
