# Checker-only native Map/String bisection

This preparation keeps bendc's compiler, code generator, native table and memo
policy unchanged. It redirects implementation references in the pinned
`check.bend` module to private copies of the actual Base algorithms. That module
contains parser, type-checker and reporting code; this is not automatically a
type-checking-only timing ablation.

The authenticated bendc commit is
`56edcc65b3527a75838011682c231072d5b46097`. Source dependencies come from
`selfhost/build/phase158/current`. Helper source comes from the matching
**acquisition Base 2.0.34**, 71,530 bytes, SHA256
`c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661`.
The common measured-input Base remains the separate Phase162/phase66
75,064-byte file, SHA256
`99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf`.

## What the checker actually calls

The checked source has one direct `Map.bit` reference and 41 `String.eq`
references. It has **zero direct `Map.get`, `Map.has` or `String.cmp` references**.
That does not imply native map lookup is absent:

- The checker's own `Map.find.go` at lines 760–768 uses `Map.bit` and
  `String.eq`. Its `Map.find` definitions remain unchanged apart from these
  implementation calls.
- Five `Map.set` calls reach Base helpers that call `Map.bit` and `String.cmp`.
- Three `Set.add` calls and one `Set.from_list` call reach that update path.
- Four `Set.has` calls reach native `Map.has`, notably in book validation and
  report closure. Native Map.has performs its own C bit traversal and String
  comparison; redirecting only direct String.eq calls cannot disable it.

bendc's `Natives` table at lines 3845–3862 selects these native names. The C
runtime at `rt/bendrt.h:3444–3541` implements Map.bit by returning the original
key, String.cmp by returning the original strings, and Map.get/has by returning
the original map. The corresponding Base algorithms reconstruct traversed
String prefixes and map paths. Native Map.get duplicates the selected value for
map plus answer and drops the unused default and query key; the copied Bend
`Map.get.leaf` retains its original `+v` contract and complete `(map,value)`
result. We do not replace it with a consumption-changing observer.

## Preparation and independent policies

`tools/prepare-native-lookup.py` uses the memo preparer's byte lexer. It accepts
only the exact pinned checker or its exact authorized six-name memo treatment,
and verifies all other copied module hashes. It computes dependencies on the
pinned Base definitions, finds checker-referenced roots reaching selected native
operations, then clones the complete ordinary helper closure under
`p165portable.*`. Nonselected native U32/Nat/etc. primitives form an explicit
boundary. Nominal types, constructors and type aliases such as `Set()->Data`
retain their original identities.

The original helper declarations, law signatures, erased parameters, quantities
and function bodies are copied with identifier substitutions only. Every block
and checker edit has an exact inverse check; quoted language names, literals,
comments and source layout are preserved. The native recognition table in
`bendc.bend` is untouched. A selected native call cannot remain inside a copied
helper; closure checks fail preparation if that happens.

| Policy | Checker roots redirected | Copied definitions |
| --- | --- | ---: |
| Map portable, String native |Map.bit, Map.set, Set.add, Set.from_list, Set.has|40|
| Map native, String portable |String.eq, Map.set, Set.add, Set.from_list|33|
| Both portable |All six roots above|47|

The String-only policy intentionally leaves native Map.has and its internal C
String comparison active. Conversely, the Map-only policy keeps native
String.cmp/eq. These are independent **primitive replacement** treatments, not
claims that every character comparison has become portable. The combined
treatment closes both categories for the checker while leaving compiler/backend
uses outside the checker unchanged. Unused Map.get copies are supplied in the
Map treatment but may be eliminated by reachability; do not count them as a
measured checker cost.

The runtime's special reference-counted borrowed signature for `String.eq`
(`bendc.bend:14191–14197`) continues to apply only to that native name. Private
helpers receive ordinary inferred borrowing under their unchanged Base source
contracts. In tracing mode that RC-specific override is inactive. All three
prepared primary variants retain the exact 12 memo identifier occurrences and
the native memo/purity policy; no memo rename is combined with this bisection.

## Prepared artifacts

All outputs are private copies; historical sources and existing receipts remain
unchanged. Each directory contains a `source/` tree of the six Bend modules,
`portable.bend` for review and an exact `manifest.json`:

- `selfhost/build/phase165/map-source01/manifest.json`
- `selfhost/build/phase165/string-source01/manifest.json`
- `selfhost/build/phase165/lookup-source01/manifest.json`

The checker sizes are 322,847, 320,347 and 324,945 bytes respectively. The initial
six-module source preparation deliberately does not authenticate additional
source-relative C effect files. The first original acquisition discovered
`rt/hub.c` and `rt/cc.c` were needed. Compose the separate additive support-file
preparation and receipt supplied by the memo lane; do not rewrite the original
preparation receipts or treat the failed emission as a successful baseline.
The additive receipt is `selfhost/build/phase165/source-effects01/report.json`
(SHA256 `b9d38bd86960f454dd309229d1c5f10ab9397adceae09748a7326be238ba854c`),
covering the exact four `rt/{hub,cc}.{c,js}` files for all three variants and the
original/memo trees. No existing Bend file or preparation manifest changed.

The v1 combined acquisition was refused before C emission. The ordinary checker
reported an unfilled `p165portable.String.eq` law in `Str.has`; the preserved
diagnostic is `selfhost/build/phase165/lookup01/emission.stderr`. This is a source
publication error, not a runtime or semantic result. The checker resets ordinary
definitions to bodiless declarations and fills them in publication order, while
the canonical Base has a separate forward-reference exemption. Appending private
helpers after their callers therefore does not produce a legal ordinary module.

`tools/prepare-native-lookup-v2.py` preserves v1 and makes the private transplant
legal without granting Base status or adding `unsafe` annotations. It places
dependency-ordered helpers immediately after `import Base`, before all original
checker definitions, preserving each law immediately before its definition.
Three helper cycles require an additional recorded source transformation:
`String.cmp.fin` is beta-expanded at its call in `String.cmp`, `Map.diff.fin` in
`Map.diff`, and `Map.msb.u.if` in `Map.msb.u`. Each expansion copies the pinned
callee body with explicit typed intermediate bindings; the remaining recursion
is an ordinary self-call. All other helper bodies still use identifier-only
substitution. The original helper definitions remain present, after their
dependencies. The manifest records each original body hash, replacement and
publication position. Preparation rejects any remaining nonself cycle.

The combined v2 source is `selfhost/build/phase165/lookup-source02/source`, with
325,491 checker bytes. Its manifest SHA256 is
`f5040b495a60c358765c68b7141ef2671604fe641b92ddbb34a6970301fa3590`.
The separately authenticated four effect files are recorded in
`selfhost/build/phase165/source-effects02/report.json`, SHA256
`776c2fae8b63ed21b11bfa81e8182a920c6e472642ad60a4795d9be1c2803d20`.
The v2 preparation passed source-only closure and publication audits, but
ordinary checked acquisition rejected the local `hc` scrutinee. Bend permits
matching parameters and fields, rather than locally computed values; preserving
the denotation through a beta-expansion was insufficient to preserve legal
surface syntax. This refusal is retained in
`selfhost/build/phase165/lookup02/emission.stderr`.

The next preparer, `tools/prepare-native-lookup-v3.py`, unfolds in the opposite
direction. Each worker body is unfolded into its cyclic helper's recursive
branch. The helper already owns the needed scrutinees as parameters, and its
new self-call decreases one of them. `String.cmp.fin` matches its `t1/t2`,
`Map.diff.fin` matches `xt/yt`, and `Map.msb.u.if` matches `p`. The original
outer `String.cmp.rec`, `Nat.add(33n, ...)`, and `Nat.add(1n, ...)` operations
remain, including the base cases. The last helper computes the shifted U32 once
in a fresh duplicable binding before matching `p`. No new closures, eager
recursive evaluation, local scrutinees or trust exemptions are introduced.
These three recorded worker unfoldings are part of the treatment; the experiment
is not described as a pure identifier rename.

All three v3 policies retain native memo and have fresh source roots:

| Policy | Source root | Manifest SHA256 |
| --- | --- | --- |
| Combined | `selfhost/build/phase165/lookup-source03/source` | `616a50fc983fd9c3423ccce31d98bc793a0e6682c50ece228d467af6c8187765` |
| Map only | `selfhost/build/phase165/map-source03/source` | `48d2a1b6ad59cb67c901724411943fd2cf3a5ba1f58cae4001b3c6b77e205511` |
| String only | `selfhost/build/phase165/string-source03/source` | `cb029c576e03c1442c511378a4d159c9b2059142d517ab5676da93bc427e983f` |

The separate `selfhost/build/phase165/source-effects03/report.json` authenticates
the four required effect files in each tree (SHA256
`d244bfba7b4bf76c5f64357d773f10946c36c1980bd641562419deeb0f3b95b0`).
Preparation does not claim successful checked acquisition or runtime equivalence.

V3 was also refused during parsing: after destructuring the later `hc`
parameter, matching the earlier `t1/t2` binders was no longer legal in this
frontend (`lookup03/emission.stderr`). V4 keeps the same worker unfolding but
flattens each helper into one top-level match over all original parameters:
`t1 t2 hc`, `xt yt rc`, and `p x2 z`. This changes no call conditions or returned
values and avoids both local and consumed scrutinees. The combined candidate is
`selfhost/build/phase165/lookup-source04/source`, manifest SHA256
`6985205169387e028c27cabfc8dd67fc87aee22ce60f8e5719fdaeb59bf29384`;
the effect receipt is `source-effects04/report.json`, SHA256
`b3784d3a10d217df88163cd0ab9405976256076193e861a4edca2d824e43b634`.
The combined v4 candidate passed ordinary checked C emission in `lookup04`
(11.605 seconds, 4,682,697 emitted bytes, as recorded by the root acquisition
lane). This is the first successful source acquisition; it does not establish
runtime equivalence or speed. The generated helper/call audit is documented in
`native-lookup-code-shape.md`, with reproducible static counts in
`native-lookup-code-shape-v2.json`.

The independent v4 arms are prepared but not acquired by this source lane:
`map-source04/source` (manifest SHA256
`4e6394571ff502989304f097570d98caa70f4493e873b42ad5ea03eecb0af584`)
and `string-source04/source` (manifest SHA256
`cf58771e2df1b2bd0696467e1898af106c4ad9751cfe017ece251ee2a9046f0f`).
Their separate four-file effect receipt is `source-effects04-arms/report.json`,
SHA256 `8463c14c9b972048d9c560c8d9000a56c34a0d1910d75e94ef15eca8afe3e777`.

Example for a fresh combined v4 copy (choose an unused output directory):

```sh
python3 -B experiments/phase165/tools/prepare-native-lookup-v4.py \
  --source-tree selfhost/build/phase165/memo-source01/original \
  --base selfhost/build/phase165/memo-source01/base-acquisition/base.bend \
  --maps portable --strings portable \
  --out selfhost/build/phase165/lookup-source-fresh
```

`--audit-only` computes the closure and inverse checks without writing copies.
Eight in-memory combinations of native/portable map, String and memo policy
passed preparation checks. A literal/comment fixture also verified that only
the executable String.eq reference was renamed. These are source preparation
checks, not source typing, semantic equivalence, target execution or speed.

## Required qualification and attribution gates

First source-check the private closure with the matching acquisition Base.
Inspect the generated C to verify ordinary `Chk.p165portable.*` helper bodies
exist where reachable, checker call sites actually reach them, and selected
native calls do not remain on those private paths. Native Map/String definitions
will still exist for other compiler modules; their global presence is expected.
Also verify unchanged native memo call sites and memory-mode settings.

For semantic controls, preserve complete returned maps/strings as well as the
answer, retained aliases, missing/default lookup cases and shared values. Use
empty/prefix/equal/unequal Unicode Strings; bit positions around 0/32/33 and the
end; empty/leaf/node maps; hits, misses and replacement. Do not use only a lookup
checksum or pointer identity as equivalence. Real checker gates must compare
complete acceptance/error/report outputs on the same source and common measured
Base, including malformed cases; a valid-output example alone is insufficient.

Measure parsing, checking and reporting separately before assigning a whole
`--check-only` change to the checker algorithm. Keep memo and all native memory
policies fixed for the first three comparisons, with balanced serial rounds and
the existing resource guards. A portable slowdown would identify the value of
native implementation support; it would not prove our checker performs the same
algorithmic work or that copying that intrinsic yields the same whole-compiler
gain.
