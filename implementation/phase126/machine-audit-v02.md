# Phase126 typed05 machine follow-up

This read-only comparison uses retained parent/typed04/typed05 binaries. No
compiler or target was executed. Frozen earlier evidence is unchanged.
[comparison.json](../../selfhost/tools/performance/phase126/machine/typed05/comparison.json)
pins all six binaries (active and ordinary ray, three compiler variants) and
preserves per-symbol assembly. Counts include symbol-alignment padding and are
static, not dynamic cost attribution. Word-ABI adapters are separate symbols.

| Active-ray worker | Parent → typed04 → typed05 instructions | GPR/XMM moves | Initial stack subtraction |
| --- | --- | --- | --- |
| intersection | 202 → 133 → 117 | 49 → 19 → 3 | 0x818 → 0x18 → 0x18 |
| product nearest | 427 → 419 → 381 | 4 → 28 → 16 | 0x8e8 → 0x878 → 0x88 |
| nearest.t | 372 → 384 → 361 | 4 → 28 → 16 | 0x8b8 → 0x68 → 0x48 |
| product trace | 1274 → 789 → 692 | 171 → 104 → 63 | 0xab8 → 0x198 → 0x138 |
| pixel | 704 → 547 → 527 | 81 → 73 → 49 | 0x9a8 → 0x918 → 0x8f8 |

The typed05 combination preserves incoming immutable lane facts across branches
unless either branch writes the associated word, raises the bounded fact capacity
from16 to64, restores existing width-pair/Boolean-diamond projections, and projects
op25 low-word zero-extension. It therefore tests a combination, not an isolated
fact-cap improvement. Intersection now has only three GPR/XMM moves in its typed
body. Product nearest loses two generic op25 call sites and its 2KiB scratch
allocation. Trace also loses substantial transport. The same transformations and
machine bodies are present in ordinary ray: its poor whole-result improvement is
not a failure to admit these numeric functions.

All four finite selector workers still have16 branches each. Nearest's branch
counts remain66/65. Intersections remain outlined calls with their register and
stack argument convention, and the numeric result still crosses the word ABI.
These are remaining static differences, not evidence for their dynamic shares.
Pixel retains a large scratch frame and49 GPR/XMM moves, so the new typed region
still does not span its complete input/output path. The untouched large direct
trace variant must not be called hot without tracing the actual selected calls;
its product variant already receives the larger improvement.

## Why ordinary ray can stay flat

The two fixtures perform different work even though they share the numeric
kernel. The ordinary exact Phase93 input uses `bench(80,0)`: six row levels and
fourteen column levels. It visits64×16384=1,048,576 column leaves. Multiplication
by the odd constant2654435761 followed by `&16383` permutes the16384 column
indices; only80 indices per row satisfy the width test and call pixel. Thus
5,120 leaves trace a pixel and1,043,456 return zero. This count follows directly
from the ordinary source and exact fixed inputs; it is not a sampled runtime
fraction. The active fixture explicitly calls pixel256 times at consecutive
positions starting2240, without this million-leaf traversal.

The ordinary workers `p111_$direct.colf` and `p111_$direct.rowf` remain scheduler
functions. Neither has a `p113d_`, `p114r_`, or typed private companion. Their
machine symbol sizes stay393 and436 bytes respectively across parent and
variants. Their retained QBE includes register-bank loads, explicit continuation
frame captures, Nat predecessor helper transport and scheduler jumps. The
[decoded colf](../../selfhost/tools/performance/phase126/machine/typed05/p111_direct-colf.ssa)
and [rowf](../../selfhost/tools/performance/phase126/machine/typed05/p111_direct-rowf.ssa)
show that boundary directly.

This supplies a concrete explanation for dilution: numeric improvements apply
to work shared by the fixtures, whereas the ordinary fixture also retains a
large scheduling traversal unaffected by the numeric projection. It does not
establish the exact time share. A fresh ordinary-ray profile or existing exact
same-source dynamic counts would quantify it. Upstream must still execute the
same source semantics, so this is a compiler opportunity, not a reason to remove
the benchmark or change its definition.

## Highest-value next distinction

Further local F32 work should first target actual remaining transports, rather
than another broad numeric rewrite: mixed-use scratch buffers in pixel, exact
result adapters and the few surviving conversions. But ordinary ray indicates
a potentially larger general opportunity: let the already verified local-resume
worker absorb this divide-and-combine recursion while retaining the explicit
stack. First identify the precise admission refusal. The million-leaf source
count alone does not authorize replacing evaluation order, dropping the branch,
assuming bounded public Nat inputs or emitting unsafe native recursion.

Root's typed04 and typed05 screens independently preserve complete expected
outputs. Their measured runtime effects are recorded in the root screen reports;
this audit makes no attribution stronger than the static evidence above.
