# Optimizer preparation and verified-unit reuse

This audit inspects the selected Phase137 source
`selfhost/build/phase137/integrated-source03/compiler.bend`, SHA-256
`2620d59a3a20fa5d5d27bbf3b12ceb7304439b27093fff1c0f383da03e4ecf38`.
Line references refer to that immutable source. The subsequent bounded verifier
prototype is separate from the selected compiler and changes no original
verifier declaration. Root owns campaign integration and qualification.

## The remaining floor is not one optimizer pass

[Phase136 metrics](../../phase136/metrics.json) measured these full-source native
intervals, before Phase137. They are historical diagnostic costs, not current
paired measurements:

| Interval | Seconds |
| --- | ---: |
| Open verification | 10.983 |
| Inline transformation and commit | 17.073 |
| Range transformation and commit | 9.013 |
| Final verification, borrowing, closure | 40.665 |
| Combined | 77.734 |

The [Phase138 timeline](../../phase138/timeline.md) shows verifier-table work
(`p111v_get`) in the late intervals, but active owners are not inclusive stacks.
It cannot isolate worker construction from verification. In older hosted small
screens, `arrayFinalVerify` exceeded `borrowAndFinalClosure` on Lexer and closure
cases; Map was more mixed. Do not extrapolate those timings to the full image.

The actual route is:

1. `p128raw_session_finish` (56509) opens, inlines, and range-optimizes the raw
   direct program.
2. `p114s_open` (48777) runs `p112s_verify`, then `p113e_functions`. The former
   validates all generic segments and the static image.
3. `p128raw_lowered` runs `p113a_verify`, which reaches `p113e_verify` (45088):
   full generic/static verification and direct-function verification again.
4. `p128raw_br_prepare` (56639) prepares observers for candidate owners.
   `p128br_scan_plan` (55982) may construct new reader/adapter functions or retain
   an owner for retry. `p131p_closed` (57620) reruns ordinary candidate admission
   with the new helpers ready, then retries observers against those helpers.
5. `p126bp_complete` (54635) projects/verifies final direct functions and checks
   array/transport namespaces. This last check does **not** independently repeat
   every generic raw-segment body check.

Consequently, deleting the earlier raw verifier and merely retaining the last
projected checker would be wrong. Reusing an actual previous successful judgment
under an exact unchanged context is a different, explicit obligation.

## Implemented bounded experiment

[Verifier modules](../../../selfhost/tools/performance/phase140/verify/README.md)
implement a fixed-producer internal cache of a previously successful
`P113DProgram`. The selected source is untouched; there are no overrides.

`p140v_check(current, prior)` returns the current judgment, IDs, a new success
cache, and `[rawHits,rawMisses,directHits,directMisses]`. `p140v_open` builds the
ordinary `P114SBoundary`; `p140v_array` additionally runs the original array and
transport namespace checks. Use separate prior slots at the pre-inline and
post-inline boundaries; never silently substitute one transformation stage's
input for another.

Raw-body reuse requires exact ordered generic headers and constructor rows,
plus exact whole-segment equality. All metadata fields are compared, including
result, incoming, flags and constructor hotness. This is stronger than the
actual maps' projections. The ordinary metadata scans still validate duplicate
names, capacities, and the main entry. Static-image validation runs afresh.

Direct-body reuse additionally requires exact ordered private headers and an
exact `P113DFunction`. Header equality preserves every ordered `ready` lookup,
including absence. Current signatures are republished in ordinary order on every
hit. Changed bodies invoke `p111v_segment` or `p113e_function` unchanged. The
first failing diagnostic has the original priority. A failed result publishes
no ready cache.

The correctness premise is **provenance**, not a forgeable Boolean: prior caches
must come from successful calls in this fixed producer/session. This is not a
persistent artifact format or an untrusted API. An external caller can forge a
cached program whose bodies never passed verification. Source/runtime/producer
changes require a new session. The original final projected verifier stays in
place; no compiler-correctness theorem is claimed.

The hosted screen compares actual freshly lowered old/edited Lexer and Map
programs, counts skipped original body verification, compares complete opened
boundaries, and mutates a raw body to ensure the original failure and empty cache
are preserved. Preparation and cache acquisition are separately charged. This
is not a native or complete-build speed result.

## Next reusable preparation boundaries

| Boundary | Conservative key and result | Priority / limitation |
| --- | --- | --- |
| Raw/direct verification | Implemented exact metadata and body judgments above | First: late verification is concrete and substantial; quantify total screen/integration cost. |
| Observer plan and initial workers | Source owner and complete transitive body/type/layout facts, ordered global admission epoch, synthetic-name absence; plus the actual matching original direct function for scalar fallbacks. Result is `NO_Plan`, `P118BWorkers`, helper seeds and retry disposition. | Next if worker construction remains hot. Lookup/type normalization, `NativeErasedBody` / `NativeStaticBody`, constructors and implicit literal types must be covered; the raw-owner dependency audit is reusable but not automatically sufficient. |
| Helper-ready retry | Exact previous plan/schema, current ordered helper descriptions, current relevant book facts, and exact matched fallback function. Result is one owner's patches. | First version can invalidate all retry entries once when the complete helper list changes. Compare shared helper context once per request, not once per owner. |
| Ordinary closure | Existing candidates and current ready signatures determine admission. `p113d_passes` only consults candidate error/calls and ready membership while preserving pass/order/fuel. | Cheap shape scheduling is lower priority than body construction/verification. Candidate bodies change the output even when scheduling is reusable. |
| SCC conversion | Exact pair candidates, name counts, current candidate order and partner-selection/absence facts | Global partner/count dependencies make casual owner-only memoization unsafe. Keep fresh first. |

`p128bs_find` (55361) and `p128br_find` (55630) read the complete selected original
worker, not only its signature: its body becomes the owning fallback. Reusing a
reader while retaining a stale fallback is wrong. `p128br_replan` (56002) reads
helper interfaces; an absent helper becoming available is also a dependency.
`p126bp_extra` (54592) reads the product signature and admission facts.

Do not reimplement observer analysis before the verifier result is measured.
The current raw-owner agent already retains initial lowered code and candidates
under conservative static/header/dependency checks. Reuse those established
facts rather than comparing the whole book per observer. A global entire-book
key invalidated by every body edit would demonstrate no useful incrementality.

## Cost discipline and falsifiers

The prototype still traverses exact bodies, rebuilds metadata maps and checks
static-image layout. It skips per-body schema/live-name analysis and verifier
lookup work; it does not claim O(dirty-size) verification or eliminate all late
cost. Retaining the prior IR, equality walks and final reference reclamation
must be included in complete request time and memory accounting.

Reject promotion if the full successful edit makes little complete-request
progress, even with high hit counts. For a tenfold warm target, all remaining
floors must fit roughly35s; neither 77.7s nor its40.7s combined final subinterval
can be assumed gone. Split the remaining verifier/observer costs before paying
for a wider observer-cache implementation.
