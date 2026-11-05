# Phase164 — mixed direct compilation, composition and recursive state

The experiment now handles ordinary mixed programs and compiles itself, but it
does **not** establish a meaningful cold-build improvement. The larger proposed
shortcut is therefore not promoted. A much smaller direct-import interface
captures the clearest generated-program gains, and a compact explicit index
reconstruction path gives a small measured compiler-kernel gain.

Start: `d708eef`; design committed as `41ac5a2`. Qualified Phase152, maintained
JS/C/QBE source, protected declarations and installed selections remain unchanged.
All transformations are Bend implementations. Host tools assemble snapshots,
transport bytes, compare complete results, inspect machine code and measure time.

## What the larger attempt established

Phase163's closed route rejected six of eight unrelated computations and could
not compile its IO entry. This phase adds a mixed direct/generic route: eligible
workers get genuine verified adapters before generic body construction; other
workers keep their complete original lowering. Factories, ownership facts,
effects, stack safety and independently checked final worker obligations remain.
It does not fabricate empty originals or turn arbitrary recursion into C calls.
See [method](../../experiments/phase164/hybrid-method.md),
[independent audit](../../experiments/phase164/hybrid-audit.md) and
[retained-original contract](../../experiments/phase164/retained-original-audit.md).

The conservative route executes ten original frozen native45 IO programs with
independent exact value/count checks. Its broader-discovery and retained-original
variants pass 35 structural controls and produce exactly the conservative QBE
on local-fold, tree-bitonic and Map/Set. Independent upstream checking accepts
the native source before reporting its 3,748 unsafe/foreign-dependent definitions;
that expected exit 1 is retained, not called independent BendTT proof acceptance.

| Measurement | Original | Candidate | Interpretation |
|---|---:|---:|---|
| Same experimental source, complete image acquisition |201.931s|201.271s|Single observations, effectively neutral|
| Continuation segments in that compiler |44,060|39,460|10.44% fewer|
| Native direct functions |2,096|2,096|No new coverage in this count|
| QBE stream |109.887MB|104.740MB|4.68% smaller|
| ELF |17.379MB|16.483MB|Smaller is not equivalent to faster|

Both acquisitions use the same **1,556,351-byte** private compiler source.
The qualified **249.222s** historical observation uses a different
**3,085,157-byte** source. Comparing 201 with 249 as a speedup would be invalid.
The private CLI supports ordinary live/cache source requests; it does not
replace the maintained session/batch interface.

N2 emits its own complete source in **179.548s**, excluding QBE/assembly/linking.
All 104,739,601 emitted bytes reproduce the predecessor stream exactly by
SHA256. The first 64KiB arrives after 146.399s; remaining output and teardown
take about 33.15s. Those transport boundaries are not a frontend/backend profile.
This is self-reproduction evidence, not semantic proof or a newly qualified release.

Small fresh-process source-to-QBE requests improve only 1–2% with N1. N2 is
about 5% faster on local-fold/tree, but **5.6% slower on Map/Set**. These are two
reversed pairs with exact independent hosted QBE per role. The complete results,
sample counts and identities are in [mixed findings](mixed-findings.md) and
[mixed metrics](mixed-metrics.json). No new upstream ratio or broad geometric
benchmark score is claimed.

## Keep the useful capability, question the extra machinery

Machine inspection found unchanged arithmetic and String worker bodies reached
through fewer scheduler boundaries. That suggested an independent **100-line
imports-only** experiment retaining the original generic lowering, optimizer,
all independent verification and capability decisions. It publishes verified
public workers through the existing ordinary-call ABI and avoids redundant
registry candidate work. Eighteen structural/ABI controls pass.

| Original frozen IO program | Baseline / imports-only median | Runtime ratio |
|---|---:|---:|
| Mandelbrot |708 / 601.5ms|0.8496×|
| Unicode text |270 / 236.5ms|0.8759×|
| Edit distance |252.5 / 252.5ms|1.0000×|

Two reversed pairs each; exact independent outputs pass. These bounded runtime
screens reproduce the larger route's useful gains without crediting body omission
for them. The imports-only route has not had a native compiler acquisition or
broad qualification. Its hosted backend times are mixed and cannot predict a
general cold-build gain. Existing direct-to-direct edges can acquire an extra
forwarder, another reason to measure actual code rather than helper counts.
See [machine explanation](../../experiments/phase164/runtime-mechanism.md) and
[imports audit](../../experiments/phase164/imports-only-audit.md).

## A real compiler-hot alternative, with a cheap rejection loop

Persistent insertion `p131i_insert` reconstructs a parent after returning from
its child, preventing admission to the ordinary direct DAG. We implemented a
64-line additive zipper: direct tail traversal records exact parents/siblings;
one unchanged terminal leaf/join/legacy operation runs; a direct tail loop rebuilds
the result. Arbitrary malformed trees and paths deeper than 32 remain supported.
There is no new native recursion limit or assumed canonical-tree invariant.

The initial List-plus-frame representation replaces scheduler work with two
temporary objects per level. A second version combines these into one recursive
four-field frame, matching the rebuilt node's width. Existing pooling may benefit;
actual in-place allocation reuse has not been dynamically counted.

| Complete build + overwrite + all-field consumption | Original | List zipper | Original | Fused zipper |
|---|---:|---:|---:|---:|
| Normal name hashes |245.17ms|243.98ms|244.33ms|231.21ms|
| 256 hash buckets |518.73ms|523.87ms|522.17ms|514.08ms|

Each native measurement uses eight fresh 4,096-key maps and four reversed
process pairs. The first version is effectively neutral; the fused version saves
**5.37% / 1.55%** in these complete computation slices. Both traversal and unwind
have actual direct machine workers. This does not establish a whole-compiler gain.
The small effect does not justify another full compiler acquisition this cycle.

Both variants pass 17 finite controls, 336 rich canonical/legacy insertion
sequences, 16 complete malformed/alias observations and four complete workload
trees: **356 host deep comparisons per variant**, plus exact runtime results.
The fused native control executable also passes all 17 controls, including
retained old roots and a 65-level noncanonical chain. The current insertion is
the oracle: the older two-pass helper differs on some malformed trees and would
be an invalid universal reference. Three source-check failures (match placement,
affine fixture annotation and definition order), plus an early dependent harness
refusal, are preserved. See [audit](../../experiments/phase164/index-zipper-audit.md)
and [experiment](../../experiments/phase164/index-zipper.md).

## What this means for five seconds

The large route removes only a limited portion of already-redundant control
representation. Frontend work, direct candidate construction, symbolic facts,
ownership, most optimization, rendering and machine construction remain. The
previous diagnostic frontend alone was 66.52s; deleting generic body construction
cannot produce the desired approximately 50× improvement. Its timings are not
clean intervals to subtract from these acquisitions.

The bendc comparison also has an important contract difference: its ordinary
non-tail C calls use large guarded virtual stacks, not arbitrary-depth stack-safe
execution. Our backend already has stack-safe local continuation regions; this
is a coverage/composition problem, not an entirely missing mechanism. See the
[source-grounded comparison](../../experiments/phase164/non-tail-comparison.md).

The next high-information step is to inspect the exact existing-region refusal
on insertion and typed verifier-table reconstruction, then test a complete
checker/optimizer request. If that boundary is narrow, improve the existing
region mechanism rather than proliferating source rewrites. In parallel, the
[analysis-store audit](../../experiments/phase164/large-headroom.md) identifies
repeated generic records, hashing and fact reconstruction as a distinct measured
lead. Prior numeric-identity and compact-App limits remain relevant; none of
these observations currently supports a credible five-second forecast.

Keep the small compositional interface and fused-state experiment for subsequent
integration work. Defer promotion of the mixed route, a wholesale compiler rewrite,
another native qualification campaign and an autonomous policy-search system.
No causal recursive research acceleration has been demonstrated.

Reproduction, exact evidence and research/resource cost are recorded in
[reproduce.md](reproduce.md), [evidence](evidence/README.md), [cost.json](cost.json)
and [retention.json](retention.json). Experimental source is explicitly separate
from the one maintained compiler; no unsupported lane counts as a pass.
