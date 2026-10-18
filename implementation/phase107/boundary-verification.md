# Optional pipeline with boundary verification

The checked Bridge15 prototype passes 69 exact-product comparisons and reduces
median JS optimization time by 3.57–9.70× on four paired cases. These are warmed,
same-process measurements; native optimizer timings and the remaining planned
boundary/fault controls are pending. The hypothesis and contract are in
[P107-008](../../experiments/phase107/P107-008-boundary-verification.md).

[`inline/pipeline.bend`](../../selfhost/tools/performance/phase107/inline/pipeline.bend)
adds 80 lines and 12 functions, with no new IR/type, verifier, transformation engine
or production change. Append it after the existing Phase107 optimization modules;
export only `nx_pipeline_fast`. Existing standalone pass files remain unchanged.

The new wrapper performs one input verification and, for valid input, one final
verification using the existing `nx_r_finish` fallback. Private orchestration
reuses tail, inlining, reachability, memory and folding cores. It keeps every
capacity/eligibility limit and exact deterministic pass order. Demand expansion
still sees original callee bodies and shares entry-returned fuel with remaining
functions. Both internal prunes preserve direct and address-taken references.

The wrapper skips intermediate verifier calls; it does not cache or weaken the
verifier. Exact equivalence depends on each internal core preserving validity.
The checked composition is retained as the reference, with intermediate validity
and complete products required by
[`pipeline-controls.json`](../../selfhost/tools/performance/phase107/inline/pipeline-controls.json).
Malformed input is unchanged; a malformed final candidate falls back to the
original. Neither behavior constitutes a proof of whole-pipeline semantics.

Source/data checks found no new definition-name collisions in Phase106/107; the
178-function private transformation closure reaches no public guarded pass or
verifier. Root then checked Bridge15 and ran the
[qualification harness](../../selfhost/tools/performance/phase107/pipeline-audit.mjs).
The [closed report](../../selfhost/build/phase107/pipeline-audit01/report.json)
records 82.493 seconds for the complete audit.

## Exact-product results

All 69 programs match the checked composition as complete IR objects and JSON:
61 valid inputs and eight invalid inputs. The corpus includes 11 constructed
workloads, scalar/tail/reachability/leaf/memory fixtures, eight native-source IR
graphs, and seven constructed malformed graphs alongside `tail_dead`. The
reference's seven stages pass 427 intermediate validity checks. All 61 valid
results emit identical complete C and fused QBE text; invalid results stay
unchanged and are not emitted or executed. Input nonmutation checks pass.

Six empty native-source refusal products are retained as historical refusals,
not transformed or counted as new refusal executions. This audit executes
optimizer/emitter functions only: it does not rerun independent result or memory
oracles for generated programs. Equality is to the checked pipeline, not a proof
that either route is semantically correct for every program.

## Paired JS optimizer timings

| Case | Checked median (ms) | Fast median (ms) | Checked / fast |
| --- | ---: | ---: | ---: |
| many | 8,626.527 | 889.649 | 9.70× |
| text | 9.288 | 1.176 | 7.90× |
| shared | 10.457 | 2.927 | 3.57× |
| native-source branches | 6.896 | 0.887 | 7.78× |

Each of three rounds uses both checked/fast and fast/checked order, six samples
per policy per case, 48 calls total. All timed complete JSON outputs match the
qualified result. Both policies run in the same JS process/image after the
qualification corpus; these are warmed timings, not isolated cold requests.
Individual samples remain in the report; for example, checked `many` ranges
7.343–10.065 seconds, while fast ranges 0.871–1.025 seconds.

The timed checked route calls the seven public passes, including their own
validation, with an outer input guard and final verification/fallback. The fast
route uses its input and final checks. Additional diagnostic intermediate
verification, cloning, serialization, emission and filesystem writes are excluded
from the timing interval. For invalid inputs, the matching outer guard is
essential because standalone folding itself is unguarded. The earlier kernel
measurements have different boundaries and are not the denominator here.

This measures reduced optimizer/research-loop work with identical emitted code.
It establishes neither a generated-program speedup nor a production compiler
speedup. Native-host paired measurements have not yet been recorded in this
report. Final verification, eligibility scans, node counting, renaming and
serialization remain costs.

## Remaining controls and evidence identities

The full planned controls are not complete. The existing 257-function refusal
fixture passed; explicit 255/256-function, 65535/65536/65537-program-node and
4095/4096/4097-memory-body boundary matrices have not run. Direct private-helper
versus public-pass comparisons and an injected invalid final candidate have not
run either. Intermediate checks here inspect the public reference's outputs,
not hidden candidates before its internal fallback. Source limits are reused
unchanged; this and finite equality do not prove internal validity preservation.

The immutable report binds its method, image, source controls and every complete
output. Key SHA-256 identities are:

- Report: `824bc65b434ca4751d12849acf71bf977ac60979c032fee5a7784555fc7256f2`.
- Bridge15 API: `0603ff4c58abbc953e4d05bc311976a37f87de7ce49473848aa7e29f23bbd9ae`.
- Audit method: `158b046fb06a41e3021ef67419d14871541da43dcfe3b2ed7daa30e5a4068646`.
- Pipeline source: `bb4adc761d4515ab72b522db5fd0463a577a4034405a6badf4173f322ee5051f`.
