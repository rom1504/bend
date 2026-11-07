# Selected Phase175 composition and maintained integration

Source-only audit at `c1cd409`. No maintained source was edited and no compiler
or native target was run by this audit. A proposal was assembled in memory and
written under `selfhost/build/phase175/integration-proposal01`.

## Decision

The parser-lookahead and report-name changes compose cleanly. Integrate only
their three replacement functions into their existing maintained owners. Keep
the ten small helper implementations and nine forward laws there as well; the
existing declaration-order recipe can reproduce the measured candidate
**byte for byte** without changing the assembler or adding a new compiler
module.

The exact candidate is `selfhost/build/phase175/full-source01/compiler.bend`:

- 3,163,584 bytes;
- SHA-256 `a0e953a84de73aa22403dde7ec2144540197633857a0f7b5b9784f9e66f5ad04`;
- 8,461 declarations, versus 8,442 in the pinned maintained parent;
- three changed original declarations, ten new helper definitions and nine new
  laws; all other original declaration bytes and their relative order are exact.

The laws here are forward type contracts. This audit and the finite tests do
not constitute a BendTT proof of parser or compiler correctness.

## Semantic audit

### Parser lookahead

`f_grow_base` and `f_grow_existing` retain the original precedence function,
parser calls, original/advanced cursors and diagnostic values. They avoid
repeated token extraction and defer irrelevant lookahead work.

For `f_grow_base`, the equivalent decision sequence is:

1. Return the original Error node and cursor unchanged.
2. Dispatch `(` to the original context-call parser.
3. Require either precedence greater than `min` or the original adjacent `<`
   rule.
4. Refuse an adjacent alphabetic `%`/`-` suffix, standalone `>`, or `>>` followed
   by one of the same nine delimiter/end tokens.
5. Otherwise invoke the unchanged binary parser.

`f_grow_existing` preserves the newline continuation test, including the
distinct sign rule which checks adjacency without the alphabetic test. If a
newline is not a continuation, it retains the **original** cursor. Bang calls
still require adjacent `!(` on the same line; indexing retains the original
expression/closing-bracket parser; other cases delegate to `f_grow_base`.

The inspected `FInput` operations are immutable projections/list traversals.
`f_tl` returns its input at EOF and `f_skip` preserves the parse context. The
refactor therefore does not suppress a stateful lexer operation or move a
mutation across an error branch. It changes evaluation work, not the selected
parse action. Existing U32 column arithmetic and boundary behavior remain.

### Ordered report names

`dr_own_names` retains first-occurrence order of non-native names and excludes
the initially supplied `seen` set. `p175rn_walk` skips native rows **before
marking their name**, so a later ordinary definition of the same name remains
eligible. It reuses `p142j_members/member/mark`, the existing collision-safe
index; it does not replace equality with hash equality.

The invariant is that the new index and the old `seen` list represent the same
membership at each suffix. Duplicate initial entries, duplicate source names,
empty names and hash collisions preserve the same ordered result. The existing
Unicode/equality boundary audit is in
[`semantic-report-names.md`](semantic-report-names.md).

This changes the algorithmic membership cost from repeated linear list scans
toward indexed lookup. It does not change proof-dependency traversal, checking,
unsafe admission or report contents.

### Composition and retained evidence

The parser and report changes have disjoint definition replacements and helper
names. The report consumes the same checked book produced by the parser;
neither transformation changes backend optimization policy or runtime ABI.
Failed/neutral experiments—precedence rewrite, parser publication and semantic
field erasure—are absent from the selected source.

Existing evidence, not rerun here:

- `lookahead-values01/report.json`: complete parser observations including
  38 expression cases, three boundary cases, unchanged precedence observations,
  and complete finite frontend values on fourteen fixtures.
- `report-values01/report.json`: fifteen literal name-list cases, including
  native ordering, initial membership, Unicode and a known hash collision;
  fourteen frontend fixtures.
- `combined-values01/report.json`: complete parse/request values on three
  coverage fixtures, plus the unchanged ordinary request oracle. This combined
  stage run explicitly **does not rerun** the specialized parser/report control
  campaigns; its scope should not be overstated.
- `combined-full-pair01/report.json`: two balanced native rounds on the same
  Phase170 compiler input; frontend median **62.854 → 56.219 s**, ratio
  **0.89444**. Complete fresh-process median **71.320 → 64.684 s**. The frontend
  clock excludes the separately observed structural digest. These are not full
  source-to-executable self-build times, and a digest is not the independent
  semantic oracle.

Full selected-source checking and native image qualification remain the
parent's current gates. Assembly equality alone does not qualify an image.

## Exact maintained locations and complexity

| Maintained file | Changes | Source growth |
| --- | --- | --- |
| `selfhost/src/front/parser.bend` | Replace `f_grow_base` and `f_grow_existing`; own eight `p175p_*` helpers and their laws | +1,609 bytes; 916 → 1,003 lines |
| `selfhost/src/driver/report.bend` | Replace `dr_own_names`; own `p175rn_name`, `p175rn_walk` and the latter's law | +566 bytes; 181 → 192 lines |
| `selfhost/src/compiler.json` | Add nineteen declaration identities at the already measured positions | No policy/profile/protection changes |

No new runtime, IR, cache format, parser state or semantic datatype is added.
The helper count is ten, not nineteen algorithms. Keeping the current names
and exact declaration bytes for integration avoids making renaming or
formatting a second qualification variable.

The recipe already schedules each `(module, kind, name)` independently. A law
and its implementation must share one module owner, but may be far apart in
the assembled source. This permits readable ownership without moving the
measured declarations in the compiler image.

The nine laws keep these exact measured positions:

| Law | Before |
| --- | --- |
| `p175p_grow_word` | `f_grow_base` |
| `p175p_grow_newline`, `p175p_grow_suffix` | `f_grow_existing` |
| `p175rn_walk` | `dr_own_names` |
| `p175p_grow_operator` | `p175p_grow_word` |
| `p175p_grow_sign`, `p175p_grow_shift` | `p175p_grow_operator` |
| `p175p_shift_end` | `p175p_grow_shift` |
| `p175p_grow_bang` | `p175p_grow_suffix` |

Helper definitions remain globally appended in the same order as
`full-prepare.py`. The integration script preserves existing local module
order, rather than regrouping every module by global order. The latter would
cause an unnecessary lexer-file reorder; the prepared proposal avoids it.

## Reproducible integration procedure

`selfhost/tests/phase175/integrate-selected.py` is source transport only. It
authenticates the pinned parent and selected source, requires precisely the
three replacements and nineteen additions, and exercises the real maintained
assembler against proposed bytes before any maintained write.

The completed default invocation was:

```text
python3 selfhost/tests/phase175/integrate-selected.py \
  --out selfhost/build/phase175/integration-proposal01
```

Its `report.json` records `applied: false`, exact QBE candidate identity, all 112
protected declarations, three proposed files and exact assembly under all five
existing entry profiles. Proposed module/recipe files are under `files/`.

After the parent accepts the outstanding native gates, integration is an
explicit second invocation with a fresh output directory and `--apply`. It
rechecks every maintained input, stages the exact proposal, atomically replaces
each of the three files and checks QBE assembly equality again. Individual
files are atomic; the three-file operation is not a transactional repository
commit. No concurrent maintained-source writer should run during application.

All `profiles`, protected contracts, module ownership inventory and original
relative declaration order remain unchanged. The new order and an explicit
inventory-change receipt are the only recipe metadata changes. The script does
not alter `frozenSource` or claim qualification; updating release selection and
qualification metadata remains a separate parent decision.

## JS/C preservation and economical gates

Both changes belong to the shared frontend/report implementation. JS, native C
and QBE therefore receive the same semantics; they are not QBE-only overlays.
The existing `p142j_*` index helpers are already present in every source profile.
No new foreign dependency or backend API is introduced.

The proposal verifies exact assembly for `qbe`, `native-c`, `js-api`,
`qbe-policy` and `qbe-policy-test` against the selected declaration bytes with
their **unchanged** main replacement/omission rules. This verifies source
transport, not JS/C execution performance.

Do not repeat a broad benchmark merely because files moved. Exact QBE source
identity lets the already-running native qualification apply to the maintained
assembly. Retain the focused frontend/diagnostic controls, compare generated
outputs on a small shared target set, and preserve the installed compiler until
those normal promotion gates pass. No generated-program runtime gain is
expected from these edits; unchanged generated output is the strongest useful
regression check when available.
