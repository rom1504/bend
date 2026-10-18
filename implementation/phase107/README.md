# Phase107 — native IR campaign (in progress)

The campaign began 2026-10-18 06:37 UTC, with a three-hour horizon. The installed
native compiler remains unchanged. The experimental bridge now lowers actual
checked Bend source to the shared native IR; QBE provides a third backend using
GNU tools without Clang. Parsing/checking and IR lowering execute Bend-written
compiler code hosted in JavaScript. This is not yet a native compiler self-hosted
through the new backend.

First admitted source snapshot: `selfhost/build/phase107/bridge05/source.bend`;
source/API gate `bridge-check05/process.json` passed in1.392s. The exact snapshot
contains the lowerer, bounded inliner, verifier and all three emitters. Five
source families pass: arithmetic/helpers, Boolean branches, erased arguments,
self-recurrence, and exact ASCII classifier definitions extracted from the real
compiler lexer. Two valid source families deliberately refuse the experimental
route (Nat and Nat-counted shifts). No fallback silently emits legacy functions.

The initial three-round paired screen, `measure02/report.json`, completed in
32.424s with78 builds,312 independent interpreter observations,936 native output
checks and234 runtime observations. Inlining speeds Cranelift's real-source
classifier1.83× and synthetic text1.26×; QBE classifier1.76×. The many-function
chain gains little because the first pass refuses deep dependencies. These are
small experimental programs, not a new full-compiler or upstream comparison.

The QBE backend's separate finite gate passes1,938 native observations across
three backends; see [backend details](backend-options.md). The
[inlining report](inlining.md) describes semantic scope and pending extensions.
All measurement configurations remain experimental; no production promotion.

Next: deeper bounded purity summaries, tail recurrence, a usable complete
source-to-executable command, complete iteration measurements, and evidence-led
incremental reuse. Final evidence capsule and full interpretation follow.

## Second controlled screen: shared optimization closes a measured gap

The checked `bridge09` adds entry-first bounded inlining and integrates self-tail
lowering with optional QBE entry fusion. `artifacts02` preserves the raw policy
and applies all three only to the candidate. The three-round `measure03` batch
passed312 independent model cases and936 native output checks across13 programs
and three backends, then recorded234 runtime observations in30.92 seconds.

The128-helper chain improves5.62× with Cranelift and5.05× with QBE; the candidate
runtimes are1.01× and1.00× the raw Clang-O2 reference. Real-source QBE arithmetic,
branches, classifier, erasure and recurrence improve2.01×,1.80×,2.53×,1.75× and
2.27× respectively. Their ratios to the raw Clang-O2 reference are1.14×,1.10×,
1.18×,1.20× and1.05×. These are this focused IR/source set, **not** a new full
compiler or45-program upstream result. Tiny-program ratios include the common
entry/checking loop. Shared-memory workloads remain substantially slower.

The larger inline expansion costs473ms in the JS-hosted Bend optimizer for the
128-helper graph and retains5471 total IR nodes. This cost is not hidden behind
the runtime win: retaining and reoptimizing now-unreachable helper bodies is the
next explicit cost experiment. The source examples each spend1.4–11.7ms in the
optimizer. `audit02` separately passes108 transformations/696 finite input pairs
for all three inline policies, plus three detected emitted-IR semantic mutants.

Native frontend source01 checked and emitted its bootstrap C using the installed
Bend compiler in110.886s, peak772.3MiB. Its21MiB C artifact has not yet earned
executable admission. This is a one-time image acquisition cost, kept separate
from ordinary source-to-QBE requests.
