# Dense facts: actual-owner transfer preflight

**Do not port the complete scalar optimizer on the synthetic speedup alone.**
The bounded audit found a semantic and ownership boundary, not a demonstrated
compiler transfer. There is no dense optimizer candidate or timing from this
lane. Production and every existing verifier/admission path remain unchanged.

The source artifact is a small eligibility probe,
[`dense-eligibility.bend`](../../../selfhost/tests/phase156/dense-eligibility.bend),
which root can add to the checked Phase154 API closure. It implements no compiler
transformation. Its own source checking and target execution remain pending.

## Actual retained evidence

`static-audit.json` authenticates all nine admitted Phase154 QBE products against
their retained hashes, then counts surviving conditional branches without
executing a target. Seven contain branches. The branchless outputs are
`p111_empty` (31 QBE lines) and `p37.map.key` (39). The four substantial compiler
verifier owners have 4, 8, 9 and21 conditional branches. These are output-shape
observations, not proof of eligibility of their earlier P154 bodies. In
particular, a source-level branch can disappear during scalar optimization.

No benchmark-name admission is proposed. An eventual restricted implementation
would use the same structural gate for every function, and fall back on the
whole function if it encounters an unsupported form. A large timing win on the
two tiny helpers would not justify applying it to the other seven owners.

## Why the Phase155 representation cannot be substituted directly

1. **The old state remains observable during an update.** In
   `p154k_scalar`, the same persistent facts feed `p154l_base_scalar` and the
   subsequent `p154l_scalar_done`/`p154l_record`. Relation and predicate updates
   read pre-statement versions after the new ordinary fact has been computed.
   In-place Array writes would change that pre-state. The candidate needs a
   snapshot of all required old fields, or an explicitly separate state version,
   before the first mutation. A late read from an aliased array is not a snapshot.
2. **Branches require independent state.** Unknown scalar/body conditions fork
   the facts and apply different assumptions. Continuing arms intersect facts;
   terminal arms select the continuing state. Ordinary versions restart at one
   on a real join and relation/predicate provenance is discarded. A dense port
   must pay cloning or another valid snapshot scheme and the complete join scan.
3. **An identity is not a dense offset.** `P154Binder` supports every U32 ID and
   `P154Named` contains exact synthetic spellings. A zero-based array cannot use
   arbitrary IDs, truncate them, or merge a named spelling with a binder. A
   compact dictionary or a checked numeric-range layout must be built and paid
   for. Full-width misses and named identity collisions remain correctness cases.
4. **Array ownership changes the interface.** `P154Facts`, `P154KScalar` and
   `P154KBody` are persistent Data with shared fields. Arrays are affine Type
   values. Putting array handles into shared result wrappers recreates the
   Phase148 unsafe-sharing failure. A genuine port must thread raw storage and
   consume returned wrappers once. It cannot retain every existing `+facts`
   alias and replace only `get`/`put`.

The existing Phase154 scalar module is548 lines. Copying it mechanically and
changing the map representation does not solve these four obligations. Cloning
the whole dense table on every `put` could restore persistent semantics, but it
does not preserve the work-removal mechanism measured by Phase155. It needs its
own complete-lifetime measurement, not a projected6× gain.

## Optional cheap eligibility gate

Export `p156d_eligibility(P154DFunction) -> String` from the same fresh checked
closure as `p154d_candidate`. It scans the **fresh original P154 producer body**,
before scalar optimization. The returned fields are:

```text
flags:statements:branches:comparisons:binderOccurrences:namedOccurrences:maxNumericSpan
```

Flags are ORed:1 any scalar/direct conditional,2 a predicate-producing comparison,
4 a numeric binder outside the last4096 U32 identities,8 the original scalar
cutoff of4096 statements. The numeric range is a proposed bounded layout test,
not a change to supported P154 identities; failing it requires whole-function
fallback. Counts use the existing saturating `p113i_add`. Named occurrences are
not unique-name counts and do not measure dictionary cost. The probe does not
build a dictionary, allocate fact buffers or claim measured dense coverage.

A zero flag only establishes shape eligibility for a possible straight-line,
no-provenance subset. It does not establish speed, source correctness or full
optimizer parity. Any future candidate must retain exact named identities,
snapshot source facts before destination mutation, preserve the scalar cutoff
and produce the original complete optimized function and final QBE text.

## Integration recipe if root chooses to run this preflight

1. Preserve the Phase154 canonical source, producer, capture, controls and API
   receipts. Add this probe as an additive module in a **fresh** source closure;
   add `p156d_eligibility` to explicit roots/exports. Do not alter the old files.
2. Reuse the authenticated Phase154 captured input graph and original ordered
   verifier contexts. Call `p154d_candidate(book,name)` for every one of the20
   retained owners, preserve original producer refusals, and apply the probe to
   every successfully produced function. Record actual eligibility per owner.
   Do not manufacture the timed producer input from an optimized output.
3. Keep the original admission/complete-QBE gate independent. The nine previous
   accepted products must remain exact if a transformation is later attempted.
   Do not call old API outputs new source qualification.
4. If only tiny owners survive, stop without a native candidate acquisition.
   If a material owner survives, scope one dense implementation to that structural
   subset. Include schema construction, scalar pre-state capture, result copying,
   final verification/rendering, destruction and fallback decisions in the same
   whole-child clock. An eventual branch extension must also charge independent
   branch snapshots and joins; branch-free timing cannot stand in for that cost.

This preflight deliberately avoids a speculative550-line fork. The synthetic
storage result supports asking whether direct indexing transfers; it does not
establish that the compiler's persistent fact lifetime can be discarded.
