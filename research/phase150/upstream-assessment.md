# Phase150 bounded upstream assessment

**Keep the active upstream pin for the parser experiment; migrate upstream in a
separate qualification cycle.** Upstream contains useful performance ideas and
real compatibility changes, but the inspected changes do not supply a replacement
parser or a general compact String/List representation that would make migration
the prerequisite for this experiment.

This is a source assessment on 2026-11-01, with no compiler/program executions,
production edits, merges or pin changes. The immutable assessed range is
[`059266225b77c8ca256ac6b25ee5c21449bab151` to
`e9d269b588f4ed39166dca87a0acb4d5a9be4f9f`](https://github.com/bendlang/bend/compare/059266225b77c8ca256ac6b25ee5c21449bab151...e9d269b588f4ed39166dca87a0acb4d5a9be4f9f):
246 commits ahead, zero behind, with the active pin as merge base. Three compare
pages supplied the commit index; this was not an audit of all 246 commits.
The compare API returns 300 changed-file entries, so that list is not asserted
to be the full inventory. Actual aggregate frontend/Base/elaborator patches and
12 selected commit patches support the classification below. The compact
[primary-source evidence](upstream-evidence.json) records URLs, immutable SHAs,
selected code excerpts, local boundaries and coverage limits.

## Compatibility work required if the pin moves

“Required” here means required to advertise compatibility with the new upstream
contract. It does not mean the pinned compiler must change before further work.

| Boundary | Actual code change | Consequence for this fork |
| --- | --- | --- |
| Parser/name resolution | `parse_own` selects the current file's qualified declaration/constructor when present. Sugar now uses it for `Empty`, `Exists`, `Array.new/get/set`, `U32`, list/tuple constructors and named operators; `term_write` gains a `Parse` argument. The `do` terminal rejects a stray `=`; several other hunks change diagnostics. | Update the Bend frontend's corresponding resolution rules and negative/source-location oracles. Include imported files that define their own names, aliases and array assignment. This is a semantic/diagnostic compatibility change, not an identified parser speedup. |
| JS constructor identity | `js_tag(k)` strips the loading namespace before `:`. Construction, matches and CID expansion use the same tag. Public definition/effect names keep their namespaces. | Requalify cross-module ADT interchange, foreign wrappers, constructor readback and generated-JS adapters. Old and new generated modules cannot be assumed interchangeable. |
| JS Nat/Char/String host values | Nat host values become numbers instead of BigInt conversion trees. Char preserves any U32 internally: non-scalar codes have a packed JS representation, and text edges replace them with U+FFFD. | Existing primitive adapters and fixtures need explicit version binding. The maintained JS Base shim currently uses BigInt for Nat and has its own Char/text functions. Separately test language values, host arguments/results, text IO and surrogate/non-scalar cases; do not infer agreement from ordinary ASCII programs. |
| Native runtime arguments | Options move inside `+RTS ... -RTS`; native startup also reads `BENDRTS`. Bare `--threads`/`--gpu` become program arguments. | Current maintained request, benchmark, session and qualification commands use the old spelling. A migrated upstream product needs a runtime-version-specific wrapper, or it can silently lose its one-thread/GPU-off controls and receive wrong arguments. Preserve old wrappers for old images. |
| Proof adapter | `safe_check` changes from boolean success to `string \| null`, with **null meaning success**. Kernel infrastructure failures throw separately. `Def` gains law metadata `l`; elaboration of templates, groups, annotations and fallback models changes. | Audit callers and exact verdict/error oracles before using the new elaborator. Rebuild and bind the kernel and elaborator together, then replay positive and negative proof controls. Never reinterpret a truthy error string as success. |
| Base/runtime surface | Base changes include search bodies, numeric corner cases, new `U32.popcount/ctz`, and `@unsafe Array.get_unchecked`. Effect APIs and sources also change. | A Base swap invalidates prepared-Base/carrier identities and adds new intrinsic/refusal obligations. Unsupported APIs must remain explicit. Rebuild all relevant generated/runtime assets rather than mixing a new Base with the old prepared image. |

Primary code: [frontend at assessed head](https://github.com/bendlang/bend/blob/e9d269b588f4ed39166dca87a0acb4d5a9be4f9f/bend2/bend.ts),
[constructor tags](https://github.com/bendlang/bend/commit/34c02a1fc17e6adc2bcde4693fad5e80fb45f9d9),
[Nat host values](https://github.com/bendlang/bend/commit/381dc87799de1117e58087fbfd67b0d12bb20b14),
[Char/text edges](https://github.com/bendlang/bend/commit/7ba0ce7a94fc6c6ccf8eccb71d97115e15a382be),
[runtime argument contract](https://github.com/bendlang/bend/commit/10256a7bd047ece2ca1bfbe50d5813e9287ec8b4),
[elaborator at assessed head](https://github.com/bendlang/bend/blob/e9d269b588f4ed39166dca87a0acb4d5a9be4f9f/bend2/safe.ts),
[Base at assessed head](https://github.com/bendlang/bend/blob/e9d269b588f4ed39166dca87a0acb4d5a9be4f9f/bend2/base.bend).

The complete aggregate `bend.ts` patch is only +99/-40 lines. Its actual checker
optimization short-circuits two quantity `Min` comparisons; it does not replace
the term representation or checker architecture. The parser remains the direct
native-string cursor architecture already available at the old pin. Its earlier
2.583s load observation remains useful motivation for a local experiment, with
the nonmatching intervals documented in the
[Phase145 parser boundary](../phase145/parser-boundary.md).

## Reusable performance ideas

| Priority and idea | Evidence from actual implementation | Transfer condition |
| --- | --- | --- |
| High: stop producing discarded comparison results | `String.order.go(a,b,c)` tail-walks the two strings and returns only `Cmp`. The old `Pair.snd(String.cmp(...))` reconstructed both input strings. `String.cmp` retains its separate returning-input contract. | Useful model for exact parser/name queries: return the decision directly and charge destruction of the unused suffix. Our JS shim already has a direct comparison, and native specialization may eliminate some old work; identify actual executed paths before predicting gains. |
| High: suspend work that a predicate may discard | Final List any/all/find/contains pass the recursive tail in a `Unit -> result` closure and call it only when required. The first search patch was reverted; the later reviewed implementation is the relevant one. Prefix matching now inspects the prefix first, so an empty prefix does not inspect the source tail. | Use exact early admission with preserved errors/evaluation contracts. In Bend, writing an eager Boolean combinator is insufficient. Native closure allocation, suffix release and missed-search cases must be measured. |
| High: avoid scanning or retaining irrelevant emitted text | The latest emission patch scans `c_ids` over runtime placeholders before inserting generated C/effects, skips `ty_srcs` on JS because only C reads those ADTs, and releases file state after a JS module. | This fits our existing explicit runtime assets and fragment rendering. Audit for remaining duplicate scans and long-lived temporary state; work already removed by this fork is not a new gain. |
| Medium: bind memoization to semantic lifetime | The allocation patch keys literal expansion by literal kind/value per file, reuses named memo workers, caches type openness and resets probes per definition. Later code memoizes ground constructor tests and uses data for the type-query predicate. | Retain a fact only while its inputs and identity are stable. Include key construction, ownership, invalidation and teardown in complete request timing. Do not add a global cache from static hit counts. |
| Medium: carry ownership facts at the actual physical lane | The borrowing patch only reads root provenance for boxed lanes; scalar words sharing a slot do not own a reference. Joins collect roots only from boxed alternatives, and reboxing avoids stale provenance. | Potentially relevant to shared parser/IR records, but copying this into our distinct native/QBE runtime is not mechanical. Require local ownership controls and unchanged independent verification. |
| Small: short-circuit quantity comparisons | `compare_go` changes eager `fa`/`fb` calculation to `&&` and `||`, preserving which comparison decides the result. | A narrow measured checker opportunity, not evidence that the whole parse/check region improves by the commit's local benefit. |

Primary patches: [String.order](https://github.com/bendlang/bend/commit/15a336cce776abe1225009e018e7ca7a7c4ba694),
[final List searches](https://github.com/bendlang/bend/commit/e1a7a698e0a34c4e1f2d9ceeaf1fe07ab931b517),
[emission lifetime/work](https://github.com/bendlang/bend/commit/f1273d300840c9b167104985efb71fd08f79126e),
[allocation reduction](https://github.com/bendlang/bend/commit/239d53fd7730346c0cf0ee1698e993c76cb94d93),
[boxed-lane borrowing](https://github.com/bendlang/bend/commit/a5bae35cf4f80f90a493c32998bda7529ffd4226),
[quantity comparisons](https://github.com/bendlang/bend/commit/3c8fb663af8255257c1ee394cc68413c0eb601e1).
Upstream commit timing/allocation claims are not measurements on our compiler;
none is imported into a Phase150 speedup estimate.

## Proof and unrelated scope

The new kernel adequacy theorem says that an accepted book's **closed live kernel
term** with a type convertible to an equality has convertible sides. Its theory
unfolds opaque definitions to their models. This strengthens the stated kernel
theory; it does not prove the TypeScript-to-kernel elaborator, our Bend frontend,
native ownership, C/QBE emission or emitted-machine semantics correct. The kernel
also gains a rigid comparison pass before unfolding, with corresponding soundness
lemmas. Keep kernel acceptance, finite equivalence and runtime execution separate.
[Adequacy code](https://github.com/bendlang/bend/commit/b8664b0a7ff36858b353fdbee77e41a3dd3548db),
[rigid comparison code](https://github.com/bendlang/bend/commit/b9b1582cbb1caad7e32b601219f0b52908b6a944).

The index also contains many formatter/LSP, installer/publishing, graphics/audio,
network/file/channel and GPU/scheduler changes. Those are outside the current
serial parser experiment, though they matter to a later supported-feature
migration. They were classified from metadata rather than exhaustively reviewed.
No GPU, broad effects or full latest-head correctness claim follows from this
bounded assessment.

## Decision and next boundary

Proceed with the Phase150 parser optimization against the existing pin, exact
prepared Base and qualified runtime. The useful upstream architectural lesson is
to avoid constructing/traversing data that the consuming query does not need.
The String comparison, early-search and emission patches reinforce that lesson;
they do not justify changing all source String/List representations at once.
Any local candidate must preserve complete parse products, fresh identity and
origin/error behavior, then demonstrate a net complete-region gain including
conversion, allocation, ownership and teardown on unrelated sources.

A separate migration cycle should first preserve the current baselines and make
an isolated checkout of an explicitly chosen immutable upstream head. Port
frontend semantics and versioned host/runtime adapters; regenerate Base/carrier
and image bindings; then run finite source/error/ABI/proof controls, maintained
JS/C/QBE gates, and justified native reproduction/integration with independent
outputs. New runtime options must be active before comparing clocks. Historical
upstream ratios remain tied to `0592662`; a changed reference requires fresh
matched measurements. The human-written `bend2/bend.ts` is never hand-edited.

Local constraints: [maintained workflow](../../docs/self_hosted/workflow.md),
[current frontier](../../experiments/STEERING.md),
[active native assets](../../selfhost/manifests/assets-native.json),
[request invocation](../../selfhost/tools/build/request.py),
[benchmark invocation](../../selfhost/tools/bench/bench.py).
