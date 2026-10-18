// Exact schema decoder extracted from pipeline-audit.mjs; historical harness unchanged.
import assert from 'node:assert/strict';
const list = xs => xs.reduceRight((tail, head) => ({$: 'Con', head, tail}), {$: 'Nil'});
const typ = t => { const tag = {u32: 'NxU32', u64: 'NxU64', ptr: 'NxPtr', invalid: 'NxBad'}[t]; assert(tag, 'unknown type'); return {$: tag}; };
const param = p => ({$: 'NxParam', name: p.name, typ: typ(p.type)});
function expr(e) {
  switch (e.kind) {
    case 'const': return {$: 'NxConst', typ: typ(e.type), value: e.value};
    case 'var': return {$: 'NxVar', name: e.name};
    case 'bin': return {$: 'NxBin', op: e.op, left: expr(e.lhs), right: expr(e.rhs)};
    case 'call': return {$: 'NxCall', name: e.name, args: list(e.args.map(expr))};
    case 'alloc': return {$: 'NxAlloc', bytes: expr(e.bytes)};
    case 'load': return {$: 'NxLoad', typ: typ(e.type), ptr: expr(e.ptr), offset: e.offset};
    case 'ptradd': return {$: 'NxOffset', ptr: expr(e.ptr), bytes: expr(e.bytes)};
    case 'func': return {$: 'NxFunc', name: e.name};
    case 'icall': return {$: 'NxICall', callee: expr(e.callee), args: list(e.args.map(expr)), params: list(e.params.map(typ)), result: typ(e.result)};
    default: throw Error('unknown expression ' + e.kind);
  }
}
function stmt(s) {
  switch (s.kind) {
    case 'set': return {$: 'NxSet', name: s.name, value: expr(s.value)};
    case 'return': return {$: 'NxReturn', value: expr(s.value)};
    case 'if': return {$: 'NxIf', condition: expr(s.cond), yes: list(s.then.map(stmt)), no: list(s.else.map(stmt))};
    case 'while': return {$: 'NxWhile', condition: expr(s.cond), body: list(s.body.map(stmt))};
    case 'store': return {$: 'NxStore', typ: typ(s.type), ptr: expr(s.ptr), offset: s.offset, value: expr(s.value)};
    case 'free': return {$: 'NxFree', ptr: expr(s.ptr)};
    default: throw Error('unknown statement ' + s.kind);
  }
}
export function decodeNxProgram(p) {
  assert.equal(p.version, 1);
  return {$: 'NxProgram', entry: p.entry, functions: list(p.functions.map(f => ({$: 'NxFunction', name: f.name,
    params: list(f.params.map(param)), result: typ(f.result), locals: list(f.locals.map(param)), body: list(f.body.map(stmt))})))};
}
