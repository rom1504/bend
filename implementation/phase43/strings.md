# Phase43 String handoff

Runnable saved-JS full-component ablation and selected full-value/host/alias/
activation oracle are prepared. No execution measurement, correctness pass,
source qualification or installation is claimed. Static node --check passes
for derive.mjs and controls.mjs. The source proposal is in the
[design](../../design/phase43/strings.md).

Root executes serially from repository root, using fresh Phase43 output paths:

```sh
NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
python3 selfhost/tools/performance/phase32/bounded-run.py --seconds 30 \
 selfhost/build/phase43/strings-derive-run01 -- taskset -c 3 "$NODE" \
 --max-old-space-size=1024 selfhost/tools/performance/phase43/strings/derive.mjs \
 selfhost/build/phase42/integration03/runtime-batch1/modules/candidate/modules/lexer.mjs \
 selfhost/build/phase37/typescript01/modules/lexer.mjs \
 selfhost/build/phase43/strings-prototype01
python3 selfhost/tools/performance/phase32/bounded-run.py --seconds 120 \
 selfhost/build/phase43/strings-controls-run01 -- taskset -c 3 "$NODE" \
 --max-old-space-size=1024 selfhost/tools/performance/phase43/strings/controls.mjs \
 selfhost/build/phase43/strings-prototype01 selfhost/build/phase43/strings-controls01
```

Create a fresh compare-small.json selecting variation-lexer-6-17 from the
produced compare.json, then use the existing Phase35 comparer:

```sh
python3 selfhost/tools/performance/phase35/compare.py \
 selfhost/build/phase43/strings-prototype01/compare-small.json \
 selfhost/build/phase43/strings-screen01 --node "$NODE" --cpu 3 --budget 20
```

The catalog default.bench is the timed public export. Use the produced full
compare.json only after controls and the smallest-point discriminator survive.
Derivation also parses generated modules with the Node-bundled Acorn parser.
Report pins derive, worker, parent, comparator and generated module identities.

Controls inherit corrected Phase40 BigInt state/token arithmetic and add full
generated String comparisons, zero/nonzero ident/num complete outputs, mode/
tuple/fresh-field allocation and unchanged-input alias assertions, ordinary
public activation for each role and gen/line/batch/lex/step liveness for full,
raw code/partial demand, argument mutation before guard, and Error constructor
reentry. Existing controls cover Unicode/astral/lone surrogates, source metadata,
getters/bindings, String global/static/fromCodePoint/codePointAt/slice mutations,
marker hooks, Array/Object hooks, exceptions, deferred foreign tuple demand and
100000-character loop stack. Complete generation comparisons include invalid
surrogate constructors with exact error observations.

Limit: handwritten full workers establish the mechanism only. Source-valid
admission and actual ordinary compiled activation must be proven after root
integration; adding dead emitted workers or accepting String purity cannot
substitute for that evidence. No new proof flag is opened in this prototype.

The production admission proposal is saved as
[admission-proposal.patch](../../selfhost/tools/performance/phase43/strings/admission-proposal.patch),
with standalone ABI/runtime chunks alongside it. It extends exact native type
and literal0/Ref proof support, substitutes only exact covered original literal
references, captures only admitted compiler wrappers, and threads a conservative
String-family capture flag to scalarGuard's host-family check. It has not been
applied, compiled or qualified. Existing closed Sigma1/1 support stays shared.
Structural lowering activation remains an independent gate after this patch.

Reviewer correction before execution: bad() in every saved-JS role now suspends
and restores $lxActive around Error construction. A nested public step otherwise
could borrow rewritten fast edges while the diagnostic manual scope was active,
even though its nested root guard refused. The Error control asserts the flag is
false and that nested step adds no private counters. All prior Phase40 artifacts
remain untouched. Screen budget corrected to the supported20second preset.

The first root derivation failed its inherited cls-site assertion (actual2,
expected1). derive.mjs preserves that failed input. Frozen derive-v2.mjs corrects
only the static expectation to cls2/step1/lex2; a static Acorn inventory locates
the duplicated classification call in checked16's separate prior-private/fallback
branches. Both remain individually guarded operation sites. Use derive-v2.mjs
for the next root attempt; controls.mjs/full-workers.js are frozen.

Root executed strings-prototype02/strings-controls02 with frozen derive-v2 and
controls: selected controls pass in4.925s. strings-screen02 reports two manual
ordinary-bench points: depth8 original148.604ms/full8.40919ms/TypeScript1.68566ms
(17.67× faster than original; still4.99× TS), depth6 original42.1182ms/
full2.2355ms/TS0.403994ms (18.84×; still5.53× TS). These root-provided short-screen
results are mechanism evidence, not a source/installed improvement; exact raw
report remains root's authority and further source activation is pending.

The integration proposal is now combined-proposal-v3.patch, against current
production including product-owner tree additions, with staged review source
copies under proposal-v3/. It combines exact ABI/literal0 proof, all three
native matcher capability gates, source-project native fields, once-per-entry
String family guard, normalized typed-family traversal and the exact total U32
helper-prefix gate needed by prng in ident/num. Earlier admission-only and fixed
native-temporary patches remain preserved; v2 matcher temporaries use constructor
plus typed environment depth to keep outer tail references distinct from nested
Chr projections. Normalized family traversal shares512 work steps; unknown type
or budget exhaustion conservatively requests the String guard. Prefix admission
checks original all-U32 telescope, acyclic direct plan, bounded total U32 primitive
syntax and canonical arguments; no allocation/container/effect helper prefix is
added. Root alone applies/builds/tests the integration.
