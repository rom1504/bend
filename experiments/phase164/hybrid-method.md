# Mixed direct-first QBE experiment

This is an experimental Bend backend entry, not a selected compiler or a claim
of a faster complete self-build. It accepts the same checked `NR_Request` as
the maintained backend. Host code still transports source, requests and QBE
bytes; lowering, admission, verification and optimization remain Bend code.

## Construction boundary

`selfhost/tests/phase164/hybrid-lower.bend` reuses the current constructor
catalogue, static preparation, raw direct candidates and bounded dependency
admission. It asks whether each ordinary source worker has an admitted boxed
direct implementation **before** constructing that worker's generic body.

The frozen first pilot used an intentionally conservative additional test: ordered
direct verification with an empty scheduler-function identity map. A worker
whose implementation needs a scheduled function identity is therefore retained
generically even when a larger mixed closure could prove it safe. This extra
test cost compiler time and excluded valid closure-producing workers. The next
source snapshot instead discovers proposed omissions from admitted candidate
signatures. Discovery grants no authority: the mandatory mixed-original and
actual-header direct checks still run before optimization. A retained factory
identity can then be used as closure data; the direct checker still refuses
scheduler transitions, and missing identities fail. The old source snapshot
remains the independent conservative comparison.

Eligible owners have at most 32 arguments, one boxed result, a public direct
signature, and are neither native/foreign declarations nor members of the
actual bang-reference set. Arity-positive owners retain their real closure
factory and its actual continuations. Their worker segment becomes a concrete
adapter: read the argument registers, call the verified boxed worker, write one
result to a real stack slot, and return through the scheduler runtime. Arity-zero
owners use that adapter directly. Every other definition retains the existing
generic lowering, including unsupported control, dynamic application and IO.

There are no fictitious original bodies. Skipped bodies create no generic
statements or continuations. Fresh counters advance through the bodies actually
built, so later local identities need not equal baseline identities. Runtime
function tables and static references are generated from this actual program.

## Independent admission and final obligations

`hybrid-adapter.bend` records each omitted source owner, public worker identity
and arity in a dedicated obligation map. `hybrid-verify.bend` checks:

1. The actual original segment and constructor catalogues, including duplicate
   identities and the zero-argument main contract.
2. Every ordinary generic segment with the unchanged generic verifier.
3. Every recorded adapter against its exact fixed statement sequence, source
   declaration, actual original header and final public direct signature.
4. The actual static image with the existing image verifier.

After this mixed original check, `hybrid-entry.bend` invokes the unchanged
ordered direct-body verifier with the actual original function and constructor
identities. Only that success creates a checked optimization boundary. The
existing inlining, scalar, array, borrowing, transport and cold-constructor
pipeline then operates on that real boundary and the original raw candidates.

Before returning a streaming plan, the new entry repeats the original mixed
check and all owner obligations against the final functions. It also runs the
existing borrowed-helper projection checker and array/transport namespace
checks. Thus a later transformation cannot silently remove the sole worker
implementing an omitted generic body. Merely checking whichever functions remain
would not establish that property.

No protected verifier or public maintained entry is overridden. The new route
is `p164h_emit_request` / `p164h_emit_plan`, and failure remains a diagnostic.
The experiment's native entry is separately named and retains the checked
request/cache protocol; session and batch CLI modes are explicitly excluded.

## Generic-to-direct calls and streaming

The two experimental renderer overrides are `p134e_prepare` and
`p134e_private`, in `hybrid-render.bend`. Exact authenticated adapters are
excluded from generic body analysis. Their ordinary-call imports seed the
existing region registry with rank zero, while actual generic workers retain
their normal positive ranks and real worker plans. No fabricated worker plan is
passed to the generic optimizer.

Every imported `p112w_*` symbol is emitted as an actual ordinary-call forwarder
to its final `p113d_*` implementation. Generic regions can therefore call an
omitted owner without degrading automatically to scheduler transport. Their
remaining region analysis, emission and public adapters reuse the existing
streaming machinery. Forwarder machine elimination is a measurement question;
the experiment does not assume it occurs.

The ordinary live-register eligibility scan rejects unknown direct calls in a
generic body. The mixed route instead checks all remaining generic bodies and
all direct bodies, after separately authenticating the exact adapters. The
adapter takes its register snapshots before the ordinary call and performs a
single terminal runtime return. Array, live-register and cold-constructor table
capabilities are still produced by the existing table transforms.

## Integration and evidence

Acquire the five `hybrid-{adapter,lower,verify,entry,render}.bend` modules with
the maintained source and `--allow-overrides` for the two renderer definitions.
The root's guarded acquisition/build tools own all target execution. Useful
exports are `p86_prepare`, `p86_plan`, `p164h_emit_plan`,
`p164h_emit_request`, `p164h_summary`, `p134e_begin` and `p134e_next`.
`p164h_summary` reads an already completed emission; it does not rerun lowering.

Keep optional `hybrid-retained.bend` and its controls out of this base module
list. That separate candidate replaces only the private successful-open
continuation and is described in `retained-original-audit.md`. A wildcard over
the experiment directory would accidentally combine the ablations.

The intended gates are malformed adapter/obligation controls, complete outputs
of an actual mixed fixture, original IO-bearing benchmark sources, generated
runtime speed and then native compiler cold measurements. Timing must include
the full retained optimization, final verification, streaming rendering and
transport teardown. Pure direct-only fixture gains do not establish full
language coverage or the five-second self-build target. Early duplicate
verification, repeated eligibility scans and registry forwarding are costs to
measure, not omit from the reported boundary.
