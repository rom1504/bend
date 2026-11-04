# Phase156 independent semantic review

Read-only source/evidence review, 2026-11-02. No targets, production edits or
new performance measurements. Reviewed the isolated
[publication candidate](../../selfhost/tests/phase156/publication.bend), its
[invariant argument](publication-invariant.md), the
[use-summary override](../../selfhost/tests/phase156/uses.bend), current canonical
checker/index/lowering helpers and `controls02` receipts.

Reviewed source SHA256: publication
`5ae6a0288a00d4b04758ceaf4f86ddc4a6264adc52a92662bb3597cbb217f60c`, uses
`692c962d7901de3af98525a996c6cae4d1c3e8672cf3feec121591ee918337e0`, request harness
`a38be817481b336801a7c03b3e4fb701966f13946bc63d58b8dab1633d9249e1`.

**No semantic defect was found in either change within the stated admitted,
finite compiler-source domain.** This is a source review and finite-test account,
not a formal proof, completed campaign gate or promotion decision. The following
scope and evidence corrections should remain explicit.

## Publication invariant and hidden mutations

The candidate starts its private dirty bit at True in both entry initializers.
It can establish False only after an ordinary insertion into an empty book or
the same canonicalize-and-`book_put` operation that the original logged loop
already performs. A childless logged insertion sets True. When another event of
the same name follows, both loops skip publication and retain the actual checked
world. Successful publication obtains `rw(result)`, not the pre-check world.

For established clean worlds, skipping `p143cp_canon` is valid provided:

1. The raw tail has the canonical unique-name order and its leading BookCache
   is coherent with its visible declarations.
2. All reachable checker mutations preserve that property or restore an entry
   world that had it.
3. The clean bit remains private to this event loop and cannot be supplied by
   an arbitrary hosted caller as a semantic certificate.

The first premise deserves explicit wording. `book_put` uses
`index_put_rest`: a nonempty-name index miss can skip raw-list removal. Thus
“book_put removes every same-name row” depends on coherent cache/raw-tail lookup;
it is not an unconditional theorem for fabricated stale BookCache objects.
The actual candidate begins conservatively dirty and preserves existing private
admission; no new stale-cache admission was found. `p143cp_canon` preserves the
existing cache/index rather than repairing arbitrary inconsistency.

An independent conservative named-closure census from `check_definition_world`
on exact qualified source `027e1504…` found **435 distinct names / 578 declaration
blocks**: 418 definitions, 143 laws and 17 types. The original invariant's “435
declarations” should be read/corrected as distinct names, not total blocks. The
164,814-byte extracted closure identifies these actual mutation sites:

| Operation | Reason it preserves the established property |
| --- | --- |
| `check_template_open` | Uses ordinary `book_put` to install a temporary binder. |
| `kw_restore_definition` | On successful template checking, restores the book from that check's entry world; preserves the result's memo/fresh/checked data. Failure retains the actual result world. |
| `kw_temporary_fresh` / `kw_bound_book` | Updates the leading bound metadata or preserves the raw book while changing deferred fresh roots. |
| `kw_owner_fresh` | Changes deferred roots, not the book. |
| `sp_live_body` | Ordinary bound update and `book_put` of the declared instance. |
| `sp_live_done` | On success, ordinary `book_put` of the completed instance with unchanged memo/fresh/checked construction; failure returns the original result. |

`kw_with_book` is a direct world constructor. Its reachable callers in this
closure are the temporary insertion and restoration above. No additional direct
KWorld/book mutation site was found. This is a conservative lexical source audit,
not a proof that future source additions preserve the invariant; refresh it when
checker mutation logic changes.

The candidate retains the original event guard, `p143cs_mode`, checking call,
failure translation, checked-output insertion, seen-history `book_put`, schedule,
prepared ordering and fresh/bound arithmetic. It calls the unchanged
`p143cp_result` at the outward boundary, so success and failure both retain the
original final canonicalization. Logging=False uses the original walk directly.
No constructor-membership cache is mixed into this experiment.

## Actual routing and current finite evidence

The selected ordinary planner requires `p143cg_enough(suffix,256)`. Loaded Base
does not count. `controls02` now records:

- Compiler-checker input: **645 suffix definitions, publicationRoute=True**,
  exact complete old/new raw result equality. Its full result graph is retained
  as 72,636,421 bytes, SHA256
  `7eaf3dc615144e5e9b0cbe485b85b6b3b199cb268817d681eb8c826a58360693`.
- Unrelated Map input: **8 suffix definitions, publicationRoute=False**, complete
  result equality. This is a useful unchanged-routing control, not positive
  exposure to the publication optimization.
- Eleven publication fixture rows pass in `controls02`, covering success,
  dirty/clean transitions, template success/failure, law/fill and open laws.
  The real Base preparation and eleven use controls also pass.

The remaining `publication-duplicate-definition` row fails its **harness parse
success assertion**: the parser already reports duplicate declaration `same`.
This is not a disagreement between checker candidates. Classify the parsed
fixture as an expected parser refusal; if checking's own duplicate-event guard
needs direct coverage, provide a separate exact KDef-event control without
claiming the ordinary parser admitted it. Preserve `controls02` as failed until
a new successor report closes that expectation error.

Earlier graph-size observation failure likewise does not turn preceding equality
into a complete successful campaign. The successor full graph now supports the
specific equality claim above. Hosted diagnostic seconds are not a clean native
performance result. Existing source proposals for collision, childful/nonregular
fallback and deferred-fresh controls are not executed evidence merely because
they appear in the specification.

## Use-summary sharing, ordering and empty environments

The override changes only `p113pl_bind_flat`. On a nonempty environment it binds
one `nc_uses(body)` result and passes it to both `p111_keep(value_env,uses)` and
`nc_live_uses(env,uses)`. The original second consumer is
`nc_live_env(env,body)`, whose nonempty case is exactly
`nc_live_uses(env,nc_uses(body))`. Both observe the original body, before the
unchanged bundle substitution. The boxed sibling already shares uses and remains
untouched.

The new empty-environment guard is valid in this domain: `nc_live_env([],value)`
returns [], then `p111_keep([],anything)` and `nc_live_uses([],anything)` both
return []. It avoids a pure unused traversal rather than substituting a different
live set into an observed consumer. The guard uses `env`, not `value_env`: when
the value uses no bindings but the body does, the latter still needs its exact
uses. This distinction is correctly implemented and explicitly controlled.

`nc_live_uses` and `p111_keep` preserve original environment order, duplicate
bindings and ownership-kind decisions. The shared `NU_Set` records membership;
it does not become a use count, sort the environment or change full-width IDs.
`nc_uses_term` still treats Var as a leaf even when malformed finite raw terms
carry children. Params, bundle shape, first lowering, target, fresh IDs, second
lowering, join, errors and call list are unchanged. Existing controls compare all
`P113DCode` fields and include empty/mixed/duplicate environments, maximum IDs,
valid output and ordinary refusal results.

The empty case removes evaluation of `nc_uses(body)`. It should not be advertised
as demand-order equivalence for cyclic/host-forged terms, failing foreign
callbacks or arbitrary resource exhaustion. Those are outside the admitted
finite source boundary and not introduced as supported lanes by this review.

## Native request and promotion obligations

The shared request harness selects publication during planning and uses during
emission, leaving original final verification and streaming output in place.
Its live `p86_prepare` setup is common to all modes. Preserve complete QBE checks
against the actual Phase152 producer before drawing timing conclusions. A shared
image prevents different code-generator generations from confounding source
changes, but does not prove that every workload reaches the changed flat-binding
path; retain an explicit exposure census/counter where a claim needs it.

Require frozen original/candidate declaration identities and unchanged protected
verifier bodies. Independent hosted source checking does not prove native
ownership execution. Continue to exact native outputs and bounded paired
requests; only a useful surviving result warrants a complete compiler image and
fresh integration gates. The current review supplies no whole-build speedup,
upstream ratio, generated-program runtime or compiler correctness theorem.
