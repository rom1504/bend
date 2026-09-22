# P5-009: distinguish do assignment binders from patterns

Started2026-09-22 22:26UTC, after the first integrated checked frontend gate.
Baseline API`a17d909d9c48…`, isolated initial paired witness report
`selfhost/build/phase5/do-followup-baseline/paired.json`.

Pinned`parse_term_do_stmt`uses`parse_bind`for typed`=`and`<-`statements;
ordinary local destructuring uses`parse_patt`. A constructor's bare name is a
legal do binder but requires braces as an ordinary pattern. Our pure do path
creates an unmarked`Local`and later applies ordinary pattern validation.
Two fresh valid witnesses (`False : U32 = 4`, repeated shadowing) are rejected;
the equivalent`<-`witness passes. Ordinary local constructor-name binders still
must reject. These live oracles all passed on the pinned reference.

Candidate: mark only parser-generated pure do`Local`nodes in the otherwise
unused name field, and validate these plain binders without constructor-pattern
lookup. Keep all name/shape rules, existing scoping, affine annotations, local
value evaluation and Let lowering. Erase the marker during normal scoping.
Do not replace Let with lambda application or alter general constructor rules.

Gate before promotion: genuine isolated checked bootstrap; prior36do grammar
controls; constructor-name plain/marked/shadowing binders; outer-scope and
invalid-binder controls; first-error ordering; interpreter and JS exact outputs
for all valid additions. Independent review of the two source changes. Keep
failed speculative fixtures/oracles; new confirmed manifests never rewrite old
observations. Final combined frontend and self-reproduction remain required.
