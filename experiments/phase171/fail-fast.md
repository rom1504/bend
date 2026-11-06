# Phase171: stop lowering a rejected direct candidate

Experimental source only. No target run, maintained change, speed claim or
qualification is made here. The root-owned Map pilot places 0.4176 diagnostic
CPU seconds between `p113pl_candidates` and `p168_candidates`, out of 2.19 seconds
total. That is a roughly 19.1% **upper envelope for all candidate generation**,
not a prediction that all of it is removable. The full-source profile will
determine whether this is a useful large-build opportunity.

## Mechanism

`p113d_join` receives two already computed results and selects their first
nonempty error. Several callers nevertheless lower the whole remaining let or
branch tree after the first result is already a definite rejection. That work
cannot make the candidate successful. A guard inside `p113d_join` would be too
late: its second argument is already evaluated.

[fail-fast.bend](../../selfhost/tests/phase171/fail-fast.bend) changes nine
callers, leaving the join, candidate admission and independent final verifier
unchanged:

| Replaced definition | Removed work on definite failure |
|---|---|
|`p113d_let`, `p113dl_let`|Remaining ordinary/liveness let body after the bound expression fails.|
|`p113pl_bind_flat`|Remaining product body, including substitution of its bundle.|
|`p113pl_bind_boxed`, `p113px_boxed`|Remaining ordinary/liveness product body.|
|`p113dm_more`, `p113pm_more`|All later Word-pattern rows when the first lowered row fails.|
|`p113dm_original_match`, `p113pm_original_match`|Both branches for the pre-existing unconditional effect/specialized-Word refusal; otherwise the no branch after a failed yes branch.|

Two private helpers keep the admitted match expressions explicit. The exact
original normalized declaration pins are in
[fail-fast-originals.json](../../selfhost/tests/phase171/fail-fast-originals.json).
The new source checks the same error string and retains the original successful
expression. A failed result may have a shorter partial body/call list and a
different unused fresh counter. Therefore this is **not complete equality of a
raw failed-inspection record**. Its contract is successful code identity, exact
first diagnostic, unchanged retry/admission decisions and complete compiler
output identity.

## Why failed metadata cannot simply be deleted

`p126sc_counts` visits every raw candidate before the SCC optimizer filters by
error. Candidate name, signature, multiplicity and position must stay unchanged;
filtering failed candidates out would change duplicate protection and generated
worker names. This experiment keeps every candidate in its original position.

The failed body/call suffix is not used to admit a successful pair:

1. `p126sc_index` inserts only candidates with empty error, suitable shape and
   name count exactly one.
2. `p126sc_one` starts pair discovery under those same conditions.
3. `p126sc_partner_try` obtains its right function from that filtered index, then
   reads the right name's saved call metadata. A unique successful name's metadata
   came from that same successful candidate; an error or duplicate name cannot
   supply it.
4. `p113d_pass_function` discards an errored candidate before dependency admission.

Thus changing discarded partial calls does not change successful SCC selection,
provided names, counts, positions and all successful records remain identical.
The finite controls include failed-name duplicates both before and after the
successful candidate, and collision with a generated `$p126scc.0` name.

Other reachable consumers were checked: `p125p_params` only wraps candidates with
empty error; `p118t_ready` only publishes successful retry code; `p118t_retry`
selects its attempt from the exact first error plus owner/parameter metadata.
In particular, `product non-tail self call` must remain exact because it enables
TRMC retry. The overlay does preserve it. Construction-elimination producers may
still eagerly construct several separate candidate bodies; this experiment does
not remove those candidates or change their relationships.

The borrowed residual lowerer (`p118b_*`), scalar emission, construction-fusion
joins and native-transport joins are unchanged. Some also contain eager work,
but expanding the experiment there would require a separate consumer audit.
The current patch does not alter liveness-plan construction or signature/static
preparation, so those costs remain even when a later direct attempt fails.

## First gates and measurement

The same [finite Bend fixture](../../selfhost/tests/phase171/fail-fast-controls.bend)
is added to separately checked baseline and candidate sources. Its 22 observations
cover all nine changed sites: nine complete successful records, thirteen literal
first-error cases, and the self-call retry diagnostic. Another six rows exercise
SCC metadata/selection and the unchanged verifier. The independent host
[runner](../../selfhost/tests/phase171/fail-fast-controls.mjs) compares complete
successful `P113DCode` fields, not only acceptance or a checksum. The helper
fixtures test private lowering records; they are not a generated-runtime suite.

After actual checked API acquisition, the root-run command is:

```sh
bun selfhost/tests/phase171/fail-fast-controls.mjs \
  --baseline BASELINE_API_REPORT --candidate CANDIDATE_API_REPORT --out FRESH_OUTPUT
```

Then compile the same real Map, lexer and checker inputs through the two APIs,
including complete checking/lowering/final verification/rendering and teardown.
Require complete QBE bytes to agree. Count raw candidates, failures and selected
functions; reductions in partial failed statements/calls are expected, changes
in selected functions are not. Do not compare only the time spent inside the
new guards. The guards add a success-path cost, so an input with few rejected
candidates is an essential transfer control.

Only after a complete-request benefit should this acquire a native compiler and
test the full maintained source. No full-build estimate is justified yet. The
cheap falsifier is whether the Map candidate-generation stage and complete
request actually shrink while outputs stay exact. If failed suffixes are small
or guard/ownership cost cancels the work reduction, retain the negative result
and stop this branch.
