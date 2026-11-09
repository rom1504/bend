# Phase187 direct-object controls

The maintained compiler's checked Bend export owns every encoding decision:
`x187_assemble(text: String) -> X187ObjectResult{bytes: List<U32>,error:String}`.
`object-controls.mjs` only transports exact assembly text, serializes validated
bytes, reads ELF metadata and orchestrates independent tools/observers. It never
implements instruction selection, code encoding, relocation application or
object writing. Root alone runs jobs under `phase187/job.py`; this plan is not an
execution result.

The default fixture is `object-controls.s`, with `object-controls.c` and exact
`object-controls.stdout`. Its19 functions and five data globals cover:

- U32/U64 arithmetic and compare results over a12×12 raw-word grid; shifts mask
  machine counts, high words remain visible, and output buffers have canaries.
- Full64 immediates; low/high GPR encodings; extended byte-register REX; U32
  zero extension; negative and128-byte memory displacement; RBP zero-displacement
  handling and R12 SIB encoding; LEA; preserved RBP/R12; ordinary call stack use.
- Forward and backward conditional branches, RIP-relative data addresses,
  external calls, absolute pointer addends, external-data and function pointers.
- `.byte`, `.long`, `.quad`, `.zero`, `.balign`, symbol type/size/global bindings,
  static bytes and addresses observed from an independent C translation unit.
- All93 frozen Phase112 binary F32 labels, including ordered/unordered compares,
  signed zero, infinities, subnormals and NaN class; seven frozen U32 conversions.
  Each is repeated with three upper words. XMM2/XMM15 exercise extended SSE
  register encodings; results are observed as full64 raw words. No host floating
  arithmetic supplies the oracle.

The exact default output reports926 observations. Both the direct object and
GNU-as reference must independently pass the same observer. The runner verifies
API/assets/source binding and input hashes, finite byte values, deterministic
re-emission, eight malformed-parser/encoder refusals, ELF64 little-endian
ET_REL/AMD64 identity, bounded sections/symbols/RELA, local/global symbol ordering,
relocation width/bounds/types and nonexecutable-stack metadata. When exported,
`x187_parse_controls` and `x187ec_controls` additionally require the fixed38/106
row inventories and exact checked-source fixture pins; absence is reported
explicitly rather than counted as a pass. It compares global
and undefined symbol inventories with the reference. `readelf -W -h -S -s -r`
and `objdump -drw` are separately captured for both objects; every process command,
status, timing, stdout/stderr and product is pinned in the report.

The malformed controls are invalid opcode/register/operand arity/destination/
register class, duplicate labels, unsupported directive and a numeric literal
larger than64 bits. Refusals require a nonempty error and an empty byte list.
None is linked or executed. These controls are finite contract observations,
not an assertion that the parser supports arbitrary GNU assembly.

`--mode elf` isolates the ELF writer using checked exports
`p187el_controls`, `p187el_object`, and `p187el_assembly` from
`object-elf-controls.bend`. It requires exactly27 named control rows and the
independent seven-entry RELA inventory (four text, one rodata, two data records),
then runs `object-elf-oracle.c` against direct and reference objects. Its exact
output reports27 observations. GNU as resolves the local branch internally,
so its relocation count is six rather than seven; these counts need not match.
No parser invocation occurs in this mode. The writer fixture must occur in the
exact checked source-assembly manifest.

Example root-owned guarded invocation (substitute a complete checked receipt):

```sh
python3 -B selfhost/tests/phase187/job.py object-controls01 60 128 \
  selfhost/.assets/bin/bun selfhost/tests/phase187/object-controls.mjs \
  --api selfhost/build/phase187/object-api01/report.json \
  --assets selfhost/manifests/assets-native.json \
  --out selfhost/build/phase187/object-controls01
```

Add `--mode elf` for isolated writer controls. To reuse actual emitted Phase186
machine controls, pass `--assembly emitted.s --observer controls.c --expect
expected.stdout`; repeat `--extra preserved-abi.s` when needed. The runner pins
local quoted C includes recursively. Pass only the Bend-emitted assembly, **not**
`*-combined.s`: arbitrary GCC-generated assembly is outside the selected parser
contract. C observers and extra ABI shims compile through the unchanged external
toolchain, then link separately with each emitted object. The emitter's existing
`.globl` entries make the x86 private functions accessible across those objects.
No fixture body is rewritten by the host.

## GNU-as policy and interpretation

Current assets use `-mbranches-within-32B-boundaries`, `-no-pie`, and the declared
pthread/math libraries. GNU as may shorten branches, insert branch-boundary
padding and redundant instruction prefixes, and choose a shorter immediate
encoding. The direct encoder initially uses rel32 branches and does not claim
the same branch padding policy. Text `.balign16` remains supported; the current writer admits data/rodata
alignment at most8, matching maintained P111QData. The default fixture uses
`.balign8` for data and makes no16-byte data-address assertion. Unsupported
larger data alignment must refuse, rather than publish an under-aligned section.
Every admitted `.balign` still must hold.
Actual ELF instruction offsets, text size, branch lengths, relocation counts,
symbol offsets and complete binary bytes may differ while semantics agree.
The runner records text-size ratio and both disassemblies; it does not assert
byte identity or infer generated-program runtime from object-emission savings.

The linker's treatment of PLT32 versus PC32, absolute addends and local branch
relocations must be observed in linked execution. `.note.GNU-stack` prevents a
silent executable-stack change. Linker overflow or unsupported relocation is a
failure, never a zero placeholder. Initial non-PIE qualification does not imply
PIE/shared-library, other architecture, parallel runtime or GPU support.

Once the focused controls pass, root can feed unchanged Phase186 XMM, u32float,
parallel-move, call-argument, callee-save and expression assemblies through this
runner. These extend live-register, alias, branch and calling-convention coverage
without claiming new optimizer behavior. Full source/runtime qualification and
native self-reproduction remain separate gates. A matched runtime screen is
needed before claiming unchanged program performance because layout alone can
change runtime despite exact semantic outputs.

## Actual native program checks

The maintained `qualification.py` explicitly refuses object emission. The
bounded `native-catalog.py` adapter therefore uses the maintained `native.build`
object route and the existing independent native45 complete-output/count oracle.
It defaults to10 representative cases; `--cases id,id` selects an explicit set,
and `--all` selects all45. Each source and complete expected stdout is pinned to
the unchanged catalog. Candidate requests require explicit native image, receipt,
stage, target x86 and `--emit object`; the adapter checks the returned object
format and absence of an assembler job before executing each result once.

The default reference is the retained Phase186 native45 x86 role, authenticated
by exact source, oracle, assembly and ELF identities. It is neither rebuilt nor
run, and is labelled `retained-authenticated-not-executed`, never a fresh pass.
Use `--execute-reference` for a fresh independent observation of those retained
programs, `--only-object` to omit reference metadata, or `--build-reference` for
a fresh installed/explicit text-assembly build. Recorded compiler/ELF clocks
are diagnostic only; this adapter produces no runtime performance aggregate.

Example root command, substituting the actual image stage and its binding:

```sh
python3 -B selfhost/tests/phase187/job.py native-ten01 600 256 \
  python3 -B selfhost/tests/phase187/native-catalog.py \
  --assets selfhost/manifests/assets-native.json \
  --host native --stage N0 --target x86 --emit object \
  --image selfhost/build/phase187/native01/program \
  --image-receipt selfhost/build/phase187/native01/report.json \
  --out selfhost/build/phase187/native-ten01 --seconds 590 --guarded
```

This is finite generated-program qualification. It does not replace native
self-reproduction, optimizer controls, runtime-specific tests or installed-image
promotion. The adapter stops at the first discrepancy and retains its complete
build receipt and process outputs.
