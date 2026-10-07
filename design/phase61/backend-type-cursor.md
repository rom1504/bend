# Private backend type cursor: first bounded experiment

Proposed, not applied or measured. [P61-008](../../experiments/phase61/P61-008-backend-type-cursor.md)
freezes the hypothesis and gates before root source execution. The broader
[backend analysis](../../implementation/phase61/backend-types-next.md) records
State06 profile scope and pinned TypeScript comparisons.

The first candidate specializes constructor type parameters with fewer temporary
trees. `j_specialize` currently normalizes a head, substitutes the argument
through its entire remaining codomain, and repeats. A raw `All` telescope with
beta-stable children can instead retain pending substitutions and realize the
remaining type once. The existing checker environment materializer supplies the
substitution-order proof; this experiment does not extend its admission grammar.

The new private `jd_specialize` accepts the same arguments/result as the old
helper. Zero or one argument uses the old path. Multiple arguments first pass
`env_tele_safe(tel)`. Each step requires a raw `All`, fewer than 64 pending
bindings, and `env_tele_safe(argument)` under explicit `kc` branches. The next
raw tail and `KTelescopeBinding{binder,argument}` are retained. Exhaustion or
unknown/unsafe shape realizes all pending bindings before invoking the complete
original helper on the remaining arguments. Empty input realizes pending
bindings without normalizing the final result.

This fallback is significant: a non-function head makes `j_app_type` return
`Absent`, while `j_specialize` continues through subsequent arguments. The
checker fill helper's `Error` result is not an interchangeable contract. Earlier
replacements that mention later binders must still receive later substitutions;
later inserted replacements remain raw relative to earlier bindings. Quantity,
source-span and KLambda metadata remain exact.

The patch adds one private module plus four direct-only call-site substitutions
and a manifest entry. Shared common queries, public carriers, runtimes and native
consumers remain unchanged. The [focused controller](../../selfhost/tools/performance/phase61/backend-telescope/controls-v1.mjs)
requires 24 old/new/legacy/independent-value cases and actual activation through
`jd_ctor_checked`; it also covers unchanged inputs and empty original identity.
These are bounded explicit-IR controls, not a claim about arbitrary host getters
or a substitute for genuine source/B2 and broad output qualification.

Expected whole-request scope is modest, roughly 1–3% if this specialization alone
pays. Map's remaining substitution allocation is not all constructor parameter
work. Admission scans can consume the saved allocations, so reject a repeatable
regression and stop on negligible eligible work. Only a cheap coherent gain
justifies a later signature/field cursor proposal. Sharing rendered definitions
between reachability and final emission requires a separate proof for changed
calls/SCC/forcing contexts and is outside this experiment.
