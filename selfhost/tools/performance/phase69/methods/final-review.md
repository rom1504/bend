# Independent final review: typed10

**No blocking issue found.** Source/data audit only; this reviewer ran no
compiler, Node, C compiler or generated program. Retained evidence and source
hashes are in [final-review-data.json](final-review-data.json).

## Production change and representation proof

Compared the current native implementation with `48a0dd4`: three files,
61 inserted and eight removed lines, net +53. All three current files exactly
match the checked `typed-build10/snapshot` sources.

`NF_Worker.params` now stores rendering metadata; the lowering environment and
tail-call ownership bindings are unchanged. Only trusted canonical U32, F32,
Char and Bool domains receive `NF_SCALAR`. F32 remains its integer bit pattern.
Nat, user enums, unresolved/dependent types and product fields remain Terms.

Kind extraction requires the actual worker arity to equal the original live
telescope arity, skips erased binders, and falls back on unknown heads or fuel
exhaustion. Product expansion inserts exactly its shape width of opaque kinds.
The expanded list must match the final binding count or the complete parameter
list falls back to Terms. Prototype, definition and adapter parameter counts
use the same metadata. No unsafe shape-width or erased-slot shift was found.

Only `nc_compile_checked` supplies the scalar permission, using the existing
checked-layout/trusted-effects certificate. Ordinary raw `nc_compile` supplies
no permission; its `NF_SCALAR` macro selects `Term`. No new runtime assumption,
packed-enum assertion or borrowed observer is part of this production diff.

## Retained generated-C checks

Audited all 71 candidate native control files: 68 explicitly enable typed
scalars and three disable them. The disabled cases are foreign runtime apply,
boxed array cloning, and the dependent-array audit. Their refusals agree with
the certificate boundary.

All four cold-user refusal controls emit `NATIVE_COLD_USER_CTORS 0`: captured
user value (25n), container-held user values (52n), shared literal user value
(30n), and shared dynamic user value (22n). Matching outputs therefore do not
conceal accidental certificate admission.

Generated signatures preserve large Nat and tagged user enums as Terms, narrow
actual U32 parameters, skip the erased parameter in the closure control, and
keep flattened record fields as Terms. The widening control returns
12884901887n; `U32.to_nat` retains its explicit u64 conversion before arithmetic.

All 36 retained raw C sources leave typed permission undefined. The two raw
counterexamples falsely declaring a high Nat as U32/Bool both preserve
4294967303n on one and four threads. Raw annotations therefore do not activate
the checked scalar ABI.

## Evidence scope

Root's native report passes 71/71 selected controls with no changed inputs.
Its `selectedComplete` is true and full-suite `complete` is false: this is a
focused selection, not a new exhaustive conformance run. The raw receipt has
28 passing report rows, including role-separated executions and diagnostics;
that count is not 28 distinct source programs.

The other retained gates report seven pure static-boundary queries, an exact
unchanged generated JS closure of 2,992 functions, and eight B2 driver
comparisons. Static queries do not qualify a complete near-capacity C image;
the B2 comparison executes JS and compares emitted C bytes, without claiming
native C execution or compiler fixed-point equality. Preserve these limits in
the phase report.

## Separate P69-010 diagnostic

Also inspected the finite saved-C lexer fact producer, without promoting it.
Its exact checked Mode constructors have zero/U32 payloads and Cls is a user
nullary enum. All five packed-entry edits keep full Term bits and require both
typed permission and constructor packing. The 33 scalar-result edits target
checked U32/Char results, including only field 1 of the Mode/U32 product.

Verified all plan pins, the historical fixture's membership in the checked
emission inputs, and exact reverse recovery of the parent C for each arm.
These checks qualify that finite diagnostic's derivation; a future general
rule still needs explicit constructor representation facts. In particular,
Base Bool is immediate 0/1, and a dead foreign definition can disable packing
while live-only scalar permission remains enabled.
