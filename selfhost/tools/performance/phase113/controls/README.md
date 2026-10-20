# Independent Phase113 source controls

`manifest01.json` freezes twelve actual Bend sources and complete independent
execution observations before candidate runs. No compiler, generated program,
API acquisition or benchmark was executed while preparing these controls.
Source acceptance remains an explicit gate; a newly authored fixture rejected
by the original checked compiler is a fixture issue, not a candidate regression.
Preserve the refusal and version any corrected source/oracle instead of changing
this frozen manifest.

The scalar recurrence oracle uses Python mathematical integers modulo 2^32.
Other success outputs follow literal source inputs, index selection, rotations
and elementary arithmetic. It never imports the compiler, its AST or generated
code. The unchanged strict-unused-overflow source and its exact runtime error
come from the independently retained Phase112 failure contract. It must compile
successfully and fail at **execution**, not parser/type/IR admission. Expected
failure is exit1, empty stdout and the complete pinned Nat-overflow diagnostic.

| Source | What an incorrect optimization could change |
|---|---|
| `scalar-closed-loop` | Closed callee scalar results, U32 wrap, empty/deep loops |
| `tail-argument-permutation` | Parallel argument transfer overwritten by sequential assignments |
| `closed-branch-suffix` | Wrong result kind or value at a branch join/shared suffix |
| `scalar-shadow-nested-arguments` | Confusing shadowed binders, stale aliases or nested call results |
| `array-scalar-return` | Field order, scalar width or owner lost across two returned products |
| `array-shared-swaps` | Copy-on-write, swaps and release order corrupting a shared original |
| `string-field-alias` | Flattened owned fields dropped early or surviving aliases corrupted |
| `owned-capture-call` | Escaping captured owner incorrectly treated as an ordinary scalar call |
| `non-tail-reconstruction` | Unsupported non-tail self-recursion incorrectly turned into a loop |
| `product-escape-branch` | Escaping products or branch-selected owners losing their boxed boundary |
| `lazy-branch-no-overflow` | Evaluating a delayed unselected overflow branch |
| `strict-unused-overflow` | Erasing a strict actual because its formal parameter is unused |

The non-tail/closure/escaping sources are **positive language programs** requiring
generic fallback where the proposed direct slice is unsupported. Passing their
stdout does not prove optimization admission/refusal, ownership credit balance,
allocation freedom or stack bounds. Structural admission observations and
negative IR/signature mutations remain separate gates when those interfaces are
ready. The 100,001-step loops are finite depth observations, not a general stack
or termination proof. This suite is small and independent of benchmark names;
it does not replace the original45 corpus.

Root can create a target-free plan for the existing serial job supervisor:

```sh
python3 -B selfhost/tools/performance/phase113/controls/prepare-jobs.py \
  --api selfhost/build/phase111/p112-facts-api02/api.mjs \
  --runtime selfhost/build/phase111/runtime-source04/runtime.o \
  --prefix selfhost/build/phase111/p113-controls-baseline01 \
  --out selfhost/build/phase113/controls-baseline-plan01.json
```

Use `--all` for twelve sources or `--names NAME ...` for a chosen group. Root
executes the resulting jobs under its one CPU3 process-tree guard. The plan
reuses unchanged Phase111 `emit.mjs` and `build.py`, then Phase112 `observe.py`
for exact status/stdout/stderr. It does not execute a program once during build
and again during observation. One plan is a semantic gate, not a timing benchmark.
Create a separately named plan/prefix for the candidate. Every output path is
fresh; historical references and expected outputs remain immutable.

Run `python3 -B selfhost/tools/performance/phase113/controls/oracle.py` to check
the expectation files offline. Its original `--write` mode refuses existing
oracle paths. The method and every source/oracle are hashed in the manifest.

For Phase113 static/direct comparisons use `prepare-jobs-v2.py` with the same
arguments and `--pipeline static` (default) or `--pipeline direct`. It selects
`phase113/staged-emit.mjs`, validates the exact staged API exports, and records
its own method hash. The original frozen preparer remains unchanged for
provenance; its `p111_compile_source` entry uses the generic fallback and must
not be used to attribute a direct optimization. The source and oracle pins are
identical in both methods.

`direct-ir-manifest01.json` pins `direct-ir-controls.mjs`, an independent
45-case verifier and guarded-emission suite. Root runs it with a complete
checked API exporting `p113d_verify` and `p113d_chunks`, then a fresh Phase113
output directory. Eleven structurally valid controls and 34 refusals cover
call topology, joins, vectors, reserved state/scratch, scheduler exclusion and
public ABI preservation. The script retains each raw IR, diagnostic and emitted
text. Its deliberately artificial original segments must **never execute**.
The emitted two-result buffer and parallel-move checks inspect syntax only;
source/runtime controls establish separate execution evidence.

`array-pair-manifest01.json` freezes ten positive runtime boundary cases and
six required fail-stops. Build its C source using the recipe in the manifest
and the additive profile11301 runtime. Inside the root CPU3 guard, run:

```sh
python3 -B selfhost/tools/performance/phase113/controls/run-array-pair.py \
  --binary FRESH_BOUNDARY_BINARY --runtime ADDITIVE_RUNTIME_OBJECT \
  --out selfhost/build/phase113/array-pair-boundary01
```

Every positive checks both the original boxed Tuple route and the flat helper
against literal Unicode strings and scalar values. The cases exercise get,
swap, clone, size, input/output overlap and release order. Cloned arrays share
cell contents but have distinct handles. The supplemental
`array-shared-handle-manifest01.json` instead checks true reference-counted
shared handles: mutation remains visible through both aliases, and the removed
String survives releasing both roots. Build `array-shared-handle.c` with its
own manifest recipe; use `run-array-pair-v2.py --manifest` to select that
manifest, with the same binary/runtime/output arguments. The original frozen
files remain unchanged. These finite observations do not prove allocator
balance or universal ownership correctness. No target was executed by the
control author while preparing either suite.
