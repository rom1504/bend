# Negative-test compatibility audit

The 377 check-lane failures are **not all diagnostic wording differences**.
The recorded evidence supports a presentation-only explanation for 173 cases,
shows 16 different rejection-phase/rule outcomes, and leaves 186 cases without
proof that only presentation differs. Two additional check acceptances are
correctly deferred compiler gates, with exact rejections in every execution
lane. These groups total 377; none is silently promoted to an exact test pass.

This is a read-only audit of
[typed-release-a6f.json](../tests/conformance/typed-release-a6f.json), compiler
SHA256 `a6f99fc20820d59a622e5a08deb5e631a3c1c1d7fd82f66e00010a0bd9d27f6d`,
against its embedded expectations from upstream revision
`6018e28ecc67cf1fffc0c20c64b11023474c2df8`. No fixtures were rerun and no compiler,
API, or runtime was changed. Per-case classifications and verbatim expected and
actual outputs are in
[negative-audit-a6f.json](../tests/conformance/negative-audit-a6f.json).

The report contains 459 negative fixtures: 82 exact check-lane passes and 377
failures. All 919 positive fixtures pass the check lane. Positive acceptance is
evidence about that corpus; it does not establish negative-rule completeness.
Also, fixture namespaces are not rejection phases: several `check/array_*`
fixtures expect syntax errors at this upstream revision.

| Observed output among the 377 failures | Count |
| --- | ---: |
| Structured checker diagnostic | 185 |
| Flat checker diagnostic | 32 |
| Positioned parser error | 72 |
| Parser error reporting line 0, column 0, and end of input | 23 |
| Frontend declaration/flattening validation message | 57 |
| Filesystem loading error | 6 |
| Check succeeds; subsequent compiler gate rejects | 2 |

| Evidence-based assessment | Count |
| --- | ---: |
| Diagnostic core and context identical; location/source-window rendering differs | 146 |
| Same parser expectation, observed token, and source line after explicit wording normalization | 27 |
| Expected syntax/flattening rejection replaced by another reported phase/rule | 15 |
| Aggregate TODO rejection masks the expected live-use-of-unfilled-law rejection | 1 |
| Correct later-phase compiler rejection | 2 |
| Not established as presentation-only | 186 |

For the 146 core matches, comparison removes `Location:` and the following
source window but retains the complete expected/observed/message/context text.
For the 27 parser matches, it requires identical token and line and normalizes
`term` to `a term`, plus the two declaration-list error labels. This is evidence
of equivalent diagnostics for those inputs, not proof that the parsers accept
identical syntax. Missing spans, different location labels, or different source
windows remain real compatibility defects.

Representative recorded differences:

| Fixture | Expected | Actual | Assessment |
| --- | --- | --- | --- |
| `check/beta_ann_lambda` | Expected `Nat`, observed `U32`, with highlighted source window | Same expected/observed and `Location: main`, no source window | Presentation-only evidence |
| `check/array_boxed_default` | Expected a term, observed `'!'`, highlighted line 24 | `line 24:7: expected term; got !` | Presentation-only evidence |
| `check/cop_ctr_field_000` | Expected `Data`, observed `Kind(a)` | `Box: type mismatch` | Same broad rejection class, but the flat message does not prove the exact obligation checked |
| `comptime/err_arg_type` | Expected `Nat`, observed `Bool` | `template argument is open or ill-typed` | Conflates two conditions; intended type obligation is unproven from this result |
| `parse/invalid_assign_target` | Expected a binder/constructor pattern, observed `f(1)` | Checker cannot infer the type of `3` | Different rejection phase and rule |
| `spec/comp_erased_args` | Reject non-leading `~` clause | Checker reports expected `-g`, observed `g` | Syntax restriction not demonstrated; later quantity rejection is not a substitute |
| `import/position_independent` | Reject the late `import` token | Filesystem `ENOENT` for `/late` | Import processing occurs instead of the expected syntax rejection |
| `check/axiom_runtime_capture` | Reject live use of unfilled law `magic` | `1 TODO found` | Aggregate incompleteness check does not validate the intended live-use rule |
| `check/error_window_rewrite_proof` | Observed equality type, with rewrite binders in context | Observed `e`, with a smaller context | Elaboration, error selection, or rendering may differ; the report cannot distinguish them |
| `check/array_element_data` | Expected a term, observed `':'`, at line 9 | `line 0:0: expected term; got <eof>` | Lost or replaced failure information; not established as merely a missing span |

The 15 explicitly classified phase/rule differences comprise 14 cases that
reach checker errors despite syntax/flattening expectations:
`check/erased_match_numeric`, `comptime/err_untyped`,
`flatten/statement_beta`, `flatten/statement_lam_absorb`,
`parse/array_length_power`, `parse/invalid_assign_target`,
`parse/law_fill_arrow`, `parse/prefix_operator_dead`, and
`spec/comp_{erased_args,generic_dedupe,generic_mint,instantiation_error,late_param}`
plus `spec/mint_count`; the remaining case is
`import/position_independent`. This is a conservative identified subset, not a
claim that the other 186 cases have equivalent rejection rules.

Five of the six filesystem errors concern the same missing-file situation as
the expected output, but expose a host `lstat` error for a directory instead of
the language's full requested-file diagnostic. They do not exercise the import
behavior suggested by their fixture names. They remain in the unproven group.

`io/main_foreign` and `reg/array_open_element` accept in check-only mode, then
reject with the exact expected message and exit status in interpreter, JS, and
native lanes. These are compiler-entry/layout restrictions, so these two
check-lane mismatches do not demonstrate invalid proof acceptance.

The other 375 failed negative check probes reject, but rejection alone does not
validate the intended rule. Aggregate guards, generic template errors, an
unrelated syntax failure, or an environmental missing file can hide a missing
specific check. The audit finds no additional negative fixture that proceeds
to execution through all recorded gates; it does not prove soundness or full
negative compatibility. Accurate release wording is: **the recorded positive CPU probes
pass, while negative compatibility still includes diagnostic rendering,
rejection-phase/rule differences, and unproven intended-rule coverage.**
