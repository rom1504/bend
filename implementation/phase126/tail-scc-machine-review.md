# Tail SCC source32: actual machine boundary

The checked source32 emission and completed five-case screen retain four joined
workers per program: `Nat.read.if/go`, `U32.read.if/go`, `Nat.show.go/fin`, and
`U32.show.go/fin`. This is actual selected QBE/assembly, not merely candidate
admission. The first two pairs were discovered by the same recognizer without
being named in its implementation.

For the record-aggregation product:

| Original pair | Joined identity | Term lanes excluding tag/state | Machine instructions | Local backward branches | Fixed stack allocation |
|---|---|---:|---:|---:|---:|
| Nat.read.if/go | `$p126scc.8` | 4 | 115 | 2 | 40 bytes |
| Nat.show.go/fin | `$p126scc.18` | 3 | 113 | 2 | 112 bytes |
| U32.read.if/go | `$p126scc.38` | 3 | 107 | 2 | 24 bytes |
| U32.show.go/fin | `$p126scc.92` | 4 | 104 | 2 | 16 bytes |

All twenty joined workers across the five products have two machine backward
branches. None calls itself, either member of its pair, another joined worker,
or `p111_rt_frame/jump/return`. QBE contains one entry jump and two transition
jumps to its existing loop label. The fixed frame allocation precedes that label;
it does not grow per transition. Saved registers and external callees' frames
are additional fixed call costs, so the table is not total stack usage.

Both formatting member wrappers call their corresponding joined worker. Existing
inlining also sends callers directly there: the record-building TRMC worker has
two static calls to the U32 formatting loop, while `p93.word` calls the U32 reader
loop. Nat formatting retains a direct `Nat.show.put` call and constructor/take
work; this pass removes the mutual transfer boundary, not every representation
or allocation cost.

The corrected source30 API passed all 16 finite predicates, including the
unchanged direct verifier over a generated worker and its two wrappers. Source28
and its law-signature parser failure remain preserved. The ordinary fixture's
separate Bool-pattern syntax correction is `tail-scc/cases02.json`; its native
semantic qualification is a separate root-run gate, not inferred here.

Exact input, QBE, build-receipt and assembly pins plus all per-worker counts are
in [tail-scc-machine-review.json](tail-scc-machine-review.json). The screen also
changes observers and Nat.divmod; it cannot isolate an SCC timing effect. These
static counts imply neither dynamic call counts nor a speedup estimate. This
review only read existing artifacts and did not run a compiler or target.
