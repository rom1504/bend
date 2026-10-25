# Phase140 component and integrated hosted results

The composed experiment reuses real parser/checker states, owner products,
optimization units, successful verifier judgments, registry plans and emitted
text. Two substantive edited programs produce exactly the independent fresh
QBE while the warm hosted requests take **1.91× and 2.60× less time** in the first
ordered screen. This is evidence to proceed to the native experiment, not a
native full-compiler rebuild result or established upstream parity.

The qualified selection remains **Phase137 N3**, source `2620d59a…e4ecf38`.
Source/API checking and finite controls are not a whole-compiler correctness
proof. Reused states are private products of the same fixed producer; forged or
untrusted serialized states are outside these interfaces' contracts.

## Component evidence

All timing observations below are hosted checked Bend. They include each
component's comparison/admission work but do not compose arithmetically into a
whole-request speedup. Guard costs, failed attempts and cache acquisition are
recorded separately.

| Component | Work actually reused | Correctness evidence | Measured result / limit |
| --- | --- | --- | --- |
| [Parser](../../selfhost/tools/performance/phase140/parser/README.md) | Actual top-parser state at an exact unchanged prefix; lexer suffix resumes with original cursor/lookbehind. |20 Bend controls;10 edit-hint controls;9 boundary mutations; multiline/comment/unsafe cases; three real loader graphs and four public error plans equal fresh. | Small reused loads are slower because exact Base-scope comparison exceeds the short prefix saved. No full-source parser speedup yet. |
| [Checker](../../selfhost/tools/performance/phase140/checker/README.md) | Complete successful checker world and seen state before unchanged post-freshening declaration headers. |15 finite predicates; actual edit/revert and prepared-Base requests; balanced-binder and unsafe-header rejection; real specialization-memo omission detected. | Reuses2 or3 source events in the integrated examples. No isolated checker speed claim. Global freshening and current driver finalization remain paid. |
| [Owner annotation/erasure/lowering](../../selfhost/tools/performance/phase140/owner/README.md) | Exact owner products with transitive dirty-body propagation and global/header/static/fresh-counter gates. |18 controls; complete raw lowered structures and complete optimized B QBE equal independent fresh outputs. | Lexer raw stage0.557→0.768s (**38% slower**); Map2.888→0.799s (**3.62× faster**). These are single ordered stage observations. |
| [Verifier](../../selfhost/tools/performance/phase140/verify/README.md) | Prior successful unchanged raw/direct body judgments under exact ordered IDs/signature contexts. |25 controls; changed invalid bodies retain first errors; full opened boundaries and array checks equal original verifiers. Current global/static/namespace checks remain fresh. | Three alternating pairs: geometric isolated speedups4.46× Lexer,6.26× Map. Retained IR, acquisition and later final projection remain costs. |
| Render | Exact emitted-unit payload with bounded complete helper/continuation dependencies and global context admission. |49 original/extended finite controls; whole output equals original fresh renderer on two actual edits. | Lexer0.479→0.238s (2.01×); Map0.738→0.465s (1.59×). Including unchanged fresh preparation yields only1.10×/1.08× in that isolated screen. |
| [Registry](../../selfhost/tools/performance/phase140/render/registry-README.md) | Legal per-pass candidate plans under exact immutable ready/symbol views and continuation dependencies; current registry publication remains original. |21 registry controls, run together with49 render controls; all70 pass, including six-pass bound and negative plans. | No isolated balanced speed claim. Integrated warm hits298/299 Lexer and547/555 Map; hit count alone is not a gain. |

The original final projected verifier is retained. Prior Phase134 exact
inline/range unit reuse is included in the session; the final generic/raw
verification obligation is reused from successful exact inputs, not silently
dropped because a later checker exists.

## Integrated G2 screen

Receipt: `selfhost/build/phase140/session-screen01/report.json`, preserved in
[the evidence archive](evidence/components02/index.json). Checked source:
`ac6fcb969dc749db88a8030dcc166f73828725e5d361aae8d435ec224a81c9cf`
(`session-source03`, API `p140-session-api03`).

Each reported request includes frontend, backend, registry construction,
rendering, full output materialization, hashing and writing the complete QBE
file. Shared authenticated Base acquisition costs0.753s separately. “Cold” means
empty candidate state in the same warmed process, not a cold process or OS.

| Real same-path edit | Original fresh B | Candidate cold B | Candidate warm B | Fresh/warm | Same-candidate cold/warm |
| --- | ---: | ---: | ---: | ---: | ---: |
| Lexer shift13→12 |5.302s|5.087s|2.774s|1.91×|1.83×|
| Map multiplier31→29 |7.187s|6.470s|2.768s|2.60×|2.34×|

Both edited outputs match independent fresh B byte-for-byte; A also matches its
frozen native-reference QBE, and B differs from A. Complete frontend plans match
in both revisions. Parser and checker reuse both occur. Warm output reuse is
973/980 pieces for Lexer and1454/1457 for Map. The7 source-cut controls pass.

The observed complete reductions are47.7% and61.5%. Candidate cold B is4.1% and
10.0% faster than the original in this order, so no cold regression appears in
this screen. Ordering, JIT warmup and allocation make these unsuitable as a
calibrated cold-overhead estimate. No-op times are not substituted for real-edit
times. Do not multiply the isolated component ratios.

This clears the useful-work portion of the planned G2 screening: actual skipped
work, exact edited outputs and substantial complete small-request improvement.
It does **not** establish the full native/compiler-source milestone, steady-state
memory behavior, generated-program performance over the frozen45 suite, a2×/5×
large rebuild or a20-second rebuild. Native integration and qualification remain
separate gates.

## Negative findings retained

- Parser-prefix equality alone was unsound. Five operator edits changed how the
  previous expression parsed. The repaired cache requires an unchanged initial
  declaration token and actual lexer/parser state; old mismatches remain in
  `parser-boundary01`.
- Exact initial-scope comparison costs enough to make small parser reuse slower.
- Owner reuse is not uniformly profitable: Lexer raw lowering regressed despite
 33/45 generic/private owner hits. Map benefited with69/72 hits.
- Removing a real specialization memo entry can still return successful checking
  but change the complete checker state. The independent graph observer detects
  this; the retained checkpoint includes the actual memo.
- Source-check, host-observer schema/path and early fixture failures are retained,
  including their stderr and exact frozen module snapshots. They were not omitted
  from the cost ledger.

## Durable evidence and research cost

[components02](evidence/components02/index.json) maps original paths to713
byte-exact archive members. Its2,491,333 raw bytes compress to412,540 bytes in
[metadata.tar.gz](evidence/components02/metadata.tar.gz). It retains reports,
source manifests, exact source/API/module identities, process receipts, small
methods/modules and failure diagnostics. Large compiler sources, generated APIs,
QBE, executables and runtime objects are identity-only entries, explicitly marked
as excluded. No unrelated historical output payload is copied.

The [cost ledger](evidence/components02/costs.json) contains51 completed guarded
processes totaling471.30 charged seconds, including17 failed guard attempts;
maximum sampled process-tree RSS is2.26GB. Concurrent durations are summed, so
this is neither elapsed research wall time nor model/agent quota. Nested API
seconds are not double-counted. This component snapshot excludes subsequent
native acquisition and validation work.

Seven recorded older module/method identities differ from their current working
paths. Every one is resolved to the exact preserved source-directory/module or
method snapshot inside the archive. The index records both facts rather than
pretending current working files reproduce every earlier attempt. The first
archive's relative-path comparison issue is retained as `components01`; use
`components02`, which compares content identities and supplies exact historical
member mappings.

Reproduce or extend the metadata snapshot with
`selfhost/tools/performance/phase140/archive-v02.py --out FRESH_PHASE140_EVIDENCE_DIR`.
Use `--root` for completed later Phase140 native receipt roots, or
`--no-default-roots` for a small addendum. The original v01 method remains for
traceability. Neither archiver executes compiler targets or changes selection.

## Native runner preflight addendum

[Native preflight evidence](evidence/native-preflight01/index.json) additionally
preserves checked `native-source03`, SHA
`c0a45049c8a4371d270a7fe4de1839fb4ee346db7ec7bf55ab585af367ce5353`,
API `p140-native-api03`, the earlier failed source/API attempts, and all33 passing
runner/framing/source-cut controls (6+20+7). This is independent source checking
of the proposed native runner, not execution of its native image. The ongoing
N3 image acquisition is deliberately absent from this completed checkpoint.

This addendum has188 archived members,206,011 compressed bytes and three
completed API guards totaling24.29s. No recorded input content mismatch remains.
The component and native preflight ledgers are separate; do not add superseded
`components01` again. The archive method itself only reads and hashes metadata
and small source snapshots; it does not launch compiler targets.
