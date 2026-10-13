# Active frontier: Phase82 installed; fixed native request costs reduced

Installed genuine B2 `098320e8…`, checked B1 `8a400725…`, source commit `070064e`.
[Report](../implementation/phase82/README.md), [qualification](../implementation/phase82/qualification.json),
[release](../implementation/phase82/release.json), [usage](../docs/self_hosted/NATIVE_COMPILATION.md).
Paired45 fresh C requests improve5.10% B1/6.15% B2 against simultaneous Phase78:
1.76295×→1.67299× B1 and1.41542×→1.32836× B2 upstream. Historical Phase78's
qualified1.732×/1.382× remains a separate run. Imports, explicit Bend Base,
Clang and execution are excluded; reports enabled, no reused process.
Held-out small/functions65 B2 improve20.7%/15.1%, to0.826×/1.483× upstream.
Cold parity still needs24.7% less B2/40.2% less B1 time on the three-source loop.

Keep canonical runtime chunks produced by the Bend scanner and host-verified by
exact asset/runtime hashes. Prefix/payload marker fallbacks and raw/custom API
behavior stay intact. The owned annotation merge carries its exact source bound
instead of scanning the mirror index/declaration list again. No semantic host
compiler or new optimizer framework. +69 physical/+53 code Bend lines,132 modules:
32,540/26,576 lines. Source/driver equal selected compiler04; compiler05 deferred.

Reject the extra private erasure consumer despite exact preparation products:
only1.68% B1/1.38% B2 over compiler04. Preserve both patches and actual B1/B2
images. Full per-function representation replacement remains open; do not label
this small consumer experiment a completed IR fusion. Two selected B2 profiles
show no template-scanner samples; source processing, report/index work,
normalization and native planning remain. Read the current report before a rewrite.

All159 clean experimental requests retain C/reports. Renderer250/transport5,
frontend36/native100/raw31/new14/word10/heldout2/threads28, B2 driver8,
self-check/B3 and installed/relocated42/24/session5 pass. Both stages emit all12
benchmark C files exactly; all23 JS sources (45points) remain byte-identical.
Reuse prior native1.067× upstream execution evidence, not a new runtime clock.
Seven reference native failures/thirteen broader native API gaps remain explicit.
264 guarded jobs take1,363.5s; peak RSS1.61GiB, no OOM or timeout. No quota claim.

Prior Phase79–81 findings follow; those phases left Phase78 installed at their
completion. Their raw evidence and rejected prototypes remain historical inputs.

[Phase79 report](../implementation/phase79/README.md): whole-library and selected-worker
prepared products pass exact-C screens but save only 3.49%/5.15% against their
ordinary modes, below the 15% discriminator. Added preparation is 3.3 s and the
artifact is 2.94 MB. Two profiles confirm annotation/erasure savings offset by
decode, GC and context work. Non-IO held-outs are unchanged. Reject both, stop
observer-cache expansion, and restore exact Phase78 production source. Release
verification passes after rollback. All prototypes/failures remain preserved.

[Phase80 report](../implementation/phase80/README.md): whole/live-only checker type
retention saves0.6–1.3% on the IO-based B1 screen but the live-only variant regresses
small17.4%/functions65 8.9%; reject and restore. Exact-argument counters expose
repeated different-binder occurrence walks. List and integer-set body summaries
pass15,678 generated comparisons each; final set summary saves2.15% on45 fresh
requests, with small unchanged/functions65 1.31% slower on18 held-outs. Defer
both summary patches. All147 clean requests and four diagnostic requests preserve
C. Five checked-B1/frontend36 builds pass; no prototype B2 or release claim.
Production source/driver/dist are unchanged and final release verification passes.

[Phase81 investigation](../implementation/phase81/README.md) adds54 clean requests,
15 CPU profiles,3 allocation profiles and5 internal-region requests; all77 outputs
remain exact. Unchanged-source fresh ratios1.722x/1.309x are a new diagnostic
screen, not an improvement over the qualified1.732x/1.382x. Functions65 stays1.72x.
B2 final native-stage time is near upstream emission on IO sources, but has large
fixed cost on small sources. Template scans cost43–66ms, five freshness-bound
queries25–50ms and three final-book constructions17–19ms in separate diagnostics.
These overlap other stages and are not additive savings. Numeric sampled
allocations:B1 538MB,B2 138MB,TS148MB. B2 text helpers account for about50MB.

The Phase81 recommendation was fixed text/book/report removal, then a per-function
native representation that replaces annotation/erasure/reconstruction and feeds
multiple consumers. Resolve symbols once where measured. Cold parity still needs
about42% less B1 /28% less B2 time on the qualified three-source loop. Combined
25–35% B2 reduction is a target to falsify, not a measured forecast; held-outs may
need more. Whole typed graphs, eager products, generic memo tables and node IDs
alone have no demonstrated large net gain. Read Phase79/80 before repeating them.
New primary-source research compares V8, Cranelift, Go, Zig, LLVM and Lean. No
production edits, candidate promotion or implementation gain in Phase81.

One guarded CPU3 tree,2GiB RSS/4GiB available floor,Node1GiB heap/4MiB stack.
No agents or PR comments. Preserve unrelated inherited Phase6/68 work and all
sealed historical evidence. Phase78–80 evidence is sealed and linked from the respective reports.
Historical frontiers remain in Git history and the linked Phase73–77 reports;
consult them before repeating a rejected hypothesis.
