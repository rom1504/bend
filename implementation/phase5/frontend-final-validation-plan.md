# Selected final frontend/backend validation

Prepared only; no final-source run is claimed here. The selection is
`selfhost/tests/frontend/phase5-final-backends/cases.json`: 16 programs/fixtures,
42 selected lane observations per compiler (84 paired observations). Nine
positive programs execute through interpreter, JavaScript and actual native C
compilation/execution. The same pinned negative matcher fixture exercises all
three execution entry points and must preserve its exact diagnostic. Six custom
negative controls use parse/check acceptance-and-phase oracles; they are not
execution tests or exact diagnostic claims.

Positive coverage includes Nat wrong-result precedence, a prefix with an inner
operator namespace, duplicate parallel binder ordering, naked-reference/brace
adjacency, local namespace propagation, a do-bound constructor name, ordinary
law filling, a genuine imported helper and legal sharing of a constructor/top-
level definition name. The last two are newly prepared controls, not previously
observed passing results. Negative coverage includes namespace closing errors,
spaced Nat operators, decorators before laws, constructor names as parallel
binders and native/Base declaration freshness. Known semicolon and imported-
law-fill residuals remain in their original experiments; they are not disguised
as passing oracles in this selected gate.

The Phase4 native graph matrix covers a different artifact (a compiled native
compiler) and different module-loading scope. Its results must not be carried
forward as evidence for the changed Phase5 frontend. Here use the final genuine
normal checked B1 API and its actual snapshot, via the maintained workflow:

```sh
# From selfhost/, after root freezes and checks FINAL_ATTEMPT.
export CC="$PWD/build/phase1/clang/root/usr/bin/clang-16"
export LD_LIBRARY_PATH="$PWD/build/phase1/clang/root/usr/lib/x86_64-linux-gnu"
export LIBRARY_PATH="$PWD/build/phase1/clang/root/usr/lib/x86_64-linux-gnu"
export CPATH="$PWD/build/phase1/clang/root/usr/include"
node --stack-size=4096 --max-old-space-size=4096 \
  tools/development/workflow.mjs validate FINAL_ATTEMPT \
  tests/frontend/phase5-final-backends/cases.json NEW_OUTPUT
```

The workflow selects isolated workers for execution lanes and verifies the
actual bootstrap/source/API/runtime identities. Pin the parent process and
children to the CPU assigned by root; record exact Clang/environment identities
and the final source/proof lineage in the integration archive. Retain every
failure, including unsupported setup/resource failures; do not remove a row to
claim complete selected coverage. Final execution requires root's scheduling
clearance. No GPU execution or full-conformance claim follows this selection.

A final size recount should reuse the original category/file-list method from
prior architecture reports, reporting tracked production Bend modules, host
workflow/harness modules and experimental tools separately. Compare byte/line
counts over the same file sets at the campaign baseline and final revision;
list newly added/deleted production helpers and modules. Do not call those
counts cyclomatic complexity or infer a runtime improvement from fewer lines.
