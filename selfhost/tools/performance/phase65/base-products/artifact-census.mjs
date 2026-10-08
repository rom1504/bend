// Root-supervised, read-only compiler diagnostic. No source/driver/cache writes.
// Usage: node artifact-census.mjs CENSUS_INPUT.json NEW_PHASE65_OUT
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {performance} from 'node:perf_hooks';
import {pathToFileURL} from 'node:url';

const [configArg, outArg] = process.argv.slice(2); assert(configArg && outArg);
const root = path.resolve(import.meta.dirname, '../../../../..'), out = path.resolve(outArg);
assert(out.startsWith(path.join(root, 'selfhost/build/phase65') + path.sep) && !fs.existsSync(out));
fs.mkdirSync(out, {recursive: true});
const hash = value => createHash('sha256').update(value).digest('hex'), inputs = new Map();
const pin = (file, expected) => {
  const name = fs.realpathSync(file), bytes = fs.readFileSync(name), value = {file: name, sha256: hash(bytes), bytes: bytes.length};
  if (expected?.sha256) assert.equal(value.sha256, expected.sha256, name);
  if (inputs.has(name)) assert.deepEqual(value, inputs.get(name)); inputs.set(name, value); return value;
};
const report = {kind: 'phase65-base-annotation-artifact-census', complete: false, pass: false, diagnosticOnly: true, rows: []};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify({...report, inputs: [...inputs.values()]}, null, 2) + '\n');
const array = value => { const out = []; while (value?.$ === 'Con') { assert(out.length < 65536); out.push(value.head); value = value.tail; } assert.equal(value?.$, 'Nil'); return out; };
const list = values => values.reduceRight((tail, head) => ({$: 'Con', head, tail}), {$: 'Nil'});
const bodySize = term => {
  const todo = [term]; let count = 0;
  while (todo.length) { const t = todo.pop(); assert(++count < 1000000); if (t.kids) todo.push(...array(t.kids)); }
  return count;
};
save();
try {
  pin(import.meta.filename); pin(configArg); const config = JSON.parse(fs.readFileSync(configArg, 'utf8'));
  for (const x of [...Object.values(config.image), ...(config.provenance ?? [])]) pin(x.file, x);
  assert.equal(pin(process.execPath).sha256, config.image.node.sha256);
  const preparation = JSON.parse(fs.readFileSync(config.provenance[0].file, 'utf8'));
  assert(preparation.complete); const observations = preparation.preparations.map(x => x.observation)
    .filter(x => x.role === 'baseline' && x.image.api.sha256 === config.image.api.sha256);
  assert.equal(observations.length, 1); const observation = observations[0]; assert(observation.pass);
  const project = path.resolve(path.dirname(config.image.driver.file), '..'), cache = path.join(project, 'build/typed/cache');
  const files = fs.readdirSync(cache).filter(x => x.startsWith('base-' + config.image.api.sha256 + '-' + config.image.base.sha256) && x.endsWith('-frame4.json'));
  assert.equal(files.length, 1, 'Exactly one identity-bound frame4 Base');
  const frameFile = path.join(cache, files[0]);
  const framePin = observation.verification.cacheFiles.find(x => x.file === frameFile); assert(framePin);
  report.frame = pin(frameFile, framePin);
  const frame = fs.readFileSync(frameFile), nl = frame.indexOf(10); assert(nl > 0 && nl < 65536);
  const header = JSON.parse(frame.subarray(0, nl).toString()), payload = frame.subarray(nl + 1);
  assert.equal(header.format, 'bend-base-cache-frame-4'); assert.equal(header.compilerSha256, config.image.api.sha256);
  assert.equal(header.baseSha256, config.image.base.sha256); assert.equal(header.segments.length, 2);
  assert.equal(header.segments[0] + header.segments[1], payload.length);
  const bookBytes = payload.subarray(0, header.segments[0]), preparedBytes = payload.subarray(header.segments[0]);
  assert.equal(hash(bookBytes), header.bookGraphSha256); assert.equal(hash(preparedBytes), header.preparedGraphSha256);
  assert.equal(header.sourcePath, fs.realpathSync(config.image.base.file)); assert.equal(header.preparedWorldVersion, 3);
  assert.equal(header.preparedWorldProducer, 'base_prefix_world_prepare');
  const helperFile = path.join(path.dirname(config.image.driver.file), 'base-cache-graph.mjs');
  const helperPin = observation.copies.find(x => x.after.file === helperFile)?.after; assert(helperPin); pin(helperFile, helperPin);
  const {encodeBaseArena, decodeBaseArena} = await import(pathToFileURL(helperFile));
  const options = {range: {begin: header.sourceBegin, end: header.sourceEnd}, termAbi: header.termAbi};
  const decodedBook = decodeBaseArena(bookBytes, {...options, rootKinds: ['defs']});
  const decoded = decodeBaseArena(preparedBytes, {...options, base: decodedBook, rootKinds: ['checked', 'fresh', 'world', 'frontend']});
  const prepared = decoded.roots[2]; assert.equal(prepared.$, 'KBasePreparedWorld'); assert(prepared.state.ready);
  assert.equal(prepared.prefix, decodedBook.roots[0]); assert.equal(prepared.state, decoded.roots[0]);
  const module = await import(pathToFileURL(config.image.api.file)), api = module.default;
  assert(!module.G); for (const name of ['book_context', 'jd_stops', 'annotate_selected', 'book_cached']) assert.equal(typeof api[name], 'function', name);
  const checked = array(prepared.checked).reverse(), context = api.book_context(list(checked));
  const stops = api.jd_stops(context), stopNames = new Set(array(stops));
  const start = performance.now(), annotations = array(api.annotate_selected(context, list(checked), stops));
  report.fullBaseAnnotationMs = performance.now() - start; assert.equal(annotations.length, checked.length);
  const annotated = new Map(annotations.map(d => [d.name, d]));
  const candidates = checked.filter(d => d.kind === 'Def' && d.templates === 0 && !stopNames.has(d.name) && !['Absent', 'Foreign'].includes(d.value.tag))
    .map(d => ({name: d.name, sourceTerms: bodySize(d.value), annotation: annotated.get(d.name)}));
  const sourceRoots = [decodedBook.roots[0], ...decoded.roots], base = encodeBaseArena(sourceRoots);
  const decodedBase = decodeBaseArena(base.bytes, {...options, rootKinds: ['defs', 'checked', 'fresh', 'world', 'frontend']});
  report.base = {definitions: checked.length, candidates: candidates.length, nodes: base.records.length, bytes: base.bytes.length,
    sourceBytes: bookBytes.length + preparedBytes.length, sourceNodes: decoded.nodes.length};
  report.candidates = candidates.map(({name, sourceTerms}) => ({name, sourceTerms}));
  for (const minimumWork of [0, 32, 64, 128, 256]) {
    const selected = candidates.filter(d => d.sourceTerms >= minimumWork), defs = list(selected.map(d => d.annotation));
    // These are actual Bend-built cached lookup values, not host-built semantic facts.
    const product = api.book_cached(defs, 0), keys = list(selected.map(d => d.name));
    const encoded = encodeBaseArena([product], base), keyEncoded = encodeBaseArena([keys]);
    const file = path.join(out, 'annotations-' + minimumWork + '.arena'); fs.writeFileSync(file, encoded.bytes, {flag: 'wx'});
    const keyFile = path.join(out, 'keys-' + minimumWork + '.arena'); fs.writeFileSync(keyFile, keyEncoded.bytes, {flag: 'wx'});
    const samples = [], expectedHash = hash(encoded.bytes); let last;
    for (let i = 0; i < 3; ++i) {
      const before = performance.now(), bytes = fs.readFileSync(file); assert.equal(hash(bytes), expectedHash);
      last = decodeBaseArena(bytes, {...options, base: decodedBase, rootKinds: ['defs']});
      samples.push(performance.now() - before);
    }
    const restored = array(last.roots[0].tail); assert.equal(restored.length, selected.length);
    for (let i = 0; i < restored.length; ++i) assert.deepEqual(restored[i], selected[i].annotation);
    report.rows.push({minimumWork, definitions: selected.length, names: selected.map(d => d.name),
      artifact: pin(file), keys: pin(keyFile), incrementalNodes: encoded.records.length - base.records.length,
      reconstructionSamplesMs: samples, reconstructionMedianMs: [...samples].sort((a, b) => a - b)[1],
      exactProductEquality: true}); save();
  }
  report.scope = 'Read/hash/validate/materialize optional products with mandatory prepared graph already decoded. Three same-process diagnostic samples, not fresh whole-request speed. Full Base annotation producer measured once, outside request. Generic term-count thresholds are diagnostic policy alternatives, not benchmark-name specialization.';
  for (const p of inputs.values()) pin(p.file, p);
  report.complete = report.pass = true;
} catch (error) { report.error = {name: error.name, message: error.message, stack: error.stack}; process.exitCode = 1; }
save(); console.log(JSON.stringify({complete: report.complete, pass: report.pass, base: report.base,
  rows: report.rows.map(({minimumWork, definitions, artifact, keys, incrementalNodes, reconstructionMedianMs}) =>
    ({minimumWork, definitions, bytes: artifact.bytes, keyBytes: keys.bytes, incrementalNodes, reconstructionMedianMs})), error: report.error}));
