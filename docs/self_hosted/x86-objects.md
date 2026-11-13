# Direct x86 object emission

The x86 backend emits ELF64 relocatable objects using Bend code, then uses the
existing authenticated linker and runtime. Direct objects are the
`selfhost/tools/build/native.py --target x86` source-build default and the
Phase189 public executable/`--run` default. Explicit public `.s` output remains
assembly. Raw `request.py` and the generic `bootstrap.py` retain assembly defaults;
select `--target x86 --emit object` there for binary output, with a compiler
image that implements `x86-object`.

The [Phase189 report](../../implementation/phase189/README.md) binds the checked
Phase188 x86 source and actual QBE-built N1 → object-built N2 → object-built N3
lineage. Phase189 installs that x86 N2 after all 64 finite catalog cases and ten
runtime controls pass through objects; all 14 installed public-command controls
also pass. JS/C/QBE retain their exact Phase182
identities, and the previous Phase183 x86 image and selector remain available
for rollback.

This is an output option on the existing x86 target. It shares instruction
selection, register allocation, ownership rules and all optimizations with the
assembly route. It is not a separate source-language backend.

## Current architecture

Instruction selection produces typed machine sequences directly. Registers carry
architectural indices and widths; operands retain full immediate bits, memory
addresses and symbolic references. Instructions, labels, sections and data widths
survive until the final consumer:

```mermaid
flowchart LR
  A[Verified native bodies] --> B[Shared optimization and register placement]
  B --> C[Typed x86 instructions and data]
  C --> D[Assembly renderer]
  C --> E[Binary encoder and local fixups]
  D --> F[GNU assembler]
  E --> G[ELF object writer]
  F --> H[Existing linker and runtime]
  G --> H
```

Selection lives in the existing scalar, floating, call and function modules.
`machine-model.bend` and `machine.bend` define sequence composition and assembly
rendering; `object-model.bend` defines numeric operands and object records.
`object-build.bend` consumes the same typed sequences, `object-encode.bend`
encodes instructions, and `object-elf.bend` writes the object. The old strict
`object-parse.bend` parser is a test/diagnostic API, absent from the selected
production source closure. Object output never renders or parses assembly.

Both consumers release typed sequences per function; assembly additionally writes
data in slices of at most128 directives. The object writer still retains byte
sections in memory. It resolves local relative branches and omits unescaped,
nonglobal local symbols; address references, exported symbols and unresolved
external relocations retain their explicit identities. The encoder still uses
near branches and does not perform relaxation.

`File.write_bytes` sends objects without text decoding. Host tools authenticate,
capture, inspect and link bytes; instruction selection, encoding, fixups and ELF
records are implemented in Bend. Original native verification and semantic
admission remain intact. Supported instructions are the Linux AMD64 SysV scalar
and SSE subset selected by this backend; invalid encodings fail explicitly.

## Build

Use a fresh output under the existing disk/resource guard. The producer image
and its receipt must be supplied together:

```sh
python3 -B selfhost/tools/build/native.py \
  --assets selfhost/manifests/assets-native.json \
  --image /absolute/compiler --image-receipt /absolute/report.json \
  --host native --stage N1 --target x86 --emit object --mode cache \
  --source /absolute/program.bend --out selfhost/build/example/object \
  --seconds 60
```

The explicit `--emit object` above also records the intended format for replay;
omitting it from this x86 source build has the same effect. The recorded stage
must match the image binding. Older installed compilers
reject `x86-object`; adding the flag does not update an image. The build links
`program.o` directly, executes no assembler, and records `assemblerSkipped`,
`emissionFormat`, exact bytes and tool identities. Use `--expected-object` for
complete object-byte comparison. `--ir FILE.o --target x86 --emit object` links
an already emitted object through the same authenticated machine-build path.

Use `--emit assembly --retain-ir` on a fresh native build for assembly output and
`program.s` ownership maps or inspection. Raw assembly remains available with
`request.py --target x86 --emit assembly`, or publicly with
`selfhost/bend --target x86 input.bend -o output.s`. Public output filenames other
than `.s` request a linked ELF, including names ending in `.o`; use the maintained
request tool for raw objects. The public selector's `defaultEmission: object`
controls executable construction; an absent field preserves the old assembly
default for rollback.

## Limits and qualification

Each text, read-only data and writable data section is capped at 32 MiB. Objects
are currently materialized in memory; this is not a streaming full-compiler
object writer. Text alignment is at most 16 and data alignment at most 8. These
bounds refuse before publishing a successful artifact. Phase189's actual N2
builds the same complete compiler source into N3 with object bytes identical to
those that produced N2. This reproduction is separate from source acceptance,
finite catalog/runtime controls and public-interface qualification.

Branches currently use near encodings, without GNU-as relaxation or its
`-mbranches-within-32B-boundaries` policy. Byte identity, code size and program
runtime may differ between formats. The object default requires no external
assembler; it does not imply faster compilation or generated-program execution.

See the [Phase188 refactor report](../../implementation/phase188/README.md),
[design](../../design/phase188/README.md), and
[reproducible control plan](../../selfhost/tests/phase188/control-plan.md).
The [Phase187 report](../../implementation/phase187/README.md) preserves the
text-parsing prototype and its315.35s versus199.11s same-source build result.
Those timings describe the old implementation, not the typed path.

Phase188's controlled same-source build takes 205.02s for direct objects versus
197.40s for assembly. The older object route took 315.35s. Both new formats preserve
the corresponding baseline's machine code on the full compiler and the
45-program corpus. Direct objects take 1.039× assembly time in this measurement,
while improving 35.0% over the previous object path. See the report for stage,
source and statistical scope; the Phase189 default change is a separate release
decision.
