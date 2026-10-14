# Phase89: native compiler cost and self-hosting investigation

Checkpoint: investigation continues; production and installed Phase82 remain
unchanged. The qualified native image is still Phase88 native02. No PR comment
has been posted.

- [Host engines](engines.md): all 210 output comparisons pass. Bun improves
  upstream cold process time by 20.2% across the six-source screen, while Node
  remains faster for our frozen B2. Native wins five cold cases; Map remains a
  large exception. The official upstream executable fails with SIGILL on this
  host, separately from the successful source comparisons.
- [Operation counters](counts.md): Map performs 26.64 million append-character
  operations and 1.12 GB of cumulative allocation churn per request. All 32
  counted operations stay identical on calls 2–5 while time grows. This rejects
  increasing counted work as the explanation, without proving cache locality.
- [Owned composition](composition.md): a 14-line source increase removes retained
  child-result projections. The isolated candidate improves Map cold request
  time 19.6% and fifth request 26.4%, with exact C on 87 requests. Tiny/full
  lowering controls pass. Small cases show no clear benefit; promotion awaits
  broader integration.
- [Deferred body pieces](body-chunks-feasibility.md): the combined native candidate
  reduces Map cold request time 28.0% and fifth-request time 33.7% against native02.
  All 129 paired outputs and 45 broader points preserve complete C. Counters show
  39.8% less character copying and 29.4% fewer allocations on Map. This remains a
  native build experiment: [ordinary JS B1](js-integration.md) regresses 7–11% on
  Numeric, Lexer and Functions65, so unconditional source promotion is rejected.
- [Native B2 feasibility](native-b2-feasibility.md): native self-emission requires
  narrow file-effect admission, an explicit argument adapter and new stage/cache
  qualification. Corrected argv, decoder and file-IO controls pass, including
  expected failures. The first fixture's affine-checking failure is preserved.
  A fully checked nine-effect native B1 has built; its live/cache gates and
  bounded self-emission are now being attempted. Native B2 is not established.

[Design](../../design/phase89/bun-and-native-output.md),
[host usage](../../docs/self_hosted/host-runtimes.md),
[immutable checkpoint receipt](evidence01.json). The checkpoint capsule contains
all completed attempts through the first native-B2 fixture refusal, full source/
C/JS/native images, output products and method snapshots. Later attempts will
use a new capsule; the original remains unchanged. External runtime downloads
have explicit URL/version/hash receipts; Phase88 admission assets remain in
their existing capsule. Current raw build links can be restored at their recorded
repository paths from the checkpoint manifest.

[Checkpoint two](evidence02.json) retains the corrected/rejected chunk attempts,
native comparisons, counters, broad45, JS regression screen and nine-effect B1
build. Verified duplicate raw products were removed only after archiving; their
[deletion receipt](prune-checkpoint02.json) gives exact restoration members.
The smaller ownership-only JS ablation remains pending. All installed and
production compiler files are still unchanged.

The clocks above measure compilation to C, not generated-program execution.
Exact C preserves prior program behavior/code identity on the checked sources;
it is not a fresh execution-speed measurement or full-language conformance.
