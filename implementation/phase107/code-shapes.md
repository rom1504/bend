# Phase107 code shapes: the measure03 boundary

The large improvements have a concrete explanation: the selected entry's deep
helper chain disappears, and recursive scalar recurrence becomes an explicit
loop. The remaining shared-memory gap still contains an observer call inside
every iteration. Clang exposes that body and optimizes the surrounding loop;
the measured Cranelift and QBE candidates have not yet done that.

This is a **read-only audit of measure03/artifacts02**, before the separately
running effectful-leaf and reachability experiments. No compiler, generated
program, profile or benchmark was executed for this audit. The historical
measure02/artifacts01 objects are retained as the first-screen comparison.

## Matched code and recorded runtime

`c` means the emitted IR C compiled with Clang `-O2`; `cl` is Cranelift
`speed_and_size`; `qbe` is QBE 1.3 for `amd64_sysv`, followed by GNU `as`.
These are experimental IR kernels, **not the production C backend or full
compiler**, and none of these ratios compares against the TypeScript compiler.
Only `source-recurrence` among these four workloads is automatically lowered
from checked Bend source; the other three are directly constructed IR fixtures.

Times below are the existing measure03 three-round medians, in milliseconds.
They include process/runner overhead and repeated kernel calls. No fresh timings
or statistical significance are inferred here.

| Workload | Clang raw → 4096 | Cranelift raw → 4096 | QBE raw → 4096 | Candidate / raw Clang, CL / QBE |
| --- | ---: | ---: | ---: | ---: |
| `ir-many` | 16.261 → 16.193 | 92.112 → 16.384 | 82.132 → 16.258 | 1.008× / 1.000× |
| `source-recurrence` | 15.227 → 15.076 | 29.305 → 16.398 | 36.504 → 16.046 | 1.077× / 1.054× |
| `ir-shared` | 10.600 → 10.663 | 40.761 → 41.326 | 35.328 → 37.117 | 3.899× / 3.502× |
| `ir-shared_borrow` | 9.203 → 9.269 | 34.489 → 33.432 | 21.001 → 23.763 | 3.633× / 2.582× |

Budget 0 is the raw/folded route. The measure03 budget-4096 candidate combines
entry-first inlining, tail-loop conversion and the QBE entry fusion route.
Consequently these measurements do not isolate the contribution of each pass.
The twelve raw objects for the four workloads and three backends are byte-identical
between measure02 and measure03; their timing differences therefore illustrate
screen variability, not changed raw code. Small candidate differences on shared
workloads should not be attributed to an optimization that did not change their
hot observer calls.

## Deep helpers: budget placement matters more than backend choice

The raw `ir-many` entry reaches 130 machine functions in Cranelift and QBE:
the external wrapper, main, and 128 helpers. There are 129 static call sites in
that reachable set: one wrapper call plus 128 nested calls per loop iteration.
The old measure02 candidate only reduces that to 126 reachable functions and
125 call sites. It leaves the expensive chain largely intact.

The measure03 candidate has **two entry-reachable functions and one call site**
in both backends: `phase106_entry` calls `bend_ir_main` or `nx_main`, whose loop
has no helper calls. Clang already has one entry function and zero call sites
with either budget. The corresponding Cranelift/QBE improvements are 5.62× and
5.05×, bringing this workload close to the Clang screen. This supports the
specific call-boundary explanation; it is not a general 5× compiler claim.

All definitions are still emitted. Cranelift retains 130 functions and grows
from 13,472 to 16,248 object bytes; QBE retains 131, including its unused allocator,
and grows from 9,952 to 12,448 bytes. Entry-reachable function bytes instead fall
from 4,194 to 1,857 in Cranelift and 3,776 to 1,598 in QBE. Removing unreachable
definitions could reduce object/build size without requiring more hot-path
inlining. That requires the stated single-entry ABI: other retained functions
must not secretly be externally callable or address-taken roots.

## Recurrence: frames become a loop, with small cleanup opportunities

Match `f_119_97_108_107` (`walk`) across `bend_ir_` and `nx_` symbols. The raw
Cranelift and QBE functions call themselves and create a frame on every recursive
invocation. Budget 4096 replaces that call with a backward branch. The static
entry-reachable call count falls from 3 to 2 in Cranelift and 3 to 1 in QBE.
QBE additionally fuses the entry-to-`bench` wrapper, so its entry calls `walk`
directly. Clang already lowers the recurrence without calls in the entry.

Cranelift's transformed `walk` still emits a constant-true loop test on each
iteration (`mov r10d,1; test r10d,r10d; jne ...`) and a redundant unreachable
zero-return path. QBE eliminates that guard. Both retain the explicit Boolean
termination state computed with comparison/set instructions. These are small,
visible opportunities for local control-flow simplification after tail lowering.
They do not explain a remaining multi-fold gap: the current recorded ratios are
only about 1.08×/1.05× raw Clang. Static absence of recursion supports this specific
function's frame claim; it is not proof of a general mutual-tail ABI.

## Shared observers: calls, memory traffic and alias information

Both shared variants allocate a 16-byte parent and a 16-byte child, initialize
them, loop, inspect final reference counters, and free both objects. The
reference-counter checks contribute to the result. This is the experiment's
explicit `calloc`/`free` model, not the production Bend ownership implementation.

The measure03 raw and candidate Cranelift shared objects are byte-identical.
QBE fusion removes the outer entry-to-main call and duplicates main's body into
the entry, but **does not remove the observer call inside the loop**. In particular:

| Matched observer | Cranelift instructions / memory operations / writes | QBE instructions / memory operations / writes |
| --- | ---: | ---: |
| `observe`, shared | 12 / 6 / 4 | 16 / 10 / 4 |
| `observe`, borrowed | 7 / 2 / 0 | 4 / 2 / 0 |

Counts exclude alignment nops and include ordinary prologue/return instructions.
A read-modify-write instruction counts as one memory instruction, hence the
Cranelift/QBE count difference is not a direct comparison of memory transactions.
Cranelift gives even the two-load borrowed observer an `rbp` frame; QBE emits it
as a frameless leaf. Cranelift main reserves 64 bytes, preserves registers across
the call and spills/reloads the rolling accumulator. QBE preserves registers at
entry but does not have the same accumulator stack traffic.

Clang has no separate observer symbol or loop call. In the borrowed case its
main hot loop holds the seed/value in a register and unrolls four iterations;
there are no heap loads in that loop body. In the shared case it unrolls two
iterations but still performs child-value loads and some reference-counter
stores. It has not eliminated all ownership bookkeeping. All three backends
retain allocation and free paths; QBE's one static `calloc` site lives in an
allocator helper called twice, so it is not evidence of one dynamic allocation.

The next targeted hypothesis is therefore to expose this small observer body
while preserving the exact order of loads/stores and call-argument evaluation.
That can remove loop calls and expose load forwarding, invariant values and
redundant counter operations. Any subsequent alias/ownership rewrite needs its
own legality evidence: parent/child disjointness and live-owner facts cannot be
guessed from these four fixtures. The separately running effectful-leaf candidate
is not included in this audit and earns no success claim here.

## Reproduce the audit and interpret its limits

[`code-shapes.py`](../../selfhost/tools/performance/phase107/code-shapes.py)
runs only `objdump` and `readelf` against existing objects. It records ELF function
sizes, matched symbols, direct entry reachability, static calls/backward branches,
frame setup, explicit stack reservations and memory-instruction counts. It
checks objects are unchanged after inspection. The
[48-object JSON](code-shapes.json) includes source/object/API/tool hashes and the
original timing rows, without executing them.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase107/code-shapes.py \
  --measure selfhost/build/phase107/measure03 \
  --artifacts selfhost/build/phase107/artifacts02 \
  --previous-measure selfhost/build/phase107/measure02 \
  --previous-artifacts selfhost/build/phase107/artifacts01 \
  --out /tmp/phase107-code-shapes.json
```

Output must be fresh. Static function sizes exclude cross-function padding;
object sizes also include symbols, relocations and other metadata. Whole-object
instruction totals would incorrectly count unreachable helpers as executed work,
so the report separates all functions from the entry's direct reachable set.
Indirect function targets are outside this reachability analysis. Backward
branches are syntactic, not measured loop counts. Stack operands/reservations
are not maximum stack usage, retained heap size or RSS, and no retained-memory
measurement is claimed. Allocation lifetimes above come from the matched source
and control flow. The first audit attempt stopped before output because the
historical artifacts01 receipt has no `method` key; the reader now records that
field as absent rather than inventing provenance.

Pinned comparison records (full per-file pins are in the JSON):

| Record | SHA-256 |
| --- | --- |
| measure03/report.json | `6b78ca76c631e6528de6bf91877640f37bf28ee986996af985fe22effe2c28fc` |
| artifacts02/report.json | `6d14159cfe464bda7ee3458aef2fc4c2375c4660f41259edfe4a24031d383417` |
| artifacts02 producing API | `62059b2861670d540ee3faadb989e99652410d1fe090405a2881013319014020` |
| artifacts02 recorded emitter source | `8875dde8c84a144abc6259fc669540d432a98983fe5c43ff4526dbf234cd9c94` |
| measure02/report.json | `20cba63631d4c72c386ca669004c515c2cbb85bb240f94364707bf29d3448a18` |
| artifacts01/report.json | `b01ab62f739b7fbab15326fcb93d2c66d429176eb09a0bf367e8ab4c20c0fbf0` |
| artifacts01 producing API | `965f201bafb30512951c53662e2ee70dda0ae55fab4606a31277e8d704b144cf` |

Historical emitter-source hashes are copied from those emission receipts; the
working emitter has since changed. This audit pins the actual retained C/JSON/SSA
files and objects rather than pretending the current emitter created old runs.

## Follow-up: measure04 exposes the remaining memory dependency chain

This section separately audits **measure04/artifacts03** (`leaf-reach`, producing
bridge11 API). The original measure03 conclusions and census above remain intact.
The unchanged inspection tool produced a second [48-object census](code-shapes04.json)
for measure03 versus measure04; the interpretation here concerns only the shared
and borrowed fixtures. No runtime was executed. All six raw shared/borrowed
objects are byte-identical between the two campaigns, so compare each candidate
with its own paired raw timings rather than attributing cross-campaign drift to
the pass.

The measure04 recorded medians are:

| Workload/backend | Raw ms | Candidate ms | Raw / candidate | Candidate / raw Clang |
| --- | ---: | ---: | ---: | ---: |
| Shared, Cranelift | 36.720 | 35.021 | 1.049× | 3.298× |
| Shared, QBE | 35.175 | 35.869 | 0.981× | 3.378× |
| Borrowed, Cranelift | 31.896 | 16.464 | 1.937× | 1.804× |
| Borrowed, QBE | 18.674 | 13.338 | 1.400× | 1.461× |

**The observer boundary was removed successfully in both fixtures.** No observer
symbol remains, and no call remains inside either hot loop. Cranelift's reachable
function count falls from 3 to 2, and its explicit main stack reservation falls
from 64 to 48 bytes. Its static stack-memory instructions fall from 14 to 10;
the per-iteration accumulator spill/reload is gone. QBE goes from three reachable
functions to two (entry plus allocation helper). It removes the observer call
and the explicit eight-byte stack reservation, but still saves registers at
entry. These are code-shape counts, not measurements of peak stack or RSS.

What remains differs substantially:

| Measure04 hot body, matched symbol | Loads and stores retained per scalar iteration |
| --- | --- |
| Shared CL `bend_ir_main`, `0x10b`–`0x143` | Four counter read-modify-write instructions, child-pointer load and child-value load |
| Shared QBE `phase106_entry`, `0x190`–`0x1c7` | Six explicit loads and four stores: parent count, child pointer/count, parent count again, child value/count |
| Borrowed CL `bend_ir_main`, `0x108`–`0x12b` | Child-pointer load and child-value load; no heap store |
| Borrowed QBE `phase106_entry`, `0x170`–`0x189` | The same two loads; no heap store |

The shared code still performs this ordered sequence:

```text
p.count += 1
c = p.child
c.count += 1
p.count -= 1
value = c.value
c.count -= 1
```

Neither backend has reduced that chain after inlining. Cranelift expresses the
updates compactly as memory arithmetic; QBE expresses them as separate
load/arithmetic/store instructions. Compact instruction encoding does not remove
their memory dependencies. In the borrowed loop only the pointer/value loads
remain, so eliminating the call, frame and register spills removes a larger
fraction of the work. This is a static explanation consistent with the measured
difference, not a sampled attribution of cycles or cache misses.

The pointer loaded from `p.child` also obscures its relationship to the earlier
child allocation. Without a proven location model, a store through that pointer
may alias a later load through the parent. Blindly cancelling the counter updates
could change the intermediate value returned by an aliasing observer. Similarly,
the remaining borrowed loads are invariant in this fixture, but the backends
still execute them every iteration. QBE already forwards the final borrowed child
counter to its known value 1; it has not hoisted the loop's two loads. Clang retains
its earlier two-way shared and four-way borrowed unrolling; the borrowed loop
uses the seed register directly. All variants still allocate/free both objects.

### Next general-purpose pass: bounded memory-value forwarding

Use facts already explicit in the IR: each successful allocation introduces a
fresh root; a constant byte offset and access width identify a range within that
root. Copies preserve pointer provenance, and a pointer value stored in an
unmodified field can be forwarded when that field is loaded. Distinct live
allocation roots are disjoint; unknown pointers remain potentially aliasing.
This is ordinary memory reasoning, not recognition of reference-count names.

1. **Start with straight-line forwarding.** Track known values for exact typed
   ranges; forward loads after matching stores and invalidate overlapping ranges
   on writes. Stop or invalidate conservatively at unknown calls, escapes,
   unknown-address writes, free/reallocation, and unsupported control flow.
   Preserve evaluated argument/value snapshots and the ordered effects.
2. **Summarize loop writes conservatively.** A loop may retain preheader values
   only for ranges that no iteration can overwrite. Here `parent+8` can resolve
   to the child root, and `child+8` can resolve to the original seed, while the
   counter writes are separate four-byte ranges. Existing scalar folding plus
   forwarding can then expose the restored counter values; dead-store cleanup
   can remove unobserved intermediate stores. Do not replace an entire retain/drop
   protocol on the basis of net arithmetic alone.
3. **Take the smaller borrowed-only step if necessary.** A call-free, write-free
   loop admits invariant-load reasoning once its pointer inputs are invariant.
   Guard any hoisting so zero iterations do not introduce a potentially trapping
   load, or forward a value from an already executed initialization instead.

Verify with distinct and aliased roots, overlapping offsets/widths, overwritten
pointer fields, unknown-call barriers, free/reallocation, both branch arms,
zero-iteration loops, U32 counter wraparound, and observers that read a counter
between updates. Include complete returned values and memory observations, plus
unchanged refusal on unsupported cases. Then require the actual emitted loop to
lose the intended loads/stores before requesting another runtime screen. A
successful local pass would still leave allocation/free, arithmetic dependency,
unrolling and backend register/branch choices as separate costs. No gain estimate
or production ownership theorem follows from this read-only result.

New pins:

| Record | SHA-256 |
| --- | --- |
| measure04/report.json | `31c1b76f3aad21c97e42d2856770414c999e6ce5187323e4924344ee99f35737` |
| artifacts03/report.json | `882728d08e7d8e65487fcdfd73dbf798fe48151f2e14e638d9d231e4d9eba66d` |
| artifacts03 producing API | `7e35892941940e47e00d320a73779cd9712332535c14ca51ae8e382d6dcb0286` |
| code-shapes04.json | `4ef08648513b7290fec90dab4952b8e15956bfeb6141fb1ba954777dcd41e952` |

The replay command is the same as above with current `measure04`/`artifacts03`,
previous `measure03`/`artifacts02`, and a fresh output path. The census pins all
matched objects and generated C/JSON/SSA files, including the unchanged four-case
inspection set. It does not include any later memory-forwarding candidate.
