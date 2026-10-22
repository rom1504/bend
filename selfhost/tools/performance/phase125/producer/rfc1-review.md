# Independent offline review: count-one RFC spine admission

Reviewed raw-only `runtime-concat.c` against pinned Phase118 runtime-extend01.
No implementation, build or target execution was performed for this review.

**Conclusion:** accepting an RFC-wrapped cell whose current count is exactly one
is justified for this sequential owned-input ABI, provided the entire spine is
proved uniquely owned and dynamic before the final store. Merely replacing
`term_rfc(node)` rejection with a root count check is insufficient.

For each nonempty node, retain the exact tag/link-CID checks. If raw, its location
must be dynamic. If wrapped, both the wrapper location and the **resolved payload**
must be dynamic; read its cell using existing `rfc_view`, require
`(cell & RFC_CNT)==1`, and use `cell>>24` as the payload address. Continue from
that payload's tail field. Require the exact terminal empty value as before.
Do not call `ctr_take`, free wrappers, unwrap terms in parent fields, retain/drop
heads, or mutate anything during this probe. Return the original left Term on
success, with every wrapper and ownership credit preserved.

The resolved-location guard matters: `rfc_seal` at runtime.c:863 wraps any raw
TAG_CTR, including a static constructor. A heap-allocated wrapper can therefore
point below HEAP_OFF. Testing only the wrapper location could permit modification
of immutable static storage. `term_triv` does not eliminate this case because its
location test sees the wrapper address.

The ownership argument is inductive. The checked append wrapper transfers one
owning left input. A raw root is unique by the existing ownership invariant; a
wrapped root with count1 has that single credit. From a unique parent, a raw child
is uniquely owned, while a wrapped child must independently have count1. Check
every child: a unique prefix can lead to an externally retained/shared suffix.
An externally retained left alias or right input aliasing any suffix contributes
another ownership credit and must cause refusal at that node. Head aliases are
irrelevant to spine mutation: no head value/credit is changed. Borrowed views
must obey the existing nonescaping owner-lifetime contract; this helper does not
make arbitrary borrowed aliases safe.

`rfc_view` at runtime.c:870 performs an acquire operation when observing count1.
This is the same observation used by `ctr_take` at:1033 to free the wrapper and
transfer its payload. The proposed concat is less invasive: it leaves wrapper
and payload ownership intact and changes only the final trivial empty tail.
Use the existing capability8/constructor-hot sealing policy to publish the owned
right suffix, then return the unchanged left root. The empty-left case continues
to return right without changing ownership counts.

The whole-spine probe is stable only under the current one-thread/no-GPU contract
and well-formed owned runtime values. `p111_rt_main` explicitly rejects other
thread/GPU modes; no callbacks or arbitrary source code execute between the probe
and store. This review does **not** establish safety under parallel mutation or a
concurrent retain racing a count-one observation. Acquire ordering alone is not
a general lock or uniqueness reservation.

Required finite controls before promotion: count1 root and interior wrappers;
raw prefix with a shared interior tail; retained left alias; right aliasing a
left suffix; wrapped static root/interior; shared heap String heads; empty left;
long mixed raw/count1 spine. On every refusal, require unchanged complete inputs
and untouched output sentinel. On success, require correct output and retained
external values, with no wrapper freeing/credit duplication. These are proposed
checks, not tests executed by this reviewer.
