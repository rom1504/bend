# Bounded registry classification experiment

This investigation uses the current251.358s diagnostic request, whose registry
preparation interval costs16.879s. The interval's active-owner samples include
`String.eq`18.5%, `p118z_runtime`6.9%, `p118z_transition`2.9% and
`p112t_runtime_call`1.9%. These are different active owners, but they do not
identify every runtime-classification caller or prove an achievable speedup.
The entire16.879s interval is an upper bound; this first helper experiment is
expected to address a much smaller part.

Two attractive alternatives were checked before implementation:

- `book_final_fast` switches to indexed publication at incoming length≥256,
  regardless of existing-book size. A medium overlay on a huge book could do
  unnecessary repeated filtering. However, QBE-path callsites mainly supply
  whole Base/final lists; the other batch caller is JS emission. No current
  dynamic occurrence of the proposed small-overlay condition was established.
  The threshold was left unchanged.
- `p118ns_scalars/segments/direct/functions` use eager Boolean conjunction and
  continue after failure. Early termination would help rejected inputs, but
  **the actual full request is accepted**. Its exact output descriptor has
  capabilities5. Production starts that field at1 and adds4 only through
  `p118z_tables`, selected by `p118z_eligible`. The entire admission walk therefore
  succeeds; no false accumulator can prune this measured workload. No early-exit
  experiment or full build was spent on that hypothesis.

The frozen candidate replaces only `p118z_runtime`'s Boolean observation:

1. Original: construct the signature list for one of18 runtime names, inspect
   nonemptiness, then evaluate seven additional literal comparisons eagerly.
2. Candidate: recognize the same25 complete names through constructor patterns,
   sharing `p111_rt_` and `p118_rt_` prefixes, and return a Boolean. It constructs
   no signature list, uses no hash or input cache, changes no semantic IR, and
   does not admit prefixes or suffix extensions.

The experiment's explicitly reviewed25-name list was checked against the exact
original `p111v_signature` and `p118z_runtime` declarations. Preparations01–03
were data-only. Plan04's first API acquisition refused a forward reference to
`p147z_runtime_111`; no finite comparison or native timing ran. Plan05 moved
both helpers before their entry, preserving all three complete bodies.

Plan05 passed checked API acquisition, all677 independent finite controls,
small native construction, complete native controls, and timing. The677 cases
include25 positives, every proper prefix and single-position mutation,
suffix/case/prefix collisions, and Unicode/NUL near misses. Native output is the
complete677-result Boolean string before and after timing. Zero repeats and a
nonempty runtime salt independently check the benchmark protocol.

The benchmark uses1,375 actual `N111Call` symbol occurrences from three existing
captured complete-function cohorts, represented as frequency-compressed data.
This selection is neither the full compiler IR nor a dynamic call profile.
Runtime mode, repetition count and salt prevent fixed-name specialization.
Both algorithms live in one native binary; four ABBA blocks produce16 timed
observations, with both modes calibrated to at least0.15s. Complete stdout,
stderr and exit status remain exact; startup is never subtracted. The measured
candidate/original ratio is **0.09213**, or **10.85× faster in this classifier
workload**. This does not imply a10.85× whole-request improvement. The entire
16.879s registry interval is only6.8% of the profiled request, and this helper
accounts for a subset of that interval.

Plan06 expressed the same exact suffix/full-name patterns using Bend string
literals. Checked API acquisition and all677 controls passed again. The actual
selected N2 emitted **byte-identical1,188,233-byte QBE** to plan05's native
fixture, SHA-256
`144a2b11fc38a24297267dd4e43b54b62a987f20cdf90b30498dce85870e010a`.
This checks the self-hosted frontend's literal desugaring, beyond the upstream
API check. The compact syntax removes3,009 source bytes compared with the
explicit constructor patterns. It is a representation cleanup of the measured
candidate; no new algorithm was silently substituted.

Production integration changes only the existing `p118z_runtime` body and
adds `p147z_runtime_111` and `p147z_runtime_118` immediately before it in
`selfhost/src/back/qbe/ownership.bend`. The original `@unsafe` annotation and
`+symbol: String -> Bool` interface remain. The manifest gains exactly two
helpers; all112 protected raw/final declarations retain their exact hashes.
Independent source review decoded the complete accepted set and found exactly
25 names with no prefix, trailing-character or Unicode loophole. This is a
source-level correctness argument plus finite checks, not a kernel theorem.

The final frozen integration is
`selfhost/build/phase147/integrated-source03/compiler.bend`,3,045,282 bytes,
SHA-256 `0f3bd8a0f29944a317d6de14db05e6e34ba36daa22b350c25236d07519227eaf`.
Its `classifier-literal-bridge.json` binds the accepted experiment, exact syntax
replacement and protected declaration inventory. Full-image qualification and
whole cold-request timing are root-owned integration gates and are reported
separately; the helper result alone does not establish promotion.

Current reusable controls are documented in
[`runtime-classifier.md`](../../selfhost/tests/phase147/runtime-classifier.md).
They extract the actual production declaration and its two dependencies against
the unchanged independent677-case oracle. The current producer was checked by
offline preparation: exactly three declarations, the final source hash above,
and two fresh guarded target jobs. No new targets were run during consolidation.

All exploratory candidate/preparer versions were removed from current tests
only after exact archival verification. The
[experiment capsule](evidence/runtime-classifier-history01/README.md) contains
215 files,4,433,916 uncompressed bytes in a593,495-byte ZIP, including every
consumed source/method, failed attempt and accepted native/API result. Its
standalone verifier reopens and hashes every member without resolving old
paths. Original raw run directories remain intact. Historical method pins now
resolve through the capsule, never through replacement current test files.
