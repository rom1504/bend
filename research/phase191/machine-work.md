# Actual Phase191 development products: removed and remaining machine work

Read-only inspection compares **Phase190 `native45-02`** with **Phase191
`both-dev-build01`**, plus the original mature-C products in Phase190's
`references01` manifest. The candidate contains loop-priority, addressing and
memory-ALU changes together; these observations do not isolate their runtime
contributions. No target, compiler or sampler was executed.

[Input/product pins and exact commands](../../selfhost/build/phase191/machine-audit01/inputs.json) ·
[Derived counts and CFG bounds](../../selfhost/build/phase191/machine-audit01/summary.json) ·
[Offline derivation](../../selfhost/build/phase191/machine-audit01/derive.py)

The three manifests' source, independent oracle and workload point agree for
both cases, and selected executable bytes/hashes were rechecked. The new
`frame-transitions.py` runs the unchanged Phase190 decoder and emits exact
instruction witnesses. All selected symbols have exact decoded-byte coverage.
Each candidate region was chosen from its own disassembly and checked on
instruction boundaries; no historical candidate offsets were reused.
Audit artifacts total approximately **3.3 MB**, below the requested 16 MiB.

## Local-pair: address transport disappears, predicate transport remains

The row loop has 64 enumerated syntactic positive paths in both products.
Enumeration begins at the row's loop header and ends at its backward jump,
excluding returns. Predicate correlations are unsolved, so these are static
bounds, not execution frequencies or measured per-iteration instruction totals.

| Positive row path | Phase190 | Phase191 | Mature C inner cell loop |
| --- | ---: | ---: | ---: |
| Instructions | 142–147 | 97–102 | 26 |
| Explicit rbp memory references | 54–55 | 21–22 | 0 |
| Register/memory move instructions | 97–98 | 62–63 | 7 |
| Conservative frame store→next-load witnesses | 15 | 3 | 0 |
| Indexed memory instructions | 0 | 5 | 5 |
| Conditional branches | 7 | 7 | 1 |
| Calls | 0 | 0 | 0 |

The C row is `NF_FID_…dp.row`, whose cell arithmetic is inline in
`[0x11010,0x1106a)`. Its whole-function scope also includes ownership and
allocation work; the table uses only the actual inner cell loop. It uses
indexed `cmp`/`add` memory operands and two `cmovb` operations. The x86 positive
row path still materializes predicates with compare/setcc/movzx/test and keeps
branches selecting minima. Several conditional branches and following jumps
have the same destination. This is a concrete remaining selection opportunity,
not a new correctness argument for changing those branches.

The [subsequent physical profile](profile-assessment.md) establishes that C
actually spends its CPU in the equivalent loop inlined into `NF_FID_pair`,
at `[0x10ca0,0x10cfc)`. The `dp.row` figures above are a static code comparison,
not the measured hot-function identity. The actual hot C loop also has 26
instructions; its rbp-indexed references use an array base, not frame spills.

The strongest local witness is `prev[j+1]`:

| Corresponding producer/load sequence | Phase190 | Phase191 |
| --- | ---: | ---: |
| Address span | `[0x40d841,0x40d8b5)` | `[0x40d580,0x40d58f)` |
| Instructions / bytes | 20 / 116 | 4 / 15 |
| Explicit frame references | 12 | 0 |
| Store→next-load witnesses | 5 | 0 |

Phase191 executes `mov %edi,%esi; add $1,%esi; and %r9,%rsi;
mov (%rbx,%rsi,4),%r8d`. This replaces the separate truncated-index,
increment, mask, scaled-offset and computed-address stack transports. Four
exit handles now occupy `-0x50`, `-0x58`, `-0x60`, `-0x68(%rbp)` instead of
reserving homes throughout the cell body; the candidate reloads them on exit.
This is direct machine evidence that the intended placement/addressing
mechanisms reached the actual product.

The whole-function totals preserve less favorable boundaries:

| Function | Instructions 190→191 | Explicit rbp refs 190→191 | Store→load witnesses 190→191 | Indexed memory 190→191 |
| --- | ---: | ---: | ---: | ---: |
| `$product.row` | 393→344 | 169→147 | 45→34 | 0→5 |
| `$product.cell` | 535→520 | 200→190 | 51→46 | 0→5 |
| `$product.cell.f1` | 444→428 | 158→150 | 39→35 | 0→4 |
| `$direct.cell` | 195→192 | 46→46 | 0→0 | 0→1 |

These frame-reference totals include `lea` address operands in the cell
functions; the JSON separately reports actual memory-reference instructions.
The generic/product cell paths still have calls and substantial frame work.
Their measured contribution requires the separate physical profile.

## Local-fold: indexed accesses help, shared scaling and copies survive

The actual positive iteration is 27→23 instructions (98→90 bytes), with
zero frame references and zero store→load witnesses in both products. Two
indexed accesses replace two explicit base-plus-offset address constructions;
the whole worker changes 128→125 instructions because setup also changes.

Phase191 still computes `imul $4,%r8,%r8` and uses scale **1** in both
`(%rdx,%r8,1)` load/store operands. The shared scaled offset remains a live
value. The loaded word passes through register copies before the accumulator
addition, so this selected loop still has a separate load and register `add`.
The new memory-ALU facility has not converted that operation into C's direct
memory-add form in this product.

The original mature-C hot loop is `[0xf880,0xf8b2)`: **15 instructions for two
elements**, four indexed memory operations, one conditional backedge, zero
frame references and no calls. It uses two indexed memory-add operations and
is unrolled by two. Do not compare 15 directly with the x86 one-element count
without preserving that work difference. C's larger surrounding function
contains initialization, allocation and cleanup; its whole count is not the
repeated fold-body count.

Phase190 positive spans are `[0x40931f,0x40932c)` and
`[0x40935c,0x4093b1)`; Phase191 spans are `[0x40928b,0x409298)` and
`[0x4092c8,0x409315)`. The short first span is the header comparison/branch;
the second is the positive body through its backedge. Both are required for
the stated complete positive-iteration counts.

## Interpretation boundaries

Indexed memory counts exclude `lea` and alignment NOP encodings; scale 1 is
included because it still combines base and index in the memory instruction.
The frame diagnostic recognizes only conservative same-width integer stores
and subsequent loads. It resets at control-flow boundaries, unsupported
operations and potential unknown writes; zero witnesses never proves zero
transport. `%rbp` references are a syntactic category, not universal evidence
that an operand accesses the stack, particularly in C functions using rbp as
a general register. Selected C inner loops have neither rbp nor rsp references.

These observations show emitted work removed and remaining. They do not
measure cache misses, DRAM traffic, store forwarding, dependence latency,
retired instructions or runtime. The paired ablations and independently
qualified sampling lane must establish performance and dynamic hotness.
