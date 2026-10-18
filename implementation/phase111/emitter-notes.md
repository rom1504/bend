# Phase111: direct QBE module emission

The new emitter consumes structured `N111Stmt` bodies. It does not inspect C,
generate C expressions, invoke cproc, or extend the restricted scalar Nx model.
Its algorithms are written in Bend under
`selfhost/tools/performance/phase111/qbe/`.

## Architectural findings

QBE already accepts mutable non-SSA temporaries and constructs SSA internally
(`qbe-1.3/doc/il.txt`, “Non-SSA temporaries”). Therefore ordinary structured
locals can remain QBE temporaries: allocating a stack slot and loading/storing
every variable would introduce avoidable work. The emitter creates explicit
memory only for `N111Alloca`, loads, stores, and runtime state access. Static
allocations are hoisted to the entry block. Branches get distinct labels; a
join appears only when at least one branch falls through. Missing terminators
and instructions after a terminating statement deliberately produce invalid
output if admission is bypassed.

QBE 1.3's integer lexer consumes decimal integers. A hexadecimal spelling that
looks reasonable in C is not an exact-integer interchange format for this
version. `numbers.bend` prints a full unsigned 64-bit bit pattern directly from
two U32 halves, using base-65536 long division by ten. Each arithmetic
intermediate stays below 655360. It does not round through a JavaScript Number,
floating point, or Bend Nat's smaller immediate range.

A metadata distinction emerged during integration: a segment's output width
and a continuation's incoming result width are different facts. Production
uses `nb_frame_results(frame, parameter_count)` for the latter. The structured
record now retains both `result` and `incoming`; descriptor `result_width`
uses the former and `fid_results[]` uses the latter. Collapsing these fields
would silently misread continuation frames.

## Interfaces and layout

`p111q_segment(segment, ids)` emits one exported function taking a borrowed
state pointer and returning a complete 64-bit Reply. The runtime communicates
the next trampoline function separately through `state.next`; Reply is never
narrowed to a function ID. The generic runtime owns allocation, reference
counts, closures, constructors, continuation transitions, and primitives.

`p111q_chunks(program)` emits independently usable function/data chunks;
`p111q_text(program)` is the convenience whole-module interface. The caller
must run `p111_verify_program` first. Function and constructor IDs use one
Patricia index per program, so a reference does not scan all 21,000-plus
segments. Chunk accumulation prepends to lists and finishes once, avoiding a
growing output-prefix copy. The current convenience interface still retains a
whole module; actual streaming to a file remains a frontend decision.

`data.bend` describes byte/word/long fields, explicit relocations, and zero
runs. `program.bend` emits the 192-byte, 24-slot runtime descriptor and its
tables. Integer tables have their declared byte widths. String metadata is
UTF-8 with a trailing zero. Constructor identities remain raw; pretty-print
names are a separate table. Empty tables have a one-byte sentinel object and
a zero count. ABI v1 has no static image and requests sequential execution.

Segment linker names use the existing injective Unicode-codepoint encoder.
The verifier restricts local names to ASCII identifiers; emission copies them
into a disjoint `%v_` namespace instead of repeatedly Unicode-encoding every
use. Generated addresses and block labels use `%t_` and `@b_`. This local-name
contract is another reason admission is required before public program
emission. No scalar Term is represented as a U32 or raw host pointer merely
because its current value fits.

## Bounded controls

`data-controls.mjs` is an independent host oracle, not compiler logic. It
compares 272 boundary/pseudorandom 64-bit values against BigInt decimal output
and checks two exact data/relocation strings. It prepares QBE data plus a C
readback harness covering complete 64-bit words, mixed-width layout, zero
padding and actual linker relocations. Root reported all controls and the
QBE/assembler/native readback passed (`data-controls01`, `readback01guard`).

`emitter-controls.mjs` prepares separate fixtures for mutable branch joins,
explicit stack memory, 64-bit pointer loads/stores, retained effect calls,
fully terminating branches, invalid fallthrough/post-return output, metadata
widths, UTF-8, descriptor relocations and a pure-42 program using the real
continuation-return ABI. It does not invoke a compiler or execute targets.
Root owns execution and records the results; these controls do not establish
whole-language conformance or performance by themselves.

Root subsequently linked and executed the real-runtime pure-42 fixture and
observed stdout `42`. This establishes the complete emitted module's basic
continuation-return, descriptor, runtime and native-toolchain connection.

The exact dependency slice containing the new module emitter passed source
checking in 1.64 seconds (`qbe-api03`, root-reported). Full semantic integration,
native linking and compiler self-hosting remain separate gates. No speedup or
complete self-hosting claim follows from successful module emission alone.

## Remaining limits

The initial arithmetic vocabulary intentionally contains only operations the
lowerer uses; full Bend primitive semantics live behind typed runtime calls.
All imports remain effectful to QBE. The initial IR carries scalar words and
explicit memory; it does not yet contain ownership proofs that justify
removing runtime calls. No static constructor image, parallel execution claim,
cross-function inlining, speculative specialization or instruction-selection
policy is hidden in this emitter. These are independent future decisions,
after the complete direct path is qualified.
