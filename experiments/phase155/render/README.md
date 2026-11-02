# Phase155 renderer screen: ideas 11–13

These are private Bend experiments, with no selected compiler changes. Root owns
all checked acquisition, native execution and timing. The common manifest is
[`spec.json`](spec.json); the implementation is
[`render.bend`](../../../selfhost/tests/phase155/render.bend). No target was run
while preparing this lane.

| ID | Decision | Actual work tested |
| --- | --- | --- |
| 11 | Prepare a paired screen | Fuse UTF-8 constructor-name traversal with QBE byte-text rendering. |
| 12 | Reject the duplicate mechanism statically | Current native publication already uses bounded pieces and avoids copying a piece to append LF. |
| 13 | Prepare a paired screen | Render each distinct local spelling once per owner, paying fresh cache construction and every lookup. |

All four measured entries take `n: U32` and return `String`. Each repetition
constructs fresh complete output. Controls are 0, 1, 2, 7 and 31. The caller must
consume the complete returned string and compare exact bytes; a length or prefix
comparison is insufficient. Calibration may use another repetition count but
must charge output construction, ownership and final process cleanup. There is
no cache across repetitions or processes.

## 11: fuse name-table construction and rendering

`p155r_fused_old` calls current `p111q_utf8` then `p111q_data`. The new entry
renders the same UTF-8 byte decimals directly while traversing the source string.
It removes the boxed `P111QByte` list, its reverse, the later datum-string list
and flattening. Decimal formatting and final full-string construction remain.

Inputs are every constructor name in the original Phase154 captured compiler
and Map programs: 185 and 150 names, in original order. These are exactly the
strings selected by `p111q_ctor_names` for the `p111_cid_names_N` declarations in
`p111q_tables`. Map's `show_names` list is empty, so that different field is not
used as a convenient zero-work case. [`fixtures.json`](fixtures.json) retains
the complete transported values, original graph fields and source hashes.
Host preparation only extracted and serialized these values.

Each repetition concatenates all definitions from both separate workload
tables. This is a text corpus for comparison, not a single linkable QBE module
(the independent tables reuse symbol names). The current native output cursor
also slices large datum lists. This pure one-string screen therefore does not
establish native streaming-memory parity or a whole-compilation gain.

The independent `p155r_literal_controls() -> Bool` must return true. Its literal
oracles cover empty input, ASCII, two-, three- and four-byte Unicode, embedded
NUL and newline. They complement complete equality with the original renderer.

## 12: avoid repeating an existing optimization

`p134e_next` already emits/releases one private or public function at a time;
data tables advance through `p134e_data_slice` with a 128-item bound. The native
IO path writes the optional newline separately. Phase134's packet-batching
experiment added length scans and string joins and was 1.29% slower than its
same-block parent. Phase101 also rejected naive chunk splicing with sparse
512-byte chunks and excessive memory.

This screen therefore has `status: rejected-static`, without invented old/new
entries. A genuinely different destination-buffer API is not ruled out. It would
need an explicit runtime and ownership experiment; Phase148 shows why using an
Array does not by itself establish cheap native access. We do not add a runtime
primitive or another output protocol for this bounded screen.

## 13: owner-local spelling reuse

`p155r_cached_old` applies current `p111q_local` to every observed local operand.
The new entry builds a small owner-local association list, renders each distinct
name once, then retrieves it for each occurrence. The cache is created and
destroyed independently for every owner and repetition. Exact comparisons,
lookup, cache construction and output concatenation are all included.

Inputs are all `N111Local` occurrences in source traversal order in three
complete retained Lexer-generated scalar segments: `$direct.$native.U32.sub`,
`$p111.k.21850`, and `$direct.$native.U32.mod` (12, 10 and 13 occurrences).
`fixtures.json` pins the original Phase147 fixture and keeps all extracted
occurrences; it does not deduplicate on the host. The fixed spelling oracle
covers special `state`, repeated names, empty names and Unicode.

This is an authentic local-operand kernel, not the complete function renderer,
central Lexer control flow, or a numeric-constant/label cache. Linear search and
ownership can cost more than formatting the short strings. A negative result
is useful; it should not be rescued by omitting cache setup or retaining it
between repetitions.

## Evidence that constrains interpretation

- [Phase101](../../../implementation/phase101/README.md) demonstrates that string
  representation and sparse chunk behavior matter; a traversal-count reduction
  alone is not a speed result.
- [Phase134](../../../implementation/phase134/README.md) already implements
  bounded publication and retains the negative packet-batching experiment.
- [Phase148](../../../implementation/phase148/README.md) found nearly equal full
  and no-render adapter ratios; common rendering did not hide a large analysis
  gain. Late transport alone cost approximately 16.2% in that experiment.
- [Phase154](../../../implementation/phase154/README.md) reports a 13.02%/2.36%
  compiler/Map regional improvement, with substantial ownership and reclamation
  remaining. It does not support extrapolating a renderer micro-result globally.
- [Phase153](../../../implementation/phase153/README.md) attributes 40.99% of
  allocation-call events in one request probe to `String.append` and
  `p144e_body_tail`. These are event counts, not elapsed-time percentages or a
  guarantee that these particular kernels explain that cost.

Source checking, finite exact-output controls, native kernel timing and whole
compiler qualification remain separate gates. None of the first three alone
authorizes integration or establishes a new compiler speed relative to upstream.
