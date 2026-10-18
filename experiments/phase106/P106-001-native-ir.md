# P106-001: cheaper validated native research iterations

2026-10-18. Status: preregistered; no Phase106 results yet.

[Design](../../design/phase106/native-ir-research-loop.md).

Hypothesis: a structured Bend native IR with C and Cranelift consumers can reduce
build-plus-evaluation cost on compiler-shaped workloads while checked local laws
constrain useful transformations. Separate this from full compiler integration,
whole-compiler correctness and recursive acceleration.

Order: current full-source/Clang attribution; two-consumer IR vertical slice;
law and negative controls; complete iteration measurements; bounded policy search
with frozen training and held-out inputs. Preserve failed attempts and tool costs.

Acceptance: both consumers execute equivalent declared operations and independent
expected results, the actual transformed helper has a checked contract and wrong
variants fail, and policy selection is evaluated outside its training inputs.
Performance promotion requires measured cycle benefit, not merely fast codegen.
Current candidate04 and upstream pins remain read-only controls.

Heavy target jobs are serial and resource-guarded; offline agents have disjoint
implementation paths. The low-disk constraint is part of the recorded experiment.
Final results and exact replay commands will be linked from the Phase106 report.
