# Independent physical-graph and fast-loop audit

At **2026-10-18 19:20:34 UTC**, `manifest.json` freezes six control families,
seven concrete graphs and fourteen complete-value observations. Three graphs
(six drop-order observations) are training controls. Four graphs (eight
observations) are fresh supplemental held-outs. The earlier Phase110 held-out
workloads become reused regressions for these new candidates.

The proposed laws explicitly account for distinct child cells and a distinct
incoming owner. They do not prove the physical cases here: one object can have
multiple edges into the reconstructed graph, including edges reached through
the incoming `other` argument. Both result-first and remaining-first release
orders observe the surviving owner and then every independent alias.

`operator-controls.c` contains graph preparation, generic runtime-operation
calls and observers. It never implements a Bend source worker. Its default
callbacks call the qualified C pair adapter; compiling with `P110_AUDIT_IR`
selects the ABI agent's `nx_ir_probe_c1_k0`, `nx_ir_probe_c1_k1` and
`nx_ir_probe_c3_k0`, which use the same classifier/rebuild generator as actual
source workers. Those test probes transfer their second owner through scratch0.

The root runner must link the private runtime materialization plus the
test-only `runtime-ir/probe-runtime.inc.c` adapter when using IR callbacks.
Both modes include `abi-private.h`, because allocator controls inspect the
actual class0 HOT/LEN/COLD words. They prepare allocator states using ordinary
public constructor/keep/sink operations; they never fabricate a heap or mutate
free-list metadata. The handoff case retains at most 32,768 one-character
padding roots, not a deep or expensive source workload.

Each probe takes `GRAPH result-first` or `GRAPH remaining-first`; graph names,
splits and complete preparation recipes are in `recipes.json`. Run training
first. Preserve the eight held-out observations until candidate selection.
Compare a saved observation without executing any target:

```sh
python3 selfhost/tools/performance/phase110/controls/audit/check.py \
  --case remaining-is-other --drop-order result-first --stdout CAPTURE.stdout
```

The frozen manifest's `sourceInputs` record source inspection context. They are
not dependencies of the independent oracle and do not prevent a new candidate
source version. Each actual execution must separately pin its compiled template,
runtime, toolchain and probe binary. `harness`, `recipes` and `expected` remain
immutable; repairs require a new evaluator version and preserved failed attempt.

`fast-loop-v2.json` predeclares a follow-up measurement schedule, separate from
the completed original twelve-choice search. Repetitions are calibrated from
that search's fused-QBE medians toward a 5 ms baseline worker clock: respectively
6, 3, 6, 1, 7, 1 and 3 for its seven training workloads. Graph contents, physical
ownership, weights and three rounds remain unchanged. The old search receipts
are untouched. The estimated 32.9 s process cost is a linear projection, not a
measured speedup; longer confirmation remains necessary for close/noisy wins.

## Inline Take2 supplement

`take-manifest.json` freezes twelve generic take graphs and twenty-four
complete-value observations at **19:35:14 UTC**. List and String parents cross
raw dynamic, last-owner redirect, shared and static ownership. Further cases
cover a heap-wrapped static parent, overlapping child subgraphs, empty class1
free lists and the exact class1 32,766→32,768-word handoff boundary. Both child
release orders preserve the remaining child and all retained aliases.

`take-controls.c` defaults to `nx_rt_pair_take2`; with `P110_AUDIT_IR` it calls
`nx_ir_probe_take2`, then reads scratch0. Link a runtime exposing pair-take and
the private test adapter. Class1 padding uses at most 16,384 ordinary raw String
roots, with read-only inspection of HOT/LEN/COLD. No allocator cells are forged.
The eight basic graphs/sixteen observations are training; the four additional
graphs/eight observations are fresh held-outs. A saved single result can be
checked using `check.py --kind take --case string-raw --drop-order field0-first
--stdout CAPTURE.stdout`.
# Wrapper-spare supplemental controls

`spare-manifest.json` freezes seven additional graphs and fourteen complete
value/lifetime observations. `spare-controls.c` uses the same rebuild probe ABI
with `P110_AUDIT_IR`; add `P110_AUDIT_SPARE` for candidate-specific mechanism
assertions. Without that second define the production helper is a semantic
reference, including the handoff graphs where its allocator transition differs.

Eligible cases have a dynamic String parent behind a count-one redirect and a
raw dynamic or raw static other. The result's stored other must take ownership
of exactly that consumed wrapper, with count one and the original other target;
class0 HOT/LEN/COLD must remain unchanged. Both raw kinds are also tested at
LEN32767, where freeing before allocating would otherwise cross the handoff
boundary. Existing other redirects with count one or two are ineligible and
must retain their term while the parent wrapper is freed normally. A shared
parent must preserve its independent alias and cannot donate its wrapper.

All results are "az", all remaining children "b", and all external aliases are
observed after both result owners are dropped. The scalar retained String head
ensures its seal does not allocate, making allocator invariance specific to the
spare operation. Two ordinary cases are training; the static/handoff/shared
graphs are fresh supplemental held-outs. Check saved output with
`check.py --kind spare`; source preparation performs no target execution.
