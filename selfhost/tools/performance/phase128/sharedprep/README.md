# Request-local raw lowering reuse

This is a checked-API prototype, not a production entry replacement. It adds
only new Bend declarations. It never changes `NR_Request`, `P113AProgram`,
certificates, the prepared Base format, existing verifiers or installed images.

The preceding ready-flat filter produced byte-identical Map QBE but only about
1.4% wall /0.5% admitted-entry reduction in the coordinating agent's three-pair
screen. Those measurements do not establish a robust gain. This prototype
instead removes the complete second native preparation/candidate generation
from requests that execute the late flat-observer closure.

## One immutable computation, two consumers

Current initial lowering executes:

```text
p112s_prepare(raw request book)
  -> p113pl_candidates(prepared book, full names, bangs, signatures)
  -> p126sc_candidates(raw candidates)
  -> p113d_passes -> ordinary optimizers -> independent verification
```

The late `p126bp_close` starts again from the same raw request, repeats static
preparation and candidate generation, then passes those raw candidates to
dependency closure with the newly available borrowed/flat workers. It does
**not** apply `p126sc_candidates` in that late pass.

The prototype computes the same raw list once. `P128RawLowering` carries
`{lowered, raw}`; the prepared static book is not retained in that bundle.
Initial lowering still transforms one view of `raw` through the exact SCC
pass, dependency closure, inliner and range optimizer. The late pass consumes
the original raw list. Candidates blocked initially remain available for late
admission. Only storing admitted functions would lose those opportunities;
storing SCC-rewritten candidates would change the late algorithm.

There is no cache key, invalidation protocol, cross-request reuse, serialized
certificate, caller-supplied prepared native book or hidden request metadata.
Both consumers are descendants of the same successful request/source-bound
preparation. The raw request remains unchanged for scalar/unshared derivation,
borrowing, effect permission and cold constructor analysis.

## Exports and composition

Compose `raw-session.bend` and `controls.bend` onto the Phase127
`live-bank-source01/compiler.bend` parent using the existing Phase126 exact
declaration composer with **empty override and module-override sets**.
No protected entry exception is needed.

- `p128raw_compile_prepared(path, source, prepared)` matches the existing
  `p111_compile_prepared` interface and includes ordinary planning/admission.
- `p128raw_emit_request(request)` runs existing runtime admission internally.
- `p128raw_emit_admitted(request, error)` matches `p111_emit_admitted` for
  same-source admitted-entry comparisons. Like that existing internal entry,
  its supplied admission error must come from the ordinary trusted gate.
- `p128raw_controls()` returns eleven finite control rows.

The controls exercise exact error propagation, the independent verifier's
continued refusal, retaining two raw candidates while initial SCC conversion
admits three functions, retaining a candidate blocked on an unavailable helper,
and exact private QBE when the helper becomes available later. Real complete-QBE
comparisons remain mandatory.

## Gates retained

`p128raw_emit_request` calls `p111_runtime_admission`. Initial native preparation
still calls `nc_compile_error_known(source,bound)` before lowering. The initial
`p114s_*` pipeline and original `p113a_verify` are unchanged. Scalar requests
alone execute the existing `p118e_cold`; effect-permitted requests retain their
separate permission check and certificate. Borrowed functions still run through
`p118b_verify_functions`. Final late closure invokes unmodified
`p126bp_complete`, including `p113a_verify_after` and `p114t_verify_done`.
Error prefixes match the existing paths.

The second source-bound check formerly inside `p113pl_inspect_request` is not
repeated: the exact request has already passed the same check, and the reused
candidates are the result of that invocation. The independent final verifier
is still run on the actual merged program.

## Small decisive experiment

Acquire one checked API exporting both existing and new entries; retain this
source unchanged during the comparison. Require the eleven controls and
existing observer/transport controls to pass. Compare complete QBE/error
bytes on Map, records, RLE and unaffected lexer/closures; include effectful and
source-rejection controls. Use identical source, prepared Base and runtime
identities. If any bytes differ, reject before timing.

Then interleave complete prepared-request and admitted-entry timings. Record
peak memory as well as elapsed time. Actual profiling should show one
`p112s_prepare` and one raw candidate enumeration on formerly duplicated
requests. The source structure alone is not a measured inclusive cost result.
No target execution or performance claim is made by this module.

The important risk is lifetime: raw candidates stay alive across initial
optimization and verification, creating sharing/reference-count work and
retaining old bodies longer. An unaffected request could regress despite no
additional analysis. Full-compiler peak memory must be checked before native
qualification. Do not retain the prepared static context in addition to raw
candidates unless separate evidence justifies it.

If measured gains justify integration, replace duplicated pipeline wrappers
with a small explicit request-local context at the existing entry boundary.
That later consolidation must preserve the original verifier gates and prove
native scale independently. This prototype does not justify a global cache or
changing the optimizer's semantic representation.

## Combined observer preparation

`combination.bend` is an optional overlay after the scalar-borrow helper/layout
modules, `borrow/next/single-scan.bend`, `raw-session.bend` and raw controls.
Its only replacement is the experimental `p128raw_prepare`; no original gate
changes. Allow that exact name as a module override when composing together.

The new continuation calls `p128br_scan` once against the original functions,
retains the scan's worker/helper/retry products, applies cold metadata only on
the scalar-permitted route, and retries the same selected plans against those
original functions. Empty patches use `p128raw_integrated`. Nonempty patches
verify added workers, perform late flat closure using retained raw candidates
only when required, call the selected `p128br_apply`, and then invoke unchanged
`p126bp_complete`. Thus later patch-composition improvements can replace
`p128br_apply` without changing this integration. No signatures are preadmitted
to the final verifier. Export `p128raw_br_controls` for four exact error-path
comparisons in addition to the raw and borrowing controls.
