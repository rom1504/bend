# Phase134 deferred emission and bounded rendering

Experimental Bend overlay; checked hosted API, not native-qualified. Inputs and exact success-result-only
substitutions are authenticated by `success-manifest.json` against selected
Phase131 source `1bc5930e…a6728f9`. No original verifier or runtime is changed.

Compose `plan-v02.bend`, `success.bend`, then `controls-v02.bend`.
The original files retain the first attempt; v02 fixes affine closure quantities
and adds the zero-public control. Root also composes `../native-io.bend`. Overrides:
`P111Emission`, `p111_emit_admitted`, `p118b_emission_chunks`, `p128rawc_same`,
and the nine functions named in `success-manifest.json`. All other declarations
are new. Parent owns native IO and the native request call-site substitution.

Native interface:

- `P134Planned{plan}` denotes the successful internal verification continuation.
  It is not a new independently forge-resistant proof object.
- `p134e_compile_source` has precisely the old `p111_compile_source` arguments;
  it preserves preparation, planning, runtime admission and integrated lowering,
  and bypasses only the pure collector.
- `p134e_begin(plan) -> P134Cursor` prepares the same IDs, region registry,
  signatures, lookup catalogue and tables as the original emitters.
- `p134e_next(cursor) -> P134Done{} | P134Piece{text,legacy_end,next}`.
  Write `text` without an implicit newline, then write `\n` iff `legacy_end`.
  This recreates the original `IO.print` per original chunk, even when that
  original chunk contained an enormous joined private prefix.
- `p134e_collect` restores the old `P111Emission{chunks,error}` interface and
  exact chunk boundaries. `p111_emit_admitted` uses it, preserving the checked
  hosted API. It intentionally materializes complete output; native IO must not
  invoke it.

The cursor contains structured IR, never an already-rendered tail. It emits one
existing private/public function String at a time, one data header, at most 128
data items, one data trailer, or `main`. Thus rendering has a per-function/name
size exception, not an absolute byte bound: an arbitrarily large function or
identifier still creates a correspondingly large piece. The current largest
qualified function is 171,719 serialized bytes. A data table containing hundreds
of thousands of entries does not create one whole table String. No packed-buffer representation is introduced; linked-character
physical cost is still larger than serialized bytes. Native File.write also
creates a transient byte buffer for the current piece.

Private worker entries are reversed structurally before traversal because the
old `p113e_old_private_chunks` / `p112c_private_chunks` accumulated in reverse.
They carry `legacy_end=False` until the first public chunk. An empty public list
emits no legacy workers, matching `p112c_attach([],private)`. New private worker
chunks each retain their own boundary. Capabilities (`p117p`, `p118z`, `p118c`)
are selected by the exact existing conditions and applied in the same order.

This is output streaming only. Whole structured IR, index/signature state,
prepared data and selected worker catalogue remain live. No bounded total-IR,
parallel lowering, incremental reuse or cold-time improvement is claimed.

`p134ec_controls` compares exact lists of original chunks, including all datum
forms, 128-item boundaries, empty tables, raw/static/direct/array/boxed/no-private
routes, private-prefix chunk behavior and error preservation. Synthetic IR is
only rendered, never executed. Root must additionally check real checked
requests, nonempty static pools, original verifier refusals, real worker prefixes,
raw File.write output and bounded live pieces at scale before qualification.


Checked evidence (source02 remains frozen):

- `selfhost/build/phase134/stream-source02/manifest.json`: source
  `a7c3522a563bb4eb58d215b0f614ba4df06ef57bcd98a096c5d56e9e8cafd9d4`.
- `selfhost/build/phase111/p134-stream-api02/report.json`: full source check and
  eleven public exports accepted; guarded acquisition 14.17 seconds, 2.01 GiB
  peak process-tree RSS. This is API acquisition, not native compiler latency.
- `selfhost/build/phase128/p134-stream-finite03/report.json`: all 15 finite
  controls pass. `finite.mjs` is the existing Phase128 transport harness with
  relative path adjusted and this control export's `PASS ` formatting accepted.
- First source check refused an affine accumulator captured by both branches;
  no target ran from that source. The first finite harness rejected the fifteen
  successful rows because it expected a different string format; that negative
  report is retained at `p134-stream-finite02`.

`differential.mjs` consumes the independently frozen Phase131 reference manifest,
checks all input hashes, and compares exact native-reference QBE with checked
Bend output. For the three-request group it also drains the cursor incrementally
and checks every piece and added legacy newline against those bytes. It does
not implement compiler transformations or native IO, and its hosted cursor
counts do not establish native memory improvement.


First real-request differential passed (`stream-differential01/report.json`):

| Checked request | Exact reference bytes | Cursor pieces | Largest piece |
|---|---:|---:|---:|
| lexer | 577,297 | 980 | 41,481 B |
| closures | 99,537 | 616 | 9,137 B |
| Map churn | 1,028,294 | 1,457 | 127,386 B |

Both the pure adapter's complete bytes and the incrementally consumed cursor
matched the qualified native Phase131 products. The 38.55-second guarded test
included two compilations per case and metadata validation; it is correctness
cost, not a controlled compiler-speed measurement. Native IO and full-size
memory behavior remain separate qualification steps.


Historical45 hosted coverage also passed. `hosted-evidence.json` binds the compact
summary; `stream-wrappers03/report.json` authenticates 33 exact outputs retained
from a bounded 240-second campaign and 12 further outputs obtained in 81.36
seconds. The first campaign timed out without a mismatch. An initial resume
correctly refused a changed planner-tool input. The successful resume requires
complete reference02/reference03 payload equality apart from input provenance,
records the planner's explicit metadata rebinding, and rehashes every retained
output before accepting all45 coverage. No completed case was recompiled merely
to recover the timed-out batch. Native candidate reproduction and IO remain the
root qualification lane's separate responsibility.
