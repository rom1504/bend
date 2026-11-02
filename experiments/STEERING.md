# Current frontier — Phase155 twenty-idea screen

[Latest experiment](../implementation/phase155/README.md) ·
[Phase153 investigation](../implementation/phase153/README.md) ·
[Headroom metrics](../implementation/phase153/metrics.json) ·
[Qualification](../implementation/phase152/qualification.json) ·
[Independent audit](../research/phase152/final-audit.md) ·
[Experiment ledger](ledger.md).

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

[Phase155](../implementation/phase155/README.md) screened20 distinct ideas:
17 paired native kernels and3 source-level rejections.12 local wins,2 neutral,
3 losses. One shared small image;159.16 guarded seconds including failed checks
and transfer follow-ups,19 sealed jobs, no full self-build or production changes.
Seven agents prepared disjoint prototypes and an eighth reviewed independently;
root owned the single measurement lane. Agent effort is extra, not guard time.

The strongest directions are now:

1. Publication provenance05/constructor metadata07:0.302×/0.268× local new/old.
   Exact complete replay of603 compiler and504 Map events passes with actual
   source order, guards and law/fill schedule. Production checker mutations and
   canonical-state invalidation still need an explicit invariant. Measure that
   complete region next; do not assume the replay is dependent checking.
2. Dense scalar facts19:0.166× complete mutable kernel, general Term-slot arrays.
   Transfer to retained Phase154 actual-owner lowering with full metadata,
   snapshots, joins and original verifier/output equality before a large rewrite.
   Current model is not the selected fact engine and has no persistent branches.
3. Shared use-set15:0.569× complete keep/live consumer, active duplicate analysis.
   Check actual body sizes/early exits and byte-identical QBE before promotion.
4. Lifetime and query fusion09/02/04:0.705×/0.766×/0.747× local; require measured
   hot consumers and disappearance of ownership/scheduler work.

Identifier classification18 is0.362× in lexer-plus-all-token validation, but its
actual-parser transfer remains unmeasured: final checked fixture hits hosted
`dg_width` stack limits. Stop that harness campaign; do not count matching parse
errors as success. Body-analysis16's0.775× is discounted because actual inliner
admission rejects the large calibrated bodies. Text fusion11, local-spelling
cache13 and sparse bulk storage20 lose1.108×/1.665×/1.657×; retain negatives.
12/14 are already implemented; naive lazy lexer17 violates parser contracts.

These gains overlap and are component results. Do not add them or project them
onto the cold build. [Phase153](../implementation/phase153/README.md) remains the
complete-source profile:7,406 usable samples,236.947s staged CPU, N3 QBE equality.
Raw lowering39.27s + initial optimization23.55s + output/cleanup38.63s =101.45s;
checking/publication33.57s. Ownership/reclamation/allocation/register transport
42.71% of physical samples overlaps these stages and is not wholly removable.

[Phase154](../implementation/phase154/README.md) actual-owner numeric identities
improved complete child time13.02% compiler/2.36% Map, with9 original-verifier
QBE oracles. It missed the near2× gate. Phase155 creates new storage/lifetime
hypotheses; it does not retroactively qualify that private producer.

Keep identity comparison before broad machine builds and timing. Reuse qualified
unchanged products under exact source/runtime/toolchain identities. Identity is
not a fabricated timing observation or a new full-suite speed score. The Phase152
C-route and benchmark-eligibility fixes remain the maintained methods.

## Relevant recent evidence

- [Phase154](../implementation/phase154/README.md): 15 guarded jobs,5.82min;
  one small image, no full compiler build; all closed without pruning.
- [Phase152](../implementation/phase152/README.md): 51 guarded jobs, 29.10min;
  all closed, no OOM/pruning. Guard time excludes agent and documentation work.
- [Phase150](../implementation/phase150/README.md): scalar lexer integrated;
  the two-process correctness pilot is not native heap parallelism.
- [Phase149](../implementation/phase149/README.md): reduced optimization saved
  acquisition but regressed compiler execution1.831×. Keep complete-loop metrics.
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
