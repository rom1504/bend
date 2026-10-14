# Phase90: native self-hosting — implementation in progress

[Design](../../design/phase90/native-self-hosting.md). This phase is still active.
Neither a completed native self-emission nor a native B2 fixed point has been
established. The installed JS release is still Phase82; current source needs the
real checked/self-hosting release qualification, not a manifest-only update.

## Confirmed repairs

Two static-image conversions and three whole-segment traversals now use tail
loops and reversal. Their previous JavaScript stack overflows are preserved.
The static-image controls include65,536 distinct words; all28 segment controls
pass, including65,536-segment inputs and retained complete products. Checked
compiler04 passes36 frontend witnesses, and its genuinely self-emitted B2 passes
the eight driver comparisons. These are finite gates, not full conformance.

See [static image](static-image.md), [segment traversals](segment-traversals.md)
and [bootstrap lineage and commands](bootstrap.md).

## Native table candidate and unresolved full-source cost

The previous exploratory late native profile attributed essentially all samples
in its120–180s window to growing-prefix String append. Its outer input-identity
gate failed after a concurrent source edit, so its attribution remains an
exploratory lead, not a qualified performance result.

Five table builders now collect reversed chunks and flatten once in an isolated
native source derivative. All108 complete String observations match independent
codepoint expectations in actual JS and native execution. The combined source
also includes the separate stack repairs; a full comparison measures that
combination, not tables alone. Canonical table code has not been promoted.

Combined source `74b390d3…` passed pinned-upstream checking with zero holes and
emission in87.366s. Clang built native image `c621447d…` in181.227s, peaking at
4,295,766,016 bytes RSS. All eight live/cache Small, Map, Unicode and file-I/O
gates emit byte-identical reference C.

Full self-emission still hit240.006s without C, at1,082,228,736 bytes peak RSS.
The independent genuine JS-B2 attempt on the same source hit90.066s without C,
at1,259,184,128 bytes. Neither failed from the RSS limit. The remaining emission
cost is being profiled before another change or longer full-source attempt.

[Table controls and exact derivatives](tables.md), [profiling](profiling.md),
[own-backend provenance/gates](own-backend-gates.md),
[paired native and45-point methods](../../selfhost/tools/performance/phase90/native-comparison.md).

## Evidence and resources

[Evidence01 receipt](evidence01.json) seals3,106 completed raw/method files,
including rejected attempts and generated source derivatives. Its archive uses
repository-relative member paths; restore only needed members into this checkout
and verify their manifest hashes. The explicitly excluded active native capture
is not part of that checkpoint. Shared Phase88/89 assets retain their original
capsules and identities. No successful profile capture implies completed C.

[Reclamation notes](reclamation.md) and [prune04](prune04.json) record recovery of
220.17MiB by removing14 historical CPU-profile copies only after exact comparison
with committed archives. Current compiler images and release dependencies remain.
Root alone runs compiler/native targets under resource guards. No PR comment was
posted.
