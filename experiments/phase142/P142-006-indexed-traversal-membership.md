# P142-006 — indexed visited names without changing traversal semantics

The completed native Phase141 warm-edit profile places `has_name` at42.62%
of the conservative frontend sample window. This identifies a substantial
membership-search cost, but does not establish which callers account for it.
The layout and reachability walkers both retain growing linear visited lists.

Hypothesis: replacing only membership queries with the existing collision-safe
name index removes quadratic searching on large compiler graphs, while
preserving traversal order, diagnostics, annotation products and generated QBE.
This is a general algorithm change, not another cross-request cache.

The layout prototype retains sentinel precedence, stops, definition lookup and
the complete original term traversal. The reachability prototype retains its
exact ordered result list, including duplicates of resolved constructor-owner
names. A separate index answers membership; hashes never establish equality.
Source bodies and independent final verification remain unchanged.

## Decision gates

1. Check both implementations in Bend; pass independent collision, alias,
   cycle, stop and failure controls.
2. Compare original and candidate in one checked API on real warm annotation
   products. Preserve negative results and full ordered outputs.
3. Use bounded constructed graphs to test the asymptotic hypothesis. These are
   not compiler-runtime gains and cannot substitute for a real full workload.
4. If scaling evidence and native profile justify acquisition, build one
   production-only candidate with the qualified Phase137 compiler. Compare
   the same frozen complete compiler edit against Phase141 N2, on one CPU,
   including both cold and warm requests and both independent complete QBE
   oracles. Record acquisition separately.
5. Keep the qualified selection. This bounded request comparison does not
   establish native self-reproduction or broad conformance.

## Early evidence

The first layout screen passes26 controls. On actual small programs it is
slower or approximately neutral (median paired gate ratios1.376 Lexer and1.015
Map). On constructed128/512-definition graphs the ratios are0.235/0.111.
The2048 case recorded two pairs near0.022 before the75-second total guard
expired, mostly in the original quadratic walker. That run is incomplete;
the next screen bounds synthetic size at512 rather than extending the deadline.
The small-program overhead is a real tradeoff to evaluate, not a result to omit.

Methods and controls: `selfhost/tools/performance/phase142/layout-seen/`
and `reach-seen/`. Initial receipts: `layout-component02` and its guard.
The combined bounded screen is `membership-component01`.


## Native outcome

The checked production source changes only the two audited entries (+79physical
lines). One qualified Phase137 acquisition produced the experimental image.
Matched clean Phase141 N2/candidate requests preserve both complete independent
A/B QBE oracles and all reuse stats. Warm frontend31.330→20.798s, warm total
101.672→91.434s; cold357.428→346.870s. The joint change removes approximately
10.5s of frontend time in this pair; separate native attribution to layout versus
reachability was not measured. Later stages are essentially unchanged overall.

Inclusive edited-executable estimate125.227→114.916s (−8.23%). Three independent
requests by rebuilt B pass. Native open-array refusal and dead/erased acceptance
match the parent exactly. No default promotion or full native qualification.
See implementation/phase142/{native-comparison,build-metrics,candidate}.json.
