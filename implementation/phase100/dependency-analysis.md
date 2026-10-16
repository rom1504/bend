# Dependency planner: usefulness, cost and next invariants

The [application](../../selfhost/apps/dependency-plan/README.md) turns a runtime graph file and requested targets into a complete prerequisite-first plan. It deduplicates shared subgraphs and reports missing dependencies or cycles with the active root path. This is a usable dependency-planning component: a build tool can select stale targets and consume the resulting order. It does not inspect timestamps, execute build commands, or provide an indexed database for very large projects. Handled graph errors are stdout records; callers must inspect the first record rather than rely on a nonzero exit status.

The implementation exercises file effects, parsing, String comparison, irregular graph traversal, sharing, explicit state, and complete formatted output. The graph and roots are runtime inputs. The native result is therefore an application result rather than a fixed-answer arithmetic loop or a compiler self-compilation result.

## Measured scope

[Smoke02](../../selfhost/build/phase100/dependency-smoke02/report.json) passed 20 complete-output executions over ten valid/invalid cases. [Survey01](../../selfhost/build/phase100/dependency-survey01/report.json) passed all 40 complete-output executions: five generated graphs, four alternating pairs per graph, two native program products, one worker pinned to CPU 3. The larger points are:

| Runtime graph | B2-emitted program median | Upstream-emitted program median | B2/upstream |
| --- | ---: | ---: | ---: |
| Shared DAG, 800 nodes | 0.230263 s | 0.692871 s | 0.332332 |
| Chain, 1,000 nodes | 0.230011 s | 0.633725 s | 0.362951 |

These are whole application process measurements, including graph reading, parsing, planning and complete stdout. Both products come from the same Bend source; this phase made no compiler change. The 100/350-node DAGs and 511-node tree also pass, but their B2 medians are below 0.1 s and are weaker timing evidence. This is one machine and a small size range, not a general compiler ranking or an asymptotic scaling measurement.

[Acquisition02](../../selfhost/build/phase100/dependency-acquire02/report.json) records identical B1/B2 C. The inspected [B2 C](../../selfhost/build/phase100/dependency-acquire02/dependency-plan/b2.1.c) is 748,255 bytes, SHA `282200231763264bbb725b0eaf82d9ea2db4bde25c2a6b14a80fa46f4e6d2d34`; [upstream C](../../selfhost/build/phase100/dependency-acquire02/dependency-plan/upstream.1.c) is 249,345 bytes, SHA `c661d7b37f2e1d13d2006d3ebc54a250eb12d87c64cb2736b567f9a2ba79caed`. Source size is not executable size or a speed explanation.

## Algorithmic cost remains visible

Parsing tokenizes lines, validates bounded ASCII names, and uses a linked-list lookup to reject duplicate declarations. Planning uses explicit `DPEnter`/`DPExit` work records, an active path, a completed-name list and reversed postorder. Entering a completed target skips it; entering an active target reports a cycle. Dependencies are pushed before their target's exit, so successful exits produce prerequisite-first order. Unreachable missing edges/cycles do not prevent an unrelated plan; syntax/duplicate errors are checked over the entire file.

Let `C` be input characters, `L <= 128` the maximum name length, `V,E` all declared nodes/edge occurrences, `R` requested roots, and `Vr,Er` the reachable subset. Parsing costs `O(C + L*V²)` because duplicate checks scan prior declarations. Traversal has `O(R+Er+Vr)` work records, but graph lookup and active/completed membership scan lists. A conservative bound is `O(L*(V*Vr + Vr*(Er+R)))`. Live algorithmic storage is `O(C+V+E+R)`, apart from backend/runtime overhead.

For the bounded-fanout generated DAGs and the chain, `E=O(V)`, so these list operations still permit quadratic time. The measured backend advantage does not change that fact. Faster comparisons cannot make a linked-list membership test constant-time.

The first application-level improvement for substantially larger graphs is interned numeric node IDs, indexed adjacency, and color/status storage. A map or sorted index can also remove quadratic duplicate checking during parsing. With a suitable index, the graph traversal itself approaches `O(Vr+Er+R)`; ordering and diagnostics must retain their current semantics. That is a data-structure change, distinct from compiler optimization, and has not been implemented or measured here.

## What the emitted C establishes

- B2's `$direct.String.cmp` entry (C line 15,381) calls the observer adapter under `NATIVE_READONLY_OBSERVERS`. Its worker (line 2,252) reads via `term_peek` and advances equal-character cursors with `goto nf_again`; the adapter preserves the original String roots for the result. Upstream `FID_STRING_CMP` (line 4,749) instead consumes String nodes and reconstructs them, including continuation `FID_STRING_CMP_K203`. Repeated name comparisons give this difference a plausible application-level role, but there is no isolated toggle/profile attributing the timing ratio to it.
- Both products still consume list nodes in `dp_contains` and `dp_lookup`. B2's direct entries are at lines 14,867 and 17,992; upstream's are at lines 2,129 and 1,937. B2 emits no `$observer.dp_contains` or `$observer.dp_lookup`. A borrowed character walk does not eliminate outer-list traversal or ownership work.
- Both `dp_choose` implementations dispose the unselected closure and invoke the selected closure. B2's direct entry is at line 7,409; upstream's is at line 4,874. Saturated known-closure branch lowering is consequently a general candidate for this application, with capture lifetime and demand preservation required.
- Upstream already passes flattened `DPUpdate`/`DPState` components through `dp_walk`/`dp_step`; B2 passes the carrier and consumes a five-field `DPState`. Unboxing private loop carriers or fusing adjacent producers/consumers is another candidate. Its presence in the slower product is also a reason not to infer whole-program performance from one favorable C feature.

The focused compiler opportunities are therefore exact-type borrowed list observations, general branch-closure elimination, and private state-carrier/continuation simplification. `dp_contains` has a scalar result, while `dp_lookup` returns an owned node: the latter additionally needs a child-retention/escape contract or caller fusion. None can safely replace the graph's list representation with a map automatically, and none has a measured improvement in this report.

## Next useful law

The strongest next target is a preservation invariant for the pure `dp_step` transition, followed by a theorem for `dp_walk`. Assume unique valid declarations. The state invariant should establish that the active path is duplicate-free, completed names are unique and disjoint from active names, pending exits align with active ancestors, and each completed target follows all its reachable prerequisites in accumulated postorder.

From that invariant, prove: a successful result contains exactly the requested reachable closure, contains each target once, and places each dependency before its consumer. A cycle result should carry an actual root-to-repeat edge path whose repeated endpoint yields a directed cycle; a missing result should end at an undeclared name after valid edges. The current exit step pops the active head without comparing its name, so the exit/active alignment obligation is concrete and necessary.

A companion progress argument should justify fuel `R+E+V+1`: every root/dependency occurrence introduces at most one enter record, each newly reached target at most one exit, and one step observes completion. Already completed results remain valid at zero fuel. This establishes bounded completion and rules out spurious internal-budget errors; a termination check alone does not establish topological correctness.

The Python oracle uses dictionary adjacency and recursive three-color DFS, unlike Bend's work stack/fuel. Complete-output comparison catches ordering, duplication, paths, counts and formatting errors on the tested inputs. Different implementation structure reduces correlated mistakes, and adversarial shared/cyclic cases are valuable. Finite cases still do not prove the state invariant for every allowed graph, exclude shared specification errors, or prove emitted-C ownership, file effects or concurrency sound.

## Broader application picture

The sibling [image renderer](../../selfhost/apps/image-render/README.md) supplies independent pure row work with deterministic joins; [source-index](../../selfhost/apps/source-index/main.bend) supplies runtime text scanning and lexical state. Together with dependency planning they cover different demands instead of relying on compiler self-speed alone. The planner's shared DFS state is deliberately sequential: extra runtime workers are a serial-workload control, not an expected scaling mechanism. Independent queries or a level-based graph application would require a separate design and measurements.
