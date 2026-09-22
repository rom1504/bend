# P5-006 — Constructor adjacency and term growth

- Owner: compact_index; reviewer: root.
- Started: 2026-09-22, after P5-001 source integration.
- Correctness: investigation; retained P5-001 counterexamples, fresh baseline pending.
- Measurement: none; CPU1 short correctness probes only after the combined sweep releases it, Node 4 MiB stack / 4 GiB heap.
- Decision: investigate a parser-only overlay; no production edit or promotion yet.

## Claim and invariant

Pinned `bend2/bend.ts:1822` recognizes a constructor brace immediately after the raw name, without skipping whitespace. `parse_term_ops` never grows an arbitrary reference into a constructor. The port instead recognizes `{` in `f_grow_base` after any Ref, even when separated by spaces or parentheses. This consumes the next independent parallel value as constructor fields and can reject valid programs before the shared binder rules run.

Move this recognition to the raw identifier atom: the next token must be `{`, on the same line and at column `name column + name length`. Token columns and this length both count scanned identifier characters; no source-position decoding or term-name heuristic is needed. Numeric atoms remain literals. Preserve constructor arguments, metadata, original error propagation, calls, family angles, and source-order evaluation. Remove brace suffix growth rather than adding a positional test to already-parenthesized terms.

Cheapest disproof: a genuine adjacent constructor changes, a spaced/newline/comment-separated name becomes a constructor, or a parenthesized reference still grows a brace. Also test whitespace calls, namespace names, nested family angles, constructor patterns, and multiple parallel values with simultaneous outer scope. The retained invalid-first-binder case must reach the same intended rule as upstream; matching rejection alone is insufficient.

## Bounded setup

Freeze a new checked overlay from the first integrated Phase5 source once its build is available; record actual checked report, source/API, canonical Base, runtime, host, harness and fixture hashes. Compare live pinned TypeScript with baseline and candidate using the existing paired harness and genuine overlay adapter, never fabricated bootstrap metadata. Preserve original P5-001 fixtures and failed attempts. Fresh fixtures live in `selfhost/tests/frontend/phase5-adjacency/`.

First run check acceptance/phase and intended-rule assertions; execute legal parallel/single-local/constructor controls in interpreter and JavaScript. Re-run earlier frontend witnesses before promotion. Selected gates do not establish full conformance, native correctness or self-reproduction. Root schedules any broad gate.

Generic argument semicolon skipping is a separate controlled follow-up: upstream `parse_term_args` skips only whitespace/comments, whereas `f_args_base` calls semicolon-dropping `f_skip`. Do not change global `f_skip` or sugar in this first adjacency candidate. Shared newline-only helper ownership must be agreed before that follow-up.

## Evidence and decision

Pending fresh probes. Results belong in `implementation/phase5/frontend-adjacency.md`; preserve all observed mismatches and exact diagnostics separately from acceptance/phase verdicts. No performance claim is planned.

## Selected result

The genuine maintained-workflow candidate passes110 selected observations:
96 paired check acceptance/phase oracles and14 exact interpreter/JS results.
Five baseline acceptance gaps and the intended first-binder error are repaired.
Root reviewed the parser-only diff and requested qualified/Unicode controls;
those pass, including non-BMP text before the constructor and explicit rejection
of unsupported Unicode names. Forty-six exact diagnostic differences remain
across the96 checks. No timing or full-conformance claim follows.

Initial invalid positive fixtures, the failed metadata-oracle correction, and
an unannotated constructor inference control are retained separately. See
[frontend-adjacency.md](../../implementation/phase5/frontend-adjacency.md) and its
verified archive for exact attempts, source/API identities and selected audit.
Root approved the final candidate and its exact parser was promoted with an
original-byte guard after archive verification. Generic argument delimiters
belong to P5-008.
