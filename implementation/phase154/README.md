# Phase154 — numeric identities before lowering: useful, insufficient

The private Bend prototype reduces complete selected compiler-helper processing
time by **13.02%**, but only **2.36%** on the unrelated Map helpers. It does not
meet the near-2× regional discriminator from Phase153. Keep the experiment and
its evidence; do not migrate the production compiler or acquire a full image on
this result. This is a bounded result, not a rejection of every compact-IR design.

[Design](../../design/phase154/README.md) ·
[Hypothesis](../../experiments/phase154/P154-001-direct-identities.md) ·
[Metrics](metrics.json) · [Costs](cost.json) · [Evidence](evidence/README.md).
Starting HEAD: `bde17c0`, branch `selfhost/bootstrap`. Maintained source, installed
selection and the qualified Phase152 N2 remain unchanged.

## What was actually changed

The [producer](../../selfhost/tests/phase154/lower.bend) mirrors the existing
`p113d_candidate`, taking an actual erased request book. Its local binders become
`P154Binder{U32}` immediately, before an old string-named direct body exists.
Fixed/synthetic names remain `P154Named{String}`. These distinct constructors
preserve the full U32 domain without reserving a colliding numeric sentinel.
The [model](../../selfhost/tests/phase154/model.bend) carries the identities
through scalar statements, calls, conditions and returns.

The [consumer](../../selfhost/tests/phase154/scalar.bend) replaces generic
`KDef`/`KTerm` fact encodings with dedicated Patricia-tree cells. It retains
bounds/constants, ordinary versions, relation epochs, predicate provenance and
inversion, branch joins and the original 4,096-statement limit. Existing arithmetic
transfer functions remain the reference. Hash collisions use exact tagged-name
comparison. This is still a persistent tree of runtime objects, not an arena of
unboxed records or an allocation-free numeric table.

The [codec](../../selfhost/tests/phase154/codec.bend) converts back once at the
original final verifier/emitter boundary. Primitive and static fixed-leaf helpers
still produce small old-form snippets and convert them; that cost is included.
Global names, constructor metadata, operation strings, output rendering and
the independent verifier remain original. The whole-function forward codec is
used for controls, not to manufacture the timed producer input.

Five private prototype/fixture modules total 1,383 lines. They are not a second
selected compiler implementation. The prototype includes `@unsafe` recursion
as the surrounding implementation does: source checking and these finite gates
are not BendTT proofs, termination proofs or compiler semantic-equivalence theorems.

## Scope and results

Two inputs were captured through the exact current checked API: an extracted
compiler-verifier workload and the unchanged Map churn workload. Selection used
source branch/call counts and declaration spread before candidate timing. All
16 initial owners remain in the results. Four owners already admitted by the
original final headers were added before timing to increase executable coverage.

This boundary is narrower than the proposed whole backend region:

- It tests the legacy `p113d_candidate` producer on real pre-backend inputs.
  It does **not** replace the canonical prepared `p126s`/`p113pl` pipeline.
- Of 20 owners, five retain the same producer refusals, six retain the same
  verifier-context refusals and nine produce independently accepted exact QBE.
  Map's central non-tail recursive insert/search/pop paths are not covered.
- Consequently, neither these percentages nor their inverse can be applied to
  Phase153's 101.45-second region or the 249.222-second cold-build observation.

Both paths run in one native executable built by qualified Phase152 N2. Each
process reads the complete captured book, constructs authentic ordered verifier
contexts once, then repeats fresh production, optimization, verification, QBE
rendering and writing. The new path also pays conversion. Final destruction and
process cleanup remain in the clock. No lowered results or optimized bodies are
reused. Zero-repeat costs are reported without subtraction.

| Workload | Owners timed | Repetitions per child | Original median | Prototype median | Less time |
| --- | ---: | ---: | ---: | ---: | ---: |
| Compiler verifier helpers | 5 | 16 | 5.90059s | 5.13259s | **13.02%** |
| Map helpers | 4 | 1,024 | 6.91972s | 6.75623s | **2.36%** |

Four alternating old/new pairs, serial CPU3, one worker, GPU off. Compiler pair
ratios span 0.8591–0.8822; Map 0.9748–0.9812. These are observed ranges, not
confidence intervals. Fixed setup is approximately 1.0s/0.8s respectively and
is included. Complete output is checked before and after timing; timed writes
go to `/dev/null`. Exact native image SHA256:
`fdd0ce72723d9c90a00412d01e8b77ef6d2809b7bef6ca6035d8ed67cf80e09b`.

The 25 literal scalar cases and 20 actual-owner differential cases pass. The
literal cases cover facts, branches, epochs, predicate inversion, ID boundaries,
hash collisions and the 4,095/4,096 limit. The authentic private-header prefix
excludes the current and later owners. The original independent verifier runs
unchanged on every timed successful owner. Nine complete QBE outputs match.
The checked Bend fixture decoder also reproduces every field of both whole
captured books; an independent host roundtrip checks sharing correspondence.

No emitted user program runtime was measured: exact output protects these nine
products, not the full benchmark suite. No whole-compiler speed, fresh upstream
ratio, self-reproduction or new installed qualification is claimed.

## What the profile tells us

A 21.76-second guarded capture reuses the same executable and retained sampler:
33 repetitions in each role, 16ms period, 707/607 samples, no lost samples, over
99.96% process CPU coverage, 96.75%/95.72% symbol resolution. These pass the
profiler's quality gates. One physical-leaf capture per role is diagnostic;
small differences are noisy and do not establish allocation counts or callers.

| Physical sample class | Original | Prototype |
| --- | ---: | ---: |
| Named `index_hash` workers | 55 | 24 |
| Ownership and product runtime | 152 | 130 |
| Reclamation | 112 | 107 |
| Allocation | 23 | 29 |
| Scheduler | 22 | 17 |
| All samples | 707 | 607 |

The strongest supported interpretation is that numeric IDs remove some hashing,
while much of the representation/ownership machinery survives. Reclamation is
almost unchanged in this capture. Do not interpret the six additional allocator
samples as an established allocation regression. Shared original verification,
rendering, loading and teardown also remain in these samples.

Machine inspection explains a remaining abstraction mismatch. The generated
`$direct.p154k_get` pushes a continuation, transports arguments through the
register bank and calls `p111_rt_jump`; `p154f_lookup` appears as a generic
scheduled Bend segment in the samples. Source-level lookup returns a complete
`P154FCell` containing owned fields before a consumer projects its fact. It is
not a direct native load from a compact numeric table. The retained assembly
and source make this observation reproducible; it is not a claim that this
one helper explains the whole remaining gap.

## Failed attempts and research cost

Fifteen guarded jobs total **349.08 seconds (5.82 minutes)**, including:

- One small native build, 63.97s; no full compiler acquisition or self-hosting.
- Clean timing/calibration/oracles, 157.86s; final short profile, 21.76s.
- Capture, source/fixture/control checks and four failed jobs, 105.49s.

This excludes agent implementation/review, offline analysis, report and retention
work. Three bounded agents prepared disjoint producer, fact-model and capture
work; root owned integration and the only target lane. No quota/billing telemetry
is available. Peak guarded process-tree RSS was 1.143GiB, below the 2GiB ceiling.
Every job used disk admission, the default 5GiB reserve and 16GiB memory floor.
All executed guards are sealed; no pruning or production selector changes.

Preserved failures: an exact historical-method binding mismatch before compiler
work; a host capture field error (`program` versus `original`); two ordinary
source-check errors in fixture/harness affine use. Offline capture plans that
did not execute are distinguished from target failures. Two early control
contexts included invalid private-header sets; their results are superseded by
the ordered-prefix gate, not counted as independent evidence. A 4.5MB literal
book fixture was rejected offline in favor of exact external data interpreted
by a checked Bend decoder. No resource exhaustion or unsafe runtime probe ran.

## Decision and next experiment

**Do not integrate this prototype as a large backend refactor.** It proves a
modest bounded opportunity, not the near-2× gain needed for the proposed cold-build
step. It also shows why simply renaming objects with integers is insufficient.
It does not falsify direct indexed storage, lifetime-aware borrowing or a broader
prepared-IR design; those are materially different experiments.

The most useful next discriminator is to remove a complete lookup-result lifetime
on this retained compiler workload: descend to and consume a scalar fact without
returning an owned whole cell through the scheduler. First inspect whether a
scalar-result query can become a verified borrowed native worker, using current
backend capabilities; if not, test the smallest explicit lifetime-preserving
interface. Require actual native direct access, fewer ownership/scheduler events,
and a complete-region gain with the same original verifier/output oracle. Do not
start by porting the entire compiler to arrays: Phase148 already showed that
current array transport can erase the benefit.

If that local machine-level ceiling is weak, move to Phase153's independent
publication-replay experiment instead. The present evidence supports stopping
the numeric-identity migration now, not buying a full qualification to search
for a better headline. No recursive research acceleration has been demonstrated.
