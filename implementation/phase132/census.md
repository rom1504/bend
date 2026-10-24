# What occupies the qualified compiler's 107 MB of QBE?

Measured at repository HEAD `2227ce264dc138d524990e27ef458abbee67a384`.
The qualified Phase131 N2 product has **107,059,385 bytes**, SHA256
`f3ff63b04b58e5a5b92be781d0d1cba8cc574a37765cbf66d817c3d38f4b576e`.
Source `1bc5930e…a6728f9`, pinned Base and N2 ELF are joined through their actual
emission/build receipts in [census-audit01.json](census-audit01.json).
No compiler, runtime, production selection or generated code changed.

The central finding is that **local variable spelling occupies 57.15% of the
file**, but there is also a substantial instruction inventory. Short names
should make rendering and parsing cheaper; eliminating repeated continuations
could remove actual compiler and machine-code work. These are different claims.

## Exact inventory

The [streaming census](census01.json) counts 63,239 functions, 142,134 basic blocks,
2,294,179 instructions, 224,684 call instructions, 575 data declarations and
2,614,827 physical lines. Function text occupies 102,381,128 bytes, data 4,626,796
and interstitial whitespace 51,461. Every byte belongs to one lexical category:

| Text category | Bytes | Share |
|---|---:|---:|
| Local `%` identifiers |61,186,325|57.15%|
| Other syntax, opcodes, literals and punctuation |21,602,831|20.18%|
| Whitespace |11,537,768|10.78%|
| Global `$` identifiers |11,355,214|10.61%|
| Block `@` labels |1,377,247|1.29%|

There are 4,504,082 local-name occurrences, 337,984 global-name occurrences and
231,393 label occurrences. No quoted-string or comment bytes occur in this
particular product. The global total includes 5,761,263 bytes of exported function
names, 2,869,586 private function names, 21,484 data names and 2,702,881 unresolved
external/runtime names. Counts independently agree with the compact-symbol
scanner: 63,814 global definitions and 48,913 exported definitions.

## Actual code, wrappers and continuations

These categories are disjoint and based on exact emitted symbol namespaces and
decoded identities. "Private owned reader fallback" describes its emitted role;
it does not mean dead or removable. The [machine census](census-machine02.json)
matches all 63,239 QBE functions to nonzero ELF function sizes.

| Category | Functions | QBE bytes | QBE instructions | Machine function bytes |
|---|---:|---:|---:|---:|
| Public continuation segments |41,455|60,371,881|1,482,137|6,285,094|
| Public named segments |7,456|13,573,352|311,369|1,653,144|
| Private direct workers/adapters |1,278|15,457,018|250,905|1,106,414|
| Other private p113 workers |499|5,326,853|91,333|399,541|
| Private p112 workers |12,275|5,599,076|114,298|673,960|
| Borrowed readers |99|1,103,214|23,770|65,751|
| Owned reader fallbacks |98|413,812|7,676|30,126|
| Recursive regions |78|535,792|12,689|50,545|
| Process entry |1|130|2|22|

Public continuations contain 64.60% of QBE instructions and 61.23% of the QBE
functions' machine bytes. The huge private-worker function count is not the
largest code contribution. No simple one-block/single-private-call public
adapter matched the deliberately narrow census rule; wrappers containing more
control flow remain in their public/private categories. They are not implicitly
classified as fallbacks or redundant code.

The most common instructions are 538,259 `add`,475,978 `copy`,351,135 `storel`,
342,637 `loadl` and224,684 `call`. Static calls include 53,608 `sink`, 18,503 `keep`,
24,358 runtime `return`,23,049 `jump` and 22,233 `closure` calls. These are code-site
counts, not execution frequencies, and cannot alone rank runtime optimizations.

The actual source snapshot identifies 62,805 functions covering 98,160,741 QBE
bytes. 434 functions remain unattributed. Existing segment ownership is lexical;
known adapter prefixes additionally identify their source declarations. Neither
provides instruction-level inline provenance. Largest individual functions
include borrowed `core_nat` 171,719 bytes, direct `p111_op_id` 167,233, direct
`p88_build` 143,640 and direct `ni_template` 139,766. Grouping all lexical segments
of `ni_template` yields 2,130,828 bytes / 145 functions. Exact source files and line
numbers, top 40 functions and top 40 owners are in census01.

## Repetition is a stronger structural lead than global names alone

Erasing only each definition name finds 52 exact repeated-body groups,
128 functions and 223,602 candidate redundant text bytes. Consistently
alpha-renaming local variables/labels additionally finds 1,713 groups,
19,675 functions and 13,547,812 candidate redundant text bytes.

The largest group has 7,978 continuations occupying 4,685,006 bytes. Its example
`$p111.k.1033` (lexically `fs_root`, source line 15528) has 15 instructions: allocate
scratch, pop/read a saved slot and argument, then call `p111_rt_apply`. Constants,
types, external callee and complete instruction sequence agree; only local
identities and function names differ. This suggests investigating a shared
continuation template while keeping distinct logical FIDs where necessary.

**This is a candidate, not a demonstrated deduplication optimization.** Current
dispatch tables, exported names, address identity, fallback behavior and profiler
owner contracts require explicit treatment. Do not remove functions merely
because no direct `call` references them; the dispatch table references 48,911
segments. Alpha equality also does not establish dynamic hotness.

## Data, ELF and storage compression

Data text 4,626,796 bytes represents 930,271 initializer bytes. The dispatch table
alone is 3,076,306 text bytes for 391,288 pointer bytes. The static image is 662,783
text bytes for 367,816 data bytes. Small arity/result/flag tables each occupy about
245 KB of text for 48,911 bytes. The linked `.data` size 930,312 independently agrees
with this scale, including runtime/link additions.

The whole ELF is 17,132,048 bytes. `.text` is 10,815,649 bytes, of which exact QBE
function symbols occupy 10,264,597. Other named functions contribute 53,110 bytes;
497,942 bytes remain as alignment/unnamed text. File-backed allocated sections
total 11,769,705 bytes; zero-filled `.bss` is 1,148,424. Symbol/string tables add
5,352,650 nonallocated file bytes. Shortening symbols can therefore shrink the
ELF without making its executable instructions faster.

| Storage encoding of unchanged 107,059,385-byte QBE | Bytes |
|---|---:|
| gzip level 9 |8,123,624|
| Zstandard level 3 |7,932,667|
| Zstandard level 19 |3,931,184|

These are storage streams, not QBE inputs or compact compiler IRs. Compression
does not remove parse/codegen work once the text is expanded. Streams were
counted/hashed without retaining another artifact.

## What reduction is realistic?

The independent name experiment saves 2,680,118 bytes with private globals only,
or 7,917,956 with generated exports also renamed under a stronger boundary.
The local-name experiment subsequently removed **46,859,899 bytes** through
reversible variable/label maps. Private globals plus locals produce 57,519,368
bytes (**46.27% smaller**), preserving every export name. Renaming generated
exports too yields 52,281,530 bytes (**51.16% smaller**). The
[independent count join](census-local-join01.json) agrees on all 4,504,082 variable
occurrences, 231,393 label occurrences, 142,134 label definitions and 63,239
functions. Its pinned compact-name receipt records full original-byte recovery;
machine/runtime qualification is a separate experiment. Data text is only 4.32% of this
file, so replacing just the data format cannot explain a 100-fold reduction.

Retaining the current instruction inventory needs 2,294,179 bytes even under the
unrealistic budget of one byte per opcode and zero operands. Adding current
initializer bytes raises that illustrative budget to 3,224,450 bytes. Four bytes
per instruction line alone gives 9,176,716 bytes before headers, operands or data.
Thus **107 MB→1 MB requires eliminating or representing repeated computation**, not
merely shortening names in otherwise unchanged QBE. This is an inventory-based
budget, not an information-theoretic lower bound: sharing/compression or changing
the computation can violate its assumptions.

The highest-information next steps are to measure build cost for the now-proven
local-name text ceiling, then a small shared-continuation experiment that measures avoided preparation/emission
and validates FIDs/ABI, and deterministic unit reuse under a real source edit.
No broad IR rewrite is justified by this census alone.

## Reproduction and cost

Commands for the primary pass are in the [tool README](../../selfhost/tools/performance/phase132/census/README.md).
The full pass took 158.34 seconds on CPU1,323,512 KiB peak RSS; 52.91 seconds were
storage compression. It retained only small JSON reports, not another full IR.
Independent lineage/arithmetic verification:

```sh
taskset -c 1 python3 -B selfhost/tools/performance/phase132/census/audit.py \
  --census implementation/phase132/census01.json \
  --emission selfhost/build/phase130/p131-final-self01/report.json \
  --build selfhost/build/phase111/p131-final-native01-n2/report.json \
  --compact selfhost/build/phase132/compact-symbols01/report.json \
  --out implementation/phase132/census-audit-FRESH.json
taskset -c 1 python3 -B selfhost/tools/performance/phase132/census/machine-v02.py \
  --census implementation/phase132/census01.json \
  --out implementation/phase132/census-machine-FRESH.json
```

Machine01 also counted two zero-sized startup functions outside `.text`; machine02
restricts all function accounting to `.text` and is authoritative. Code sizes
were unchanged. Both attempts are retained. None of this is a runtime benchmark
or a new compiler qualification.
