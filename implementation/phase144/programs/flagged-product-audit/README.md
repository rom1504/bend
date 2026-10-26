# Two flagged products: static findings

This read-only inspection follows the completed720-observation screen. The
selected post-hoc recheck uses eight alternating pairs, unchanged binaries,
runtime arguments, repetition/warmup counts and complete-output oracles. It does
not replace or pool observations into the original full-corpus score.

## Complete generic row32

Phase143 and final03 code-generation roles use the identical atomic runtime.
Only the direct`String.append` function changes among923 generated functions.
The QBE adds a call to`p125_rt_concat_typed`, tests its nonzero result, and retains
the original complete TRMC worker as fallback. That wrapper grows8→26 assembly
instructions; total executable text grows64bytes. No other generated assembly
function changes after normalizing local label names within each function.

The frozen workload includes complete-result serialization in its timed loop.
`p93.value` calls`p88_row_output`, which serializes all four128-slot arrays using
recursive `++`; `p93.loop` validates the entire resulting String on every
iteration. The change therefore affects work inside the benchmark, not just its
initial print. The runtime's typed-concat helper checks whether the left spine
is dynamically mutable; refusal leaves both operands untouched and invokes the
old worker. Extra attempted ownership checks are a plausible cause, but dynamic
success/refusal counts are not measured here. The64-byte layout shift may also
matter. Static evidence alone cannot apportion the observed slowdown.

The exact before/after assembly and QBE diff are retained beside this file.
The source is pinned in the original corpus/acquisition; relevant source names
are `p88_row_numbers`, `p88_row_array`, `p88_row_output`, `p93.value`, `p93.loop`.
The exact runtime helper is in`selfhost/build/phase128/runtime-borrow01/runtime.c`
at`p125_rt_concat_typed`.

## Raytrace

Omitting the outer range pass changes four QBE functions and adds1,086 text
bytes. QBE produces the **same entire object bytes**, however. All1,194 generated
assembly functions match, and both links use the same serial runtime. Every
allocated ELF section has the same bytes, size and address except the GNU build
ID. `.text` is193,537bytes at the same address with SHA256
`80d082b1e3f074d8b2056d43d606e3f8bfdfaa342f17391a26a9c93bbf0fe76e`.
The program descriptor also has the same address.

There is consequently no changed instruction, runtime or loaded-code layout to
explain the original5.86% ratio. The fresh recheck tests reproducibility and
measurement variation; it is not an optimization experiment. Different whole
ELF hashes alone do not establish different executed code.

## Reproduction and limits

`report.json` pins the acquisition, both roles' QBE/object/binary/runtime/build
and emission receipts, retained assembly and the existing read-only
`selfhost/tools/performance/phase127/compare-machine.py` inspector. Its `inspect`
function reads ELF sections, bytes and addresses through `readelf`; it does not
run the program. QBE functions are delimited by their `function ... $name(...)`
headers and closing braces. Assembly slices use the matching symbol through its
`.size` directive; `.Lbb` labels are renamed by first occurrence per function
before text comparison. The actual executable section comparison uses original
unmodified bytes and addresses.

No compiler, assembler, linker or benchmark was executed for this inspection.
The coordinator owns the separate40-second guarded recheck in
`selfhost/build/phase144/programs-recheck-plan01/jobs.json`.
