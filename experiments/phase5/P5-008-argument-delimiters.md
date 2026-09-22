# P5-008 — Reject semicolons at generic argument boundaries

- Owner: compact_index; independent reviewer: root.
- Started: 2026-09-22 after reviewed P5-006 integration.
- Correctness: hypothesis pending fresh live-reference probes.
- Measurement: none; short CPU1 correctness jobs, Node4MiB stack/4GiB heap.
- Decision: isolated parser-only candidate; production remains unchanged until review.

Pinned `parse_term_args` skips whitespace/comments, optionally consumes commas,
and stops at its matching delimiter. It never consumes semicolon separators.
The port's `f_args_base` uses statement-oriented `f_skip`, which drops semicolons;
only the list delimiter currently has a rejection guard. Thus calls, constructor
fields and family/do arguments can accept syntax rejected by the reference.

Normalize whitespace once in `f_args`, before its special nested-angle `>>`
handling, by reusing the existing `f_do_space` helper. In `f_args_base`, reject
an immediate semicolon for every delimiter before calling `f_expr` (which itself
would otherwise skip it). Preserve the old list diagnostic and generic argument
order/comma behavior. No global change to `f_skip`, expression precedence, body
statements, or typed-array count/depth syntax. The helper's name/location is
transitional; root owns any later shared rename with the do follow-up.

First falsifier: fresh baseline/reference checks for leading, middle, trailing
and post-comma semicolons in calls/constructors/families and typed do headers;
valid whitespace/comma/newline/trailing-comma/nested-angle calls and constructors;
existing lists, body semicolons, and typed arrays. Retain operator-RHS semicolons
as an explicit separate limitation rather than pretending this boundary fix
repairs the full expression grammar. A positive neighbor regression or changed
first error blocks promotion.

Use P5-006's genuine normal checked API/snapshot as baseline and build a new
isolated project with the maintained development workflow. Preserve exact source,
API, runtime, Base, tools, commands and failed attempts. Run selected live TS
checks, prior frontend controls and applicable interpreter/JS execution. No broad
suite or self-reproduction without root scheduling, no fabricated bootstrap,
and no speed claim from concurrent correctness runs.

Outcomes and durable evidence will be recorded in
`implementation/phase5/frontend-arguments.md`. Stop if the change requires a
new parser or speculative global semicolon semantics.

## Retained falsifiers and revised boundary

The fresh baseline accepts13 semicolon spellings that upstream rejects. The
first candidate fixed those but introduced an overacceptance: newline before
combined `>>` is rejected by upstream (operator ambiguity), while moving
whitespace normalization ahead of the special split accepted it. That candidate
is rejected and retained. The second candidate leaves `f_args` entirely unchanged
and normalizes whitespace only inside `f_args_base`; all28 focused oracles and
124 combined regression checks pass.

The local preparation script accidentally changed the new diagnostic word
`arguments` to `argumenspaced` while replacing a token variable name. Root and
owner caught this in the source diff. V2 stays frozen; V3 changes only that
literal and receives a fresh genuine bootstrap and focused/execution gate.
This correction does not relabel the v2 API or its diagnostic bytes.

## Final selected outcome and promotion

V3's genuine checked build passes28 focused checks and16 exact interpreter/JS
observations. The separately frozen V2 grammar artifact passes124 regression
checks. Thirteen invalid acceptances are repaired; nine specific semicolon
messages survive and four family-angle errors still render generically. Exact
TS diagnostics are not claimed. A fresh retained operator-RHS witness remains
an invalid acceptance and is excluded from passing gates.

Root independently approved the final literal-corrected parser, which was copied
to production with a P5-006 original-byte guard. Root owns the later helper rename
and combined-source gate. [frontend-arguments.md](../../implementation/phase5/frontend-arguments.md)
links the exact artifact identities, failed candidates/audit and verified archive.
No speed or full-conformance claim follows this selected promotion.
