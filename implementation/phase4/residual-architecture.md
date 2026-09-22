# Residual generated-code architecture

Read-only review found a concrete remaining difference between B1 and H/private: the upstream emitter creates full typed workers that continue through matches, while the Bend emitter groups only consecutive lambdas. Several central substitution and annotation helpers therefore still construct matchers and partially applied arm functions in the optimized private compiler. This supports a new bounded lowering experiment; it does not establish its runtime importance or a speedup.

The [next lowering design](../../design/phase4/next_compiler_lowering.md) gives the mechanism, demand-order proof obligations, cheapest falsifiers, stop rules and implementation scope. No compiler, runtime, private image, benchmark or completed proof was changed by this review.

## Exact artifacts and observations

The [inventory](evidence/residual-lowering-inventory.json) hashes the actual B1, H, private candidate, emitter, runtime, private calling implementation and upstream compiler. It records 19 helper declarations and their source line numbers. B1 is `0653f21e…`, completed fixed-point H is `b33b38e3…`, and the inspected opt-in private image is `4318bbcd…`, all derived from final source `34c6ef63…`. The private image's separate full gates determine its acceptance; static inspection here supplies no additional full-validation claim.

Three examples explain the difference:

- B1 `subst_node(term,id,value)` destructures KTerm fields inside one three-argument worker. H begins with `matcher1("KTerm",()=>fn(8,...))`: six projected fields partially apply the arm, then `id` and `value` arrive in two subsequent calls. Private ordinary-call specialization leaves that matcher-root entry intact.
- B1 `ka_defs_except(book,defs,stops)` matches the list inside its three-argument worker. H's initial `fn(1)` receives only `book`, returns a list matcher, then consumes `stops` after matching. The private worker removes the ordinary initial dispatch but not the matcher or later staged application.
- B1 `tele_check` takes five parameters; H initially accepts three, matches the argument list and then accepts the final demand. Conversely `wnf`, `check`, `check_node` and `annotate` already have matching B1/H entry arities. Replacing their root calls again would miss the issue.

The frozen H has 1,518 named globals: 386 matcher-root entries and 1,132 ordinary function entries. The inspected private image has 1,123 positional workers. These static counts do not say how often any path runs. Full function bodies, including counterexamples to an overly broad claim, are retained in the inventory.

## Cause in the emitters

In `selfhost/src/back/js/emit.bend`, `j_lambda_count` and `j_call_arity` stop at a match; `j_apply_regular` groups a call only within that prefix. `j_match` constructs runtime matcher values. Runtime `matcher1` projects fields and returns a jump into a newly created arm. An arm with more parameters than constructor fields creates a partial application before receiving the remaining arguments.

In pinned upstream `comp.ts`, `sig_def` derives live parameters from the typed signature, `js_def` declares them together, and `js_func` carries unused parameters through Lam/Mat/Let. A match projects fields and continues the arm body inline with those fields plus the remaining parameters. That is an emitter scheduling/arity decision; it is not recovered by the current private transform's ordinary `G=fn(...)` extraction.

This makes the proposed mechanism different from the zero-site [ordinary uncurrying experiment](../../experiments/phase4/P4-011-ordinary-uncurry.md) and the rejected [Con-arm pilot](private-con-arms.md). The latter fused only already saturated two-field arms and left the partial-arm case above untouched. Its null result still limits confidence in another allocation-only hypothesis.

## Important limits

Saturating across a matcher can evaluate later argument expressions before an earlier match rejects or diverges. Neither typed arity nor pure Bend source proves that transformation safe. The first prototype must accept only already-computed private data values, preserving the old path otherwise. General lowering needs an explicit evaluation schedule. The [design](../../design/phase4/next_compiler_lowering.md) requires malformed field-count, partial/overapplication, early error, captured context, dependent substitution and deep-stack controls before timing.

B1 also allocates trampoline/closure objects. Its stability predicate still calls generated `kc` with closures; H already emits conditional choice directly. H's `build`/`force` machinery evaluates constructor fields using an explicit stack, whereas B1 often nests calls in direct object construction. Removing that machinery without an equivalent continuation strategy risks a stack or demand-order regression. Private field access and exact-application copying have already been optimized, so those savings cannot be counted again.

The completed source proof recorded B1-to-H at 670.766 seconds and H-to-H at 1,591.343 seconds. The separately measured original TypeScript compiler processed the same source/root policy with a 51.443-second median process wall. These are different implementation and measurement paths; the source-proof stages are not paired timing trials. They show why there are two questions: lowering overhead between B1 and H/private, and algorithm/data-structure costs shared by the Bend implementation relative to the handwritten TypeScript compiler. A better JS emitter alone does not establish a solution to both.

No old profile percentage is used as a ceiling. New final-core B1/private profiles are being collected separately as P4-022; this review's structural conclusion does not depend on their eventual timing or sample distribution. Any follow-up must link the actual profiles, distinguish exclusive from inclusive samples, and retain the original rejection evidence for general normalization memoization and narrow matcher fusion.

## P4-022 update: name lookup is a hypothesis, not the profile label

The fresh [residual profiles](residual-profile.md) record 16.58% exclusive B1 samples in three generated string-comparison helpers, plus 2.91% in `String.eq`. Calling the entire share “name lookup” would overstate the evidence: term-tag comparisons use the same functions. Private H's generic `apply` remains 28.16% and `force` 9.65%; those shares likewise do not identify which matcher family is responsible.

Source inspection identifies concrete algorithm paths to distinguish. The existing compressed index hashes the complete name at each `index_lookup`, tests the `Absent` kind string at each trie node and compares exact names in its collision bucket. Uncached `lookup` still scans declarations. `has_name` scans a list and is used independently for annotation stop names and layout seen/stopped names. Numeric `ctx_get` is a list scan too, but does not explain string-comparison samples. The existing compressed trie and rejected eager signature-suffix index are prior work, not newly proposed optimizations.

Pinned Base's `String.eq` calls `String.cmp`, which reconstructs consumed string prefixes to satisfy its returned ownership tuple before `eq.fin` discards them. B1 emits those helpers; private H already has specialized string equality. In contrast, handwritten TypeScript stores definitions/constructors in null-prototype dictionaries and local contexts in a numeric persistent map. These concrete differences motivate separate counters for hashing, trie visits, exact identifier comparisons, list membership and short tags before choosing a representation change. The [design update](../../design/phase4/next_compiler_lowering.md#fresh-profile-update-separate-identifier-work-from-tag-dispatch) specifies the smallest membership/hash/equality falsifiers and their Unicode, persistence, ABI and demand-order limits. No instrumentation or timing was added during this review.
