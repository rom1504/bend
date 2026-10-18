#!/usr/bin/env node
// Independent BigInt oracle and object readback fixtures. This script generates
// QBE plus a C assertion harness; it does not invoke compilers or run targets.
import assert from 'node:assert/strict';
import {mkdir, writeFile} from 'node:fs/promises';
import {resolve, join} from 'node:path';
import {pathToFileURL} from 'node:url';

const [apiPath, outPath] = process.argv.slice(2);
if (!apiPath || !outPath) throw new Error('Usage: data-controls.mjs API.mjs NEW_OUTPUT_DIRECTORY');
const api = (await import(pathToFileURL(resolve(apiPath)).href)).default;
const out = resolve(outPath);
await mkdir(out); // Preserve evidence: refuse to replace an earlier run.
const list = xs => xs.reduceRight((tail, head) => ({$: 'Con', head, tail}), {$: 'Nil'});
const long = value => ({$: 'P111QLong', lo: Number(value & 0xffffffffn), hi: Number(value >> 32n)});
const data = (name, alignment, items) => api.p111q_data({$: 'P111QData', name, alignment, exported: true, items: list(items)});
const mask = (1n << 64n) - 1n;
const values = new Set([0n, 1n, mask, mask - 1n, 0x123456789abcdef0n]);
for (let n = 1n; n < 64n; n++) {
  values.add((1n << n) - 1n);
  values.add(1n << n);
  values.add((1n << n) + 1n);
}
let seed = 0x3141592653589793n;
for (let i = 0; i < 80; i++) {
  seed ^= seed << 13n; seed &= mask;
  seed ^= seed >> 7n;
  seed ^= seed << 17n; seed &= mask;
  values.add(seed);
}
const words = [...values];
for (const value of words) {
  const {lo, hi} = long(value);
  assert.equal(api.p111q_u64(lo, hi), value.toString(), `exact decimal ${value}`);
}
const mixed = data('p111_test_mixed', 8, [
  ...[0, 127, 128, 255].map(value => ({$: 'P111QByte', value})),
  {$: 'P111QWord', value: 0x89abcdef}, long(0xfedcba9876543210n), {$: 'P111QZeros', bytes: 7},
]);
assert.equal(mixed, 'export data $p111_test_mixed = align 8 { b 0, b 127, b 128, b 255, w 2309737967, l 18364758544493064720, z 7 }\n');
const reloc = data('p111_test_reloc', 8, [
  {$: 'P111QReloc', symbol: 'p111_test_mixed', offset: 0},
  {$: 'P111QReloc', symbol: 'p111_test_mixed', offset: 3},
]);
assert.equal(reloc, 'export data $p111_test_reloc = align 8 { l $p111_test_mixed, l $p111_test_mixed + 3 }\n');
await writeFile(join(out, 'data.ssa'), data('p111_test_words', 8, words.map(long)) + mixed + reloc);
await writeFile(join(out, 'readback.c'), `#include <stdint.h>
#include <stdio.h>
#include <string.h>
extern const uint64_t p111_test_words[];
extern const unsigned char p111_test_mixed[];
extern const unsigned char *const p111_test_reloc[];
static const uint64_t expected[] = {${words.map(v => `UINT64_C(${v})`).join(',')}};
int main(void) {
  for (unsigned i=0;i<sizeof(expected)/sizeof(expected[0]);i++)
    if (p111_test_words[i]!=expected[i]) return 1;
  const unsigned char bytes[]={0,127,128,255};
  if (memcmp(p111_test_mixed,bytes,4)) return 2;
  uint32_t w; uint64_t l;
  memcpy(&w,p111_test_mixed+4,4); memcpy(&l,p111_test_mixed+8,8);
  if (w!=UINT32_C(2309737967)||l!=UINT64_C(18364758544493064720)) return 3;
  for(unsigned i=16;i<23;i++) if(p111_test_mixed[i]) return 4;
  if(p111_test_reloc[0]!=p111_test_mixed||p111_test_reloc[1]!=p111_test_mixed+3) return 5;
  puts("exact64/data/relocation readback passed"); return 0;
}
`);
const report = {kind: 'phase111-qbe-data-controls', decimalCases: words.length, exactTextCases: 2, passed: true,
  targetReadback: 'prepared, not run', qbe: join(out, 'data.ssa'), harness: join(out, 'readback.c')};
await writeFile(join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify(report));
