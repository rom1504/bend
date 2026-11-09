# Phase188: shared typed x86 instruction selection

The assembly and direct-object paths now consume the same typed machine
sequence. Instruction selection no longer constructs assembly for the object
writer to parse back. The implementation is Bend; host tools retain their
existing transport, independent observation and linking roles.

[Design](../../design/phase188/README.md) ·
[Architecture and usage](../../docs/self_hosted/x86-objects.md) ·
[Controls and reproduction](../../selfhost/tests/phase188/control-plan.md) ·
[Machine identities and measurements](evidence.json).

## What changed

- Register identities, widths, full-width immediate bits, memory operands,
  labels and data widths survive to a shared machine boundary.
- Constant-time sequence concatenation and explicit traversal stacks replace
  text concatenation during selection. Assembly rendering and binary encoding
  are the final consumers. Functions and assembly data slices retain bounded
  lifetimes; the object writer still materializes byte sections.
- Local relative branches are patched before ELF serialization. Only
  nonescaping, nonglobal local labels are omitted. Address-taken and exported
  labels retain their identities. Branch encodings are still near, with no
  relaxation or layout-policy change.
- Byte/name/relocation validity walks are tail recursive. Original count,
  section, alignment, name-byte and relocation bounds remain enforced.
- The assembly parser remains available for diagnostics, absent from the
  selected production compiler closure.

Shared semantic admission, ownership plans, register placement, aliases,
parallel moves, F32 rules and native IR verification are unchanged. The
canonical JS/C/QBE source remains byte-identical to Phase187:
`1e8a23ace83520a9d909cf20ce6168e5aa5a0f372d32991381dfc9bf0c544902`.

## Correctness and scale

The complete production source passes the pinned upstream checker with zero
holes. The nine focused semantic groups pass 160 exact admission rows and their
unchanged independent C observers. Typed machine-boundary controls pass 36
rows and 143 independent observations through each of the direct-object and
GNU-as routes, including forward/backward branches, memory, scalar/F32 widths,
relocations and invalid encodings. These are finite controls, not a proof of
backend correctness.

The independent fixup review caught an aggregate string-table-limit regression:
removing local symbols could otherwise bypass the old total-name-byte limit.
The implementation now enforces that limit before dropping symbols. Early API
extractions also failed because fixture-only verifier/emitter definitions were
omitted; the extraction now includes explicit lexical fixture dependencies from
both base and x86 module lists. These failures are retained as evidence.

## Cost and limits

The new native compiler successfully builds its own source through direct
objects in 208.552s, producing a working N2. That N2 passes all 45 programs through
both object and assembly output. All 45 GNU-as objects are byte-identical to the
Phase187 reference, including symbols and relocations. All 90 executables have byte-identical `.text`,
`.data` and `.rodata` sections relative to their corresponding Phase187 products.

The formerly failing hosted-JavaScript `local-fold` encoder diagnostic now
passes: checked upstream-JS execution and native execution produce the complete
same object byte sequence. This validates the fixed byte-walk stack problem on
that workload, not all possible hosted full-compiler inputs.

On the paired 45-program build suite, object/assembly geometric build-time ratio
falls 1.50939→1.07149. Object builds take 114.478s in total versus 169.062s previously;
assembly totals 106.529s versus 108.580s. Relative to their previous versions, the
geometric ratios are 0.69224 (object) and 0.97515 (assembly). The complete qualification
campaign takes 287.854s versus 337.022s, including correctness and identity checks.
These timings measure complete program builds performed by native N2 compiler
executables. They do not measure generated-program runtime. The two compiler
sources differ by the intended implementation change.

The full identical-source comparison uses the retained Phase187 source with both
old and new QBE-built N1 producers, identical Base/cache/runtime/toolchain, CPU3
and one runtime thread. Direct-object build time falls 315.348→205.019s, 35.0% less.
The resulting executable's loaded code and data remain byte-identical, while
its file size falls 39,142,352→25,516,688 bytes. The matching assembly build is
197.400s, essentially unchanged from 199.112s. Direct objects are now 1.039×
assembly build time, versus 1.584× previously. These are single controlled build observations,
not confidence intervals or cold filesystem-cache measurements.

| Same retained compiler source | Phase187 | Phase188 |
| --- | ---: | ---: |
| Assembly compiler execution | 188.704s| 187.115s|
| GNU assembler |8.327s|8.281s|
| Assembly complete build |199.112s|197.400s|
| Direct-object compiler execution |314.147s|204.238s|
| Direct-object complete build |315.348s|205.019s|
| Direct-object compiler peak RSS |2,201 MiB|1,532 MiB|
| Direct object file |46.234 MB|30.166 MB|
| Direct-object executable |39.142 MB|25.517 MB|

Both full-compiler products retain byte-identical linked code/data; the full
assembly object is also byte-identical. The output formats still differ from
one another in branch relaxation/alignment policy, as before. Assembly remains
the faster default in this measurement; the object route is much closer and
requires no assembler. The production x86 source grows by 4,447 bytes (0.27%)
and 81 lines, from 38,396 to 38,477. Tests and diagnostic source are separate.

Generated-program speed is preserved through actual code/data byte identity;
a new timing campaign would measure unchanged machine programs. Existing runtime
comparisons retain their original scope. Installed Phase183 remains unchanged;
this phase establishes a native self-build and finite corpus qualification,
not a complete new N1/N2/N3 reproduction fixed point or installed promotion.

The new boundary removes a representation round trip and permits local fixups
without an assembler. It does not yet stream the entire ELF byte representation,
relax branches, change instruction quality or establish a new bootstrap fixed
point. Those are separate claims and experiments.

## Experiment discipline

One execution lane on CPU3, one runtime thread, pinned Base/cache, runtime and
machine toolchain. Retention reclaimed about 2.04 GiB of authenticated archived
generated text while preserving compiler images, object products, baseline 45,
source snapshots, profiles and reports. Exact archive/restore receipts are under
`selfhost/build-retention/phase188/`.

## What we learned and what remains

The shared typed boundary pays off: preserving instruction operands avoids the
assembly String round trip, and explicit local labels enable fixups before
serialization. Eliminating local-symbol metadata reduces object size and memory
without changing executable instructions. These measurements cover the combined
refactor and fixup changes; they do not isolate each contribution statistically.

The next bounded opportunity is byte-section construction and serialization:
objects still materialize immutable byte lists and use considerably more compiler
memory than text emission. Measure that remaining cost before adding streaming,
a new opcode representation or branch relaxation. Register allocation and
program-runtime optimizations can now feed both output consumers directly.

## Reproduce the principal measurements

Use the existing Phase188 guarded job wrapper and the complete command vectors
in each retained guard/build receipt referenced by `evidence.json`. The native
producer is `selfhost/build/phase188/native-image05/program` with its sibling
receipt; the qualified finite-corpus N2 is
`selfhost/build/phase188/native-self-object05/program`. Its receipt binds stage N2
and `native-x86-source-v1`; select `--target x86 --emit object` or default assembly.
The same-source build input is the retained
`selfhost/build/phase187/source05/compiler.bend`, not the changed Phase188 source.

The paired catalog is `native45-final06`; the preliminary `native45-final05`
invocation was refused by the explicit-format check because the command omitted
`--emit object`. It emitted no candidate. The sourcecheck02 failure was declaration
ordering, corrected before checked acquisition. No failed gate counts as a pass.

