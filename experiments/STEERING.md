# Current compiler: Phase42 checked16

Phase42 is installed, on unchanged upstream0187512. API63ddb2dd35554aafafc26dbdff4aba86b5d3774cd0d99a9509ccf237d210ba54.
[Report](../implementation/phase42/README.md), [results](../implementation/phase42/results.md),
[profiles](../implementation/phase42/profile-findings.md), [portable loop](../selfhost/tools/performance/phase42/README.md).
All 15 postinstall groups,227 source bindings,42CLI checks and45runtime points pass.
This is a checked B1 derivative; no new fixed point. No PR comment is authorized.
No persistent Goal is active. Preserve the 103 unrelated files and closed historical evidence.

Full 45 geometric slowdown improves12.57→8.86×TypeScript (equal points); equal
source weighting gives15.40→11.42×. Tree gains6.27–8.02×, BST23.66–26.96×,
lists2.72–6.65×. One point beats TypeScript; overall parity remains unfinished.
Compiler costs are mixed and source grows1158lines; these costs are admitted explicitly.

## Next experiments, grounded in fresh profiles

1. Map/lexer: remove generic call/argument/allocation machinery across complete
   String-using components. The per-edge Map guard prototype regressed; first
   test one guard at an eligible component entry with exact public/host fallback.
2. BST: remove residual generic building and down-worker allocation. Private
   native data is now supported; do not retry the rejected partial-flat WeakSet
   conversion without a new boundary-cost hypothesis.
3. Tree: remaining costs are direct warp/continuation work, with allocation now
   close to TypeScript. Smaller layout tweaks have less headroom; test eliminating
   whole intermediate traversals or owned destinations.
4. Ray/records: retain scalar-island precedence while investigating remaining
   generic helpers and container/field representation. A tree-only proof does
   not establish safety for floating point, String or observer-bearing values.

Use a saved-output ablation and complete semantic/activation oracle before new
source. The changed-family portable20s screen runs tree/list/BST in9.90s here.
After source integration, test all consumers of shared predicates immediately.
Use scope-aware instrumentation and actual emitted paths; global-only counters
caused needless late repairs in this campaign. Broad qualification runs once on
a frozen image. Heavy jobs remain serial and memory bounded.

The next investigation must state its expected family-level gain and smallest
falsifier; no universal parity forecast follows from the current results. The
[roadmap](../design/phase42/README.md) and [failure lessons](../implementation/phase42/failure-lessons.md)
retain the reasoning and rejected alternatives.
