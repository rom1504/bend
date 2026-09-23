# P6-011 — Declared missing imports have a parse-phase failure

Registered 2026-09-23T05:19:54.577917+00:00, before host mutation. Root owns this isolated host-only change.
The [existing design](../../design/phase6/import-phase-boundary.md) supplies scope,
fixtures and explicit limits. Baseline is the current consolidated host/API.

Tag ENOENT only around realpathSync for a recursive declared import, and only
when the same Error has no phase. Preserve all other exceptions, source-file
fields, diagnostic bytes, reads, traversal order and verdicts. Root input and
Base/API preflight failures keep existing behavior. Do not rewrite the source
error or move the entire loading interval to parse. This first change cannot
repair missing-import source excerpts or import-versus-body error precedence.

Before promotion: meaningful host controls for missing root/recursive import,
realpath ENOENT versus EACCES/EIO/ELOOP/ENOTDIR and pretagged error, read failure,
source mutation and valid imports. Use five pinned fixtures in both parse/check
lanes with fresh TS and frozen baseline; require exactly the intended phase
changes with existing text untouched. Keep a competing body/import error witness
as a residual. Use genuine checked/equality build even though source/API should
remain identical, CPU0 with 300-second outer cap. This change expects ten fewer
phase differences, not strict diagnostic passes or measurable speed gain.
