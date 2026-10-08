# P68-012 — Reuse local liveness facts across a native let

Registered before production integration or candidate execution. This builds on
P68-009's exact occurrence summary, without adding a type, helper, persistent
cache, new IR or public API. The isolated source proposal changes four existing
functions and adds six lines.

The actual Inline09 sampled profiles still spend 551 ms in occurrence-summary
work for B1 Numeric and 152/174/180 ms for B2 Numeric/Array/Lexer, including index
operations below the collector. These are inclusive sampled unions, not clean
wall time or invocation counts. Repeated caller work is visible in source:
the same let body is summarized for its held environment, again when lowering
the body, and again when sharing the value with that body.

Compute that body's immutable index once. Reuse it for all three decisions.
Preserve the explicit partition for the newly added binder, so an unused binder
still emits its sink. In general cuts and flat worker binds, reuse the already
filtered value environment and enter live lowering directly: every row was
proved live, so the skipped partition could only prepend an empty drop string.
Keep environment order, duplicate rows, all U32 ID bits, malformed Var-as-leaf
semantics, rest-before-value lowering, fresh IDs and error precedence.

First falsifier: actual checked-B1 whole NC_Code equality for atoms, emitted
values, cuts and flat binds, plus finite nonempty/empty/duplicate environments,
unused binders, high IDs and errors. Observation-only wrappers count calls to
the existing summary function and must show actual reductions. Then require
three complete C outputs byte-identical to the qualified same-source baseline.
Only fresh actual B1/B2 requests can establish a speed improvement.

The proposed renderer simplification `String.join(String.lines(s), "\n    ")`
is retained separately as a source-only alternative. It removes seven lines,
but actual B1/B2 String.lines calls non-tail-recursive String.split; there is no
current native split primitive. Its sampled ceiling is only 46 ms B1 Numeric
and 19–27 ms B2. A large-body stack regression is plausible, so this is not
included in the occurrence candidate. Generic marker replacement also remains
unchanged: preserving sequential first occurrence and inserted-marker behavior
requires a separate experiment.
