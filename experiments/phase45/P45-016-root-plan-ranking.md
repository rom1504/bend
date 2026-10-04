# P45-016: retain stronger root plans when composing backends

Status: independent static review passes; the first build failed on a missing local type annotation before target execution. Corrected acquisition 17b is pending. This changes backend selection, not a program-name recognizer or the legality proof of any existing backend.

## Observation and hypothesis

The worker16 broad screen improves Map, record aggregation, lexer and active ray strongly, but displaces already successful implementations of other programs. The list pipeline changes from a fused scalar loop to materialized lists; the numeric loop loses its compact direct loop; the expression evaluator loses its producer and reusable-frame fold; bitonic sorting loses its flat closed graph. Their public dependency fences grow from 6/3/4/15 entries to 60/57/58/69. These are useful diagnostics of displaced compiler capabilities, not selectors in the proposed implementation.

Prioritizing every old scalar region would also lose substantial gains: the old lexer and active-ray regions still dispatch residual generic calls. The broad screen reports approximately 4.93× and 16.27× improvements there. The compiler must distinguish a completed transformation from a partial region with residual calls.

A separate origin effect appears in four small standard-library programs. Their only changed public assignments are native-source `U32.show`, `Nat.show`, and/or `Map.diff.chr`; replacing those assignments with their Phase44 forms reconstructs the entire Phase44 modules exactly. All are alias-only additions rather than contextual instantiations. These tiny wrappers acquire 58–60 guard dependencies. They also register the modules' first `exactCode` descriptors, enabling an additional generic invocation check throughout the module. RLE does not execute its changed show wrapper through the benchmark entry, so guard execution alone cannot explain its timing movement.

## Typed selection rule

`JRootPlan{code, strong}` records an emitted candidate and the strength already established by its successful planner. A region is strong when any of these existing transformations actually succeeds:

1. Total scalar fusion.
2. A valid region with no `JResidual` helpers.
3. A flat closed graph, after every existing flat audit and the final `j_flat_active` check.

A successful `JPure` proof alone does not establish the third condition. Rejected or partial flat plans remain weak. Selection preserves the existing specialized Nat-loop, tree and callback proofs, then prefers a strong region, then the general private worker, then a weak region and the existing generic fallbacks. Every selected old implementation retains its previous component declaration and public fallback.

The actual region and flat planners return the typed result; ranking does not scan emitted text or repeat their analysis. The sole flat-root caller has already attempted identical whole-root fusion, so its redundant second fusion attempt is removed. The old global-selection wrappers `j_tree_global`, `j_region_global`, `j_region_root`, and the now-unused `j_fusion_root_body` are retired, together with the temporary string accessor. A whole-source reference scan confirms no remaining callers; historical proposals and Phase42 documentation are retained as historical evidence.

For native-source public roots, the collector additionally requires nonempty original contextual rows. This requires real contextual specialization while declining the newly introduced alias-only public wrappers. It includes prior contextual cases, but is not identical to the old root-local erased-call prefilter: a native-source root with an erased call only downstream can qualify through its complete collected graph. Native-source functions remain eligible as private callees inside larger complete graphs. The rule uses existing trusted `KDef.native` provenance, not a source path or function name. It is a conservative profitability policy, not a prediction of all library workloads.

## Safety and scope

All existing graph, ownership, exact-call, layout, host and public-mutation guards remain inside their original emitted implementations. Worker roots retain the contiguous-leading-lambda legality check from P45-013b. Selection carries successful facts; it does not relax any proof, remove guards, introduce result caching, or change private callee eligibility.

The isolated patch touches only `region.bend`, `tree.bend`, `emit.bend` and `jpure.bend`, adds 27 net physical lines, and adds no module or manifest entry. It is based on frozen `selfhost/build/phase45/source-worker16`. Patch SHA-256: `ac168486cfb5e52faf974432f689be3d191a3a4345ae9536db06b4ee23305b4e`. The patch and derived source hashes are recorded in the experiment acquisition receipt when the root freezes this candidate. Patch applicability and whitespace checks pass; no compiler or benchmark was run by the author of this patch.

## Validation and decision

First build the exact isolated candidate and retain failed acquisition evidence if any. Then compare emitted assignments: the four displaced strong roots should recover their existing specialized forms, the residual lexer/ray regions should retain private workers, and the four tiny modules should recover their earlier native-source public assignments. This structural screen is necessary but does not establish correctness or speed.

Run maintained semantic/host-mutation controls and the worker graph, deep-stack, ABI, constructor and Number-Nat controls appropriate to the selected implementations. Repeat the broad representative screen with fresh predecessors and fixed inputs. The success criterion is recovering the observed regressions without losing the large general-worker wins; no gain is claimed before those measurements.

Longer term, move fusion, aggregate forwarding, compact continuation frames and direct numeric loops into composable worker-IR passes. Typed selection preserves their functionality during that migration; it is not the final replacement for general optimization passes.

## Acquisition 17: retained bootstrap failure

The first isolated build stopped during compiler bootstrap in approximately five seconds. `j_flat_root_scope` introduced `+normal = JRootPlan{...}` without a local type annotation; the bootstrap front end cannot infer that constructor expression. It reported “expected: an annotated term (cannot infer)” at that binding. This is an acquisition/type-check failure, not a generated-program semantic result.

The consumed `source-worker17` and `checked-worker17` remain unchanged. Successor 17b adds only `+normal: JRootPlan = ...`. A full scan of the patch found no other newly introduced unannotated constructor-valued locals: the remaining new local calls a Bool-returning helper, and other constructor expressions have explicit result contexts. Root owns the corrected build and validation. The original patch hash above continues to identify the failed first candidate rather than silently relabeling it.
