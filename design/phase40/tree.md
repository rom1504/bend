# Phase40 tree flow prototype (prospective)

Hypothesis: inside the already guarded checked05 scalar bench root, removing
remaining `flow`, `warp_node` and leaf dispatch lowers tree execution time while
retaining every materialized tagged tree. No producer/consumer fusion, new guard
scope, unboxed result or public tree entry is proposed.

Ablations: unchanged bytes; leaf-only direct saturated helper; flow-only private
explicit frames using the existing warp worker; complete flow plus leaf. The
flow stack visits the left warp and complete left flow before the right warp,
then constructs the parent. Zero flow copies the root and aliases its children.
Mixed-depth warp fallback leaves remain materialized. BigInt countdown remains
unchanged to isolate dispatch. Existing entry guard and dependency set remain.

Independent controls: sorted-array bench oracle at depths0/1/2/4/6/8/9 and
multiple seeds; nested-array equation oracle for flow on unequal/irregular shapes,
both directions and shared children; complete tagged tree equality; zero-flow
root freshness/child alias assertions; deep explicit-stack execution; public
mutation/getter, exact-entry, reentry, host mutation and demand/error order
observations inherited from Phase39 controls without weakening assertions.

Root alone runs all executions serially on CPU3, Node24, heap1GiB/RSS2GiB and
free memory2GiB. Prototype preparation/control budget30–45minutes. First timing
uses20seconds with unchanged-module noise role. Abandon on semantic mismatch or
weak gain before compiler integration. If viable, investigate admission of
mixed Nat/scalar/tree recursive prefixes in the existing producer/tree planner;
require independent Bend fixture and compiler-cost measurement before promotion.

Correctness: unchecked. Measurement: not run. Decision: investigate saved output.
