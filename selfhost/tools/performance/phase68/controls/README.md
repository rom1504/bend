# Phase68 native correctness controls

These controls distinguish proposed fixtures from closed observations. The selected baseline is
Phase67; upstream remains `0592662`. See the
[correctness design](../../../../../design/phase68/correctness-boundaries.md).

`catalog-v1.json` pins 29 sources and their independent fixture goldens. Four
small new sources have hand-derived expectations. Existing sources retain their
historical provenance; merely selecting one does not make it pass a new emitter.

| Selection | Sources | First use |
| --- | ---: | --- |
| `arity-fast-selection.json` | 6 | Matcher arity raising and shared residual aliases |
| `flat-fast-selection.json` | 6 | Direct return, aggregate boundary, callback and scheduler fallback |
| `ownership-selection.json` | 8 | Scalar replacement, captures, borrowing or changed disposal |
| `boundary-selection.json` | 9 | IO/foreign/error/erasure/numeric integration |
| `integration-selection.json` | 29 | Candidate integration after the relevant short set passes |

`prepare.py` is a small data-only wrapper around the existing checked workflow;
it does not import a compiler, emit C, or run a target. It requires a **fresh
Phase68 checked attempt**, verifies its snapshot and actual API, freezes the
chosen selection, and pins a current native-method recipe using the Phase67 method schema. Validation primes
the selected snapshot, so this wrapper rejects closed historical snapshot paths.

Prepare a plan on CPU0 (replace the two example input paths with the actual
selected attempt and pinned native method recipe; a historical recipe that names
a superseded installed image must not be used unchanged):

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase68/controls/prepare.py \
  --attempt selfhost/build/phase68/arity-build01 \
  --toolchain-recipe selfhost/build/phase68/native-arity01-recipe.json \
  --set arity-fast \
  --out selfhost/build/phase68/arity-controls01
```

Root then executes the exact `plan.json.command` under its existing serialized
target lane. The outer orchestrator must retain normal affinity; the immutable
checked attempt owns CPU3 worker placement. The guard enforces the 2 GiB process
tree limit and 4 GiB available-memory floor; Node heap is 1 GiB. The ordinary
workflow compares the candidate and pinned TypeScript observations and goldens.
No custom expected-output oracle or backend switch is introduced here.

External fixtures include an explicit `file` in each selection. Omitting that
field is an inventory error: an arbitrary `phase68/...` ID cannot resolve to the
upstream fixture tree. The manifest and selection are checked against each other
before any command is prepared. All source edits and failed attempts need fresh
versioned outputs once consumed.

Separate gates still required when affected:

- Phase67 `native/raw-controls-v3.mjs`: exact malformed-core first diagnostic,
  primitive override and partial application, and mocked shared-error checkpoint.
  Use a frozen baseline API and selected actual API. Its C-marker preflight may
  need an explicit successor for a new direct-return convention; never silently
  skip a failed marker. Its runtime identity must match the selected snapshot.
- Maintained `src/back/native/fixtures.mjs`: `run/fork_shared_flat`,
  `reg/array_clone_boxed`, `run/nat_overflow`, and
  `compile/bang_intrinsic_closure` with one and four threads. Derive a fresh runner
  using the three exact import/root/output substitutions already reviewed in
  Phase67 `native/prepare-focused-v3.py`; do not write into Phase67 raw paths.
- Any changed ownership algorithm: add a bounded reclamation/allocation or
  sanitizer diagnostic for the particular witness. Output alone cannot expose
  all leaks or prove race freedom.
- New path activation: retain an actual emitted-code/admission census alongside
  runtime measurements. A passing fallback is correct but is not evidence of the
  proposed optimization's benefit.

The 29-source union does not claim full native, GPU or callback-ABI conformance.
The previously unsupported native methods remain explicit. Keep reference
failures, expected fail-stops, candidate failures, unsupported operations,
crashes/timeouts and malformed raw controls separate. Compiler latency, C build
latency, and emitted executable runtime are distinct clocks.

## Competing error order

`error-order-v1` is separate from the consumed29-source catalog. It contains three
source-audited hypotheses: saturated and partially applied named matchers should
reach Nat overflow before their IO.OP tag guard in pinned upstream; an explicitly
staged source match should reach the tag guard first. No `SECRET` effect should
execute. These independent outcomes distinguish an inherited curried-entry
difference from a new optimization bug. No observed result is claimed yet.

Its tiny `prepare.py` derives only selection/output paths from a frozen plan:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase68/controls/error-order-v1/prepare.py \
  --parent selfhost/build/phase68/arity-controls01/plan.json \
  --set characterization \
  --out selfhost/build/phase68/error-order-controls01
```

The actual first plan already exists; reuse its exact command or choose a fresh
output for a new preparation. `--set required` selects just saturated/staged;
`characterization` includes the potentially failing partial-call case. Never
convert that failure into a passing comparison by omitting it after execution.

## First observations and corrected eta selection

The first arity image passed five of the six paired sources in
`selfhost/build/phase68/arity-controls01/execution/selected/paired.json`.
The sixth source was invalid: the reference rejected its lambda-local matcher,
and the candidate rejected an unannotated constructor let. The original source,
catalog and failed observation remain unchanged. `matcher-shared-residual-v2.bend`
uses full function parameters and an explicit constructor annotation; its
independent `keepkeepkeepkeep` golden is unchanged.

The first error-order run, under `error-order-controls01`, confirms that both
compilers report Nat overflow for the saturated call. For the partial call,
upstream reports Nat overflow while the old curried native entry reports the
request-tag fail-stop. This is an actual semantic difference, retained as a
failure. The staged source was invalid in both parsers because it matched a
local binder. `error-order-v2/staged.bend` instead matches a full plain-value
helper's parameter before evaluating the next let; its fail-stop golden is
unchanged. Equal parse rejections did not count as a passing runtime control.

`eta-v1` pins nine cases: the five valid arity sources, the corrected sharing
source, and all three error-order cases with the corrected staged helper. Its
preparer differs from the reviewed initial preparer only in directory depth and
the admitted selection name. The fresh plan is
`selfhost/build/phase68/eta-controls02/plan.json`, bound to `eta-build02` and
`native-eta02-recipe.json`; execution and results remain separate from plan
preparation. Use this selection to verify that the eta adapter fixes partial-call
ordering while retaining explicit sequencing, erasure and ownership.

The preliminary `prepare-repaired.py` data attempt refused the changed live
compiler manifest. Its v2 successor materialized an exact frozen-manifest
continuity plan at `matcher-shared-controls02`, but that older-image plan was
superseded before target execution by the nine-case eta plan. Neither a refused
preparation nor an unused plan is a test result.

The closed eta run has **nine exact candidate/reference observations and eight
golden passes**. Its only failing golden omitted the quotes used to display a
pure String result. `matcher-shared-residual-v3.bend` changes only that golden;
`matcher-shared-v3.json` records the previous failure and the independently
existing `show/string_unicode.bend` display convention. The subsequent prefix
run passes this corrected string fixture.

That first prefix run passes four sources but rejects two invalid sources in
both parsers: a tuple pattern cannot scrutinize a computed call. The corrected
`callback-array-owner-v2.bend` and `prefix-scratch-v2.bend` pass each computed pair
to a helper that destructures its **parameter**. Their arithmetic goldens remain
29 and 7071122. `parameter-pair-repairs-v1.json` preserves both failures. Scratch
still places two array initializers in the same main body.

`reference-fixtures-smoke01/execution/report.json` now records successful
upstream parse/check of all nine current new sources, including the future
flat-worker discriminator. This small `book_load`/`book_valid` controller runs
before native acquisition, never invokes Clang or executes a generated program,
and claims type acceptance without independent proof trust. The paired retry for
just the two repaired sources, `prefix-controls04-retry02/execution/report.json`,
is now complete and passing. Together with the four earlier valid cases, this
qualifies the six intended source witnesses on prefix04 without relabeling either
invalid fixture. `prefix-raw04/execution/report.json` separately passes all ten
inherited raw diagnostic, primitive, partial-application and shared-error
checkpoint controls. Those observations compare eta02 and prefix04, including
one/four CPU threads; they do not qualify a future flat-worker image or GPU
execution.
The separately proposed `flat-product-record-v1.bend` was written later and is
not included in that nine-source smoke.

The flat-worker selection and retained-code audit live in `flat-worker-v1`.
They keep the original paired workflow and goldens, retain all artifacts, and
require actual flat-worker admission for a deep self-tail loop. Explicit
non-tail self recursion and a mutual cycle must retain their scheduler paths.
An all-fallback output pass cannot satisfy this mechanism gate. The selected06
run now passes all eight paired sources; `flat-controls06/admission.json`
(`5d0cd5ee53497fdc4204898885775c82d77293ae2f7b4ae630535d7555da12ab`)
also confirms the actual `tail68` worker/call/local loop and excludes workers for
the live non-tail and mutual-recursion definitions. This is a selected06 result,
not automatic qualification of subsequent admission or product changes.

The product follow-up adds two proposed source controls: ordinary record
result-to-consumer `flat-product-record-v1.bend` (1131), and
`flat-product-array-v1.bend` (2917). The latter reads both the extracted value
and the returned array, exposing field reversal or premature disposal. Their
two-source upstream parse/check-only plan is `reference-products-smoke03`;
the earlier unused one-source `reference-product-smoke02` remains unchanged.
That new smoke is now complete and passing for both sources. It does not
qualify native generation or execution.

The final corrected selection is `integration-v2`: 36 distinct sources, including
all corrected fixtures, the scratch and worker-admission witnesses, and both
products. Its `prepare.py` takes `--attempt`, `--toolchain-recipe`, `--set` and
fresh `--out` just like the original wrapper. Use `--set product-fast` for six
product/ownership witnesses, and `--set integration` only at candidate selection.
The earlier catalog versions remain unchanged; their invalid source versions
are not counted as passes in this successor.

`prepare-threads.py` separately prepares the maintained four-fixture runner at
one and four CPU threads, explicitly GPU off. `prepare-raw-v2.py` binds the ten
raw controls to explicit `--baseline` and `--candidate` checked attempts. Its
v4 diagnostic instruments both the original scheduler return and the selected
flat host-worker return. The first raw07 failure instrumented only the now
inactive DEVICE fallback; the original failure remains under `worker-raw07`.
The successor keeps the exact original sequential/nonsequential body/checkpoint
oracle. Its zero poll counter and unchanged 4095 polling mask are checked before
instrumentation, so an entry poll cannot obscure that boundary.
`worker-raw07-v2/execution/report.json` now passes all ten rows with this exact
unchanged behavioral oracle. The correction changes diagnostic instrumentation,
not production code.

For the product or small-inline frontier, `prepare-raw-v3.py` selects v5 instead:
the original ten rows plus two image roles for an ignored raw product parameter
given a deliberately mismatched Nat immediate. Both must still return `7n`.
This checks that a type annotation cannot trigger eager unboxing. The successor
recognizes exactly the reviewed `INLINE`/`NF_INLINE` declaration and boxed or
one-slot-vector return spelling; unknown generated shapes still fail preflight.
It retains the previous failed diagnostic and both earlier controller versions.

`product-demand-v1.mjs CHECKED_ATTEMPT_JSON FRESH_OUT` is a small, separate
root-only controller for 18 actual compiled product-entry guard decisions. It
binds the complete selected snapshot and the exact reviewed product source,
then appends only a private diagnostic export. Cases cover single/repeated
uses, substitution, branch drops, primitive complementary conditions, unknown
constructor alternatives, and fuel exhaustion. It performs no C emission or
runtime execution and does not claim whole-product ownership qualification.
Check the actual selected API declaration preflight before scheduling it; the
controller has not been executed by the correctness lane.

The optional `flat-product-branch-drop-v1.bend` witness has independent result
1831 and a reference-only smoke plan at `reference-product-drop-smoke04`.
Its false branch drops a fresh product containing two arrays. A native mechanism
audit must also exclude its private `$product.drop_product_branch68` entry;
stdout alone cannot establish preservation of parent-versus-field drop order.
This optional source is not silently added to the frozen final36 selection.

The explicit successor `integration-v3` adds that source as the 37th final case.
Its preparer is the reviewed retained-C workflow factory with only selection
names changed. Use `--set product-branch-drop` for the single 1831 witness,
`--set product-fast` for the existing six, or `--set integration` for all 37.
The selected product10 single-source plan is `product-branch-drop10/plan.json`.
After it closes, run `integration-v3/audit-branch-drop.py --plan PLAN --out FRESH`
to require the exact paired golden and retained ordinary definition, while
rejecting any declaration, definition, or call to its private product entry.
Preparation alone does not report a successful observation.

The first product10 raw run is preserved at `products-raw10`. It stopped during
baseline atom-chain instrumentation: a substring search matched the same
`NF_INLINE` declaration as both `INLINE` and `NF_INLINE`. This was a preflight
failure; candidate atom-chain had not run. The earlier unused-mistyped-product
observations in both roles passed at one/four threads but do not make that
incomplete suite pass.

`prepare-raw-v4.py` selects the immutable v6 successor. Full-line declaration
matches distinguish the two prefixes. Ordinary and product main worker returns
are located inside their own balanced function bodies and instrumented by exact
offset, along with the scheduler fallback. The zero poll counter, polling mask,
12 behavioral rows and original sequential/nonsequential checkpoint oracle are
unchanged. The source/data-prepared retry is `products-raw10-v2`; its completed
target receipt is required before reporting the raw suite as passing.

The v6 retry failed before module execution because its `matchAll` spread had
one extra closing bracket. That attempted version and supervisor stderr remain
preserved. V7 removes exactly that bracket; `prepare-raw-v5.py` selects it for
the fresh `products-raw10-v3` retry. The pinned Node24 parser's `--check` command
passed on CPU0 before handoff, with no module or target execution. The previous
manual source review did not catch this syntax defect.
