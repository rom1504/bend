# Phase118 invocation-local builtin bank audit

Independent source review only. No compiler, build, target, benchmark or custom
failure probe was run. The reviewed `runtime-bank.py` has six exact-once textual
replacements over the pinned `runtime-transport01` source. No concrete aliasing,
initialization or live-value preservation defect was found under the existing
capability-4 certificate and authenticated source-factory boundary. This is not
an unconditional claim for arbitrary raw runtime clients or structurally valid IR.

## Reviewed identities

Paths below are relative to the repository root; SHA-256 values pin this review.

| Input | SHA-256 |
| --- | --- |
| `selfhost/tools/performance/phase118/runtime-bank.py` | `2086970037945208ecbf96f75096e33e4e5ea688a03c20d74f90a7f6ff8629f1` |
| `selfhost/build/phase118/runtime-transport01/runtime.c` | `27cc9cfaa9f7e301e7975edd6f89608bffe367dcad57b4604fa0e913a5ec258e` |
| `selfhost/build/phase118/runtime-transport01/report.json` | `868dc15c37e4cddd09350ae815fa5a9b070ce8e2a0f70e27a798d9778a32cb1f` |
| `selfhost/build/phase118/runtime-transport01/runtime.h` | `9b19b8d6ae1c8f07759041201c2692c20d9612393819e2bbc597deba44679d12` |
| `selfhost/build/phase118/transport-source01/compiler.bend` | `b539ffb4288fb7e41ca4fe63cade9f4c327f6a4ba6ef580e1107372b5a3ee8f0` |
| `selfhost/tools/performance/phase118/transport-certificate-v2.bend` | `ef94b2c1cecd6d6f27e23ff76c0a830610333a2c26e0ccdeda1e30acb438fe4b` |
| `selfhost/tools/performance/phase118/transport-emission.bend` | `4c434b44b48faf6ef54c16a85e49c8b747a3920a3e94317cc5edbcc8a893931a` |

The existing root-owned transport API receipt is complete and checked
(`phase111/p118-transport-api01/report.json`, SHA-256
`cb67d38ba0dad3f8c27102c46e22f323341da1c0c3b1eff308b9b0709b3e6bd1`).
That receipt qualifies its recorded source check, not this new runtime change.
The script's introductory capability-8 docstring is stale; its replacements and
receipt scope correctly describe capability 4.

## Live-prefix invariant and builtin cases

For the current dispatcher state, every semantically live register is
initialized and has exactly the same word as before. Dead slots may differ;
they are transport bits rather than ownership roots. `work_loop` still creates
`WlState state = {0}` and writes entry task slot 0. Physical capacities, logical
width calculation, `p111_set_regs`'s bounded live-prefix memmove, all count checks,
stack layout, `rn`, next-FID and task-delivery protocol remain unchanged.

| Builtin | Why the in-place bank preserves its inputs and outputs |
| --- | --- |
| `FID_ENTER` | Saves `t = r0` before `WL_OPEN` or writes. Task metadata and words come from the separate corpus. Loads exactly the ordinary target arity, or the continuation's incoming prefix; captured parameters still move to the worklist stack. Task storage is freed only after those reads. |
| `FID_IO_EMIT` | Saves `x = r0` before allocating; writes exactly result slot 0 and returns with `rn = 1`. Allocation helpers receive `Env`, not the register-bank pointer. |
| `BEND_CLO_APPLY` | Saves both `fun = r0` and `arg = r1` before loading captures. Loads `arity - 1` captures from closure storage, frees that storage, then writes the saved argument in the final slot. Overwriting slots 0/1 cannot corrupt either saved input. |
| `FID_EXIT` | Saves `n = rn`, checks it against result width, and copies exactly those `n` words into distinct local `rv`. After frame/parameter work, continuation forwarding restores exactly `n`; ordinary task delivery only reads `rv[j]` for `j < n`. The existing `WL_OPEN` reset of local `rn` is retained. |

`WL_SAVE` and `WL_TAKE` occur only in `FID_EXIT`, where this explicit `n` is in
scope. Binding establishes `n <= result_width <= logical_width <= 256` for valid
returns. No added path reads `rv[n..256)`. At `n = 0`, both array pointers remain
valid and the zero-byte copies read no elements. Legacy paths still initialize
and copy the whole logical width exactly as before.

## C initialization, aliases and reentrancy

With bit 4 set, `p111_regs` points to `wl->regs`. Both READ_STATE and WRITE_STATE
skip their `memcpy` entirely, so no overlapping self-copy is introduced.
INIT_BANK skips the dead-tail clear. The unused local 256-word array is never
read on this branch; merely declaring it does not require initialization. All
remaining register sizes are explicit `sizeof(Term) * count`, so changing the
bank variable from an array to a pointer does not accidentally change a copy
length. `Term` and state register elements are the same full-width word type.

The four builtin functions call heap/task helpers through `Env`; none passes
`wl` or the bank pointer to those helpers or to an effect provider. Heap objects,
worklist stack and the automatic state bank are separate storage. EXIT's `rv`
is a distinct automatic array and remains live until copying/delivery ends.
The dispatcher is synchronous: it calls one segment, receives its return, then
dispatches the next FID. Each `work_loop` invocation has its own automatic state;
there is no global bank or new pointer escape. Effect callbacks operate on
their own constructor-field arrays and activation records. No builtin helper
can re-enter this same state while it is being filled.

Some bank stores now precede the final `WL_JMP` metadata commit. No intervening
helper observes that state. Paths returning without another dispatch discard
the invocation-local state; the pinned CPU error path is fail-stop. This review
does not extend the change to device or musttail configurations: the source
sets `WL_PORTABLE=1`, `BEND_METAL=0`, and `BEND_CUDA=0`. The new WL_BANK expansion
specifically relies on the portable builtin parameter named `wl`.

## Certificate and qualification limits

The existing complete-program gate remains necessary: original verification,
result-one/incoming-at-most-one source segments, no arbitrary state-memory
access or pointer escape, terminal outgoing transitions, and no direct-worker
register/scheduler observations. Authenticated generated templates may only
add their already-reviewed live-prefix accesses. The runtime capability bit
does not prove these conditions itself. Arbitrary clients can observe a dead
slot or arrange incompatible return widths outside this boundary.

Capabilities 1/3/9/11 keep the old local-bank READ, INIT, WRITE, SAVE and TAKE
behavior. Capabilities 5/7/13/15 take the new path through the same immutable
bit-4 predicate. Descriptor layout, accepted capabilities, cold-parent bit 8,
scalar-array bit 2, constructor operations and ownership reference counts are
unchanged by these six replacements.

Ordinary qualification should relink identical emitted objects and check full
outputs for closure application with captured owned values, zero-capture and
wide captures, recursive continuation forwarding, narrow/wide call alternation,
IO entry/result delivery, and retained aliases. Include an ordinary non-cap-4
program to observe the legacy path. Record actual cap bits and whether builtin
paths execute; output equivalence alone does not demonstrate optimization
coverage. The prior tail-clear timings are not evidence for this additional
bank change. Keeping the unused local declaration may also leave compiler
stack-frame costs; source inspection alone does not establish a speedup.
