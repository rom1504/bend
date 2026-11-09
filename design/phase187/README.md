# Phase187: optional ELF object emission for the x86 backend

Implement an optional `--target x86 --emit object` route, keeping assembly as
its default and retaining the existing runtime and linker. The experiment
starts at 2026-11-09 16:40 UTC with a one-hour working budget.

The maintained selector already constructs Strings at instruction selection
sites. Converting every selector to typed fragments in this budget would put
recent optimizations at risk. This first implementation therefore retains
selection, parses its finite emitted dialect in Bend, encodes structured x86
instructions in Bend, and writes ELF64 relocatable objects in Bend. This is an
integrated assembler, not yet elimination of assembly text construction.
Unsupported syntax must fail explicitly. There is no host-language encoder.

The independent native-body verifier, ownership, stack-safe control flow,
register placement, runtime ABI and all current optimizations stay upstream of
this new serialization path. The selected native compiler remains unchanged.

## Interfaces and validation

1. Typed operands/instructions and explicit relocation records.
2. Strict parser for the existing emitted dialect; no arbitrary assembler.
3. Encoder for emitted integer/SSE instructions, labels, calls and data.
4. ELF64 sections, symbols, RELA records, non-executable-stack declaration.
5. Binary `File.write_bytes` output and authenticated host build integration.

Check the Bend source independently. Exercise the encoder through actual
checked Bend exports. Inspect objects with system readelf/objdump; link them
with independently compiled C observers and compare against GNU as output.
Use boundary integers, widths, shifts, floating point, branches, calls,
callee-saved registers and address/data relocations. Then compile real Bend
programs through the existing selector and compare exact expected outputs.
Malformed instructions, bad operands and unresolved local labels must refuse.

Near branches and explicit displacement choices can change layout relative
to GNU as, which also applies `-mbranches-within-32B-boundaries`. Thus identical
semantics do not imply byte identity or runtime parity. Measure these rather
than claiming them. Full self-hosting qualification is a later gate if a
bounded full pipeline is not ready inside this experiment.

## Cost hypothesis

Phase186 x86 N2 acquisition took 290.135 s: compiler emission 279.430 s,
GNU as 8.020 s, link 0.228 s. Removing GNU as alone saves at most about 2.8%
before paying for the Bend encoder. This initial implementation tests
capability and correctness, not an assumed speedup. Avoiding assembly Strings,
streaming large object sections and branch relaxation are separate next steps
only justified by measurements. Preserve all failures and exact artifacts.
