# Phase88: Data continuations for the native observer

Implemented in `selfhost/src/back/native/observer-analysis.bend`, initially frozen
at SHA256 `26aa9fcbdb144e2a900190812e0e1776d446e0f6c8d5ccc26259756c125f478a`.
This lane performed source/offline checks only; root owns guarded compilation and
execution. Root's checked acquisition and complete-product comparison now pass.

Phase87 established that shared closure values fail native reference counting,
while the same operation represented as Data succeeds. Separate-law and inline
signature controls emit identical C/JS, so annotation spelling was not the cause.
The observer intentionally reuses its remaining computation on both symbolic
branches; merely replacing eager choice helpers by direct matches is incomplete.

The repair adds one recursive Data type with eight constructors and one dispatcher.
It replaces 13 captured continuation lambdas and 10 calls through a host function.
The analysis context stays as an ordinary threaded parameter, outside the frames.
The source grows 25 physical lines in one module; no manifest/backend/runtime change
is required for the repair. Native's closure/task sharing guard stays intact.

`NO_KEvalArgs`, `NO_KApplyArgs`, `NO_KAppFunction`, `NO_KAppArgument`,
`NO_KConstructor`, `NO_KLetBody`, `NO_KApplyOne` and `NO_KFinish` reproduce the
captured values and operations mapped in the
[Phase87 audit](../phase87/map-investigation.md). Only Data values occur in their
fields. Existing ordinary-stack `noa_prepend`, `noa_match_join` and
`noa_recur_done` behavior is retained. The dispatcher adds no fuel decrement.

Preserved obligations are yes-before-no analysis, starting no with the fresh/fuel
returned by the *complete* yes continuation, no second branch after a first error,
branch-local facts, exact result-marker tail proof and the Efq/error paths that
skip the continuation. Public `noa_analyze` results and permission input keep
their original type/meaning. Internal observer CPS helper types intentionally
change from function values to `NO_Cont`.

[Focused controls](../../selfhost/tools/performance/phase88/observer/README.md)
return 17 complete analysis products from synthetic compiler-owned core. The old
JS interface is derived through exactly three adapter substitutions. Candidate JS
and native must agree with all old products and independently satisfy intended
success/refusal/body-tag/fresh-limit assertions. This isolates the repair without
rebuilding the full IO compiler image for every edit. Actual source fixtures,
complete emitted C and compiler/runtime speed remain separate gates.

## Measured component result

The retained [comparison](../../selfhost/build/phase88/observer-controls.json)
passes all 17 cases. Old raw JS, new raw JS and new native stdout are exactly
3,638 bytes each, with SHA256
`6f83df8ea27f22276803811b5ce9c2a1edfb812a536abb01dd630bc7b072eb27`.
This compares every printed analysis field, not only final success or body tags.
Independent assertions also pass: both symbolic branches allocate in order
(fresh 102), the first unsupported branch stops at fresh 100, exhausted inputs
retain fuel zero, the fresh limit refuses at 294967200, Efq skips the continuation,
tail recurrence returns `NO_Loop`, and non-tail recurrence returns the original
`observer: non-tail or discarded recursive result` error.

The [old JS](../../selfhost/build/phase88/observer-old-js-guard/process.json),
[new JS](../../selfhost/build/phase88/observer-new-js-guard/process.json) and
[native](../../selfhost/build/phase88/observer-native-guard/process.json) runs all
exit zero. The native component [O2 build](../../selfhost/build/phase88/observer-native-build-guard/process.json)
completed in 16.08 s with a 355.8 MiB peak under the 2 GiB guard. These tiny run
times are correctness receipts, not a compiler-speed comparison.

Root also reports complete Map C identity from the new JS-hosted full compiler
against ordinary B2. Full native Map and broader native conformance remain root's
separate integration gates; these component results do not establish them.

Offline validation also passes `git diff --check`, balanced source delimiters and
Python AST parsing. There are no remaining `NO_Input -> NO_Analysis` types or
`k(NO_Input...)` applications in the production observer.

## Bounded follow-up source audit

A comment/string-stripped scan of all 132 active manifest modules finds only
three remaining definitions with function-valued parameters:
`core/term.bend:4` (`kc`), `front/lexer.bend:48` (`f_choose`) and
`back/native/text.bend:2` (`nt_choose`). Each directly matches its Boolean and
invokes exactly one affine thunk once. No function-valued law parameter or
locally bound reusable lambda is found in this scan. The historical assembled
`src/compiler.bend` is outside the manifest and is not another active call site.
This is a bounded source audit, not a proof of every generated closure lifetime;
it identifies no additional concrete repeated-continuation hazard to repair now.

## Next bounded native-host experiment: consuming equality

The ownership lane reports `term_drop` below `STRING_ORDER` during Base setup.
The inspected pinned `base.bend:1893–1923` reconstructs both equal prefixes in
`String.cmp.rec`; `String.order` at line 1952 immediately drops the returned
strings through `Pair.snd`. All 132 compiler modules use the Boolean operation
`String.eq`, with no direct `String.order`/`String.cmp`/ordered-comparison calls.
Thus the narrower experiment is a first-order consuming Boolean equality helper,
not an ownership-runtime change or replacement of the paired `String.cmp` API
used by Base maps.

In an isolated native-host assembly, add a checked helper which matches both
strings, compares heads with `Char.is_eq`, tail-calls on equal heads and returns
`False{}` on a mismatch. Do not reconstruct strings, return a pair, capture a
continuation or mark this helper unsafe. Redirect only lexical `String.eq` calls
in compiler-owned source to the helper; preserve strings containing emitted code,
the pinned Base source and the runtime input Base used by the compiler. Record
the derivative's source/hash separately. Keep the existing JS source and its
primitive-string equality adaptation as the reference. If a later shared-source
version is tried, its helper needs the same explicit, reviewed JS primitive-string
fast path; otherwise its structural recursion could reintroduce the JS stack
overflow already recorded in Phase86.

First use a tiny checked native/JS component, with equal/unequal empty strings,
first/last/prefix mismatches, Unicode, long equal prefixes and shared versus
consumed inputs. Reuse inputs after comparison to catch incorrect ownership.
Compare all results to unmodified `String.eq`; then require full emitted C
identity on the compiler screen before timing Base preparation and requests.
This can remove reconstructed-prefix allocation and disposal, but it cannot
remove required disposal of consumed inputs or shared-reference accounting.
The ownership sample fraction is an opportunity location, not a predicted
removable-time percentage. No prototype or timing claim is made in this audit.
