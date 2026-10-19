# Early private-planner refusal

Append `early-refusal.bend` after the selected direct worker modules. Apply
`early-refusal-entry.bend` as the final override of `p112t_scan_next`,
`p112w_scan_next` and `p112w_add`. This optional profile requires the existing
side-exit block scanner and composes with either direct argument bound. It does
not widen worker eligibility, failure admission or continuation fusion.

The original scalar case first evaluated the recursive suffix, then combined
its validity with `p112t_scalar_safe(stmt)`. The new case checks that mandatory
predicate first and returns a canonical invalid body when it fails. Branches
evaluate yes, no and shared rest in order, stopping after the first invalid
component. Valid branches retain the original assembly helpers and node order.
Failure recognition remains at block entry and still precedes ordinary scalar
scanning. Workers already admitted in an earlier immutable pass keep their
existing record and rank without reconstructing a discarded plan.

Each change uses only the same Boolean admission predicates. A refused scalar
or branch made the original conjunction false irrespective of later work.
Invalid plan payloads are private diagnostic data: all consumers select the
original fallback graph based on validity, and invalid nodes are never emitted.
Canonicalizing those payloads changes neither admitted plans nor runtime
operations. The planner is pure over finite checked structured IR; this argument
does not assert equivalence for cyclic fabricated host objects.

Root-only qualification:

```sh
node selfhost/tools/performance/phase112/workers/early-refusal-controls.mjs \
  OLD_CHECKED_API NEW_CHECKED_API FRESH_OUTPUT
```

The two APIs must differ only in this profile. Eighteen controls compare the
exact ready trie and first ranks, loop/direct admission, every valid plan,
complete worker chunks and the final program chunks. Six scaling cases use
rejected suffixes of 32, 128 and 384 statements, either behind an immediately
refused scalar or in an arm following an invalid first arm. Five samples per
case are recorded by the coordinator; preparation executes no target.

Before another native image, compare full emission from the same checked
40,000-segment program: byte identity is required, and the wall-time comparison
must include worker planning. Existing fail-stop admission receipts reject the
changed final declarations until a separate conjunctive profile explicitly
binds this override. Earlier presets and admission methods remain unchanged.
