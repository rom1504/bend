# Phase84 candidate: stop after an actual private-worker refusal

Agent handoff notes; see the [final Phase84 report](README.md) for root-run
measurements, completed controls and rejection/deferral decisions.

Status: source prototype, not checked, measured or promoted by this lane.
Baseline `7352a00`; patch [refusal.patch](../../experiments/phase84/prototypes/refusal.patch).
The patch applies cleanly with `git apply --check`; production files were not
modified by its author. It adds 18 physical lines in four existing modules.
No compiler build, target run, subagent or commit was performed in this lane.

## Scope and decision

This is a conservative shared-lowerer implementation. It does **not** claim to be
a preflight classifier or a complete fix for rejected candidate generation.
It preserves the actual ordinary/product routing rules and reacts only after
those rules produce a definite `NC_Code.error`.

A syntax-only classifier saying “self reference beneath a constructor is rejected”
is unsound here. An ordinary worker named `f` can redirect a recursive source call
to `$product.f` through a speculative signature; that is not its own loop owner.
A product worker has owner `$product.f`; whether its source call selects that
route depends on `nq_args_fit` and virtual-bundle handling. Product signatures
can subsequently be removed, causing an ordinary retry to reveal the refusal.
Duplicating that logic in a cheap source walk would be a second backend algorithm.

Instead, `nf_failed(target, code)` recognizes a nonempty error under a private
`NC_Destination`; `NC_Scheduler` always follows the original path. The original
`nf_call_local` rule remains the source of non-tail-self-call rejection.

Changes:

- `nc_match_apply_slow_to`: once the hit branch has failed, skip the miss branch.
  If only the miss fails, return its failure without assembling parent C text.
- `nw_emit_more`: once a word-pattern row fails, skip subsequent rows.
- `nf_bind_boxed` and `nq_bind`: lower both children in the existing order, then
  avoid building parent text/call lists when a child has failed. Value errors
  retain precedence over continuation errors, matching `nc_first_error(val, rest)`.

Successful workers execute the same code construction expressions. No function
name, benchmark name, Map shape or scalar width grants the shortcut. Both ordinary
and product workers can use it, while their distinct routing remains intact.

## Why the retained worker record is sufficient

A failed candidate record still exists with its original name, parameters and
result shape. Only the failed `NC_Code` payload can be shortened; its nonempty
first error is retained. Missing siblings' C, dependencies, segments and fresh
counter are not promised to remain identical for this private failed result.

- `nf_admit_pass` requires empty error before dependencies can admit the worker.
- `nf_retry` retries only empty-error ordinary workers. A failed worker remains
  ineligible for retry; successful dependency-blocked workers are unchanged.
- `nf_prototypes`, `nf_bodies` and `nf_adapter_defs` select only ready names.
- `no_worker_taken` still sees all names, so private observer collision checks
  retain the same reserved names.
- `no_route_pair` admits only its new pair against the old ready set. It does not
  reconsider failed existing records. Scalar redirects require an already-ready
  owner and therefore cannot revive a rejected worker.

The shortcut preserves hit-before-miss and value-before-rest error precedence.
It deliberately does **not** skip a let value merely because the continuation
was lowered first and failed: the value may own an earlier error. Shortening the
failed fresh counter is safe only because that candidate cannot be emitted;
focused raw controls should challenge this with nested local binders. The public
scheduler path preserves its full result, including diagnostics and freshness.
Direct callers inspecting failed private-worker C/dependency/fresh payloads will
see the intended shorter internal product; complete payload identity is not a
stated private API guarantee of this prototype.

## Required controls before acceptance

Use the existing checked-B1 workflow; no separate compiler pipeline is needed.
The following cases should compare baseline and candidate, focusing on worker
admission/name/shape/error and complete final C/report equality. Failed private
body/dependency/fresh payloads may differ as described above.

| Case | Required observation |
| --- | --- |
| Tail-self-recursive scalar function | Still admitted; exact C. |
| Recursion beneath a constructor | Rejected by actual non-tail rule; fallback C exact. |
| Ordinary recursion routed to a speculative product | Initial successful candidate remains successful; no source-only false refusal. |
| Product recursion with matching bundles | Exact routing and refusal/admission. |
| Product recursion with opaque arguments | Original fallback route still decides; no guessed bundle permission. |
| Product signature removed before ordinary retry | Same retry eligibility and final ready set. |
| Match hit error A, miss error B | A retained, miss generation can be skipped privately. |
| Let value error A, continuation error B | A retained, even though continuation is constructed first. |
| Word row failure followed by more rows | Same first error; subsequent private rows skipped. |
| `NC_Scheduler` variants of failed cases | Entire `NC_Code` unchanged. |
| Empty-error dependency-blocked worker | Same metadata and retry; no new failure propagated. |
| Observer private-name collision / scalar redirect | Names reserved and ready-set behavior unchanged. |

The existing Map compilation is the positive performance discriminator because
Phase83 measured large discarded match-generated text there. Numeric and a
constructor/list/BST family test generalization; small/functions65 measure added
branch/helper overhead when no worker rejects. Compare exact C first, then use
fresh serial balanced measurements. A diagnostic worker-fate run should show
fewer generated body units and lower construction time for failed candidates.
Do not compare instrumented clocks with clean baseline clocks.

## Expected value and remaining work

Phase83's 181 ms of Map locally failing construction is an upper bound on this
lane, not an estimate: the first failing branch must still be lowered, and
successful prefix branches still incur work. Of the four Map helpers' 304 ms,
some attempts are locally successful but dependency-blocked; this patch does not
eliminate those attempts. It also adds tests and one helper call on successful
match paths. Whole-request benefit must be measured; a small or negative result
should be rejected without broad qualification.

The remaining roughly 198 ms of Map dependency-blocked construction needs a
separate experiment. Product-first ordering plus propagation of final refusal
could avoid speculative ordinary construction, but cannot simply blacklist
failed product signatures: ordinary fallback and product dependencies may differ,
and admission needs the actual dependency facts. A shared lightweight lowering
product or a precisely equivalent restricted dry-run would have to establish
those facts without duplicating routing logic.
