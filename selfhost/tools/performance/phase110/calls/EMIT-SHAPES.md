`emit-shapes.mjs` transports the exact eight checked facts selected by
`../controls/call-shapes/catalogue.json` into Bend's closed library lowerer.
Its six exports include the labeled synthetic `p110_reverse_via_call` witness,
whose reconstruction is followed by an ordinary call and return. It verifies
the capture binds the frozen source bytes, verifies every recorded input and
product, and never rewrites a checked fact or implements a source algorithm.

Root runs these commands through the campaign's serial CPU3 guard:

```sh
bun selfhost/tools/performance/phase109/capture.mjs \
  selfhost/tools/performance/phase110/controls/call-shapes/source.bend \
  selfhost/build/phase110/capture-call-shapes-FRESH
bun selfhost/tools/performance/phase110/calls/emit-shapes.mjs \
  selfhost/build/phase110/CHECKED_SOURCE/api.mjs \
  selfhost/build/phase110/capture-call-shapes-FRESH \
  selfhost/build/phase110/emit-call-shapes-FRESH runtime-ir-single
```

The API must export `nx110rt_lower_library`, `nx110rt_verify`, `nx110rt_qbe`,
`nx110rt_c`, and `nx_json_function` for runtime policies. Scalar policies use
`nxc_lower_library`, `nxlib_verify`, `nxlib_qbe`, `nxlib_c`; pair policies also
need the corresponding `nx110_*` verifier, emitters and converter. Policies are
the same finite choices as the selected native source. Runtime template
selection belongs to the authenticated API composition, whose file is pinned.

Outputs include QBE/C, the complete library, the unchanged selected facts,
ownership and machine graphs for every definition. Success means positive
emission passed; native execution is separate. Compile `program.ssa` and
`program.c` against one matching runtime object and the prepared
`controls-call-shapes-training01` or `controls-call-shapes-heldout01` harness.
Compare every output line to that harness's exact `expected.jsonl`; retain
alias and zero-live-word checks. The root's compile/run receipts establish
those results, not this transport's `complete` field.

The frozen positive main does not reference dynamic/partial functions, so the
mature request correctly omits their erased facts. The initial combined probe
failure is preserved. Negative probes use a separate source wrapper prepared by
`prepare-refusals.py --out FRESH_SOURCE`: it retains every original declaration
and changes only main to make both negatives reachable. Capture that source with
the normal checked capture tool, then run:

```text
emit-refusals.mjs API PREPARED_SOURCE_DIR CAPTURE_DIR FRESH_OUT runtime-ir-single
```

The refusal transport consumes those actual captured facts with their complete
ordinary-call dependencies. It never fabricates a `KDef` or substitutes a
positive fact. Positive transport reports explicitly leave refusal coverage to
this separate receipt.
