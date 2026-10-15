# Phase98 production-connected proof work

The accepted comparison proof imports exact safe declarations extracted from the
actual D04 compiler and the held-root candidate. Its public equality ranges over
all finite Bend `String` values, including arbitrary character codepoints. It
does not assume ASCII, normalization, a bounded string length, or an opaque
comparison callback.

Current accepted evidence is
[`held-proof-check01/report.json`](../../build/phase98/held-proof-check01/report.json):
all five theorem bodies passed source checking, safe BendTT emission, and the
independent pinned BendTT kernel. The inventory contains no opaque definitions.
The deliberately unequal kernel control was rejected separately.

The [deduplicated catalog](catalog06.json) currently records 16 distinct Phase98
public contracts and 40 support lemmas, rather than adding repeated checks of the
same laws. Together with Phase96 and the explicitly modeled Phase97 ownership
protocol, this is 51 public contracts and 50 supports. The catalog contains 16
accepted closures with 127 checked law instances, but only 56 distinct Phase98
named statements and 58 proof-body variants. Repeated implementations and
inherited dependencies do not become additional laws. See
[the ongoing-source workflow](RUNNING.md) for extraction from the actual compiler
being edited, root-run commands, boundaries and a measured fast-tier budget.

| Public law | Exact subject |
| --- | --- |
| `consuming_equal_specification` | Actual D04 `p88_string_eq` equals recursive structural equality using actual Base `Char.is_eq`. |
| `held_observation_complete` | Actual candidate `p98_eq_observe` returns the exact comparison result and both complete original strings in order. |
| `held_comparison_preserves` | Actual candidate public `p88_string_eq` equals the D04 function for every pair of strings. |

`consuming_equal_invariant` and `held_walk_equal` are support lemmas, not two
additional public contracts. The first includes an arbitrary carried comparison
flag, so a previous mismatch cannot disappear at simultaneous end of input.

[`comparison/prepare-held-exact.py`](comparison/prepare-held-exact.py) authenticates
the baseline/candidate source and exact forward replay, then extracts declaration
bytes without removing `@unsafe` or renaming functions. The only added text is
`import Base`. The accepted source preparation is
[`held-proof-source02/manifest.json`](../../build/phase98/held-proof-source02/manifest.json).
The earlier renamed-walker package is retained but is not this acceptance basis.

Additional accepted packages and the remaining prepared attempt:

- [`dispatch/prepare.py`](dispatch/prepare.py): four full-enum selector laws over
  arbitrary tags and 33 explicitly counted support lemmas. The straight-line
  specification uses the original caller's ordered conditions; exact candidate
  stage bodies are extracted separately. The
  [offline original-condition audit](dispatch/original-condition-audit.json)
  verifies all 33 conditions against the actual pre-change D04 declarations.
  All 37 laws independently passed in
  [`dispatch-proof-check01`](../../build/phase98/dispatch-proof-check01/report.json),
  with no opaque definitions.
- [`comparison/literal.bend`](comparison/literal.bend): initial exact recognizer
  equivalence attempt for empty, `Var`, and a Unicode literal. The initial proof
  failed because its catch-all pattern did not normalize the residual suffix;
  see [`literal-proof-check01`](../../build/phase98/literal-proof-check01/report.json).
  No universal recognizer acceptance is claimed. The untested
  `literal-bits.bend` support draft is not in any accepted closure. The current
  tag candidate avoids numeric patterns, so this work is lower priority.
- [`comparison/held-simple.bend`](comparison/held-simple.bend): legitimate removal
  of the intermediate carrier type, keeping the public Bool equality statement
  byte-identical. The complete-observation helper theorem has no new subject
  after that helper is removed; its retirement is explicit rather than a weaker
  replacement contract. All four laws (two public and two support) independently
  passed in
  [`held-simple-proof-check01`](../../build/phase98/held-simple-proof-check01/report.json).
- [`comparison/tag.bend`](comparison/tag.bend): arbitrary-term/key preservation
  for the exact fused tag helper, composed with the unchanged accepted held
  comparison proof. The reference uses actual `tg` and the original D04
  comparator. All six laws (one new public, one new support, four inherited)
  independently passed in
  [`tag-proof-check01`](../../build/phase98/tag-proof-check01/report.json).
  Exact `KTerm` and `tg` are extracted from the actual compiler, with only the
  leading unsafe annotation removed from the total observer for safe checking.
- The same frozen tag contract and proof also passed for the smaller v4 and
  fallback v5 implementations in
  [`tag-proof-check04`](../../build/phase98/tag-proof-check04/report.json) and
  [`tag-proof-check05`](../../build/phase98/tag-proof-check05/report.json).
  These are implementation instances, not new laws. The v3 value proof passed
  even though its C ownership mechanism failed inspection; v4 passed that
  separate inspection. The [v4 bridge audit](comparison/tag-source04-bridge.json)
  binds the accepted declarations to the full candidate and 1,366 substitutions.
- [`comparison/scalars.bend`](comparison/scalars.bend): two public laws preserve
  the complete `ix` and `qt` results over the exact production datatype. Both
  independently passed in
  [`scalar-proof-check01`](../../build/phase98/scalar-proof-check01/report.json).
  The original projection bodies are reference functions with only their
  declaration names changed; the body identity is authenticated reversibly.
- [`permission/laws.bend`](permission/laws.bend): exact whitelist and
  guard contracts for the real source02 foreign-admission predicate. The
  [preparer](permission/prepare.py) checks its full source replay and actual use.
  All seven laws independently passed in
  [`permission-proof-check01`](../../build/phase98/permission-proof-check01/report.json):
  four new public contracts, one new membership support and two inherited
  comparator laws. Host authentication, unsafe traversal and scoped backend
  routing remain separate obligations. The three guard laws are useful public
  corollaries of the exact contract; distinct declarations do not imply logical
  independence.
- [`permission/bridge.bend`](permission/bridge.bend): one further public law
  preserves the original complete guarded membership expression; one support
  lemma relates the new helper to actual `nb_contains` for arbitrary lists and
  strings. The original declaration keeps its name and recursive calls, with
  only `@unsafe` removed. All nine laws, including the seven inherited laws,
  independently passed in
  [`permission-bridge-check01`](../../build/phase98/permission-bridge-check01/report.json)
  against source02. Its final-composite instance also independently passed in
  [`combined-membership-proof-check01`](../../build/phase98/combined-membership-proof-check01/report.json).
- [`prepare-challenges.py`](prepare-challenges.py): candidate-only snapshots of
  independently selected semantic faults, each with law-free helper admission
  before unchanged-law rejection. It also records the independently chosen
  equivalent codepoint refactor and a support-proof maintenance exercise.
- [Redirect preservation](redirect/README.md): the actual lazy redirect equals
  the original complete worker-list transformation for arbitrary payloads and
  duplicate names. One public law and two supports independently passed in
  [`redirect-proof-check01`](../../build/phase98/redirect-proof-check01/report.json).
  The safe dependency closure includes actual code/text construction helpers;
  its value proof is separate from native ownership and allocation cost.

Three bad held helpers were admitted independently of laws, then rejected by
unchanged proofs. The codepoint refactor was admitted but needed one support
proof repair; its second repair independently passed all original five laws in
[`held-maintenance-check02`](../../build/phase98/held-maintenance-check02/report.json).
The first repair's invalid match order is retained. A frozen proof is a
certificate requiring maintenance, not a classifier that rejects only wrong
edits. The independent fault witnesses and the repaired valid refactor make that
distinction observable.

The repeated-left observation fault escaped the old 1,444-pair finite suite, but
the old suite checks public comparison behavior while this law also constrains
an internal complete observation. The final Bool can remain correct after the
extra fields are discarded. This is additional contract coverage, not evidence
that a public compiler regression escaped the finite suite.

The independent dispatch fault that drops `Efq` was likewise admitted alone and
rejected by the unchanged selector laws in
[`dispatch-formal-check01`](../../build/phase98/dispatch-formal-check01/report.json).
It is reported separately from kernel acceptance of the positive package.

The combined parent source `59b36a1c…` was separately extracted and independently
checked with the unchanged tag closure (six laws) and permission closure (seven)
in [`combined-tag-proof-check01`](../../build/phase98/combined-tag-proof-check01/report.json)
and [`combined-permission-proof-check01`](../../build/phase98/combined-permission-proof-check01/report.json).
These checks use the actual composed helper bodies, including the held comparison
finish dependency. This parent also passes the nine-law membership
bridge closure above. These are additional implementation instances of the same
contracts. After deduplicating inherited comparator laws, the parent-source union
contains thirteen distinct names: eight public contracts and five supports.
The larger catalog also retains the historical carrier and other candidate
packages; it is not a count of contracts on a single compiler source.

The later minimal origin-guard candidate `2a72bbdc…` starts from that parent and
adds a lazy `OField` recursion guard in `noa_below`. It omits the unpromoted
redirect/cache changes. Its fresh actual-source tag and membership extractions
bind that full compiler and preserve the same helper/proof module bytes. Both
independently pass in
[`origin-tag-proof-check01`](../../build/phase98/origin-tag-proof-check01/report.json)
and [`origin-membership-proof-check01`](../../build/phase98/origin-membership-proof-check01/report.json).
The [source-specific account](../../build/phase98/origin-proof-account01.json)
authenticates the accepted source snapshots against their extraction manifests
and the actual compiler. This successor has the same thirteen distinct law names
(eight public, five support); the fifteen instances across its two packages add
no new contract names. Their guarded target occupancy was 1.85 s and 2.36 s.
The origin fix is covered separately by
[`origin-controls01`](../../build/phase98/origin-controls01/report.json): the old
mismatched-root helper raises a stack failure; eleven candidate origins pass;
three complete C products remain exact; and a valid owning root-swap program
declines the borrowed observer route and executes with exact output. These
controls are not a universal origin-termination proof or additional laws. The
comparison/permission laws do not establish native evaluation order or detect
the old eager-conjunction bug.

The original independently selected challenge set remains eight bad changes and
two equivalent controls. Its unchanged finite suites detected five distinct bad
changes; the separate targeted follow-up detected all eight using the previously
frozen distinguishing witnesses. The follow-up does not rewrite the earlier
results. Same-contract comparison faults bad03 and bad05 were caught by both
methods; the observed proof-only bad08 result expands the internal contract, as
explained above. No additional same-contract public regression missed by those
finite tests has been demonstrated. See the
[independent review](../../../implementation/phase98/review.md).

Three later candidate-specific faults are separate from that original set:
tag/name confusion, ignoring the trust flag and omitting `File.close`. Every
helper was admitted alone, then rejected by unchanged laws with a normal semantic
expected/observed mismatch in
[`tag-negative-check04`](../../build/phase98/tag-negative-check04/report.json) and
[`permission-negative-check01`](../../build/phase98/permission-negative-check01/report.json).
These are source-check rejections, not independent kernel rejections. Their
selection occurred before reading the respective new laws/reference, but after
some earlier campaign results were known.

The proof boundary stops at safe Bend value semantics. Generated C, retained
aliases, RC operations, unsafe caller branches, full compiler termination and
whole-compiler correctness require other evidence. Exact complete-value controls
and inspected C are complementary evidence, not consequences of these proofs.

Root runs all targets serially. Preparation scripts only read, authenticate and
write source/receipt data. Failed preparation methods are preserved separately;
they are not semantic negative controls. The implementation account is
[`implementation/phase98/proofs.md`](../../../implementation/phase98/proofs.md).
