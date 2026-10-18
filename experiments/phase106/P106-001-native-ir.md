# P106-001: cheaper validated native research iterations

2026-10-18. Status: completed bounded experiment; no production promotion.

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

## Outcome

All five steps completed; [report](../../implementation/phase106/README.md).
A native Bend producer drives both consumers, thirteen named laws pass independent
checking, four admitted semantic mutants fail, and independent backend controls
pass. Cranelift object generation is10–17× faster, but runtime quality differs.
Fresh one-shot target-cost estimates are0.476×/0.504× C O2 on training/held-out
families. Repeated-batch training regresses on new sizes; no universal policy or
full-compiler backend is promoted. The measured loop exposes inlining and
supervision costs as the next bounded opportunities.
