# Phase98 native prefix diagnosis and exact correction

The late full-self failure in source `59b36a1c…2714` has a concrete source cause:
`noa_below` eagerly recurses through a missing child before testing whether the
origin is an `OField`. `kid(Absent,0)` returns `Absent` again, so a nonmatching
root can retain an unbounded continuation chain. The minimal `2a72bbdc…e051`
candidate makes that predicate lazy. It changes one source line and 38 bytes;
cache/redirect planning changes remain separate and unpromoted.

The intentionally stopped 75s and 90s profiles exit77 and do not produce accepted
self compilations. Their peak tree RSS is 1,060,147,200 and 2,760,970,240 bytes.
The 60–75s window has 937 samples: `nb_contains` plus its attributed cleanup is
371 samples, 39.59%. The 75–90s window has 938 samples, including 139 direct
`norm_exact` and 11 direct `noa_below` samples. KTerm projections and their cleanup
dominate much of the remainder. These physical samples locate a promising path;
they are neither allocation counts nor a complete logical call tree. The saved
[75s](../../selfhost/tools/performance/phase98/comparison/ownership-prefix-attribution01.json)
and [90s](../../selfhost/tools/performance/phase98/comparison/ownership-prefix-attribution02.json)
attributions preserve denominators, C/source mappings and limitations.

The exact [old/new C audit](../../selfhost/tools/performance/phase98/comparison/origin-c-shape-audit01.json)
independently confirms the evaluation order:

| Exact generated C | Old59b36 | New2a72 |
| --- | --- | --- |
| Fallback `C896` | Calls `kid` at49660 | Calls tag guard, then `NT_CHOOSE` at49662 |
| Recursive path | `K897` at49693 calls `noa_below` | True closure `C897` at49693 calls `kid`; `K898` at49723 recurses |
| Refusal path | Tag check runs only after recursion returns, `K898` at49724 | False closure `C900` at49767 returnsFalse, with no child access, recursion or allocation |

The audit records full pinned C blocks and 11 source/data assertions. Its C pins
are old `5782601e…06767` (17,724,799 bytes) and new `21c0e6b6…4e128`
(17,725,478 bytes). Lines refer to `WL_CASE` starts, rather than individual calls.
Reproduce this inspection with a fresh output:

```sh
python3 -B selfhost/tools/performance/phase98/comparison/origin-c-shape-audit.py --out /tmp/phase98-origin-c-audit.json
```

Existing root-run `origin-controls01/report.json` retains the bounded old
nonmatching-root failure and successful corrected helper/retained-term controls,
three unchanged complete C products, and the valid root-swapping program's
native execution. These finite controls are distinct from the static C audit.
Full upstream source acquisition has zero holes; final native B1/B2 self,
semantic, resource and public-release gates are separate. This correction
extends termination to previously divergent inputs; it is not an unconditional
equivalence claim with the old executable or a whole-compiler proof.

The corrected public source recipe is
[`phase98-comparison02/profile.json`](../../selfhost/tools/native/profiles/phase98-comparison02/profile.json).
It contains 1,376 exact sequential edits against D04, represented by 14,812 bytes of
compressed changes and a1,941-byte manifest. Its candidate is 1,754,096 bytes,
79 physical lines above D04. `profile-replay03.json` verifies the full candidate
hash and exact inverse to D04 using the committed Phase90 capsule and the current
replay method, whose default is comparison02. Historical replay01/02 and their
prior method bytes are preserved separately. Profile01,
native07, canonical compiler modules, and public default selection are unchanged
by this preparation. The [promotion plan](../../selfhost/tools/performance/phase98/comparison/promotion-plan.md)
specifies the separate release gates.
