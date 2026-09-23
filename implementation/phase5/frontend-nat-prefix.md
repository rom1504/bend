# Nat prefix adjacency and precedence

P5-018 repairs a wrong-result bug: `(2n * 1n+3n : Nat)` evaluates to **8** in
pinned TypeScript but **5** in the integrated baseline, in both interpreter and
JavaScript execution. The final candidate produces 8 in both lanes. It also
repairs six fresh invalid acceptances involving spaced, parenthesized or
newline/comment-separated prefixes and namespace placement.

Upstream parses immediate `n+` inside the numeric atom and consumes its right
side at full expression precedence. The port previously recognized a Nat literal
in generic binary growth, ignored adjacency, and let the caller's precedence
change grouping. The repair tests actual token line/column adjacency in the
numeric branch, validates/converts the literal before parsing its right side,
and reuses the converted value. Ordinary names take the existing constructor/
reference branch. The two duplicate binary special-case helpers and two
subsequently unreachable literal helpers were removed.

## Evidence and retained failures

The [semantic audit](frontend-nat-prefix-evidence/final-audit.json) distinguishes:

- 25 selected acceptance/rejection-phase controls, including the six repaired
  invalid acceptances. Eight diagnostic strings differ in the initial 19-case
  gate; the extra negative controls are also not exact-diagnostic claims.
- Fourteen exact execution observations: seven programs in interpreter and JS,
  with arithmetic association observed through a simple Nat-to-U32 counter.
  The baseline's only two execution mismatches are the wrong-result witness.
- Fourteen unaffected raw parser graphs identical to the baseline and eleven
  accepted graphs identical between the first and corrected source variants.

Variant 1 established the atom-based repair. Variant 2 reorganized numeric/name
handling to avoid duplicated digit tests and an additional helper on ordinary
names. Additional first-error controls then found a real regression:
`4294967296n+(0 => 0)` reported the RHS lambda error instead of the earlier
invalid Nat literal. Variant 3 validates the literal first and restores the
baseline/upstream ordering. The failed variant and its passing acceptance/phase
and execution gates remain preserved; those gates alone did not prove error
ordering.

Variant 4 deletes only the two unreachable literal helpers. Its fresh genuine
checked build passes the 19-case gate and eleven exact raw-graph comparisons.
Its **normal API bytes are identical to variant 3**, so the artifact used by the
fourteen execution observations is preserved. The
[cleanup audit](frontend-nat-prefix-evidence/final-v4-audit.json) records that
those executions were performed under variant 3's source provenance, not rerun
under variant 4. All 59 source modules were searched for remaining references;
neither removed helper belonged to the maintained 54 exports.

A setup error is retained: the first baseline execution attempt requested
persistent workers, which do not support execution lanes. A new isolated-worker
configuration produced the actual baseline observations. No rows were overwritten.

Two adjacent limitations remain explicit. `1n+;2n` is still incorrectly accepted
because the generic expression parser skips semicolons. Malformed float-`n`
suffixes still disagree with upstream's selected parser rule/diagnostic. Their
before/after observations are retained separately; agreement on rejection phase
is not proof of the same rule.

## Artifact and integration scope

Baseline: genuine checked `integration/attempt-03`, API `8cfa124d…`. Its combined
selected gate was 273/274 at experiment start; this report does not label that
gate passed. Final variant 4 source:
`7458ea82ed9bf56c27fc9d81b444ea860bb3c1ec8eb6f85d6dc83633b0c8e91d`.
Variants 3 and 4 normal API:
`07c2ee92f6a47fae3f0feb2997f4a3d19bdf1a3dbb9f7dfb34f34f263aad8083`.

Root independently reviewed the final algorithm and authorized promotion. Both
production modules were still byte-identical to the baseline at promotion;
[the record](frontend-nat-prefix-promotion.json) captures before/after hashes.
Other agents' isolated expectation-rendering changes must be composed separately.

The [archive](frontend-nat-prefix-evidence/manifest.json) preserves each source
variant, genuine bootstrap, raw observations, fixtures, histories and consumed
tooling with verified hashes. It retains historical absolute paths and is not a
new bootstrap or relocatable package. CPU1 used Node 24, a 4 MiB stack and 4 GiB
heap, alongside other correctness work and outside coordinated timing holds.
No performance, native execution, broad-conformance or fixed-point conclusion is
made here; the final integration gates are separate.

Use the maintained workflow with fresh destinations. The final checked config
is `selfhost/build/phase5/nat-prefix/candidate-v4.config.json`; confirmed checks
are `selfhost/tests/frontend/phase5-nat-prefix/confirmed-cases.json`, and exact
execution oracles are in `execution.json` beside it. The original failing
`final-boundaries.json` remains available to reproduce the semicolon residual.
