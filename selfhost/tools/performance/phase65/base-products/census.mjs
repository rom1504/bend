// Root-supervised diagnostic. Usage: node census.mjs CONFIG.json NEW_PHASE65_OUT
// CONFIG: {image:{api,driver,runtime,base,node}, sources:[{id,file,sha256?}]}
// Each image field is {file,sha256}; root owns generation/provenance qualification.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [configArg, outArg] = process.argv.slice(2);
assert(configArg && outArg);
const root = path.resolve(import.meta.dirname, '../../../../..'), out = path.resolve(outArg);
assert(out.startsWith(path.join(root, 'selfhost/build/phase65') + path.sep) && !fs.existsSync(out));
fs.mkdirSync(out, {recursive: true});
const hash = bytes => createHash('sha256').update(bytes).digest('hex'), inputs = new Map();
function pin(file, expected) {
  const actual = fs.realpathSync(file), bytes = fs.readFileSync(actual);
  const value = {file: actual, sha256: hash(bytes), bytes: bytes.length};
  if (expected?.sha256) assert.equal(value.sha256, expected.sha256, actual);
  if (inputs.has(actual)) assert.deepEqual(value, inputs.get(actual)); inputs.set(actual, value); return value;
}
const report = {kind: 'phase65-base-backend-product-census', complete: false, pass: false,
  diagnosticOnly: true, productionQualified: false, cases: [], comparisons: []};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify({...report, inputs: [...inputs.values()]}, null, 2) + '\n');
save();
try {
  report.config = pin(configArg); pin(import.meta.filename); pin(process.execPath);
  const config = JSON.parse(fs.readFileSync(configArg, 'utf8'));
  assert(config.image && config.sources?.length && config.sources.length <= 12);
  for (const entry of config.provenance ?? []) pin(entry.file, entry);
  for (const name of ['api', 'driver', 'runtime', 'base', 'node']) {
    assert(config.image[name]?.sha256, 'Expected pinned image ' + name); pin(config.image[name].file, config.image[name]);
  }
  assert.equal(pin(process.execPath).sha256, config.image.node.sha256);
  const helper = path.join(path.dirname(config.image.driver.file), 'base-cache-graph.mjs'), helperIdentity = pin(helper);
  const original = fs.readFileSync(config.image.api.file, 'utf8');
  const parserSource = process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'], parser = {exports: {}};
  new Function('module', 'exports', parserSource)(parser, parser.exports);
  const parse = source => parser.exports.parse(source, {ecmaVersion: 'latest', sourceType: 'module'});
  const ast = parse(original), declarations = new Set(ast.body.filter(x => x.type === 'FunctionDeclaration').map(x => x.id.name));
  const symbols = {};
  const resolve = name => {
    const choices = ['$' + name + '$', '$jd$' + name.replaceAll('_', '_95_')].filter(x => declarations.has(x));
    assert.equal(choices.length, 1, 'Expected one lexical function for ' + name); symbols[name] = choices[0]; return choices[0];
  };
  const templateFile = path.join(import.meta.dirname, 'observer-template.mjs'); pin(templateFile);
  let suffix = fs.readFileSync(templateFile, 'utf8');
  const replacements = {__RESUME_WORLD__: 'base_prefix_resume_world', __KA_DEF__: 'ka_def',
    __CALL_ROW__: 'jd_calls_row_arity', __CALL_BODY__: 'jd_calls_body',
    __LAYOUT_TERM__: 'j_layout_term', __LOWERING__: 'jd_doc_definition', __BOOK_CONTEXT__: 'book_context'};
  for (const [token, name] of Object.entries(replacements)) suffix = suffix.replaceAll(token, resolve(name));
  suffix = suffix.replaceAll('__FORCE__', declarations.has('run_loop') ? 'run_loop(value)' : 'value');
  assert(!original.includes('phase65BaseProducts')); parse(original + '\n' + suffix);
  const derived = path.join(out, 'diagnostic-api.mjs'); fs.writeFileSync(derived, original + '\n' + suffix, {flag: 'wx'});
  report.derivative = {parent: config.image.api, output: pin(derived), appendOnly: true, symbols,
    suffixSha256: hash(suffix), parserSha256: hash(parserSource), trampoline: declarations.has('run_loop')};
  // A diagnostic API has another cache identity. Keep its cache writes outside
  // the already consumed measurement project, even on its preparation request.
  const originalProject = path.resolve(path.dirname(config.image.driver.file), '..');
  const project = path.join(out, 'project');
  const inventory = directory => {
    for (const item of fs.readdirSync(directory, {withFileTypes: true})) {
      const file = path.join(directory, item.name);
      if (item.isDirectory()) inventory(file);
      else { assert(item.isFile(), 'Expected regular staged project files'); pin(file); }
    }
  };
  inventory(originalProject); fs.cpSync(originalProject, project, {recursive: true, errorOnExist: true});
  const driver = path.join(project, path.relative(originalProject, config.image.driver.file));
  const runtime = path.join(project, path.relative(originalProject, config.image.runtime.file));
  report.isolatedProject = {original: originalProject, copied: project,
    driver: pin(driver, config.image.driver), runtime: pin(runtime, config.image.runtime),
    helper: pin(path.join(path.dirname(driver), 'base-cache-graph.mjs'), helperIdentity)};
  for (const key of Object.keys(process.env)) if (key.startsWith('BEND_')) delete process.env[key];
  process.env.BEND_TYPED_API = derived; process.env.BEND_TYPED_RUNTIME = runtime; process.env.BEND_BASE = config.image.base.file;
  const D = await import(pathToFileURL(driver));
  assert.equal(D.apiPath, derived); pin(D.directRuntimePath);
  const api = await D.loadApi(), mod = await import(pathToFileURL(derived)), observer = mod.phase65BaseProducts;
  assert(!mod.G, 'Named-layout images only'); assert.equal(api, mod.default, 'Keep driver-owned API identity');
  const annotation = api.annotate_selected;
  assert.equal(typeof annotation, 'function');
  api.annotate_selected = (book, defs, stops) => { observer.select(defs, stops); return annotation(book, defs, stops); };
  const layoutError = api.j_layout_error; assert.equal(typeof layoutError, 'function');
  api.j_layout_error = (book, defs, ...args) => { observer.layouts(defs); return layoutError(book, defs, ...args); };
  for (const spec of config.sources) {
    const source = pin(spec.file, spec), row = {id: spec.id, source, pass: false}; report.cases.push(row); save();
    observer.stop();
    const plain = await D.inspect(source.file, {mode: 'library', backend: 'direct'});
    assert.equal(plain.status, 'ok', plain.diagnostic); assert.equal(plain.checked, true);
    if (spec.expectedOutput) {
      pin(spec.expectedOutput.file, spec.expectedOutput);
      assert.equal(plain.code, fs.readFileSync(spec.expectedOutput.file, 'utf8'), 'Qualified module oracle changed');
    }
    observer.start(); let actual;
    try { actual = await D.inspect(source.file, {mode: 'library', backend: 'direct'}); } finally { observer.stop(); }
    assert.deepEqual(actual, plain, 'Complete driver observation changed');
    row.diagnostic = observer.finish();
    row.output = {sha256: hash(actual.code), bytes: Buffer.byteLength(actual.code)};
    for (const file of actual.files) pin(file);
    row.fullObservationEqual = row.pass = true;
    save(); console.log(JSON.stringify({id: row.id, pass: true, summaries: row.diagnostic.summaries,
      baseAnnotationsEqual: row.diagnostic.allBaseAnnotationsEqual}));
  }
  const groups = new Map();
  for (const row of report.cases) for (const event of row.diagnostic.events) if (event.ownership === 'base-exact') {
    const key = event.stage + '/' + event.name + '/' + event.input;
    const group = groups.get(key) ?? []; group.push({case: row.id, bound: event.bound, product: event.product}); groups.set(key, group);
  }
  report.comparisons = [...groups].filter(([, entries]) => new Set(entries.map(x => x.case)).size > 1)
    .map(([key, entries]) => ({key, equal: new Set(entries.map(x => x.product)).size === 1, entries}));
  for (const value of inputs.values()) pin(value.file, value);
  report.inputsUnchanged = true; report.complete = report.pass = true;
} catch (error) { report.error = {name: error.name, message: error.message, stack: error.stack}; process.exitCode = 1; }
save();
