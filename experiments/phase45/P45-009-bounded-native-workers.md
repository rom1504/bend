# P45-009: bounded native calls with the same private fallback

Status: worker06's first screen was mixed. Worker09 adds proper native tail
transfers and passes the small and five deep composition controls at the default
stack size. Its two-point screen improves both workloads, with remaining gaps of
5.48× and 4.61× versus TypeScript. These are selected-workload results, not a
full-suite performance claim or a release-promotion decision.

The hypothesis is that direct JavaScript calls and scalar locals can avoid most
register-vector allocation and PC dispatch for shallow recursive work. Unbounded
native recursion is not an acceptable implementation: the existing continuation
machine supports input-dependent recursion without growing the JavaScript stack.
This experiment adds a bounded direct path and retains that exact machine as its
fallback. It applies to every admitted recursive component, with no source-name,
export-name or workload recognizer.

Worker06 is built from the frozen worker05 source plus the emitter change and a
model comment correction. It does not include the separate nullary admission or
private tagged-field experiments. Its selected equality-derived API SHA-256 is
`3bc1ab40c9a2ebba67a55d35b95e71acb4ce13dd6b9539c320a62087c91b632e`;
worker05 is `af2776fee3b04d0f448af890e86fbba11b2a2d119801e949cd2896d6636a0f50`.
The original checked-bootstrap API hashes are respectively
`68c431ecac4359ac945be5e64d94392bbede9cba3b368eadc12df7c1dc2ef209` and
`0a54c1d4f0519c7bcf579dbdf7ec84eec1441d817c4df5da41add5fcb750985e`.

The emitter creates one lexical `let $workerBudget=32` for the complete private
root graph. Each recursive entry first checks the shared budget. At zero it calls
its component's existing private machine. Otherwise it decrements the budget,
executes the direct body in a `try`, and restores the budget in `finally`. The
direct body reuses the same positional-call/scalar-local printer as acyclic
functions. Acyclic entries themselves remain unchanged.

The safety argument has four parts:

- Every native recursive entry consumes the same root budget. There is no reset
  at a function or component boundary. At most 32 such entries can be active.
- A machine's same-component calls remain PC/frame transfers. They cannot
  reenter the native path at budget zero. Downstream components also observe zero
  until the outer native entries unwind.
- Cross-component calls follow the proven condensation DAG. A component cannot
  appear twice along that portion of an active call chain. The remaining native
  wrapper/machine depth is bounded by the admitted component count, at most 96,
  rather than source recursion depth. This is a source-edge bound, not a bound on
  arbitrary externally initiated host reentry.
- Argument evaluation, private representations, public guards and generic
  fallback are unchanged. `finally` restores one decrement on normal return or
  an exception. Same-root reentry shares the remaining budget; it cannot silently
  grant a new allowance.

Independent static review accepted this proof and the emitter's reuse of the
reviewed direct printer. The diagnostic v3 composition controller checks shallow
native activation, deep machine activation, all lexical budgets restored to 32,
and balanced native-entry/finally counters. A one-shot callback injected inside
the native `try` tests throw and same-root reentry mechanics. That deliberately
instrumented fault is not evidence that an arbitrary effectful source program is
admitted by the private-worker proof. Clean source-oracle tests remain separate.
The controller's deep runs are intended to use Node's default-sized
`--stack-size=984`; completion must be read from their own receipts.

`runtime-worker06/report.json` passes 18 samples across two points and three roles
in 16.80 seconds. Each role has three fresh rounds, rotated order, at least 350 ms
warmup and a 150 ms sample target, on CPU 3 with Node 24.18.0. The timed roles use
`--stack-size=4096`, a 1,024 MiB heap and the campaign's process-tree memory guard.
The baseline role is unchanged Phase44, not worker05. TypeScript is pinned at
`018751270e800bc222a93dad7f257083ee53a5f7`.

| Point | TS ms | Phase44 ms | Worker06 ms | Phase44 / worker06 | Worker06 / TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| Map churn 128 | 0.807146 | 22.713903 | 9.120569 | 2.4904× | 11.2998× |
| Record aggregation 256 | 1.256006 | 100.700502 | 10.116960 | 9.9536× | 8.0549× |

The preceding worker05 run measured 7.262652 ms for Map and 11.055931 ms for
records. Comparing these separate runs gives approximately 26% slower Map and
8% faster records. These are screening observations, not a paired causal estimate
of the native-path effect. Within-sample drift is substantial: worker06 Map ranges
from −11.9% to −42.5%, and records from +9.0% to +24.6%. The first screen therefore
does not establish a general speed gain.

There is a measurable code-size cost. The complete acquired Map module grows from
209,623 to 245,987 bytes; records from 203,489 to 240,612 bytes. Recursive bodies
appear in both their direct implementation and machine fallback. No source text
is copied by an ad hoc rewrite: both are emitted from the same typed instructions,
but the duplicated generated code still affects compilation and optimization.

The initial decision was to inspect worker06 CPU/allocation profiles and compare
an alternative on the same saved inputs. Try/finally overhead, repeated exhausted
budget checks and larger generated functions were plausible explanations for the
mixed screen; the timings alone did not establish any of them.

The next isolated ablation, worker09, gives the native path proper same-component
tail transfers. Static inspection of worker06 finds six exact self-tail call sites
in Map and two in records whose native code calls the budgeted wrapper and then
immediately returns. This establishes unnecessary budget consumption at those
sites; it does not measure their dynamic frequency. A long-running tail loop can
therefore exhaust the shared allowance even when its pending non-tail depth is
small, leaving subsequent work on the machine path.

Worker09 emits one positional native function per recursive component, with an
entry PC and scalar locals sized for the maximum arity and destination register
across its members. An exact same-component Call+Return first captures every
argument into fresh temporaries, then updates input locals, changes the entry PC
and continues in the same frame. This preserves permutations, repeated operands
and different entry arities. Non-tail calls still use the budgeted wrappers;
cross-component calls still follow the proved DAG. Acyclic functions are unchanged.
No array or continuation frame is needed for a native tail transfer.

The wrapper keeps its existing budget/finally logic and calls the component's
native function positionally. Consequently each charged entry can occupy two
JavaScript frames, rather than one: the bound is at most 64 such frames plus the
bounded DAG/machine frames, still independent of input recursion depth. Tail-only
cycles should remain native even for deep inputs, so their validation must count
native tail transfers rather than require machine activation. The non-tail depth
controls must continue to prove fallback.

Worker09's selected equality-derived API SHA-256 is
`ff2c23761dd664ca2668c1bacffcae736cb0e159a578b3d4f0d249d0a94dbaa3`;
its original checked-bootstrap API is
`6069620318e353f3cd7c8c29158d452e9adc78c69d32c61d097c87d26e554e95`.
The isolated source derivation and parent hashes are recorded in
`native-tail-patch01/receipt.json`. Its acquisition emits 15 native component
functions for Map and 14 for records, alongside the same number of machine
fallbacks. There are 11 and nine static native-tail transfer sites respectively;
those counts describe emitted code, not hot-path frequencies. Complete module
sizes are 248,515 and 242,894 bytes, only 2,528 and 2,282 bytes above worker06.

The v4 diagnostic controls pass all 135 small independent oracle comparisons,
five public-data checks, five descriptor-mutation refusal checks and two
diagnostic fault/reentry checks. Each of five deep root suites also passes the
4,096 and 50,000 cases with two seeds under `--stack-size=984`. At depth 50,000:

| Independent fixture | Charged native entries | Native tail transfers | Machine entries | Saved machine calls |
| --- | ---: | ---: | ---: | ---: |
| Pure mutual tail cycle | 1 | 50,000 | 0 | 0 |
| Mutual non-tail arithmetic | 32 | 0 | 1 | 49,968 |

Both restore every lexical budget to 32 and pass shallow/deep/shallow replay.
This directly verifies the intended mechanism on independent source fixtures:
tail depth no longer spends the native allowance, while non-tail depth still
enters the stack-safe machine. Diagnostic counters are not timing evidence.

`runtime-worker09/report.json` completes 18 samples in 16.05 seconds using the
same short-screen protocol and unchanged Phase44/TypeScript roles described
above. Its same-run medians are:

| Point | TS ms | Phase44 ms | Worker09 ms | Phase44 / worker09 | Worker09 / TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| Map churn 128 | 0.790373 | 22.338640 | 4.333730 | 5.1546× | 5.4831× |
| Record aggregation 256 | 1.257469 | 100.673655 | 5.794293 | 17.3746× | 4.6079× |

Across separate runs, worker06/worker09 median ratios are 2.105× for Map and
1.746× for records; worker05/worker09 ratios are 1.676× and 1.908×. These support
keeping the transformation for broader qualification, but they are not a paired
estimate of its isolated speedup. Worker09 candidate samples are 4.209–4.419 ms
and 5.790–6.093 ms; within-sample drift still ranges from −15.7% to +13.4% for Map
and −11.9% to −3.7% for records. Repeated screens and profiles should qualify the
combined candidate before reporting stable or full-corpus gains.

The next general bottleneck to test is value allocation and representation.
Worker09 still builds ordinary tagged objects plus field arrays and retains
BigInt Nat values. Its private bodies also retain the guarded generic invocation
path at 20 static Nat-native call sites in each module, plus String.append and
U32.cmp sites. These facts justify the separate private-field and Number-Nat
experiments; they do not assign those costs a runtime percentage. In particular,
worker06 allocation-profile shares must not be presented as worker09 results.
Measure the representation changes next, then use new profiles to decide whether
remaining cost is construction, arithmetic, native-call adapters or machine
frames. Another dispatch-policy rewrite is premature before that evidence.

Raw receipts are under `selfhost/build/phase45/`: `source-worker06/`,
`checked-worker06/`, `qualify-worker06/report.json`, `preparation-worker06/`,
`runtime-worker06/report.json`, and the corresponding worker05 directories.
Worker09 uses `source-worker09/`, `checked-worker09/`, `preparation-worker09/`,
`runtime-worker09/report.json`, and the six
`worker-controls09-*-defaultstack/report.json` receipts.
`diagnose-worker06/` contains the separately instrumented profiles; their
execution times are not benchmark samples. Raw files are campaign evidence and
are not linked as if they were committed public artifacts.
