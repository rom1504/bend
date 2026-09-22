# P5-010 — Declaration freshness at the parser boundary

- Owner: direct_calls; independent reviewer pending.
- Started: 2026-09-22, after P5-007; initial investigation timebox 30 minutes.
- Correctness: static analysis only; no candidate or promotion yet.
- Measurement: none planned; concurrent correctness work is not a timing sample.
- Decision: investigate, beginning with local constructor freshness.

## Claim and invariant

Pinned TypeScript checks a constructor name immediately after reading its name,
before its field telescope. It checks both earlier constructors of the current
family and constructors in previously declared families. The Bend frontend
currently collects all constructors and leaves duplicate rejection to the
checker. Detecting the same collision at the declaration boundary should restore
parse/check status and first-error order without changing accepted programs.

Top-level declaration names and constructor names are separate namespaces.
A valid definition may fill an unfilled law. Imported names additionally require
upstream's namespace/alias resolution; an unqualified local parser cannot decide
those collisions from an empty book. Do not replace these rules with a global
string uniqueness scan or move all validation ahead of earlier syntax errors.

First falsifiers: duplicate versus malformed second fields; malformed first
fields versus later duplicate; a constructor and definition sharing a spelling;
valid law fill; duplicate names in distinct imported namespaces. Stop or narrow
scope if the current graph representation cannot preserve order without a
parser/loader redesign.

## Setup and gates

Baseline: first integrated genuine checked B1 at
`selfhost/build/phase5/integration/attempt-01`, API `a17d909d9c48…`.
Current live observations are recorded in
`selfhost/build/phase5/integration/live-comparison-01.json`.
Pinned upstream `.bootstrap/upstream` stays unchanged. Candidate source will be
an isolated snapshot with exact source/runtime/host/Base/tool hashes and a new
genuine bootstrap. CPU3, 4 GiB heap, bounded selected paired validation; no broad
run without root scheduling.

Start with the five local duplicate-constructor fixtures in the current live
comparison, then fresh positive and negative ordering controls. Inspect imported
`duplicate_name`, `shadow_lib`, and `shadow_tmpl_lib` separately before proposing
any graph hook. Capture exact acceptance, phase, checked flag and diagnostics;
formatting differences remain differences. Keep every failed setup and fixture
correction. Source edits require the parent's reviewed scope and later promotion.

## Evidence and next action

Static sources: pinned `parse_fresh`, `parse_def`, and `parse_book` in `bend.ts`;
Bend `f_top_ready`, `f_type_ctors`, `f_type_ctor`, and `f_graph_finish_alias`.
No implementation result is claimed by this preregistration. Add measured gate
reports and durable evidence paths when available.

## Final decision

Promoted only the reviewed local constructor check after an original-hash guard.
The final single-file checked overlay passes the scoped ordering and positive
controls:52paired parse/check observations per variant,14resolved phase differences,
0resolved exact text differences,0new exact differences. Imported collisions and
missing-opening-brace diagnostics remain explicit limitations. Independent static
review: compact_index, scoped GO. No timing claim.

See [the implementation report](../../implementation/phase5/declaration-freshness.md)
and [durable archive](../../implementation/phase5/declaration-freshness-evidence/manifest.json).
The initial mixed-source candidate, invalid import fixtures and failed supplement
launcher are preserved separately from the final exact-source gate.
