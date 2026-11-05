# Phase168 — verified interfaces before continuation discovery

The bounded alternative now offers a useful joint build/runtime tradeoff on two
real compiler computations. It does **not** establish a faster full native
self-build or a 10× architecture. Phase152 remains qualified; production source,
runtime, manifests and installed selection are unchanged.

[Design](../../design/phase168/README.md) · [Metrics](metrics.json) ·
[Reproduce](reproduce.md) · [Independent audit](../../experiments/phase168/quality-audit.md) ·
[Implementation notes](../../experiments/phase168/scalar-plan.md).

## Measured result

Each final pair uses identical source, checked API05, authenticated prepared Base,
runtime and machine toolchain. These are fresh-process **Bun-hosted Bend compiler**
requests, including source preparation/checking, backend work, final verification,
rendering/writing, QBE, assembly and linking. They are not native N1/N2 compiler
timings. Standard Base preparation is reused equally, so these are complete
requests under that fixed policy, not cold reconstruction of every dependency.

| Real compiler computation | Baseline build | Candidate build | Build time reduction | Baseline native runtime | Candidate native runtime | Runtime ratio |
|---|---:|---:|---:|---:|---:|---:|
| Nonempty verifier, 39,333-byte source |31.558s|27.759s|12.04% (1.137× speedup)|0.43819s|0.42841s|0.978×|
| Lookup/complete-record digest, 15,408-byte source |11.754s|7.037s|40.13% (1.670× speedup)|0.53772s|0.57496s|1.069×|

Build times are single screening observations. Runtime values are medians of
four alternating pairs; every observation checks complete independent stdout.
The verifier's first pair is slower than later pairs, so describe its runtime as
roughly maintained, rather than claiming a robust 2.2% improvement. Lookup's
approximately 7% regression is real evidence against universal quality parity,
although it passes the pilot's ≤1.10× limit. The original verifier objective of
approximately 25% lower build cost with this runtime limit was **not met**.

Final comparisons use `baseline03`/`imports01` with `runtime-final01`, and
`lookup-baseline01`/`lookup-candidate01` with `runtime-lookup01`. The earlier
`runtime-imports01` block used baseline02's executable and measured 0.964×; it is
retained as preliminary evidence, not substituted for the final matched pair.
All three verifier baseline QBE products are byte-identical.

## What changed and why the first attempts failed

Phase167 demonstrated that early semantic capabilities can admit direct workers
without constructing their full generic continuation bodies. It reduced this
verifier's build cost by about 25%, but execution became 1.485× slower. This
phase tried to recover the missing composition without restoring the old pipeline.

1. **Scalar readers were necessary but insufficient.** Cache source-authorized
   scalar plans before candidate admission, then materialize each reader only
   when its actual owned fallback passes the existing leaf and ownership gates.
   Broad early inlining restored ten reader pairs, but embedded old owned helper
   bodies inside consumers before their borrowed replacements existed. Some
   consumers grew substantially, and build cost returned near baseline.
2. **Selective preparation avoids that stale inlining.** Preserve ordinary
   consumers; inline only eligible nonleaf scalar fallbacks using unchanged leaf
   helpers. Exclude owners scheduled for replacement from that helper table.
   This keeps the preparation saving, but by itself leaves execution about 1.35×
   slower. Counts of restored functions did not establish equivalent composition.
3. **Late callable flags arrive too late.** The demanded direct workers are
   private, while verified adapters establish a callable boxed ABI. A renderer
   copy can recover those public signatures from authenticated adapters, after
   unchanged private final verification and an additional public/borrowed check.
   However, the ordinary renderer has already built its continuation registry
   from an empty seed. Publishing the signature afterward cannot repair earlier
   missing local composition.
4. **Seed verified imports before discovery.** Reuse the Phase164 import contract
   before the unchanged region passes. Match actual adapter headers and checked
   direct signatures, retain the full fusion index, omit imported owners from
   redundant region candidate construction, and emit one real `p112w → p113d`
   forwarder for each rank-zero import. No fake successful plan or missing body
   justifies a ready entry. This is the successful treatment.

The 93 direct worker bodies are **byte-identical** between the stock-public and
import-seeded variants. The latter adds 36 real import forwarders; the increase
from 124 to 160 region-named functions is entirely those forwarders, **not** a
new cascade of discovered region workers. What changes is their availability to
local continuation composition. See [the census](imports-census.json).

The concrete compiler path `p111v_put` previously saved a six-value continuation
frame and scheduled `atom`. The candidate makes two local `atom` calls and one
local `index_hash` call before the remaining `index_set` transition. This survives
QBE machine construction; the audit links the actual QBE and assembly locations.
Static jump sites decrease 716→421, while several other instruction/call counts
increase because composition duplicates code. These are static observations,
not dynamic event counts or an exclusive attribution of runtime savings.

The architectural lesson is specific: **verified interfaces must exist before
the analyses that need them**. An equivalent signature added at the final emitter
cannot replace missing information at an earlier composition boundary. This
pilot reuses an existing mechanism rather than requiring a new backend or SSA IR.

## Negative results retained

| Treatment | Verifier build | Runtime relative to its measurement-block baseline | Decision |
|---|---:|---:|---|
| Cached scalar plans, no broad inlining |24.599s|1.359×|Quality gate fails|
| Broad protected inlining and scalar recovery |31.014s|1.407×|Build saving largely lost; quality fails|
| Generic registry renderer control |32.808s|Same runtime as broad inline in paired block|Does not restore direct-aware composition|
| Selective scalar preparation |24.291s|1.354×|Useful preparation policy, insufficient alone|
| Maintained cursor, private view |27.025s|1.356×|Still missing composition|
| Maintained cursor, callable view |27.070s|1.391×|Public flags alone arrive too late|
| Same callable view, early registry imports |27.759s|0.978× final matched block|Useful bounded result; transfer required|

Do not compare these runtime ratios as one randomized multi-treatment trial.
They belong to separate alternating blocks. Selective preparation's earlier
build used a different checked API from baseline01; its absolute time is an
observation, not a same-API comparative claim. Final headline pairs are matched.

The final API's stock-public control emits QBE **exactly equal** to API04's
callable-view control, despite the additional export and module. This isolates
the final import-ordering change. An attractive alternative explanation—baseline
array-mode emission—was rejected from the actual artifacts: both programs have
capability 5, the same 185 hot constructor entries and no relevant array/float
templates. We did not force an unauthenticated array certificate.

One API acquisition failed because new finite controls lacked explicit local
List type annotations. The failed source and stderr remain in evidence; corrected
annotations passed the next source check. No admission or verification gate was
weakened to fix it.

## Where complete build time went

| Interval | Verifier baseline | Verifier candidate | Lookup baseline | Lookup candidate |
|---|---:|---:|---:|---:|
| Checked API loading |0.224s|0.226s|0.225s|0.224s|
| Authenticated Base preparation |0.856s|0.840s|0.842s|0.843s|
| Input frontend/checking/preparation |8.162s|8.093s|2.795s|2.758s|
| Backend, final verification, rendering/writing |21.555s|17.965s|7.480s|2.919s|
| QBE + assembler + linker |0.401s|0.339s|0.136s|0.063s|
| Process/orchestration remainder |0.360s|0.324s|0.277s|0.234s|
| **Complete request** |**31.558s**|**27.759s**|**11.754s**|**7.037s**|

The combined backend/render interval is intentional: the baseline cursor delays
part of rendering while the experimental entry materializes chunks earlier.
Comparing only `lowerVerifySeconds` would misattribute this work. There is no new
exclusive breakdown of individual backend passes. Machine construction is small
for these slices; that does not establish its contribution for the full compiler.

Verifier emission falls 2,042→1,237 functions and 2,895,455→2,309,376 QBE bytes;
ELF bytes fall 618,480→473,480. Lookup falls 521→50 functions and
914,799→273,944 QBE bytes; ELF bytes fall 254,464→156,008. Those are corroborating
work/product observations, not substitutes for the complete measurements.

## Correctness, implementation and cost

The checked experimental implementation is 572 lines across six Bend modules
under [selfhost/tests/phase168](../../selfhost/tests/phase168). Final source SHA256
is `836b64c1d88e18502dbff738e7837056f7d73059ba2ee4f16f82dca2d06bbce3`.
[Source-only replay](reproduction.json) reproduces those bytes. It overrides only
the experimental `p168_closed` and `p168v_prepare` declarations; no production
declaration is replaced. Historical variants remain explicitly experimental.

The initial all-private actual-program final verifier remains unchanged. The
renderer-only callable copy additionally passes the maintained public ABI and
borrowed-body verifier. Import eligibility binds actual identity, arity, result,
zero incoming captures/flags and public direct signature. Real emitted forwarders
satisfy registered symbols. Existing region verification and rank ordering remain.

Final API05 passes 68 finite malformed-program, source/adapter, borrowed-root,
scalar/layout and selective-preparation controls. All timed verifier outputs are
the independently established `768`; all lookup outputs are `3279346725`.
Additional final candidate checks pass shared Data captured by distinct affine
partial closures plus 20,000 non-tail calls (`20040`), and the frozen catalog's
Map/IO point (`3714872484`, correct iteration/time fields). The latter checks
semantics, not a resolved Map runtime improvement.

These establish checked source/types, structural contracts and finite semantic
agreement. The experimental modules use the existing compiler's `@unsafe`
style; no new BendTT proof or whole-compiler equivalence theorem is claimed.
Neither the frozen45 suite nor native N1/N2 self-reproduction ran in this phase.

There were 32 root-owned guarded jobs, one failed acquisition, and **461.27s
(7.69 minutes) of total target execution-lane wall time**. Peak sampled process
tree RSS was about 1.97GiB. Three bounded agent roles covered implementation,
independent criticism and retention; only root ran targets. This cost excludes
reasoning, editing, source extraction and archive work. Quota telemetry was not
available, so no claim about total research cost follows from target time alone.

All target runs are closed, archived and verified. Reviewed retention reclaimed
60.17MiB of old authenticated intermediates, another 20.51MiB of Phase149 machine
intermediates, then 5.60MiB of the superseded baseline01 SSA/assembly/object.
ELFs, source/API snapshots, receipts, final comparisons and qualified images stay
hot. Reproducing baseline01's offline inspection requires its verified archive;
its runtime executable remains available. Default 5GiB disk reserve was retained.

## Decision and next experiment

Retain this as a working experimental alternative. It recovers the verifier's
execution quality and transfers a useful build/runtime tradeoff to lookup. It
does not yet justify production promotion: the original verifier build target
was missed, lookup regresses, and full native scalability is unmeasured. The
qualified **249.222s full-build observation remains unchanged**.

The next useful step is one larger, nonempty checker/optimizer closure using the
same early semantic interfaces, with complete native execution and build costs.
First distinguish remaining frontend cost from retained region preparation and
verification; do not restore every old optimization or add another generic cache.
If transfer holds, consolidate the duplicated experimental interface plumbing
into one preparation boundary before paying for a full native image.

For a future larger architectural change, the competing option remains one
canonical recursive computation representation with explicit resumable frames.
This pilot favors the cheaper interfaces-first correction for the next test.
It provides no evidence yet that either option can remove the frontend and
runtime costs needed for a 10× full-build gain, nor causal recursive acceleration.
