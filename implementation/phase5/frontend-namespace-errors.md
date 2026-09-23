# Namespace parser error propagation

P5-016 repairs six fresh invalid acceptances: malformed namespace expressions,
missing namespaces, wrong closing delimiters and an absent closing delimiter at
EOF. Sixteen selected acceptance/phase checks and fourteen interpreter/JavaScript
observations pass against live pinned TypeScript. All execution outputs agree
exactly. Eight focused diagnostic strings still differ; this is a semantic repair,
not complete parser diagnostic parity.

`f_group_namespace` previously passed a failed namespace parse into
`f_namespace`. That transformation ignores its namespace argument for ordinary
literals and references, discarding the Error. The new branch propagates that
Error unless the earlier expression already contains an Error. In that case it
preserves the earlier expression, including nested errors. Successful namespace
transformation is unchanged; the recursive earlier-error scan runs only when the
namespace result is already Error. No type check is added for namespaces that an
expression does not actually use.

The genuine isolated normal bootstrap changes only this function in
`src/front/sugar.bend`, based on integrated attempt02. Its API is
`047e5d191e8ef56a713d7723cb251774e1caeb1859b48afde56217c8698e46b2`;
assembled source is
`cdcac70cf84b649a665f24af5cd0013e47fa747af5a7b9ecb290df85bd3bc069`.
After independent root review, only the function was promoted, preserving the
separate parser transport edit in the same module. The
[promotion record](frontend-namespace-errors-promotion.json) captures production
module hashes; these are distinct from the isolated candidate's identity.

Seven accepted raw parser results remain structurally identical. Three earlier
error controls preserve their previous raw results/text. The tuple-nested lambda
error remains inside the exact raw book; its public parser error field is empty,
and the loader reports the intended lambda-binder error. One other nested-call
fixture preserves a pre-existing generic top-level diagnostic, so it is not
claimed as intended-rule parity.

Two failed test assumptions remain visible. The initial local-binding positive
lacked a required annotation and was rejected by both compilers; a separate
annotated fixture replaces it in the confirmed selection. An initial raw audit
incorrectly required a nonempty top-level error for the tuple-nested case; a
separate corrected helper verifies the full identical raw result and embedded
Error. Neither failed attempt was overwritten.

Three sibling controls remain separate: `(42 : 0)` is valid because no operator
uses the namespace; `(1 + 2 : 0)` still fails at checking instead of parsing;
`(1 + 2 : 0]` now agrees on parse rejection but reports the delimiter instead of
the upstream namespace-name error. Agreement on phase is not proof of the same
first rule. This patch does not claim to fix namespace-head validation.

The [selected audit](frontend-namespace-errors-evidence/final-audit.json) checks
actual source/API/bootstrap provenance and distinguishes these outcomes. The
[archive](frontend-namespace-errors-evidence/manifest.json) preserves raw reports,
worker histories, fixtures, source, tooling and failed attempts with verified
content hashes. Historical absolute paths are retained; this is not a new
bootstrap or a relocatable package. CPU1 jobs used Node 24 with a 4 MiB stack and
4 GiB heap alongside other correctness work; no timing, broad-conformance,
native or fixed-point claim is made.

Confirmed selections are `selfhost/tests/frontend/phase5-namespace-errors/`
`cases-v2.json`, `error-order.json` and `execution-v2.json`; residuals have their
own manifest. Reproduce with the maintained workflow, using fresh destinations:

```sh
node tools/development/workflow.mjs run \
  build/phase5/namespace-errors/candidate-v1.config.json NEW_ATTEMPT
node tools/development/workflow.mjs validate NEW_ATTEMPT \
  tests/frontend/phase5-namespace-errors/cases-v2.json NEW_VALIDATION
python3 tests/frontend/phase5-namespace-audit.py \
  build/phase5/namespace-errors NEW_AUDIT.json
```
