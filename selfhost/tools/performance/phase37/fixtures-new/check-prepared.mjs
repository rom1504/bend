// No timing/profile APIs: root executes this finite correctness workload under
// the shared resource supervisor. Holdout observations are correctness only.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [baselineArg, typescriptArg, proposalArg, catalogArg, outArg] = process.argv.slice(2);
assert(baselineArg && typescriptArg && proposalArg && catalogArg && outArg && process.argv.length === 7,
  'Usage: check-prepared.mjs PHASE36_MANIFEST TYPESCRIPT_MANIFEST POINTS_V1 CATALOG NEW_OUT');
const out = path.resolve(outArg);
assert(!fs.existsSync(out), 'Output must be new');
fs.mkdirSync(out, {recursive:false});
fs.copyFileSync(import.meta.filename, path.join(out, 'consumed-check-prepared.mjs'));
const report = {
  kind:'phase37-prepared-application-correctness', schemaVersion:1, complete:false, pass:false,
  node:process.version, scope:'One untimed execution per compiler per point. Holdout performance is not measured.',
  expected:{applicationFamilies:8, applicationPoints:16, catalogPoints:45, smallPoints:32, compilerRoles:2, observations:154},
  inputs:[], modules:[], observations:[], errors:[]
};
const tracked = new Map();
const read = file => JSON.parse(fs.readFileSync(file, 'utf8'));
const persist = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
function identity(file) {
  const canonical = fs.realpathSync(file), stat = fs.statSync(canonical);
  assert(stat.isFile(), 'Identity target must be a regular file');
  const hash = createHash('sha256'), fd = fs.openSync(canonical, 'r'), buffer = Buffer.alloc(1024 * 1024);
  try { for (;;) { const length = fs.readSync(fd, buffer, 0, buffer.length, null); if (!length) break; hash.update(buffer.subarray(0, length)); } }
  finally { fs.closeSync(fd); }
  return {path:canonical, sha256:hash.digest('hex'), bytes:stat.size};
}
function verify(file, expected) {
  const actual = identity(file);
  if (expected) {
    assert.equal(actual.sha256, expected.sha256, 'Changed identity: ' + actual.path);
    if ('bytes' in expected) assert.equal(actual.bytes, expected.bytes, 'Changed byte count: ' + actual.path);
    if (expected.canonicalPath) assert.equal(actual.path, expected.canonicalPath, 'Changed canonical path');
  }
  if (tracked.has(actual.path)) assert.deepEqual(actual, tracked.get(actual.path), 'Input changed during verification');
  else { tracked.set(actual.path, actual); report.inputs.push(actual); }
  return actual;
}
function target(root, row) {
  assert(row && typeof row.sha256 === 'string');
  const name = row.file ?? row.path;
  assert.equal(typeof name, 'string');
  return path.resolve(root, name);
}
function relative(root, row) {
  assert(row && typeof row.path === 'string' && !path.isAbsolute(row.path));
  assert(!row.path.split(/[\\/]/).includes('..'), 'Relative identity must remain inside bundle');
  const file = target(root, row), canonical = fs.realpathSync(file);
  assert(canonical.startsWith(fs.realpathSync(root) + path.sep), 'Bundle link escapes bundle');
  verify(file, row); return canonical;
}
function verifyPointer(row, root = '.') {
  return verify(target(root, row), row);
}
function observationValue(value) {
  if (typeof value === 'number') return Number.isFinite(value) ? value : {nonfinite:String(value)};
  if (typeof value === 'string' || typeof value === 'boolean' || value === null) return value;
  if (typeof value === 'bigint') return {bigint:String(value)};
  if (value === undefined) return {undefined:true};
  return {unexpectedType:typeof value};
}
function compilerIdentity(compiler) {
  assert.equal(compiler.upstreamCommit, '018751270e800bc222a93dad7f257083ee53a5f7');
  if (compiler.kind === 'checked-pinned-typescript') {
    assert.equal(compiler.sources.length, 3); compiler.sources.forEach(row => verifyPointer(row));
  } else {
    assert.equal(compiler.kind, 'checked-development-attempt');
    assert.equal(compiler.api.sha256, '93e55ad7ee456eebb5fa3dd9606c2cf262ea386c6f66bfd891ffe187d8f50a75',
      'This worker compares the frozen Phase36 compiler with pinned TypeScript');
    for (const key of ['api','runtime','base','driver']) verifyPointer(compiler[key]);
  }
}
function acquire(manifestArg, label, proposal, selectedCatalogFile, selectedCatalog) {
  const manifestFile = verify(manifestArg).path, root = path.dirname(manifestFile), manifest = read(manifestFile);
  assert.equal(manifest.kind, 'bend-program-bundle'); assert.equal(manifest.complete, true);
  assert.equal(manifest.upstreamCommit, proposal.upstreamCommit);
  const roles = Object.keys(manifest.roles); assert.equal(roles.length, 1);
  const role = roles[0], compiler = manifest.roles[role].compiler;
  assert.equal(role === 'typescript', label === 'typescript'); compilerIdentity(compiler);
  const prepFile = relative(root, manifest.preparation), prep = read(prepFile);
  assert.equal(prep.kind, 'bend-program-preparation'); assert.equal(prep.complete, true);
  verifyPointer(prep.producer); verifyPointer(prep.worker); verifyPointer(prep.supervisor);
  verifyPointer(prep.node); prep.verifiers.forEach(row => verifyPointer(row));
  const catalogFile = verifyPointer(prep.catalog).path, catalog = read(catalogFile);
  assert.equal(catalogFile, selectedCatalogFile);
  assert.deepEqual(catalog, selectedCatalog);
  assert.equal(manifest.catalogSha256, prep.catalog.sha256);
  assert.equal(catalog.upstreamCommit, proposal.upstreamCommit);
  const result = new Map();
  for (const selected of selectedCatalog.cases) {
    const rows = manifest.cases.filter(row => row.id === selected.id); assert.equal(rows.length, 1, 'Missing/duplicate prepared point: ' + selected.id);
    const item = rows[0]; assert.equal(item.sourceSha256, selected.source.sha256);
    assert.deepEqual(item.point, selected.point, 'Changed selected point: ' + selected.id);
    const catalogRows = catalog.cases.filter(row => row.id === selected.id); assert.equal(catalogRows.length, 1);
    const cat = catalogRows[0]; assert.deepEqual(cat.point, selected.point);
    assert.equal(cat.source.sha256, selected.source.sha256); assert.equal(cat.source.bytes, selected.source.bytes);
    const sourceFile = relative(path.dirname(catalogFile), cat.source);
    const preparations = prep.sources.filter(row => row.source.sha256 === selected.source.sha256);
    assert.equal(preparations.length, 1, 'Source must have exactly one checked emission');
    const acquired = preparations[0]; assert.equal(acquired.process.complete, true); assert.equal(acquired.process.returncode, 0);
    assert.equal(verifyPointer(acquired.source).path, sourceFile);
    const emissionFile = relative(root, acquired.emission), emission = read(emissionFile);
    assert.equal(emission.kind, 'bend-program-checked-emission'); assert.equal(emission.complete, true);
    assert.equal(emission.observation.status, 'ok'); assert.equal(emission.observation.checked, true);
    if (label === 'typescript') assert.equal(emission.observation.mode, 'library');
    else { assert.equal(emission.observation.phase, 'compile'); assert.equal(emission.observation.exitCode, 0); }
    assert.deepEqual(emission.compiler, compiler); assert.equal(verifyPointer(emission.input).path, sourceFile);
    assert.equal(emission.input.sha256, selected.source.sha256);
    assert.equal(verifyPointer(emission.catalog).path, catalogFile);
    assert.equal(emission.catalog.sha256, manifest.catalogSha256);
    assert.equal(verifyPointer(emission.producer).sha256, prep.worker.sha256);
    assert.deepEqual(emission.verifiers.map(row => verifyPointer(row).sha256), prep.verifiers.map(row => row.sha256));
    if (label !== 'typescript') {
      const attempt = read(verifyPointer(emission.attempt).path);
      assert.equal(attempt.kind, 'bend-development-attempt'); assert.equal(attempt.checked, true);
      for (const key of ['api','runtime','base']) assert.equal(attempt[key].sha256, compiler[key].sha256);
    }
    const moduleFile = relative(root, item.modules[role]);
    const rawFile = verifyPointer(emission.output).path;
    if (selected.adapter) {
      assert.equal(selected.adapter, 'generic-row');
      const adapters = prep.adapters.filter(row => row.adapted.sha256 === item.modules[role].sha256);
      assert.equal(adapters.length, 1); const adapter = adapters[0];
      assert.equal(adapter.kind, 'complete-generic-row-serialization');
      assert.equal(relative(root, adapter.raw), rawFile);
      assert.equal(relative(root, adapter.adapted), moduleFile);
      assert.equal(verifyPointer(adapter.producer).sha256, prep.producer.sha256);
    } else {
      assert.equal(rawFile, moduleFile); assert.equal(emission.output.sha256, item.modules[role].sha256);
    }
    const row = {label, role, id:selected.id, family:selected.family ?? selected.source.path, file:moduleFile,
      source:verify(sourceFile), module:verify(moduleFile), emission:verify(emissionFile), compiler};
    result.set(selected.id, row); report.modules.push(row);
  }
  assert.equal(result.size, selectedCatalog.cases.length); return result;
}

persist();
try {
  verify(import.meta.filename);
  const proposalFile = verify(proposalArg).path, proposal = read(proposalFile);
  assert.equal(proposal.kind, 'phase37-application-point-proposal');
  assert.equal(proposal.cases.length, 16); assert.equal(proposal.validationPoints.length, 32);
  verify(path.join(import.meta.dirname, 'oracles.py'), proposal.oracle);
  const catalogFile = verify(catalogArg).path, catalog = read(catalogFile);
  assert.equal(catalog.kind, 'bend-program-catalog'); assert.equal(catalog.cases.length, 45);
  assert.equal(new Set(catalog.cases.map(row => row.id)).size, 45);
  for (const row of proposal.cases) {
    const matches = catalog.cases.filter(item => item.id === row.id); assert.equal(matches.length, 1);
    assert.deepEqual(matches[0].point, row.point); assert.equal(matches[0].source.sha256, row.source.sha256);
  }
  const selected = catalog.cases.map(row => ({id:row.id, moduleCase:row.id,
    family:row.family ?? row.source.path, partition:row.partition ?? 'historical-or-variation',
    selection:'catalog-point', ...row.point}));
  const families = new Map(proposal.cases.map(row => [row.family, row])); assert.equal(families.size, 8);
  for (const [family] of families) {
    assert.equal(proposal.cases.filter(row => row.family === family).length, 2);
    assert.equal(proposal.validationPoints.filter(row => row.family === family).length, 4);
  }
  const small = proposal.validationPoints.map((row, index) => ({id:'small-' + index, moduleCase:families.get(row.family).id, ...row,
    partition:families.get(row.family).partition, selection:'small-validation'}));
  for (const row of [...small, ...selected]) {
    assert.equal(typeof row.exportName, 'string');
    assert(Array.isArray(row.args) && row.args.length <= 2);
    assert(row.args.every(value => Number.isInteger(value) && value >= 0 && value <= 4294967295));
    assert(['number','string'].includes(typeof row.expected));
    for (const label of ['phase36','typescript']) report.observations.push({...row, label, status:'pending'});
  }
  assert.equal(report.observations.length, 154); persist();
  const owners = {phase36:acquire(baselineArg, 'phase36', proposal, catalogFile, catalog),
    typescript:acquire(typescriptArg, 'typescript', proposal, catalogFile, catalog)};
  const loaded = new Map();
  for (const row of report.observations) {
    const module = owners[row.label].get(row.moduleCase); row.moduleSha256 = module.module.sha256;
    try {
      if (!loaded.has(module.file)) {
        try { loaded.set(module.file, {value:await import(pathToFileURL(module.file))}); }
        catch (error) { loaded.set(module.file, {error}); }
      }
      const imported = loaded.get(module.file); if (imported.error) throw imported.error;
      const entry = imported.value.default?.[row.exportName]; assert.equal(typeof entry, 'function');
      const actual = entry(...row.args); row.actual = observationValue(actual);
      assert.deepEqual(actual, row.expected); row.status = 'pass';
    } catch (error) {
      row.status = 'fail'; row.error = error.stack ?? String(error);
    }
    persist();
    console.log(JSON.stringify({id:row.id, family:row.family, role:row.label, status:row.status}));
  }
  for (const expected of tracked.values()) assert.deepEqual(identity(expected.path), expected, 'Input changed during correctness execution');
  report.complete = true; report.pass = report.observations.every(row => row.status === 'pass');
} catch (error) {
  const message = error.stack ?? String(error); report.errors.push(message);
  for (const row of report.observations) if (row.status === 'pending') { row.status = 'not-run'; row.error = message; }
}
report.counts = Object.fromEntries(['pass','fail','not-run','pending'].map(status =>
  [status, report.observations.filter(row => row.status === status).length]));
persist();
if (!report.complete || !report.pass) process.exitCode = 1;
console.log(JSON.stringify({complete:report.complete, pass:report.pass, counts:report.counts, errors:report.errors}));
