# Remaining parser semantic gaps: bounded analysis

Status at2026-09-23 02:51UTC: source review and bounded isolated erased-name
gate complete. The candidate remains unpromoted. Production/default artifacts
remain frozen. This is a proposed next-phase experiment, not a Phase5 promotion.
No performance claim is intended; CPU1 correctness overlaps broad validation.

## Actual retained observations

The final05 B1 and live pinned-reference reports already establish these six
parse/check observations; no new execution was needed to rediscover them:

| Fixture | Final B1 | Pinned TypeScript |
| --- | --- | --- |
| `comptime/err_plus_term` | Rejects parsing, unchecked | Parse accepts; checking rejects unbound `y^-1`, checked |
| `parse/plus_binder_term` | Rejects parsing, unchecked | Parse accepts; checking rejects unbound `x^-1`, checked |
| `parse/prefix_operator_dead` | Parse accepts; checking rejects undefined name `5` | Both lanes reject parsing, expected a name at `5` |

All three remain invalid programs at the final check boundary. These are two
premature parse rejections and one false parse acceptance/late check rejection,
not three accepted ill-typed programs. Their exact diagnostics and checked flags
also differ. Inputs are the unchanged pinned fixtures under commit
`6018e28ecc67cf1fffc0c20c64b11023474c2df8`. Final05 API is
`5969c53d34a088bc9630eb2c065c2eea7fd260294cf3fefb14dffb305b7e4667`.

## Marked names: a deliberate unbound variable, not an operator

Pinned `parse_term_base` parses the operand of prefix `+` at precedence12.
For a raw Var naming no datatype it returns `Var(name,-1,span)`; `term_higher`
explicitly preserves negative-index Vars. Thus the marker does not refer to the
lexically bound variable even when its spelling matches. It can instead be
consumed by pattern/binder construction (`parse_bind`) to create a reusable
binder. In an ordinary value position the checker must encounter an unbound
variable. Quantified datatypes are a separate checked parser branch.

The port parses a Ref with quantity2. Pattern conversion already consumes that
mark correctly for binders, but value scoping's first `f_scope_reference` branch
returns Error for every marked non-ADT name. This guard precedes and is separate
from P5-013's late unresolved `.operator` check. Removing the P5-013 check would
not fix these cases and would regress its operator repairs. Dropping the earlier
guard would also be wrong: the following bound-name branch would resolve `+x`
to ordinary `x` and could accept the invalid program.

A sound small experiment needs a private intermediate unbound-reference node,
not arbitrary core-ID arithmetic. Introduce it only after binder/pattern handling
has distinguished a value occurrence; a conservative first scope is a marked
non-ADT Ref with an actual local binding. Flattening must preserve the marker
without substitution/capture. The existing global freshener could replace each
marker with a fresh Var ID and increment its counter **without installing any
binder mapping**. No marker may reach checking/emission. Both existing locals
and subsequently allocated binders then have different IDs. A full extension to
unbound/global/qualified names must separately match `parse_var`/`parse_reso`:
upstream raw Ref and Var are not interchangeable, especially through imports.

This is a proposal, not an implemented patch. Required falsifiers: repeated and
nested shadowing, marked lambda/local/do/parallel binders, templates, rewrite and
match flattening, quantified ADTs and a local with the same name as an ADT,
qualified globals and aliases, earlier syntax/type errors, seeded/unseeded graph
identity, and marker elimination. Check that accepted controls retain exact raw
core graphs and execution. A freshly allocated unbound ID alone does not reproduce
upstream's printed `^-1`; diagnostic presentation is a distinct requirement.
Do not claim exact checker output until it is measured.

Rejected shortcuts: `U32_MAX` as `-1` feeds `norm_max_walk`, whose callers use
maximum+1, so it can wrap the fresh-ID bound. Zero is not proven reserved through
pre-freshening generated binders. Reusing the lexical binding wrongly accepts
programs. A new permanent core tag or global signed-ID migration is outside this
bounded repair. No new core ABI is proposed.

## Erased names: validate before constructing a Ref

Pinned `parse_body` consumes leading `-`, then immediately invokes `parse_name`;
its erased branch later requires `=` rather than permitting a reply. The port's
`f_body_at` delegates to `f_erased_local`, which blindly takes `f_tx(ts)` as a Ref
name and sends the result to general `f_statement`. `-5` therefore becomes an
undefined reference named `5` instead of a parser failure. The existing later
binder validator is bypassed because this is returned as a reply.

The isolated [patch](erased-name-candidate.patch) adds a name guard at this exact
boundary, after `f_space` (newlines only, preserving semicolon rejection).
Valid names use the original statement continuation. Non-name tokens use the
existing source-aware expected-name renderer. The change is deliberately a name
boundary repair, not a replacement statement parser. The separate lone `-x`
mandatory-`=` rule and erased parallel-let edge cases remain to investigate.
Reserved/trailing-dot cursor formatting is not assumed exact: upstream consumes
the lexeme before those errors; the present candidate is tested for phase and
reports exact text differences honestly.

Preregistered [plan](../../design/phase6/semantic-gaps.md), preserved preparation,
source hashes and fresh genuine bootstrap are under
`selfhost/build/phase6/erased-name/`. The selection contains13 new fixtures plus
the actual pinned prefix fixture, each in parse/check lanes. Positive controls
include ordinary, erased, annotated and newline/comment-separated erased locals
inside a separately declared law body. Negatives cover number, string, brace,
semicolon, EOF, keyword, trailing dot and a bad name before another malformed
body. Original source/API and patch hashes are recorded before the build.
No canonical compiler file or default API is edited.

## Missing imports: host phase plus a distinct first-error boundary

The five remaining import fixtures account for10 additional phase observations.
Normal `inspectWithMemo` initializes phase to load; discovery calls realpath/read
before advancing to parse. Missing imported files therefore surface native ENOENT
messages (sometimes naming a missing parent directory). The reference adapter
starts at parse, and upstream `book_load` explicitly throws a structured
`no such file: requested-path` error carrying the import's source span.
This is not a parser acceptance change: both reject, unchecked.

A targeted host classification fix must distinguish an actual missing imported
module from missing main/Base/cache/API files, permissions, symlink/path errors
and module-name collisions. It should not globally relabel every load exception.
Exact source output additionally needs a preserved import token position: current
Import nodes carry id0 and discard this provenance. Reconstructing a line by
searching arbitrary text would repeat the source-attribution mistakes already
seen in Phase5.

There is also a real ordering issue beyond the phase label. The port parses the
whole importing file before recursively discovering imports; upstream processes
header imports before parsing the remainder. A missing import followed by a
later syntax error can therefore choose different first errors. A future fix
must explicitly decide whether it repairs just classification or separates
header discovery with retained parser-owned import positions. Neither a broad
catch nor a reference-adapter relabeling proves loader equivalence.

## Decision

Keep the +name mechanism as a documented representation experiment until its
noncapture/ID and rendering contracts are tested. Evaluate the erased-name
micro-patch independently, preserving even a passing gate as isolated evidence.
Do not reopen the frozen Phase5 source or relabel these proposed fixes as part
of its completed proof. Fresh combined checking/conformance/proof obligations
belong to any later authorized integration.


## Isolated gate completed — 02:46 UTC

The genuine maintained bootstrap succeeds with candidate API
`c23671a37f49dcbc45eee57269f816e39529712baf59bd67529f103e1e3b4617`,
assembled source
`ab0c1a175802295c8a69d3bee7ab22742db19edbf25539cdad16fba76cb14684`.
The file-only audit verifies all59 emitted-snapshot module identities and confirms
that only `front/sugar.bend` differs from final05. Production sugar still matches
its recorded pre-experiment bytes. No default artifact was updated.

| Same corrected14 fixtures, both lanes | Final05 baseline | Isolated candidate |
| --- | ---: | ---: |
| Observations |28|28|
| Agreement on acceptance/phase/checked classification |16|28|
| Exact complete observations |6|20|
| Exact residuals |22|8|

All28 live TypeScript observations are unchanged between runs. Fourteen
observations become exact; no formerly exact observation is lost. All five
positive programs pass parse/check and agree exactly, including the two
newline/comment-separated erased locals the baseline incorrectly rejected.
The original `parse/prefix_operator_dead.bend` passes both lanes with the exact
pinned diagnostic. The numeric-head-before-later-bad-body control now also
matches the earlier expected-name error. This gate does **not** execute generated
programs or establish broad/frontend/fixed-point equivalence for the candidate.

The remaining four fixtures each have two text differences: braced head `-Box{}`
(existing missing-`=` selection mismatch, unchanged), EOF location, reserved-name
reason/cursor, and trailing-dot reason/cursor. The latter three change diagnostics
without making them exact; this selected acceptance/phase gate does not hide or
approve those residual presentation choices for production. A follow-up can use
actual name-token-end provenance and a mandatory-assignment parser boundary;
do not filter these fixtures out merely to obtain an exact gate.

The first gate had four mistaken positive fixtures: unannotated local literal7
cannot be inferred by either compiler. Both correctly rejected them. That whole
failed gate and its original fixtures remain unchanged. A fresh `fixtures-v2`
copy annotates the values; the same already checked candidate then passes all
declared oracles. The maintained validation report is `complete:true,pass:true`;
the underlying paired report remains `complete:false` because it additionally
requires exact agreement for all rows. Its `selectedComplete:true` and eight
residual rows must both be retained.

The first two file-auditor attempts mistakenly treated paired `complete` as
coverage completion. Both source versions and assertion failures are retained;
the corrected auditor verifies all expected rows, finished workers, exit statuses,
no changed inputs, selected oracles and exact residuals separately. No compiler,
fixture result or oracle changed to repair that audit assumption.

[The selected audit](erased-name-audit.json) contains actual before/after/reference
observations and report hashes. [The archive](erased-name-evidence/manifest.json)
retains298 historical identities in185 deduplicated objects (2,132,288 compressed
bytes): raw reports, both fixture versions, failed auditor attempts, consumed
small frozen host/harness tools, normal bootstrap metadata and patch. Generated
API/compiler files and cache bytes are omitted; their identities and checked
regeneration prerequisites remain explicit. Restore final05's archived source
and tools, apply the patch in a separate project, then use a fresh normal build.
Historical absolute paths are records, not silently relocated proof identities.

Recorded commands, from `selfhost/`, use Node24.18.0, CPU1 and4GiB heap:

```sh
node --stack-size=4096 --max-old-space-size=4096 tools/development/workflow.mjs run \
  build/phase6/erased-name/config.json build/phase6/erased-name/attempt-01
node --stack-size=4096 --max-old-space-size=4096 tools/development/workflow.mjs validate \
  build/phase6/erased-name/attempt-01 build/phase6/erased-name/fixtures-v2/cases.json \
  build/phase6/erased-name/validation-02
node build/phase6/erased-name/attempt-01/snapshot/tools/conformance/target.mjs \
  build/phase6/erased-name/baseline-v2.json build/phase6/erased-name/baseline-v2
```

Actual launch logs retain `taskset -c1` and external300/120/60-second bounds;
choose new output paths on replay. All compiler jobs ended by02:46:29, within
five minutes of the02:41:38 launch, alongside other correctness work. Elapsed
times are not a speed comparison. The decision remains **isolated evidence;
no promotion**, with the marked-name design still entirely unimplemented.
