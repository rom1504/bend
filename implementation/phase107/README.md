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
