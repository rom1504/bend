# P5-007: structured constructor and datatype reasons

Hypothesis: three narrow structured-reason corrections can improve the existing
negative diagnostics without changing any acceptance, authoritative checker error
string or first-error order. Owner: direct_calls. Root owns integration.

The current Phase 4 check records contain three unknown-constructor inference
cases with the generic annotation message, one missing datatype `<>` hint, and
two unknown-datatype cases. These are not seventeen separate constructor-rule
failures: seventeen records share the broader cannot-infer first-line cluster.

Proposed isolated changes:

1. During rejection tracing, distinguish an unknown `Ctr` from other
   non-inferrable terms by consulting the existing current-book family lookup.
2. Append the pinned datatype-arguments hint only for a constructor-shaped term
   whose name actually resolves to a datatype.
3. Delegate the existing `infer_adt` failure branch to a structured diagnostic
   helper: retain declared-family arity diagnostics; use message-only unknown
   datatype diagnostics for absent/non-datatype names. Keep its error code.

The constructor-field error in `check/forward_data_table.bend` loses structured
metadata earlier in declaration replay. That separate replay change is deferred.
The nat/list/tuple cases may still have independently missing source locations;
reason improvements are not automatically complete strict conformance fixes.

Cheap gates: live TypeScript/current-B1 witnesses, known constructor inference,
known constructor with wrong goal, declared-family wrong arity, unknown and
filled-definition family names, valid neighbors, and competing earlier errors.
Compare exact raw diagnostics and status/phase; count unchanged authoritative
error strings independently. Never normalize the strict oracle. Only after the
integrated broad gate releases resources will the isolated sources be checked
and the focused differential tests run.

Correctness: the checked isolated candidate passes all 16 local exact paired
observations (12 negative, four positive); sixteen authoritative checker strings
are unchanged. Two of six selected upstream diagnostics now match exactly;
the other four retain the documented independent issues. Zero new exact
differences in this selection. The initial invalid-empty-angle fixture attempt
is preserved separately and supplies no compiler conclusion.

Measurement: not planned. Decision: recommend the reviewed narrow repair;
production promotion and integrated broad coverage remain root decisions.
See [the report](../../implementation/phase5/constructor-diagnostics.md).
