# Word-pattern and selector source review

Independent review by `/root/p110_laws` found no concrete defect in the reviewed
adapters under the checked Phase111 producer/runtime premises. The reviewer
read source, fixtures and receipts, checked hashes, and parsed the admission
script's Python syntax; the reviewer executed no compiler or generated target.

The Word emitter is pinned at
`6a51fea7589656439fd21da25b4492c004ad5440790c52c1d7e9bb36c0b74a27`;
the selector emitter at
`9e24d5480b60d784f45a3af5ef7fc14ff673cbaa4ebaaac484e49451d06ed91b`.
Both exact renamed generic fallbacks and final entry overrides are pinned by
[admit.py](../../selfhost/tools/performance/phase112/word-pattern/admit.py),
whose reviewed SHA-256 is
`b09c34c43253ad6dcec629cdcebc1dca27a721a60c30edda66dbc624b3ff9fcf`.
Its frozen mature source is Phase111 `full-source05/compiler.bend`, SHA-256
`825cb03276c30a944ef1b1e8ed0624531253d2f39a502b0fcbfbfea3f3bb3f44`.

Word recognition accepts only the mature raw U32/F32 matcher shape. It retains
`nw_walk` row order, including specific rows before overlapping prefix defaults.
Runtime04 converts exactly the low32 bits into a 32-cell LSB-first Word; the
shortcut's saved low32 scalar, depth32 mask, and integer bit comparisons match
that representation. Signed zero and NaN payload distinctions here are exact
bit-pattern distinctions, not floating arithmetic or equality claims.

The body transformation preserves mature beta substitution, `nw_restore`, and
remaining-argument application order. It plans every row before emission and
refuses the entire shortcut if any residual Word tail remains used. Three IDs
are reserved for every branch, with Var/Lam/Bind and environment collision
checks; later branch fresh counters advance while row tests keep the same saved
scalar. The consumed scalar is immediate, so removing its old environment
binding requires no heap release. Ordinary `p111_lower` still partitions and
drops other owned values separately in each selected branch. Raw `NWPattern`
markers are not accepted as certificates.

The selector adapter retains the mature bounded closed-body, saturation,
literal-argument, freshness, and sharing guards. Nonliteral arguments retain
ordered let evaluation. It routes the selected ordinary term through existing
structured lowering and otherwise calls the exact original reference lowering.
The adapter does not introduce a new ownership analysis.

Root's completed [Word controls02](../../selfhost/build/phase112/word-controls02.json)
has SHA-256 `a55ce833e630d3a6e25d32f3acb01afafca581e8a677eca058406d3a6cd84553`:
22 recognition records, 74 recorded scalar evaluations, and 21 refusal records.
The checked API is pinned there at
`52de71923978132ac61b05631197199c0f110a382e1f8f8595bc129412cf2571`, using composed
source `efac7e31641c32af5e6baf636ee3216210f7cd574ac9412a6cfb20e7d2975128`.
Additional assertions in the pinned method execute restoration, upper-word
masking, used-bit extraction and overlapping-prefix cases; they are not extra
rows in the 74-record count. Actual-entry whole/residual-tail refusals compare
complete output with the generic fallback. The independent N111 interpreter
models scalar results and ignores sink effects, so these are not native heap
observations.

Root's completed [selector controls02](../../selfhost/build/phase112/selector-core-controls02.json),
SHA-256 `f0a1eb601094c93de0e039329c766743ae7acef73740ad463a2d1e3f9c5ee29c`,
records 23 admission cases and 11 finite semantic comparisons. This review does
not convert those checked-API results into native ownership or performance
claims.

The four frozen [source fixtures](../../selfhost/tools/performance/phase112/word-pattern/fixtures/manifest.json)
cover integer/character boundaries, opposite owned String branch selections
with retained aliases, escaping Word-tail fallback, and explicit F32 raw-bit
patterns. Their source/oracles were reviewed; native execution is a separate
coordinator gate.

The new admission script has not been run by the reviewer. Its `both` profile
compares 4,993 declarations and prepares 14 source-mutation refusals, including
final-hook bypass, tail escape, high-bit mask, freshness, mature sharing/beta,
verifier-entry changes, duplicate hooks, and extra adapter namespace helpers.
It pins all mature declarations rather than claiming a partial dependency
closure for `nw_*`, `nd_*`, and `nbc_*`. Other Phase111/112 lowering, backend and
runtime selections require their own receipts on the same composed source.
Exact source binding and finite controls are not an arbitrary ownership proof
or whole-program semantic proof.

Coordinator command for the reviewed combined source:

```sh
python3 selfhost/tools/performance/phase112/word-pattern/admit.py \
  --source selfhost/build/phase112/word-source02/compiler.bend \
  --profile both --out selfhost/build/phase112/word-admission01
```

Use `--profile selector` for a selector-only composition and a fresh output
directory. Admission writes data receipts and runs no target.
