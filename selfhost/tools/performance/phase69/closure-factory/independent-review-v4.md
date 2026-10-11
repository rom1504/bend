# Independent review: literal combinator specialization V4

Source review only. This reviewer ran no compiler or native target and changed
no production source. Reviewed `direct-v2-to-v4.patch` and its six raw/six typed
controls after rejecting the earlier V3 patch.

## Rejected V3 counterexample

The ordinary core `subst` helper rebuilds applications through `core_apply_span`,
which immediately beta-reduces literal lambdas. For the admitted linear
combinator `after(f, g, x) = f(g(x))`, supplying `f = y => 0` therefore rewrote
the body to zero and discarded the demanded `g(x)` computation. Linearity of
the combinator parameters does not prove that a supplied function demands its
own parameter. A failing or divergent `g(x)` makes the change observable.

The owner independently found the same issue in the existing `nd_beta`
Var-argument substitution: it could normalize an unrelated nested application
inside a literal body before ordinary native sequencing. That behavior predates
V3, so correcting it is recorded as an explicit prerequisite, with its own
one-line patch and a separate nested-literal demand control.

## V4 reasoning

V4 uses syntax-only `nq_layout_subst` for telescope renaming, literal capture
insertion and the existing `nd_beta` Var case. Applications survive substitution
until native lowering processes them. Non-variable arguments then pass through
the existing `nc_mklet` sequencing path, including arguments ignored by the
eventual lambda body. This fixes the concrete V3 counterexample without assuming
purity or totality of arbitrary runtime calls.

The remaining admission checks are deliberately narrow: an ordinary proper
partial named call already admitted by V2, at most eight live telescope
parameters, a body containing only bound variables and applications, distinct
parameter IDs and exactly one use of each parameter. A bounded depth walk
precedes the recursive use counter. Valid admitted bodies therefore have at
most fifteen App/Var nodes. No global reference, match or recursive definition
body is copied by this rule.

Every telescope binder is renamed before substituting captures. Freshness is
checked against the original callee, argument syntax and caller environment;
the raw colliding-caller/callee-ID case tests this boundary. Supplied literal
lambdas are inserted once as values; other captures remain evaluated once in
their original order. The existing closure environment and sharing/drop
machinery subsequently owns free values. Repeated or dropped combinator
parameters retain V2 rather than relying on beta substitution to preserve their
ownership or demand behavior.

No further concrete source-level blocker was found. This is permission to test
the hypothesis, not production qualification.

## Execution requirements

Run the six V4 raw cases and typed fixtures, plus the existing partial/bang,
overapplication, foreign callback and shared-closure controls. Record candidate
runtime failures as required results where specified: an unused argument is
still demanded. The old baseline may itself fail the nested-demand oracle due
to the corrected `nd_beta` behavior; preserve that observation and distinguish
the prerequisite correctness change from the optimization's result.

Require ordinary and stored/escaped closures, String captures also used by the
caller, argument permutation, nonliteral capture error before application error,
and repeat/drop fallback. CPU one/four-thread success and fewer closure applies
do not establish GPU conformance or a general speed gain. Compare V2 plus the
beta prerequisite separately when attributing runtime benefit to specialization.
