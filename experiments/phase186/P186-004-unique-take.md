# P186-004: guarded unique-constructor take

V1 rejected after the 2026-11-09 runtime screen. Keep `unique-take.bend` and
its controls as negative evidence; its production hook was removed. A separate
single-fallback v2 prototype is described below and has no performance result
at the time of this entry. Root owns every source acquisition and target run.

The selected final185 runtime's `p125_rt_take2` unique heap/cache path has
roughly 50 static machine instructions before caller setup. Fresh record and
morning profiles identify 16.15% and 13.87% respectively in all take helpers;
these are physical leaf shares, not attribution to Map or String callers.
The prospective estimate that roughly half that helper work might be removable
suggested a hypothesis near 7%, conditional on unique-owner frequency and machine
optimization. The v1 screen below rejects that profitability estimate.
The full deletion ceiling is not an attainable predicted speedup, and this
does not close the broad C parity gap by itself.

`unique-take.bend` expands exact verified `p111_rt_take` calls with literal
counts 1..4, canonical state, qualified stack scratch and local/constant words.
It is a separate late template; this prototype installs no production hook.
Runtime guards require tag CTR with RFC clear, CID in [3, constructor_count),
the actual arity byte equal to count, a dynamic rather than static location,
and free-list length after insertion below 32768. Every miss invokes the
original helper, including shared values, packed words and bank handoff.

The selected ABI11102 runtime rejects threads other than one and GPU requests
at runtime.c:4721. Therefore its host `err_seen` is false, `LANE_STEP` is one,
and `KEEP_WORDS=CAP_WORDS=32768`. Its static corpus boundary is exactly
51413504 + round_up(static_words,128), using descriptor offset64. State mem/alc
are offsets0/8; allocation heads and lengths use classes0/1/2 and32+class.
No new descriptor capability is inferred, and no hot/cold publication fact is
needed: taking fields never seals or retains them on this unique path.

N111 has no byte load. The AMD64 template reads a U32 from cid_arity+(CID-3)
and shifts right24; all four bytes are inside the table. This conservative
CID restriction includes the observed hot map/tree constructors and avoids
reading padding or extending the IR. Runtime binding remains the explicit
layout/descriptor qualification boundary, as for existing frame expansion.

Field copies preserve the runtime's ordered load/store pairs, then insert the
consumed location at the free-list head and update its word length. The output
status is the original count. The existing reserved p114t namespace supplies
temporary hygiene; raw input aliases in that namespace decline explicitly.
Fallback calls render once through the previous pipeline.

Controls comprise 28 structural/verifier rows, an isolated 4,038-check machine
observer and an ordinary source ownership fixture. The observer checks all
state/cache words, touched heap/output regions, static rounding boundaries,
cache handoff boundaries, first/last admitted CID and overlapping field/output
copies. Invalid words occur only in isolated fallback-routing stubs. The
ordinary source fixture has unique parents, retained child fields and a shared
parent; its independently derived output is [2080,4160,6240,8320,12480].

Reject or narrow if real machine guard work/code growth offsets call removal,
or if unique-owner hits are uncommon. Compile-time lookup is constant per
eligible site, with no new whole-program analysis or descriptor-table scan.

## V1 measured decision

The [third paired runtime report](../../selfhost/build/phase186/third-qbe-runtime01/report.json)
compares the retained first bundle (`before`) with the third bundle
(`candidate`) in the same campaign. Do not subtract measurements from the
separate first runtime report. There are three rotated rounds on CPU3, four
warmups per batch, independently calibrated repetition counts and a 250ms batch
target. All 45 timed observations match complete expected outputs, have exit0,
and meet resolution admission; the shortest timed batch is 248ms. No input
changed. Values below are medians in microseconds; percent is third/first−1.

| Case | First bundle | Third bundle | Runtime change |
|---|---:|---:|---:|
| tree-bitonic | 386.807 | 404.798 | +4.65% |
| map-churn128 | 623.472 | 722.527 | +15.89% |
| record-aggregation256 | 895.105 | 1,020.492 | +14.01% |
| unicode-text64 | 105.152 | 93.000 | −11.56% |
| generic-row32 | 275.000 | 244.858 | −10.96% |

This is a five-case screen, not the full45 result. The third bundle also has
stacked-continuation changes: neither the Unicode/generic wins nor the record
regression independently measures unique-take. A read-only QBE comparison gives
a tighter boundary for tree and map: replacing each exact v1 expansion with its
original call, then consistently renaming local values and labels within each
function, produces byte-identical normalized QBE to the first bundle. Constants,
import names, function names and control structure are otherwise unchanged.
Tree/map therefore isolate the emitted unique-take change at this IR boundary;
record/Unicode/generic do not. This does not identify the hardware cause of the
regression.

The unique group of [second-controls01](../../selfhost/build/phase186/second-controls01/report.json)
passed all28 rows and all4,038 machine checks. The containing report is incomplete
because its separate stacked group failed; do not count the whole report as a
pass. The isolated observer links routing stubs, not the production runtime.
Correctness of these finite controls and runtime-output success do not establish
profitability or a complete compiler proof.

## V1 actual machine evidence

[Static audit with exact ELF/QBE/assembly hashes](P186-004-static.json) records
read-only `objdump -h`, `objdump -t`, and symbol disassembly of the retained first
and third native artifacts. No new compiler or program was executed for this
audit. `.text` includes the linked runtime as well as generated code.

| Case | First `.text` bytes | Third `.text` bytes | Growth | Static take call sites |
|---|---:|---:|---:|---:|
| tree-bitonic | 99,697 | 111,729 | +12.07% | 43 → 172 |
| map-churn128 | 219,569 | 270,417 | +23.16% | 132 → 528 |
| record-aggregation256 | 192,145 | 244,017 | +27.00% | 132 → 528 |

All43 tree and132 map original take sites expand. Each expansion retains four
identical helper-call copies, one for each nested guard failure. Exactly one of
those can execute on a miss; the fourfold count is code duplication, **not four
dynamic helper calls per take**. The original runtime helper remains linked.
QBE source grows 531,022→662,401 bytes for tree and 1,723,034→2,144,913 for map.

The growth reaches actual algorithm workers:

| Owner | Machine bytes first → third | Static instructions first → third | Stack subtraction first → third |
|---|---:|---:|---:|
| tree `warp_zip` | 928 → 2,420 | 205 → 562 | 2,072 → 2,152 |
| tree `warp` | 1,335 → 3,511 | 301 → 791 | 6,168 → 6,328 |
| map `Map.ins.go` | 27,576 → 38,488 | 6,171 → 8,320 | 15,144 → 16,104 |
| map `Map.seek.go` | 16,100 → 23,965 | 3,591 → 5,239 | 14,568 → 15,048 |

These are complete static function inventories, not executed instruction counts.
For example, `warp_zip` has26→111 instructions containing an RBP/RSP memory
operand (including address formation), and its straight-line entry through the
first conditional branch grows29→62 instructions. The third ELF at
`0x40771d` onward computes extra tag/CID/location pieces before the first dispatch
branch at `0x4077c5`; it also creates extra stack temporaries. The corresponding
first branch is at `0x406ae3`. This directly demonstrates added work on that
function entry even before a take fast-path choice. It does not measure how often
that function or a particular guard executes.

The half-helper estimate was too optimistic for this implementation. The fast
path still performs tag/ownership and CID/arity checks, descriptor reads, static
boundary computation, allocator-length validation, field copies and free-list
updates. Inlining removes a call boundary but does not delete those obligations.
Misses additionally execute guard work before entering the original helper,
which performs its own checks. Actual machine output also shows larger functions,
more stack operands and earlier pure computations; static helper counts alone
missed those caller costs. Instruction-cache effects, branch prediction, cache
misses and the unique-hit rate were **not measured** in this screen, so none is
asserted as the cause. The measured conclusion is to leave v1 unhooked.

## Isolated single-fallback v2 follow-up

`selfhost/src/back/qbe/unique-take-v2.bend` preserves every v1 guard and reuses the
same ordered fast writes. A private U32 flag starts at zero; only completion of
all writes sets it to one. Every guard miss leaves it zero. A final branch assigns
the original result to the known count on success, or invokes the original call
once on failure. This also defines the destination on both final branch arms,
rather than relying on a status definition behind a correlated flag. The fast
helper's private status value is unused. No runtime or descriptor rule changes.

Reserved destination names explicitly decline; existing word/buffer hygiene
remains. Destination aliases of word, scratch and state read all operands before
writing the result. New `unique-take-v2-controls.bend` adds four structural
single-call assertions and alias/refusal rows (36 total). The optional
`uniquev2` semantic-driver group preserves all4,038 v1 observations through the
unchanged C observer and adds1,296 destination-alias checks across every routing
case, threshold edge and output overlap mode. This paragraph records the
prototype and expected controls, not their execution or a speedup. Root controls
source checking, actual machine tests and any separate tree/map screen. V2 is
unhooked pending those results; v1 and its negative artifacts remain unchanged.

## Single-fallback v2: rejected as well

The revised template retains one fallback call instead of duplicating it. The
independent observer passes the original 4,038 checks plus 1,296 destination,
input, state and buffer alias checks. That semantic success does not establish
profitability. Against the continuation-only candidate, the controlled
`unique-v2-qbe-runtime01` screen observes candidate/baseline ratios of 1.0890
for tree, 1.1527 for Map, and 1.1301 for record aggregation. All three regress.
Both unique-take prototypes remain unselected. The final canonical module list
excludes v1, and v2 was never registered. Reducing fallback duplication alone
did not overcome the remaining inline-code and register-pressure costs; no
further ownership-template campaign was justified during this phase.
