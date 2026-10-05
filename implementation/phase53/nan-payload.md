# P53-001: stable NaN payload transport

Status: runtime fix reviewed and implemented. Corrected01 checked emission and
all 96 existing candidate source scenarios pass, including the original fixture
returning 40. Additional independently renamed/cold controls and final selected
qualification remain separate.

The source oracle in `tests/compile/f32_table_nan_bits.bend` remains40. Installed
Phase52 direct06 returns39 on the cold invocation; pinned TS returns1. Neither
passes that source oracle. This investigation does not change the fixture or
silently accept the erroneous upstream result.

## Diagnosis

`f32_bits(x)` formerly created `new Float32Array([x])`. On pinned Node24.18.0,
the intermediate ordinary array's cold numeric-element transition can discard a
NaN payload on a single conversion. The independent40-comparison loop gives
39/40/40 across three turns, with first-turn n35 left0x7fc00003 versus right
0x7fc00000. Both operands derive from the same source signaling payload0x7f800003.
This is not explained by different numeric inputs or table row selection.

Pinned TS has an additional compiler issue: constant F32 rows serialize through
String(NumberNaN), producing a bare `[NaN,NaN,NaN]` table. That erases all payloads
before runtime. Runtime correction is judged against source40, not TS1.

## General correction

The direct runtime now allocates fresh `Float32Array(1)`, assigns `f[0]=x`, and
reads its bytes through a Uint32Array view. This removes the ordinary JS array
without canonicalizing all NaNs or storing payloads in a global/shared buffer.
Source actuals remain evaluated once before the helper; the indexed typed store
performs one conversion. Nested coercion/reentry cannot overwrite another call's
storage. The numeric primitive templates and finite arithmetic hot path are
unchanged. `f32_from_bits` retains its finite U32 intermediate array.

The Float32Array constructor receives length1 rather than `[x]`. Constructor
and iterator hook shape is intentionally different as a runtime bug correction;
this is not arbitrary overridden-constructor equivalence. Claims concern stable
quieted payloads on the pinned native host. Signaling status or arbitrary NaN
storage through other JavaScript structures is not guaranteed.

## Evidence and remaining gates

Producers: `selfhost/tools/performance/phase53/nan-diagnostic-v1.mjs` and
`nan-store-controls-v1.mjs`; receipts: `selfhost/build/phase53/nan-diagnostic01/`.
Each diagnostic ran CPU0, Node24.18.0, heap256MiB with10-second timeout.
No compiler build or benchmark was run by the author.

The old helper gives39/40/40; explicit store and DataView alternatives both give
40/40/40. The implemented store avoids introducing DataView to the runtime.
Eleven signed quiet/signaling payloads across four turns retain their quieted
payload bits; ten finite, signed-zero, subnormal and infinity patterns roundtrip.
Nested coercion observes outer/nested once each; throwing coercion retains the
thrown identity and runs once. Static reviewer approved the source-first contract.

Corrected01 subsequently passed the original 96 source scenarios. Fresh checked
original and independently renamed fixtures return 40 on each cold and repeated
call; the reference's separate payload failure remains visible. Its eight-point
performance screen shows effectively unchanged speed. The ordered successor
requires its own selected-image qualification. Tiny helper substitution alone
is not actual emitted qualification. All Phase52 failures remain preserved.
