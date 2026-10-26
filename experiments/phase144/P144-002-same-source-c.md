# P144-002 — same Bend compiler, different native execution

Compare the exact Phase143 Bend source compiled by pinned upstream C/Clang with
the qualified direct-QBE image. Both compile unchanged Phase142 source to the
same complete QBE oracle using the same prepared Base. This isolates the
execution backend/runtime without replacing the compiler's algorithms.

Acquisition is separately timed and guarded. Use the existing explicit-file
Phase102 C emitter, then pinned Clang-O2. Current-source memory/build cost is
unknown; retain the16GiB available floor and allow up to8GiB RSS for one serial
Clang acquisition if headroom remains. Abort on resource/deadline failure.

Upstream C includes argv[0] in IO.args; the QBE harness supplies its own phase111
sentinel. The C observer therefore omits that sentinel and otherwise preserves
source/carrier admission and raw output verification. First pass one small
request and only then attempt the full source. The future QBE product still uses
the same runtime; the C image itself uses upstream's emitted runtime.

A materially faster C image would justify machine/source comparisons on compiler
hot paths. A neutral result would favor algorithm/representation work. Neither
result establishes generated-user-program speed, new self-hosting qualification
or a free gain: acquisition and subsequent rebuild costs remain separate.

## Acquisition evidence (2026-10-26)

Exact Phase143 source first refused upstream C emission at an arity over247.
A diagnostic-only emitter identified one263-word continuation in the native
session adapter:208captured words plus55result words. Removing an unobserved
rollback capture fixes that boundary while retaining generic transactional
rollback. This is included in integrated-source01, checked independently and
shown to preserve complete frozen QBE products. Therefore the subsequent
comparison, if acquired, is integrated-source01 versus its QBE N1, not unchanged
Phase143.

Pinned upstream emits integrated-source01 C successfully in88.332s supervised,
including81.466s emission, with4,796,280,832-byte peak tree RSS. The C output is
32,974,652bytes. Clang-O2 acquisition then hit the6GiB RSS limit at104.302s and
was stopped cleanly by the guard (peak6,442,622,976bytes; available20.60GB).
No native C image or speed comparison exists. No resource limit was removed.

Evidence: `selfhost/build/phase102/p144-integrated-upstream01/report.json`,
`selfhost/build/phase144/integrated-upstream-c-emit01-guard/process.json`,
`selfhost/build/phase144/integrated-c-build01-guard/process.json`.
The interrupted inner build receipt remains incomplete; the guard receipt is
the authoritative resource failure. Further acquisition is deferred in favor
of cheaper retained-object experiments.

A separately labeled same-C `-O1` diagnostic also hit the6GiB tree-RSS cap
after103.464s (peak6,444,810,240bytes), without producing an executable. Its
receipt is `selfhost/build/phase144/integrated-c-o1-build01-guard/process.json`.
This rejects lowering the optimization level as a cheap acquisition shortcut
under the retained limit; no further C build is attempted. The generated ABI
has21,973 segments sharing219 arguments (214Term registers), approximately
4.81million formal parameter slots. That is a source-grounded explanation for
substantial frontend/IR scale, not a measured attribution of the failing LLVM
phase. See `research/phase144/upstream-c-build-cost.md`.
