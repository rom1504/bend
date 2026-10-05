# Phase 47 completed type-query memo counterfactual

Recorded 2026-10-04. **Prepared diagnostic only; no compiler request executed,
timing collected, maintained compiler edit or promotion by this owner.** Root
owns preparation execution, semantic comparisons, priming and exclusive timing.
This follows the [compiler-cost census proposal](compiler-cost-proposal.md).

The saved [lexer census](../../selfhost/build/phase47/compiler-census01/lexer-library.json)
contains 21,664 outer `j_pure_type` calls and 11,005 repeated exact raw
book/type pairs. Its instrumented `j_library_selected` boundary takes approximately
3.374 seconds of the 7.241-second cold request. The census adds wrappers and
includes normal Base preparation; neither its repeat fraction nor its stage time
predicts the clean memo gain. Previous WNF memo regressions remain relevant.

## Exact hypothesis and scope

Reuse completed Boolean results of `j_pure_type(book, ty)` during one compiler
request, keyed by the exact raw book object and type object. Do not normalize or
structurally hash keys. Each contextual/rebuilt book has its own identity, even
when definitions have the same printable names. Only this outer query is changed;
inner `j_pure_type_check` calls retain active owners, fuel consumption and recursion.

The producer requires these exact checked worker23 identities:

| Input | SHA-256 |
| --- | --- |
| Selected API | `e77c504a9c91d9ae9d43e52f4f4899711eb7a8ebe707ee565348df2708488b4c` |
| Runtime | `4f057842e476d01be5cfa06ad7984fea55ad2537b2fe6e861965a782e8b94c26` |
| Base | `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661` |

The source [outer entry](../../selfhost/src/back/js/jpure.bend) always supplies
`Nil` active owners and fuel 512, returning `j_region_local_ok` of the result.
The selected generated API has the exact body:

```js
function $j_pure_type$(_book_0, _ty_0) {
  return $j_region_local_ok$(run_loop($j_pure_type_check$(_book_0, _ty_0, {$: "Nil"}, 512)));
}
```

Its `j_region_local_ok` immediately returns JS `true` for `Some`, otherwise
`false`. The producer checks both exact function bodies occur once, as well as
the complete API identity. Thus this function returns a completed primitive
Boolean, rather than a pending tail message. The overlay adds no `force`,
`run_loop`, continuation processing or conversion. It delegates misses unchanged
and publishes only `typeof result === 'boolean'`; exceptions and unexpected
non-Boolean results stay uncached. There is no in-progress success entry.

Both true and false can be hits. The outer query exposes no remaining fuel,
so it cannot return an inner shortcut with a different active-owner context or
restore the graph proof's separate admission budget. Keys are private
compiler-owned immutable graphs during normal `inspect`; arbitrary public raw
graphs, getters, mutation hooks and persistent inspectors are outside this
diagnostic domain. That narrow immutability assumption still needs challenge
before any maintained source cache.

## Producer and variants

[compiler-memo-probe.mjs](../../selfhost/tools/performance/phase47/compiler-memo-probe.mjs)
does not invoke the compiler. It verifies the completed checked attempt, pins the
selected API/runtime/Base, checks exact anchors and produces three saved APIs:

- `api-baseline.mjs`: byte-for-byte original selected API, with no overlay.
- `api-memo.mjs`: request-local nested WeakMaps; no hit/miss/stat counters.
- `api-memo-count.mjs`: the same memo plus calls/hits/misses/stored/nonObject/
  nonBoolean/exceptions/saturation counters. Use for attribution, never clean timing.

The cache begins immediately before one `inspect` or Base-priming call and is
discarded in `finally` afterwards. Direct calls outside this interval delegate
to the original helper. At most 40,000 completed pairs are admitted; existing
hits remain available after capacity is reached, and further misses execute
unchanged. The clean variant retains only the entry count needed for this bound.
Weak keys avoid retaining otherwise dead books/types; result values are Booleans.

The successful earlier request supplies its observed source-file inventory,
not a cache-equivalence proof. The producer freezes current bytes for that list,
checks prior hashes where the earlier receipt has them, and requires entry source
and Base membership. Fresh successful requests must report exactly that inventory.
The exact pinned Base declares 90 foreign paths (68 distinct files), including
unused IO helpers. The producer inventories and snapshots all of them and their
relative JavaScript imports conservatively. Every quoted Base import must match
the exact supported line form. Non-Base quoted `import` token text is refused,
including comment/newline separation; this can refuse harmless text too and is
not a replacement parser. Other foreign-bearing sources need an expanded
acquisition inventory. The first lexer source itself has no quoted imports.

Inputs include the selected and checked APIs, runtime, Base, attempt manifest,
bootstrap and derivation reports, all checked frozen compiler source modules,
producer, earlier observation, host compiler configuration, source/foreign files, and
transitive relative JavaScript imports of the driver/producer. The selected
equality-verification helper is included explicitly. Each has a byte copy under
`snapshots/` and original/snapshot identities in `derive.json`. Node binary
identity/version comes from the checked attempt; the runner verifies its hash.
The runner and all three generated APIs also receive exact hashes.

These copies preserve dependency bytes without changing execution paths:
the verified original driver runs so source resolution and Base-cache location
retain their ordinary behavior. Original and snapshot bytes are rechecked before
and after each request. No live source/pin/production tool is rewritten.

## Root commands

Use a fresh output directory and the existing exclusive CPU/heap/RSS/deadline
supervisor. These commands are templates for root; no executions are claimed.

```sh
NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
OUT=selfhost/build/phase47/compiler-memo01
"$NODE" selfhost/tools/performance/phase47/compiler-memo-probe.mjs \
  selfhost/build/phase45/checked-worker23 \
  selfhost/tools/performance/phase37/fixtures-historical/lexer.bend \
  selfhost/build/phase47/compiler-census01/lexer-library.json "$OUT"
```

Prime each API identity independently, serially. New saved API hashes receive
distinct verified driver Base-cache identities. A cold baseline and a primed
memo are not comparable, even if they share Base source bytes.

```sh
"$NODE" --max-old-space-size=1024 "$OUT/run-memo.mjs" baseline prime "$OUT/prime-baseline.json"
"$NODE" --max-old-space-size=1024 "$OUT/run-memo.mjs" memo prime "$OUT/prime-memo.json"
"$NODE" --max-old-space-size=1024 "$OUT/run-memo.mjs" memo-count prime "$OUT/prime-count.json"

"$NODE" --max-old-space-size=1024 "$OUT/run-memo.mjs" baseline check "$OUT/check-baseline01.json"
"$NODE" --max-old-space-size=1024 "$OUT/run-memo.mjs" memo check "$OUT/check-memo01.json" "$OUT/check-baseline01.json"
"$NODE" --max-old-space-size=1024 "$OUT/run-memo.mjs" baseline library "$OUT/library-baseline01.json"
"$NODE" --max-old-space-size=1024 "$OUT/run-memo.mjs" memo library "$OUT/library-memo01.json" "$OUT/library-baseline01.json"
"$NODE" --max-old-space-size=1024 "$OUT/run-memo.mjs" memo-count library "$OUT/library-count01.json" "$OUT/library-baseline01.json"
```

First require stable inputs and exact comparisons for check/library and the
counted library request. The comparison includes the complete returned observation
(status, verdict/diagnostic, phase, checked/trust flags and discovered files),
emitted library byte length and SHA-256, and common derivation/input identities.
The earlier census output hash is
`a288fb4c6a8dd2309c961f1632e3e9e0e51bc3d9237973507b2b3c22b8fb89c2`;
this is a sanity observation, not a substitute for the new baseline comparison.

If these pass, root can alternate clean baseline/memo library requests in fresh
processes, reversing order each round and retaining every report. Give each report
a new path. Compare each memo against a baseline from the same frozen producer.
Do not include `memo-count` in clean timing aggregates. Root chooses the bounded
sample count and deadline; this producer does not schedule a campaign.

## Reports, limits and stopping rules

`run-memo.mjs` records `requestMs`, separate API/driver import and ABI-adapter
times, synchronous public API stage times, output hash/bytes, complete observation,
memo stats when enabled, process max RSS, stable-input status and comparison.
`requestMs` excludes module imports and input verification, but includes ordinary
driver Base handling. The same public-stage proxy runs in all variants. Public
stage times include marshaling and can overlap; do not sum them as exclusive
compiler-pass costs. Process RSS includes imports and identity hashing as well as
compilation; use the supervisor's matched process-tree memory observations too.

Errors from `inspect` are retained observations; thrown exceptions, changed inputs
and comparison failures make the report incomplete and preserve their diagnostic.
The runner executes no generated target and cannot qualify target performance.
Supervisor timeouts retain their separate receipts even if no report was completed.

Stop on changed check/emission observations, non-Boolean memo results, missing
inventory, tail-protocol anchor drift, saturation that invalidates attribution,
unexpected source/host identity changes, or adverse latency/memory tradeoffs.
Low hit count is a useful rejection result; high hit count alone is not success.
API-specific Base priming and module-process isolation are explicit, so no
import-cache mismatch is being presented as a compiler speedup.

A surviving saved-API experiment would justify a separate Bend implementation
with request-owned facts and exact contextual book/type identity. It would still
need budget/recursive-ADT refusal, first diagnostic, same-path source/import
changes, failed-then-corrected requests, restored sources and separate API identity
controls. The broader graph/SCC and Base-checkpoint proposals remain separate.
