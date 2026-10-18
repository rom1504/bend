# P107-012: propagate scalar invariants after representation changes

Scalar field promotion exposes ordinary U32 locals, but backend code can still
spill a counter that returns to its initial value on each loop iteration. Test a
general constant-propagation pass rather than a reference-count-specific rewrite.
The same pass should simplify scalar snapshots, branch agreements and arithmetic.

The lattice records only known U32 values; absence means unknown. Parameters start
unknown and U32 locals start at their IR-specified zero. Assignment substitutes
known scalar values and applies the existing exact wrapping-U32 literal folder.
Loads, calls and allocation remain at their original statement positions; their
results are unknown. Pointer/U64 variables never become constant facts.

At branch joins retain only agreeing facts. For each loop start from preheader
facts, repeatedly intersect the current header with abstract body exit until no
facts disappear. Facts never change value or reappear in that iteration, so the
initial known-fact count plus one bounds convergence; exhaustion yields unknown.
Only then rewrite the loop condition and body. Nested-loop abstract transfer
forgets all assignments in that nested loop, avoiding exponential nested fixed
points; its eventual rewrite computes its own safe header independently. Preserve
control-flow shape, effect ordering and every zero-trip path. No load hoisting,
branch deletion, ownership inference or memory-layout assumptions.

Freeze full-result controls before target execution: invariant counter, changing
loop condition, zero iterations, equal/differing branch joins, old-value snapshots,
load/call results, wrapping overflow, nested-loop assignment and U64 nonpropagation.
Input/output structural verification, finite source caps and nonincreasing IR node
counts gate publication. Test deliberately stale loop and branch facts against the
same independent oracle. Qualify native outputs before interpreting backend gains.
If review/checking cannot finish within this bounded slice, leave the pass prepared
and unintegrated. Existing pass behavior and installed compiler defaults remain
unchanged. This is finite validation, not a proof of global compiler correctness.

## Paired executable comparison

After the three-round matrix screen, freeze the existing measure07 (promotion) and
measure09 (promotion plus scalar constants) binaries. Five alternating rounds of
all39 backend/workload pairs compare identical args, repeats and full expected
results. Hash ELF text to distinguish actual machine-code changes from noise;
unchanged text receives no optimization credit. This is a focused incremental
comparison, not a new upstream or production-default result. Retain all samples
in `constant-pair01`. The shared-IR policy remains optional pending outcomes.

## Skip programs with no eligible function

Kernel04 repeats the unnecessary no-op cost on the inlined helper-chain graph,
whose only function exceeds the existing 128-binding limit. Before another source
revision, preregister a necessary-condition preflight: if no function satisfies
the existing binding/body/depth caps, return the exact original program before
verification. Extract one eligibility helper shared by preflight and per-function
rewriting so their rules cannot drift. The cheap binding limit is checked first.
This is identity refusal, including on invalid input, not a validation shortcut.
Global function-count/program-node gates remain unchanged. Recheck existing cap
predicates, correctness controls and exact prior outputs before a matched native/JS
kernel comparison. Preserve kernel04 and all previous evidence.

## Qualified outcomes

The original checked pass passes 12 direct semantic families, eight composed
workloads, 288 native outputs and 266 independent interpreter executions in
[`constant-audit01`](../../selfhost/build/phase107/constant-audit01/report.json).
Both typed stale-fact mutations are detected. The five-round
[`constant-pair01`](../../selfhost/build/phase107/constant-pair01/report.json)
comparison preserves complete outputs across 390 observations. Of 39 executable
pairs, 37 have identical machine-code text; they receive no improvement credit.
The shared-workload Cranelift pair drops from 27.596ms to 19.105ms (30.8% lower),
while QBE remains effectively unchanged (13.568ms to 13.534ms). Pinned assembly
inspection finds that the candidate removes hot-loop accumulator spills, supporting
the scalar-facts/register-pressure hypothesis within this workload.

The final necessary-condition preflight passes bridge22 checking,
[`capacity02`](../../selfhost/build/phase107/constant-capacity02/audit-report.json)'s
18 controls, and [`prefilter01`](../../selfhost/build/phase107/constant-prefilter01/report.json)'s
78 exact product comparisons plus 20 predicate expectations. Identical output
products reuse their prior finite native/semantic evidence. Kernel04 retains the
old complete-process cost on `many`: 97.172/147.130ms native and
1270.522/2180.219ms JS for `promote`/`constant`. Kernel05 measures the preflight
revision separately; generated-code gain and optimizer overhead remain distinct.
See the [implementation report](../../implementation/phase107/constants.md) for
exact scope, limitations, receipts and final kernel results. The pass is optional;
installed compiler behavior and broad self-hosting claims remain unchanged.

[`kernel05`](../../selfhost/build/phase107/kernel-measure05/report.json) passes
18 native/JS output pairs over three rounds in 10.36s. On over-cap `many`, matched
`promote`/`constant` medians are 90.355/90.161ms native and 1280.781/1272.382ms JS:
no meaningful no-op overhead remains. The preflight changes pass selection cost,
not generated code. Eligible graphs still pay for analysis; `shared` costs
4.336/4.575ms native for those policies. The native source05 image costs 46.855s
to acquire once; that is separate from research-kernel request times. Historical
kernel04 evidence remains intact, and cross-image timing differences receive no
isolated speedup attribution.
