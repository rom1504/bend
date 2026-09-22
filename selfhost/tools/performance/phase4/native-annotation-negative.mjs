// Invalid inputs must leave through the unchanged sequential preparation gate.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {pathToFileURL} from 'node:url';
const [configFile, outArg] = process.argv.slice(2);
if (!outArg) throw Error('Usage: native-annotation-negative.mjs CONFIG NEW_DIRECTORY');
const cfg = JSON.parse(fs.readFileSync(configFile)), out = path.resolve(outArg); fs.mkdirSync(out, {recursive:false});
const sha = f => crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const oracle = JSON.parse(fs.readFileSync(cfg.oracleReport)); assert.equal(oracle.complete, true);
const worker = path.join(path.dirname(cfg.oracleReport), 'workers.cjs'); assert.equal(sha(worker), oracle.identity[worker]);
const api = createRequire(import.meta.url)(worker), {spawnFileCapture} = await import(pathToFileURL(cfg.captureTool));
const build = JSON.parse(fs.readFileSync(cfg.binary + '.build.json')); assert.equal(build.complete, true); assert.equal(sha(cfg.binary), build.binarySha256);
const files = [import.meta.filename, configFile, cfg.binary, cfg.binary + '.build.json', cfg.oracleReport, worker, cfg.captureTool, cfg.base, ...cfg.fixtures.map(f => f.file)];
const identity = Object.fromEntries(files.map(f => [f, sha(f)])), report = {kind:'native-annotation-negative-controls',complete:false,identity,rows:[]};
const save = () => fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n'); save();
try {
  for (const fixture of cfg.fixtures) {
    assert.match(fixture.id, /^[A-Za-z0-9_-]+$/);
    const prepared = api.ap_prepare(fs.realpathSync(fixture.file), fs.realpathSync(cfg.base), fs.readFileSync(fixture.file,'utf8'), fs.readFileSync(cfg.base,'utf8'));
    assert.ok(prepared.error, 'Fixture must be rejected before annotation');
    const diagnostics = [];
    for (const variant of [{mode:'serial',threads:1},{mode:'fork2',threads:2}]) {
      const output = path.join(out,fixture.id+'-'+variant.mode+'.tree'), start=performance.now();
      const result=await spawnFileCapture('taskset',['-c','3',cfg.binary,'--threads',String(variant.threads),fs.realpathSync(fixture.file),fs.realpathSync(cfg.base),output,variant.mode],{timeout:60000,maxBuffer:1024*1024});
      const row={fixture:fixture.id,variant,wallMs:performance.now()-start,status:result.status,signal:result.signal,error:result.error?.message,stdout:result.stdout,stderr:result.stderr,expectedError:prepared.error};report.rows.push(row);save();
      assert.ok(!result.error);assert.equal(result.status,1);assert.equal(result.signal,null);assert.equal(fs.existsSync(output),false);assert.ok(!result.stderr.includes('annotation_consume_ms='));
      const diagnostic=(result.stdout+result.stderr).replace(/^prepare_ms=\d+\n/gm,'');assert.ok(diagnostic.includes(prepared.error));diagnostics.push(diagnostic);row.rejectedBeforeAnnotation=true;
    }
    assert.equal(diagnostics[0],diagnostics[1]); save();
  }
  report.changedInputs=Object.entries(identity).filter(([f,h])=>sha(f)!==h).map(([f])=>f);assert.deepEqual(report.changedInputs,[]);report.complete=true;
} catch(error){report.error=error.stack;process.exitCode=1;}finally{save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));}
