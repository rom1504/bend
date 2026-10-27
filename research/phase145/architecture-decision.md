# Architectural conclusions from the comparative work experiment

This investigation observes the qualified Phase144 final04 compiler. It does
not implement an optimization or replace its selected runtime. The strongest
conclusion is that we should preserve useful semantic products across phases,
then make the complete computations over those products cheap. Replacing QBE,
counting passes, or adding another generic cache is not supported as the first
step by this evidence.

Sources: [same-source execution](same-source-execution.md),
[upstream observations](upstream-findings.md), [source trace](architecture-audit.md),
[native accounting](native-accounting.md), and [independent review](evidence-review.md).

## 1. Representation choice and phase boundaries interact

The real Lexer `slot.go` trace has 88 raw statements, 65 destination occurrences
but only 21 distinct destination names. The selected lowering already knows
numeric local identities, then represents many of them as names. Downstream
schema, flow and rewrite queries repeatedly validate, hash, compare and rebuild
those names. Backend observations on the complete Lexer request count 931,026
`index_find` entries and 3,033,872 actual character comparisons in one string
predicate. These are not exclusively local-variable queries or CPU shares.

The verifier represents local facts using a nine-field generic `KDef`, and
reconstructs rows even when their immutable schema has not changed. Branches
fork flow maps and reconstruct their intersection. A small record alone is not
the solution: Phase144's first compact variant lost direct-worker admission and
gained only 1.9% on its slice; making absence an explicit sum restored useful
workers and reached 11.06%. This is measured local evidence, not a whole-build
gain estimate.

**Architectural inference:** an internal identity should remain an identity
through a complete producer/query/update/consumer region. Immutable schema
belongs separately from changing definite-assignment or capacity state. The
generated ownership and continuation paths are part of this design, not a later
implementation detail. A compact array of boxed generic records can preserve
most of the expense while adding conversion work.

This is a practical application of the [pinned Zig study](../phase133/zig-ir.md):
compact identities, separate payloads and bounded per-function lifetimes. It
does not imply that Zig checks the same language or that its build timings are
an attainable Bend baseline. Our existing compact-symbol experiment changed
text size, whereas this proposal changes the computation before serialization.

## 2. A checked result should be a reusable product

For Lexer, `p114s_open` and later `p113a_verify → p113e_verify` both invoke
`p112s_verify` on the same actual root object. The strict observation finds the
same complete 27,479-object data content before and after both calls. The final
QBE agrees with the original qualified product. This is stronger than counting
two similarly named passes. The fingerprint is a diagnostic, not a reusable
certificate or a proof about all requests.

The source explains the repetition: the original immutable raw/static program
survives optimization, but the later verifier entry accepts a general bundle
and independently reconstructs its validity. Ready/signature and constructor
catalogues are also rebuilt in several contexts. Their repeated invocation
counts alone do not establish identical judgments; only the raw/static check
has this strict same-input witness in the present experiment.

Upstream provides a useful contrasting boundary. Each observed definition body
is checked once and its checked runtime term is retained immediately as `Def.e`.
Its backend retains useful function/layout facts while clearing some temporary
memo tables. It still performs two to five emission/fact-discovery rounds on
these programs. Therefore "one pass" is not the transferable principle;
**produce an appropriate reusable result, with an explicit lifetime and context**
is the stronger one.

A possible narrow interface, not a new universal IR:

```text
accept_raw(raw, runtime_contract)
    -> private AcceptedRaw { immutable raw, checked schema, contract identity }

transform(AcceptedRaw, original_direct_functions)
    -> Candidate { original context, transformed functions, explicit dependencies }

independent_final_check(Candidate)
    -> accepted actual transformed functions, or the original ordered error
```

The accepted context is created by the checker, not by the optimizer asserting
`valid = true`. Raw contents, runtime ABI, constructor layouts, call availability
and any context on which a judgment depends must remain bound to that context.
The final checker still derives the transformed functions' safety facts from
their actual contents. Public arbitrary-input verification remains available.

Within an immutable request, provenance may establish identity without hashing
the whole tree again. Across requests, it needs a different invalidation design;
this proposal does not introduce persistent caching. A small Bend law about
identity-preserving transit could describe part of the contract, but would not
prove compiler correctness or license ignoring a changed dependency.

## 3. Optimize useful work, not a runtime operation counter

Native Lexer performs 16.77 million allocation calls, 16.48 million constructor
takes and 22.36 million requested register-word copies. These look enormous,
but the same compiler source executes substantially faster natively than in
its checked generated-JavaScript form. The JS warm-engine check reduces startup
cost without closing that gap. This rules out simply using the hosted engine
as the obvious faster research compiler on these requests; it does not prove
QBE's machine code is optimal.

A fixed subset of Base decoder owners contributes 4.50 million allocations to
each small request. Exact native stage clocks put all Base preparation near
0.23 seconds; the retained full-build interval is similarly only 0.256 seconds.
Removing this fixed work helps very small requests, but cannot explain a route
from 247 seconds to 50 seconds. Allocation counts are not allocation time,
destruction entries are not recursively visited nodes, and requested register
words are not measured memory bandwidth.

**Architectural inference:** profile complete regions and retain both semantic
work and execution costs. If one verifier judgment becomes cheaper but produces
more generic call/return transport elsewhere, an isolated lookup result will
overstate the benefit. Conversely, a transformation that eliminates a whole
intermediate list/schema and its construction, traversal and destruction may
benefit both user programs and the compiler without changing the runtime ABI.

## 4. The large-build budget is distributed

The latest exact full-stage capture is final03, not final04: 88.45 seconds in
frontend including erasure, 43.44 in admission/static/raw lowering, 56.25 in
initial optimization/first verification, 23.35 in observer/final admission,
and 67.61 in registry/rendering/output. These diagnostic intervals overlap
neither each other nor the additional downstream machine-build clock, but they
cannot be substituted for final04 clean timings.

Their distribution explains why a dramatic cold-build reduction likely needs a
coherent design used across several consumers, rather than one lookup helper.
It also prevents assigning the entire optimizer/verifier budget to the one
duplicate raw check. We have not yet measured that check's exclusive native
cost. The first useful experiment should measure it while testing reuse.

The qualified final04 clean request is 231.682 seconds and downstream machine
construction adds 15.318. With that downstream cost unchanged, a 50-second build
would leave only 34.682 seconds for our compiler: about a **6.68×** compiler
throughput improvement. Even halving its execution gives about 131 seconds
end to end. The current observations identify opportunities, not evidence for
an already-established 5–10× gain.

## Recommended sequence and rejection criteria

1. **One request-local checked context.** Measure and avoid the witnessed repeat
   of raw/static validation in a diagnostic candidate, preserving the actual
   independent transformed-body check. Check changed raw nodes, headers,
   imports, constructor layouts, reordered callees, forged/mixed contexts and
   prior errors. Require exact positive QBE and unchanged rejection behavior.
   Time the full open→transform→final-check computation; do not count a cache
   hit as a gain. This is the cheapest concrete architectural discriminator.
2. **One complete verifier with numeric local identities.** Reuse the real Lexer
   slice and metadata. Include conversion, schema building, flow, joins, errors,
   rendering compatibility and teardown. Inspect generated worker admission
   and runtime operations. Transfer to a range-analysis or registry consumer
   before broadening it. Reject if conversion dominates, admission regresses,
   or gains disappear in complete native requests.
3. **A compact parser boundary.** The additional full-input comparison finds
   upstream loading/parsing in 2.583s versus the retained selected native parser's
   31.175s. The [boundary audit](parser-boundary.md) separates extra lexical,
   contextual, validation/freshening and runtime work. Inspect the current
   complete pipeline before testing one cursor/token or producer-fact fusion.
   Charge source conversion, Unicode/error positions, parsing and cleanup; keep
   complete parsed-graph/error oracles. This is not evidence for changing the
   global String ABI or skipping source validation.
4. **Carry the successful product earlier and later.** Only after these tests
   pays, share the same compact semantic identity/schema across lowering,
   optimization, independent verification and rendering. Investigate preserving
   the frontend's checked runtime product rather than rebuilding it. Preserve
   exact type, erasure, ownership and error-order contracts. Bound per-function
   lifetime where global dependency rules permit.

This sequence can create a useful foundation for incremental checked units,
but its first purpose is to remove cold-request work. It does not reopen an
object-cache campaign, migrate backends, or promise a new compiler in a fixed
number of hours. Small native complete-computation tests should select the
design before another expensive full native qualification.

Defer a universal IR rewrite, a general proof-carrying optimizer framework,
additional runtime counters, and a new full JS/C compiler acquisition. The
present data is sufficient to select these narrower falsifiers. Independent
final checking, exact products and the retained qualified compiler remain the
boundaries of the next experiment.
