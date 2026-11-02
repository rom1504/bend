# Current frontier — Phase152 prepared constants and integrated native compiler

[Latest report](../implementation/phase152/README.md) ·
[Metrics](../implementation/phase152/metrics.json) ·
[Qualification](../implementation/phase152/qualification.json) ·
[Independent audit](../research/phase152/final-audit.md) ·
[Experiment ledger](ledger.md).

This is current steering, not another historical ledger. The previous complete
Phase151 frontier remains in Git at `8b5abf2`.

## What Phase152 establishes

The maintained source now integrates authenticated prepared nullary constants,
the preferred Phase150 scalar lexer and compact Phase151 dispatch tables.
Original selector admission, bounded correspondence, constructor identity,
full-width nonownership and the independent final verifier remain intact.
The implementation is in the existing five modules, not a new parallel compiler.
The exact qualified source has 66,399 lines and 8,265 declarations (+292/+42).
All 112 protected declaration hashes remain unchanged.

Same-source cold source-to-executable screens: Phase147 N2 → new N1 takes
259.302s; new N1 → N2 takes 254.613s; new N2 → N3 takes 249.222s (3.89% less
than the first). One observation each, fixed assets/CPU3, OS caches not flushed;
this is not a confidence interval or a fresh upstream ratio. Three smaller
compiler requests improve 2.56% geometrically in four balanced rounds.

N1 → N2 removes all 13,600 strict nullary constructor/copies/sink pairs across
4,466 functions, preserving all 73,926 symbols. Calls fall 10.83%; QBE text
1.50%, object 4.99%, executable 3.32%. These are immediate values: the removed
calls did not allocate heap objects. Static counts are not dynamic hotness.
Consumed scalar dispatch witnesses improve 34–54%; this is not a whole-compiler
speedup of that size. The safe usage-summary witness is neutral.

All 45 ordinary benchmark QBE, assembly and object products are byte-identical
between Phase147 and Phase152. The 44 resolved runtime points are neutral
(0.99896×): 40 use scale1, four short points use scale64 in both roles, and
one zero-work point is correctness-only. No fresh upstream comparison.

## Qualified and installed identities

Phase152 N2 is the latest qualified ordinary serial native research compiler:
`selfhost/build/phase152/native-n2/program`, SHA256
`d62712958b53ecdbe19998ca54c9184f895b556acc661ad014dae89754b952bd`.
Use its [qualification receipt](../implementation/phase152/qualification.json)
and explicit assets. Maintained source assembly exactly matches the qualified
3,085,157-byte source, SHA256
`027e15041035522ed7e40ef971eff75f24a09ef6a00e3f8fe335839f94bcb8a8`.
N2/N3 QBE, assembly and objects reproduce exactly; ELF files differ. N1 focused19,
N2 all64, 66 compiler-data controls, hosted JS8 and C6 spot checks pass.
These finite gates are not a new BendTT theorem or parallel/GPU qualification.

Installed JS/C/QBE releases remain the
[consolidated selection](../selfhost/manifests/current.json). Phase147 remains
available as the qualified parent. Use the one maintained source tree and
[workflow](../docs/self_hosted/workflow.md), not retired experimental overlays.
Metric definitions remain in the
[comparison guide](../docs/self_hosted/NATIVE_COMPILER_COMPARISON.md).

## Highest-value next investigation

The narrow prepared-value boundary paid off, but its prior ctor/sink profile
envelope was only about 6%. Repeating this as another ambitious whole-build
prediction is unjustified. Refresh attribution on the new qualified image and
look for complete allocation/representation work in lowering, rendering and
frontend publication. Use the roughly 16-second checked API acquisition and
small independent witnesses before another full compiler build.

Packed static values and static boxes are a possible narrow follow-up. Raw static
boxes can acquire owning wrappers when stored into owning objects; do not extend
nonownership without preserving that boundary. Remaining sites are unprofiled.
See the [semantic contract](../research/phase152/prepared-values-contract.md).

Make identity comparison the first generated-program regression gate. Emit
against complete frozen references, then build/time changed products under the
same runtime/toolchain. All 90 fresh program machine builds in this campaign
preceded discovering identical code; much of that cost was avoidable. Identity
is evidence, not a fabricated timing sample or a new full-suite speed score.

Two existing host defects were fixed: C requests now use the public native route
instead of direct-JS dependency analysis, and benchmark eligibility is assigned
per input row. Frozen failed reports remain intact; future manifests must pin
the corrected tools. Do not reinterpret old aggregate claims silently.

## Relevant recent evidence

- [Phase152](../implementation/phase152/README.md): 51 guarded jobs, 29.10min;
  all closed, no OOM/pruning. Guard time excludes agent and documentation work.
- [Phase151](../implementation/phase151/README.md): the artifact counterfactual
  correctly identified the missing fact; it was diagnostic, not a production pass.
- [Phase150](../implementation/phase150/README.md): the preferred scalar lexer is
  now integrated; the earlier 4.43× lexical / 9.62% parser figures are component
  results. The two-job process-parallel pilot is not native heap parallelism.
- [Phase149](../implementation/phase149/README.md): reduced policy11 saved 53.59s
  acquisition but produced a compiler running 1.831× slower. Keep ablations;
  do not promote blanket reduced optimization to shorten one build.
- [Phase148](../implementation/phase148/README.md): late compact-IR conversion
  was neutral or worse; direct compact production remains a separate hypothesis.
- [Phase129](../research/phase129/selected-compiler-audit.md): source checking,
  finite laws, admission checks and independently checked proofs are distinct.
- [Upstream assessment](../research/phase150/upstream-assessment.md): migration
  needs runtime, representation and checker-contract gates. No upstream pin
  change was mixed into these measurements.

## Resource, evidence and communication rules

One root-owned serial CPU3 target lane. Ordinary jobs use maintained process-tree
and disk guards,2GiB RSS,16GiB available floor and5GiB disk reserve. Larger image
campaigns need an explicit measured budget; the prior6GiB gate is not a default.
Separate-process parallel correctness pilots require an explicit disjoint CPU
mask, aggregate accounting and no concurrent performance target. QBE's qualified
runtime remains one heap mutator, one CPU worker, GPU off.

No unsafe/failure-runtime probes; do not resume Phase113 custom failure
reproductions. Use ordinary valid programs, finite compiler/data refusals and
frozen independent oracles. Never overwrite frozen artifacts or hardlinked
products. Close each run through maintained retention; preserve negatives and
exact evidence before optional pruning. No full image build without measured
benefit and disk admission. No PR comments unless explicitly requested.

Use bounded agents for independent work; root owns target execution. Track
compiler work, machine builds, validation, failures, agent effort and billing
separately. Guard seconds are not total research cost; unavailable quota data
must not be invented. Keep commentary updates during sustained work.

Recursive research remains an open question. Follow the
[Phase104 design](../design/phase104/recursive-improvement.md) and
[research](../research/compilers_architecture_and_techniques/recursive-self-improvement.md).
Self-reproduction is not recursive acceleration.1×/10×/100× describe research
ambition, never established speedups.
