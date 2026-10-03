# Prospective independent unary/shared-frame controls

No execution, correctness or admission result yet. Use the checked baseline,
new checked candidate and pinned TypeScript receipts for tree-linear-order.bend.
Reuse unary-compiled-controls-v4.mjs's AST-only counters/returned-value capture,
full receipt checks, actual phase observations and boundary controls; do not
replace any emitted work or open new proof scopes for ordinary roots.

The expected actual workers are order.first/middle/last/pass, with a different
return ADT. All first/middle/last functions contain one-child known-combiner and
two-child independent-let branches. Child indices are0/1/2 respectively. AST
phase instrumentation must mark each actual worker entry, $uN pre-child
initializer, leaf $value assignment, resumed argument after child and combiner
invocation. Capture final returned tagged values. Inline finite combiners need
AST invocation instrumentation rather than assuming named private functions.

1. Independently model alternating OOne/OTwo input using nested arrays, with
   BigInt U32 arithmetic; compare complete OrderResult graphs and score at
   depths0/1/2/3/7, seeds0/17/18/MAX_U32 and small before/leaf/after values.
2. For each unary reconstruction require RPair.left/right both RStamp, with
   exact same child object at their .a[1] slots. Different return tags, stamp
   values and all materialized fields must be checked, not merely scalar score.
3. Capture order.pass leaf result object; require every unary identity resume
   returns that exact child object. Capture child $value before invocation if
   needed. Do not replace the source identity helper or invalidate the guard.
4. MAX_NAT=281474976710655n. Test depth0 and depth1,seed18 (one unary input).
   first: all MAX must reach leaf failure before sibling increments; safe leaf
   plus MAX before must fail after leaf and before after; safe before plus MAX
   after must fail last. middle: MAX before wins before leaf; safe before+MAX
   leaf wins before after; safe before/leaf+MAX after fails on resume. last:
   MAX before wins first; safe before+MAX after wins before leaf; both siblings
   safe+MAX leaf fails only after both pre-child initializers. Pair baseline
   and candidate exact error observations. Distinguish equal Nat messages using
   actual phase events, as Phase39 did; error text alone is insufficient.
5. Depth3 input alternates OOne→OTwo→OOne and exercises pooled unary phase2/3
   versus binary phase0/1 in one worker. Require left-complete-before-right
   source order and exact output alias graph. Deep stack probe should use
   diagnostic full-tree adapters or result capture; avoid generic score's
   possible exponential traversal of aliased children.
6. Keep unchanged public dependency/host mutation/getter/reentry/throw and
   exact-entry partial/oversaturated/raw/slot controls. A mutation must refuse
   actual workers and preserve generic demand/error events. Include a shared
   input subtree to distinguish alias retention from accidental reconstruction.

Fixture static quantity audit: repeated before/leaf/after/extra parameters are
unrestricted; repeated child in picker is unrestricted; all input fields are
consumed once; make predecessor used once, seed reused only as unrestricted;
score's affine accumulator and children consumed once; roots consume each
parameter once. Pure Nat bumps may throw at precisely their source phase.
