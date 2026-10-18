# Phase111 structured segment lowering

The semantic baseline is the selected Phase102 compiler at
`selfhost/build/phase102/projection-cost-source01/compiler.bend`, SHA256
`63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237`.
This note describes source implementation; successful source checking and
machine qualification require their separate execution receipts.

`p111_lower_request` consumes an internally prepared, checked `NR_Request`.
It retains `nc_compile_error_known(source,bound)`, the native erasure already
recorded as `NativeErasedBody`, exact constructor identities, literal compaction,
occurrence-ID ownership sets, and checked source metadata. It does not establish
that an arbitrary caller-constructed `NR_Request` was checked. The native entry
must obtain the request through the mature checked frontend.

The generated representation consists of typed machine values and statements.
No generated C expression or C body is accepted, split, or parsed. The indexed
function/constructor identifiers are resolved by the QBE module emitter. Every
segment receives one borrowed state pointer. All owned values use full U64
words. A reusable 256-word stack buffer holds arguments and helper results;
constructor fields are copied into fresh locals before that buffer is reused.
Direct-entry parameter width, continuation incoming-result width, and output
width are separate metadata. A continuation pops saved captures, reads them
from the stack, and reads returned values from the register bank.

The port preserves the generic bridge's ordered argument evaluation, lifetime
partition, keep-result rebinding, constructor child sealing, unsealed closure
captures, exact constructor discrimination, destructuring, currying, saturated
ordinary calls, dynamic closure application, and continuation creation. Named
ordinary user factories use the same typed-arity eta-entry criterion as the
mature generic path. Foreign, primitive, and bang-referenced factories retain their actual bodies.
Bang membership comes from the same cached request closure as mature lowering.
Primitive operations are explicit calls to a finite runtime catalogue whose
source is audited independently. Nat constructor-run compaction retains the
first checked increment before adding the remaining offset.

The initial CPU capability is sequential execution. A parallel `Let` uses the
same ordered sequence used by the mature bridge when `seq` is true. This is not
qualification of the nonsequential task scheduler, GPU dispatch, or worker
concurrency. Bang calls execute in the sequential state. The runtime module
owns its Reply/transition protocol and effect-provider validation.

The request has not passed through static preparation or optional native worker
planners. Consequently `NFCall`, `NQBundle`, `NQBox`, `NTRCons`, `NWPattern`, and
`NStatic` are refused if supplied. The ordinary erased forms that create these
optimized forms are instead lowered by the generic route. This deliberately
forgoes typed-flat workers, product layouts, constructor-cell reuse, scalar
array specialization, literal static images, and specialized observers. It is
not a claim of preserving their compile-time or runtime performance.

The structural verifier is a separate implementation. It must check identifiers,
constant widths, definite assignment, consistent local types, exact runtime
helper signatures, helper count/metadata relationships, terminal paths, and
fixed capacities before emission. Scalar typing alone is not an ownership proof:
the lifetime decisions rely on the checked request and the direct semantic port.

Initial source review corrections, before the first complete lowerer gate:

- Separate `N111Segment.incoming` from `result`: ordinary entries have incoming
  zero; a saved continuation has incoming one even when it captures no words.
  This preserves `FID_RESW_T` rather than confusing it with output width.
- Compare the runtime U64 constructor tag against a zero-extended constructor
  ID at U64 width; comparison results remain U32.
- Retain original factory bodies for definitions named by a bang reference,
  using `nc_bangs_names` over the actual cached request. This also retains their
  bang flag on generated segments instead of applying ordinary eta factories.
- Defer named-definition arity lookup until the application head is a `Ref`,
  and defer saturation admission until it is not a bang reference, preserving
  the mature lazy classifier order.
- Directly sequence matcher arguments only for a single argument or a list of
  already-evaluated variables. Additional unevaluated arguments use binary
  slow application, so matching is not moved after later argument evaluation.
- Static source checks corrected two unmatched delimiters and marked reused
  pattern fields explicitly before the next compiler snapshot.

The earlier qualified mature compiler contained 21,179 segments, but that does
not bound this generic emitter. Non-tail ordinary calls and closures can add
continuations that worker planning had removed. Conversely the direct entry's
reachable source excludes the mature C-emission path. Literal constructor
chains stay within a segment through evaluated-value binding, rather than
creating a continuation for every character. The actual lowered metadata must
pass the runtime capacity gate (at most 65,532 program segments and 255 live
input/output words) before full QBE acquisition. No speed or capacity conclusion
is inferred from source size alone.

The root-run `full-api04/report.json` now records successful checking of seven
API exports from `full-source04` in 7.775 seconds. All six lowerer module hashes
in that frozen source manifest match the current source, including the matcher
and bang corrections above. This establishes the composed Bend source gate;
it does not establish generated-program semantics or self-hosting.

The root-run `focused01` exposed two admission defects after that source gate:
unknown custom foreign providers reached emission, and F32 native primitives
whose definitions have an `Absent` body were incorrectly included in the foreign
effect list. The frozen failure remains intact. The correction in
`lower-book.bend` gives `nc_native_def` priority before `nc_foreign`, matching
`nc_definition_plain`, and adds `p111_runtime_admission(request)`. The entry calls
this backend admission check before lowering/emission. It accepts only the 15
registered effect names in `runtime/effects/prepared01/catalogue.json` (SHA256
`2bcb481d3d117a92a48a20bd508cbe78cd39aa81b77a1b835967d9b0065db29f`).
Unknown custom foreign providers require an explicit runtime capability extension
and coordinated admission catalogue; they are not emitted speculatively.

This capability-name check is not independent validation of arbitrary user-made
foreign types. The qualified pipeline pins the actual Base and compiler host
asset definitions that supply the registered provider signatures. Public compiler
installation/version binding must preserve that trust boundary; a replacement
Base path alone cannot establish the builtin representation or provider contract.
