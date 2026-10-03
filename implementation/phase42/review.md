# Phase42 independent review

Status: prospective/static review only. No compiler, benchmark or semantic jobs
were run by this owner. Root's execution evidence must be linked separately.
Read repository AGENTS, experiments README/latest ledger frontier/STEERING,
checked B1 development rules, Phase41 tree source/independent review and corrected
actual/fixture controls. No distinct latestcode/facts file was found in the active
tree; active `selfhost/src/back/js/tree.bend` supplies code facts.

## First priorities

Whole-component calls must retain the complete typed transitive guard and never
revive a refused entry after getter reentry. Compact frames must capture original
parent values across left/right/join phases and retain stack safety. Private ADT
layout needs an explicit public/generic boundary, fresh constructor and alias
argument. Fusion needs full values, demand/error order and the current direct-
unfused denominator. The [minimum matrix](../../design/phase42/review.md) records
the exact discriminating witnesses.

## Initial concrete static inspection

`calls/derive.mjs` changes only private `$tree` bodies and keeps ordinary globals
and root guards. It adds handwritten warp-leaf/key helpers and separately removes
inner proof conditionals. This is a mechanism ablation, not generic source
admission. Its fixed tree dependency list must cover every bypassed primitive,
combiner and transitive dependency. Removing inner guards requires all private
worker entry paths to come from a root proof covering that closure; a diagnostic
direct worker adapter alone does not establish this invariant.

`frames/derive.mjs` extracts branch-specific right/join code, captures live `xN`
values in scalar frame fields, and switches on the original branch site. It keeps
`$next` vectors and the existing iterative worker. Its prototype only handles
binary sites. Unary phase2/phase3 continuations must remain unchanged/refused.
`ids` subtracts all declared names from all referenced names without lexical
scope analysis. This can serve the exact generated fixture only if generated
binder IDs are globally unique; source admission needs binder identity rather
than a textual approximation. A declaration in one sibling scope must not erase
a free use in another. The native recursive role is a ceiling experiment; its
deep failure cannot be omitted or counted as parity for the iterative survivor.

Concrete owners were sent these priorities and asked to supply frozen proposals.
No approval or production promotion is claimed by static inspection.

## Challenges and corrections

Calls controls initially labeled saved-JS rewrites `checked:true`. Reviewer
challenged this; owner reports correction to `checked:false,parentChecked:true`.
The guard-only role originally had no counter, so parity could not independently
show private refusal. Owner reports adding an actual warp_node worker entry
counter to every role and extending refusal assertions. Root must execute the
corrected concrete controls; these are reported author changes, not run results.

Layout's first marker proposal reads public `_p42` properties in generic
`project`, `fields` and slot helpers. This introduces demand on hostile public
getters even when representation is refused. Owner independently caught it
before execution and proposes bound private WeakSet membership. Reviewer asked
to retain the marker tool as a rejected pretest predecessor, bind membership
without public property demand, and document packed constructor ownership plus
generic fallback routing. Private diagnostic representation escape does not
establish public ABI admission.

Fusion rewrites the exact closed scalar bench root and retains generic/public
workers and proof cleanup. Its handwritten arbitrary-U32 fused helper is an
arithmetic witness only: actual producer values are limited to `seed % 16`.
Reviewer requested this distinction and an ordinary fused `bench(30000,max)`
oracle because the existing deep rows test unchanged producer/stage workers.
Tail-before-head filtering rules out general fusion with observable predicate
effects/errors unless the admitted scalar subset proves total inert operations.

Reviewer tool attempt `node --check review/oracles.mjs` could not launch:
`/bin/bash: line 1: node: command not found` (2026-10-03). A following independent
hash command succeeded; its shell status does not turn the missing syntax check
into a pass. No syntax or semantic pass is claimed for the new helper. Root may
use the campaign's configured Node binary. `rg` was unavailable as well, so this
review used `find`, `grep`, `sed` and direct reads.

Further read confirms calls' corrected metadata and every non-original role's
refusal counters. Layout `prepared02` replaces public marker reads with a bound
private WeakSet and records 40 complete-value / 59 boundary cases in
`controls02.json`; this is an owner-run report, not independent execution. Its
control report lacks consumed producer, derivation and module identities, and
the harness does not verify derivation hashes before import. Reviewer requested
a versioned successor with provenance plus recursive host input (the current
hostile flow case uses count zero). A future source solution must also justify
the new WeakSet/has/add/bind native assumptions at the host boundary.

Fusion owner reports adding ordinary depth30000 calls with actual root entry
counters and an independent renamed Chain fixture. Those statements are pending
root acquisition/execution; unchecked fixture refusals must remain exact. The
proposed source domain explicitly excludes callbacks, String/native hooks,
division and early termination rather than inferring totality from purity.

## Corrected saved-output tools

Calls derive-v1 actually fails nested AST edit overlap. The earlier first-pass
statement that its overlap assertions looked sound was incomplete: nested
discarded fallback guards create overlapping ranges. Owner retained derive-v1;
derive-v2 renders an admitted consequent before descending and therefore never
edits its discarded fallback. Static review finds no analogous overlap in v2.
This correction preserves the same mechanism/domain rather than widening it.
Root reports complete direct-call controls 191 oracle rows / 75 boundaries,
including deep results, and a 2.35–2.46x three-point screen; these are root-run
results, not this reviewer's independent execution or source admission.

Fusion v1 fails at the 30k diagnostic generic filter after 112 oracle rows /
79 boundaries / two admissions. The diagnostic invoked public non-tail filter
outside the original private proof. V2 validates the diagnostic scalar domain,
uses the existing full graph host/local guard and closes proof in `finally`.
Clean original/fused bytes remain unchanged. Static review accepts this as a
diagnostic route correction, provided the original stack failure remains retained;
it does not assert general public filter stack safety.

Layout successor controls now verify all six module hashes from derive.json
before import and again after observations, retain consumed producer identity,
refuse reused output paths, and test recursive host flow plus warp_node. The
old controls-v1/controls02 report remains retained. Successor execution was not
run by this reviewer. Existing regionHostGuard already snapshots WeakSet global,
has/add and Function.call-related assumptions; a source solution must use that
existing boundary consistently for private packed routing.

## Whole-private graph ceiling blocker

New layout `complete-v1.mjs` bundles direct private graph, flat named fields,
BigInt Nat and native recursion under depth12. It is explicitly a manual ceiling,
not isolated layout causation or source/deep-stack admission. Its independent
private flow/warp cases cover mismatched/uneven/shared shapes and fresh zero-flow
roots, with public fallback bodies retained.

Static blocker: the producer inserts `$s0<=12&&` before `$entered`, host guard
and original canonical scalar checks. A noncanonical host count object can now
demand `valueOf`/`Symbol.toPrimitive`; a Symbol count can throw sooner than the
original fallback. Thus the ceiling itself changes hostile entry demand/error
order. Reviewer requested a versioned successor retaining v1, moving the cap
after the existing guarded canonical domain, plus count-coercion/throw/reentry/
Symbol/raw-entry observations. No execution or admission is approved by this
static review pending that correction.

Complete-v2 moves the cap after the exact original host/canonical-U32/local
guards, fixing the coercion blocker by static inspection. Controls-v2 then
reports an unbounded bsort getter reentry causing stack-dependent trace counts;
owner retains that failure and controls-v3 bounds getter reentry once before the
nested call. It adds guarded/private entry counters and preserves exact finite
traces. These are owner/root-reported checkpoints; no independent run occurred.

## Checked source acquisition review

Reviewed `calls/helpers-v2.patch` SHA256
`c86194e887a49242b51b1be7285c9eb7a8eee73ce735ef629b00f519f6d0fd66`
and `frames/context-source.patch` SHA256
`0966c282aeb343774eaf3e81f5aff20589c15c492d2d8082383257fae237c5c4`.
No static semantic blocker found; root may acquire a checked candidate, subject
to runtime and independent fixture gates. This is not source promotion.

The helper plan starts from original typed JPure graph, then bounded active-name
DFS rejects self and transitive backedges. Native helper emission is limited to
the typed Bool.xor signature: the visit rejects other native definitions even
when JPure admits one. The context rewrite requires exact canonical/current
definition identity and exact complete callee-graph subset. It removes the
current owner from the context, so a callee whose closure returns to that owner
cannot erase its boundary. Current-owner self recursion remains under the
existing stack machine. Original definition/body remain the planning witnesses.

Partial, oversaturated and function-valued source calls are independently
excluded by JPure; private rewrite requires the original saturated call spine.
Original result annotations retain shared binder/argument typing. Inline finite
helpers use original left-to-right argument emission once and eager fresh tagged
constructors. No new runtime or public entry weakening is proposed. Guard
lifetime still depends on the original synchronous pure scalar-owned root and
its finally cleanup; hostile/refused public inputs remain generic.

Remaining cost risk: recursively inlining an acyclic graph can expand shared
callee bodies exponentially. Per-body256, graph8192 and depth16 bounds establish
finite analysis, but are not a practical emitted-byte budget. Root was notified
to disclose compiler/request/source costs and consider an expansion budget
before wider admission. Tests and a timing gain cannot prove universal validity.

`review/fixture-renamed.bend` independently supplies a renamed ADT map, U32 key
and pair helper, nested Bool.xor dependency, scalar public checksum, first-class
and partial-reference refusals, unsupported String signature and transitive
wrapper backedge. Its main oracle is 37035 (key(0)=12345, True flip reverses the
pair, score=3*12345). Fixture is unchecked; retain exact acquisition failures.

## Mandatory narrowing, expansion, fusion and constructors

Static reviewed patch identities:

| Proposal | SHA256 |
| --- | --- |
| calls expansion | `452f9748bdfbb02881ca4e62de6697e40a6c9d0fdea2619c5d11e2c2d35044a6` |
| calls annotation types | `c8f9aa4f61ff2e6e496a63a68e5edfde8ecaed124635cd73bce52b532d13d899` |
| fusion source-v1 | `a69d7fa232c87aadc93d3f695debaa8812013415b24a36545995fa1df5d36bd2` |
| owned constructors | `ff425a184f5d5274742a84a882bed805b71068c9f08d256d7a1028c2b10bcd7b` |
| owned helper activation | `9675ab9ad829208d9cf554bab0106a9846e20f2b05664be93d85073ad3c84b9d` |

Annotation-types is mandatory narrowing. The original helper walker could
rewrite source annotation type Apps although the typed graph validated source
values; tree-only checked01 observations did not cover that possibility. The
successor preserves Ann.type exactly and requires Def/positive arity before
rewriting a call. Explicit List/type-alias annotation regression was requested.

Expansion adds shared2048 fuel charged for every source node and every copied
nonprimitive callee at every saturated occurrence, including argument expansion
before callee expansion. Native helper emission is charged and cycles refuse.
Its conservative traversal of annotation types may reject extra shapes, but
does not admit uncharged emitted inline calls. This addresses the previously
reported repeated-callee expansion concern; emitted-byte and request costs
still require root measurement.

Fusion source-v1 replaces only the existing successful guarded root body. The
nested saturated producer/filter/map/fold syntax admits a single private scalar
use; returned/shared/let-bound intermediates and non-U32 root inputs refuse.
Owner proof requires exactly two constructors with U32 head/same-owner tail;
producer recursively uses the actual Nat predecessor, map/filter use the actual
structural tail, filter selector reconstructs True and aliases False, and fold
returns the original accumulator at empty. The scalar whitelist rejects
arbitrary calls, native hooks, early termination and floating/String operations.
Original primitive emission owns U32 wrapping/mod0, and source operand positions
are retained in the fold update. Producer head and next seed use an immutable
binding of the original seed. Number countdown requires exact native U32.to_nat
of a total scalar U32 operand after the unchanged canonical root guard.

No static semantic blocker was found in fusion. Required execution includes
independent Chain full-width/overflow cases, mod0, noncommutative accumulator,
zero count/nonzero initial accumulator, and sharing/returned/native/demand
refusals. This is approval for checked acquisition, not promotion or a proof.

Owned constructors mark only admitted component/helper source bodies and retain
Ctr shape plus original annotations for shared typing. Emission additionally
requires a closed nonnative ADT, exact constructor name/arity and valid pure type.
Runtime ctor's nonnative branch is exactly `{$:k,a}` and has no registration side
effect; the literal preserves tag/array/fresh-root/child-alias behavior. Shared
j_ctor_args retains erased slots and once left-to-right eager field evaluation.
Unary phase3 reconstruction uses the same resume arguments. The final patch
does not alter constructor_mode: deferred tail builds remain unchanged, so
metadata marker forgery cannot turn deferred construction eager. No static
blocker found; fresh/zero-alias/unary/deep/native/deferred execution remains
required. No runtime/production edits or execution jobs were done by reviewer.
