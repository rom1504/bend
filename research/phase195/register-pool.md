# Eleven-register prototype boundary

The smallest useful expansion is RCX plus R12, with RAX/R10/R11 remaining selector scratch. RCX gets a per-point forbidden mask for variable shifts and the existing call-clobber restriction. R12 becomes an ordinary saved color by giving `state` one canonical stack home. This avoids dynamic register scavenging, spill insertion, SSA construction, or a new machine instruction representation.

## Actual hot witness and limits

The qualified Phase194 edit owner is `p113d_FID_36_112_114_111_100_117_99_116_46_114_111_119_`. Its executed loop body `0x40cb17..0x40cc69` contains 75 instructions, 20 RBP-relative operand occurrences across 11 slots, and no RCX or R12 instruction. The two-instruction loop condition makes the matched loop 77 instructions. Nine allocation homes coexist with repeated selector use of RAX/R10/R11. Exact source: `research/phase195/profiles/hot-pcs/editdist-p113d_FID_product_row.asm`, from the qualified binary.

Examples: `[rbp-0xa28]` and `[rbp-0xa38]` carry the next loop counter/index (two accesses each); `[rbp-0x958]` reloads an invariant array base once per iteration; `[rbp-0xb30]`, `[rbp-0xb40]` and `[rbp-0xb58]` each publish/reload intermediate minimum values. These are actual executed memory operations, not a count of reserved stack bytes. The profile assigns 98.02% of this workload to this owner; its separate attribution to stack-addressed instructions does not measure causal memory stalls.

The economics replay finds peak pressure 13 against nine colors and only three additional hot admissions from widening the candidate graph to 64. Eleven colors therefore address a real limit but do not eliminate all pressure. The 32-name graph still excludes values. No runtime gain or suite ceiling is established: two additional homes are 22% more allocation capacity, not a 22% speedup.

## Why canonical state storage is needed

The captured analysis body still contains an unreachable `p111_rt_fail(state,4)` arm. Actual branch selection removes that arm from the machine loop. State liveness on the conservative analysis body would keep R12 occupied across the loop despite no executed state use. Reliance on a separate selected-control projection would couple two experiments.

Instead, append an eight-byte state slot to the fresh frame only when installing a successfully validated eleven-color assignment. Existing frame offsets remain unchanged. Set `state` to `X181Stack{offset=newBytes,width=8}`. All scalar loads, product-call implicit state arguments, external-call state arguments, inline F32 buffer access, incoming parameter copies and ordinary memory addressing consult the frame map. The audit found no direct fixed-R12 state use outside the saved-home mapping. Entry stores state once; actual later uses load it. Calls therefore trade a register move for a stack load. Bodies without state uses pay no state reload in their hot loop. This tradeoff needs balanced timing across call-heavy helpers as well as edit/ray.

R12 remains callee-saved. Existing save-mask collection sees a new local assigned `X181Register` index 0 and saves/restores old R12. If R12 receives no local, canonical state storage does not itself require preserving R12. Allocation refusal must return the original frame, including the original state home.

## Exact physical contracts

| Color | Frame encoding | Conditions |
| --- | --- | --- |
| 9 | `X185Transient` index 5 = RCX | No live-through real call; incoming parameter position at least 3; forbidden at variable-shift `liveOut OR writes` |
| 10 | `X181Register` index 0 = R12 | Canonical state moved to a checked, nonoverlapping stack word; usual interference; saved-color treatment across calls |

Variable shifts are the only scalar selector operation besides call setup that writes RCX. A source dying at the shift may use RCX: the right operand is snapshotted into R11 and the left is read before ECX changes. **The destination cannot use RCX**: the physical selector first loads left into the destination, then loads the count into ECX; destination=RCX would destroy left. Hence blocking only `liveOut-minus-writes` is unsound. A constant RHS uses an immediate shift and does not clobber RCX. Calls retain their ordinary fixed-register conflict and argument snapshot handling.

RAX remains unavailable: conditional selects and indexed-load/store fallbacks use it throughout the hot edit loop, and incoming/multi-result/tail-copy emitters also overwrite it. R10/R11 remain general selector temporaries. Exposing these three requires an explicit per-selected-operation scratch allocation contract; changing physical mappings alone is unsafe.

## Consumer patch and controls

`selfhost/tests/phase195/pool/physical-hooks.bend` overrides five declarations:

- Both transient register getters map index 5 to RCX.
- Call-argument validation accepts six transient homes and snapshots RCX sources.
- Float narrow-home selection accepts RCX while preserving the five saved-home bound.
- Parallel assignment permits local R12 destinations and RCX homes. It explicitly rejects literal `state` as a destination even when state is now a stack slot.

`physical-controls.bend` exports 13 finite structural checks for these paths, including strict upper bounds and R12 save-mask preservation. The economics agent owns the new eleven-color picker, independent assignment validator, fixed-point/shift mask and incoming-ABI constraint. No maintained edits or target jobs were performed by this audit. The static reference and delimiter checks passed; checked-source and machine controls are pending.

Cheapest falsifier: capture the exact new homes and matched hot loop. Require newly admitted RCX/R12 values to remove executed loads/stores before interpreting timing. Controls must reject a variable-shift RCX destination, retain a live-through shift value elsewhere, handle dead shift sources in RCX, preserve incoming fourth arguments, survive call argument permutations, restore caller R12 and preserve state across cold/hot calls. Screen isolated pool widening, then its composition with physical select, while retaining call-heavy regressions in the suite metric.
