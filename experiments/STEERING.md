# Current frontier — Phase154 compact-identity experiment

[Latest experiment](../implementation/phase154/README.md) ·
[Phase153 investigation](../implementation/phase153/README.md) ·
[Headroom metrics](../implementation/phase153/metrics.json) ·
[Qualification](../implementation/phase152/qualification.json) ·
[Independent audit](../research/phase152/final-audit.md) ·
[Experiment ledger](ledger.md).

This is current steering, not another historical ledger. The previous complete
Phase152 frontier remains in Git at `0a16bb7`.

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

## Highest-value next experiment

[Phase153](../implementation/phase153/README.md) profiles the actual Phase152 N2
on its exact qualified source: 7,406 usable samples, 236.947s staged CPU, complete
N3 QBE equality. Raw lowering39.27s + initial optimization23.55s + output/cleanup
38.63s =101.45s. Halving this whole region is a conditional roughly20% cold-build
opportunity, not an achieved saving. Ownership/reclamation/allocation plus register
transport occupy42.71% of disjoint physical samples; selected string workers
add9.92%. These overlap stage costs and are not wholly removable.

Phase154 tested direct numeric identities and compact facts on actual compiler
and Map owners. Whole child time improves13.02%/2.36%; nine original-verifier QBE
oracles match. The legacy direct producer covers only nine admitted helpers,
not the full prepared pipeline. It misses the near2× gate: retain the private
prototype, do not integrate or acquire a full image. Numeric hashing improves,
but persistent owned fact objects, reclamation and scheduler transport remain.

The next bounded discriminator is a scalar-result lookup that avoids returning
an owned whole fact cell through a continuation. Require a real direct native
access and complete-region saving before widening the representation change.
If the machine-level ceiling is weak, use the independent publication replay.
Do not project these component percentages onto the101.45s backend region.

Two alternatives are source-grounded: lifetime-tied borrowed-descendant results
are still unsupported by scalar/original-root borrowing summaries, and
`p143cp_put_log` canonicalizes the accumulated definition world before ordinary
non-childless publication. The latter has243 named book-finalization samples in
the33.57s checking interval and369 static type declarations as exposure; this is
not369 measured calls or a20% whole-build opportunity. Audit exact publication
commutation and failure worlds before its cheap replay experiment.

Phase153 spent281.46s across five guarded jobs, including just10.48s for the small
output gate; no self-build or broad runtime campaign. Production source remains
Phase152. A small event probe records24.69M pooled allocation calls for a complete
request including Base load and1.24MB output; do not extrapolate its counts to
full-source CPU shares.

Keep identity comparison before broad machine builds and timing. Reuse qualified
unchanged products under exact source/runtime/toolchain identities. Identity is
not a fabricated timing observation or a new full-suite speed score. The Phase152
C-route and benchmark-eligibility fixes remain the maintained methods.

## Relevant recent evidence

- [Phase154](../implementation/phase154/README.md): 15 guarded jobs,5.82min;
  one small image, no full compiler build; all closed without pruning.
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
