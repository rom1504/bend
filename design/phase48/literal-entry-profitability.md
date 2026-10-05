# Literal-array entry: decline only trivial direct countdowns

Status: isolated source overlay for review, not built or executed. Root owns all
integration and targets. The array03 scale diagnostic passes, but exposes a
fixed entry cost: n0 changes 1.2516→13.0082 μs (10.39× slower), n1 changes
5.0163→13.7007 μs (2.73×), while n128 improves 295.046→18.1077 μs (16.29×)
and n8192 improves 19.1454→0.269082 ms (71.15×). These are a separate diagnostic,
not a full-corpus result. Real Evening is excluded and byte-identical to baseline.

The minimal proposal declines private literal-handle entry for an exactly
identified public primitive countdown of zero or one. It keeps every existing
host/source/type guard for all other inputs. It does not choose an empirical
threshold of 16, recognize a benchmark, weaken permission, cache mutable host
proof, or introduce a new context analysis.

## Source facts and bounded implementation

Only an already successful literal-array region plan supplies facts. Require a
single existing Mat/Zero countdown helper and no second matcher, producer, fold
or residual loop. Visit at most 256 executable planned nodes, stripping Ann
without visiting its type children. Require exactly one direct JCall to that
countdown helper. Do not expand helpers or substitute root arguments through
wrappers; an indirect/unknown count keeps the old policy.

The first Nat argument must be exactly a native U32.to_nat application to a
root binder, or exactly a root Nat binder. Existing primitive proof verifies
the conversion, and the root's formal telescope verifies the matching exact
primitive domain. Resolve no more than 32 root binders. Let aliases, arithmetic,
computed counts, helper forwarding, multiple calls and constant counts are
unrecognized, so they emit no new predicate. A native constant 37 retains its
existing entry. The successful original plan still owns all typing, helper,
native, alias, demand and stack semantics.

No new type or planning-mode family is introduced. Small KTerm facts distinguish
an absent, unknown or proved direct slot; they are local compiler metadata.
Every recursive fuel/shape check is kc-fenced. Helper inventory is capped at 32,
plan walk at 256 and root slots at 32, with no branch-local budget reuse or
unbounded helper expansion. Exhaustion emits the unchanged original guard.

The overlay adds 89 helper lines in the existing array-literals module and one
emission conjunct; there is no runtime or compiler manifest change. Parent
array-literals SHA-256 is
`795ea4888d9dca473c8793e895bab6609276cbabcbde533bb87f88cc2b672cc3`.
The [patch and identity manifest](../../selfhost/tools/performance/phase48/proposals/literal-profitability/manifest-v1.json)
bind exact parent/output bytes. Applying the patch to a different parent requires
an explicit reviewed derivation, not silent fuzz. No live source was edited.

## Runtime behavior

For a U32 root slot N, prepend before arrayViewHostGuard:

```js
!(typeof $sN === "number" && ($sN === 0 || $sN === 1)) &&
```

For Nat use typeof bigint and 0n/1n. Number -0 compares equal to zero and declines
as required. No Number/Math/Object global call, conversion, property access,
coercion, iteration or allocation is introduced. The slot was already read in
the original wrapper in its original order. Objects, proxies, boxed numbers,
NaN, noncanonical numbers and mismatched primitive kinds retain the original
entry policy; this precheck does not inspect them or grant permission.

When the precheck declines, the existing complete generic body executes. It
still observes changed G/native/host dependencies, errors, aliasing and reentry
in their old order. No alternate fast path is added. Skipping a pure guard scan
is safe only because it selects that original body and cannot demand an input
or invoke a changed hook earlier. Positive calls still pay the full guard, so
this does not claim to solve general public entry overhead.

## Required qualification changes

Keep full value, boundary, alias and deep controls. Version the controller with
an explicit new activation policy: cycling at canonical n0/-0/n1 must take the
old body; n16/n128/n8192 must still execute its existing literal worker. Glowing's
constant37 nullary body remains active. Test renamed direct Nat0n/Nat1n roots and
Nat16n positive roots, plus computed/aliased/indirect count refusal to specialize.
Unknown counts keep original behavior, not a newly forced refusal.

Add object/proxy coercion and unused-argument sentinels at zero/one, modified
native code/G/host descriptors, getter/throw/reentry and partial/raw entry.
These must compare complete original traces, including untouched inputs.
Independent source controls may add these cases without relaxing existing
oracles. Count derivatives remain separate from clean timing. A focused screen
at 0/1/128/8192 can establish whether the source fence recovers small calls while
retaining large gains; no additional intermediate threshold study is needed to
qualify this first variant.

## RNFA03 composition successor

The initial parent795 overlay is preserved. For root's combined candidate use
[manifest-rnfa03-v2.json](../../selfhost/tools/performance/phase48/proposals/literal-profitability/manifest-rnfa03-v2.json)
and `literal-count-rnfa03-v2.patch`, derived against frozen RNFA03's
`array-literals.bend` SHA-256
`9bd9568c55f00f0ed177b95903fac89807934191982b3e3c271ddd89c65b7485`.
This retains the composition's JF32 literal whitelist. The isolated replacement
file SHA-256 is
`b687c9f66939c6072ed94cefdf5ef449b9ecdfc241446146fb727e91d4c7b91c`;
its inversion reconstructs that exact RNFA03 parent. Review of the unchanged
count helpers/fence passes statically; checked source/activation/performance
qualification remains root-owned and pending. There is no claimed small-call
gain until the successor screen demonstrates it without changing large loops.
