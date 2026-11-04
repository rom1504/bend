# Current frontier — Phase156 real compiler transfer

[Latest experiment](../implementation/phase156/README.md) ·
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

[Phase156](../implementation/phase156/README.md) transfers the strongest
[Phase155 kernels](../implementation/phase155/README.md) into actual compiler work.
One shared checked native image retains original/candidate routes, complete
verification and exact independent qualified-image QBE oracles.

Publication provenance is the surviving candidate. Its private dirty bit skips
redundant canonicalization only after established canonical/coherent publication;
childless logged insertions invalidate it. Real checker mutations, error order,
law/fill scheduling, entry admission and final canonicalization are preserved.
Two reversed full-source pairs give medians215.026s→205.086s (4.62% less), with
identical118,227,421-byte QBE; pair gains6.19%/3.02%. Fresh **source-to-QBE** request,
live Base preparation and teardown included; machine construction is excluded.
Next integrate this state into the existing loop, then qualify its native image.
Do not call this a new qualified cold-build score or upstream ratio.

The actual645-declaration checker slice is neutral (23.670s→23.756s). It has
23 datatype declarations/21 static adjacencies versus369/294 in full source.
Static exposure and hosted checker diagnostic time are not native speed claims.

Shared-use lowering does not transfer its0.569× kernel result: the compiler
slice is neutral and balanced Map requests are1.00130×. Its initial11.6% Map
slowdown did not repeat. Machine inspection finds added guard/continuation and
retained-set transport, with no direct-worker admission loss. Preserve both
measurements; do not claim the static overhead caused a stable regression.

Dense storage's0.166× kernel is not a production fact engine. Actual owners
need snapshots, joins, old-state observations and full-width/name handling;
seven of nine retained admitted products branch. Reject a naive mutable port.
The20-owner eligibility probe is not a speedup or final optimizer-admission gate.

Next prioritize compact integration of publication-state reuse after its
balanced full-source transfer. Keep the original fallback, source invariant,
focused corrected controls and byte equality. Do not rebuild the full compiler
just to rescue the neutral use-set idea or mechanically port mutable arrays.
For further ideas, capture complete real native consumers and include lifetime,
setup and teardown before relying on Phase155 local ratios.

[Phase153](../implementation/phase153/README.md) remains the complete-source
profile:7,406 usable samples,236.947s staged CPU. Raw lowering39.27s + initial
optimization23.55s + output/cleanup38.63s =101.45s; checking/publication33.57s.
Ownership/reclamation/allocation/register transport42.71% of physical samples
is overlapping attribution, not wholly removable work. Phase154 numeric locals
improved its smaller actual-owner kernel13.02%/2.36%, not a near2× region.

Keep identity comparison before broad machine builds and timing. Exact unchanged
products can reuse prior generated-program evidence under fixed identities;
this is not a fabricated timing or new whole-suite score. Source checking,
finite controls and source reviews are not mathematical proof. Phase156 leaves
the maintained source and qualified/installed selections unchanged.

## Relevant recent evidence

- [Phase154](../implementation/phase154/README.md): 15 jobs,5.82min; one small image, all closed.
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
