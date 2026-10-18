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

## Frozen selection and new heldouts (20:29 UTC)

The v2 protocol added exactly combined and delayed-load ablations before any
fresh performance heldout was executed. Five alternating rounds select the
simpler compact-general QBE policy:0.79427× fused-QBE on training. Stored-field
(0.98347× incumbent), combined(0.99708×), delayed(0.98602×) and wrapper
(1.02693×) do not meet the incremental magnitude/round-consistency rule.
Wrapper-spare is the Clang winner,0.62114× fused-QBE training time.

The single fresh eleven-case evaluation accepts both frozen winners: QBE
0.8051019× fused-QBE; Clang0.6581565×. QBE has four small per-case regressions,
maximum1.022085×. The original production denominator was also measured directly
in a separate five-round matched13-control comparison: general QBE0.8530908×
preserved production Clang reverse time (0.0119145s versus0.0139663s). Do not
multiply historical ratios or interpret these kernels as whole-compiler speed.

Generic Take/rebuild physical probes, wrapper-spare probes and the final delayed
physical overlap witnesses pass. Fresh six-case append and ten-case ordinary-call
heldouts also pass their exact independent oracles.

## Native acquisition diagnosis

A1,024-character literal emits in0.718s; the75,064-character literal exceeds45s.
Splitting into74 String helpers still exceeds45s (730MB peak). Packing the
identical ASCII bytes into18,766 U32 words in bounded helper bodies emits in
4.825s (147MB), builds through cproc/QBE in2.492s, and passes11 checked-API plus
14 actual-native equality controls, including same-low-byte non-ASCII negatives.
The implementation still compares every original codepoint and rejects extra
suffixes; no digest or weak cache-stamp trust replaces exact equality.

Source inspection identifies the65,536-word static image limit and literal
expansion into constructor syntax. The experiments demonstrate a size-sensitive
representation problem and a useful mitigation; they do not separately attribute
all time to parsing, checking, interning or dynamic-body lowering. Full general
image integration remains pending at this checkpoint.

## Native qualification complete (20:41 UTC)

Full source05 emits in148.836s and builds in87.720s guarded wall, with3.086GB
peak tree RSS. Native general qualification passes eight exact QBE/C products
and four refusals. Actual emitted closure workers pass36 independent observations
per backend; actual Base String.append passes20 per backend. The four prior
fixed contracts preserve all eight QBE/C products, and native reverse passes the
old13-case harness on both backends. Ordinary source-to-QBE requests use no
JavaScript, Clang or cproc; one-time acquisition still uses C/cproc/QBE.

The first native worker runner failed before execution because Clang was absent
from PATH. Its receipt is retained; rerunning with the pinned Lean toolchain
path completes. No evaluator or semantic expectation was changed. The native
source and machine image are frozen for this phase's final transfer checks.

## Final transfer and context-boundary diagnostic

The fixed selected policy improves compiler nt_append medians to0.9215,0.7180
and0.6246 times fused-QBE on its three predeclared shapes, but recursive Base
String.append regresses consistently to1.1584 and1.0519 times fused-QBE.
`native-transfer01` preserves both the positive and negative observations.

The separately preregistered [P110-002](P110-002-context-boundary.md) removes
repeated context getters inside closed owning calls while retaining checked
public wrappers. All18 workers pass234 original observations, with31 Bend
controls and54 malformed-certificate refusals. Five paired rounds improve
String.append QBE worker medians by about10–15% versus the current compact
baseline. There is no same-campaign fused denominator and no new native-image
selection. A synthetic eight-owner gate adds24 observations and verifies QBE's
eleven-private-argument calling convention; Clang optimizes its private ABI.

Compiler/runtime changes stop before21:30. Final work is evidence sealing,
source/resource accounting and documentation. The phase report retains rejected
policies, the literal acquisition cliff, development gate failures, exact
qualification boundaries and unchanged broad production metrics.
