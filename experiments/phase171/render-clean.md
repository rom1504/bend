# Share original-body hygiene across public emission alternatives

This experiment computes `p112f_clean(original body)` once within one actual
`p124r_public` invocation. It changes no compiler IR or persistent cache, retains
the exact fallback order, and leaves the original planners available to every
other caller. It is a source-level work-elimination candidate, not a measured
speed improvement.

## Repeated work and legal boundary

After the public-direct lookup refuses, the maintained public renderer tries:

1. `p114h_plan(segment,index,ready)`;
2. `p114r_plan(segment,index)` and its original/continuation hygiene;
3. `p114g_plan(segment,index,ready)` and its original/continuation hygiene;
4. `p114h_plan(segment,index,view)`;
5. `p112c_plan_index(segment,index,ready)` followed by ordinary public emission.

All five possible successes require the exact same original-body
`p112f_clean` predicate. The first four also require result1 and flags0, as does
the final fusion planner. Incoming count and arity have different scopes and
cannot be used as a common refusal gate.

The preceding [lazy-admission overlay](../../selfhost/tests/phase171/lazy-admission.bend)
already avoids inspecting bodies when a particular planner's metadata or
readiness rejects it. It does not preserve the common predicate across later
alternatives, so an unchanged original body can still be scanned five times.
This is distinct from retaining a complete legacy plan: the ready and view
environments are deliberately different, and plans selected against them cannot
be interchanged.

The new [render-clean.bend](../../selfhost/tests/phase171/render-clean.bend)
overrides **only `p124r_public`**. After exactly the original public-direct test,
its private entry checks result1/flags0 and computes the common predicate.
If either condition fails, every original specialized alternative necessarily
refuses and the fusion plan necessarily has count0. The exact original result
is therefore `p112w_public_segment(segment,ids,ready)`.

If the common predicate succeeds, eight private helpers follow the same
h(ready) → r → g → h(view) → fusion order, omitting only that established original
predicate. They retain all arity/incoming checks, readiness distinctions, the
512-statement bound, separate h/r namespace checks, continuation hygiene,
original prelude parsing and actual planner algorithms. The final fusion scan
receives the same original body/index/ready/site0; its removed header and clean
conditions were established by the enclosing entry. The original actual final
verification remains untouched.

No body query is moved in front of the public-direct branch. In particular,
public direct signatures still select the exact `p113e_public(name,arity)` even
for irrelevant dirty or oversized legacy bodies. Source-level aliasing and
allocation costs may differ; output equivalence alone does not establish gain.

## Files and finite gate

- [render-clean-laws.bend](../../selfhost/tests/phase171/render-clean-laws.bend)
  supplies one forward law for the private entry.
- [render-clean-controls-v2.bend](../../selfhost/tests/phase171/render-clean-controls-v2.bend)
  reuses the existing lazy-admission fixture builders and exports `p171rc_case`.
- [render-clean-controls-v2.mjs](../../selfhost/tests/phase171/render-clean-controls-v2.mjs)
  compares all complete output strings and supporting observations from two
  separately checked API images, authenticating inputs before and after.

The 44 finite cases cover dirty original names and uses, nested dirt, distinct
f/r/h dirt in continuations, missing continuations, 511/512/513-statement bodies,
arity/result/incoming/flags boundaries, legacy versus public/private direct
readiness, differing ready/view helper admission, and the unchanged direct
shortcut. At least one accepted recursive helper and a genuine ready/view
admission difference are required. Constructed IR is compiler test data and is
not executed as a runtime program.

Candidate preparation adds the new module, its prelude law, the two fixture
modules, `--replace p124r_public` and `--export p171rc_case` to the same existing
combined source recipe. Baseline preparation includes those same fixtures but
not the new override or law. The root execution lane runs:

```sh
selfhost/.assets/bin/bun selfhost/tests/phase171/render-clean-controls-v2.mjs \
  --baseline BASELINE_API_REPORT --candidate CANDIDATE_API_REPORT --out FRESH_OUT
```

Module SHA256:
`24f9d0e8d60f3152515765fdf3cdc0f5121fb386c7e3e05baa292e2a4c39f6ed`.
Source inventory and delimiter checks passed offline. The initial baseline
source check rejected a fixture's nested match of an earlier binder; that failed
`render-baseline-api01` and both source01 preparations remain preserved. Fixture
v2 reorders the helper parameters and its sole call to match the parser's binder
order, changing no compiler algorithm or fixture observation. Fresh baseline and
candidate source02 preparations were recreated from the authenticated source01
manifests; only the fixture module differs. Their checking and finite comparison
remain pending gates. No production files were edited.

## Decision and limits

After finite agreement, compile the same retained verifier source and require
complete exact QBE, then compare the render interval against the existing
combined candidate. Proceed to native acquisition only if the cheap loop earns
it. The current candidate's complete render/output interval is 30.454s; it
contains required formatting, private/legacy rendering and cleanup as well as
public selection. That entire interval is not removable, and there is no
measured frequency or gain estimate for this repeated predicate yet.

Two additional repetitions were identified but deliberately excluded. The
common `p112t_prelude(body,arity)` can be reparsed across h/r/g/view, while
`p114r_hygiene` and `p114g_hygiene` use eager conjunction and therefore inspect
original/continuation hygiene even when a plan is invalid. Sharing the former
or making the latter lazy needs a separate measured experiment. This candidate
does neither, keeping the causal question limited to one common predicate.

## Executed gate and complete-request result

`render-baseline-api02` and `render-candidate-api03` are separately source-checked.
The latter corrects only the forward-law declaration syntax; the failed02
receipt and original law bytes are retained. `render-controls01` passes all44
complete public-emission comparisons, including genuinely different ready/view
admission. No constructed malformed runtime program was executed.

A fresh serial verifier pair (`render-verifier-baseline01`,
`render-verifier-candidate01`) preserves all QBE bytes. Whole hosted requests are
29.013105s and29.176440s; render/write is2.743712s and2.731715s. This shows no
material speed gain on the real verifier. No standalone full native compiler
acquisition is justified by this screen. Keep the candidate off the selected
path; the removed scans have not demonstrated meaningful end-to-end cost.
