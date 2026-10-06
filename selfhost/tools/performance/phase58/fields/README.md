# Literal constructor and marshalling field keys

Prepared, not promoted. `literal-fields-v1.patch` changes three key-emission sites
in the direct constructor, ordered constructor and host-clone paths. A shared
`jd_literal_field_key` returns a quoted ordinary literal key except exact
`__proto__`, which retains computed-key syntax. `patch-v1.json` binds baseline
43de269 and every before/after source hash. Root applies the reviewed patch;
these tools do not edit production source.

Values, left-to-right prefixes, telescope specialization, quantity erasure,
property access, own-property attributes and public ABI are unchanged. Quoted
keys support reserved words, dots and underscores without identifier guessing.
`__proto__` is a semantic exception, not a profitability/benchmark-name rule.
The helper remains JavaScript-specific. No host/runtime proof is added.

The source fixture includes six valid unusual field names, dynamic fields,
callback-valued RHSs, shared shells, Nat fields and host roundtrips. The controller
requires actual checked baseline/candidate receipts, exact source/catalog/runtime
and API pins, complete own fields/descriptors/prototypes/key order, wrapping U32
results, Nat conversion, preserved incoming fields, sharing, callback order,
throw identity, reentry, partial application, getter traces and inherited
`__proto__` setter noninvocation. AST checks require plain candidate keys and
computed baseline keys, with `__proto__` computed in both. Syntax tests passed;
source checking and execution are pending root's serial jobs. There are 17
observation groups per role; getter traces must agree without ignoring events.

Use the reviewed shared private paired emitter. It verifies each genuine checked
attempt, copies the selected API/driver/runtimes into a fresh Phase58 project,
and gives that project its own ordinary validated Base cache. It does not write
closed baseline snapshots. From repository root, under root's sole serial guard:

```sh
NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
$NODE --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase58/qualification/paired-fixtures-v2.mjs \
  selfhost/build/phase56/checked-string01 selfhost/build/phase58/checked-fields01 \
  selfhost/tools/performance/phase58/fields/catalog-v1.json \
  selfhost/build/phase58/fields-fixtures01
$NODE --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase58/fields/controls-v1.mjs \
  selfhost/build/phase58/fields-fixtures01/baseline/literal-fields.mjs \
  selfhost/build/phase58/fields-fixtures01/candidate/literal-fields.mjs \
  selfhost/build/phase58/fields-controls01
```

The controller binds the exact reviewed paired producer SHA
`6a2947f7a3c9fd84f7a78215c607fd5f90773e1edddf31376828d2d1f7fe0fe7`,
actual receipt/compiler/copy identities and all emission inputs. Both genuine
attempts must retain their completed 36-case validation with zero exact
differences. The pilot candidate's `strictExact:false` is recorded honestly;
the actual exact agreement is asserted, not inferred from that flag. Future
producer versions require a new reviewed controller binding before acquisition.
There are explicit zero-event assertions at both incomplete partial calls.

Use the genuine selected Phase56 checked B1 as baseline, not historical worker23
or the pinned TS compiler's plain-`__proto__` constructor. The source oracle
requires an own data property; the TS special-name behavior is not a candidate
waiver. Broad maintained qualification remains separate from these focused gates.

## Saved-image causal diagnostic

`derive-v1.mjs PARENT_B2 EXACT_DIRECT_RUNTIME NEW_OUT` is data-only. It uses pinned
Node's internal Acorn, selects only nonmethod/nonshorthand `init` properties of
post-runtime ObjectExpressions with computed constant-string keys, and retains
`__proto__`. It changes neither MemberExpressions nor value evaluation. The
normalized AST differs only in admitted `computed` flags; an inverse edit list
must reproduce the exact parent bytes. Runtime, parent, output, parser, producer
and Node hashes are in `derivation.json`. It never imports or executes a compiler.

The root-authorized CPU0 derivation is retained in
`selfhost/build/phase58/fields-derivative01`: 7,297 edits, zero `__proto__` keys in
that particular compiler image, AST equality and exact inversion pass. Its
`productionQualified:false` receipt must accompany latency jobs; it is a saved
syntax ablation, not a checked compiler image or a bootstrap. An initial missing
output-parent-directory refusal remains in `fields-derivative01-parent-missing.json`.
Root's latency owner qualifies ordinary emitted outputs and owns clean execution.
This file contains no performance or installation result.
