# P4-017 — Native parse/check lane feasibility

- Owner: lexer-analysis; root reviews the decision.
- Started: 2026-09-22, approximately 17:33 UTC; 20-minute feasibility limit.
- Objective: shorten the complete frontend validation workflow while preserving exact parse/check observations. The established 9.328-second warm 21-case B1 loop remains the ordinary developer baseline.
- Correctness/measurement: investigation only; no native parse/check implementation exists yet.
- Decision: investigate the cheapest obstruction before building a new binary.

## Claim and falsifier

Native execution could accelerate frontend work if it stops at the actual requested parse/check boundary and reuses a checked Base prefix across a finite batch. The existing native host only offers JavaScript program/library emission; relabeling those results as parse/check is invalid.

Prior [native measurements](../../implementation/phase2/native-host.md#controlled-small-workload-comparison) already found fresh native requests slower than cached B1 on small tasks (1.892–1.927s native versus1.591–1.851s B1), because native reparses/checks Base. Current source/backend may change absolute costs, so do not extrapolate a new speedup from those numbers.

Cheapest disproof: inspect current native/host gates and run representative existing capabilities and frontend observations. If mode changes cannot preserve exact diagnostic/origin/TODO/report behavior without a new request/result and cache lifecycle, stop the20-minute prototype rather than timing compile-mode as a substitute. A tiny successful fresh native compile can diagnose its existing setup floor, not establish parse/check speed.

## Required boundaries

Genuine parse stops after graph loading/elaboration with checked=false. Genuine check must preserve detailed diagnostic replay/location, owned/TODO/specialization gates and declaration stdout. Dependencies must be discovered/parsing-demanded in the same order, canonical aliases preserved, and check must not load foreign assets or demand an entrypoint. Native batch caching must key Base bytes/path/compiler, check Base once, use exact-prefix checks, and keep per-request trace/error/source state fresh. JSON/manifest inputs cannot supply unchecked compiler graphs.

No production module, frozen API or canonical private package will change. Any surviving wrapper would be checked Bend code plus byte/path host transport; no parser/checker delegation to JS/TypeScript. Root controls whether a larger implementation is worth its build and validation cost.

## Results

Pending feasibility observations. No benchmark conclusion or promotion.

## Completed feasibility decision

**No-go for the cheap mode-switch; defer a genuine finite native frontend batch to a separately assigned host-wrapper project.** Existing native adapter correctly refuses all12 selected frontend requests. Current B1/H agree on12/12 full observations; pinned TS agrees on12/12 acceptance/phase/checked/exit semantics and9/12 diagnostic/report texts. Existing native negative compile diagnostics are demonstrably plainer than current check diagnostics. No native frontend timing or full-suite speedup is claimed.

The detailed [feasibility report](../../implementation/phase4/native-frontend-feasibility.md) identifies seeded Base reuse, diagnostic/report parity, ordered source discovery and bounded result/batch transport as required work. It preserves known current-native small-compilation observations and earlier cached-B1 evidence without treating compile as check. No binary build, full sweep or production mutation was attempted. [Archive manifest](../../implementation/phase4/native-frontend-evidence/manifest.json) retains exact controls, fixture sources and consumed code.
