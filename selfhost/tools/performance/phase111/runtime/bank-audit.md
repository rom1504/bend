# Bounded register transport

`runtime-source04` is a runtime-only candidate over frozen `runtime-source03`.
The runtime ABI and QBE program bytes are unchanged. Its admitted logical width is
`W=max(program.register_width,program.result_width,2)`, computed once after the
descriptor widths and all segment metadata have passed binding checks.

The state remains 2,088 bytes with 256 physical Term slots. Built-in local banks
and temporary result arrays also remain 256 words. `WL_WIDTH` and `WL_RESW` remain
256; `H_BANK`, `STAT_OFF=51413504`, all heap classes and all Term bits are unchanged.
The materializer records the transport policy separately from these capacities.

The candidate narrows the scalar transfer's trailing clear, and coherently narrows
built-in INIT, READ, WRITE, SAVE and TAKE to W. Transfers check `count<=W` before
subtracting count. Built-in load and last-argument stores are bounded by W. Closure
and task entry check arity against W. EXIT checks actual result count against the
descriptor's result width; continuation reconstruction checks input width against
W and result count against that input width. Public register access rejects an
index at or above W. The full state is still initialized once on dispatcher entry.

## High-slot argument

For generated direct entries, the independent IR verifier bounds register reads
by the segment's declared arity. For continuations it bounds reads by incoming
result width. The descriptor bounds arity by register width, and incoming by both
arity and result width. Every live register read is therefore below W.

The retained built-ins have these reads:

| Built-in | Live input and output |
| --- | --- |
| ENTER | Reads r0; loads an ordinary input arity or incoming result width. |
| IO_EMIT | Reads r0; constructs and returns one result. |
| CLO_APPLY | Reads r0/r1; loads arity minus one captures, then the final argument. |
| EXIT | Saves W initialized words; only `rn<=result_width<=W` are delivered. |

Local bank slots at or above W may now be uninitialized. No remaining built-in
bank copy touches them. SAVE initializes exactly the W words that TAKE later
copies. The retained `task_deliver` loop may iterate to 256, but reads its result
array only under `j<n`, where n is bounded by result width. Other `root_take`
consumers use the recorded result count. This is why SAVE and TAKE must change
together: narrowing only SAVE would introduce reads of uninitialized high words.

State words outside W may retain old bit patterns. They are transport storage,
not scanned roots, and neither old nor new clearing performs keep or sink. No
owner credit depends on zeroing them. The compiler's ownership decisions and the
production allocator/reference-count operations are unchanged.

The authenticated full-emission census currently has maximum arity 26, incoming
width 1 and result width 1. For that descriptor, a scalar transition copies and
clears 208 bytes total instead of 2,048. A built-in READ+INIT+WRITE handles 624
bytes rather than 6,144. These are byte counts, not measured speedups.

## Coordinator commands

All compilation and execution below belong inside the coordinator's exclusive
process-tree guard. Source preparation is the only step performed by this agent.

```sh
python3 selfhost/tools/performance/phase111/runtime/materialize.py \
  --out selfhost/build/phase111/runtime-source04
gcc -O2 -std=gnu11 -ffp-contract=off \
  -c selfhost/build/phase111/runtime-source04/runtime.c \
  -o selfhost/build/phase111/runtime-source04/runtime.o
python3 selfhost/tools/performance/phase111/runtime/check-boundaries.py \
  --runtime selfhost/build/phase111/runtime-source04/runtime.o \
  --out selfhost/build/phase111/runtime-boundaries04
```

Source04 already exists; the materializer refuses an existing destination.
Reproduction requires another fresh destination. The original ten boundary
recipes stay frozen. `bank-controls.c`, `bank-expected.json` and `check-banks.py`
provide the separate focused transport gate when source preparation is complete.
Then relink the exact previously qualified QBE object against runtime04 and
compare its outputs before collecting a matched timing. No Bend module or QBE
body needs rebuilding to isolate this runtime ablation.
