# Phase165 independent source-ablation audit

This bounded audit covers the planned bendc checker memo and Map/String source
ablations. No compiler, target or benchmark was executed. It is not promotion,
whole-compiler qualification or a mathematical correctness proof. Preparation
scripts and emitted code need their own identity/admission receipts.

## Memo: intentionally remove an optimization, not replace it equivalently

Pinned current bendc `check.bend:1738–1765` explicitly documents its six Bend
memo bodies as no-storage fallbacks. `memo.new` returns `Qnt{NoSp{}}`, `has` and
`same` return false, `get` returns its input, `set` returns the computed value and
`link` returns the comparison result. Native `rt/bendrt.h:3085–3135` instead
implements mutable two-slot cells, value sharing, identity tests and linking of
already evaluated equal values.

Renaming just those six checker definitions and their actual call references
away from the six `Chk.memo.*` compiler-recognized names is a reasonable
**no-memo ablation**. It does not implement the same memo algorithm in Bend.
Direct native/fallback `memo.same` or `memo.has` outputs intentionally differ;
complete checker outcomes are the correct semantic comparison boundary.
`memo.get` is harmless only because fallback `memo.has` always refuses that
branch. Renaming an incomplete subset can mix incompatible cell representations
or admit `get` on a placeholder, and is not an acceptable experiment.

The six-symbol renamer must leave compiler `Natives()` strings, parser strings,
comments and unrelated modules unchanged. The existing `Chk` import namespace
must remain stable. Verify generated calls reach the renamed ordinary bodies
and cannot reach native `F_Chk_dmemo_*` through another wrapper. Header presence
of an unused native function alone is not evidence that it executes. Keep source
definition counts, twelve intended edits (one definition and one reference per
symbol in this pinned checker), and producer/runtime identities explicit.

The prepared `memo-source01` sources and `tools/prepare-memo.py` were subsequently
reviewed. An independent offline reversal of the twelve recorded byte spans
reconstructs the exact original checker, and all five other Bend modules are
byte-identical between roles. Manifest SHA256 is
`f03b1e679e90d80dd2b6a58cb642294dd5d3aa48e38946ca4d0174172ec46f78`;
candidate checker SHA256 is
`fec74488fae4ccb721269e46dcefffd06d91fbcb373a906b42d76894c226c6c3`.
This is source identity evidence only. The acquisition Base is pinned2.0.34
(`c742fa…`), whereas the planned common measured-input Base is Phase66
(`99ac43…`), matching the earlier Phase162 workload. Do not substitute one for
the other or reuse an exact verdict against changed live Base bytes.

`term_wnf` and `term_compare` use finite `Fuel.max()` (4,000,000,000 in this
version). `cmp.run` returns false at exhausted fuel. Repeated normalization and
comparison after disabling sharing can therefore change termination, timeouts
or verdicts even when unlimited pure evaluation would agree. A different error,
timeout or resource refusal fails the output gate; it is not a valid elapsed-time
speed ratio. Do not increase fuel or silently skip a failing proof to make the
ablation pass.

## Map/String: preserve the whole relevant implementation closure

Native `Map.bit` traverses a key without rebuilding its prefix. Native
`String.cmp/eq` reads code points without reconstructing the input strings;
`String.eq` also has compiler borrowing treatment. Native `Map.get/has` calls
its own C `map_bitv` and `str_cmp`, returning the original map and retaining the
selected value. These operations move work out of Bend; they are not evidence
that all map/string work disappeared.

A checker-only fallback experiment should clone the exact pinned Base helper
closure under fresh names and redirect resolved checker implementation calls.
Keep erased type/quantity parameters, ownership modes, exact comparison order,
returned maps/strings, miss/default behavior and source error text. Do not
rewrite quoted operator names such as `"String.append"` that describe the
*input language*, and do not replace the checked user's Base or source. Pin
every cloned declaration and law used by the closure.

Names matter beyond runtime lookup: compiler `Natives`, borrowing analysis,
specialization, result flattening and generated runtime feature macros can all
change when a function becomes ordinary Bend. That bundle is the treatment;
timings cannot be attributed solely to the source algorithm or one native call.
Replacing `Chk`'s explicit `String.eq` alone leaves native `Map.get/has`'s hidden
C string reads. Replacing a top-level Map helper while its cloned dependencies
still call native `Map.bit`/`String.cmp` is a partial ablation. Conversely parser,
error formatting and checker live in the same `Chk` module: a module-wide
redirection is a **checker-frontend** change, not just typechecking time.

Original and variants need identical producer, runtime header/policy, C flags,
unboxing policy, worker count, CPU affinity, Base bytes, input bytes, argv and
environment. In particular preserve the established private bounded-refill
policy, `BEND_RC=0`, `BEND_NO_FREE=1`, disabled auto-parallelism and any explicit
GC-factor policy. Do not compare a rebuilt current checker against the unrelated
historical published self-emission executable. A combined memo+Map/String run
does not isolate either effect; retain separate original and single-treatment
roles before interpreting interactions.

## Exact checker gates

Use the same source path and bytes for each role. Complete check-only calls
load/check live Base and the input, then call `Chk.report`; parse-only success
does not establish successful body checking. Expected success is exit0 with
`ALL PROOFS CHECK` and `Use --verdict for mathematical validity.` on stdout,
including exact newlines, and empty stderr.

An unsafe-dependency report is exit1 with empty stdout and the exact report on
stderr. Phase162 full source's report has 122,602 bytes and 7,026 listed names;
bind its retained source/Base oracle, not merely those counts. Both genuine
type errors and unsafe reports start `SOME PROOFS FAIL`. The original
`experiments/phase162/tools/frontend.py` incorrectly rejected that prefix for
type errors; its negative receipt was preserved. Reuse the corrected exact-byte
observation method, not that old classifier. No substring-only error admission.

Small independent negative controls already exist:

- `selfhost/tests/phase162/unsafe-type-error.bend`: `True{}` where an `@unsafe`
  main promises U32. The exact 128-byte Phase162 stderr demonstrates that
  unsafe annotation does not skip body checking.
- `tests/check/typed_let_mismatch.bend`: an incorrectly typed local binding.
- `tests/check/beta_ann_lambda.bend`: an annotated lambda's domain remains
  checked instead of disappearing during reduction.

The last two have explicit expected diagnostics in `#|` lines, but obtain and
retain the unchanged original bendc's exact exit/stdout/stderr on the selected
path before comparing variants. These source tests are independently authored
gates, not synthetic byte strings inferred from candidate output.

## Cheap sharing witnesses

Upstream `tests/check/conversion_shared_cells_once.bend` was written specifically
for two shared term DAGs that would expand to roughly 2^32 tree work.
`conversion_copy_before_unfold.bend` tests copies of a call comparing before
either unfolds. Starting the no-memo ablation at depth32 risks an unnecessary
long failure. New additive fixtures reduce just that depth/name to4:

- `selfhost/tests/phase165/shared-cells-4.bend`
- `selfhost/tests/phase165/copy-before-unfold-4.bend`

`sharing-fixtures.json` pins both originals, derivatives and exact transformation.
All actual declarations are otherwise preserved, with their existing expected
successful proof report. These derivatives have **not** been checked or executed
in this audit. The first exercises two independently built but extensionally
equal shared computations; the second tests the rigid/copy shortcut and is a
useful control for an optimization that may remain effective without memo.
Use depths4 then8 only after exact original/variant agreement and bounded cost.

Passing these tests alone does not prove a cache hit occurred. If mechanism
attribution needs it, existing scoped memo counters should record new/has/hit/
get/set/same-hit/link events, separately from clean timing. Alias controls must
consume both outcomes; constructing then dropping an unobserved cell does not
exercise reuse. Do not compare raw memo-array representations or require
native/fallback primitive equality. The independently equal proof outcomes and
full diagnostic controls are the semantic gates.

## Subsequent offline gate of the completed memo observations

`memo-observation-audit.json`, reproduced by
`tools/audit-memo-observations.py`, validates all18 retained observations from
`memo-controls01`, `memo-checker01` and `memo-full01`, without launching targets.
It verifies exact original-C acquisition, source/Base/binary/output identities
and the independent outcome gates described above. All four full observations
match Phase162's entire122,602-byte unsafe report. The checker's464 unsafe-name
set exactly equals the earlier full report restricted to the closure's declared
names; a pre-existing exact checker-slice byte oracle was not found. The fresh
original and variant slice reports themselves are byte-identical.

Both sharing fixtures pass, and all three negative fixtures produce the intended
type errors. `beta_ann_lambda.bend` differs from its authored `#|` text solely by
one trailing space on the empty source-gutter line `9 | `. The independent gate
uses the repository's explicit `gates/test.ts:64` whitespace normalization for
that fixture; it does not alter original-versus-variant byte comparison. The
other control oracles match literally, including the retained128-byte Phase162
unsafe type error. These finite results do not establish cache-hit counts or
general equivalence on arbitrary normalization workloads.
