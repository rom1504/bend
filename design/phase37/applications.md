# Phase37 application coverage selected before optimization

This is a frozen selection rationale, not a claim that these programs cover all
of Bend. The Phase36 catalog contains thirteen distinct programs at fifteen
points. Its six original algorithm bodies are useful but mostly have one input,
and its four mixed upstream tests are smoke-sized. Adding input variants alone
would leave important program shapes absent. This proposal therefore adds eight
program families, each at two preselected inputs, before the next optimizer is
chosen from the measurements.

The original catalog remains a historical regression set. The additive catalog
owner combines these fixtures with additional input variants of the original
algorithms. A case is one program/input pair, not a distinct program. Runtime
results must state both counts and keep generated JavaScript execution separate
from compiler throughput, correctness suites, native backends and GPU execution.

## Selection and coverage

| Family | Fixed `(size, seed)` points | New workload dimension | Partition |
| --- | --- | --- | --- |
| Captured closure chain | `(64,17)`, `(256,123)` | Dynamically build and apply composed affine functions, capturing a different word in each closure | Development |
| List pipeline | `(128,17)`, `(512,123)` | Generate a list, filter, map and fold through several traversals | Development |
| Unicode text | `(16,17)`, `(64,123)` | Greek, CJK and supplementary-plane emoji; split into a list of strings, then join and observe the complete text | Development |
| Map churn | `(32,17)`, `(128,123)` | Many distinct keys, replacement, deletion and ordered observation of every surviving key/value | Development |
| Numeric recurrence | `(256,17)`, `(1024,123)` | Separately rounded F32 operations, F32-to-U32 conversion and a wrapping digest of every iteration | Development |
| BST insertion | `(32,0)`, `(64,17)` | Zipper state, a maximally skewed ascending input and an irregular insertion order | Holdout |
| Expression interpreter | `(32,17)`, `(128,123)` | Build and evaluate an unbalanced AST with varying constructors and shallow side branches | Holdout |
| Record aggregation | `(64,17)`, `(256,123)` | Compose text generation, numeric parsing, aggregation into sixteen Unicode-named departments and complete report rendering | Holdout |

The names and point IDs are in
[`oracles.py`](../../selfhost/tools/performance/phase37/fixtures-new/oracles.py).
Sizes were chosen from source inspection, before timing either compiler on the
new inputs. The larger points increase real input size; repeated executions are
not described as larger datasets. The closure count, list length, map key count
and record count all reach beyond the old smoke tests. These remain small enough
for a bounded sequential JavaScript comparison. A size rejected for stack,
memory or time remains evidence; a corrected smaller point needs a new catalog
version and cannot silently replace it.

There is no population-weighted application average. Each family is a deliberate
mechanism sample. Multiple points from one family are related observations, not
independent demonstrations of transfer.

## Source provenance and semantic boundaries

Five fixtures consist of the complete unchanged pinned upstream file followed
by a wrapper. The pin remains
`018751270e800bc222a93dad7f257083ee53a5f7`:

| Fixture | Original source |
| --- | --- |
| `closures.bend` | `tests/run/closures_hof.bend` |
| `list-pipeline.bend` | `tests/run/list_map_fold_ops.bend` |
| `bst.bend` | `tests/run/bst_insert.bend` |
| `unicode-text.bend` | `tests/run/string_algorithms.bend` |
| `expression.bend` | `tests/run/expr_interpreter.bend` |

[`upstream-provenance.json`](../../selfhost/tools/performance/phase37/fixtures-new/upstream-provenance.json)
records the original Git blob, SHA-256, byte count, exact appended wrapper and
complete source identity. The oracle generator checks that each original prefix
still matches. Original `main.out` goldens remain in the source, but are not
incorrectly reused as oracles for the new dynamic wrappers.

The closure wrapper calls upstream `chain` with the dynamic size and applies its
result to the dynamic seed. It does not replace the closure computation with its
closed-form sum. The list wrapper generates new words and calls the original
filter, map and fold. The Unicode wrapper builds repeated mixed-script blocks
and calls the original split/join implementation; the returned string itself is
the observation, including trailing delimiters and the non-BMP character.

The BST wrapper uses upstream `bst.down`, `insert.fin` and `inorder`, supplying
`size + 1` fuel instead of the original smoke test's constant eight. The original
`insert` definition remains unchanged. That distinction matters: extending the
input with constant-eight fuel would stop insertion prematurely on a skewed
tree. Seed zero inserts ascending distinct keys; seed seventeen permutes their
order modulo257. Both current sizes stay below257. The expression wrapper builds
a left-deep structure with a varying shallow right subtree and then invokes the
original evaluator. These are distinct shapes from the balanced symbolic
regression generator already optimized in Phase36.

The other three fixtures are new independent application-shaped programs using
the unchanged pinned `Base` library. `map-churn.bend` inserts every key, replaces
every third value and deletes every fourth key; its digest walks all remaining
ordered keys and values. `numeric-recurrence.bend` uses only U32, Nat and F32,
not an unsupported claim of broad numerical-type coverage. Its positive bounded
F32 recurrence avoids transcendental accuracy tolerances; every primitive must
round independently. `record-aggregation.bend` generates numeric fields as text,
parses each one, accumulates map values and renders every final aggregate. It
does not parse CSV framing, perform IO, or represent a real production dataset.

## Independent references and execution protocol

The root generates the versioned point proposal with:

```sh
python3 selfhost/tools/performance/phase37/fixtures-new/oracles.py \
  --out selfhost/tools/performance/phase37/fixtures-new/points-v1.json
```

The generator refuses to overwrite existing output. It reads fixture bytes but
never imports either Bend compiler or any emitted JavaScript. It writes sixteen
timed points and thirty-two small validation points: `(0,0)`, `(1,0)`, `(2,17)`
and `(7,123)` for each family. These exercise empty, singleton and mixed cases;
they are correctness observations, not extra runtime cases.

References use different representations from the Bend algorithms:

- Closure composition is checked against the closed-form triangular sum.
- List traversal is checked with Python integers and list comprehensions.
- BST insertion plus inorder is specified by sorting the generated values.
- Unicode split/join is specified by native code-point string replacement.
- Expression construction/evaluation is specified by a bottom-up scalar
  recurrence without any AST allocation or recursive interpreter.
- Map operations use a Python dictionary and independently ordered digest.
- F32 operations use `struct` binary32 round trips after each primitive and
  Python integer wrapping; no compiler-generated result seeds the reference.
- Record aggregation uses a Python dictionary and complete report string.

Digest comparisons can collide. They establish the stated scalar output, not
complete internal-state equivalence. The two string-returning families observe
their complete returned values. Relevant optimizer-specific controls must still
test complete structures, demand/error ordering, sharing, public mutation and
actual optimized entry; benchmark agreement cannot replace those controls.

Both the Phase36 checked compiler and the pinned TypeScript compiler must first
compile the exact fixture identities and pass their output references. Root
alone performs builds, correctness runs, timings and profiles, serially under
the existing CPU3, 1GiB heap, 2GiB process-tree ceiling and 2GiB free-memory floor.
Agents only prepare sources, provenance, references and design. Emission and
startup are excluded from execution timing and reported separately where
measured. Profiles and syntactic analysis are separate from clean timing.

All holdout sources and points are frozen before candidate selection. They may
be compiled and correctness-checked beforehand; their candidate performance
results are measured only after the optimization is frozen. No candidate tuning
uses those timings. If a holdout regression leads to another change, that case
has become development evidence and must be described accordingly; it cannot
continue to be advertised as an unseen holdout. Holdouts are public and chosen
by us, so this is a procedural defense against repeated tuning, not a blind
external evaluation.

## Remaining exclusions

This adds useful dimensions without covering all possible interactions. It
still lacks complete real-world applications, external IO/FFI cost, substantial
long-lived heap pressure, streaming inputs, adversarial Unicode normalization,
large graph algorithms, heavy sharing across heterogeneous structures,
significant partial-application/oversaturation workloads, native/C/Metal/CUDA
throughput, concurrency and GPU scheduling. Correctness gates can exercise
several of these semantics but do not supply their missing performance data.
Further additions should respond to a documented coverage gap or an independent
application, rather than repeatedly adding variants of whichever optimizer
just improved most.
