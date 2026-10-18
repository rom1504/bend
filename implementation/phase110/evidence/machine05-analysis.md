# Wrapper-spare machine mechanism

This is offline disassembly inspection of `wrapper-build01`, compared with
`general-build01` and `stored-build01`. No compiler, worker or timing process ran
for this audit. `machine05/report.json` authenticates the new disassembly;
`machine05-paths/report.json` records every instruction and branch choice in the
selected path, together with the source-only counting method.

## The selected scenario

One nonterminal `List<String>` reverse iteration has a count1 RFC parent whose
decoded shell is dynamic, a retained field that is already sealed, and a raw
constructor accumulator. The incumbent's class0 free does not hand off and its
subsequent hot allocation succeeds. This describes the steady unique-list path;
it excludes the first/final iterations, shared/static inputs, allocator misses
and handoffs. These are explicit source-derived choices, not hardware traces.

| Backend/candidate | Instructions | Conditional branches | Stack reads / writes | Allocator reads / writes | Heap reads / writes |
|---|---:|---:|---:|---:|---:|
| QBE compact/general | 100 | 9 | 0 / 5 | 4 / 4 | 4 / 4 |
| QBE stored-field | 95 | 8 | 0 / 4 | 4 / 4 | 4 / 4 |
| QBE wrapper-spare | 100 | 8 | 3 / 12 | 0 / 0 | 3 / 3 |
| Clang compact/general | 69 | 8 | 1 / 1 | 4 / 4 | 4 / 4 |
| Clang stored-field | 60 | 7 | 0 / 0 | 4 / 4 | 4 / 4 |
| Clang wrapper-spare | 54 | 7 | 0 / 0 | 0 / 0 | 3 / 3 |

Every selected path has zero calls. Read-modify-write memory operands count in
both read and write columns. Instruction counts are architectural sites along
the selected path, not micro-operations or cycles.

The generic wrapper transfer is present in both backends. It removes all eight
allocator reads/writes and two heap accesses from this scenario. QBE replaces
those ten accesses with ten additional stack reads/writes: the total remains21.
Clang reduces total accesses from18 to6. QBE's instruction count also stays100,
whereas Clang's falls from69 to54. Thus missing runtime inlining is not the
remaining explanation for this path: both already execute without calls.

## QBE's additional stack traffic

The wrapper QBE function reserves0x68 bytes of local stack, versus0x38 for
compact/general and0x28 for stored-field. Its complete worker grows from768 to894
bytes, versus614 for stored-field. The larger function includes fallback paths;
these size figures do not measure executed work.

In wrapper QBE, the region `0x40207a..0x4020d3` computes the common RFC cell and
Term metadata before the spare/no-spare branch. It stores values that a possible
allocation fallback may need, even when the current iteration uses the spare:

```asm
4020a6: mov    %rdx,%r8
4020a9: shr    $0x28,%r8
4020ad: mov    %r8,-0x28(%rbp)
4020b1: mov    -0x28(%rbp),%r8
4020b5: shl    $0x28,%r8
4020b9: mov    %r8,-0x30(%rbp)
4020bd: movabs $0x8000000000000000,%r8
4020c7: mov    %r8,-0x38(%rbp)
4020cb: mov    -0x30(%rbp),%r8
4020cf: or     -0x38(%rbp),%r8
4020d3: mov    %r8,-0x58(%rbp)
```

This is additional data traffic for pure shifts and a constant flag. The
incumbent performs its equivalent metadata construction entirely in registers.
The wrapper's common path also executes two register `xchg` instructions at
`0x401fda/0x401fdd` to reconcile the live spare, source location and external
field across the retained-head sealing join. The spare and external top-byte
remain live across that join, including its possible cold allocation call.

The emitted QBE source has two complete external-wrap encodings: one following
ordinary allocation and one consuming the spare. Their shared arithmetic
appears before the storage-choice branch in the final assembly. The assembly
establishes the placement and spills; this audit does not identify which
individual optimizer/register-allocation pass caused them.

Clang keeps those values in registers on this path. Its spare block at
`0x402020..0x402045` writes the count1 redirect and constructs the RFC Term with
no stack accesses. It also reduces `(word & ((1<<40)-1)) << 24` to `word << 24`:
the U64 shift itself discards the upper24 bits. QBE retains the redundant
mask/AND pair, both here and in the incumbent.

## Actionable follow-up, without a new candidate

The narrow next investigation is to select the wrapper storage first, then
perform one common RFC encoding after that choice. Currently the private graph
duplicates encoding in the allocate/spare branches; this creates pure values
that the final QBE code keeps across a possible allocator call. A single
post-selection encoding block would shorten those live ranges. It should be
assessed with the same ownership certificate and spare controls before any
performance claim.

A separate backend-local algebra rule can remove the low40-bit mask immediately
before a U64 left shift by24. That equivalence holds for every U64 word and does
not require a new source ownership assumption. Another future comparison could
combine the independently authenticated stored-field fact with wrapper reuse
to remove the retained-head allocation join, but neither a combined candidate
nor any new variant was implemented in this audit.

These observations make the backend-sensitive result plausible and identify
specific work to remove. They do not prove that stack traffic accounts for a
particular timing difference; final winner selection must use the parent's
matched repeated measurements.
