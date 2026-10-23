# Phase130 — measured decoder gain, scalar query still under investigation

**Work in progress.** Phase128 remains the qualified compiler. No installed
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
