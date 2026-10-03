# Static review of historical raytrace selection

Final status: checked05 was rejected for performance; corrected checked06 is
installed after fresh validation. Both corrected ray modules exactly equal
Phase39. Fresh three-point ratios have overlapping ranges and are recorded in
[final execution](execution/report.md); no new ray speedup is attributed to
identical code. The analysis below explains the rejected05 graph, and its
original timing and semantic evidence remain preserved.

Compared inputs are `selfhost/build/phase39/final-candidate01/modules/raytrace.mjs`
and `selfhost/build/phase40/final-candidate01/modules/raytrace.mjs`. Their sizes
are132317 and143078bytes. Both retain two private scalar-tree wrappers and their
existing region-local helper machinery. The candidate additionally declares
rowf/colf structural components and a private scalar bench root.

The candidate bench root's admitted path directly selects rowf$tree. Its depth6
row tree has64 leaves; each leaf directly selects colf$tree with depth14, giving
1048576 column leaves overall. In the new global colf component, a leaf invokes
`callOwned(get(G,"colf.px"), [...])`. The previous colf scalar-tree island instead
calls its locally emitted private colf.px helper, which continues into the
existing private pixel/helper chain. The new complete proof is valid, but the
new component path bypasses a stronger existing lowering at an exceptionally
hot leaf. Those generic leaf calls are a plausible dominant regression mechanism;
static inspection alone cannot quantify their share versus frame/guard costs.

The existing ADT/List-first component work needs scalar-result folds. The new
Nat-first extension is needed for data-producing flow and list constructors.
Therefore the smallest proposed selection repair is to add this predicate only
to the primitive-Nat alternative in j_component_plan:

```bend
Bool.not(j_region_scalar(book, j_fold_root_result(book, dt(d), da(d))))
```

The existing result peeler normalizes each telescope step. The scalar predicate
recognizes canonical U32, Bool, Nat and F32. The unchanged whole-graph JPure
signature must still independently prove every argument/result type and body.
Consequently this narrows the Nat-first extension to eligible data results; it
does not admit arbitrary nonscalar values or broaden native-container purity.
ADT/List-first scalar folds remain eligible. General function-name checks,
benchmark exceptions and recursive generation of j_tree_worker inside planning
are unnecessary.

This deliberately leaves Nat-to-scalar selections to the pre-existing lowering
and generic fallback. It may forgo some new scalar opportunities, which need a
future lowering-precedence design rather than displacing established private
islands globally. Fresh checked emissions must confirm rowf/colf's old selection,
preserved list/tree gains, owner semantics, broader integration and compiler cost.
No old failed timing or successful checked05 owner is overwritten or rebound to
the proposed successor. No production source is changed by this review.

## Completed rejected05 execution evidence

[Historical report](../../selfhost/build/phase40/historical-final01/report.json)
completes in402.070seconds. Raytrace's three rotating rounds retain nine clean
role samples. Phase39 median is777.015800ms (772.662309–783.444901), checked05
median1884.697110ms (1884.350562–2119.180809), and TypeScript
median34.370772ms (34.330553–38.494203). Baseline/candidate is0.412276×:
checked05 takes142.556% more time, or2.426× the baseline time. Candidate/TypeScript
is54.834×. Candidate loses all three pairs with disjoint observed ranges; paired
baseline/candidate ratios are0.412352,0.364604,0.415687. Baseline/candidate
half-drift values are unavailable because these slow samples use one measured
call; unavailable drift is not evidence of stability. TypeScript drift spans
−0.365% to+3.446%.

The [rejected05 aggregate](../../selfhost/build/phase40/rejected05-execution-summary01/report.json)
binds45 points/23 sources and669 primary samples across four separate runs
(total1088.826seconds). Every recorded result check passes; its `pass:true`
reports measurement/value completion, not performance acceptance. Raytrace's
large adverse result rejects this image despite its useful tree/list gains. The
checked06 result restriction needs new checked source/output identities and its
own performance/semantic admission; old checked05 timings cannot establish it.
