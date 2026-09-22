// Fresh pinned TypeScript full-source comparison, with genuine Phase 4 provenance.
// The checked B1 root classifier is exposed by a disposable export adapter only.
import fs from 'node:fs';
import path from 'node:path';
import {spawn} from 'node:child_process';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import assert from 'node:assert/strict';

const sha = file => createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const digest = value => createHash('sha256').update(JSON.stringify(value)).digest('hex');
const read = file => JSON.parse(fs.readFileSync(file, 'utf8'));
const save = (file, value) => fs.writeFileSync(file, JSON.stringify(value, null, 2) + '\n');
const identity = file => ({file: path.resolve(file), canonicalPath: fs.realpathSync(file), sha256: sha(file)});
const verify = record => assert.deepEqual(identity(record.file), record, 'Input changed: ' + record.file);
const filesBelow = dir => fs.readdirSync(dir, {withFileTypes: true}).flatMap(e => e.isDirectory() ? filesBelow(path.join(dir, e.name)) : [path.join(dir, e.name)]);

async function captured(command, args, prefix, timeoutMs, env = process.env) {
  const stdoutFile = prefix + '.stdout', stderrFile = prefix + '.stderr';
  const a = fs.openSync(stdoutFile, 'wx'), b = fs.openSync(stderrFile, 'wx');
  const start = performance.now();
  let outcome;
  try {
    outcome = await new Promise(resolve => {
      let timedOut = false, spawnError;
      const child = spawn(command, args, {env, detached: true, stdio: ['ignore', a, b]});
      const timer = setTimeout(() => {
        timedOut = true;
        try { process.kill(-child.pid, 'SIGKILL'); } catch { child.kill('SIGKILL'); }
      }, timeoutMs);
      child.once('error', error => { spawnError = error.message; });
      child.once('close', (status, signal) => { clearTimeout(timer); resolve({status, signal, timedOut, spawnError}); });
    });
  } finally { fs.closeSync(a); fs.closeSync(b); }
  const text = file => { assert.ok(fs.statSync(file).size <= 2 ** 20, 'Output limit: ' + file); return fs.readFileSync(file, 'utf8'); };
  return {command, args, ...outcome, wallMs: performance.now() - start, stdoutFile, stderrFile, stdout: text(stdoutFile), stderr: text(stderrFile), stdoutSha256: sha(stdoutFile), stderrSha256: sha(stderrFile)};
}
const passed = result => result.status === 0 && !result.signal && !result.timedOut && !result.spawnError;

if (process.argv[2] === '--worker') {
  const request = read(process.argv[3]);
  const B = await import(pathToFileURL(path.join(request.snapshot, 'bend.ts')));
  const C = await import(pathToFileURL(path.join(request.snapshot, 'comp.ts')));
  assert.equal(B.BASE_BEND, request.base, 'Canonical Base differs');
  const report = {base: B.BASE_BEND, checked: false, complete: false, phases: {}, roots: []};
  let phase = 'load';
  const timed = async (name, fn) => { phase = name; const start = performance.now(); try { return await fn(); } finally { report.phases[name] = performance.now() - start; } };
  const start = performance.now();
  try {
    const book = B.book_nil();
    await timed('load', () => B.book_load(book, request.input, '', new Map()));
    await timed('check-and-owned', () => { B.book_valid(book); C.book_owned(book, C.SYNTH); assert.equal(book.hols + book.open, 0, 'Unresolved holes/laws'); report.checked = true; });
    // Same policy as actual Bend j_library_roots; not the limited B1 API exports.
    report.roots = [...new Set(book.order)].filter(k => { const d = book.tlds[k]; return d.$ === 'Def' && d.x === 0 && (d.v !== null || d.i !== undefined) && (!d.b || d.i !== undefined); });
    report.baseForeignRoots = report.roots.filter(k => book.tlds[k].b);
    const code = await timed('emit', () => C.js_lib(book, report.roots, report.roots));
    report.outputBytes = Buffer.byteLength(code);
    report.compileMs = performance.now() - start;
    // Full metadata consumed by both actual Bend classifiers, outside timing.
    report.rootMetadata = [...new Set(book.order)].map(name => { const d = book.tlds[name]; return {name, kind: d.$, templates: d.x ?? 0, base: !!d.b, valueTag: d.i !== undefined ? 'Foreign' : d.v === null ? 'Absent' : 'Present'}; });
    fs.writeFileSync(request.output, code); report.outputSha256 = sha(request.output); report.complete = true;
  } catch (error) { report.error = error?.$ === 'Err' ? B.err_show(error) : error?.stack || String(error); report.failedPhase = phase; report.compileMs = performance.now() - start; process.exitCode = 1; }
  save(request.result, report);
} else if (process.argv[2] === '--verify-h') {
  const [measurementFile, proofFile, outputArgument] = process.argv.slice(3);
  if (!outputArgument) throw Error('usage: final-fullsource-typescript.mjs --verify-h MEASUREMENT.json PROOF.json NEW_DIRECTORY');
  const out = path.resolve(outputArgument); fs.mkdirSync(out, {recursive: false});
  const report = {kind: 'phase4-final-typescript-h-root-verification', complete: false, started: new Date().toISOString(), inputs: []};
  const capture = file => { const record = identity(file); report.inputs.push(record); return record.file; };
  try {
    const measurement = read(capture(measurementFile)); assert.equal(measurement.complete, true);
    for (const record of measurement.inputs) verify(record);
    const proofSnapshot = path.join(out, 'self-emission-proof.json'); fs.copyFileSync(proofFile, proofSnapshot);
    const proof = read(capture(proofSnapshot));
    assert.equal(proof.sourceSha256, measurement.source.sha256); assert.equal(fs.realpathSync(proof.source), measurement.source.canonicalPath);
    assert.equal(proof.base.sha256, measurement.base.sha256); assert.equal(proof.base.canonicalPath, measurement.base.canonicalPath);
    assert.equal(proof.initialCompiler.sha256, measurement.classifier.original.sha256);
    for (const record of [proof.sourceIdentity, proof.base, proof.initialCompiler, proof.driver, ...proof.hostHelpers]) { verify(record); capture(record.file); }
    const stage = proof.stages.find(row => path.basename(row.output) === 'stage2.mjs');
    assert.ok(stage && stage.code === 0 && stage.inputsVerified, 'No verified checked stage2 output yet');
    const hFile = capture(stage.output); assert.equal(sha(hFile), stage.outputSha256);
    report.selfEmission = {proofOriginal: path.resolve(proofFile), proofSnapshot, proofComplete: proof.complete, stage2Sha256: stage.outputSha256, stage};
    const H = await import(pathToFileURL(hFile));
    assert.equal(typeof H.default.j_library_roots, 'function');
    report.rows = [];
    for (const row of measurement.rows) {
      const sample = read(capture(row.resultFile));
      const nil = H.list([]), atom = tag => H.ctor('KTerm', [tag, '', 0, 0, nil, nil]);
      const defs = sample.rootMetadata.map(d => H.ctor('KDef', [d.name, d.kind, 0, d.templates, atom('Type'), atom(d.valueTag), nil, d.base, false]));
      let list = H.default.j_library_roots(H.list(defs)); const roots = [];
      while (list.$ === 'Con') { roots.push(list.a[0]); list = list.a[1]; }
      assert.equal(list.$, 'Nil'); assert.deepEqual(roots, sample.roots);
      for (const root of roots) assert.ok(Object.hasOwn(H.default, root), 'Selected root absent from H: ' + root);
      report.rows.push({repetition: row.repetition, metadataSha256: digest(sample.rootMetadata), rootsSha256: digest(roots), roots: roots.length, exactOrderedRoots: true, rootsPresentInH: true});
    }
    for (const record of report.inputs) verify(record);
    report.inputsUnchanged = true; report.complete = true;
    report.scope = 'Actual checked self-emitted stage2 classifier on retained checked TypeScript metadata. proofComplete records whether stage3 fixed-point completion was available; verification completion alone is not a fixed-point claim.';
  } catch (error) { report.error = error.stack || String(error); process.exitCode = 1; }
  report.finished = new Date().toISOString(); save(path.join(out, 'report.json'), report); console.log(JSON.stringify({complete: report.complete, selfEmission: report.selfEmission, error: report.error}));
} else {
  const [configArgument, outputArgument] = process.argv.slice(2);
  if (!outputArgument) throw Error('usage: final-fullsource-typescript.mjs CONFIG.json NEW_DIRECTORY');
  const configFile = fs.realpathSync(configArgument), config = read(configFile), resolve = file => fs.realpathSync(path.resolve(path.dirname(configFile), file));
  const out = path.resolve(outputArgument); fs.mkdirSync(out, {recursive: false});
  const report = {kind: 'phase4-final-pinned-typescript-full-source-library', complete: false, started: new Date().toISOString(), inputs: [], rows: []};
  const inputMap = new Map(), capture = file => { const record = identity(file); inputMap.set(record.file, record); return record.file; };
  const flush = () => save(path.join(out, 'report.json'), {...report, inputs: [...inputMap.values()]});
  const ensure = () => { for (const record of inputMap.values()) verify(record); };
  try {
    capture(import.meta.filename); capture(configFile); capture(process.execPath);
    const tool = path.join(out, 'consumed-tool.mjs'); fs.copyFileSync(import.meta.filename, tool); capture(tool);
    const launchFile = capture(resolve(config.launch)), launch = read(launchFile), checkedFile = capture(launch.checked), checked = read(checkedFile);
    assert.equal(checked.kind, 'phase4-checked-overlay'); assert.equal(checked.complete, true); assert.equal(checked.inputsUnchanged, true); assert.equal(checked.requestedRootsExist, true);
    for (const name of ['source', 'api']) { verify(checked[name]); assert.deepEqual(launch[name], checked[name]); capture(checked[name].file); }
    for (const record of checked.inputs) { verify(record); capture(record.file); }
    for (const module of checked.modules) { assert.equal(sha(module.destination), module.sha256); capture(module.destination); }
    assert.ok(checked.phases.some(p => p.name === 'check-owned-and-closed'));
    for (const item of launch.hostFiles) { assert.equal(sha(item.path), item.sha256); capture(item.path); }
    capture(launch.base); capture(launch.runtime);
    report.source = identity(checked.source.file); report.base = identity(launch.base); report.runtime = identity(launch.runtime); report.launch = identity(launchFile); report.checked = identity(checkedFile);
    const cpu = config.cpu, repetitions = config.repetitions ?? 3, timeoutMs = config.timeoutMs ?? 180000;
    assert.ok(Number.isInteger(cpu) && cpu >= 0 && Number.isInteger(repetitions) && repetitions >= 1 && repetitions <= 3 && Number.isInteger(timeoutMs) && timeoutMs > 0);
    report.cpu = cpu; report.repetitions = repetitions; report.timeoutMs = timeoutMs;
    report.node = {path: process.execPath, version: process.version, args: ['--stack-size=4096', '--max-old-space-size=12288']};
    report.stackLimits = fs.readFileSync('/proc/self/limits', 'utf8').split('\n').find(line => line.startsWith('Max stack size'));
    const upstream = fs.realpathSync(checked.upstream.path); let serial = 0;
    const git = async args => { const result = await captured('git', ['-C', upstream, ...args], path.join(out, 'git-' + serial++), 30000); assert.ok(passed(result), JSON.stringify(result)); return result.stdout.trim(); };
    assert.equal(await git(['rev-parse', 'HEAD']), checked.upstream.pin); assert.equal(await git(['status', '--porcelain', '--untracked-files=no']), '');
    report.upstream = {path: upstream, pin: checked.upstream.pin, trackedClean: true};
    const snapshot = path.join(out, 'upstream'); fs.mkdirSync(snapshot);
    for (const name of ['bend.ts', 'comp.ts']) { const source = capture(path.join(upstream, 'bend2', name)), dest = path.join(snapshot, name); fs.copyFileSync(source, dest); capture(dest); assert.equal(sha(source), sha(dest)); }
    fs.symlinkSync(report.base.canonicalPath, path.join(snapshot, 'base.bend')); fs.symlinkSync(path.join(path.dirname(report.base.canonicalPath), 'effs'), path.join(snapshot, 'effs'));
    for (const file of filesBelow(path.join(path.dirname(report.base.canonicalPath), 'effs'))) capture(file);
    const original = checked.api.file, classifier = path.join(out, 'b1-classifier.mjs');
    const source = fs.readFileSync(original, 'utf8'); assert.equal((source.match(/function \$j_library_roots\$\(/g) ?? []).length, 1);
    const adapter = '\nexport function phase4LibraryRoots(defs){return run_loop($j_library_roots$(defs));}\n';
    fs.writeFileSync(classifier, source + adapter); capture(classifier);
    report.classifier = {original: identity(original), adapted: identity(classifier), adapter, policy: 'Exact checked B1 worker, exposed by export only; no worker changes. Limited B1 default export list is not the library root set.'};
    const classifierModule = await import(pathToFileURL(classifier));
    const classify = metadata => {
      const nil = {$: 'Nil'}, atom = tag => ({$: 'KTerm', tag, name: '', id: 0, quant: 0, kids: nil, removed: nil});
      let defs = nil;
      for (const d of [...metadata].reverse()) defs = {$: 'Con', head: {$: 'KDef', name: d.name, kind: d.kind, arity: 0, templates: d.templates, typ: atom('Type'), value: atom(d.valueTag), ctors: nil, native: d.base, unsafe: false}, tail: defs};
      let list = classifierModule.phase4LibraryRoots(defs); const roots = [];
      while (list.$ === 'Con') { roots.push(list.head); list = list.tail; }
      assert.equal(list.$, 'Nil'); return roots;
    };
    const env = {...process.env}; delete env.NODE_OPTIONS; delete env.BEND_TYPED_TRACE;
    report.childEnvironmentPolicy = 'Inherited environment with NODE_OPTIONS and BEND_TYPED_TRACE removed.';
    report.scope = 'Three fresh processes, canonical source/Base, fully checked/owned/closed library compilation by unchanged pinned TypeScript modules copied to a private directory. No persistent Base cache. Root projection/classifier verification, output writing/hash, syntax and execution gates are outside compileMs; processWallMs includes worker startup, imports and transport. Same-source comparison on CPU0, not interleaved or same-core paired with H proof on CPU2. Other physical cores may be active.';
    flush(); let outputHash;
    for (let repetition = 0; repetition < repetitions; repetition++) {
      ensure();
      const request = {snapshot, input: report.source.canonicalPath, base: report.base.canonicalPath, output: path.join(out, `library-${repetition}.mjs`), result: path.join(out, `sample-${repetition}.json`)};
      const requestFile = path.join(out, `request-${repetition}.json`); save(requestFile, request); capture(requestFile);
      console.error('[Phase4 pinned TS] sample ' + repetition);
      const child = await captured('taskset', ['-c', String(cpu), process.execPath, ...report.node.args, tool, '--worker', requestFile], path.join(out, `sample-${repetition}-worker`), timeoutMs, env);
      const row = {repetition, processWallMs: child.wallMs, process: child, requestFile, resultFile: request.result, passed: false}; report.rows.push(row);
      if (fs.existsSync(request.result)) { capture(request.result); row.compilation = read(request.result); }
      flush(); assert.ok(passed(child) && row.compilation?.complete, 'Worker failed: ' + JSON.stringify(row));
      const roots = classify(row.compilation.rootMetadata); assert.deepEqual(roots, row.compilation.roots);
      row.rootComparison = {classifier: 'checked-B1', exactOrderedRoots: true, roots: roots.length, rootsSha256: digest(roots), metadataSha256: digest(row.compilation.rootMetadata)};
      if (outputHash === undefined) outputHash = row.compilation.outputSha256;
      assert.equal(row.compilation.outputSha256, outputHash); capture(request.output);
      const syntax = await captured('taskset', ['-c', String(cpu), process.execPath, '--check', request.output], path.join(out, `sample-${repetition}-syntax`), timeoutMs, env);
      row.syntax = syntax; assert.ok(passed(syntax), 'Syntax failed');
      const oracle = `const api=(await import(${JSON.stringify(pathToFileURL(request.output).href)})).default;const roots=${JSON.stringify(roots)};if(JSON.stringify(Object.keys(api))!==JSON.stringify(roots))throw Error('Exports differ');if(api.f_ascii_ident_code(65)!==true||api.f_ascii_ident_code(128512)!==false)throw Error('ASCII helper differs');console.log(JSON.stringify({exports:roots.length,asciiOracle:true}));`;
      const oracleFile = path.join(out, `sample-${repetition}-oracle.mjs`); fs.writeFileSync(oracleFile, oracle); capture(oracleFile);
      row.execution = await captured('taskset', ['-c', String(cpu), process.execPath, ...report.node.args, oracleFile], path.join(out, `sample-${repetition}-execution`), timeoutMs, env);
      assert.ok(passed(row.execution), 'Output execution failed'); row.passed = true; flush();
    }
    ensure(); assert.equal(await git(['rev-parse', 'HEAD']), checked.upstream.pin); assert.equal(await git(['status', '--porcelain', '--untracked-files=no']), '');
    report.inputsUnchanged = true; report.trackedStillClean = true; report.complete = true;
  } catch (error) { report.error = error.stack || String(error); process.exitCode = 1; }
  report.finished = new Date().toISOString(); flush(); console.log(JSON.stringify({report: path.join(out, 'report.json'), complete: report.complete, rows: report.rows.map(row => ({passed: row.passed, processWallMs: row.processWallMs, compileMs: row.compilation?.compileMs})), error: report.error}));
}
