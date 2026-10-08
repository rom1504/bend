# A proof pilot for native lowering

`immediate-let.bend` states continuation contraction for the first Phase67
native candidate, `selfhost/src/back/native/bridge.bend::nc_let`. It is a semantic
model of that rule, **not a proof of the production emitter or whole compiler**.
Its validation status is recorded in `implementation/phase67/proof.md`.

In its sequential path the original emitter saves the ordered live environment in a continuation,
evaluates a `Var` or `NWord`, returns its already available word, and enters the
continuation with that word appended to the held slots. The proposed candidate emits
`Term v_id = word;` then the same body, retaining the same sharing and dead-value
accounting. It does not remove continuation boundaries for arbitrary calls. The nonsequential
path uses a runtime task rather than a stack frame and is outside this model.

The production claim is deliberately the `NWord` transport slice. An already
evaluated word could also originate from a variable, but this theorem does not
prove variable lookup, reference sharing or ownership.

The proof file has no imports, unsafe definitions, foreign declarations,
postulates, primitive arithmetic, or assumed lemmas. Its word type `W` is an
arbitrary `Data`; result type `R` and body are arbitrary. `np_contract` states
one transport contraction. `np_sequence_contract` uses structural induction for
the same result for an arbitrarily long sequence of immediate bindings,
including their ordering. A result type can encode a trace as well as a value;
this does not model real effects in the C runtime.

Production correspondence:

| Proof object | Production operation |
| --- | --- |
| `NP_Words` | Ordered held bindings from `nc_live_env(env, body)` |
| `NP_Saved{held,value}` | `nc_cut` frame slots plus returned immediate word |
| `np_append` | Held bindings followed by `nc_binding(id)` |
| `np_resume` | Frame return and entry to generated continuation segment |
| `np_local` | New local binding followed by the same lowered body |
| Sequence theorem | Composition of consecutive eligible immediate lets |

The correspondence above is reviewed source reasoning and tested executable
behavior. It is **not mechanically proved**. In particular the pilot does not
prove `nc_occurs`, variable lookup, generated C, reference-counting, memory
allocation/failure, scheduling, runtime cancellation and error polling, C local
name freshness, exceptions, FFI, or arbitrary expression evaluation. The
model assumes the same held slots and already evaluated word, with the same
external ownership actions; it cannot justify changing those actions or
reordering effectful work. Native differential and ownership controls remain
required before promotion.

Bend typechecking alone is preliminary. Independent validation elaborates this
file to BendTT and runs the exact pinned kernel from `bend2/bendtt.lean`. The
upstream launcher requests Lean 4.34.0; the first bounded bootstrap experiment
uses available Lean 4.32.0 on the **unmodified** source and records that version
explicitly. The source typecheck and elaboration passed. Independent validation is blocked:
Lean 4.32.0 does not provide `ite_eq_left` required by the unmodified 4.34.0
kernel. No kernel patch or assumed success was substituted. See the phase report
for exact outcomes and resource-bounded replay commands.

`reject-unequal-labels.bendtt` is a deliberately false equality. The same
independent kernel must reject it with nonzero exit; it is a negative control,
not part of the proof.
