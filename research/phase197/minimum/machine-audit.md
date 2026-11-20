# Actual emitted machine activation

The actual ELF object instructions confirm the eight-instruction prediction in
all three edit-distance programs. This audit disassembles frozen objects; it
neither executes a target nor infers instructions from typed assembly.

| Case | Qualified baseline | Minimum | Combined |
| --- | ---: | ---: | ---: |
| editdist | 64 instructions / 277 bytes | 56 / 253 | 55 / 247 |
| local-pair | 64 / 277 | 56 / 253 | 55 / 247 |
| variation-editdist-3-123 (held out) | 64 / 277 | 56 / 253 | 55 / 247 |

Counts cover the positive straight-line body of `$product.row`, excluding its
final backward JMP and the loop-header CMP/JNE. Thus including the backward JMP
adds one instruction to every column. The ELF symbol is
`p113d_FID_36_112_114_111_100_117_99_116_46_114_111_119_`.
The extraction follows the function's final backward jump to its header and the
header's JNE target to the positive body; it asserts there are no internal
branches/calls/returns in that body.

Two minimum sites activate per row body. The first seven-instruction copy/CMP/
CMOV/publication sequence becomes these two actual decoded instructions:

```asm
cmp    r8,rsi
cmovae r8,rsi
```

The second six-instruction sequence becomes these three instructions, followed
by the original publication:

```asm
cmp    r8,rsi
mov    r11,rsi
cmovb  r11,r8
mov    QWORD PTR [rbp-0xb18],r11
```

This removes five plus three instructions, as predicted. There is no discrepancy.
The inequality Boolean CMOV earlier in the body remains unchanged. The combined
body has one further reduction: its opening `mov r10,rsi; sub r10,0x1` becomes
`lea r10,[rsi-0x1]`. The original increment sequences remain; consequently neither
candidate reproduces the full eleven-instruction handwritten Phase196 reduction.

Concrete editdist object addresses: baseline body `[0x7687,0x779c)`, minimum
`[0x754c,0x7649)`, combined `[0x752e,0x7625)`. Minimum's two sites begin at
`0x75f1` and `0x7609`; combined's begin at `0x75cd` and `0x75e5`.
The complete raw-byte function disassemblies, indexed bodies, normalized diffs,
addresses and exact object SHA-256 pins are in `machine-evidence/`. Addresses are
object-section addresses, not linked executable addresses.

The minimum objects for coverage-bst-64, coverage-bst-32 and mandelbrot are
byte-identical to their qualified baseline objects. Combined changes the BST
objects by the separately owned decrement rule and leaves mandelbrot identical.
Whole-object decoded instruction counts fall by 113 for each edit-distance
minimum candidate (126 for combined); these are static totals, not hot-path or
runtime estimates. This report certifies the two named hot sites, not a complete
attribution of every changed instruction elsewhere in each object.

Reproduce from the repository root:

```sh
taskset -c 0 python3 research/phase197/minimum/audit-machine.py
```

The script reads the qualified `phase195/native45-01` baseline objects and the
`phase197/shared-emission01/{minimum,combined}` objects, records objdump's version,
and writes research evidence only. Focused correctness controls are separately
recorded in `control-evidence.json`. This structural observation does not assert
runtime benefit or replace the qualification owner's ordinary-program oracles.
The qualification owner had frozen whole-object comparisons before timing; this
more detailed independent loop audit finished while timing was underway.
