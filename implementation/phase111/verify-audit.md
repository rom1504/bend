# Phase111 structured segment admission

Status: source implementation and named controls prepared; execution receipts are
owned by the root Phase111 runner. This note is not evidence that the controls or
the full compiler have passed.

`selfhost/tools/performance/phase111/segment/verify.bend` exports
`p111_verify_program(P111Program) -> String`. Empty output admits the program;
otherwise the first error includes its segment name when applicable. The QBE
emitter is a separate consumer and must only receive admitted IR.

The source uses the actual Phase111 model and signatures in `runtime/runtime.h`
and `runtime/primitives.h`. Primitive arities match the operation catalogue.
It does not recover structure from C text or introduce another source parser.

## What the gate establishes

- Function and constructor identities are nonempty, bounded, NUL-free Unicode
  names with no duplicates. Symbol lookup uses the mature exact-name Patricia
  index, preserving collision buckets, rather than a whole-book linear scan.
- Metadata fits the runtime's 16-bit IDs and byte-sized arities. Four runtime
  function IDs remain reserved. `main` exists and is a direct zero-argument
  segment. Output `result` and continuation `incoming` are distinct fields.
- All local uses follow a definition on every surviving predecessor path.
  Branches intersect live environments; a terminated predecessor does not
  constrain a continuation. All paths terminate, and no statement follows a
  terminal path. The sole implicit parameter is the `state` pointer.
- Each mutable local has one global width within a segment. Comparisons consume
  their declared scalar width and produce U32. Unsupported operators, arbitrary
  data symbols, and QBE-unsafe local names are refused. Semantic names use the
  emitter's injective Unicode-code encoding rather than C-name sanitization.
- Runtime calls name a declared segment import, return U64, use the exact
  argument widths/count, and pass the actual `state` local. Constructor, jump,
  closure, frame, return, primitive, and special-constructor counts obey their
  known static contracts. Direct jumps and closures target direct segments;
  frame captures plus incoming values equal continuation arity.
- Register and captured-stack indexes fit the current segment. Scratch
  allocations fit 2048 bytes, are uniquely declared, and use admitted QBE
  alignments. Loads/stores and runtime buffers fit a known allocation/state
  extent. Dynamic offsets or pointers with unknown extent are refused.

Global indexing is bounded by trie depth. Per-segment declaration and flow
passes are linear in statements apart from bounded trie lookup and branch-live
intersections. They do not scan every program segment per function reference.
The constant-size import and primitive catalogues remain simple tables.

## Explicit limits

This is structural and ABI admission for trusted Bend lowering, not a whole
compiler proof, an ownership proof, or a foreign-code sandbox. In particular:

- It does not establish initialization of each scratch byte, ownership/linearity
  of individual Term words, semantic correspondence with checked Bend, or that
  a raw state store preserves runtime invariants.
- It checks offset alignment and bounds; it does not propagate a separate base
  pointer alignment lattice. The target is x86-64 and the selected lowerer uses
  an eight-byte-aligned scratch allocation with eight-byte slots.
- Return values are typed machine words. The gate does not prove that the
  chosen scheduler transition is semantically the intended one.
- Show descriptors and effect declarations retain the mature formats and remain
  subject to runtime descriptor validation. The gate does not reimplement that
  format or prove that host effects exist.
- Exporting a scalar-returning synthetic segment from this verifier's controls
  is not evidence that the full runtime descriptor is executable.

These limits are deliberate: frozen semantics, runtime checks, differential
controls, and ownership laws remain necessary independent gates.

## Named controls

`selfhost/tools/performance/phase111/controls/verify.bend` exports
`p111_verify_controls() -> String` for the ordinary checked-library bridge.
Each line is `name|PASS-or-FAIL|diagnostic`. The small descriptors are fixtures
for the verifier only and **must never be run as native programs**. Root should
record all rows, require each PASS and the expected row count, and retain the
bridge source/module hashes.

Positive controls cover assigned/mutable values, both-branch definite assignment,
a surviving nonterminal predecessor, complete branch termination, comparison
widths, bounded scratch, runtime imports, a primitive count, and a frame whose
incoming result is distinct from capture count. Negative controls mutate one
structural property at a time: undefined locals, width changes, partial joins,
termination, state replacement, token/symbol injection, unknown IDs/imports,
argument/result/count mismatches, capacity and alignment, allocation uniqueness,
unsupported binary operators, truncation, duplicate identities, and ABI metadata.

The primitive control intentionally checks argument-buffer capacity only; it
must not be interpreted as a runtime execution or initialized-memory test.
