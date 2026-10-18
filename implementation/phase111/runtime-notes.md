# Phase111 cached runtime boundary

The direct backend links QBE-generated program code and metadata to one cached C
runtime object. Ordinary program builds need QBE, an assembler and a linker; they
do not emit a program C translation unit or invoke cproc. Acquiring or rebuilding
the cached runtime still requires a C compiler. The retained runtime remains C;
this is not a claim of a C-free bootstrap.

`selfhost/tools/performance/phase111/runtime/materialize.py` authenticates and
extracts the exact Phase108 portable-v3 runtime (`portable-source04/runtime.c`,
SHA256 `bffb4258ac362a338b18bb7a6ece1c816a46e6f3112a3cb594d65ae79cdde0dc`).
It records each exact substitution and all input/output hashes in a fresh source
snapshot. It never compiles or executes a target. The allocator, Term encoding,
reference counts, constructor ownership operations, task delivery, CLI, pure
readback and selected effect implementations remain the production routines.
Descriptor binding and scalar adapters replace program-dependent C tables and
aggregate call boundaries.

## Contract

ABI version 11101 uses `uint64_t segment(P111State *)`. The only argument is a
borrowed state pointer; owned values travel as complete 64-bit Terms. Runtime
helpers have scalar and pointer arguments, with no by-value Env aggregate.
`runtime.h` fixes and asserts the x86-64 layout: Env at offset 0, stack pointer at
16, sequence flag at 24, incoming result count at 28, next FID at 32, and 256 Term
registers at 40; the state occupies 2,088 bytes.

The 192-byte `P111Program` describes function pointers, input arities, continuation
incoming widths, flags, constructor identities/arities, static words, pure-show
data and requested effects. All metadata lives for the process lifetime.
Constructor names are semantic identities; show names are separate display
strings. Program FIDs occupy `[0, segment_count)`, followed by IO_EMIT, CLO_APPLY,
EXIT and ENTER. The runtime binds one descriptor per process and rejects an
incompatible version, missing tables, unsupported capabilities or widths, invalid
entry metadata, missing core identities and unavailable requested providers.

The dispatcher resets `next` to UINT32_MAX before each invocation. A segment that
sets a next FID has requested another segment; its numeric return value is not
interpreted as that FID. Only an unchanged sentinel returns the full 64-bit Reply
to the retained scheduler. This preserves the distinction between transitions and
task-delivery replies.

The register and result capacities are both 256 words. Byte-sized metadata limits
individual emitted arities to 255; the verifier must refuse overflow. With these
capacities the fixed static-image base is 51,413,504 words, asserted by the cached
runtime and used by descriptor emission. The source-only authenticated census in
`selfhost/build/phase111/runtime-capacity-census01.json` found 21,179 program
segments in the preserved mature compiler, maximum input width 17, continuation
incoming width 1 and constructor width 10. That historical census does not replace
checks on newly emitted programs.

## Ownership and continuations

Generic constructors allocate the production class and seal every stored child.
Generic take delegates unique/shared/static handling to `ctr_take`, then releases
the returned spare. Closures preserve the mature affine capture layout without
constructor-style sealing. Keep and sink delegate directly to the retained Term
operations. The finite primitive/special-constructor catalogue is independently
recorded in `runtime/catalogue.json` and `runtime/primitives.md`.

A continuation frame writes captures in order followed by its next FID. Return
copies result Terms into the register bank and pops only the FID. The structured
lowerer's continuation prelude then subtracts the capture count, reads captured
locals from stack offsets zero onward, and reads returned locals from register
offset zero onward. These reads all precede body operations that may reuse the
stack or scratch buffer. A continuation with zero captures still has incoming
width one; ordinary output width and incoming continuation width are distinct.
This source audit covers `segment/lower-helpers.bend` and the scalar frame/return
helpers, rather than assuming scalar machine types prove owner conservation.

ABI v1 admits one CPU worker with GPU execution disabled. The structured lowerer
uses the mature sequential interpretation of parallel lets and bang calls. This
does not qualify concurrent scheduling or GPU execution. The fixed corpus base
and production allocator remain unchanged; no new allocator is introduced.

## Providers and qualification

The cached provider set follows the selected Phase102 admission: the nine exact
compatible files in `phase90/runtime-accessor-transport02/effs`, plus NativeHost.
They provide 15 registrations. The generated binder runs after descriptor
installation, with no startup constructor that can observe unbound IDs. Requested
effects must have a registered implementation. See `runtime/effects/README.md`
for exact source provenance and the separate arbitrary-foreign-C boundary.

The coordinator compiled `runtime-source01` and passed all ten frozen direct
boundary cases (`runtime-boundaries01`). That compiler reported a possible
unsigned underflow in the retained closure-apply `arity - 1` load. Fresh
`runtime-source03` adds explicit closure tag/FID/nonzero-arity checks and bounds
on register loads, result copies and continuation subtraction. It preserves the
legitimate built-in IO_EMIT closure created by the runtime itself. Source02 is
preserved as an unexecuted intermediate with an overly restrictive IO FID guard;
source03 is the corrected candidate. Further execution receipts determine its
qualification; source preparation alone does not establish a passing gate.
