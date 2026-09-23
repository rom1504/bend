# Named matcher heads

The isolated P5-014 candidate moves numeric and other non-name matcher keys to
the same parse-error boundary as pinned TypeScript. Sixteen custom acceptance/phase
checks and 12 interpreter/JavaScript observations pass; the execution outputs
agree exactly. The three original pinned fixtures now reject during parsing in
both parse/check lanes. Their three strict diagnostic checks still fail because
the rendered messages differ. Those failures remain visible.

The implementation changes one condition in `f_matcher_head`: a colon introduces
an arm only after a raw Ref. This raw frontend shape represents upstream's
unresolved Var/Ref before scope elaboration. Other terms take the existing tail
route and fail when `}` is expected at the colon. No numeric matching feature or
checker change is introduced. Ordinary pattern validation must not be used here:
a bare constructor is a valid matcher key, unlike an ordinary local binder.

The fresh baseline confirms six minimal gaps, including an actual invalid
acceptance for a braced-constructor key and five parse/check phase mismatches.
The new condition repairs them. Positive controls cover named, parenthesized,
marked and qualified names, ordinary tails and an empty matcher. Negative
controls also include strings, characters, calls, actual braced annotations,
lambdas, quantities and an invalid body after a numeric key. The latter must
still report the key's delimiter failure first.

One initial oracle was wrong: `(MatcherOn : MatcherBit)` supplies an operator
namespace, preserving a raw name; it is not a term annotation and is accepted
by both compilers. The original attempt remains unchanged. A separate corrected
manifest accepts it and adds `{MatcherOn : MatcherBit}` as the true annotation
negative. No pinned `#|` diagnostic was replaced with an acceptance-only oracle.

## Artifact and review scope

The baseline is the completed second integrated Phase5 normal bootstrap under
`build/phase5/integration/attempt-02`. The candidate is a genuine normal build
from its frozen copied project, modifying only the matcher condition:
API `61f64b45ca8f55e5bca64252c8e84ebc0e429076ecd207f91676f859594b8689`,
source `b1176efbb33f547d4ad89f0e8869e74f0f3c6b4175090838ac4272f6c403c764`.
Node 24 used CPU1, a 4 MiB stack and 4 GiB heap alongside other correctness work.
No performance comparison, native gate, full-conformance or fixed-point claim
is made.

Lexer-analysis independently reviewed the actual condition and its composition
with the separate error-transport change. It confirmed the raw-name distinction
and found no blocker; that review did not rerun tests. After root’s second source checkpoint, only this reviewed condition was promoted.
The [promotion record](frontend-matchers-evidence/promotion.json) captures both
production module hashes; the isolated artifact results above are unchanged.

[Selected audit](frontend-matchers-evidence/final-audit.json) verifies the actual
bootstrap/API/source/input identities and these separate outcomes:

| Gate | Result |
| --- | --- |
|16 custom check observations|All acceptance/phase oracles pass; nine exact diagnostic differences remain|
|12 interpreter/JS observations|Six programs, both execution routes, exact outputs|
|Six original pinned parse/check observations|All phases now agree on parse rejection; three strict check diagnostics still fail|
|Three adjacent grammar controls|All retain known disagreement, outside this patch|

The adjacent controls establish two invalid acceptances (missing opening brace
and repeated arm semicolons) and one valid rejection (an optional semicolon after
the matcher tail). They remain failed rows, not passing coverage. A later bounded
matcher-boundary change can address them independently.

The [verified archive](frontend-matchers-evidence/manifest.json) preserves the
baseline, initial wrong oracle, genuine candidate, raw reports/history, source,
fixtures and tools. It is not a new bootstrap or an automatic relocation of
historical absolute paths. The focused selection is
`selfhost/tests/frontend/phase5-matchers/cases-v2.json`; original pinned and
residual selections are separate files in that directory.

Recorded commands from `selfhost/`, with new destinations:

```sh
node tools/development/workflow.mjs run \
  build/phase5/matchers/candidate-v1.config.json \
  build/phase5/matchers/candidate-v1
node tools/development/workflow.mjs validate \
  build/phase5/matchers/candidate-v1 \
  tests/frontend/phase5-matchers/cases-v2.json \
  build/phase5/matchers/focused-v1
python3 tests/frontend/phase5-matchers-audit.py \
  build/phase5/matchers build/phase5/matchers/final-audit.json
```
