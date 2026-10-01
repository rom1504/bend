# Phase39 new-owner release gates

**Status: all four final owner groups and the v4 identity closure pass.** The
selected image is checked05, API SHA256
`04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f`.
Every candidate control below was acquired and run against that image.
This closes these owner gates, not the separate release decision.
Checked01 guard/countdown and checked04 component
results establish earlier candidates only. A matching source file, a matching
runtime, or a passing earlier API cannot substitute for the selected API.

Unary fixture v3 was rejected by the frontend's termination check for its
deliberately non-predecessor recursive call. The failed
`selfhost/build/phase39/unary-cohort02` acquisition and unexecuted v1 closer/spec
remain unchanged. Fixture v4 marks that refusal case `@unsafe`; compiler
eligibility is unchanged. Its actual checked05 controls pass all required counts
in `selfhost/build/phase39/unary-actual-controls01/report.json`. The versioned
v2 closure bound that successful tool/fixture version, then failed on an audit
schema assumption: pinned TypeScript receipts have `mode: library`, without
Bend's `phase` and `exitCode` fields. The versioned v3 closure retains both
schemas' checking assertions and requires every acquisition process to exit
zero. The failed `new-owner-close01`/`new-owner-close-run01` evidence remains.
V3 then closed the countdown owner but rejected relative `src/...` module
identities in the selected bootstrap report. That report has no `kind` field;
its module names are relative to the assembled compiler snapshot. The failed
`new-owner-close02`/`new-owner-close-run02` evidence also remains. V4 binds this
namespace to the sibling checked attempt and exact bootstrap report, then
verifies each module against its absolute assembled-source provenance and the
matching frozen source bytes. Unknown namespaces still fail. A read-only walk
of the current four-owner identity graph found this was the only missing
namespace; that inventory was not an executed audit. Root subsequently executed
v4 successfully at `new-owner-close03/report.json`.

The [final closure receipt](../../selfhost/build/phase39/new-owner-close03/report.json)
verifies **four groups, 775 file identities and 15 pinned Git blobs**. Its bounded
execution completed in 3.516 seconds with 27,500,544 bytes peak process-tree RSS;
that is audit cost, not generated-program throughput. Receipt SHA256:
`5be69ea17b8e97afb5b8fe30a96a2ac3ec5df54a9cbc6333375c58aefaaa017a`.
The exact final attempt, mapping, specification, control reports and execution
receipts are bound inside it. Ignored raw paths are restored from the phase
evidence capsule once published.

All paths below are relative to `selfhost/tools/performance/phase39/` unless
stated otherwise. Root owns execution, serially on CPU3 with Node 24.18.0,
1 GiB heap, at most 2 GiB process-tree RSS and a 2 GiB available-memory floor.
Acquire tools already own `ExecutionGuard`; do not wrap them in another shared
lock. Derivation/control tools need the maintained bounded supervisor.

| Owner | Frozen acquisition / derivation | Actual-output controls | Required observations |
|---|---|---|---|
| Private Number countdown | `countdown-acquire.py`, `countdown-fixture.bend` | `countdown-compiled-controls-v2.mjs` | 66 oracles, 12 admission, 25 boundaries |
| Reused outer guard scope | selected active-ray checked emission, `guard-checked-derive.mjs` | `guard-checked-controls.mjs` | 13 observations; 26 unchanged graph guard names |
| Two-child structural component | `component-acquire-v3.py`, `component-fixture-v3.bend`, `component-actual-derive.mjs` | `component-actual-controls.mjs` | 159 oracles, 113 boundaries, 3 admission |
| Unary producer | `unary-acquire-v4.py`, `unary-fixture-v4.bend` | `unary-compiled-controls-v4.mjs` | 83 oracles, 56 structures, 3 admission, 32 boundaries, 3 error-order observations; three explicit refusal shapes |

Any source/control successor must preserve consumed predecessors, declare its
derivation and update the required gate version before final runs.
Callbacks are a rejected saved-output experiment, not a production owner.

The independently reviewed and successfully executed closure tool is
`selfhost/tools/performance/phase39/new-owner-close-v4.py`. Its frozen
`new-owner-spec-v4.json` records the unchanged mandatory counts and tool/fixture
hashes, plus the consumed v3 inputs and failure evidence. Earlier independent
reviews covered selected-image/receipt links, actual report and supervisor
schemas, diagnostic parents and required counts. V4 adds explicit bootstrap
namespace verification. An independent read-only review confirmed that all
module bytes remain verified and all four semantic/count/resource assertions
are unchanged; no blocker was found. Neither reviewer executed the auditor or
target programs; root executed the successful closure.
Invoke it with `FINAL_ATTEMPT MAPPING_JSON NEW_REPORT_JSON` under the bounded
supervisor after all four final runs succeed. The mapping has these exact shapes
(paths may be repository-relative or absolute):

```json
{
  "countdown": {"cohort": "NEW_COUNTDOWN_COHORT", "report": "COUNTDOWN_CONTROLS/report.json", "execution": "COUNTDOWN_RUN/run.json"},
  "guard": {"derivation": "NEW_GUARD_DERIVATION", "report": "GUARD_CONTROLS/report.json", "execution": "GUARD_RUN/run.json"},
  "component": {"cohort": "NEW_COMPONENT_COHORT", "derivation": "NEW_COMPONENT_DERIVATION", "report": "COMPONENT_CONTROLS/report.json", "execution": "COMPONENT_RUN/run.json"},
  "unary": {"cohort": "NEW_UNARY_COHORT", "report": "UNARY_CONTROLS/report.json", "execution": "UNARY_RUN/run.json"}
}
```

`cohort` names the top-level acquisition directory, not its `countdown`,
`component`, or `unary` child. `execution` names the bounded control run receipt,
not its acquisition or derivation receipt. Changing a frozen fixture/control
requires a versioned successor; do not relax a failing count to admit a partial
run.

## Acquisition protocol

For each of `countdown`, `component`, and `unary`, run its acquisition tool with
`--attempt FINAL_ATTEMPT --baseline-attempt selfhost/build/phase37/checked03
--upstream selfhost/.bootstrap/upstream-phase23 --node NODE --cpu 3
--rss-mib 2048 --available-mib 2048 --timeout 180 --out NEW_COHORT`.
All three roles compile identical consumed source bytes. The baseline API must
remain Phase37 `ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1`;
the TypeScript role remains pinned to upstream
`018751270e800bc222a93dad7f257083ee53a5f7`.

Run countdown/unary controls with `NEW_COHORT/countdown` or
`NEW_COHORT/unary`, respectively, and a new output directory. Component derives
from `NEW_COHORT/component/{baseline,candidate,typescript}.mjs`, followed by the
selected attempt and a new derivation directory; its controls consume that
derivation directory. Never substitute the saved component-expression rewrite.

Guard derivation arguments are `FINAL_ATTEMPT CANDIDATE_RAY BASELINE_RAY
NEW_DERIVATION`. `CANDIDATE_RAY` must have its checked receipt at the adjacent
`.mjs.json` path, acquired by the selected attempt. The Phase37 ray baseline is
byte-pinned by the derivation tool. Guard controls consume `NEW_DERIVATION` and
write a new output directory. Use the 45-point preparation's active-ray source
emission directly; no repeated acquisition is necessary if its receipt and
identity match exactly.

## What the final closure must check

1. The selected attempt is a complete checked `derived-b1`, with strict exact
   checking, one job, CPU3 and the recorded bounded Node. Verify API, checked API,
   runtime, Base, bootstrap/derivation reports, all artifacts and frozen sources.
   Historical original source paths are allowed to differ; frozen bytes are not.
2. Every Bend candidate emission has `checked=true`, status `ok`, type acceptance and
   zero exit status. Its exact attempt path/hash, API/runtime/Base/driver paths
   and hashes, bootstrap source hash and upstream pin match the selected image.
   Validate baseline attempts independently and all three pinned TS input files.
   The TS receipt requires `checked=true`, status `ok` and `mode=library`; its
   acquisition process separately requires zero exit status.
3. Each source and raw module is tied to its own checked receipt. Derivation
   clean copies equal raw output bytes. Diagnostics identify that parent and add
   counters/adapters only. Candidate module identity cannot be inferred merely
   from the report's assertion that it passed.
4. Each final control report is complete, passes, has no unfinished `current`
   record/error, and has exactly the required counts. Verify the consumed tool,
   fixture, derivation and diagnostic identities. Reject an unrelated report
   with the same count or a report from an earlier checked candidate.
5. Verify the supervisor's completed zero-status command names the exact tool,
   input directory and output directory, uses the selected Node and CPU3, and
   records the heap/RSS/free-memory bounds. Acquirers' own process receipts are
   the authority for their emissions; they must not acquire a nested shared lock.
6. Resolve transitive catalog references in their document context, and pinned
   historical Git provenance by verified `commit:path` bytes. Rehash every file
   and Git blob after the audit; do not silently skip unresolved references.

## Coverage limits and complementary gates

Countdown admission covers real Number loop steps and refusal when a Nat
predecessor escapes. Large Nat values are tested as values/results, never huge
trip counts. Finite small tests do not establish arbitrary Nat arithmetic.

The guard witness compares all 26 emitted names and the old entry condition,
tests mutation after a successful call, live host-hook reentry, staged/raw calls
and proof restoration. Its injected error is explicitly a cleanup diagnostic;
it is not represented as a legal source callback. The ray does not exercise
DataView calls; inherited DataView controls remain necessary.

Component controls compare independent array/BigInt semantics, full tagged
structures and sharing; they also test actual scalar-root entry and deep tail
cycles. Diagnostic owned-input adapters are distinct from source-root admission.
The deep 30,000-step structural worker has a direct structural oracle but does
not require the older generic implementation to survive that stack depth.
Every emitted `$tree` call target must have exactly one declaration. This checks
the concrete regression found in checked02/03; successful compilation alone did
not expose the missing helper declaration.

Unary controls must witness first/middle/last child positions, ordered argument
errors before recursion, in the zero branch and after recursion, Error reentry,
shared child identity and deep explicit frames. Nested constructor admission
needs a genuine actual-emission witness; a screen with zero workers is not an
optimization success. Broader constructor grammar cannot bypass full typed
lowering or graph proof.

The four new owners supplement, rather than replace, the inherited Phase35
15 groups, Phase36 seven groups and Phase37 cast/DataView/finite three groups.
All inherited closures also pass on checked05; the latter uses
`phase37-owner-plan.py` with the exact 45-point/23-source preparation. The
14 pre-install correctness gate groups and all 154 expanded application
observations pass their stated criteria; see [integration](integration.md) for
the distinct counts and retained shared failures. All 45 execution points,
compiler-request cost, source complexity, performance admission, installation
and relocated CLI checks remain separate release decisions. No average program
claim or full backend/GPU conformance follows from these four owner fixtures.
