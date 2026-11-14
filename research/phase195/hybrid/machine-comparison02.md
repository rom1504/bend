# Baseline, hybrid and expanded register pool

The pool has a demonstrated local benefit in edit-distance and a demonstrated
static cost in several other workers. Its new state loads explain the extra
frame accesses. This is a placement-profitability failure, not evidence that
the validated register mappings or output controls failed.

All six pool products are complete with matching source/oracle pins and verified
artifact/build/oracle hashes. `machine-comparison02.json` compares Phase194
native45-02, hybrid-dev-build01 and pool-dev-build01. No target ran during this
audit. Pool machine controls separately passed in the root lane; this note
does not replace runtime measurement.

| Actual owner / cyclic component | Baseline instructions / frame refs | Hybrid | Pool |
| --- | ---: | ---: | ---: |
| editdist and pair p113d product.row | 77 / 20 | 74 / 19 | 75 / 17 |
| ray p113d product.nearest | 578 / 129 | 579 / 117 | 578 / 137 |
| ray p113d direct.nearest.t | 468 / 83 | 468 / 71 | 467 / 88 |
| tree p114r direct.warp | 341 / 110 | 322 / 85 | 353 / 130 |
| lexer p114r direct.gen | 168 / 38 | 163 / 34 | 183 / 52 |

Whole lexer product.step.at is unchanged by pool at 638 instructions and
174 frame references; hybrid reduces it to 562 and 131. Ray trace/pixel owners
remain unchanged in both experiments. Numeric recurrence has no established
major mechanism gain; some shared or subsidiary workers change.

## Exact state-slot accounting

The original capture's frame byte count identifies the newly appended state
word without relying on similar-looking instruction patterns. In each loop,
the changed frame-offset frequencies are:

| Owner | Removed references to old slots | New state loads | Net frame-reference change |
| --- | ---: | ---: | ---: |
| ray nearest | 4 at `0x48` | 12 at `0xcc8` | +8 |
| tree warp | 4 each at `0x19c8`, `0x1a40` | 28 at `0x1af8` | +20 |
| lexer gen | 5 at `0x58` | 19 at `0x1a78` | +14 |
| edit row | 1 at `0x958`, 2 at `0xaf8` | 0 at `0xb80` | −3 |

These offsets are positive magnitudes of negative RBP displacements. The new
state location is the original aligned frame end plus eight bytes. The hot
edit owner needs state only outside its actual loop, so it keeps the two
predicted recovered homes without paying a repeated state load. Call-heavy
workers repeatedly need the canonical state pointer and pay more than they
save. The pool currently moves state whenever color10 is used, without pricing
those state accesses.

The smallest useful follow-up is an RCX-only ablation that keeps canonical
state in R12. Retaining broader R12 allocation needs a state-use profitability
decision or explicit lifetime placement; simply adding candidate bits does
not repair these new state loads. The independently useful hybrid has different
coverage: modest hot edit gains, material static reductions in tree/lexer, and
fewer ray-nearest frame accesses. Its balanced runtime screen should decide
retention separately from pool.

Frame-reference instructions and cyclic components have the same limitations
documented in machine-comparison01.md. Added or removed static instructions do
not establish wall-time gains. No compiler-cost comparison is claimed.
