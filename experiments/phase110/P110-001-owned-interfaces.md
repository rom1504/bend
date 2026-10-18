# P110-001 — Preserve ownership facts across the native runtime boundary

Design: [Phase110 ambition ladder](../../design/phase110/ownership-laws-and-search.md).
Baseline: `7fc45f3`. Initial design commit: `5b7e903`.

Hypothesis: constant constructor/field roles and atomic multiple-result transfers
remove helper-interface overhead, independently of changing the machine backend.
Follow-up: lowering generic ownership primitives as structured IR exposes common
last-owner work to QBE while retaining actual runtime fallback behavior.

Initial evidence, 2026-10-18 (intermediate; campaign continues):

- All twelve initial policies/backends pass eleven frozen training graphs.
  The fixed three-round search selects specialized QBE (0.9515× fused QBE) and
  pair Clang (0.8827× fused QBE). Held-out ratios are 0.9135× and 0.8772×,
  respectively; all eighteen held-out semantic observations pass. The tiny
  four-cell long-head case has a noisy worker clock and remains in that fixed
  aggregate. These are selected worker kernels, not a full compiler ratio.
- Actual QBE pair lowering stores/reloads the RAX/RDX return pad; Clang/GCC do not.
  Source specialization does not automatically eliminate lower-level ABI costs.
- Ten safe laws independently pass BendTT/Lean. Five well-typed semantic mutants
  are rejected by unchanged laws. The actual selector is source-connected;
  physical C heap correspondence remains a separately tested obligation.
- Real Base tail and unchanged compiler append lower and execute with ordinary
  owning calls; six builds each pass their independent graphs. Append includes
  physically shared arguments. No source-name optimization rule is added.
- A private structured runtime-IR prototype passes its initial eleven graphs on
  ten worker configurations. The follow-up calibrated search gives QBE 0.8260×
  and Clang 0.6990× fused-QBE time across the same seven training workloads.
  Fresh physical-alias/allocator-boundary qualification is pending at this point.
  Unique deep-list QBE ratio is 0.5989×; shared cases remain around parity with
  the incumbent. The admitted runtime is explicitly single-context/single-thread.
- The original search takes 247.68s, only 6.734s of which is timed worker work.
  Calibrated repetitions reduce the ten-choice follow-up to 30.52s. Candidate
  counts differ; do not call this a measured equal-work eightfold speedup.

[Intermediate evidence index](../../implementation/phase110/evidence/milestone01.json)
pins complete raw reports. Later report must separate the original frozen search,
follow-up reused regressions, fresh supplemental held-outs, promotion and failure
receipts. No selected production compiler change or recursive-acceleration claim.
