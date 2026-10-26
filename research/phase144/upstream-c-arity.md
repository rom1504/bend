# Pinned upstream C acquisition: arity refusal

Read-only source/receipt audit; no new compiler execution. Pinned upstream is
`059266225b77c8ca256ac6b25ee5c21449bab151`; `bend2/comp.ts` SHA256
`2b13224ba09a9e39e37cccf06e449c1bdafe5e03a81641654f7d0e455507629c`.
Failed acquisition:
`selfhost/build/phase102/p144-upstream-source01/report.json`.
Exact source Phase143 integrated-source03:
`a51a4a6d0a32e118ca75eac96fb4e64bae0fcf951b09ee859c2632f65550bd4e`.
Load/check completed in2.557/3.414s; emission refused with `an arity over247`.
The retained max RSS is4,562,680KiB. There is no generated C product or successful
upstream C compiler-runtime comparison.

## Unused test removal is not the missing switch

The public `compile_book(book)` already performs reachability:

- `comp.ts:2768–2778`: roots `main`, runtime ADTs and any pure-main show families.
- `file_book`,1364–1418: follows body references, constructor/type dependencies
  and runtime roots. It does not emit every loaded source definition.
- `compile_book`,2814–2821: closes emitted segment references from main and
  filters segments/spins before the247-word check at2837–2839.

The failure checks two alternatives: any live entry's flattened parameter count
above247, or a constructor size-class encoding above255. Therefore merely
pre-filtering the source's unused controls does not fix a missing root policy.
There is no exported alternative compilation-root API that avoids this check.

The selected compiler's `p111_native_args` also exposes Phase140 batch and pair
session modes as well as the ordinary six-argument request. Those are genuinely
reachable public branches. Dropping them could be a separately described
ordinary-only acquisition experiment, but changes supported command behavior
and must not be presented as faithful dead-test removal or the same executable.
A conservative lexical source scan found no `*controls` function reachable from
main; it is not a substitute for upstream's actual lowered dependency graph.

## Initial hypothesis and the coordinator's decisive observation

`fun_of`1187–1190 boxes multiword ordinary argument layouts when their sum would
exceed WIDE. `seg_open`1555–1566 instead concatenates all live captured values
plus a result into a continuation's parameters. That can exceed247 even when
each source definition has few explicit arguments. The source survey's largest
recognized declared constructor has10 fields; ordinary source arity alone is
not the failing metric. This points strongly toward a live continuation's
flattened captures, but the error records neither `fid` nor defining owner.

The initial exception did not identify an exact culprit. The coordinator then
ran the diagnostic below. Its completed report identifies exactly one oversized
live entry out of21,911: `p140n_compile$k37090`,263 parameter words,208 retained
frame words and55 incoming result words. No constructor encoding overflows.
The entry contains191 boxed,69 U32 and3 U64 words. Evidence is
`selfhost/build/phase144/upstream-arity-plan01/report.json`.

The key unnecessary capture is the old complete `P140SCache` (109 words in the
same report's `p140s_finished` argument layout). `p140n_raw` retains it through
`p140b_session` only to produce the generic rollback result. But its sole native
consumer, `p140n_backend`, terminates with `IO.die` for **every** P111Emission;
that branch never observes the returned cache or statistics. On P134Planned,
the generic finisher always uses the new front/raw/back cache, not the old one.

The isolated `native-result-v01.bend` candidate therefore changes only
`p140n_raw` and adds a four-argument result constructor. It does not retain the
old session for that unobservable rollback. Existing `p140n_backend` still owns
all success/error effects and error text; generic `p140s_finished` and later
cache publication after file close remain untouched. This removes a concrete
category of dead retained state rather than increasing the upstream ABI limit.
The24-line module and exact diagnostic/source pins are in
`native-result-v01.json`. It is not yet source-checked or emitted by this lane;
the coordinator must establish that the new maximum fits and full behavior
remains correct. It does not remove the supported incremental CLI modes.

## Smallest decisive diagnostic

On a **derived diagnostic copy**, preserve all original successful compiler
behavior, rewrite only its `./bend.ts` import to the exact original absolute
module (so the loader and compiler still share the same Bend module instance),
and enrich the existing WIDE refusal message. Keep the pinned upstream checkout
untouched and authenticate the inverse transformation.

The observer should return:

- Live `FL.segs` entries with `params.length > WIDE`: `fid`, `def`, parameter
  count, result width, and frame pop/held counts; largest ten entries as context.
- Reachable ADT constructors from `FL.srcs`, their already memoized
  `lay_node(k).ks.length`, and encoded arity; same foreign-definition accounting
  as the original local `cids` construction.
- The exact error, source/toolchain hashes, source-root count and report scope.

This does not loosen the ABI limit, change layout/optimization policy, or emit
an otherwise refused program. The message reads the existing local
`entries/cids` at the exact original refusal. Printing an early oversized
segment inside `seg_open` is weaker: it may later be unreachable.

The metadata-only preparer is now available at
`selfhost/tools/performance/phase144/upstream-arity/prepare-v01.py`; the root-run
observer is `observe-v01.mjs`. `selfhost/build/phase144/upstream-arity-plan01/prepare.json`
pins the exact derived copy and proves inverse byte identity. No compiler was
run by this lane. The bounded diagnostic retains the first32 offending entries
with complete parameter structures, the exact total/omission count, largest10
entries and every constructor overflow. Expected refusal is a successful
diagnostic observation, explicitly **not** a successful compiler acquisition.

A new run would likely repay roughly the previous86s and4.7GB footprint; it is
not a free metadata query, and nothing can inspect the terminated process's
lost FL state. The coordinator must approve its resource lane. Until that
information is worth the cost, the C comparison is explicitly blocked by a
pinned upstream ABI/layout refusal, not evidence that the native QBE compiler
is faster or slower than a successfully acquired C counterpart.
