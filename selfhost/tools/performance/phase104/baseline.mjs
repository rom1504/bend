// Independent experiment tooling, not part of the Bend compiler or public CLI.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';

const method = fileURLToPath(import.meta.url);
const root = path.resolve(path.dirname(method), '../../../..');
const absolute = p => path.resolve(root, p);
const read = p => JSON.parse(fs.readFileSync(absolute(p), 'utf8'));
export function pin(p) {
  const file = absolute(p), hash = crypto.createHash('sha256');
  const fd = fs.openSync(file, 'r'), buffer = Buffer.alloc(1024 * 1024);
  let bytes = 0, n;
  try { while ((n = fs.readSync(fd, buffer))) { hash.update(buffer.subarray(0, n)); bytes += n; } }
  finally { fs.closeSync(fd); }
  return {file, bytes, sha256: hash.digest('hex')};
}
export function verify(item) { assert.deepEqual(pin(item.file), item, `Changed: ${item.file}`); return item; }
export function decode(stderr) {
  const clocks = [...stderr.matchAll(/^request=(\d+) request_ms=(\d+) consumed_chars=(\d+)\r?$/gm)];
  assert.equal(clocks.length, 1, 'Exactly one request clock required');
  assert.equal(clocks[0][1], '1');
  return {requestMs: Number(clocks[0][2]), diagnostic: stderr.replace(
    /^(?:base_prepare_ms=\d+|runtime_prepare_ms=\d+|request=\d+ request_ms=\d+ consumed_chars=\d+)\r?\n/gm, '')};
}
const median = xs => { const a = [...xs].sort((a,b) => a-b); return (a[(a.length-1)>>1] + a[a.length>>1])/2; };

function audit() {
  const base = 'selfhost/build/phase102/native-chain04';
  const paths = ['selfhost/build/phase102/native-b1-04/b1.json', `${base}/b2.json`,
    `${base}/b1-self/report.json`, `${base}/b2-self/report.json`];
  const [b1,b2,s1,s2] = paths.map(read);
  const receipts = paths.map(pin), artifacts = new Map();
  function check(p) { verify(p); artifacts.set(p.file,p); }
  for (const b of [b1,b2]) {
    assert.equal(b.complete,true); assert.equal(b.cPatched,false);
    for (const key of ['source','binary','c','emission','guard','buildInputs','clang']) check(b[key]);
  }
  for (const s of [s1,s2]) {
    assert.equal(s.complete,true); assert.equal(s.passed,true); assert.equal(s.inputsUnchanged,true);
    assert.equal(s.row.passed,true); assert.equal(s.row.diagnosticExact,true);
    for (const p of [s.source,s.producer.build,s.producer.binary,s.row.output,s.row.diagnosticFile,...s.row.raw]) check(p);
    assert.equal(decode(fs.readFileSync(s.row.raw.find(p=>p.file.endsWith('/stderr.log')).file,'utf8')).requestMs,s.row.requestMs);
  }
  for (const s of [b1.source,b2.source,s1.source,s2.source])
    assert.equal(s.sha256,'63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237');
  assert.deepEqual(s1.producer.build,receipts[0]); assert.deepEqual(s2.producer.build,receipts[1]);
  assert.deepEqual(s1.producer.binary,b1.binary); assert.deepEqual(s2.producer.binary,b2.binary);
  assert.deepEqual(b2.emission,receipts[2]); assert.deepEqual(b2.c,s1.row.output);
  assert.equal(s2.row.output.sha256,s1.row.output.sha256);
  assert.equal(s2.row.output.bytes,s1.row.output.bytes);
  assert.equal(s2.row.diagnosticFile.sha256,s1.row.diagnosticFile.sha256);
  const build = read(b2.guard.file);
  assert.equal(build.complete,true); assert.equal(build.returncode,0);
  const bend = s2.row.requestMs / 1000, clang = build.wallSeconds, f = bend/(bend+clang);
  return {kind:'phase104-bootstrap-audit', freshCompilerExecution:false, receipts,
    verifiedArtifacts:[...artifacts.values()], source:b1.source,
    generations:[
      {generation:1,status:'historical-built-and-executed',binary:b1.binary,selfC:s1.row.output,requestSeconds:s1.row.requestMs/1000},
      {generation:2,status:'historical-built-and-executed',binary:b2.binary,selfC:s2.row.output,requestSeconds:bend},
      {generation:3,status:'C-emitted-historically; executable-not-built',buildInput:s2.row.output},
      {generation:4,status:'not-executed'}, {generation:5,status:'not-executed'}],
    emittedCFixedPoint:true, executableFixedPointMeasured:false,
    historicalBuild:{seconds:clang,peakTreeRssBytes:build.peakTreeRssBytes},
    conditionalCostModel:{bendSeconds:bend,clangSeconds:clang,bendFraction:f,
      compiler2xCycleSpeedup:1/(1-f+f/2),compilerInfiniteCycleSpeedup:1/(1-f),
      scope:'Derived from single historical observations, no agent/tests; not an experiment speed measurement.'}};
}

function screen(out, report, save) {
  const selection = pin('selfhost/tools/native/selection.json');
  const oraclePin = pin('selfhost/build/phase99/phase102-b2-screen04/report.json');
  const oracle = read(oraclePin.file);
  assert.equal(oracle.complete,true); assert.equal(oracle.passed,true);
  const cases = oracle.cases.filter(c=>['small','lexer_original'].includes(c.name));
  assert.equal(cases.length,2);
  const admission = verify(read(selection.file).admission), release = read(admission.file);
  assert.equal(release.qualified,true);
  for(const stage of ['b1','b2']) assert.deepEqual(release.stages[stage].binary,
    report.audit.generations[stage==='b1'?0:1].binary);
  const methods = ['selfhost/native.py','selfhost/tools/native/launch.py',
    'selfhost/tools/performance/phase86/guard.py','selfhost/tools/performance/programs/support.py'].map(pin);
  report.screen = {complete:false,selection,admission,oracle:oraclePin,methods,rounds:4,rows:[],
    scope:'Fresh-process cached-Base requests, two development cases; no rebuild or new correctness qualification.'};
  save();
  for(let round=0;round<4;round++) for(const c of cases) for(const stage of (round%2?['b2','b1']:['b1','b2'])) {
    const disk=fs.statfsSync(root); assert(disk.bavail*disk.bsize>512*1024**2,'Need 512 MiB disk reserve');
    verify(selection); verify(admission); methods.forEach(verify); verify(c.source); verify(c.candidateOracle);
    const output = path.join(out,`${round+1}-${c.name}-${stage}.c`);
    const argv=['-B','selfhost/native.py',c.source.file,'-o',output,'--stage',stage,'--seconds','30'];
    const started=Date.now(), t=performance.now();
    const child=spawnSync('python3',argv,{cwd:root,encoding:'utf8',maxBuffer:2*1024**2});
    const prefix=output.slice(0,-2);
    fs.writeFileSync(prefix+'.stdout',child.stdout??'',{flag:'wx'});
    fs.writeFileSync(prefix+'.stderr',child.stderr??String(child.error),{flag:'wx'});
    const record={round:round+1,case:c.name,stage,started,launcherWallMs:performance.now()-t,exit:child.status};
    report.screen.rows.push(record); save();
    assert.equal(child.status,0,`Request failed; retained ${prefix}.stderr`);
    const match=child.stderr.match(/^Request evidence: (.+)$/m); assert(match);
    const receipt=pin(path.join(match[1],'report.json')), request=read(receipt.file);
    assert.equal(request.complete,true); assert.equal(request.stage,stage);
    const text=fs.readFileSync(path.join(match[1],'guard/stderr.log'),'utf8');
    const decoded=decode(text); assert.equal(decoded.diagnostic,c.expectedDiagnostic);
    const product=pin(output); assert.equal(product.sha256,c.candidateOracle.sha256);
    Object.assign(record,{receipt,product,requestMs:decoded.requestMs,
      processMs:request.process.wallSeconds*1000,peakTreeRssBytes:request.process.peakTreeRssBytes,
      exactC:true,exactDiagnostic:true}); save();
  }
  verify(selection); verify(admission); verify(oraclePin); methods.forEach(verify);
  report.screen.summary=cases.map(c=>({case:c.name,stages:Object.fromEntries(['b1','b2'].map(stage=>{
    const rows=report.screen.rows.filter(r=>r.case===c.name&&r.stage===stage);
    return [stage,{medianRequestMs:median(rows.map(r=>r.requestMs)),medianProcessMs:median(rows.map(r=>r.processMs))}];
  }))}));
  report.screen.complete=true;
}

if (process.argv[1] && path.resolve(process.argv[1])===method) {
  const [directory,mode]=process.argv.slice(2);
  assert(directory && (!mode || mode==='--screen'),'Usage: node baseline.mjs FRESH_OUTPUT_DIR [--screen]');
  const out=absolute(directory); fs.mkdirSync(out,{recursive:false});
  const report={complete:false,started:new Date().toISOString(),method:pin(method)};
  const save=()=>{fs.writeFileSync(path.join(out,'report.tmp'),JSON.stringify(report,null,2)+'\n');fs.renameSync(path.join(out,'report.tmp'),path.join(out,'report.json'));};
  try { report.audit=audit(); save(); if(mode) screen(out,report,save); verify(report.method);
    report.audit.verifiedArtifacts.forEach(verify); report.audit.receipts.forEach(verify);
    report.complete=true;
  } catch(e) { report.error=String(e); process.exitCode=1; }
  finally {report.finished=new Date().toISOString();save();}
  console.log(JSON.stringify({complete:report.complete,error:report.error,output:path.join(out,'report.json'),screen:report.screen?.summary}));
}
