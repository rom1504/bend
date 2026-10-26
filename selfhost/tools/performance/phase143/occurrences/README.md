# One exact occurrence summary per fresh-ID check

Append-only prototype against Phase142 indexed-source02
`15f5cada2710119cce19a0cfe961c21f61edc5f0b048f90359090a0c1817dac1`.
No existing declaration, proof, verifier, runtime or selected compiler changes
in the append-only prototype. [The first checked hosted screen](RESULTS.md)
now passes47 controls and72 actual-body constructed queries. It favors the
range version; native/full-output qualification remains separate.

Initial set-only controls remain in `controls-v01.bend`. For the competing
prototypes append `core-v01.bend`, `range-v01.bend`, `controls-v03.bend` and
`range-controls-v01.bend` with the current exact source composer. Do not append
both control versions. Export `p143o_original`, `p143o_summary`, `p143o_range`,
`p143o_in_range`, `p143o_controls` and `p143o_range_controls`.
The main controls contain33 explicitly expected results checked against all
three routes;14 additional cases check direct unsigned interval boundaries.
Version03 adds independent-review cases for specialized KLambda/KLiteral values
and an environment collision after unsigned wrap. Earlier versions remain.
Other dependencies are existing `KTerm`, `NC_Binding`, `NU_Set`, `nc_occurs`,
`nc_uses`, `nc_uses_list`, `nc_uses_has`, `nc_id`, `nc_word`, `nt_choose`,
`p88_string_eq`, `p134v_bool`, and `p114st_row`, plus Base primitives. No new
authority/certificate or cached admission is introduced.

`nd_comb_fresh` normally scans the same body and argument trees for every
proposed variable ID. `no_adapter` and `nbc_select` both request64 IDs.
The latter caps its selected body at32 nodes, but not its argument trees;
the former belongs to the C-style observer adapter, so its mere presence does
not establish that it is a hot direct-QBE caller.
The prototype constructs the existing Patricia `NU_Set` once, then preserves
the exact original candidate sequence and first-match environment lookups.
`Var` remains a leaf even with malformed children; binder IDs on non-Var nodes
do not themselves count. The runtime-native String sentinel behavior stays
unchanged, including a binding whose word literally equals the sentinel.

## Cost and correctness limits

The summary is a persistent U32 Patricia set, with Empty/Leaf/Node constructors;
nodes contain split mask and two children. Its depth is bounded by32 key bits.
Building it can allocate and reconstruct paths, and retains one leaf per
distinct syntactic variable. A subsequent lookup costs a bounded tree walk.
For one fresh ID or an immediate collision, a full summary can cost more than
the original short-circuit scan. This prototype deliberately exposes the pure
summary version; it does not choose an unmeasured production threshold.

For64 all-clear IDs, old body/argument work is up to64 complete passes per
input tree, versus one traversal with insertion plus64 set queries. Environment
lookup cost remains unchanged. This is a local immutable-input capability,
not cross-revision caching. U32 increment and `nc_id(n)=MAX-n` remain exactly
the existing operations, including wraparound. Very large `left` retains the
original termination/performance problem; controls use bounded counts.

The source-equivalence argument assumes finite runtime-valid inputs. It does
not promise identical allocation failure or reclaim timing. There is no theorem
yet. Independent finite review and actual complete QBE comparison are needed.
The20.62% observation is the combined occurrence active-context slice of the
Phase142 cold raw **interior**, not exclusive time in `nd_comb_fresh` and not a
predicted complete-build saving.

## Small actual-input experiment before a full image

Use the simpler [actual-body replay plan](PROXY-PLAN.md) and optional
`subjects-v01.bend` for the immediate experiment. It avoids instrumentation and
clearly labels constructed query schedules. The call-capture option below is
only a later attribution method if actual-body results warrant it, not a
prerequisite or a proposed framework project.

1. Independently check the appended source once and run all30 controls.
2. In a diagnostic checked-API adapter only, intercept actual `nd_comb_fresh`
   invocations while producing frozen Lexer and Map QBE. Retain a bounded
   stratified set of exact `(body,args,env,n,left)` values from real calls:
   clear/colliding, left1/2..8/64, small/large argument graphs. The adapter must
   call the unchanged original and compare complete frozen output afterward.
   A serialized fixture is data, not a host compiler or generated legal plan.
3. Replay both checked exports on every retained tuple, including one freshly
   reconstructed copy to avoid assuming pointer identity. Require exact Bool
   results; record distinct variable count, syntax size and `left`. Charge the
   summary construction every iteration. A whole-request source override is
   justified only after the pure boundary agrees.
4. For a native proxy, copy exact selected source declarations using the bounded
   Phase131 usage-extractor pattern. Represent the captured concrete KTerm/args/
   env values as literal fixture data, not hand-selected synthetic arithmetic.
   Baseline/candidate differ only at one query wrapper. Bound extraction to a
   small dependency closure; stop if it drags in the compiler. Keep both timed
   implementations under the same native producer/runtime and independent
   pre-recorded Bool oracle. Measure arity1 and64 separately, not one favorable
   combined score. Include unrelated constructor-wrapper and closure calls.
5. Only then consider overriding `nd_comb_fresh` in a new source candidate and
   compare complete small QBE/error controls. Root owns all targets and full
   native acquisition. The independent final verifier remains unchanged.

## Competing allocation-free summary

`range-v01.bend` visits the immutable syntax once, directly testing membership
of each Var ID in the queried cyclic interval. It constructs no Patricia set;
this does not promise zero runtime allocation or reference-count operations.
The environment loop remains the original candidate-ID order and exact
first-match `nc_word` lookup. Its Bool may short-circuit earlier by finding a
later candidate's collision first; this has the same result on finite pure
inputs, with different allocation/traversal timing. There are no syntax effects
or emitted diagnostics inside this predicate.

Let `M=2^32`. The original candidate at step `i` is
`M-1-((n+i) mod M)`. For any U32 `id`, the unique inverse step in0..M-1 is
`((M-1-id)-n) mod M`, implemented as `U32.sub(nc_id(id),n)`.
Since `left` ranges0..M-1, a collision occurs exactly when that step is `<left`.
This includes wrapped intervals and excludes every ID at zero count. The public
prototype still returns immediately at zero count before visiting syntax.

This is a mathematical argument about the existing U32 semantics, not an
independently accepted Bend theorem. The14 direct interval controls include
MAX-sized intervals without executing billions of legacy loop iterations.
The30 ordinary controls compare allthree actual predicates at bounded counts,
including1 and64, collisions early/late, wrapping and environment anomalies.
The range route may still lose to the original on an immediate small-arity
collision, but avoids the set construction cost and should be timed as a
separate competing implementation. No production choice has been made.

## Ready observer and isolated override

Root can run the prepared host observer under its shared guard:

```sh
bun selfhost/tools/performance/phase143/occurrences/run-v01.mjs \
  CHECKED_API_REPORT selfhost/build/phase143/occurrences-screen01 \
  selfhost/build/phase130/base-carrier01/receipt.json 20
```

Include `subjects-v01.bend` and export `p143o_subject`, `p86_plan` and
`p88_cache_prepare` as well as the prototype/control exports. The observer
authenticates the API, inputs, common carrier and original `nd_comb_fresh`
declaration before comparing anything. It refuses an API that already overrides
the original routine, avoiding a self-comparison. It checks47 controls, derives
bounded real Lexer/Map bodies, compares allthree predicates on identical and
reconstructed values, then alternates order across1/4/64 query schedules.
Both clear and first/last environment-collision rows remain. Calibration uses
the slowest variant so an early-failure original does not cause an unbounded
candidate run. The20s budget is soft between synchronous API calls; use an outer
guard as well. Incomplete timing rounds are retained and explicitly marked.

`override-v01.bend` is a separately composed production candidate, not part of
that differential API. It retains the exact selected **typed** declaration
signature (the source has no separate `law nd_comb_fresh`) and delegates only
its body to `p143o_range`. Complete frozen-QBE and refusal comparisons must use
the unchanged parent oracle. No target has been run by preparing these files;
only `node --check` validated the observer's JavaScript syntax.
