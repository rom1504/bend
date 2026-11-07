# Phase175 — optimize the frontend as a complete component

Start from `0d12402`, the installed and qualified Phase171 compiler published in
Phase174. The current maintained source is 3,161,409 bytes, SHA256
`74cd7de3e5076490e20ba0218d4c9254853be72562946b9ef66fed6c10c7a53a`.
The frozen original full-source timing input remains Phase170's 3,150,535-byte
source, SHA256 `434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71`.

## Objective and evidence

Reduce work in parsing/loading, checking/publication and preparation after
checking. Preserve diagnostics, checked/prepared semantics, independent final
verification and generated-code quality. Keep QBE and the installed release.

The retained candidate diagnostic assigns 29.545s to parse/load, 19.027s to
checking/publication and 18.281s to the remaining frontend work. These are
instrumented intervals, not an exact partition of the fresh 188.395s complete
build. A 2x frontend improvement would be substantial; it is a target, not a
prediction. No frontend-only experiment can justify claiming a 100s full build
without a complete measurement.

## Fast loop

1. Reuse and reanalyse the current source-bound profile before sampling again.
2. Extract the actual maintained frontend dependency closure with an explicit
   checked diagnostic entry. Stop before backend planning and QBE emission.
   Preserve the ordinary source-loading and prepared-Base policy.
3. Use small real compiler inputs and unrelated language programs first. Observe
   complete loaded/checked/prepared values and original diagnostics through the
   checked hosted reference. Native timing includes conversion and cleanup;
   compact digests are timing observations, never the only correctness oracle.
4. Run the full fixed compiler input only for the baseline and promising changes.
   Frontend-image build time, execution time, output checking and resource costs
   remain separate. A smaller diagnostic image is not a new self-build score.

One root-owned guarded CPU3 target lane. Independent agents may inspect source,
prepare isolated overrides and audit semantics, but do not launch compiler jobs.
Use explicit disk/RSS budgets, fresh outputs, default 5GiB reserve and exact
retention. Do not prune qualified images, rollback, current profiles or oracles.

## Experiments and decision gates

Investigate parser token/lookahead work, repeated semantic queries/publication,
and avoidable annotation/erasure traversals. Rank changes by dynamic exposure
and complete-component cost, not source attractiveness or allocation counts.

For each hypothesis retain a small file with source anchors, expected removed
work, uncertainty, the cheapest falsifier, complete outputs, clean paired timings
and rejected attempts. Do not repeat the neutral Phase172 pending pattern rows,
Phase173 contextual-materializer shell, or failed indexed-store migration.

- Gate A: independently source-check every candidate and compare full results,
  including first errors, spans, binder identities, order and malformed controls.
- Gate B: counterbalance complete frontend/native trials; reject local wins that
  vanish after materialization or cleanup. Check transfer beyond one input.
- Gate C: compare complete QBE on representative sources. If promised exact,
  require byte identity; do not replace a failed identity gate with weaker tests.
- Gate D: only after meaningful component transfer, acquire one full candidate
  and run a fixed-source complete build against the installed reference. Charge
  the new code and all acquisition costs; distinguish altered compiler source
  from the frozen input being compiled.
- Gate E: integrate only a justified candidate with the required source,
  conformance, generated-product and self-hosting gates. Installation requires
  the existing release contract; do not silently replace the selected compiler.

## Delivery

Commit the design, implemented fast loop, tested changes and an honest report.
Record frontend and whole-build gains separately, source growth, failures and
execution cost. No new backend, unrelated rewrite or PR comment is in scope.
