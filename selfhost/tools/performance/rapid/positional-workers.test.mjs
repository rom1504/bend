import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {transformPositionalWorkers} from './positional-workers.mjs';
const runtimeText = fs.readFileSync(new URL('../../../dist/phase1/runtime.mjs', import.meta.url), 'utf8');
const runtime = runtimeText.slice(runtimeText.indexOf('const G='), runtimeText.indexOf('function ctor('));
const definitions = `
const events=[];
G["add"]=fn(2,function(a){const x=a[0];const y=a[1];return x+y;});
G["target"]=fn(1,function(a){const x=a[0];return x+1;});
G["early"]=call(get(G,"target"),[2]);
G["entry"]=fn(1,function(a){const x=a[0];return call(get(G,"target"),[(events.push("arg"),x),]);});
G["nested"]=fn(1,function(a){return call(get(G,"add"),[call(get(G,"target"),[a[0]]),2,]);});
G["partial"]=fn(1,function(a){return call(get(G,"add"),[a[0]]);});
G["over"]=fn(1,function(a){return call(get(G,"target"),[a[0],4]);});
G["owned"]=fn(1,function(a){a.push(99);return a.length;});
G["owns"]=fn(1,function(a){return call(get(G,"owned"),[a[0]]);});
G["tail"]=fn(1,function(a){return a[0]===0?0:jump(get(G,"tail"),[a[0]-1]);});
G["capture"]=fn(1,function(a){return call(get(G,"target"),[(G["target"]=fn(1,function(a){return 100+a[0]}),a[0])]);});
G["mutateCode"]=fn(1,function(a){return call(get(G,"target"),[(G["target"].code=function(a){return a[0]*3},a[0])]);});
G["mutateArity"]=fn(1,function(a){return call(get(G,"target"),[(G["target"].arity=2,a[0])]);});
G["closure"]=fn(1,function(a){const x=a[0];return fn(1,function(a){return x+a[0]});});
G["closureEntry"]=fn(1,function(a){return call(call(get(G,"closure"),[a[0]]),[4]);});
G["env"]=fn(1,function(a){return this.offset+a[0];});
G["explicitEnv"]=fn(1,function(a){return a[0];},{});
G["arrayEscape"]=fn(1,function(a){return a;});
G["literal"]=fn(1,function(a){return 'call(get(G,"target"),[1])';});
`;
function load(original = false) {
  const source = runtime + definitions; const transformed = transformPositionalWorkers(source);
  return {...vm.runInNewContext((original ? source : transformed.source) + '\n({G,fn,call,get,events})'), stats: transformed.stats, transformed: transformed.source};
}
test('exact/nested calls, closure scopes and eager initialization', () => {
  const x = load(); assert.equal(x.G.early, 3); assert.equal(x.call(x.G.nested, [5]), 8);
  assert.equal(x.call(x.G.closureEntry, [5]), 9); assert.equal(x.call(x.G.literal, [0]), 'call(get(G,"target"),[1])');
  assert(x.stats.workers > 0); assert(x.stats.calls > 0);
  assert(!Object.hasOwn(x.stats.byName, 'owned')); assert(!Object.hasOwn(x.stats.byName, 'env'));
});
test('live global replacement, fn0 effects, and failure ordering', () => {
  const x = load(); x.G.target = x.fn(0, () => { x.events.push('init'); return x.fn(1, a => a[0] * 2); });
  assert.equal(x.call(x.G.entry, [3]), 6); assert.equal(JSON.stringify(x.events), '["init","arg"]');
  x.events.length = 0; x.G.target = x.fn(0, () => { throw Error('init failed'); });
  assert.throws(() => x.call(x.G.entry, [3]), /init failed/); assert.equal(x.events.length, 0);
});
test('callee captured before argument effect, mutable code and arity guarded', () => {
  let x = load(); assert.equal(x.call(x.G.capture, [7]), 8); assert.equal(x.call(x.G.target, [7]), 107);
  x = load(); assert.equal(x.call(x.G.mutateCode, [7]), 21);
  x = load(); const partial = x.call(x.G.mutateArity, [7]); assert.equal(partial.arity, 2); assert.equal(x.call(partial, [9]), 8);
});
test('partial application, oversaturation, bound functions and environments', () => {
  const x = load(); assert.equal(x.call(x.call(x.G.partial, [3]), [4]), 7);
  x.G.target = x.fn(1, a => x.fn(1, b => a[0] * b[0])); assert.equal(x.call(x.G.over, [3]), 12);
  x.G.target = x.fn(2, function(a) { return this.offset + a[0] + a[1]; }, {offset: 10}, [5]);
  assert.equal(x.call(x.G.entry, [3]), 18);
  x.G.target = x.fn(1, function(a) { return this.offset + a[0]; }, {offset: 10});
  assert.equal(x.call(x.G.entry, [3]), 13);
});
test('original object environment mutation is guarded', () => {
  const x = load(); x.G.target.env = {offset: 10};
  assert.equal(x.call(x.G.entry, [3]), 4);
});
test('argument ownership fallback and stack-safe tail calls', () => {
  const x = load(), control = load(true), args = [7];
  assert.equal(x.call(x.G.owns, args), control.call(control.G.owns, args)); assert.deepEqual(args, [7]);
  assert.equal(x.call(x.G.tail, [50000]), 0);
});
test('factory environments and observable argument arrays keep original ABI', () => {
  const x = load(); assert(x.stats.skippedDefinitions >= 4);
  const args = [7], result = x.call(x.G.arrayEscape, args);
  assert.notEqual(result, args); assert.equal(JSON.stringify(result), '[7]');
  assert.equal(x.call(x.G.explicitEnv, [8]), 8);
});
