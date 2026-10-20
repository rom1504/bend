# Explicit width for pure Boolean diamonds

The failed branch24 candidate exposed a QBE 1.3 optimization defect: a valid
U64 phi joining 1/0 was replaced with its dominating U32 predicate without an
extension. Under register pressure the generated code stored four bytes but
later compared eight bytes at the spill slot. The scalar kernel kept the value
in registers and did not expose this failure; the array cell worker did.
The exact frozen-worker reproducer lives in `../branch-facts/spill-repro/`.

This optional Bend emitter rule recognizes only a branch whose two arms each
contain exactly one assignment to the same U64 destination, with constants 1/0
or 0/1. It emits an explicit normalized U32 comparison with zero followed by
`extuw` into the original U64 destination. It does not assume that arbitrary
branch conditions are already 0/1. Both scalar N111 and direct P113D diamonds
are handled through their existing branch-emission hooks. Other branches use
exact renamed copies of the old emitters, preserving effects and labels.

The admitted typed IR is unchanged. Fresh temporaries use `%p113_bool_N`,
separate from `%v_` locals and the width emitter's namespace, and consume the
shared emission counter. Counter exhaustion, terminal blocks and diagnostics
retain the original emission path. QBE and its pinned source remain unchanged.

Composition: append `model.bend` and `base.bend` with `--module`; append
`overrides.bend` with `--override` after the width and branch-facts profiles.
Export `p113bq_scalar`, `p113bq_direct`, `p113bq_ready`, `p113bq_emit` for finite
shape/normalization controls. Root must run the exact spilling reproducer,
actual failed localpair case and other frozen outputs before acceptance.
