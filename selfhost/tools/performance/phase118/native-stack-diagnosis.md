# Native-safe02 catalogue-stack diagnosis

Read-only independent review, 2026-10-21. No compiler, target, benchmark, or
failure reproduction was run by this reviewer. The observations below come
from existing receipts and generated JavaScript. Frozen artifacts were not
changed.

## Observed failure and earlier qualification

`selfhost/build/phase111/p118-native-safe02-full-emit/report.json` records a
completed frontend (255.526437473 s), successful runtime admission, and
`RangeError: Maximum call stack size exceeded` after only 0.966451268 s in the
integrated compiler. The captured stack begins in `nc_foreign` and repeatedly
names `nc_pack_foreign`, API lines 5610/5614. There is no emitted QBE or native
compiler from this attempt. The request contains 6,384 source/book definitions
and 3,239 reached names.

The call path is ordinary shared lowering:

`p111_emit_admitted` → `p113a_lower_request` → `p113d_lower_request` →
`p114s_lower_request` → `p113pl_lower_request` → `p112s_prepare` →
`nc_pack_foreign(book)`.

In `safe-source02/compiler.bend`, the relevant definitions start at lines
40964, 47576, 44735, 48921, 46074, 42319, and 35782 respectively. The failure
therefore precedes the new borrowed-observer/cold-constructor continuation;
this stack does not implicate those runtime semantics.

The qualified Phase114 full acquisition **did** invoke lower, verify, and
render as separate API calls: its saved `staged-emit-method.mjs` lines 203,
227, and 233. But its first call was the same `p113a_lower_request`; it did not
skip static preparation or the foreign scan. Its generated `nc_pack_foreign`
at `p114-final-api02/api.mjs:4790` has the same body as safe02 at line 5603.
Phase114 handled 6,186 definitions / 2,885 reached names. The unsuccessful
float01 attempt had 6,356 / 3,225 and spent 332.238215562 s in its integrated
entry; it passed this early scan, but did not capture its eventual stack.

Thus an existing unbounded host-stack dependency is established. Growth of
the catalogue and available host stack headroom are consistent with the new
failure. The receipts do not isolate a precise numerical stack threshold or
prove whether additional entry frames, host compilation decisions, or the
28-definition increase from float01 caused the threshold crossing.

## Corrected trampoline rule

In safe02's API, `run_tail` (line 117) returns a `$JMP` record; `run_loop`
(line 128) consumes those records iteratively. `nt_choose` (line 380) returns
`run_tail` for its selected closure. Consequently, a recursive call made as a
tail result of such a closure need not retain one host frame per element.
The original verifier walkers `p111v_functions` (8547), `p111v_segments`
(11461), and `p113e_functions` (8130) use this pattern. Phase114 successfully
verified 35,767 segments. `p113i_functions` (5477) instead has an explicit
generated `for (;;)` dispatch loop.

By contrast, `nc_pack_foreign` evaluates its recursive child result and its
recursive sibling result **before** combining Boolean results. At API lines
5612–5615, these are ordinary recursive calls assigned to temporaries, with
no trampoline boundary. Boolean syntax does not establish short-circuiting:
this generated body eagerly visits both child and sibling lists.

This corrects my earlier overly broad warning about recursion through
`nt_choose`, including the DCE `kill_reverse` caution. Inspect generated calls
and continuation placement; do not classify all closure recursion as unsafe.
Eager `nb_contains` Boolean recursion and the recursive `p113i_size` budget
calculation remain separate depth concerns. A size budget is not a host-stack
bound.

## Nearby catalogue walks worth distinguishing

These are source/JavaScript opportunities, not additional observed failures.
Line numbers below refer to safe02's compiler and API respectively. This is
the reviewed catalogue path, not a proof that every recursively called term,
index, or library helper is stack safe.

| Walker | Source / API line | Retained work and narrow remedy |
| --- | --- | --- |
| `nc_pack_foreign` | 35782 / 5603 | Confirmed eager child/sibling Boolean fold; explicit DFS worklist. |
| `nc_bangs_names` | 35818 / 5290 | Recursive suffix must finish before append; accumulate each unchanged per-definition result, preserving order. |
| `nq_signatures` | 34235 / 8309 | Recursive suffix is an argument to `nq_signature_cons`; preserve complete signature/constructor-shape ordering in an accumulator conversion. |
| `p113pl_candidates` | 46039 / 8284 | Retained candidates wait for recursive suffix inside append/Cons; preserve per-name boxed/flat candidate order and existing refusal logic. |
| `no_candidate_names` | 37527 / 5271 | Accepted-name Cons waits for recursive suffix; ordered filter with reverse accumulator. Used only if observer permission reaches that path. |
| `nc_constructors` | 35724 / 3449 | ADT/foreign append or Cons retains suffix work; nonmatching tail branch is trampolined. Preserve constructor order/IDs. |
| `p113k_functions` | 48270 / 5467 | Map constructs Cons after recursive suffix; reverse accumulator preserves exact order. Earlier full qualification had 827 direct functions. |
| `p113a_function_names` | 47758 / 3510 | Eager Boolean conjunction over direct functions; accumulator with unchanged per-function predicate. |

`ns_definitions`, `nr_unshared`, `nh_definitions`, `p112s_defs`, and the
original verifier's catalogue walks must not be added to a failure list merely
because their source uses `nt_choose`. Their next-element calls cross its
trampoline. Nested per-definition computations can still consume stack, and
list-building branches can retain continuations. No broad rewrite is justified
by the current stack alone.

## Independent review of the proposed pack fix

`native-pack-stack.bend:5` copies the exact predicate:
`!db(d) && (Foreign(unann(value)) || (kind == Def && nc_foreign(d)))`.
The worklist at line 10 pushes `dc(d)` before the remaining siblings and prior
pending lists. It does not skip trusted cache/index nodes' children. Each finite
definition occurrence contributes the same Boolean; `found` is their OR.
The old eager traversal and this complete traversal therefore have the same
finite pure result. Reassociation changes neither foreign admission nor the
packed/static representation permission. It also avoids using `found` to stop
visiting the rest of the input.

No concrete semantic defect was found. The eight finite controls independently
state expected results for ordinary, unfilled, annotated, trusted/untrusted,
cache-child, and sibling cases, and additionally compare a frozen old predicate.
The source also provides flat/deep scale checks. This review does not claim any
control passed or that the new helper was compiled to a loop; those require
the root's fresh checked API and receipts. No claim covers infinite/cyclic
host-forged values or all nested compiler traversal depths.

## Reviewed identities

SHA-256, with paths relative to the repository:

| Artifact | SHA-256 |
| --- | --- |
| `selfhost/build/phase111/p118-native-safe02-full-emit/report.json` | `87ecf94799cafe4abe983598f194c89d87c63f857c2d8e5fb6efbd6e6148b8b7` |
| `selfhost/build/phase118/safe-source02/compiler.bend` | `6a6cdc00a5986ceec5415a82cfc803c2a371ff68ecbb9592aec1ca662ac5f6b2` |
| `selfhost/build/phase111/p118-safe-api02/api.mjs` | `5598ca5899b35a791f283ca94e8908b0283a179449b858d09daac1b83f3a64f2` |
| `selfhost/build/phase111/p114-native-final02-full-emit/report.json` | `b72642e24641d89c48e66662488cf90c42bfe29bcb9635d616b5cd85cc3e535b` |
| `selfhost/build/phase111/p114-final-api02/api.mjs` | `e388dde6a3f6a4412f0e0417ba86edd8a7f46f49807a852fdadd20bc599cbe72` |
| `selfhost/build/phase111/p114-native-final02-full-emit/staged-emit-method.mjs` | `48f8840619a5da16eb3416ad80aa774ad7bca4ee7a3616fc3b5ba92d03298193` |
| `selfhost/tools/performance/phase118/native-pack-stack.bend` | `8493ca54b61bc20920b16111c93f82b488590ce6994e28fb7fa433e4ca062b1e` |
