# Phase111 coverage and admission notes

The frozen
[manifest](../../selfhost/tools/performance/phase111/coverage/manifest.json)
contains 16 positive focused sources, three source-admission negatives and six
broader complete-output controls. Preparation and this review execute no target.
Root has since completed the first actual checked-source gate:
`source-closure01` emits the captured-closure/IO fixture through `full-api02`, and
`closure-build01` links that exact QBE with `runtime-source03/runtime.o` and
prints exactly `captured=42` plus LF with empty stderr. This establishes one
hosted checked-source/direct-QBE execution, not native compilation or self-hosting.
The remaining focused and whole-compiler gates are pending in this status note.
The serial `coverage/run.py` supervisor is prepared for root's guarded execution;
its author only parsed its Python syntax and inspected the source. The
[broad inventory](../../selfhost/tools/performance/phase111/coverage/broad-inventory.json)
also authenticates 45 earlier source/product/output records. Reused controls
remain regressions; the two new finite pure arithmetic oracles were derived
before candidate execution.

The first five executions should be unchanged Phase108 closure capture,
non-tail list recursion and arrays/IO, followed by pure U32 and String results.
Expected outputs are respectively `captured=42`, `list=14`,
`arrays=seed/changed/seed`, `42` and the quoted Unicode String, each with LF.
The first three exercise actual language operations unavailable in Phase110's
restricted library admission. They still do not establish that every closure or
continuation representation survived optimization: inspect the actual generated
segments and machine calls for that claim.

Pure-result behavior is a separate boundary from IO printing. The additional
Char, F32 and nested aggregate controls cover quoting/Unicode, float spelling,
List/Tuple/Nat/Bool/Array readback descriptors and empty lists. A compiler that
only runs IO mains has not passed these gates. Existing U32 wrap/division/modulo,
Nat arithmetic/Cmp and float arithmetic controls cover selected primitive
semantics; they do not qualify the complete runtime primitive catalogue.

The remaining high-value runtime controls are explicit: wide shifts at/above
32, Nat saturation and divide-by-zero tuple order, 48-bit Nat overflow refusal,
F32 signed zero/NaN/infinities and read/show boundaries, array swap ownership,
CAS returning the previous value, atomic fetch-add, and physically overlapping
ALeaf/ANode children. In particular, load both required children before freeing
a parent and preserve the returned redirect-bearing handle from Keep. Source
printing alone may miss ownership leaks; add pending/live-allocation checks in
the runtime probe gate. Atomic tests in a one-thread run are operation tests,
not concurrent scheduling qualification.

The generic lowering audit must distinguish a source-form inventory from actual
reachability. The selected compiler has erased lambdas, ordinary/dynamic/partial
applications, let continuations, constructor matches, scalar/array primitives,
failure paths and host effects. Obtain the complete reachable erased-form and
runtime-import census from its real checked request before full acquisition.
Record each unsupported form with its definition and node; never omit it or
fall back silently to generated C. Optional NF/NQ/observer/static optimizations
may be absent only when their generic semantic fallback remains available.

The semantic source authority is the authenticated selected mature source
`selfhost/build/phase102/projection-cost-source01/compiler.bend`, SHA-256
`63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237`.
The base source tree alone omits selected later changes. Root's composition must
bind that exact source, every additive module, Base/provider assets and the
named entry replacement. The native entry should create its checked request
through the unchanged mature frontend; no caller-supplied erased certificate
can establish source admission.

Qualification has four distinct whole-compiler steps:

1. Admit and directly emit the complete assembled Phase111 compiler source,
   including its new direct entry. Emitting only the old selected compiler can
   exercise a large input but cannot establish direct self-hosting.
2. Assemble/link the complete QBE module and descriptor against the authenticated
   runtime/providers, then run actual check/compile requests and independent
   program outputs through that directly built image.
3. Have that image emit the same frozen Phase111 source again. Compare complete
   QBE and module data where deterministic, without unexplained normalization;
   build the successor and repeat the finite request/output gates.
4. Run the full broad source/output gate once the route is stable. Keep compiler
   request clocks, generated-program runtime, acquisition cost and resource
   limits separate. An unsupported form, timeout or failed successor remains an
   incomplete milestone.

Descriptor checks must bind function IDs and address tables, argument/result
bank capacities, continuation frame widths, constructor and readback layouts,
foreign providers, static-region offsets and the distinct next-function/Reply
channels. Capture incoming arguments before resetting or overwriting outgoing
banks. Reuse of the established runtime does not by itself validate a newly
generated descriptor. Keep the selected native compiler, full Phase108 route and
portable runtime available until separate installation gates authorize change.

Root owns CPU3 execution and actual command receipts. The first cleanup proposal
authenticated 176 archived generated files against the complete Phase110 capsule
and local bytes; root subsequently removed them with a separate receipt. The
larger lossless proposal pins 21 historical raw reports/profiles/generated-C
files (1,201 MiB), with fresh compressed paths and exact raw restoration hashes.
It performs no compression or deletion. Restore any absent historical dependency
before a validator that requires it rather than weakening the validator.
