# Extra candidate: conditional selection and frame forwarding

Offline inspection compares the exact products in `both-dev-build02` and
`extra-dev-build01`. The extra candidate combines conditional selection,
empty-branch cleanup and frame forwarding. Source, oracle and workload point
match for every inspected case; executable pins were reverified. No targets
were run. All audit outputs total approximately **6.5 MB**, below 16 MiB.

[Product pins](../../selfhost/build/phase191/machine-audit02/inputs.json) ·
[Numeric product pins](../../selfhost/build/phase191/machine-audit02/numeric-inputs.json) ·
[Counts, exact spans, normalized comparisons and CFG paths](../../selfhost/build/phase191/machine-audit02/summary.json) ·
[Offline derivation](../../selfhost/build/phase191/machine-audit02/derive.py)

## Local-pair: three actual CMOVs, six fewer conditional branches

The selected `$product.row` positive iteration changes as follows. Paths run
from the header to its backedge, excluding returns; these are syntactic CFG
bounds without predicate solving or dynamic weights.

| Statistic | Both | Extra |
| --- | ---: | ---: |
| Enumerated positive paths | 64 | 1 |
| Instructions | 97–102 | 93 |
| Instruction bytes | 437–464 | 412 |
| Conditional branches | 7 | 1 |
| Total branches | 8–14 | 2 |
| CMOV instructions | 0 | 3 |
| Explicit rbp memory references | 21–22 | 21 |
| Conservative store→next-load witnesses | 3 | 2 |

The complete body contains three conditional-branch/unconditional-jump pairs
whose targets were identical; all three disappear. Actual `cmovne` operations
occur at **0x40ceb3, 0x40cf38 and 0x40cf94**. The candidate still materializes
comparison results, moves them through registers and tests them again before
CMOV; this is not yet the mature C loop's direct compare/conditional-move form.

Frame forwarding also reaches this body. Both stores the masked destination
index at `0x40d693`, then reloads it from `-0xb60(%rbp)` at `0x40d69a`.
Extra preserves the store at `0x40cfb0` but uses `mov %r10,%r11` at
`0x40cfb7`. This is a removed frame load, not removal of the store itself.

The row's whole function changes 344→314 instructions, 147→122 explicit
rbp references, 88→64 explicit mov frame loads and 34→11 conservative
store/load witnesses. `$product.cell` changes 520→492 instructions and
81→55 explicit mov frame loads, with three CMOVs added there too.
`$direct.cell` remains 192 instructions with no CMOV.

Fresh row headers/backedges are **0x40d48e / 0x40d6c0** for Both and
**0x40cdf8 / 0x40cfd9** for Extra. Candidate spans were independently inspected;
old offsets were not reused.

## Map: frame-load reduction, no CMOV in the inspected workers

`p111_FID_…$direct.Map.ins.go` changes:

| Whole-function statistic | Both | Extra |
| --- | ---: | ---: |
| Instructions | 8,149 | 8,078 |
| Bytes | 41,606 | 40,597 |
| Actual rbp memory-reference instructions | 2,090 | 1,891 |
| Explicit mov frame loads | 1,364 | 1,165 |
| Conservative store→next-load witnesses | 276 | 77 |
| Calls / conditional branches / CMOVs | 411 / 113 / 0 | 411 / 113 / 0 |

Thus **199 explicit frame loads disappear**, while instruction count falls
by only 71: forwarding can replace a memory load with a register move as well
as eliminate a move. At the first tag-mask witness, Both stores the shifted
word at `0x416513`, reloads it at `0x41651a`, then masks it. Extra stores at
`0x4163eb` and masks the already available register at `0x4163f2`, with no
intervening reload. The retained JSON contains both complete witness spans.

The large insertion worker has no backward machine branch, so assigning it a
single loop-body count would be misleading. The inspected actual backedge
worker `$p118borrow.read.Map.bit.go` remains unchanged: three syntactic positive
paths, 60–75 instructions, zero CMOV and zero explicit mov frame loads on those
paths. Its header/backedge shifts from `0x407100 / 0x407472` to
`0x406ffa / 0x40736c`. `$direct.Map.set.go` and
`$product.Map.ins.splice.bit` also keep their instruction/reference counts.
These are source-selected worker observations, not measured hotspot rankings;
the forthcoming physical profile should establish their weight.

## Numeric regression: inspected recurrence and wrapper are unchanged

`$direct.p37.numeric` is **122 instructions / 530 bytes** in both products,
with zero CMOVs and zero conservative frame store/load witnesses. Its positive
loop path is **85 instructions / 395 bytes**, including one `p111_rt_op` call,
in both. Ten explicit rbp references are `lea` addresses of the operation
buffer; the diagnostic does not count accesses through the resulting pointers
as frame references.

`$direct.p93.loop` is also unchanged at **133 instructions / 577 bytes**.
Both functions' complete normalized instruction streams compare equal,
retaining instruction offsets, byte lengths, mnemonics, registers, constants
and target symbols/relative symbol offsets; only absolute direct call/jump
addresses are stripped. This is stronger than equal instruction counts, but
it is not whole-executable byte equality.

The recurrence entry shifts **0x408459→0x4083d6** and its loop header shifts
**0x40848c→0x408409**. Both products authenticate the identical runtime object,
SHA-256 `67141c4505a0355901d857c4ba81dfc17559329e536818a843ce68615384d13e`;
the object was rehashed in the
[runtime identity receipt](../../selfhost/build/phase191/machine-audit02/runtime-identity.json).

There is therefore **no added CMOV or frame-forward rewrite inside the
inspected recurrence or repetition wrapper** to explain the reported timing
regression directly. Layout/alignment and changes elsewhere in the executable
remain hypotheses. Matched ablations are needed to isolate it; these static
observations neither dismiss the regression nor establish layout as its cause.

All frame/branch/CMOV counts here are static. They establish emitted code changes,
not retired instruction counts, cache misses, store-forward latency or runtime
causality. The conservative frame diagnostic intentionally undercounts across
control and unsupported-instruction boundaries.
