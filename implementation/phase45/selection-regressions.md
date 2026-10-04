# Phase45: isolate small-program selection regressions

Worker16 improves several larger programs but makes some small imported helpers
more expensive. The four small-program regressions below have an unusually narrow
source difference: only newly selected public worker entries for three Base
definitions changed. Restoring those assignments reconstructs each **entire
Phase44 module byte for byte**. No compiler source was changed by this analysis.

## Measured screen

`selfhost/build/phase45/runtime-worker16-screen4/report.json` records three fresh,
role-rotated rounds, 350 ms warmup and a 150 ms sample target, on CPU 3 with
Node 24.18.0, a 1 GiB heap, 2 GiB process-tree RSS limit and 4096 KiB stack.
These are execution medians; compilation and import are outside the timed calls.
Every sample returns its expected result. The timed export is `main.out`, not
the IO `main` wrapper.

| Program | Phase44 ms | Worker16 ms | Worker16 / Phase44 |
| --- | ---: | ---: | ---: |
| Morning | 0.230969 | 0.492777 | 2.13352× |
| Evening | 0.159523 | 0.400746 | 2.51215× |
| Map/set operations | 1.988139 | 3.028284 | 1.52317× |
| RLE roundtrip | 0.048194 | 0.052106 | 1.08118× |

These short screens identify regressions to investigate, not steady-state costs
or a new overall benchmark score. In particular, candidate RLE samples drift
+53.05% to +53.86% between their first and second halves; baseline RLE spans
−36.12% to +62.60%. Morning's baseline also has substantial within-sample drift.
The small RLE difference deserves especially cautious interpretation.

## Complete source isolation

The analysis parses the complete baseline and candidate modules with Node's
bundled Acorn. It identifies unique assignments to `G`, compares their complete
AST ranges, then replaces only differing candidate ranges with the corresponding
baseline assignments. It asserts equality of every UTF-8 byte in the reconstructed
module, including code outside those assignments.

| Program | Only changed assignments | Bytes added | `exactCode` calls, before → after | Complete reconstruction |
| --- | --- | ---: | ---: | --- |
| Morning | `Map.diff.chr`, `U32.show`, `Nat.show` | 9,942 | 0 → 3 | Exact |
| Evening | `Map.diff.chr`, `U32.show`, `Nat.show` | 9,942 | 0 → 3 | Exact |
| Map/set | `Map.diff.chr`, `U32.show` | 6,814 | 0 → 2 | Exact |
| RLE | `U32.show` | 3,136 | 0 → 1 | Exact |

All three definitions come from the pinned Base library. None of the fixture's
own definitions changed. The assignment sizes grow from 182 to 3,860 bytes for
`Map.diff.chr`, 207 to 3,343 for `U32.show`, and 260 to 3,388 for `Nat.show`.
Their private entries check 59, 58 and 60 descriptor names respectively, including
the entire U32/F32 primitive family, plus the host and String guards.

The original static record remains frozen. The new reconstruction receipt is
`selfhost/build/phase45/tiny-entry-analysis16-v2.json`, SHA-256
`31b28b6544065dada9521a43e0741f19989b036df4e66d50b6e16417630d304d`.
It contains complete module and assignment hashes, AST ranges, reconstructed
hashes equal to all four baseline hashes, guard lists, parser/Node identities,
and the timing samples whose module hashes match the analyzed artifacts.
Its adjacent `tiny-entry-analysis16-v2.mjs` reproduces the static check without
importing or executing a generated program. The timing receipt hash is
`4d708732d66f47fd5f882d92fe0f82b3b6e1563ed2a48763235ee6504679db9a`.
These raw paths are local evidence, not committed release artifacts.

## What this establishes and the next decision

The source isolation is exact; the attribution of runtime cost remains a
hypothesis. Morning and evening execute the new number-to-text entries; map/set
executes `Map.diff.chr`. Their small computations can pay more for entry guards
than they save in private execution. The old `U32.show` contains an inline
`U32.is_zero` primitive; it is not itself a complete primitive replacement.
All three helper graphs recurse, so merely requiring a recursive graph would
not prevent these selections.

RLE provides a separate warning: its timed `main.out` does **not** call `U32.show`.
Registering that otherwise unused exact-code wrapper nevertheless sets the
module-wide `hasExactCodes` flag. Generic `invokeExact` calls then perform a
WeakSet membership check instead of taking the former fast short circuit.
This is a plausible dispatch cost even without worker entry; source inspection
does not establish how much of the noisy RLE timing difference it explains.

The proposed immediate policy keeps earlier contextual-erasure entries, but
declines new alias-only public entries for trusted Base definitions. The same
definitions remain eligible as private callees inside an admitted user graph.
This uses existing provenance, not function names: `db(d)` returns the native
flag, and the loader sets that flag on every Base declaration. Test the original
instance rows before alias rows are added; otherwise this distinction is lost.
User-defined monomorphic roots remain eligible. This is a conservative selection
policy, not a general profitability model.

In parallel, prefer an already proved complete fusion, numeric or flat graph
plan over a weaker general worker. Longer term, carry the actual primitive and
host dependencies through the IR and compare guard cost against expected work.
The next causal check is to regenerate these four programs after the selection
change, verify the intended assignment choices, and rerun the same small screen
alongside the larger worker gains. No recovery is claimed here before that run.
