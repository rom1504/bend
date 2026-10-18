#!/usr/bin/env node
// Small independent controls for generated IL and its native ABI. Root runs
// QBE/assembler/linker/readback; this script only prepares bounded fixtures.
import assert from 'node:assert/strict';
import {mkdir, writeFile} from 'node:fs/promises';
import {resolve, join} from 'node:path';
import {pathToFileURL} from 'node:url';
const [apiPath, outPath] = process.argv.slice(2);
if (!apiPath || !outPath) throw new Error('Usage: emitter-controls.mjs API.mjs NEW_OUTPUT_DIRECTORY');
const api = (await import(pathToFileURL(resolve(apiPath)).href)).default;
const out = resolve(outPath);
await mkdir(out);
const list = xs => xs.reduceRight((tail, head) => ({$: 'Con', head, tail}), {$: 'Nil'});
const w = {$: 'N111U32'}, l = {$: 'N111U64'}, ptr = {$: 'N111Ptr'};
const local = name => ({$: 'N111Local', name});
const word = n => ({$: 'N111Const', lo: Number(BigInt(n) & 0xffffffffn), hi: Number(BigInt(n) >> 32n)});
const ret = value => ({$: 'N111Return', value});
const set = (name, typ, value) => ({$: 'N111Set', name, typ, value});
const arg = (typ, value) => ({$: 'N111Arg', typ, value});
const call = (name, n) => ({$: 'N111Call', name, typ: l, symbol: 'p111_test_effect', args: list([arg(ptr, local('state')), arg(l, word(n))])});
const segment = (name, stmts, incoming = 0) => ({$: 'N111Segment', name, arity: 0, result: 1, incoming, flags: 2, body: list(stmts)});
const symbol = name => 'p111_FID_' + [...name].map(c => c.codePointAt(0) + '_').join('');
// Standalone segment fixtures contain no IDs; obtain the genuine production
// index shape via p111q_ids rather than mocking KDef internals.
const program = segments => ({$: 'P111Program', segments: list(segments),
  constructors: list([
    {$: 'N_Constructor', name: 'Nil', arity: 0, hot: false},
    {$: 'N_Constructor', name: '$ctor.120_', arity: 2, hot: true},
    {$: 'N_Constructor', name: 'Γ😀', arity: 1, hot: false},
  ]), show: list([0x12345678, 0x89abcdef]), show_names: list(['Γ😀', 'a"b\\c']), effects: list(['IO.print']), pure: true});
const fixtureMain = segment('main', [ret(word(42))]);
const sourceProgram = program([fixtureMain, segment('continuation', [ret(word(99))], 1)]);
const ids = api.p111q_ids(sourceProgram);
const branch = segment('fixture_branch', [
  set('x', l, word(7)),
  {$: 'N111Load', name: 'condition', typ: w, base: local('state'), offset: 0},
  {$: 'N111Bin', name: 'test', typ: w, op: 'eq', left: local('condition'), right: word(1)},
  {$: 'N111If', condition: local('test'), yes: list([set('x', l, word(42))]), no: list([set('x', l, word(99))])},
  ret(local('x')),
]);
const bits = 0x800000000000007bn;
const memory = segment('fixture_memory', [
  {$: 'N111Alloca', name: 'scratch', bytes: 8, align: 8},
  {$: 'N111Store', typ: l, base: local('scratch'), offset: 0, value: word(bits)},
  {$: 'N111Load', name: 'a', typ: l, base: local('scratch'), offset: 0},
  {$: 'N111Offset', name: 'payload', base: local('state'), bytes: word(16)},
  {$: 'N111Store', typ: l, base: local('payload'), offset: 0, value: local('a')},
  {$: 'N111Load', name: 'b', typ: l, base: local('state'), offset: 16},
  ret(local('b')),
]);
const effects = segment('fixture_effects', [call('first', 10), call('second', 20), ret(local('second'))]);
const terminal = segment('fixture_terminal', [
  {$: 'N111Load', name: 'condition', typ: w, base: local('state'), offset: 0},
  {$: 'N111If', condition: local('condition'), yes: list([ret(word(0xffffffffffffffffn))]), no: list([ret(word(0x100000000n))])},
]);
const emitted = [branch, memory, effects, terminal].map(s => api.p111q_segment(s, ids));
for (const text of emitted) assert.doesNotMatch(text, /INVALID_N111/);
assert.doesNotMatch(emitted[0], /alloc|loadl|storel/); // Mutable scalars remain registers.
assert.equal((emitted[1].match(/alloc8/g) ?? []).length, 1);
assert.equal((emitted[2].match(/call \$p111_test_effect/g) ?? []).length, 2);
assert.doesNotMatch(emitted[3], /@b_2/); // Both branches return; no unreferenced join.
assert.match(api.p111q_segment(segment('fallthrough', [set('x', l, word(0))]), ids), /INVALID_N111_FALLTHROUGH/);
assert.match(api.p111q_segment(segment('after_return', [ret(word(0)), set('x', l, word(0))]), ids), /INVALID_N111_BODY/);
const moduleText = api.p111q_text(sourceProgram);
assert.doesNotMatch(moduleText, /INVALID_N111/);
assert.match(moduleText, /data \$p111_fid_results = align 1 \{ b 0, b 1 \}/);
assert.match(moduleText, /data \$p111_cid_names_1 = align 1 \{ b 36, b 99, b 116, b 111, b 114/); // Raw $ctor identity preserved.
assert.match(moduleText, /data \$p111_cid_names_2 = align 1 \{ b 206, b 147, b 240, b 159, b 152, b 128, b 0 \}/);
await writeFile(join(out, 'segments.ssa'), emitted.join('\n'));
await writeFile(join(out, 'program.ssa'), moduleText);
// Real-runtime fixture uses the continuation return ABI, not a fabricated
// Reply. The stack already contains the runtime's exit continuation.
const runtimeMain = segment('main', [
  {$: 'N111Alloca', name: 'scratch', bytes: 8, align: 8},
  {$: 'N111Store', typ: l, base: local('scratch'), offset: 0, value: word(42)},
  {$: 'N111Call', name: 'reply', typ: l, symbol: 'p111_rt_return', args: list([
    arg(ptr, local('state')), arg(ptr, local('scratch')), arg(w, word(1)),
  ])}, ret(local('reply')),
]);
const coreConstructors = [
  ['SNil',0],['SCon',2],['WNil',0],['WCon',2],['Nil',0],['Con',2],['Tuple',2],['Unit',0],
  ['None',0],['Some',1],['Fail',1],['Done',1],['Emit',1],['Halt',2],['True',0],['LT',0],['EQ',0],['GT',0],
].map(([name, arity]) => ({$: 'N_Constructor', name, arity, hot: arity > 0}));
const runtimeProgram = {...program([runtimeMain]), constructors: list(coreConstructors), show: list([0]), show_names: list(['U32']), effects: list([])};
await writeFile(join(out, 'pure42.ssa'), api.p111q_text(runtimeProgram));
await writeFile(join(out, 'segments-readback.c'), `#include <stdint.h>
#include <stdio.h>
typedef struct {uint32_t condition,pad;uint64_t calls,payload;} State;
${[branch, memory, effects, terminal].map(s => `extern uint64_t ${symbol(s.name)}(State*);`).join('\n')}
uint64_t p111_test_effect(State*s,uint64_t n){s->calls++;s->payload+=n;return n;}
int main(void){State s={0};
if(${symbol(branch.name)}(&s)!=99)return 1;s.condition=1;if(${symbol(branch.name)}(&s)!=42)return 2;
if(${symbol(memory.name)}(&s)!=UINT64_C(${bits})||s.payload!=UINT64_C(${bits}))return 3;
s.payload=0;if(${symbol(effects.name)}(&s)!=20||s.payload!=30||s.calls!=2)return 4;
if(${symbol(terminal.name)}(&s)!=UINT64_MAX)return 5;s.condition=0;if(${symbol(terminal.name)}(&s)!=UINT64_C(4294967296))return 6;
puts("mutable branch/memory/effect/terminal readback passed");return 0;}
`);
await writeFile(join(out, 'descriptor-readback.c'), `#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "runtime.h"
int p111_rt_main(int argc,char**argv,const P111Program*p){(void)argc;(void)argv;
if(p->abi_version!=11101||p->descriptor_bytes!=192||p->segment_count!=2||p->constructor_count!=3||p->main_fid!=0||p->main_pure!=1)return 1;
if(p->register_width!=2||p->result_width!=1||p->static_words||p->static_image||p->capabilities!=1)return 2;
if(p->fid_arity[0]||p->fid_arity[1]||p->fid_results[0]||p->fid_results[1]!=1||p->fid_flags[1]!=2)return 3;
if(p->cid_arity[1]!=2||p->cid_hot[1]!=1||strcmp(p->cid_names[1],"$ctor.120_")||strcmp(p->cid_names[2],"\\xce\\x93\\xf0\\x9f\\x98\\x80"))return 4;
if(p->show_words!=2||p->show_desc[0]!=UINT32_C(305419896)||p->show_desc[1]!=UINT32_C(2309737967)||p->show_name_count!=2)return 5;
if(strcmp(p->show_names[1],"a\\\"b\\\\c")||p->effect_count!=1||strcmp(p->effects[0],"IO.print"))return 6;
if(p->segments[0](0)!=42||p->segments[1](0)!=99)return 7;
puts("program descriptor/UTF8/relocation readback passed");return 0;}
`);
const report = {kind: 'phase111-qbe-emitter-controls', structuralChecks: 14, prepared: true, targetReadback: 'not run'};
await writeFile(join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify(report));
