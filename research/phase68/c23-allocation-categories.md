# Compiler23: what the extra native allocations contain

This source-and-counter audit separates product transport, application data,
closure environments, runtime reference-count redirects, and task nodes. The
most actionable new finding is a missing **general static constructor image**:
the lexer rebuilds an immutable 39-character template for every generated line,
where upstream stores that constructor graph once. Map's extra allocations are
predominantly product transport and redirects, not extra map nodes.

This is an investigation of compiler23, pinned to the exact generated C in the
counter report. It changes no compiler or runtime. Allocation counts below are
**not runtime percentages** and do not prove that every counted allocation can
be removed. Timing and any saved-C ablation results belong to the phase report.

## Evidence and reproducibility

- Raw counts: `selfhost/build/phase68/parity-survey23-counts01/report.json`, SHA256
  `9711a8bb7ba2bcb7ae50688753e30525a5321187e6907848985574fe1601aa26`.
- Portable classifications: [c23-allocation-categories.json](c23-allocation-categories.json).
- Source recognizer: [classify-allocations.py](../../selfhost/tools/performance/phase68/parity-survey/classify-allocations.py).
- Related architecture audit: [c23-upstream-mechanisms.md](c23-upstream-mechanisms.md).
- Upstream implementation: pinned `059266225b77c8ca256ac6b25ee5c21449bab151`,
  `selfhost/.bootstrap/upstream-phase66/bend2/comp.ts`.

From the repository root, regenerate the classification without executing a
compiled benchmark:

```sh
taskset -c 0 python3 selfhost/tools/performance/phase68/parity-survey/classify-allocations.py
```

The classifier verifies each source SHA and allocation-site line against the
original C, then associates the allocation variable with its explicit
`term_ctr(CID, variable)` or `term_clo(FID, variable)` consumer in that lexical
scope. Multiple consumers must agree. Runtime sites are classified by exact
`rfc_wrap` / `task_node` function identity. Unrecognized or ambiguous sites stay
in an explicit unknown bucket. All source pins and consumer lines are retained
in the JSON. This is a restricted generated-source recognizer, not general C
alias analysis.

Each number is the signed **17-repetition run minus 1-repetition run**. Both
runs passed their output oracle. This cancels much fixed work but includes
changed formatting and scheduling work; some formatting sites have a negative
delta. Category totals exactly reconcile with the total allocation counter.
There are zero unclassified nonzero-delta sites in these eight files. That
does not prove full program semantics or identify callers of runtime wrappers.

## Counts by concrete allocation category

| Program | Category | Compiler23 | Upstream | Extra |
|---|---|---:|---:|---:|
| Tree | RFC redirect | 204,801 | 1 | 204,800 |
| Tree | Task node | 1,976 | 0 | 1,976 |
| Tree | Tuple product | 2 | 0 | 2 |
| Tree | Stat product | 12,272 | 0 | 12,272 |
| Tree | Tree nodes | 421,856 | 231,424 | 190,432 |
| Tree | String nodes | 1 | 1 | 0 |
| **Tree** | **Total** | **640,908** | **231,426** | **409,482** |
| Lexer | RFC redirect | 597,839 | 364,367 | 233,472 |
| Lexer | Task node | 12,258 | 0 | 12,258 |
| Lexer | Tuple product | 376,655 | 0 | 376,655 |
| Lexer | String nodes | 610,127 | 370,511 | 239,616 |
| **Lexer** | **Total** | **1,596,879** | **734,878** | **862,001** |
| Closures | Closure environment | 12,312 | 8,208 | 4,104 |
| Closures | RFC redirect | 3 | 3 | 0 |
| Closures | String nodes | 3 | 3 | 0 |
| **Closures** | **Total** | **12,318** | **8,214** | **4,104** |
| Map | RFC redirect | 399,130 | 208,562 | 190,568 |
| Map | Tuple product | 408,322 | 17,032 | 391,290 |
| Map | Map nodes | 138,896 | 124,992 | 13,904 |
| Map | Other constructors | 4,784 | 18,568 | −13,784 |
| Map | String nodes | 269,290 | 259,450 | 9,840 |
| **Map** | **Total** | **1,220,422** | **628,604** | **591,818** |

Unknown is zero for each program/compiler pair; those zero rows are omitted
from the table. RFC refers to a reference-count redirect object, not a product
shell or a task frame. Task-node counts do not include every scheduler action;
stack continuations need not allocate a heap node.

## Map: product transport dominates reconstruction differences

The extra 391,290 Tuples account for **66.12% of net extra allocations**. Another
190,568 RFC redirects account for 32.20%. Together these are **98.32% of net
extra allocation calls**. This does not mean 98.32% of elapsed time and does not
assign all redirects to products: the wrapper counter lacks caller attribution.

The largest candidate Tuple producers are:

| Owning generated function | Tuple allocations |
|---|---:|
| `NF_Map.bit.go.rec` | 164,360 |
| `$direct.Map.bit` | 45,328 |
| `NF_Map.bit.go.chr` | 45,152 |
| `NF_Map.bit.chr` | 45,152 |
| `NF_Char.cmp` | 33,024 |
| `NF_String.cmp.rec` | 29,328 |

These six owners total 362,344, or 88.74% of candidate Tuple allocations. The
remaining owners are in the JSON, including `Map.lo`, `Map.hi`, seek/pop
continuations, and string comparison finishing paths. Upstream's 17,032 Tuple
allocations belong to its seek continuations. Therefore, unboxing only the
public `Map.seek` result would miss most of this evidence: nested helper
products and scheduler/worker transport are the broader problem.

Actual map constructor counts are `MNode` 118,840 vs 112,744 and `MLeaf` 20,056
vs 12,248. Conversely, candidate allocates `Some` 3,248 times vs 17,032 upstream;
both allocate 1,536 `Con` nodes. Combining these differences into a single
"application data" bucket would hide representation substitutions. Keep the
separate categories when assessing a typed ABI or allocation-reuse change.

The general next mechanism remains recursive typed product layouts carried
through ordinary locals, continuation arguments/results, worker calls, and
closure captures. The existing worker result flattening is only partial; its
boundaries still rebuild boxed products. The architecture audit records exact
source entry points and a staged experiment. This is a broader change than a
library-specific rewrite.

## Lexer: static constructor graphs are a smaller, decisive experiment

Candidate `NF_../phase37/fixtures-historical/lexer:tpl` allocates exactly
**239,616 SCons**, all absent upstream. The delta adds 6,144 generated lines:
`6,144 × 39 = 239,616`. The fixture's `tpl()` returns the constant string:

```text
i = ( n o i ) o ( n o i ) o ( n o i ) ;
```

All other measured String allocation counts match between compilers:
`expand` 165,888, identifier construction 110,274, numeric token construction
63,627, operator tokens 30,720, plus two formatting/IO allocations. Therefore
**all extra String allocation calls come from rematerializing this template**.

The extra RFC count also equals `6,144 × 38 = 233,472`, the 38 nonempty tail
edges in each freshly built 39-node template. The generated body explicitly
seals each tail. This numerical identity plus source construction strongly
suggests the template also explains the entire RFC excess. It remains a
source-based inference; the instrumentation does not record wrapper callers.

Separately, the candidate lexer loop allocates 370,509 Tuple products in
`NF_...lexer:lex`, with 6,144 initial-state Tuples in `native_k_16710` and two
formatting Tuples. Upstream has no Tuple allocation at these sites. Static
data and product layout address distinct mechanisms and must be tested
independently before combining their effects.

### How upstream implements it

`emit_ctr` at `comp.ts:2263–2314` recursively emits constructor fields, computes
`v.stat` from all field values, and propagates it to a boxed construction.
`ctr_build` at `comp.ts:1028–1052` handles packed/nullary values immediately;
for an all-static boxed value it interns field words in `FL.img`, records the
constructor in `FL.stat`, and returns `term_ctr(CID, STAT_OFF + offset)`.
`FL.consts` also memoizes emitted constant values. `node_fields` uses the static
constructor fact when choosing a safe take/reuse path.

This supports **closed immutable constructor graphs generally**, including
constant products that need boxing, rather than recognizing a particular
string or benchmark. Do not generalize it to all arrays or closures: the
upstream Array emission branch is separate, and arbitrary captured values are
not all-static constructor fields.

Candidate already has `N_Program.image` in `native/ir.bend`, image size/table
emission in `native/tables.bend` and `native/emit.bend`, and runtime static
region semantics. Its current lexer image is empty (`STAT_LEN 0`,
`STAT_IMG[] = { 0 }`), while `NF_tpl` dynamically builds all 39 nodes each call.
`HEAP_OFF` accounts for `STAT_LEN`; existing `term_triv` and `spare_free` treat
static locations as non-dynamic. A new allocator is not required merely to
test this hypothesis.

### Prepared saved-C experiment and general implementation hypothesis

[static-template.py](../../selfhost/tools/performance/phase68/parity-survey/static-template.py)
prepares two immutable derivatives under
`selfhost/build/phase68/parity-survey23-static-prep01/`:

1. `static-only.c`: changes only `STAT_LEN` to 78, the 78-word `STAT_IMG`, and
   the literal worker body to return `term_ctr(CID_SCON, STAT_OFF + 76)`.
2. `static-and-bangs-zero.c`: adds only the already-isolated `BANGS 0` change.

The producer pins original source bytes, interprets the original restricted
constant construction, checks all 39 codepoints against the Bend fixture,
verifies constructor IDs, preserves entry error polling, and records exact
old/new patches. Reversing the patches must recover the original byte stream.
It preserves the original worker in `original-tpl-function.c.txt` and writes
`derivation.json`. It neither builds nor runs either target. Experiment
registration, compilation, multi-input/thread oracles and clean timing remain
the root lane's responsibility. These are diagnostic files, not a compiler
feature or proof of general correctness.

The isolated experiment should remove 239,616 String allocations; removal of
233,472 redirects is a further prediction to test. Together that is 473,088
candidate allocation calls in this count window (29.63% of candidate total),
**not a predicted 29.63% runtime reduction**. Comparing static-only with original
and the joint derivative with mode-only distinguishes interaction effects.

If the experiment pays off, add a general restricted literal-constructor image
builder in Bend, carrying staticness and exact constructor/layout identities.
Only immutable closed graphs qualify initially. Preserve runtime ownership,
static-safe pattern taking, thread sharing, target-specific layouts, constant
image limits, and fallback behavior for nonconstant fields. Repeated use,
dropping, matching, and sharing of a literal must remain correct. Estimated
effort: **30–60 minutes for the saved-C proof**, **3–8 hours for a narrow general
emitter plus focused controls**, then the broader C/JS/self-hosting gates.
These are implementation estimates, not measured compiler speed gains.

## Tree and closures: the categories support different mechanisms

Tree's 204,800 extra redirects and 190,432 extra tree-node allocation calls
account for 96.52% of its net extra allocations. The additional Stat product
shells are only 3.00%. Thus a Stat-only experiment is useful for ABI correctness
but cannot directly remove the largest allocation classes. The architecture
audit identifies upstream constructor storage reuse and cold/borrowed field
handling versus candidate reconstruct-and-seal behavior. Those mechanisms
need a separate ownership/reuse experiment; classifying a tree node does not
prove its allocation redundant.

Closures' entire excess is exactly **4,104 closure environments**. The generated
chain step creates three candidate environments versus two upstream. Known
target/partial-application simplification can remove the extra intermediate
closure in a general way. Upstream itself still has opportunities for avoiding
allocation at immediately known closure applications, which makes this a
plausible route beyond upstream rather than a guarantee of a 0.5× total result.

The task-node gap in tree/lexer is real but numerically small; changing global
scheduling mode can affect many instructions beyond those allocations. Do not
infer the importance of the dead-bang metadata bug solely from heap task counts.
