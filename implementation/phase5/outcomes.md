# Phase 5 experiment outcomes

Evidence cutoff: 2026-09-23 02:26 UTC. These outcomes supplement the original
dated experiment plans; a frozen plan's pre-execution status is not rewritten.
“Included” means part of the final checked source or maintained tooling, not
complete upstream conformance. The [campaign report](report.md) gives combined
results and the release and integration gates.

| Experiment | Decision | Demonstrated outcome and limit |
| --- | --- | --- |
| P5-001 [Bindings and decorators](frontend-bindings.md) | Included | Shared pattern validation and corrected binder scope/decorator grammar; retained paired and execution witnesses. |
| P5-002 [Development entry](development-workflow.md) | Included | One checked build/validate entry with immutable attempts, explicit artifact kinds and bounded failure handling. |
| P5-003 [Reusable equality derivation](equality-derivation.md) | Included; release default | Recognizes new checked builds, preserves original APIs and fallback behavior; unknown contracts are refused. |
| P5-004 [Do notation](do-notation.md) | Included | Demonstrated acceptance/phase repairs and execution agreement; retained diagnostic mismatches remain distinct. |
| P5-005 [Application origins](application-origins.md) | Rejected | Four exact diagnostic repairs did not justify repeated quadratic reparsing; stress counterexample and failed attempts retained. |
| P5-006 [Constructor adjacency](frontend-adjacency.md) | Included | Restores demonstrated same-line adjacency rules with nearby accepted/rejected controls. |
| P5-007 [Constructor diagnostic reasons](constructor-diagnostics.md) | Included | Corrects selected constructor/datatype error reasons; no claim of general diagnostic equivalence. |
| P5-008 [Argument delimiters](frontend-arguments.md) | Included | Repairs explicit argument-list syntax boundaries while preserving statement-aware skipping elsewhere. |
| P5-009 [Plain do binders](do-plain-binders.md) | Included | Restores the demonstrated plain-binder form and retains source/error-order controls. |
| P5-010 [Local declaration freshness](declaration-freshness.md) | Included | Checks local constructor names at the appropriate declaration boundary. |
| P5-011 [Structured parser errors](structured-parser-diagnostics.md) | Included | Private raw error transport preserves the chosen Error term; the public parser result still carries diagnostic text. |
| P5-012 [Small equality comparison](equality-performance.md) | Measured | Same checked source, opposite-order core/list measurements and emitted-output gates; these are small-workload results. |
| P5-013 [Unqualified operators](frontend-operators.md) | Included | Repairs demonstrated unresolved-operator classifications while preserving bound/ADT cases; documented parser-priority gaps remain. |
| P5-014 [Matcher heads](frontend-matchers.md) | Included | Only raw Ref heads introduce named matcher arms; other heads retain the existing tail/expected-} path. |
| P5-015 [Full frontend equality loop](equality-frontend.md) | Measured | Mean 301.905→229.753s, 23.90% less, with all 11,024 observations/histories exact on its frozen source. |
| P5-016 [Namespace errors](frontend-namespace-errors.md) | Included | Closing a namespace no longer discards an earlier parser Error. |
| P5-017 [Core filter layering](core-filter-layering.md) | Included | Removes a duplicate checker filter, restores the standalone frontend component and preserves definition selection. |
| P5-018 [Nat prefix parsing](frontend-nat-prefix.md) | Included | Repairs the actual 5-versus-8 wrong result, adjacency and precedence; an intermediate first-error regression was corrected and retained. Removes two obsolete helpers. |
| P5-019 [Expectation sites](parser-expectation-sites.md) | Included with explicit residuals | Improves selected exact messages and preserves earlier exact oracles. The original stricter presentation gate remains failed; remaining parser differences are not counted as repairs. |
| P5-020 [Imported freshness](imported-freshness.md) | Included | Chronological exact-name checks repair demonstrated import/declaration gaps; deferred law-fill cases remain explicit. |
| P5-021 [Private Base decoding reuse](persistent-base-decoding.md) | Included | Exact-byte/identity validation guards one private immutable decoded book. Full same-compiler ABBA mean 292.602→242.597s, 17.09% less, with all observations/histories exact. |
| P5-022 [Embedded parser errors](embedded-parser-diagnostics.md) | Included with explicit residuals | Recovers the existing chosen Error and unique source only on rejection. Original failed strict gates and the later confirmed multiline wrong-excerpt defect remain visible. |
| P5-023 [Final complete-source comparison](full-source-comparison.md) | Measured | Six complete checked compilation/output gates: TS60.25s, B1 642.58s, derivative363.39s process means. The derivative uses43.45%less time under the documented workflow/cache policy. |

The percentages above come from distinct frozen workloads and are not multiplied
into an unmeasured combined gain. The equality derivative preserves emitted bytes;
it does not establish faster user-program runtime. The [fresh checked fixed point](final-selfhost.md)
is a separate completed proof of self-reproduction, with actual outputs and all
59 current/frozen/assembly module identities independently checked.

Final B1 frontend compatibility is [377→318 strict check failures and 560→444 exact
live differences](final-conformance.md), with no lost previously exact observation
and all 919 positive fixtures retained. These are different metrics, not counts
of equivalent soundness repairs. The [new multiline diagnostic counterexample](static-counterexample.md)
remains unfixed in this frozen source. Public-H/derived frontend validation is [complete](final-artifact-frontend.md),
with2,756exact B1 observations each. Broad backend validation has its own report
and remains pending at this checkpoint.
