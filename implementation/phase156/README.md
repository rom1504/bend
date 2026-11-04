# Phase156 — real-work transfer of the strongest kernel ideas

**Publication provenance reduced median full-compiler source-to-QBE request time
from215.03s to205.09s, a4.62% reduction across two reversed pairs. All complete
outputs are byte-identical to the qualified original.** The small-source pilot
was neutral. This is a promising transfer result, not a new qualified compiler.

[Metrics](metrics.json) · [Cost](cost.json) · [Retention](retention.json) ·
[Exact evidence capsule](evidence/capsule.json).

The important finding is that local speedups need a second, real-computation
gate. Phase155's fast publication replay, dense storage and shared-use kernels
did not justify directly changing the selected compiler. This experiment puts
their actual semantic boundaries and complete request costs back into the test.

## What was tested

| Idea | Phase155 local new/old | Phase156 actual-work test |
| --- | ---: | --- |
| Publication provenance |0.302×| Real checker world, original mutations/scheduling and complete native requests |
| Shared use-set |0.569×| Actual flat-binding lowerer, original final verifier and complete native requests |
| Dense facts |0.166×| Structural eligibility of20 actual lowering owners; reject an unsound mutable substitution before building it |

The local ratios have different workloads and boundaries. They are not projected
onto whole compilation and cannot be added together.

All candidate algorithms are checked Bend. One isolated native image contains
the original and candidate routes, using unchanged Base preparation, ownership,
annotation, erasure, downstream emission, final verification and complete writer.
Mechanical original-ancestor clones allow one executable to select each route.
This is experimental code; the maintained compiler and installed selectors remain
unchanged. [Methods and replay](../../experiments/phase156/README.md).

## Native transfer results

The first pilot uses one fresh child per role on CPU3, one runtime worker,
GPU off. It charges live Base preparation, source loading/checking, lowering,
final verification, complete QBE writing and process teardown. Machine construction
and execution of the generated program are outside this clock.

| Actual source | Original | Publication | Shared uses | Both |
| --- | ---: | ---: | ---: | ---: |
| Compiler-checker slice,645 declarations |23.670s|23.756s|23.568s|23.749s|
| Unchanged Map program,8 suffix declarations |2.697s|2.711s|3.011s|3.010s|

Every one of the eight complete QBE files matches an independently produced
qualified Phase152 N2 oracle byte for byte. Publication shows no pilot gain;
shared uses is neutral on the checker and11.6% slower on Map in this single
observation. These are transfer screens, not confidence intervals.

A subsequent two-round Map check uses both orders (`uses,old`, then `old,uses`).
Median times are2.695297s for shared uses and2.691808s for original, ratio1.00130×;
all four outputs match. **The pilot's11.6% slowdown did not repeat.** Retain both
results. Static continuation overhead is not proof of a stable runtime penalty,
and sharing still has no demonstrated real-request gain.

Publication's actual admission threshold is256 childless **suffix** declarations;
Base does not count. The645-declaration checker reaches it; Map does not and is
an overhead/control case. The checker slice has23 datatype declarations and21
static adjacent datatype pairs. The complete unchanged compiler has369 and294,
respectively, motivating one full-source original/publication screen. Static
adjacency is an exposure clue, not a dynamic count or a predicted gain.

The full-source screen uses the exact qualified3,085,157-byte compiler:

| Full-source pair | Original seconds | Publication seconds | New/old |
| --- | ---: | ---: | ---: |
| Original first |217.590805|204.119412|0.93809×|
| Publication first |212.461816|206.053563|0.96984×|
| Per-role median |215.026310|205.086488|0.95377×|

The median observed saving is9.940s. The first pair saves13.471s and the reversed
pair6.408s; the benefit survives both orders, but its magnitude varies. All four
outputs match the retained118,227,421-byte qualified N2→N3 QBE. No historical
timing is reused. There are two observations per role, with warm filesystem
caches permitted. The comparison includes live
Base preparation and differs from the maintained cold source-to-executable metric
by excluding machine construction. Do not rename204.12s a new cold-build score or
combine it with historical build times. The shared experimental executable also
has its own layout; absolute seconds are not a same-image comparison to production.

There is no whole-build confidence interval or fresh upstream ratio. The result
earns a compact production integration and its native qualification; it does not
justify promoting the experimental shared image itself. The repeated Map
measurement was deliberately much cheaper than another image acquisition.

## Why the kernel results did not directly transfer

**Publication needs a real invariant, not just a replay flag.** The new private
dirty bit starts conservatively true. Ordinary canonical publication establishes
a coherent canonical book; childless logged insertion dirties it. The reviewed
checker mutations preserve that established property or restore the entry book
while preserving the result's memo, fresh and checked fields.
The original guards, error order, law/fill schedule and final canonicalization
remain. This eliminates a redundant operation only in clean runs; all dependent
checking and backend work remain. See the [invariant](../../research/phase156/publication-invariant.md)
and [independent audit](../../research/phase156/semantic-review.md).

**Sharing can add lifetime and continuation costs.** Neither flat-binding version
lost direct-worker admission: both already use generic scheduled entries. The
candidate's empty-environment guard adds a real `List.is_empty` call and Boolean
tests. Its local continuation grows from94 to131 assembly lines and from2,088 to
4,136 stack bytes. Retaining the use-set for its second consumer introduces
another keep and additional continuation transport. Those are static facts, not
an attribution of the entire Map timing difference. The original evaluates
`nc_uses` eagerly, so an unconditional shared binding would be a safe way to
isolate guard cost; it has not been measured here. [Machine audit](../../experiments/phase156/uses/analysis.md).

**The mutable dense kernel lacked important production obligations.** Actual
scalar facts require old-state observations, branch snapshots, joins, named
identities and full-width numeric locals. Seven of nine previously admitted
products contain branches. The fresh20-owner probe finds only four bodies without
the proposed shape restrictions, including tiny wrappers; five owners refuse
the retained producer itself. No dense optimizer was implemented or advertised
as a working speedup. [Eligibility evidence](../../experiments/phase156/dense/README.md).

## Correctness and failures

Independent source checking succeeds for the control API and shared native
request image. Eleven use-set controls compare complete lowering results.
Publication controls cover clean/dirty transitions, datatype runs, templates,
law/fill, errors and complete actual compiler/Map checker worlds.

The failed attempts are retained:

- Initial control preparation omitted the Phase154 codec dependency; checking
  rejected it. The successor includes the actual dependency.
- The first control harness used the wrong hosted source field and attempted a
  graph observation beyond its configured node bound. Neither is a compiler win.
- `controls02` incorrectly expected parsing a duplicate declaration to succeed.
  It remains marked failed. A separate receipt binds precisely that report/row,
  checks the exact parser refusal, and constructs a finite duplicate-event input
  to check the actual checker guard in both logging modes against the original.
- A pre-execution file-limit admission refusal started no compiler target.

The corrected composite gate is explicit; failed reports are never rewritten.
Source checking, source review and finite controls are not a BendTT theorem.
Exact QBE permits reuse of the downstream product under the same toolchain. It
does not establish new generated-program timings, general conformance or a fresh
upstream ratio. No expensive broad runtime or native self-reproduction campaign
is justified by the pilot results.

## Cost, retention and decision

| Work | Guarded seconds |
| --- | ---: |
| Independent source checks, including failed preparation |20.75|
| Semantic controls, including failed harness attempts/correction |68.04|
| One shared native experimental image |199.27|
| Actual request measurements, full-byte checks, pilot oracle acquisition |991.14|
| Total,11 guards |1,279.20 (21.32min)|

The dominant cost was measuring actual whole-compiler requests in both orders,
not a broad generated-program validation campaign. The shared image avoids
separate baseline/candidate acquisitions. No full self-hosting image, broad45
runtime suite or new installed release was built. Peak measured process-tree RSS
was1.53GiB; no OOM or target deadline. The5GiB disk reserve stayed intact.

The experiment adds498 lines of Bend prototypes/controls/harness, and **zero
lines to the maintained compiler**. The publication experiment includes reference
and load-only helpers needed for comparison; these should not be copied into the
production checker. The use-set proposal itself is only one extra code line, yet
its compiler-generated lifetime machinery matters more than that line count.

Decision: retain publication provenance for the next integration, defer guarded
use-set sharing, and reject the naive dense mutable-fact port. Integrate the
publication state into the existing loop with one maintained implementation,
preserving the original admission/fallback/finalization and audited mutation
invariant. Reuse the finite controls and unchanged-output gates; then acquire and
qualify the resulting native image before selecting it. The current qualified
Phase152 N2 and installed release remain unchanged.

For another high-headroom experiment, use a complete captured native consumer
from the compiler before constructing a large synthetic kernel. In particular,
charge ownership/lifetime and continuation transport when eliminating a repeated
analysis. These costs explain why fewer traversals can fail to improve execution;
their exact contribution still requires a dynamic measurement. No large storage
rewrite is justified by the dense toy result alone.

One controlled target lane is used. Independent agents audit publication
semantics, dense transfer, machine code, harness bindings and artifact retention;
they do not run competing compiler campaigns. Guard seconds exclude agent,
documentation and retention work; unavailable quota accounting is not invented.

Before the full-source screen, three closed Phase155 artifact sets were reclaimed
through the maintained archive verifier and exact file-level apply plans. All
1,315 files have verified existing recovery archives. Observed free-space recovery
was125,370,368 bytes (119.56MiB); the block-based planned release was120.26MiB.
Qualified images, active dependencies and the shared lock were excluded.

The four equal full-source QBE products were subsequently linked to their exact
retained oracle through journaled byte/metadata checks, preserving every pathname
and content byte while recovering472,940,544 allocated bytes. Those shared files
are immutable. All11 runs are sealed with outputs kept available; one deduplicated
verified capsule preserves the phase's exact bytes. No Phase156 artifact is pruned.

There is no demonstrated recursive research acceleration in this phase. Its
value is preventing fast kernels from becoming expensive, ineffective compiler
changes and establishing a reusable complete-request comparison for these paths.
