# Phase130 — measured decoder gain, scalar query still under investigation

**Native qualification in progress.** The Phase130 N1 image passes focused19;
its self-reproduction is running. Phase128 remains the fully qualified compiler. No installed
selection or runtime changed. [Design](../../design/phase130/README.md),
[contracts](../../design/phase130/contracts.md),
[initial measurements](initial-results.json).

The extracted native prepared-Base decoder improved from0.374401s to0.241596s
median in nine alternating process pairs: **35.47% less time**, including input
reading, reconstruction and reclamation. Its only compiler-semantic change is
replacing bounded canonical decimal reads with two fixed-width Unicode scalar
lanes per U32. The carrier is larger in UTF-8 bytes but uses fewer runtime String
nodes. It is an authenticated private transport, not a native heap snapshot.

Twelve checked numeric controls pass. Graph-aware comparison covers88,578 object
pairs/221,919 primitive comparisons against the original cached preparation,
and125,089 pairs/318,383 primitive comparisons against fresh preparation. Exposed
old world/book sharing identities are preserved. Lexer, closures and Map emit
byte-identical complete QBE against both the original API and frozen native
oracles. These are finite checks, not a theorem or native self-host qualification.

The first scalar-only comparison source ceiling is **negative**:133ms baseline
versus149ms candidate on the shared-prefix64 workload, five alternating pairs.
The runner originally mislabeled `IO.now` integers as nanoseconds; the runtime
returns milliseconds. Raw output and wall times establish the correction above;
the ratio is unaffected. `scalar-run-v2.py` corrects future reporting. We are
investigating whether the new shape receives the intended borrowed-reader
optimization; this result does not justify an optimizer change.

Four rejected scalar fixture versions exercised binder ordering, structural
termination, Data-versus-Type quantity and constructor-binding annotation
requirements. They failed before code execution and remain recorded. The first
native decoder extraction omitted the `kc` dependency; the corrected extractor
checks lexical closure and both variants build. All failures are retained.

Preparation identity, bytes, commands and results are in
`selfhost/build/phase130/base-equivalence01`, `base-proxy-timing01`, and
`scalar-timing01`; guarded execution receipts are adjacent. One serial CPU3 lane
was used. Exact duplicate hardlinking reclaimed538,456,064 allocated bytes while
preserving all2,596 artifact paths, contents, modes/owners/xattrs. The original
inodes/mtimes and every replacement are recorded in `dedup-applied01/report.json`.

Next integrate explicit carrier mode without duplicating the decoder, measure
complete native requests, and qualify only if the whole-request result pays for
its complexity. The35% decoder result is **not** a35% compiler improvement.

## First complete native request result

The fresh three-round block reduces request time11.68% geometrically: qualified
Phase128N1 is2.0412× upstream; Phase130N1 with compact Base is1.8028×. Lexer
improves10.27%, closures21.13%, Map2.63%. All27 independent complete outputs
pass, and all18 native QBE observations are byte-identical across both compilers.
Request plus machine-build child sums are0.8824× upstream, with the existing
prepared-Base/cached-runtime policy advantage explicitly retained.

The integrated decoder proxy retains36.01% less time (0.367932→0.235432s). Its
legacy decimal mode takes0.372475s,1.23% above the old decoder in that block.
The second direct-U32 scalar ceiling is also rejected:525→640ms,21.90% slower.
Neither scalar rewrite changes the compiler.

Hosted full-image acquisition takes872.50 guarded seconds, peak6,339,612,672
bytes—close to the6GiB cap. The previous Phase128 historical acquisition was
512s/2.67GiB; this is not a same-source controlled comparison. Native request
gains must not be presented as faster full-image acquisition or demonstrated
research acceleration. Full native self-reproduction and final gates remain.

The selected source has57,018 physical lines,114 above Phase128 (0.20%), including
67 new control lines. Seventeen existing decoder declarations change; backend,
runtime and original final verification stay unchanged.
