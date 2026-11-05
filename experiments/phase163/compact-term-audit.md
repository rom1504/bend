# Phase163 compact KTerm: actionable migration audit

Read-only source audit at `a8b598980ef7016133484eb28563b63bd5e30f09`.
No compiler/build/benchmark jobs or production edits were performed.

**First run the direct-first complete-computation experiment; do not immediately
promote fixed-two-field App into the maintained KTerm API.** The census makes an
additive compact family practical, but root's explicit requirement to preserve
the existing structural laws rules out the simple fallback design below.
The strongest bounded maintained alternative is a canonical compact child
container, described under the contract boundary. Keep `KTerm`, `KLambda`
and `KLiteral` and all unusual legacy records valid. Direct child projection and
direct producers belong in this first change; a smart constructor alone does
not remove eagerly built child lists. Do not begin with all term tags or a
conversion at every consumer.

This is feasible at maintained-source scale, but it requires explicit host/cache
and proof-bridge maintenance. A new observational contract with the old law only
on legacy values would be a real scope change; it must not be presented as
preserving the existing universal law. The direct-first experiment can establish
profitability before committing to that migration work.

## Actual source surface

The census covers `selfhost/src/**/*.bend`, including embedded controls,
excluding build products and external historical tests. Counts are lexical
sites, **not dynamic frequency or hotness**. Case-pattern counts stop at the
case colon: constructions in a case's result are not mistaken for patterns.

* 28 direct `KTerm{...}` pattern occurrences, in 27 functions across 8 modules.
  One function matches two terms, hence the extra occurrence.
* 432 explicit generic-record constructions. Of these, 349 are `Absent`, 12
  have dynamic first fields, and none directly constructs an App record.
  Existing generic records also carry compiler facts, markers and malformed
  controls; they must not be replaced indiscriminately.
* Literal-tag factory sites: 7 App (`kt`/`kt_span`), 20 Var and 21 Ref.
  Six App sites are real producers; the seventh is a representation control.
* Public observation already dominates: `kid` has 1,865 lexical call sites in
  103 modules, `ks` 985 in 102, `p98_tag_eq` 1,448 in 97, and `nm` 1,507 in 116.
  `kt`/`kt_span` have 574/90 calls. This is a narrow implementation boundary
  serving a broad consumer surface, not 2,000 required manual rewrites.

Direct pattern owners:

| Module | Functions |
|---|---|
| `core/term.bend` | `tg`, `nm`, `ix`, `qt`, `ks`, `rm`, `kb`, `ke`; `subst_node`, `core_subst_stable`; `k_with_children`, `k_with_span`, `core_literal`, `kl_number`, `kl_text`, `k_quantity_present`, `k_rebuild`, `k_snf_children`, `k_lambda_presence` |
| `core/consuming-strings.bend` | `p98_tag_eq_read` |
| `front/parser.bend` | `f_span_created` |
| `front/elaborate.bend` | `f_pattern_value` |
| `load/prefix.bend` | `f_fresh_prefix_variant` |
| `check/prefix-state.bend` | `prefix_state_variant` |
| `back/native/closed-match.bend` | `p152c_variant` (two patterns) |
| `back/common/constructor-facts.bend` | `p144o_term`, `p144o_owned_term` |

The final two constructor-fact readers intentionally authenticate the **generic
P144Ownership record shape** and have wildcard refusals. They need no acceptance
extension for compact semantic terms. Preserve those refusals. Conversely,
`p152c_variant` must understand like-for-like compact source/prepared bodies;
otherwise the Phase152 constant optimization silently falls back.

## Proposed first representation and producer scope

An illustrative shape, retaining scalar metadata actually used by the parser:

```bend
KApp{+quant: U32, +fun: KTerm, +arg: KTerm, +originBegin: U32, +originEnd: U32}
KVar{+name: String, +id: U32, +quant: U32, +originBegin: U32, +originEnd: U32}
KRef{+name: String, +id: U32, +quant: U32, +originBegin: U32, +originEnd: U32}
```

KApp represents exactly semantic tag App, empty name, id 0, removed=[], and
exactly two children. Compact leaves represent their named tag with empty
children/removed; retain name/id/quantity/spans. Other shapes remain KTerm.
Do not assume Var/Ref quantities are 0: frontend syntax uses 1/2, offload Ref
uses 3, and a Ref can retain a nonzero syntax ID. `core/term.bend:473` also
interprets Var with children; `check/kernel.bend:930` and
`check/annotate.bend:365` deliberately produce such variable cells. These remain
generic, as does the `var-ignores-children` control in `core/ordered-index.bend`.

Change these App producers to take direct operands, without a temporary list:
`app` and `core_apply_span` (`core/term.bend:253,491`), `f_app` and
`f_app_span` (`front/parser.bend:302,779`), `f_scope_app_span`
(`front/families.bend:77`), and `j_region_app` (`back/js/region.bend:456`).
Keep the old public `kt`/`kt_span` signatures. They may recognize canonical
shapes, but calls passing `[f,x]` have already allocated that list eagerly.
Changing only those factories would reduce retention while missing much of
the intended allocation saving.

For compact App, `kid` must directly choose fun/arg and return the ordinary
Absent result for any index greater than 1. It must not call `ks`.
`ks` remains the compatibility view `[fun,arg]`, which allocates when used;
generic traversal consumers can migrate later if counters justify it.
`subst_node` should recurse directly into both operands and call the existing
`core_apply_span`; this avoids a list walk/rebuild on an important whole operation.
`k_with_span` and span propagation should rebuild compact fields directly.

Preserve the real quantity asymmetry: parser App uses quantity 1, core App uses
0. `core_subst_stable` currently admits App only when name/id/quantity/removed
are canonical, children have arity 2, both are stable, and the function is not
Lam (`core/term.bend:513–558`). Quantity-1 App must still return false: ordinary
substitution calls `core_rebuild`, which canonicalizes quantity to 0 even when
no beta reduction occurs. A compact branch that merely checks its children
would change behavior.

## Contract boundary: direct children versus arbitrary updates

The existing frozen representation laws are stronger than scalar observational
equivalence. `selfhost/proofs/compiler-laws/representation/laws.bend` proves:

* `k_with_children(t,ks(t)) == t` structurally, for every KTerm value;
* replacing children twice equals the last replacement, for arbitrary lists;
* rebuild put-back, update/rebuild agreement, metadata preservation, and span
  laws.

For a compact App `t`, suppose `k_with_children(t,[])` falls back to generic
KTerm while generic rebuilds retain their variant. Replacing its children
again with `ks(t)` now yields generic KTerm, whereas directly replacing t with
`ks(t)` yields compact App. **The overwrite law is false**, although public
field observations agree. Globally canonicalizing generic KTerm on updates
instead breaks put-back for explicit legacy inputs. The same issue applies
to compact childless leaves when arbitrary children are supplied.

A viable stronger design keeps a canonical compact child container:

```bend
type KChildren is Data:
  KZero{}
  KOne{+a: KTerm}
  KTwo{+a: KTerm, +b: KTerm}
  KMany{+a: KTerm, +b: KTerm, +c: KTerm, +rest: List<&2,KTerm>}
```

`KMany` has at least three children by construction; the variants have disjoint
lengths. No erased arity proof or general dependent representation framework is
needed. A KApp storing quantity, KChildren and two spans can represent arbitrary
replacement lists without changing its outer variant. Canonical from-list/to-list
round trips can support the original structural identity/overwrite laws, using
new explicit helper lemmas and cases. Direct `kid` matches KChildren and avoids
the compatibility list. Its canonical binary App uses two objects/eight requested
C words, versus the old three/fifteen; it is weaker than the one/six fixed-field
design but still removes real representation work. A compact Var/Ref preserving
arbitrary child updates similarly needs a children field; its empty child variant
is immediate. This is the largest plausible migration that preserves the stated
law meanings, not a completed proof or a claim that the host ABI needs no changes.

Therefore preserve the exact old operations on explicit legacy records and
state the new representation contract explicitly. For the experimental compact
domain, use a semantic/metadata projection bridge and valid-shape update laws;
do not cite old all-values structural proofs as covering it. Add the concrete
empty-list→two-children counterexample to controls. If universal structural lens
laws are a fixed requirement for the extended datatype, the lower-risk fallback
is a typed variant that retains its arbitrary child list. That preserves the
update shape but sacrifices direct-child allocation savings; it is a different,
smaller experiment.

The source-bound law tooling intentionally refuses changed reference KTerm/tg
outside its representation package (`selfhost/tools/laws/prepare.py:55` and
`bindings.py:54`). A new bridge/specification review is required, as the tool's
comment says. No protected manifest declaration among the inspected KTerm/core
helper names was found, but that does not make the old proof package applicable
to a different datatype. Keep the independent emitted-IR verifier unchanged.

## Compatibility boundaries to handle once

1. **Exact snapshots.** `f_fresh_prefix_variant` and `prefix_state_variant`
   currently distinguish generic/Lambda/literal representation. Allocate new
   variant codes if snapshots continue to mean exact physical representation.
   Treating new compact nodes as generic code 0 instead changes that contract;
   it needs an explicit canonical-observation decision, especially when old Base
   carriers and fresh parsed terms meet. Never weaken freshness/admission merely
   to accept a mixed cache.
2. **Prepared-body correspondence.** Extend `p152c_variant` for equal compact
   variants only; retain the original per-field/child checks and authenticated
   NStatic exception. Compact-vs-generic correspondence can be a separate
   observation bridge if needed, rather than broadening it accidentally.
3. **Host ABI and spans.** `selfhost/tools/typed-driver.mjs:240–260` accepts term
   ABI1 and lists only KTerm/KLambda/KLiteral fields. Its span validators at
   276/296 explicitly enumerate those tags. A compact output otherwise either
   fails marshaling or escapes the intended span check. Update/version the
   adapter or project once at the external boundary; retaining helper names
   alone is not public compatibility.
4. **Base wire formats.** `base-cache-graph.mjs:8` uses exact constructor-specific
   rows. `host/prepared-base.bend:244` decodes row2 directly as legacy KTerm.
   Keep old row meanings and decoder refusals unchanged initially. Old prepared
   Base can remain generic while new source is compact, provided snapshot checks
   and cache bindings still pass. Export compact values through an explicit
   canonical wire projection or new version; do not reinterpret old row numbers.
5. **Explicit legacy records.** Preserve noncanonical names/ids/quantities,
   removed names, malformed child counts and source spans. `kt` and explicit
   KTerm can still represent unknown compiler tags and future forms. Scalar
   observations and diagnostics must agree for both representations.

## Small-to-large implementation and admission

For a fixed-field research variant, implement the three additive constructors
and the centralized observations, direct `kid`, metadata rebuilds and six direct
App producers together. For a maintained migration preserving the current
universal laws, substitute the canonical child-container design above. Keep
compatibility fallbacks local; no whole-tree convert-to-compact/convert-back pass
between parser, checker and backend. This is the largest bounded first change
supported by the census after its contract/ABI gate. App alone is the smallest useful first slice if an
early semantic issue blocks leaves. All/Typ/Qua/Lambda and backend-private tags
can wait until actual constructor counts justify them.

First require complete observer agreement for canonical and adversarial legacy
records: all fields, children order, high IDs/quantities, removed names, missing
and extra children, spans, literal payload and Lambda quantity presence. Include
substitution/beta/stability, snapshot/reuse and prepared-body correspondence;
an `@unsafe` body type error must still fail normally. The structural-law
counterexample must be classified explicitly, not hidden by a hash that drops
variant information without stating its scope.

Then run one actual complete parser/checker request with exact semantic graph
and diagnostic controls, followed by small complete QBE requests through the
unchanged optimizer and final verifier. Ordinary program QBE can remain exact
because compiler-internal term representation is not part of those programs'
source ADTs. The compiler's own changed source necessarily changes generated
constructor IDs/functions; old full-self QBE identity is not the acceptance gate.
A later candidate-generation reproduction gate compares like candidate sources.

The direct five-field App requests one six-word node in the C representation,
versus the old nine-word record plus two three-word child cells: 1 object/6 words
versus 3/15, given existing operands and no compatibility-list materialization.
Five-field Var/Ref similarly use 6 versus 9 requested words. These are local
source/C allocation expectations, not QBE instruction counts or speed forecasts.
The QBE backend still has to admit useful direct/borrowed projections for new
variants; inspect actual generated `kid`, `qt`, `ix`, `p98_tag_eq_read` and App
producer bodies. A wider constructor match can lose an existing worker path,
and repeated `ks` materialization can consume the theoretical saving.

The first measured success must reduce work in the **complete operation**, with
legacy transfer and cleanup charged. Stop or revise if it merely exchanges
stored child lists for repeated synthesized lists, breaks span/cache/proof
contracts, or only helps a synthetic constructor loop. A successful App/leaf
transfer would justify extending typed direct fields to All and other measured
hot fixed-arity nodes; it would not yet explain the entire self-compilation gap.
