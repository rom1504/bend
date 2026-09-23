# P6-004 — Parser-owned source provenance

Owner: phase6_diagnostics. Started 2026-09-23 during the 05:06–15:06 UTC campaign.
Baseline `a6459af`; campaign design `2815fa1`. All candidates stay under
`selfhost/build/phase6/campaign/diagnostics`; no default image is replaced here.

## Hypothesis and constraints

Preserving parser-owned occurrence locations through lowering can repair a
bounded subset of 150 existing strict check failures whose entire message and
location heading already match pinned TypeScript. Exact structural matching
of canonical literals is insufficient: a generated equal literal elsewhere
can falsely acquire another occurrence's location. Reusing semantic `id` or
`removed` fields is forbidden. The prior per-application reconstruction repeated
parsing and was rejected as quadratic; no new source reparsing is proposed.

Correctness means exact diagnostics where claimed, unchanged acceptance and
first-error selection, correct module/source ownership, and no loss of prior
exact diagnostics. All 150 are candidates, not promised repairs. Keep unknown
origins unknown. No diagnostic failure may change authoritative checking.

## Independent first increment: multiline quoted words

`f_scan_quote` accepts physical newline characters, but `f_lex_scanned` advances
only its column. A small isolated lexer patch consumes the already scanned word
once to advance both line and column before lexing the suffix. Ordinary word
scanning retains its old path. Escaped `\\n` is not a physical newline; escaped
physical newlines still advance the cursor. This is linear in quoted word size,
not reparsing. Initial source changes only `front/lexer.bend`.

Gate: checked equality-profile B1, ten custom fixtures in both parse/check lanes:
retained counterexample, valid neighbor, multiple newlines, escaped newline,
non-BMP text, escaped physical newline, same-line suffix, next declaration,
newline character literal, and competing later error. Preserve all observations;
strict diagnostic differences remain differences. Add direct token-position
controls and unchanged default 21-case gate before promotion recommendation.
CPU2, 4 MiB stack / 4 GiB heap; 600-second outer cap and maintained per-phase
bounds. No performance claim from correctness-run wall times.

Registration correction: the first write of this file used the wrong working
directory and failed, while the following shell command launched the lexer
checked build. This file is therefore a contemporaneous written plan, not a
claim that its bytes were frozen before that first launch. The campaign design
and parent authorization preceded all source edits. Retain the original attempt.

## Broader representation proposal

An independent `KOrigin` sum type (`KNoOrigin`, `KSourceOrigin{source,line,column}`)
and final `origin: KOrigin` field on `KTerm` would make occurrence identity
explicit. Source is immutable and shared; coordinates are lexer-owned codepoint
line/column, converted to UTF-16 offset only for the selected rejection. The
origin is not a semantic child and is ignored by exact semantic equality,
normalization keys, freshness bounds, ownership, and emitted program selection.
Generated nodes start without origin. Rebuilds preserve a node's own origin;
substitution inserts the replacement's origin, while beta reduction must not
assign the old application origin to its argument-derived result.

Parser tokens would carry shared source ownership, and the parser attaches each
actual syntactic occurrence's anchor before scope/freshening. Wrappers inherit a
source anchor only when upstream does so. Scope qualification preserves origins;
alpha-renaming changes identifiers while preserving occurrence origin. Pattern
lowering must explicitly map binder/matcher origins rather than guess from the
first child. Diagnostic selection takes the deepest traced origin and preserves
existing fallback for absent origins. Cross-module templates are mandatory
controls: source comes from the origin itself, never the diagnostic definition's
module guessed after substitution.

This is an ABI change, so the bounded prototype preserves the existing API,
updates its private host ABI map, and uses fresh compiler-specific Base caches.
There are approximately 40 direct KTerm constructor/pattern sites plus parser,
scoper/freshener, transformation helper, and host boundary changes. Old six-field
host-made terms are not silently treated as new well-formed seven-field terms.
Expected initial cost: one pointer per core node (roughly 8 bytes plus engine
layout effects), one shared location object per located surface occurrence,
and retained source-string sharing; no measured memory/time overhead yet.
A common-path timing/memory gate is required before promotion. Target rejection
speed could improve by removing lexing/tree matching, but no speed is assumed.

Before broad ABI work, root and the prefix agent must agree on integration and
propagation boundaries. Root owns timing windows, promotion, Git and integration.

[Results and evidence](../../implementation/phase6/source-provenance.md).

## Representation refinement before prototype — 2026-09-23T05:19:48.820147+00:00

Root authorizes a 90-minute isolated prototype and requires serialized growth,
allocation and matched accepted-workload cost before promotion. Use the canonical
source **path**, rather than full source text, in `KSourceOrigin{module,line,column}`.
Storing full text per node would repeat the entire module in JSON caches despite
in-memory sharing. The request's FLoadTrace retains the path→source mapping.
A new diagnostic-source entry pairs canonical path with source text, and direct
origin lookup uses that exact path; no structural term match selects new origins.

An explicit `compiler_origin_abi() -> U32` export identifies version1. The private
host chooses the new seven-field KTerm map and new origin constructors only for
that version. Legacy APIs retain their old maps. Host-created new terms explicitly
use KNoOrigin. A source-aware parser entry receives canonical path from host
source discovery and from the Bend loader; the old f_parse entry remains usable
with unknown module identity. No silent old-term shape upgrade is claimed.

## Accepted-workload overhead gate prepared 2026-09-23T05:35:11.563013+00:00

After the v2 corrected diagnostic gate, compare the lexer-only control with
origin-v2 on the unchanged 60,909-byte core component, emitting a checked JS
library. Use one frozen ABI-aware host for both, the same Base/runtime/Node,
fresh processes in ABBA order on CPU2, 4 MiB stack and 4 GiB heap, 90 seconds
per sample and an absolute 06:20 UTC deadline. Root must release an exclusive
window before the measured run. Preparation primes each compiler-specific Base
cache and checks their original six semantic term fields for exact equality;
origin metadata and serialized sizes intentionally differ and are reported.
Both untimed preflights and all four measured outputs must exactly equal the
existing 138,371-byte oracle SHA016a5cedeb7e285adeabdad19388d99d3d9070668c15776ccc10fab8ea7b7186.
The overhead guard is at most5% request and process time in each opposite-order
pair. Failing this guard requires redesign before promotion; passing it is only
a small-workload observation and does not establish whole-source overhead.
Peak RSS, all failed attempts and both cache sizes remain explicit.
