# Optional x86 object emission

The x86 backend can emit ELF64 relocatable objects using Bend code, then use the
existing authenticated linker and runtime. Assembly is still the default.
Select `--target x86 --emit object` in `selfhost/tools/build/native.py` or
`request.py`, with a compiler image that implements `x86-object`.

This is an output option on the existing x86 target. It shares instruction
selection, register allocation, ownership rules and all optimizations with the
assembly route. It is not a separate source-language backend.

## Current architecture

The selected backend still constructs assembly Strings. For each emitted
function, a strict Bend parser turns the supported dialect into typed machine
instructions; a Bend encoder produces bytes and explicit relocations. A Bend
ELF writer collects sections and symbols. `File.write_bytes` sends the object
without text decoding. Host tools authenticate, capture, inspect and link bytes;
they do not compile instructions or create ELF records.

The implementation is in `selfhost/src/back/x86/object-{model,parse,encode,build,elf}.bend`.
`object-build.bend` consumes the same independently verified native cursor as
assembly output. The original verification and semantic admission remain intact.

The current option supports Linux AMD64 SysV, integer instructions and the SSE
subset selected by this backend, external calls, relative branches, RIP-relative
addresses and absolute data relocations. Unsupported syntax fails explicitly.
This parser is not a general GNU assembler replacement.

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

The recorded stage must match the image binding. Older installed compilers
reject `x86-object`; adding the flag does not update an image. The build links
`program.o` directly, executes no assembler, and records `assemblerSkipped`,
`emissionFormat`, exact bytes and tool identities. Use `--expected-object` for
complete object-byte comparison. `--ir FILE.o --target x86 --emit object` links
an already emitted object through the same authenticated machine-build path.

## Limits and qualification

Each text, read-only data and writable data section is capped at 32 MiB. Objects
are currently materialized in memory; this is not a streaming full-compiler
object writer. Text alignment is at most 16 and data alignment at most 8. These
bounds refuse before publishing a successful artifact. One complete native self-build through object output has passed; full
reproduction fixed-point qualification remains separate.

Branches currently use near encodings, without GNU-as relaxation or its
`-mbranches-within-32B-boundaries` policy. Byte identity, code size and program
runtime may differ. This option is experimental and is not the default or the
installed compiler selection. Its initial purpose is establishing a correct
Bend-written binary-output path, not claiming compilation or execution gains.

The useful next step is to produce these typed instructions directly from the
shared selector, eliminating text formatting/parsing, and to stream sections
with bounded metadata. Measure those costs before promoting the option.

See the [Phase187 report](../../implementation/phase187/README.md),
[design](../../design/phase187/README.md), and
[reproducible control plan](../../selfhost/tests/phase187/control-plan.md).

The initial same-source self-build measured 315.35s for object output versus
199.11s for assembly plus GNU as. The short 44-case runtime ratio was 0.994×.
Therefore the object format remains experimental; use assembly for build speed.
See the report for the 45-case checks and the hosted-JS diagnostic stack limit.
