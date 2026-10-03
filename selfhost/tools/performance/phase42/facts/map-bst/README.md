# Next domain: guarded Map string-comparison component

The Phase41 portable bundle retains real Map churn at 32/128 and BST at 32/64;
these are distinct families. The earlier Phase37 gaps (Map ~91–106×, BST
~152–209×) motivate a probe but are **not fresh Phase41 ratios** and do not imply
aggregate parity. No target or compiler execution was performed for this screen.

The concrete first probe is a saturated `String.cmp` edge inside crit-bit Map.
The original source comparison recursively compares Unicode scalar heads and
returns the complete `((left,right),Cmp)` value, rebuilding both strings. Eight
saved callsites in `Map.set.fin`, `Map.pop.go` and `Map.pop` can replace repeated
matcher/call/Char comparison dispatch with the already emitted runtime's native
`String.cmp` worker. Public G descriptors remain unchanged. No Map node, alias,
key order, value, or tuple representation is replaced.

Preparation reads the exact portable candidate archive and verifies the saved
module identity `4920a1662f2050c802d69417e032d19905b97160fa7eb5743b2333dbcb16d1e4`
(122,329 bytes). It preserves a baseline and emits a separate manual-JS ablation.
It captures the runtime's native comparison descriptor immediately before the
source override, rewrites eight exact simple-variable callsites, and appends
diagnostic exports. This is not checked Bend emission or source admission.

The private worker handles plain strings only and preserves the full pair/tag.
It refuses entry while any existing region proof is open. Guards cover the exact
five source dependency descriptors (`String.cmp`, `.fin`, `.rec`, `Char.cmp`,
`U32.cmp`) plus postinitialization String global/prototype/static/method
descriptors; numeric/array/protocol guards run first with captured intrinsics.
Changed codePointAt, slice or fromCodePoint must run the original generic path.
Do not claim this guard closes preimport host mutation or arbitrary realm
ownership. Those remain production-admission blockers; the saved-JS test uses
clean initialization and is a cheap mechanism falsifier.

```sh
python3 selfhost/tools/performance/phase42/facts/map-bst/prepare.py \
  selfhost/tools/performance/phase41/current/manifest.json NEW_ABLATION
node --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase42/facts/map-bst/controls.mjs NEW_ABLATION NEW_CONTROLS
```

Root owns resource-supervised execution. `ablation01` is already prepared; use
new paths for retries. Controls demand clean-path entries and compare complete
comparison operands/tag or exact errors for empty, prefix, combining, astral,
U+E000 and lone-surrogate cases. They compare **all ordered Map key/value entries**
after fill/update/remove against an independently constructed ordinary JS map,
not merely the portable wrapping digest. Host/dependency mutations require zero
fast entries and complete generic agreement. Further production controls must
cover String global/accessor/prototype replacement, marker getters, preimport
mutations, throws/reentry and unrelated scalar/ADT mixed books; this screen does
not remove those obligations.

If complete-value controls fail, retain the failure and reject this worker. If
they pass, the next cheap test is alternating saved baseline/candidate `bench`
calls at the two portable points with original digest plus full-content checks
outside timed regions. Guard cost may outweigh comparison dispatch on short
keys. Use a separate longer-common-prefix control to distinguish the mechanism;
do not tune the original portable fixture or report that as its result. No
timing gain is currently claimed.

## Source feasibility and ranking

1. **Map comparison edge:** medium plausible payoff, high admission risk, cheap
   20-second value screen before timing. Source support needs exact owned native
   String/Char and nondependent two-field Sigma facts, explicit Unicode demand
   points and new host ownership checks. Consume reusable exact closed-graph
   facts; specialize known saturated calls while keeping tagged/tuple results.
   The original recursion also crosses `String.cmp.fin -> String.cmp`, so
   `j_component_closed` rejects its helper backedge and `j_direct_visit` refuses
   its cycle. Type admission alone cannot promote this worker. General source
   support needs bounded helper contification/SCC handling, or a separate proof
   of exact native/source equivalence. A name-specific runtime substitution is
   only this saved-JS experiment.
2. **BST zipper:** high remaining gap but broader proof work. `bst.down/step/up`
   pass `BST & List<BFrame>`; native Sigma and List of user records fall outside
   current JPure coverage. BST has no String boundary, but tuple/List-BFrame
   closure and demand must be proved before reusing direct-call workers. Avoid
   a handwritten whole-BST replacement or tuple elimination as a first probe.
3. **Full Map representation / native JS Map:** highest semantic exposure and
   weakest cheap transfer. Crit-bit ordering, alias/affine transfer, right-biased
   union and returned original keys are observable. Defer representation change
   until a narrow edge survives.

The Phase38 [MLton ordering lesson](../../../../../../design/phase38/research/mlton.md)
and [Flambda known-call distinction](../../../../../../design/phase38/research/ocaml-flambda.md)
support known saturated edges before representation work. They supply no Bend
speedup estimate. The installed Phase41 String admission refusal and
[executed host counterexample](../../../../../build/phase41/lexer-string-host-counterexample01/report.json)
already demonstrate that numeric/scalar guards remain true while String hooks
run callbacks. That negative evidence is reused here; a blanket String purity
bit remains rejected. A complete source proposal is a dedicated later phase,
not part of the pending Phase42 cache promotion.

The follow-up [source SCC feasibility analysis](source-scc-feasibility.md)
records exact split/rebuild counts, descriptor capture order and midcall mutation
counterexamples. Preserving String intrinsic calls alone does not preserve the
dispatch/force hooks around them. A credible source successor requires observer
barriers and captured exact-state generic resume, with explicit limitations for
stack-sensitive callbacks; it is not an entry-guarded direct project/ctor loop.

The [BST closed private data screen](bst-closed-data-feasibility.md) identifies
an independent, host-free next mechanism: bounded exact Sigma/List-of-closed-ADT
proof inside a scalar-root graph, reusing current single-self workers. It records
all source edges and explains why type admission alone is insufficient and why
inorder remains rejected. `bst-plan-probe.mjs` is ready for root's observation-only
compiler API run; no proof predicates are overridden.

A [held sequential structural continuation proposal](sequential-feasibility.md)
uses existing types and unary frames for the dependent inorder recursion shape.
It cannot enter the unchanged BST scalar root while its zipper's Sigma/List
proof fails, so its 63-line candidate02 patch is review-only pending activation
and headroom evidence. It is not claimed as a BST benchmark improvement.

[Matched-set design](bst-matched-set-design.md) now incorporates root's actual
checked07 probe02: inorder pure graph valid/prefix refused; whole BST scalar
root proof refused; Sigma/List-frame type refusal; mismatched Sigma name-only
equality hazard; and an additional build computed-alias prefix refusal. The
strict owned mode/type-equality/emitter estimate is 320–520 LOC, not a whitelist.
[Probe summary](bst-probe02-summary.json) hashes the unchanged root report.

[Independent minimal-domain review](bst-minimal-domain-review.md) supersedes the
initial recommendation to thread a new owned proof/cache mode. The existing
scalar-root/fullgraph ownership boundary appears sufficient for a globally
valid exact closed Sigma/List source proof; public ownership remains unchanged.
Estimated matched set falls to 250–360 LOC. This is conditional review, pending
new-predicate negatives, actual private entry and complete-value evidence.

## Executed Map falsifier: hold native String work

Root completed `selfhost/build/phase42/map-native-controls01` and the independent
three-rotation short screen `map-native-screen01`. The eight saved-JS edge
replacements passed 12 complete Unicode tuple/error comparisons, five complete
ordered Map-content cases, three host-hook fallbacks and five dependency-code
fallbacks. Clean native entries numbered277; fallback entries8; each mutation
control required zero native entries. This is saved-JS evidence, not compiler
admission. [Read-only result summary](map-native-result01.json) hashes all raw
reports and both modules.

| Case | Original ms | Ablation ms | Pinned TS ms |
| --- | ---: | ---: | ---: |
| Map32 | 12.3191 | 12.2529 | 0.141275 |
| Map128 | 65.6190 | 63.6162 | 0.786770 |

The short-screen median reduction is only0.54%/3.05%, with substantial remaining
gaps. This falsifies String-comparison replacement as the proposed high-payoff
Map mechanism in these cases; native String production work is not justified.
No String purity admission, SCC lowering or broad native comparison work follows
from this experiment. Retain the prior String host counterexample and the
source-SCC feasibility analysis as negative boundary evidence. No aggregate
parity is claimed.

Exact baseline/candidate module hashes are
`b4009e7c90359808ec9bace8debc89f526a0d3ad1fa30c01c0b27103cb4123da` /
`064a1919ff2c0907bdfe8976ace47738f3bd0f511adf0d5e87ac2da0bcd1458c`.
The control report hash is
`6cfe1a3d0bf40a7064182009fddc3d95103bbd2ccaa7e2a769cf66405afab022`.

[Strict checked10 proof controls](native-proof-controls10-summary.json) now pass
all43 assertions, with exact six input identities and five separate activation
observations. The new native domain and bounded equality work; original bench
still lacks a full proof, so runtime entry/gain is unproved. Exact isolated
matched-set source delta is220 net lines/28 functions. This is not the complete
compiler cost, which must be measured on the final image.

## Executed matched-set stop

The [returning host callback assessment](returning-host-callback-assessment.md)
records the executed checked07/checked11 BigInt reentry and mutation falsifier.
That preimport case is outside the published initialization contract; the
earlier blanket reversal recommendation is superseded.
Static type controls passed43 assertions, but unsupported preimport callback ownership and dynamic
G.code parity failed; no BST runtime gain is claimed. Nat.add candidate02
remains isolated pending supported controls.

Contract clarification: docs/BEND-IN-BEND-PERFORMANCE.md405–416 already
assumes standard intrinsics at module initialization. The retained preimport
BigInt witness deliberately violates that assumption; the earlier blanket
stop is superseded and no rollback is required solely on it. Nat.add
candidate02 resumes narrow metadata review, with original runtime arithmetic
and calls unchanged. Bounds and supported postimport mutation/Error-reentry
controls remain required; arbitrary preimport observer support is not added.
