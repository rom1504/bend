# Staged full-input diagnosis

Root invokes `staged-emit.mjs API INPUT FRESH_OUT cache|live` with the pinned Bun
executable under the existing CPU3 process-tree guard. It is a separate diagnostic
transport; `emit.mjs` is unchanged. No target was executed during preparation.

The checked API must export `p88_cache_prepare`, `p86_prepare`, `p86_plan`,
`p111_runtime_admission`, `p111_lower_request`, `p111_verify_program` and
`p111q_chunks`. Preparation, checked frontend, runtime-provider admission,
lowering, verification and QBE generation remain Bend calls in the same order
as the updated entry. Tagged preparation, plan and lowering results are checked
explicitly. Source/Base/cache bytes come from authenticated selected assets;
the diagnostic accepts no externally supplied graph or semantic certificate.

`report.json` and stdout progress identify every stage before it starts and after
it finishes. A thrown error preserves its stage and diagnostic; a guard kill
leaves the active stage marked running, with the guard receipt supplying the
termination. `compilerSeconds` includes only the Bend API calls. Input reading,
API import, metadata counting, writing and final file authentication have separate
clocks. The outer guard remains the complete process-cost measurement.

The only graph inspection is a read-only List traversal for request sizes,
segment count, maximum arity/result/incoming widths, constructor count/maximum
arity and descriptor counts. No complete graph JSON is created. These counts
diagnose capacity; they neither implement admission nor modify the graph.
QBE chunks are written exactly as `emit.mjs`: each returned String plus LF.
Output authentication streams the saved file rather than loading it whole.

RSS is sampled from Linux `/proc/self/status` at stage boundaries, with the
process-lifetime high-water value. It is not an isolated stage peak or a full
process-tree measurement. The tool does not force GC; it releases obsolete host
references after each boundary, so this is a staged hosted diagnostic rather
than an identical-lifetime profile of the monolithic entry.

Before using a full compiler input, root should compare the staged QBE product
byte-for-byte with ordinary `emit.mjs` on one already qualified small source
using the same API/assets. Then use the assembled Phase111 source, preserving
all failure receipts. Neither a successful hosted emission nor metadata counts
qualify a native compiler or direct self-hosting.
