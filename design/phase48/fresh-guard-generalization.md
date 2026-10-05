# Allocation-free guards beyond raw arrays

Status: separate unexecuted proposal. The raw-array v1 producer, fragment,
controller and consumed evidence remain unchanged. Root will first measure that
candidate. This note records a bounded generalization and a concrete exclusion.

`regionHostGuard(false)` and its existing integer mode both validate the
reflection methods, Array iteration/every descriptors, and Array/Object
prototype relationships/inventories needed to remove scalarGuard's temporary
containers. Fill, isSafeInteger and the extra floor descriptor in arrayViewHostGuard
are unnecessary for that particular allocation transformation. They remain
necessary for the raw-array operation contract; no raw-array check is removed.

The separate fragment
[region-fresh-local-guard-v2.js.frag](../../selfhost/tools/performance/phase48/entry-profitability/region-fresh-local-guard-v2.js.frag)
preserves the capability parameter and its callback-U32 String-family exception.
If regionProof is non-null it delegates to the original localGuard, preserving
covered and uncovered inherited-proof behavior. At null proof, it uses the same
allocation-free predicate and unchanged descriptor order as raw v1. There are
no new top-level host captures. It is not installed or independently qualified.

Admission sites must already have an explicit null-proof check plus a successful
fresh regionHostGuard, with inert canonical scalar validation between that check
and source guard. Preserve the exact full/integer host choice, public-input
reads/order, String host proof, all source dependencies and generic fallback.
Initially replace only such qualified call sites. Do not insert a null-proof
condition into existing branches whose inherited proof currently admits them;
that would alter their selection and reentry behavior. The delegation is an
additional safeguard, not permission to specialize an unproved caller.

F32 signatures, including aliased or unused F32 inputs, retain the original
full regionHostGuard and DataView/Math hook checks before validation. Integer
mode is not inferred from the new helper. Zero branches retain their exact
predecessor guards, input demand and selected body. No transient global proof
clearing, widened ownership token or public data permission is proposed.

## Scalar-region-0 is not currently a qualified site

Static inspection of the selected array06
`array06-full/modules/scalar-region.mjs` shows its exported `G["bench"]` private
scalar-root branch reads two slots and checks canonical U32 values then
`localGuard($guards)`. It contains **zero regionHostGuard calls**. Its point
helper has seven U32 inputs and likewise lacks a host-guard predecessor.
`j_fold_root_guard` intentionally emits an empty host prefix when no fold,
residual or floating facts require it. The benchmark name does not prove a
fresh host condition. Neither site can receive this specialization now.

Adding full host admission merely to remove small guard containers could cost
more than it saves. Deriving a smaller protocol proof would be another change:
it must observe/reject mutated iteration/every/reflection before any canonical
check that can call a live hook, and preserve the entire previous generic path.
It must not reinterpret prior mutation observations or source proof. That
proposal is deferred until the raw-entry measurements establish useful savings.

## Qualification and performance decision

Use a separate saved derivative and a separate actual-source candidate for this
generalization, never overwrite consumed v1. Require fresh-proof positivity,
ordinary root activation and all F32/Math/DataView, String-host, native/G,
zero/error/raw/partial/reentry controls. Add both inherited proof covered and
uncovered cases: specialized non-null paths must delegate exactly to old
localGuard, including its protocol observations. Public ABI and old fallback
must remain byte-identical outside the qualified source-guard call sites.

Measure representative already-qualified small roots and record compiler/output
growth. A marker or fewer source allocations alone does not establish speed.
There is no prediction that this guarded generalization fixes scalar-region-0;
its absence of a fresh host guard is an explicit current NO-GO.

The separate data-only
[fresh-entry-derive-v2.py](../../selfhost/tools/performance/phase48/entry-profitability/fresh-entry-derive-v2.py)
now prepares one selected array06 root with an **existing explicit null proof
and full host guard**. It requires an exact, syntactically total scalar input
predicate grammar between that host proof and the dependency guard; any unknown
call, object getter/demand, conversion, or malformed predicate refuses before
creating output. It changes one call site, inserts the function-only fragment,
checks exact inversion and binds the checked parent/receipt identities.
The full/integer source policy is not changed; this initial saved producer
supports full guard only and does not specialize arbitrary guarded helpers.

Read-only static checks confirm array06 Unicode bench has one matching entry
with two inert U32 inputs and unchanged StringHostGuard. Scalar-region bench is
rejected for missing freshness; example unproved calls/conversions are rejected
by the input grammar. No derivative output was created and no target executed.
After root's raw-entry measurement, a bounded optional command is:

```sh
python3 selfhost/tools/performance/phase48/entry-profitability/fresh-entry-derive-v2.py \
  selfhost/build/phase47/array06-full/modules/unicode-text.mjs \
  selfhost/build/phase48/fresh-guard-unicode01 --root bench
```

Use the maintained Unicode16/64 oracles and ordinary measurement protocol on its
two clean saved modules, with separate source/host mutation and reentry controls.
The raw-v1 timing wrapper is not the interface for this two-variant manifest.
Source promotion still requires actual checked emission and independent control
coverage; the saved producer is not a compiler admission rule.
