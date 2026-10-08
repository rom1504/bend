# P68-003 — Share native bodies through ordinary eta adapters

- Owner: research/source lane; root owns all target execution and integration.
- Independent reviewers: native lowering, upstream comparison and correctness
  lanes. Source proposal reviewed on 2026-10-08 before root application.
- User objective: native parity while protecting compilation, conformance and
  simplicity. Investigator-proposed mechanism: one body shared by ordinary and
  direct entries after the matcher-arity candidate.
- Correctness: source-reviewed, **not compiled or executed at registration**.
- Measurement: **not run for this candidate**; no performance gain claimed.
- Decision: investigate with one checked-B1/controlled native screen.
- Related work: [P68-002](P68-002-match-arity.md),
  [entry design](../../design/phase68/entry-liveness.md),
  [world-compiler research](../../research/phase68/world-compilers.md).

## Hypothesis and contract

An ordinary named function entry can return a curried chain of fresh parameter
lambdas whose final body calls the full `$direct` worker. The actual source body
is then lowered once. We expect fewer generated segments and C bytes, and may
reduce emission/Clang time. No numerical reduction or execution improvement is
predicted; higher-order calls can incur an additional tail hop and retain unused
arguments longer.

Admission: positive current native arity; user definition; not a native
primitive, Foreign/Absent definition, or a definition named by any bang
reference. All excluded cases retain the previous expression. Ordinary entry
identity, closure capture/application ownership, worker signature and original
call/fork metadata remain present. The existing arity calculation is reused.

The adapter holds each evaluated argument once and transfers it once to the
worker. Fresh adapter IDs precede adapter lowering; direct parameter IDs come
after the adapter's final fresh counter. No C expression evaluation order is
relied upon. Full applications continue to call the direct worker.

**Intentional reference alignment:** upstream `call_eta` delays a named
partial matched prefix until its remaining arguments arrive. The old selfhost
ordinary body can perform that prefix early. The candidate aligns that boundary
with upstream, rather than asserting unchanged old-native partial-call timing.
Explicitly staged matcher calls require separate controls.

Stop on ownership/calling/scheduler mismatch, an unexplained diagnostic change,
failure to reduce duplicate body output, or a material higher-order regression.
Do not extend the admission domain to hide a failing case.

## Frozen source proposal and setup

The [prototype manifest](../../selfhost/tools/performance/phase68/entry-liveness/eta-adapter-v1/manifest.json)
binds exact base/candidate copies and the
[patch](../../selfhost/tools/performance/phase68/entry-liveness/eta-adapter-v1/candidate.patch).
It adds 24 lines to `direct.bend` and changes one `book.bend` call site. It was
prepared against matcher-arity v1; root must verify the base hashes or explicitly
record a rebase onto the shared-arity candidate before application.

Only those native source changes are the experimental factor. Keep the pinned
upstream, Base, runtime, host/harness, Clang flags, workloads and oracle fixed;
bind their exact identities in root's fresh attempt manifest. Root uses one
guarded CPU3 target tree; source/data work stays on CPU0. Earlier raw evidence
remains closed. Compiler emission, Clang build and execution are separate clocks.

## Required first controls

- Checked B1 and the arity-fast selection: common/unequal match prefixes,
  erased fields/partial closure, oversaturation, uncalled absurd tail, and
  shared scrutinee/residual ownership.
- Unchanged `controls/error-order-v1/{saturated,partial,staged}.bend`, paired
  with the upstream oracle. Record the old partial mismatch separately if
  confirmed; do not edit its expected result to admit the candidate.
- Phase67 raw ten diagnostics, including body/value diagnostic precedence;
  removing one lowering traversal is not permission to alter the raw API.
- Bang intrinsic closure, primitive override, foreign runtime callback,
  captured arrays/trees, and one/four-thread executions.
- Small native family screen, then held-out structural coverage if useful:
  record segment/C bytes, emission time, Clang time and execution separately.

| Attempt | Correctness | Measurement | Interpretation |
| --- | --- | --- | --- |
| Registered source prototype | Native/upstream source review; no target run | None | Ready for root's bounded checked experiment |

The native reviewer found no checked-source ownership/ID blocker in the source
proposal. The upstream reviewer confirmed `call_eta`'s delayed partial-prefix
contract. The correctness reviewer identified the paired error controls and raw
API/foreign/bang gates above. None of these reviews substitutes for execution.

## Alternative and preservation

Use-directed dead-entry pruning is deferred: the source-only literal-FID census
finds about 9–10% potentially removable body text in three baseline C files,
while actual-body sharing also removes duplicate bodies whose entries are both
live. That census is not an eta-adapter result or a runtime forecast.

Preserve the source proposal, exact hashes, checked attempts, failures and all
timing observations. Put outcomes in the implementation report/new evidence
receipts rather than rewriting this prospective registration. No production
promotion is authorized by this document alone.

## Prospective v2 guard addendum, before root application

The correctness reviewer identified leading-only arity in malformed raw inputs
as an avoidable exposure. Root requested the
[v2 patch](../../selfhost/tools/performance/phase68/entry-liveness/eta-adapter-v2/candidate.patch)
and [manifest](../../selfhost/tools/performance/phase68/entry-liveness/eta-adapter-v2/manifest.json)
before its combined build. V1 remains preserved unchanged.

V2 requires positive typed live arity equal to the full native arity, so a raw
definition whose leading lambdas alone supply its arity retains ordinary-body
lowering. `nd_user_entry` computes typed arity once and derives the existing
maximum; extracted `nd_extend_arity` consumes that result in either branch.
This adds 36 net lines instead of v1's 24 and avoids an extra type-normalization
query for admitted users. Native/Foreign/Absent/bang exclusions remain unchanged.
The same controls and stop conditions apply; v2 is still uncompiled at this
addendum. A combined shared-arity extraction must rename the new arity references
as well as the preexisting one and record the resulting source identity.
