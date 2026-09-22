# Frontend binding validation and decorator placement

Status: all109 selected paired observations and intended-rule checks pass. Root has integrated the reviewed three-file candidate alongside its separately reviewed do-block changes; combined broader gates are separate and were still running at this report cutoff.

The fresh baseline confirms eight acceptance/rejection-phase mismatches across22 new witnesses. Parallel bindings bypassed ordinary pattern validation: bare constructor names could be accepted, and braced destructuring was rejected only later. Decorator dispatch accepted `@unsafe` before a law, type, end-of-file or another decorator. The isolated candidate repairs those boundaries while preserving the existing46 Phase2 rule/grammar controls.

Execution controls then exposed a separate pre-existing scope error. Duplicate parallel names produce1 in both the baseline interpreter and emitted JS where pinned TypeScript produces2. Fresh local-destructuring and match-row examples reproduce the same wrong result. These were not caught by acceptance-only controls because both compilers successfully check the programs.

## Candidate changes

Three modules are owned and changed in isolated overlays: `front/parallel.bend`, `front/validate.bend`, `front/declarations.bend`.

Pattern validation shares one left-to-right traversal. Ordinary patterns retain their existing binder/constructor checks. Parallel patterns first require a name, then reuse the same checks; braced constructor destructuring remains legal for a single local binding and illegal in a parallel list. Validation precedes scoping values/body. The unused old traversal continuation was removed after checking that it had no callers or maintained host API export.

A shared `f_pattern_env` prepends collected binders in reverse source order for body lookup. Upstream opens patterns left-to-right and searches the newest entry first. `f_penv`, original pattern lists, value order, values' enclosing environment and row metadata stay unchanged. The helper is used only at the local, parallel and match-row body environment sites. This repairs duplicate-name shadowing without making parallel values sequential.

The decorator gate requires `def` before ordinary top-level dispatch, including before end-of-file success. The unsafe flag still reaches the same definition parser. No parser, lexer, checker or diagnostic-module rewrite is part of this change.

## Frozen attempts and evidence

- `before`: genuine normal54-export Phase4 checked API `a3a287c2…`, source `34c6ef63…`; all22 proposed live-reference oracles confirmed, candidate mismatches8.
- `checked-v1` / `after-v1`: pattern/decorator boundary repair passes22 acceptance-phase controls. `regression-v1` passes46 existing controls.
- `checked-v2`: removes a dead helper; the emitted API remains exactly `7994c52e…`. `focused-v2` passes70 check observations. Actual execution still exposes duplicate-name shadowing.
- `duplicate-before`: untouched baseline returns1 versus TypeScript2 on both interpreter and JS lanes.
- `scope-before2`: fresh-name local and match-row fixtures likewise return1 versus2 on the baseline interpreter.
- `checked-v3`: shared body-environment ordering, checked source `0687a953a4611a80812f4fa7ec53ab46960983631c1e0bfdaa07465fcd563cf0`, API `c29e31e34dbadec6a060c1007f2fefa54452d715790eece18f0962dd12060ab2`. `focused-v3` passes70 acceptance/phase observations. `execution-v3` passes12 interpreter/JS observations. `scopes-v4` passes27 observations across check/interpreter/JS; the final focused audit totals109 selected observations.

All builds use immutable copied baseline modules and separate overlays; the untouched pinned TypeScript compiler checks types, ownership, completeness and requested roots before API emission. Checked-overlay reports are retained as their actual format. The selected adapter verifies this provenance and frozen host inputs; it does not fabricate a normal-bootstrap sidecar.

Commands use Node24.18.0, CPU1, a4MiB stack, at most4GiB heap and a180-second outer limit per job. These are short correctness jobs alongside independent work, not controlled performance measurements.

## Limits and preserved failures

Exact upstream diagnostics remain different for35 of the70 check observations. The original `parallel-first-bad-value` witness (`missing {42 : U32}`) still fails for a raw-parser rule different from TypeScript; matching parse rejection does not establish intended-rule parity. A separate grouped `{missing : U32}` witness avoids that ambiguity and checks the constructor-binder rule first, as does the invalid-body control. Imported Base constructor Nil and later-declared constructors cover context availability.

The first execution setup mistakenly selected persistent mode, which correctly reported unsupported interpreter/JS lanes. It is retained and does not count as executed tests. A first local/match fixture also reused the prelude's Pair declaration and was rejected by both compilers before reaching shadowing. Those files and results remain unchanged; distinct ScopePair fixtures provide the valid observations.

The first scope execution matrix also retains a valid upstream mixed-duplicate program whose middle bare value name precedes a braced annotation. The Bend raw parser rejects that program before scope analysis. A separately named grouped-value variant passes and isolates the intended duplicate/outer-scope rule; the original valid failing witness remains in the repair queue for the parser owner.

This work does not claim full conformance, exact-diagnostic parity, native-backend coverage or self-reproduction of the changed source. Root independently reviewed the common traversal, decorator gate and shared environment-order argument before integration. Broader combined-source results must be read separately.

## Final focused gate

[The focused audit](frontend-bindings-evidence/final-audit.json) verifies **79 check observations, 15 interpreter runs and 15 JavaScript runs**, each paired with the live pinned TypeScript reference. All79 acceptance/rejection-phase oracles pass; all30 execution outputs agree exactly. Twelve specific diagnostic-rule assertions distinguish constructor-name rejection, parallel names-only rejection and decorator placement. Bad-body and grouped-unbound-value cases retain the isolated binder error first. Those assertions do not relabel the remaining35 exact diagnostic differences.

The two preserved wrong-result baseline families beyond parallel bindings use fresh constructor names and return1 instead of2. The final candidate's last-name behavior passes for ordinary and nested destructuring, match rows, nonadjacent parallel duplicates, reusable marks, an erased outer context and simultaneous values that reference an outer variable.

The reproducible gate uses `phase5-binding-audit.mjs BEFORE_PAIRED FOCUSED_PAIRED EXECUTION_PAIRED SCOPES_PAIRED NEW_REPORT`; consumed argument paths and reports are retained. The selected paired harness configurations carry CPU/resource limits, checked API/host provenance, selection and process modes. No compiler timing result is inferred from these correctness jobs.

## Durable preservation

The archive contains5,511 file-version records in3,486 verified objects (12,264,750 compressed bytes). The [evidence manifest](frontend-bindings-evidence/manifest.json) and [archive guide](frontend-bindings-evidence/README.md) preserve baseline and candidate modules/APIs, genuine checked reports, all selected run reports/worker histories, fixtures, frozen tools and failed attempts. Content-addressed gzip objects are decompressed and compared with original bytes, then source identities are checked again. The Node executable is identified as an external prerequisite.

A first archive attempt correctly refused an auxiliary README hash changed between completed scope runs. Both exact README versions are now retained with explicit historical-path mappings; no compiler, fixture, report or recorded hash was rewritten. Historical overrides are restricted to README files. The failed archive manifest/tool version remain preserved, and successful test observations are not changed by the archival correction.
