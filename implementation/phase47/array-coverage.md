# Array01 coverage: bounded static findings

Status: initial read-only inspection followed by root-executed saved-compiler
diagnosis. The diagnostic output exactly matches the checked array01 module.
The subsequent compiler patch is separate from the write-only array02 snapshot.

## Local pair already has the needed broad architecture

The `local-pair` point uses `pair(0)` from the maintained
[local-row fixture](../../selfhost/tools/performance/programs/fixtures/local-row.bend).
Its checked array01 module, `array01-fast/modules/local-row.mjs` under the raw
Phase 47 root, has one ordinary private scalar root and no raw-array root.
The corresponding source contains no unknown callback in the pair computation.
Its public input/result are U32; all four arrays are allocated locally.

The saved `G["pair"]` declaration already emits private positional functions
for `dp`, `row`, `gen`, `init`, and the cell/row/read continuations. The four-array
`Dp` record is already a private vector, with scalarized loop state. The two
Boolean selectors are already direct ternaries:

```js
function $R_98_50_117($p0){return ($p0?1:0);}
function $R_117_109_105_110_46_103_111($p0,$p1,$p2){return ($p2?$p0:$p1);}
```

Its dependency list contains 21 original definitions: pair, dp, dp.row, dp.f1,
row, cell, cell.f1, b2u, cell.f2, cell.f3, cell.f4, umin, umin.go, dist,
Array.get, dist.fin, init, Array.new, gen, Array.set, and prng.
The private body inspected contains direct region calls and array helpers;
there is no generic residual dispatch, structural fold, or producer stack in
that body. Thus accepting arbitrary residual graphs or adding another record
representation is not justified by this example.

The diagnostic in `selfhost/build/phase47/array-admission01/report.json` resolves
the initial uncertainty. Pair's region validity, scalar signature, and Array.new
dependency all pass; all twenty helper suffix checks pass. The first failing
App is canonical native `Array.new`; the first failing node is its erased
`Ref U32` argument (fuel 8012; its App record has fuel 8013). The resulting
130,967-byte output is byte-identical to saved array01
local-row (SHA `2c5335baaff3248bcde0c618ef4567704bf7c9963b1529ba16fd5c56c0779fe5`).
These completed-result probes include pending worklist/suffix results; ancestor
false records are not separate independent failures.

Some typed region plans retain a saturated native source App instead of JNative.
The new audit recognized only JNative and treated the erased source argument as
executable. This is a representation-normalization gap, not missing Bool or
record support. The exact original guarded native dependency is already present.

The separate extension reuses `j_region_local_native` to prove native ownership,
telescope, saturation, and U32 element type, and additionally requires the original
native dependency in the helper set. Only then may the audit skip the erased
argument. After complete admission, a small normalizer rewrites those Apps to
JNative throughout the private root and helper bodies, preserving Ann/JUnpack
type metadata. The raw emitter handles the new/get/set representation uniformly.
Whitelisting Apps without this normalization would risk mixing ordinary handles
with raw views. Original helper guards and fallback emission remain unchanged.

## Edit-distance batch has an additional outer boundary

The [editdist fixture](../../selfhost/tools/performance/programs/fixtures/editdist.bend)
contains the same pair computation. Its exported `bench(size, seed)` calls a
binary recursive `batch`; the saved local-row module still emits that batch
through ordinary descriptor calls. A raw private `pair` can nevertheless improve
each pair reached from that outer path. Full batch admission is a different
change and should not be required before measuring the pair improvement.

Public `row.probe`/generic-row adapters receive arrays and are intentionally
outside the scalar-only raw representation contract. Enabling raw layout merely
because their inner row loop is private would change the public backing ABI.
Keep that refusal, even if it limits a benchmark point.

## Minimal additional validation

After identifying a small audit fix, require actual raw-root activation for
local-pair and a fresh renamed fixture with two or four locally allocated
arrays in a custom record. Exercise row-role swapping, different initial values,
zero/one/multiple iterations, Bool selection in either arm, and alias-sensitive
writes. Compare a small independent grid oracle, then the maintained pair and
editdist checksums. Retain all Array01 host mutation, callback, public storage,
and demand controls unchanged. Add refusal checks for the same record as a
public input/output.

Array03 passed its checked build and independent static review, but its acquired
local-row module remains exactly the same 130,967 bytes with zero raw-array roots.
The first normalization attempt therefore did not establish coverage. The separate
`array-admission-probe-v2.mjs` pinned checked-array03 and this unchanged module.
Its executed report, `selfhost/build/phase47/array-admission03/report.json`, passes
output identity and shows every recorded Array.new native proof true. The first
false source App instead calls collected nonnative `dist`, whose planned body is
Ann (fuel 8057); all twenty helper suffix checks pass again.

Array04 addresses this with exactly saturated, positive-arity collected-helper
App admission and private JCall normalization. Its arity bound and complete typed
helper proof remain unchanged. Only the current Mat helper's own source self App
survives normalization for existing loop-tail lowering. Non-self Mat calls must
also be private: otherwise raw arrays could reach the ordinary public descriptor
ABI. The module grows from 186 to 197 lines. Activation, checked semantic replay,
and timing for this source checkpoint remain pending; the identified failure
explains the next experiment but does not guarantee its outcome.

Measure before widening further. The completed five-way saved-output experiment
found the useful change in ordered stores (84.207→63.809 µs); preserving an
invariant backing alias did not help. The unsafe guard bypass reached 73.694 µs.
These [separate causal results](array-write-statements.md) justify the isolated
write-only array02 change but say nothing yet about pair/edit-distance admission
or profitability. Keep public array boundaries refused throughout.
