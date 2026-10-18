# Phase107: scalar facts after representation changes

The optional `nx_constant_propagate` pass exposes constant U32 values across
assignments, branch joins and loops. It runs in Bend over NxProgram and can follow
scalar field promotion. The hypothesis is [P107-012](../../experiments/phase107/P107-012-scalar-constants.md);
the compact contract is [constant-spec.md](../../selfhost/tools/performance/phase107/inline/constant-spec.md).
Existing pipeline APIs and the installed compiler remain unchanged.

Only known U32 values are tracked. Function parameters begin unknown; U32 locals
begin at the IR's specified zero. Assignment substitutes the old environment,
folds supported literal operations through the existing `nx_fold_bin`, then
updates the destination. Ptr/U64 facts remain unknown. A branch retains only
agreeing facts. Loop headers repeatedly intersect incoming facts with abstract
body exits, losing facts monotonically until stable; a count-plus-one bound
includes the final stable check. Exhaustion conservatively returns no facts.
Nested loops havoc assigned names during outer abstract transfer, then receive
their own bounded analysis during rewriting. This avoids exponential nesting of
fixed-point solvers while preserving zero-trip behavior.

Calls, allocations, loads, stores, frees and control-flow nodes remain in their
original positions. Only pure expression operands change. Private scalar facts
may survive effects because this IR has no address-of-local operation; load/call
results themselves become unknown. No branch is deleted and no memory fact is
assumed. Constant substitution cannot grow expression trees. Input/output
verification and a nonincreasing total node count gate publication. Limits are
4096 body nodes, 128 parameters plus locals, control depth 16, 256 functions and
65536 program nodes; capped functions retain their exact original bodies.

The [independent source review](constant-review.md) found no concrete soundness
bug. Its pin precedes three ownership-annotation fixes: repeated U32 bounds needed
`+fuel`/`+depth`. The first source attempt, bridge20, failed that checker gate;
bridge21 passed in 2.310s. That checked core was 213 lines at SHA256
`e9de89f34a695b82f7f2c3dbec81866968e42efb31c35604069f2203deddda51`.
The failed check remains evidence, not a successful qualification.

[`constant-audit01`](../../selfhost/build/phase107/constant-audit01/report.json)
passes 20 families: 12 direct fixtures and eight broader IR workloads after the
explicit fast-plus-promotion pipeline. The 96 frozen direct-fixture inputs yield
288 native outputs across GCC, QBE and Cranelift. The independent interpreter
performs 266 distinct executions, including the broader programs and two mutated
outputs. Controls cover constant loop invariants, changing induction variables,
multi-iteration fact loss, zero trips, nested loops, equal/differing joins,
returning arms, old-value snapshots, effectful results, wrapping U32, U64
nonpropagation and parameter initialization. Graph checks retain effect/control
shape. Independent observations also compare allocation/free counts.

Both deliberately wrong output graphs pass the structural verifier and fail the
unchanged semantic oracle: a stale cascade-loop fact yields 11 instead of 14;
assuming disagreeing branches agree yields 10 instead of 12. An invalid graph
with a missing variable is returned identically. These checks demonstrate useful
fault detection. They are not a full proof of constant propagation or of the
compiler; the inherited scalar-folder laws establish a narrower arithmetic link.
The separate [capacity matrix](../../selfhost/build/phase107/constant-capacity01/audit-report.json)
passes 18 structural controls in about 2.07s: below/at/above each of five size/depth
caps, invalid-input identity, a literal witness and effect-operand preservation.
The effect-operand witness records expected result 9 but was not executed as a
generated program in that matrix. These finite boundary controls do not establish
all possible cap interactions or broad source-language conformance.

The three-round [measure09](../../selfhost/build/phase107/measure09/report.json)
matrix completes 234 runtime records in 29.07s. Its selected route is the composed
fast pipeline, scalar promotion, then constant propagation; strength reduction is
not included. On owned `shared`, Cranelift takes 18.896ms against raw Clang C O2
at 10.729ms (1.761×); QBE takes 13.772ms (1.284×). These are repeated-batch process
times for the IR experiment. The matrix compares the complete composed route with
raw code and therefore does not isolate the incremental constant-pass benefit.
The representative memory slice remains directly constructed IR, not a newly
supported source-language allocation/ADT frontend or upstream Bend parity.

The preregistered [constant-pair01](../../selfhost/build/phase107/constant-pair01/report.json)
comparison isolates the additional pass using the already-built promotion-only
and promotion-plus-constant executables. Five alternating rounds cover 39 pairs
and 390 full-result observations. Machine-code `.text` is identical for 37 pairs,
so timing differences there receive no optimization credit. The two changed pairs
are the owned shared workload:

| Backend | Promotion only | Plus constants | Time ratio |
|---|---:|---:|---:|
| Cranelift |27.596ms|19.105ms|0.6923×|
| QBE |13.568ms|13.534ms|0.9975×|

Thus constant propagation reduces Cranelift execution time by 30.8% in this case;
QBE shows no meaningful additional change. The
[pinned object inspection](../../selfhost/build/phase107/constant-inspection01/report.json)
finds a hot-loop accumulator load/store through the stack in the promotion-only
Cranelift binary (`15d9`/`15f6`), replaced by register `r12` uses in the candidate
(`15b6`/`15d4`) with no hot-loop stack access. That supports the register-pressure
hypothesis; it does not independently attribute the gain to each changed
instruction or generalize this gain to every program. The result is a useful
composition: scalar replacement exposed facts that generic constant propagation
made visible to the machine backend.

Pass cost is separate from generated-code speed. In audit01's JS-hosted checked
API, constant propagation takes about 6.37ms on `shared` and 8.84ms on
`shared_borrow`. It adds 0.932s while returning `many` unchanged: the already-inlined
entry has 385 locals, exceeds the 128-variable cap, and refuses function analysis
after program verification/counting. This avoidable no-op overhead motivated the
final applicability preflight rather than a change to the optimization itself.

A final source-only revision factors `nx_cp_eligible` out of the existing
per-function gate and reuses it in an any-eligible-function preflight. If every
function exceeds a cap, `nx_constant_propagate` returns the exact input before
verification. This addresses the capped `many` cost without changing any admitted
function's optimization. Binding count is checked first. The predicate is only a
necessary condition: true does not assert valid IR or admission by the global
program caps. Frozen expectations cover all existing capacity fixtures, including
false for binding/body/depth overflow and true for global-cap-only overflow.
Bridge22 checks the revised source. The
[new capacity matrix](../../selfhost/build/phase107/constant-capacity02/audit-report.json)
again passes all 18 controls. The
[prefilter equivalence receipt](../../selfhost/build/phase107/constant-prefilter01/report.json)
passes 78 exact comparisons: JSON/C/QBE products for all 20 audit families plus
18 capacity outputs. All 20 explicit eligibility predicates match expectations.
This gate reuses the prior native evidence for identical products instead of
repeating 288 executable observations. It does not claim new native observations
or prove behavior beyond those products. The final source SHA256 is
`b8ddd581983f242d067e6c063d5511e7f25db76bd01285af2d530ade71a29516`.

The retained [kernel04](../../selfhost/build/phase107/kernel-measure04/report.json)
matched screen confirms the old no-op overhead on native as well as JS hosting:
on `many`, `promote`/`constant` complete-process medians are 97.172/147.130ms native
and 1270.522/2180.219ms JS. Its 18 native/JS output pairs agree exactly. Final
kernel05 timings for the preflight revision are recorded separately below.

[`kernel05`](../../selfhost/build/phase107/kernel-measure05/report.json) passes
18 exact native/JS output pairs over three rounds, completing in 10.36s. On
allocation-free, over-cap `many`, `promote`/`constant` complete-process medians are
90.355/90.161ms native and 1280.781/1272.382ms JS. The matched comparison shows no
meaningful remaining no-op overhead. Kernel04 versus kernel05 is a descriptive
cross-image comparison; the same-image policy comparison isolates the optional
pass cost. Useful analysis still costs time: on `shared`, the corresponding
medians are 4.336/4.575ms native and 98.873/108.317ms JS. On unchanged but eligible
`text`, they are 4.200/4.472ms native and 78.309/96.131ms JS. These are research
kernel process timings, not complete source-compiler or generated-program timings.

Native acquisition is separate: kernel04 cost 47.223s
([8.326s emission](../../selfhost/build/phase107/kernel-emit04-guard/process.json),
[38.897s linking](../../selfhost/build/phase107/kernel-link04-guard/process.json));
kernel05 cost 46.855s
([8.239s emission](../../selfhost/build/phase107/kernel-emit05-guard/process.json),
[38.617s linking](../../selfhost/build/phase107/kernel-link05-guard/process.json)).
Both use the pinned native acquisition route, after which repeat kernel requests
reuse the executable. The pass remains optional: this establishes a bounded
optimization composition with one measured backend win, not universal benefit
or a production-default decision.
