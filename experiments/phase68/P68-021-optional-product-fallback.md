# P68-021: optional product routes must retain ordinary fallback

The checked21 admission diagnostic finds lexer `lex` has a valid ordinary
worker body but depends on `$product.lex`, rejected because the demand proof
cannot rule out the raw String match's impossible branch. Do not relax that
proof: SNil/SCon are tag comparisons, unlike complementary Bool/Nat conditions.

Hypothesis: retain all admitted workers, remove only unavailable product call
signatures, retry ordinary candidates with error-free bodies, and rerun the
existing bounded dependency closure. Tail self calls then use the existing
boxed ABI and goto loop. No C recursion cycles, new representation, guessed
exhaustiveness, or scheduler metadata are introduced. Failed/foreign/dynamic/
parallel cases retain the scheduler. One retry, not an optimization fixpoint.

Gate: checked B1, actual lexer C/oracle/mechanism screen, held-out six families,
selected native integration and raw error/polling/drop controls. B1/B2 latency
must account for retry cost. Compare with compiler20/21 and pinned upstream.
Preserve all original artifacts and rejected paths; report finite scope.

Related compilation observation: native checked admission uses eager Boolean
operators. Reordering `or` operands did not avoid the use scan in21 (27 clean
exact-C requests). Replace it with explicit lazy `nt_choose`; also avoid the
scan on non-variable nodes. No use-count map is needed if this simple repair
removes the measured cost. Exact-C comparison is the semantic gate for that
independent change.
