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

## Mid-cycle findings (19:58 UTC)

The private runtime-template path now generalizes ordinary calls and binary
destructuring, retaining checked ownership operations through Nx memory/control
generation. The closed callee catalogue rejects runtime imports masquerading as
owning calls. A subsequent source audit found a second verifier boundary: forged
ownership locals could collide with internal `ir_*` temporaries. Final sources
now require the exact allocated `p*`/`v*` namespace; actual source lowering never
produced the forged names. These are verifier fixes, not claims that model laws
prove native memory safety.

`search03` (compact/general) gives QBE single-context 0.7976× the original
fused-QBE training worker time. `search04` (stored-field seal omission) gives
0.7871× QBE and 0.6736× Clang against the same style of reference. The dedicated
five-round `stored-ablation02` shows only 0.9870× QBE versus compact/general,
below the frozen 3% promotion threshold; Clang is 0.9396×. Therefore the omission
is not selected as a QBE speed improvement. Its generated QBE list worker shrinks
768 to 614 bytes (203 to 163 static instruction sites), a distinct code-size
result. No fresh held-out tuning has occurred for these follow-up candidates.

The generalized route passes actual `List.tail`, `List.last.go`, and `nt_append`
controls, plus six call-shape exports including a labeled synthetic nonterminal
reconstruction witness. `last-search01` does **not** demonstrate a speed gain:
private Take2 is 1.0147× fused QBE across four diagnostic workloads. Ordinary-call
positive sources and separately made-reachable negative sources are distinct;
the mature frontend removes unreachable definitions, so the initial negative
transport failed on missing facts and was corrected without changing the positive
source/oracle.

Stored-field omission is supported by four independently checked model laws and
three welltyped semantic mutants, plus separately authenticated runtime writers.
A second, more ambitious candidate transfers an exclusive consumed RFC wrapper
directly to the newly stored field. Nine independent model laws establish the
resource-transfer contract modulo the newly chosen wrapper address, with six
semantic mutants. Source admission and physical allocator/alias observations
remain separate gates. The wrapper candidate is still being evaluated.

A diagnostic instrumented harness preserves all eleven original fixtures,
observations and lifetime gates. On the fused worker its 0.6902 s process time
contains 0.01972 s worker execution, 0.35145 s observation, 0.13105 s release,
0.11401 s setup and 0.05703 s lifetime accounting/close. This is a one-pass
accounting diagnostic, not a policy ranking. It explains why faster kernels
alone barely accelerate this evaluation loop.

A bounded typed-entry prototype now reads original checked types, not erased
`Absent` types: 14 actual source cases and nine explicitly labeled corrupted-data
controls pass. A reachable ill-typed result is rejected by the mature checker.
Whole closed-library admission and internally prepared native Base provenance
are the next gates; the entry certificate alone does not prove either.

## Integration checkpoint (20:17 UTC)

The five-round seven-candidate matched follow-up gives compact-general QBE
0.79093× fused-QBE worker time, stored-field QBE0.77763× and wrapper-spare
QBE0.81056×. The stored-field incremental gain is below the frozen3% threshold.
Wrapper-spare Clang is0.62160× fused-QBE. These are training observations; final
selection and the fresh eleven-case evaluation remain pending. Machine inspection
shows wrapper reuse reducing allocation while increasing QBE spills, motivating
one final combined/delayed-load ablation before freezing winners.

The first general native image (source04) passed the small exact-interface
typecheck but its full native emission hit the300s limit at600MB peak RSS.
No OOM or successful native-image claim. The newly embedded75KB exact Base
string is a hypothesis, not yet an attributed cause. Preserve the failed receipt
and diagnose cheaply before another complete acquisition.

Typed entry/closed-callee admission, namespace controls, ordinary owning calls,
23 independent local laws and14 model mutants are qualified at their stated
boundaries. The general live native request and its fresh semantic controls are
prepared, not yet executed successfully. Production selection stays unchanged.
