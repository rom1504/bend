# Phase90: native self-hosting — implementation in progress

[Design](../../design/phase90/native-self-hosting.md). This phase is still active.
Complete compiler C emission now succeeds through the checked JS-hosted Bend B1:
109.399s request time,38.6MB C,1.21GB peak RSS. A native B2 fixed point has not
been established. The installed JS release is still Phase82; current source needs the
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

Subsequent profiling isolates ordered fork-flag propagation. An exact-name index
passes46 complete-product cases in JS/native execution and removes the late
list-search stall. The next profile exposes retained string allocation during
body indentation; removing that cosmetic traversal enables the first complete
C emission. Read [fork closure](fork-closure.md) and [formatting](formatting.md)
for actual results, failed heap-limited attempts and the changed-C boundary.

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

## Second checkpoint: independent checks and build diagnosis

Compiler06 genuine JS B2 passes tiny/full emission, all eight driver comparisons,
a fresh own-source check and B2/B3 byte equality. The installed release has not
yet been changed. The four complete C preprocessing comparisons now pass
(`whitespace02`): Small, Map, Unicode and file IO. V2's stdin-pipe timeout and
v3's successful read-only stdin descriptor are both retained.

Clang-O1 full compilation reaches the6GiB guard; Clang-O0 fails register
allocation. Tiny controls isolate indirect preserve-none must-tail calls. The
runtime padding slot must remain dead: with that correction the tiny-O1 build
works, while-O0 still fails. Upstream already guards these attributes with
`defined(__OPTIMIZE__)`; our runtime omitted it. An explicit diagnostic-O0
build using `-Dpreserve_none=cdecl -Dpreserve_most=cdecl` keeps emitted C exact
and succeeds on the tiny compile/execution control. Its full-image build is
in progress. Neither an optimized native speed result nor native reproduction
is claimed yet.

[Evidence02](evidence02.json) seals2,528 additional/changed files and preserves
all included failed attempts. It excludes the then-active qualification06 and
regalloc/noindent-method preparation; those need the next capsule.

## Own-backend native request qualification

[Build/ABI report](native-build.md): native03 builds successfully from our emitted
C and passes all eight live/cache exact-C requests. It is an explicitly
unoptimized cdecl diagnostic image, not an optimized-speed result. Native
self-emission remains a separate pending gate. The ordinary JS compiler06
self-check and fixed point are complete; installed source refresh remains pending.

[Prune06](prune06.json) removes66.3MB of exact archived failed-run image copies
and completed raw JS profiles; [prune07](prune07.json) removes223.5MB of exact
archived obsolete Phase78 candidate payloads. Restoration plans retain every
original member/hash; current images and unrelated work remain present.
