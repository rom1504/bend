# Active frontier: Phase78 installed; Phase81 residual-cost investigation complete

Installed genuine B2 `cc99ac9b…`, checked B1 `475610ea…`, source commit `6758bf2`.
[Report](../implementation/phase78/README.md), [qualification](../implementation/phase78/source-qualification.json),
[release](../implementation/phase78/release.json), [usage](../docs/self_hosted/NATIVE_COMPILATION.md).
Paired45 fresh C requests: B1 1.88678×→1.73205× upstream, B2 1.46354×→1.38187×;
8.20%/5.58% less time. Imports, explicit Bend Base, Clang and execution excluded;
upstream checks Base inside its request. No backend products or reused processes.
Non-IO held-outs improve less: B1 about2–4%,B2 about0–2%; functions65 remains1.74×
upstream with B2. Cold parity is not achieved.

Retain normalized type/field annotations, private checked layout validation,
whole-closure escape facts and omission of nonescaping factories/inlined intrinsic
entries, pre-compaction body reuse and lazy observer gates. +154physical/+115code
Bend lines, no new module (32,471/26,523 lines,132modules). Reject160 branch helpers,
compact identifiers, two tag classifiers and early observer planning for poor
benefit/complexity. Rejected snapshots and independent results stay preserved.

Native execution is1.06678× upstream/1.00162× paired Phase77 over12 families;
effectively unchanged with case changes −3.0% to+1.9%. All108 intervals qualify.
All23 raw JS sources remain byte-identical, preserving45 benchmark points.
Frontend36/native100/raw31/new14/word10/held-out2/JS9/threads28, B2 driver8,
self-check/B3,12 B1/B2 C outputs, installed/relocated42/24 and session CLI pass.
Seven reference failures/thirteen broader native API gaps remain explicit.

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

Next: rank removal of fixed text/book/report work first, then a per-function
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
