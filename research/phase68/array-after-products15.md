# Array cost after active product flow

Read-only source and disassembly audit; no target was executed by this lane.
The [artifact manifest](../../selfhost/tools/performance/phase68/flat-products/array-after15/manifest.json)
pins both generated C files, their checked-emission receipts and binaries,
the upstream compiler source, and the exact `objdump` commands/output. It does
not supply new timing evidence.

The products15 active-path audit already finds a reachable private loop, cell
and step, with two-word product results and no Tuple allocation, tag check or
constructor take throughout that selected recurrence. The Q functions all
inline into the measured batch worker. One product is packed and consumed
after the whole fold; it is outside the per-element recurrence.

| Mechanism | Products15 actual C | Pinned upstream actual C |
| --- | --- | --- |
| Element storage | `blk_new(e, 1, ...)`, one 64-bit Term per element | `blk_new(e, 0, ...)`, one 32-bit U32 per element |
| Getter | C14868: `blk_keep(e, term_peek(e, a) + at)` | C1452–1455: `blk_read(e.mem, 0, loc, at)` into `u32` |
| Setter | C14809–14810: generic old-element sink and new-element seal around an eight-byte write | C1375–1379: four-byte write; no owned element destruction/seal |
| Array location | `term_peek`, with RFC redirection path | C430: `BLK_SHR 0`; C876: `blk_loc` becomes `term_loc` |
| Scalar worker arguments | opaque Term words | explicit `u32` index, accumulator and element |

Source paths are
`selfhost/build/phase68/native-products15/array-selfhost/program.c`
(SHA19087b31…) and
`selfhost/build/phase67/native-baseline02/array-upstream/program.c`
(SHA73cd2c48…). Both receipts bind the same array-batch input and imported
local-fold source. Their production revisions/toolchains remain separately
identified; this structural comparison is not a new paired timing result.

In products15's saved binary, all three Q helpers disappear as standalone
symbols. Their code lies inside `NF_FID_112_52_54_46_108_111_111_112_`
(`p46.loop`, address0x19570). The hot recurrence at0x19970–0x19b0b:

- Uses an eight-byte element stride at0x199db and0x19992.
- Tests the array RFC bit at0x199a5,0x19a43 and0x19ae4, with redirected-location
  loads on the shared alternatives.
- Retains a loaded element through RFC/tag/static checks at0x199df–0x19a38;
  possible slow paths wrap an owned box or increment its RFC.
- Loads the overwritten slot again at0x19a71 and tests whether destruction is
  required at0x19a75–0x19ab2.
- Executes no source-level per-let `err_seen` checkpoint on this optimized
  sequential path. Do not attribute the remaining gap to those source checks.

Upstream's measured batch worker `WL_FID_MAIN_C71` contains its unrolled loop
at0x8800–0x8834: fifteen instructions for two elements, with four-byte memory
operands, addition, xor, mask/index updates and one loop branch. It has no
element RFC/tag/destruction branch and no array-location redirect branch.
Clang also halves initialization stores (512bytes for128 U32 elements versus
1024bytes). Both representations fit this example's small array in cache;
the clear distinction is ownership/pointer work, not a demonstrated bandwidth
bottleneck.

The upstream mechanisms are general. In pinned `bend2/comp.ts`:

- `lay_c` and `lay_arr`, lines981–992, map `w32` leaves to C `u32` and packed
  buffer storage; an element layout containing any other word kind uses an
  array of Terms.
- `arr_cells`/`arr_op`, lines1731–1781, retain only box leaves and route scalar
  leaves through typed `blk_read/write`. `val_sink`, lines1664–1666, drops only
  owned box words. This is stronger than removing a wrapper Tuple.
- `facts_hot`, lines1421–1473, propagates possible sharing through types and
  their fields; the emission/facts fixed point starts at2777. Line2874 emits
  `BLK_SHR` from whether `t:Array` can be shared. Scalar storage and sharing
  permission are separate facts.
- `arr_loc`, lines1751–1756, additionally reuses cached locations for eligible
  spin parameters when sharing is possible. It retains a handle-equality
  fallback to ordinary lookup.

The smallest discriminating experiment is the two-axis saved-C intervention
registered in [P68-016](../../experiments/phase68/P68-016-scalar-arrays.md).
It can establish which mechanism warrants production complexity; it cannot
authorize a type-only fast path in the raw public native API.
