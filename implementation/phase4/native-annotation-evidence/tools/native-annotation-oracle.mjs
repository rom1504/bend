// Exact JS-tree oracle for the checked native probe, using the original B1 API.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {pathToFileURL} from 'node:url';
const [configFile, outArg] = process.argv.slice(2);
if (!outArg) throw Error('Usage: native-annotation-oracle.mjs CONFIG NEW_DIRECTORY');
const cfg = JSON.parse(fs.readFileSync(configFile)), out = path.resolve(outArg);
fs.mkdirSync(out, {recursive: false});
const sha = f => crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const reportFile = path.join(cfg.build, 'native-build-report.json'), checked = JSON.parse(fs.readFileSync(reportFile));
assert.equal(checked.complete, true); assert.equal(checked.upstreamTrackedFilesClean, true);
assert.equal(sha(checked.javascript.file), checked.javascript.sha256); assert.equal(sha(checked.source), checked.sourceSha256);
const b1check = JSON.parse(fs.readFileSync(cfg.checkedB1)); assert.equal(b1check.complete, true); assert.equal(b1check.inputsUnchanged, true); assert.equal(sha(b1check.api.file), b1check.api.sha256);
const source = fs.readFileSync(checked.javascript.file, 'utf8'), entry = 'cli(process.argv.slice(2));\nio_exit($main$, null);';
assert.equal(source.split(entry).length, 2);
const names = [...source.matchAll(/^function \$(ap_[A-Za-z_0-9]+)\$\(/gm)].map(m => m[1]);
for (const name of ['ap_prepare', 'ap_dispatch', 'ap_defs', 'ap_hash_defs']) assert.ok(names.includes(name), name);
const worker = path.join(out, 'workers.cjs');
fs.writeFileSync(worker, source.replace(entry, 'module.exports={' + names.map(n => JSON.stringify(n) + ':run_lib($' + n + '$,$' + n + '$.length)').join(',') + '};'));
const candidate = createRequire(import.meta.url)(worker), baseline = (await import(pathToFileURL(b1check.api.file))).default;
const inputs = [import.meta.filename, configFile, reportFile, cfg.checkedB1, b1check.api.file, checked.source, checked.javascript.file, worker, cfg.base, ...cfg.fixtures.map(x => x.file)];
const identity = Object.fromEntries(inputs.map(f => [f, sha(f)]));
const report = {kind: 'phase4-native-annotation-js-oracle', complete: false, started: new Date().toISOString(), config: cfg, identity, rows: [], scope: 'Exact complete KDef/KTerm output equality between frozen B1 annotate_selected and checked wrapper serial/fork JS workers; native binary gate is separate.'};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n'); save();
const nil = {$: 'Nil'}, array = xs => { const a = []; while (xs.$ === 'Con') {a.push(xs.head); xs = xs.tail;} assert.equal(xs.$, 'Nil'); return a; }, list = xs => xs.reduceRight((tail, head) => ({$: 'Con', head, tail}), nil);
try {
  for (const fixture of cfg.fixtures) {
    console.log('ORACLE ' + fixture.id);
    const start = performance.now(), prepared = candidate.ap_prepare(fs.realpathSync(fixture.file), fs.realpathSync(cfg.base), fs.readFileSync(fixture.file, 'utf8'), fs.readFileSync(cfg.base, 'utf8'));
    assert.equal(prepared.$, 'ApPrepared'); assert.equal(prepared.error, '', fixture.id + ': ' + prepared.error);
    const preparedJson = JSON.stringify(prepared), definitions = array(prepared.selected), scenarios = [{id: 'normal', selected: prepared.selected, stops: prepared.stops}];
    if (fixture.boundaries) {
      scenarios.push({id: 'empty', selected: nil, stops: prepared.stops});
      if (definitions.length) {
        scenarios.push({id: 'duplicate-selection', selected: list([definitions[0], definitions[0], ...definitions.slice(1, 3)]), stops: prepared.stops});
        scenarios.push({id: 'stop-all', selected: prepared.selected, stops: list(definitions.map(d => d.name))});
        scenarios.push({id: 'reverse-subset', selected: list(definitions.slice(0, 5).reverse()), stops: prepared.stops});
      }
    }
    for (const scenario of scenarios) {
      const expected = baseline.annotate_selected(prepared.context, scenario.selected, scenario.stops);
      const structuralDigest = candidate.ap_hash_defs(expected, 2166136261);
      const encoded = candidate.ap_defs(expected), expectedFile = path.join(out, fixture.id + '-' + scenario.id + '.expected');
      fs.writeFileSync(expectedFile, encoded);
      for (const mode of ['serial', 'fork2', 'fork4']) {
        const actual = candidate.ap_dispatch(mode, prepared.context, scenario.selected, scenario.stops);
        assert.deepEqual(actual, expected, fixture.id + '/' + scenario.id + '/' + mode);
        assert.equal(candidate.ap_defs(actual), encoded);
        report.rows.push({fixture: fixture.id, scenario: scenario.id, mode, definitions: array(scenario.selected).length, exactTree: true, structuralDigest, expectedFile, sha256: sha(expectedFile)});
      }
      save();
    }
    assert.equal(JSON.stringify(prepared), preparedJson, 'Input mutation');
    report.rows.push({fixture: fixture.id, preparationAndOracleMs: performance.now() - start}); save();
  }
  report.changedInputs = Object.entries(identity).filter(([f, h]) => sha(f) !== h).map(([f]) => f); assert.deepEqual(report.changedInputs, []); report.complete = true;
} catch (error) {report.error = error.stack; process.exitCode = 1;}
finally {report.finished = new Date().toISOString(); save(); console.log(JSON.stringify({complete: report.complete, error: report.error, rows: report.rows.length}));}
