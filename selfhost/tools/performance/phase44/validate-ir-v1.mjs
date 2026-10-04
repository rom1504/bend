// Finite untimed semantics controls. Root owns compilation and bounded execution.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [baselineArg, candidateArg, typescriptArg, outputArg, mode] = process.argv.slice(2);
assert(outputArg && (!mode || mode === '--include-mixed'),
  'validate-ir-v1.mjs BASELINE_MODULE CANDIDATE_MODULE TYPESCRIPT_MODULE NEW_OUT [--include-mixed]');
const output = path.resolve(outputArg);
assert(!fs.existsSync(output), 'Output must be fresh');
fs.mkdirSync(output);
const report = {
  kind:'phase44-composable-backend-semantics', complete:false, pass:false,
  scope:'Finite authored correctness controls; no timing, prevalence or universal conformance claim.',
  mixedFeatureStage:mode ? 'included-after-freeze' : 'not-run',
  inputs:[], compilers:[], values:[], boundaries:[], higherOrder:[], mixed:[]
};
const pinned = new Map();
const json = file => JSON.parse(fs.readFileSync(file, 'utf8'));
function identity(file) {
  const canonical = fs.realpathSync(file), bytes = fs.readFileSync(canonical);
  return {path:canonical, sha256:createHash('sha256').update(bytes).digest('hex'), bytes:bytes.length};
}
function pin(file, expected) {
  const actual = identity(file);
  if (expected) {
    assert.equal(actual.sha256, expected.sha256, 'Changed input: ' + file);
    if (expected.bytes !== undefined) assert.equal(actual.bytes, expected.bytes);
  }
  if (pinned.has(actual.path)) assert.deepEqual(actual, pinned.get(actual.path));
  else {pinned.set(actual.path, actual); report.inputs.push(actual);}
  return actual;
}
const word = n => Number(BigInt.asUintN(32, BigInt(n)));
function normal(value) {
  if (typeof value === 'bigint') return {bigint:String(value)};
  if (value === undefined) return {undefined:true};
  if (typeof value === 'number' && !Number.isFinite(value)) return {number:String(value)};
  assert(value === null || ['boolean','number','string'].includes(typeof value), 'Only scalar boundary results');
  return value;
}
function snapshot(module) {
  const objects = [module.G];
  for (const descriptor of Object.values(Object.getOwnPropertyDescriptors(module.G))) {
    const f = descriptor.value;
    if (f && typeof f === 'object' && Object.hasOwn(f, 'code')) {
      objects.push(f);
      if (f.bound && typeof f.bound === 'object') objects.push(f.bound);
    }
  }
  const saved = [...new Set(objects)].map(object => [object, Object.getOwnPropertyDescriptors(object)]);
  return () => {
    for (const [object, descriptors] of saved) {
      for (const key of Reflect.ownKeys(object)) if (!Object.hasOwn(descriptors, key)) delete object[key];
      Object.defineProperties(object, descriptors);
    }
  };
}
function observe(module, action) {
  const restore = snapshot(module), events = [];
  try { return {value:normal(action(module, events)), events}; }
  catch (error) { return {error:{name:error.name, message:error.message}, events}; }
  finally { restore(); }
}
function wrap(module, name, events, action) {
  const f = module.G[name], original = f.code;
  assert.equal(typeof original, 'function', 'Expected public function: ' + name);
  f.code = function(args) {
    events.push(name);
    return action ? action(args, original, this) : Reflect.apply(original, this, [args]);
  };
}

try {
  pin(import.meta.filename);
  const catalogFile = path.join(import.meta.dirname, 'fixture-catalog-v1.json');
  pin(catalogFile);
  const catalog = json(catalogFile), source = pin(path.join(import.meta.dirname, catalog.cases[0].source.path), catalog.cases[0].source);
  const roles = ['baseline','candidate','typescript'];
  const modules = [];
  for (const [index, file] of [baselineArg,candidateArg,typescriptArg].entries()) {
    const module = pin(file), receiptFile = pin(file + '.json'), receipt = json(receiptFile.path);
    assert.equal(receipt.kind, 'bend-program-checked-emission');
    assert.equal(receipt.complete, true); assert.equal(receipt.observation.checked, true);
    assert.equal(receipt.observation.status, 'ok');
    assert.equal(receipt.output.sha256, module.sha256); assert.equal(receipt.input.sha256, source.sha256);
    assert.equal(receipt.compiler.upstreamCommit, catalog.upstreamCommit);
    pin(receipt.catalog.file ?? receipt.catalog.path, receipt.catalog);
    assert.equal(receipt.catalog.sha256, identity(catalogFile).sha256);
    if (index === 2) {
      assert.equal(receipt.compiler.kind, 'checked-pinned-typescript');
      for (const record of receipt.compiler.sources) pin(record.file ?? record.path, record);
    }
    else {
      assert(['checked-development-attempt','checked-installed-release'].includes(receipt.compiler.kind));
      for (const field of ['api','runtime','base']) {
        const record = receipt.compiler[field]; pin(record.file ?? record.path, record);
      }
      if (receipt.attempt) {
        const attemptFile = pin(receipt.attempt.file ?? receipt.attempt.path, receipt.attempt), attempt = json(attemptFile.path);
        assert.equal(attempt.checked, true);
        for (const field of ['api','runtime','base']) assert.equal(attempt[field].sha256, receipt.compiler[field].sha256);
      }
    }
    report.compilers.push({role:roles[index], module, receipt:receiptFile, compiler:receipt.compiler});
    modules.push(await import(pathToFileURL(module.path)));
  }
  for (const item of catalog.cases) {
    const {exportName, args, expected} = item.point;
    const values = modules.map(module => module.default[exportName](...args));
    for (const value of values) assert.equal(value, expected, item.id);
    report.values.push({id:item.id, exportName, args, expected, values});
  }
  // Same algebra expressed via extra helper and let binding must remain equal.
  for (const module of modules) {
    for (const [x,y] of [[1,2],[4294967295,4294967295]]) {
      assert.equal(module.default.arithmetic(x,y), module.default['arithmetic.forward'](x,y));
      assert.equal(module.default.arithmetic(x,y), module.default['arithmetic.let'](x,y));
    }
  }
  const bends = modules.slice(0,2);
  function boundary(name, action, check) {
    const observations = bends.map(module => observe(module, action));
    report.currentBoundary = {name, observations};
    assert.deepEqual(observations[1], observations[0], name);
    for (const observation of observations) {
      assert(!observation.error, 'Unexpected boundary error: ' + name);
      if (check) check(observation);
    }
    report.boundaries.push(report.currentBoundary); delete report.currentBoundary;
  }
  boundary('left-to-right-calls', (m,e) => {
    wrap(m,'observed.left',e); wrap(m,'observed.right',e); return m.default.ordered(7);
  }, o => {assert.equal(o.value,4294967292); assert.deepEqual(o.events,['observed.left','observed.right']);});
  boundary('unused-closure-does-not-run-effects', (m,e) => {
    wrap(m,'observed.left',e); wrap(m,'observed.right',e); m.default.deferred(17); return 0;
  }, o => assert.deepEqual(o.events,[]));
  boundary('deferred-closure-runs-fresh-each-call', (m,e) => {
    wrap(m,'observed.left',e); wrap(m,'observed.right',e);
    const f = m.default.deferred(17); e.push('created');
    assert.equal(m.call(f,[3]),18); return m.call(f,[5]);
  }, o => {assert.equal(o.value,12);assert.deepEqual(o.events,['created','observed.left','observed.right','observed.left','observed.right']);});
  for (const name of ['observed.left','observed.right']) {
    boundary('mutated-code:' + name, (m,e) => {
      wrap(m,name,e,() => 100); return m.default.ordered(7);
    }, o => {assert.deepEqual(o.events,[name]);assert.equal(o.value,name.endsWith('left')?79:4294967213);});
    boundary('code-accessor:' + name, (m,e) => {
      const f=m.G[name], code=f.code;
      Object.defineProperty(f,'code',{configurable:true,get(){e.push('get-code:' + name);return code;}});
      return m.default.ordered(7);
    }, o => assert(o.events.includes('get-code:' + name)));
    boundary('binding-accessor:' + name, (m,e) => {
      const f=m.G[name];
      Object.defineProperty(m.G,name,{configurable:true,get(){e.push('get-binding:' + name);return f;}});
      return m.default.ordered(7);
    }, o => assert(o.events.includes('get-binding:' + name)));
  }
  boundary('thrown-object-identity-and-order', (m,e) => {
    const token = new Error('phase44 observer sentinel');
    wrap(m,'observed.left',e,() => {throw token;}); wrap(m,'observed.right',e);
    try {m.default.ordered(7); assert.fail('Expected sentinel');}
    catch (error) {assert.equal(error,token); e.push('same-error');}
    return 0;
  }, o => assert.deepEqual(o.events,['observed.left','same-error']));
  boundary('reentrant-call-restores-outer-state', (m,e) => {
    let active=false;
    wrap(m,'observed.left',e,(args,original,self) => {
      if (!active) {active=true; e.push('nested:' + m.default.ordered(3)); active=false;}
      return Reflect.apply(original,self,[args]);
    });
    return m.default.ordered(7);
  }, o => {assert.equal(o.value,4294967292);assert.deepEqual(o.events,['observed.left','observed.left','nested:4']);});
  for (const [index,module] of bends.entries()) {
    for (const seed of [0,31,4294967295]) {
      const f = module.default.retained(seed);
      for (const input of [1,17,1]) {
        const value = module.call(f,[input]); assert.equal(value,word(BigInt(seed)-BigInt(input)));
        report.higherOrder.push({role:roles[index],kind:'retained-capture',seed,input,value});
      }
    }
    const partial = module.call(module.G.arithmetic,[9]);
    assert.equal(module.call(partial,[4]),23);
    report.higherOrder.push({role:roles[index],kind:'host-partial-call',value:23});
    for (const input of [0,17,4294967295]) {
      const value = module.default.invoke(module.G.shift,input); assert.equal(value,word(BigInt(input)+7n));
      report.higherOrder.push({role:roles[index],kind:'host-unknown-callback',input,value});
    }
  }
  if (mode) for (const args of [[0,0,1],[5,17,99],[11,4294967295,0],[23,12345,67890]]) {
    const [n,seed,salt] = args, shifted=BigInt(word(BigInt(seed)+7n));
    const expected=word(BigInt(salt)-(BigInt(n+1)*shifted+BigInt(n*(n+1)/2)));
    const values=modules.map(module=>module.default.mixed(...args));
    for(const value of values) assert.equal(value,expected,'Mixed-feature qualification');
    report.mixed.push({args,expected,values});
  }
  for (const old of pinned.values()) assert.deepEqual(identity(old.path),old,'Input changed during controls');
  report.complete=report.pass=true;
} catch (error) {report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(output,'report.json'), JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({complete:report.complete,pass:report.pass,values:report.values.length,
  boundaries:report.boundaries.length,higherOrder:report.higherOrder.length,mixed:report.mixed.length,error:report.error}));
