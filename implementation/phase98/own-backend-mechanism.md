# Observer mechanism in the actual self-generated C

The complete C emitted by the new native B1 for source `2a72bbdc…` contains the
borrowed String comparison route intended for the B2 image. This is a separate
backend observation from the earlier upstream-generated B1 C audit. The
[exact-span report](../../selfhost/tools/performance/phase98/comparison/origin-self-c-mechanism01.json)
pins both complete C files, their successful producer receipts, the common input
compiler source, every mapped route and the inspected function spans. Its
[method](../../selfhost/tools/performance/phase98/comparison/origin-self-c-mechanism.py)
runs no target and changes neither C file.

The comparison is between
[`origin-b1-self01/output.1.c`](../../selfhost/build/phase98/origin-b1-self01/execution/output.1.c)
(`6ae1675a…`, 38,327,511 bytes) and old native07's output for the **same source**,
[`origin-reference01/output.1.c`](../../selfhost/build/phase98/origin-reference01/execution/output.1.c)
(`cd335843…`, 38,307,512 bytes). The new header changes
`NATIVE_READONLY_OBSERVERS` from 0 to 1. `NATIVE_PACK_CTORS` remains 1;
typed scalars, cold user constructors, scalar arrays and unshared arrays remain 0.

The new C contains seven concrete observer workers and their seven adapters;
the reference contains none. Each name below is decoded from its exact numeric
`NF_FID_` symbol, and the report records the matching definition and caller.

| Original owner | Actual entry route |
| --- | --- |
| `p88_string_eq_go` | Shared-root guard calls `$observer.adapter.p88_string_eq_go`. |
| `p98_eq_finish` | Shared-root guard calls `$observer.adapter.p98_eq_finish`. |
| `String.is_empty` | Shared-root guard calls its observer adapter. |
| `index_hash` | Shared-root guard calls its observer adapter. |
| `f_head` | Shared-root guard calls its observer adapter. |
| `dg_import_tail` | Shared-root guard calls its observer adapter. |
| `String.cmp` | CPU scheduler entry `$direct.String.cmp` calls its product-result adapter under `NATIVE_READONLY_OBSERVERS`. |

The decisive equality change is at
[`p88_string_eq_go`](../../selfhost/build/phase98/origin-b1-self01/execution/output.1.c:77531).
A new guard dispatches when either root is reference counted with count greater
than one. Removing that one redirect line recovers the reference worker
byte-for-byte, including its `ctr_take`, `spare_free` and field-disposal fallback.
The new
[`$observer.p88_string_eq_go`](../../selfhost/build/phase98/origin-b1-self01/execution/output.1.c:41639)
instead uses `term_peek` and direct `e.mem` field reads, compares the complete U32
character values, and advances both cursors with `goto nf_again`. Its entire
body has no `ctr_take`, `spare_free`, `term_sink`, `term_keep` or `heap_alloc` call.
The unchanged runtime `term_peek` reads the location through `rfc_view`; the
unchanged consuming `ctr_take` can free the reference cell or call `span_fade`.

The
[`owning adapter`](../../selfhost/build/phase98/origin-b1-self01/execution/output.1.c:41721)
saves both incoming roots, calls the observer, then sinks both saved roots after
successful observation. The public `p88_string_eq` wrapper is identical in the
two C products: it retains both roots before calling the walker and passes them
to `p98_eq_finish` afterward. These exact bodies establish the intended static
separation between borrowed traversal and owning disposal on this route.

The tag boundary is narrower. `p98_tag_eq`, `p98_tag_eq_read` and
`p98_tag_eq_finish` are byte-identical in both products. The generic `KTerm`
branch of
[`p98_tag_eq_read`](../../selfhost/build/phase98/origin-b1-self01/execution/output.1.c:76806)
still uses `ctr_take` and disposes unused fields before calling
`p88_string_eq_go`. There is no `$observer.p98_tag_eq_read` definition. Thus the
generic tag comparison reaches the new String observer indirectly; this C does
not demonstrate a newly borrowed `KTerm` projection.

This is static mechanism evidence. The mapped route names are not counts of
dynamic calls or saved allocations, and no aggregate RC reduction or speedup is
inferred. Runtime lifetime safety, B2 execution and qualification remain separate
checks.
