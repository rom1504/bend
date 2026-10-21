# Matched hosted compilation cost

`cost.mjs` compares the complete `p111_emit_admitted` entry of Phase117 and a
checked Phase118 integrated candidate under the same Bun process. It executes
no generated target and changes no compiler source. Output consists only of a
small report and an exact harness snapshot, not repeated QBE files.

The selected `p117-version-api03` report does **not** export
`p111_emit_admitted`. Acquire a fresh checked API from the exact selected
Phase117 source, exporting `p88_cache_prepare`, `p86_plan`,
`p111_runtime_admission`, and `p111_emit_admitted`. The harness rejects a different
parent source or missing export; it does not emulate the parent entry in host
JavaScript. Candidate reports require the same exports and exact checked-source
identity. API acquisition is a separate cost, not a timed request.

Root-run example, inside the repository and the ordinary CPU3 resource guard:

```sh
P118_PARENT_API_REPORT=selfhost/build/phase111/PARENT_ENTRY_API/report.json \
P118_RUNTIME_REPORT=selfhost/build/phase118/CANDIDATE_RUNTIME/report.json \
P118_EXPECT_EMISSION_REPORT=selfhost/build/phase118/CANDIDATE_EMISSION/report.json \
selfhost/.bootstrap/bun-1.4.3/bun selfhost/tools/performance/phase118/cost.mjs \
  selfhost/build/phase111/CANDIDATE_API/report.json \
  selfhost/build/phase118/CANDIDATE_SOURCE/manifest.json \
  selfhost/build/phase118/FRESH_COST_OUTPUT \
  coverage-map-churn-128 coverage-list-pipeline-128 lexer tree-bitonic \
  coverage-closures-256 editdist variation-local-fold-128-0 \
  coverage-numeric-recurrence-1024
```

Those eight cases are the default if no names are supplied. Explicit names use
the same frozen original45 manifest; `P118_CASE_MANIFEST` can select another
explicitly pinned case manifest. `P118_PARENT_EMISSION_REPORT` optionally checks
the parent's bytes against a prior verified emission too. Emission evidence must
match that role's exact compiler source and each input source. Candidate and
parent output hashes may differ; this measures compilation of different
optimizers, not identical backend output.

Each API independently prepares the same authenticated Base/cache bytes once.
No checked request or derived compiler state is shared between compiler sources.
Every iteration creates a fresh source request. One complete warmup round is
retained but excluded from summaries, followed by three measured rounds. Case
order rotates and API order alternates within each pair. Reports preserve all
individual observations, per-case medians and geometric candidate/parent ratios.

Clocks are explicit:

- API import and Base preparation are reported separately for each compiler.
- Frontend planning/checking and runtime admission are separate request stages.
- The admitted-entry clock includes Bend lowering, optimization planning,
  original/derived verification and QBE chunk rendering.
- Whole prepared-request time includes frontend, admission and admitted entry.
- Host chunk serialization/hash is outside that request clock and reported
  separately. Its exact newline convention matches the existing emit harnesses.

Both versions run under the exact same recorded Bun executable, host process and
CPU affinity. Three observations are a screen, not a high-confidence tiny-effect
claim. Cold preparation order is fixed; warmup/timed ordering controls do not
make those two single preparation measurements statistically paired.

The report pins parent/candidate compiler source and API, both target runtimes,
Base/cache/admission, fixture/output-oracle evidence, method and Bun. Runtime
objects are identity evidence only; no machine-code build or target run occurs.
Successful emission and repeatable hashes do not prove output semantics. An
optional exact replay against the independently built/verified emission connects
this cost measurement to existing correctness evidence; keep its scope explicit.

## Full compiler observer permission

File effects normally deny the packed-scalar `ns_definitions` permission, hence
also cold sealing in the conservative integrated entry. The optional independent
observer entry asks the existing `no_effect_definitions` predicate instead,
without broadening cold/array permission. A checked compiler using authenticated,
filled `File.open/read/size/write/close` and the admitted IO providers can pass.
It may still fail because of `Rwt`, another source form, an untrusted/unfilled
provider, or `File.read_bytes/write_bytes/read_at` or `NativeHost.*`, which are
outside that mature observer whitelist. Runtime availability alone is not an
observer-safety certificate. Query `p118i_permission` on the exact compiler
request before acquiring a native image; a false result is useful evidence and
must not be changed merely to improve the benchmark.

This harness was prepared source-only. The root owns all compiler/API acquisition,
cost measurements and target correctness evidence.
