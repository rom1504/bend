# Phase192 incremental pass economics audit

The selected compiler is already frozen. Retain that selection for its current
full evaluation; this audit makes no source changes and does not tune against
held-out results. Predicate normalization has a substantial real lexer witness.
Shared-address selection also changes real code. The later selected local-fold
output confirms that the sixteen-row bound removes a multiply and copy from
its repeated loop; tree/expression/lexer private workers are unchanged by the
bound increase. Neither pass has an isolated runtime or compiler-throughput
measurement. Credit the measured FP/H capability changes
separately; do not describe the bundled result as measured wins for each pass.

Before selection froze, my complexity-first recommendation was to preserve the
small predicate slice provisionally and defer shared-address selection pending
ablation. With the frozen selection now underway and the additional local-fold machine
witness available, the practical recommendation is to retain the correct sources,
record the missing causal evidence, and make shared-address off/on the first
future simplification experiment if compiler cost or maintenance complexity
warrants it. No new optimization should be
introduced to rescue either pass during the held-out evaluation.

## Source and evidence identity

`selfhost/build/phase192/selected-source01/compiler.bend` is 1,803,092 bytes,
SHA-256 `301435947ae813b64eebaf30610d2be4aa3be5b7ddd772bd0e68f1b6aac48c20`.
It exactly equals the prior virtual maintained-H integration recorded in
`selfhost/tests/phase192/recursive-maintained-closure.json`. That receipt
establishes the canonical H planner/closure/rename/symbol dependency closure
from the unchanged `main` root and byte identity of all five non-x86 profiles
before/after H integration. It is source transport evidence, not target proof.

The machine comparison uses Phase191 selected objects at
`selfhost/build/phase191/native45-02/CASE/machine/program.o`, Phase192
`dev-emit01/CASE/program.o`, and diagnostic assembly under the corresponding
emission directory. `dev-emit01/report.json` binds checked API source05 and its
artifacts. Source05 uses shared-address fuel 7 (eight original rows); selected
source and recursive-source01 use fuel 15 (sixteen original rows). All predicate
declarations have identical normalized bodies between source05 and selected.
The only shared-address declaration body change is that fuel constant.

No compiler, generated program, target or sampler ran for this audit. Python
read metadata/source; objdump disassembled existing objects. Instruction counts
below count disassembly rows excluding mnemonics beginning `nop`; they include
all paths in a function and are not executed instruction counts. Differential
scaled-address counts inspect operands with scale 2/4/8. Multiple other Phase192
changes are present, so total function deltas are not isolated pass attribution.

## Incremental implementation complexity

| New module | Lines / bytes | Declarations | Added responsibility |
| --- | ---: | ---: | --- |
| predicate-normalization | 108 / 5,114 | 14 | Exact-0/1 facts, pure-copy diamond certificates, branch recursion, width/mutation invalidation |
| shared-addresses | 199 / 10,976 | 24 | Alias records, bounded windows, whole-function use/write/protection certificates, memory-row placement and emission |
| recursive-regions | 206 / 10,701 | 30 | Structured consumer of unchanged canonical H planner; demonstrated capability expansion |
| float-conversions | 63 / 3,033 | 9 | Exact conversion selection used by the demonstrated FP experiment |

These counts include laws/types and exclude tests and edits to existing files.
Predicate adds one pipeline call before local-value propagation and allocation.
It scans functions up to 4096 statements, builds mutable-name facts, recursively
checks branches and clears unresolved joins/calls. It does not maintain general
expression graphs, path environments, load facts or loop invariants. Existing
`x191_select_plan` supplies its bounded pure-copy shape certificate.

Shared addressing touches placement, ordinary emission, branch-fact enabling
and the float ordinary-route gate. Placement and emission must agree on exactly
the selected rows. It runs a bounded scan at eligible scale operations, maintains
aliases and rejects input writes, calls, control edges and allocations. It reuses
Phase191 read/write/protected-name facts; with ordinary address selection already
enabled it does not newly justify charging all fact-building cost to this pass.
Conversely, its scan/record work and repeated placement/emission selection are
real added work. Existing timing reports do not isolate that work. Doubling
window fuel doubles the worst bounded search length, not total compilation time.

## Predicate: real repeated lexer code changes

| Lexer function | Phase191 instructions | dev-emit01 instructions | cmov before → after |
| --- | ---: | ---: | ---: |
| `$direct.cls` | 140 | 92 | 10 → 4 |
| `$product.lex` | 245 | 197 | 10 → 4 |
| `$product.step` | 182 | 134 | 10 → 4 |
| `$direct.gen.at` | 271 | 233 | 9 → 4 |
| `$direct.slot` | 91 | 61 | 6 → 2 |
| `$direct.expand` | 217 | 211 | 3 → 2 |
| `$direct.op` | 72 | 66 | 3 → 2 |

The repeated product lexer is changed, not only an unused helper. The class
comparisons now feed exact predicate copies/complements instead of six extra
1/0-select round trips. See `dev-emit01/lexer/program.s:7358` onward: the range
comparisons, xor complements and remaining composite selects are visible.
There are no new scaled addresses in these changed lexer workers, and their
classification is integer code, distinguishing this witness from FP conversion
or shared addressing. Full independent attribution still requires an off/on
emission and timing comparison.

The slice remains incomplete: four cmovs survive in product.lex, including an
identical tagged-constant pair around lines 7418–7422. It does not carry facts
through unresolved joins or understand all tagged Boolean forms. This is a
limit of the current slice, not authorization to expand it during selection.

Across the other development cases, the common six-instruction/one-cmov change
is a generated continuation; there is no demonstrated broad hot predicate win
in numeric, local-fold, local-pair, expression, editdist, Map or tree. In
particular the local-pair repeated numeric worker and tree generic-Boolean
decode are not fixed by this pass. Lexer variants are plausible beneficiaries,
but this audit does not inspect held-out outputs or transfer their performance.

The bundled development lexer ratio is 0.967213 versus Phase191, about 3.28%
lower time. This supports investigating the structural change but does not
isolate predicate gain. It cannot justify the earlier speculative 5–20% lexer
hypothesis as an observed result. Even repeating the full bundled 3.28% benefit
across three lexer cases would reduce a 44-case geometric mean by only about
0.23%; that is an illustrative extrapolation, not a measured suite contribution.

## Shared addresses: actual but conditional coverage

Every one of the nine emitted development cases gains six scaled-memory
operands in borrowed `$p118borrow.read.String.order.go`, whose full static body
changes 470 → 452 instructions. Additional changes are:

| Development case / function | New scaled-memory operands | Full-body instruction change |
| --- | ---: | ---: |
| Map / borrowed `String.cmp` | 6 | 509 → 491 |
| Map / borrowed `Map.bit.go` | 2 | 221 → 215 |
| Map / borrowed `p37.map.string` | 2 | 142 → 137 |
| Tree / borrowed `stat_out` | 2 | 144 → 140 |

This is not a zero-hit pass. The split U32 loads at offsets 0 and 4 share a
scaled heap address. The former shift/add/pointer staging becomes two memory
operands `(base,index,8)`, while exact load order and later reconstruction remain.
The String.order.go savings occur in several alternative branch regions; they
must not be counted as eighteen instructions on every traversal.

The important hotness qualification is visible at
`dev-emit01/coverage-map-churn-32/program.s:1805–1821`. Borrowed Map.bit.go tests
bit 63 and branches over the newly indexed split-load block when it is zero.
The changed block is not the complete bit-traversal loop. The final Phase191
profile assigns 10.958% to the entire borrowed bit leaf and 1.485% to borrowed
String.cmp (only nine samples, low precision); it does not establish the dynamic
fraction executing these particular changed blocks. No String.order.go or
borrowed p37.map.string entry occurs in that reported candidate leaf table.
Absence of those sampled leaf entries is not proof of zero execution.

The bundled Map result is 0.982332 versus Phase191, about 1.77% lower time;
private staging and other changes are also present. No part of that improvement
is assigned causally to shared addressing here. Whole-leaf sample shares,
static savings and a bundled speedup are insufficient to establish the pass's
independent economic value.

## Eight-row versus sixteen-row window

Comparing `dev-emit01` and `recursive-emit01` assembly for tree-bitonic,
coverage-expression-32 and lexer: every existing private function is byte-for-
byte identical as assembly text. Common function changes are the public H
adapters and continuation wrappers with unchanged instruction counts and table
references; there are respectively 3, 3 and 2 new H workers. Thus the larger
window adds no observed transformation in those existing private workers.
New H workers have no cap8 counterpart in these artifacts, so this comparison
does not establish that cap16 is globally inert.

The later `selected-emit01/local-fold/program.s` supplies a positive development
witness for cap16 (assembly SHA-256
`8b4b5364c2b4d02db53afe32196d1b16bf3612b98dfc4daee6c2eedeccce7492`).
`$product.fold.loop` changes from 124 to 122 assembly
instructions: `imulq $4,%r8` and one register copy disappear; both the load and
store using `(base,index,1)` become `(base,index,4)`. The common-body diff is
confined to this chain, apart from the String.length H adapter and a continuation
table reference elsewhere. These are instructions in the repeated fold loop,
not an unused helper. This supports retaining the existing bound, but supplies
no isolated runtime estimate. The earlier cap8 bundled local-fold result
(0.997181 versus Phase191) cannot price this newly admitted transformation.

Do not tune the bound from newly evaluated held-out programs. A future causal
experiment should hold FP/H and all other source bytes fixed, compare shared
off / cap8 / cap16, confirm which generated functions differ, and then price
runtime and compiler selection cost. Correct finite controls alone do not answer
that economic question.
