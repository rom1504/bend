# String append: existing destination passing, missing spine reuse

Source/machine audit only. No compiler, runtime, or benchmark target was run for
this note. The qualified Phase143 source, runtime, ELF and QBE identities are
the ones recorded in [emission.md](emission.md). Focused extracts and the actual
profile rows are retained in
`selfhost/tools/performance/phase144/emission/string-append/`.

## What is actually executing

The qualified QBE image already uses a constructor-tail destination worker for
String.append. The61-line function at QBE line49248 loops over the left spine,
calls `p125_rt_take2`, appends a new private node with `p118_rt_extend1`, and
finishes through `p118_rt_finish`. The8-line public direct wrapper at49310 calls
that worker with empty root/parent. The corresponding machine worker has74
disassembly instruction rows including alignment, two helper calls per cons,
and a local backedge. It does not schedule a continuation for each character.

Its two helpers still destroy and rebuild the cons spine. `ctr_take` can return
a uniquely transferred dynamic cell, but `p125_rt_take2` immediately passes that
cell to `spare_free`. `p118_rt_extend1` separately calls `heap_alloc`, seals the
head as required, initializes the tail hole, and fills the previous destination.
Thus a generic removal of recursive continuations is already implemented;
ownership-preserving whole-spine composition is the remaining stronger idea.

The fresh profile's String.append active context contains543/10083 samples
(5.385%). Within those543, take2 accounts154, extend1 accounts103, destination
fill111 including its cold outline, the generated worker54, rfc_wrap33, and
heap allocation28. These are disjoint physical leaves within this particular
active context. They are not all calls to String.append: synchronous private
calls can retain another dispatch context. Conversely, the context is not an
exclusive source call tree. The root's350 samples in the render interval imply
about11.2s at32ms sampling, not11.2s guaranteed saveable time. Do not add global
drop/allocation fractions to this context as if independent.

## Comparison with available C implementations

The actual retained mature C String.append on the independent Unicode workload
uses `p102_trmc_keep_cell(ctr_take(...))` followed by
`p102_trmc_take_cell(...)`. It preserves a matching exclusive cell across
reconstruction; shared/static inputs allocate normally. Exact source:
`selfhost/build/phase102/native-chain04/runtime-continuity/36-coverage-unicode-text-64/output.1.c`,
lines1645–1660 and3226–3340. This is an older user-program product, not a
same-source measurement of the current compiler.

The retained pinned-upstream C product for the same Unicode workload instead
uses an explicit continuation for String.append, frees the taken cell and
allocates during resume (Phase93 `upstream.1.c`:2099–2155). Current repository
`bend2/comp.ts:1046` and`:1603` has generic spare-cell reuse in compatible
tail-position construction, but that capability alone does not prove it applies
to a particular append product. Therefore neither current QBE nor upstream C
can be called uniformly superior from these source shapes. A fresh same-source
C compiler comparison remains unmeasured.

Do not resurrect generic TRMC cell credits as a new discovery. The Phase118
[reuse audit](../../selfhost/tools/performance/phase118/trmc-reuse-audit.md)
already records a negative QBE result (list197→210ms), plus a separate sized-ABI
ablation. More parameters, helper transitions, and missed specialization can
cost more than the eliminated allocator free-list operations.

## The cheapest stronger falsifier uses an existing capability

Phase125 already introduced `p125_rt_concat_typed`. On a source-certified
structural append, it checks the complete owned left spine without mutating it;
if every node is dynamically exclusive, it attaches the right suffix once and
returns the original left root. Heads and RFC wrappers remain untouched. A
shared or static path refuses with both operands still owned by the caller,
which executes its original complete worker. This removes take, reconstruction,
allocation and destination-fill work together, rather than speeding up just one
allocator operation.

The selected source still contains the full source certificate and integration
(`p125p_admitted`:52403; `p121f_selected`:51981). Yet the actual String.append
direct wrapper contains no `p125_rt_concat_typed` call. That is a concrete
composition/admission gap, not evidence that runtime uniqueness succeeds on
rendered Strings. The refusal point is not established by this static audit.
`inspect-v01.bend` exposes the unchanged admission subconditions on an actual
checked request without altering any compiler or verifier body. Inspect those
bits before changing the lowering path. If certification succeeds, trace the
selected candidate to the final wrapper and preserve the certificate when
installing the operation; do not emit this import based on a function name.

Required controls remain the independently checked Phase125 owned-append cases:
retained whole/interior aliases, overlapping suffixes, static inputs, empty
left/right, heap String heads, deep spines, changed equations, and exact fallback
outputs. Add actual String.append and an unrelated structural List append, and
confirm the helper call is present on the hot caller. Measure successes and
refusals separately from clean runtime. The first screen should test complete
function render/output and an unrelated concatenation workload, followed by
the same full compiler request only if this removes real work. No performance
claim is established by these prepared diagnostics.

## Actual refusal and isolated repair

The root executed `selfhost/build/phase144/append-inspect01/report.json` in2.988s.
The actual library String.append passes the bounded syntax, exact append
equations, parameter/result type, and two-constructor owner predicates. Only
`j_fusion_def` refuses it. The reason is `db(d)`: **this is the native-library
flag, not ownership** (`KDef.native`:source47; getter5743). The first diagnostic
unfortunately called this field `owned`; its immutable receipt is retained and
`inspect-v02.bend` corrects that label to `native`. No ownership conclusion
should be drawn from the old label.

Base-library source definitions are native-marked even when the C/QBE backend
uses their ordinary checked bodies. `nc_native_def` distinguishes actual runtime
intrinsic substitution from these source implementations; its classifier is
also used by the existing private-candidate gate. Therefore the narrow repair
does not change global `j_fusion_def`. It replaces that guard only within
`p125p_admitted` with Def/arity2/templates0, **not nc_native_def**, and **not
Foreign/Absent**. All existing append equation/type/closed-owner checks remain
byte-identical. A native-marked true primitive must still refuse even if supplied
fabricated append-like metadata. Ordinary source functions with native-looking
spelling continue to follow their actual source semantics.

The isolated candidate is `selfhost/build/phase144/append-source01/compiler.bend`,
SHA256`913b0987502a1b420fc905836afc663995737b8e60498df58e2f006a4b022601`.
Its manifest records three overrides: append admission, the transport whitelist,
and the historical transport control that deliberately refused concat. No
runtime implementation or full verifier changes. It is prepared, not checked or
native-qualified at the time of this audit.

The transport addition is necessary independently of append semantics. The
existing helper uses `state->e` heap state and constructor metadata; it does not
read/write scheduler registers, retain their address, schedule Bend code, or
invoke callbacks. The unchanged full import verifier separately proves argument
and result widths, constructor presence/arity/distinction, and ordinary local
types. Extending the explicit allowed-symbol predicate is justified by these
exact runtime effects; setting a descriptor capability bit directly would not
be justified. The original divmod pointer/buffer/alias controls remain intact.

`controls-v01.bend` adds23 finite cases, including actual full-verifier rejection
of wrong constructor arities, wrong widths, missing/aliased constructor names,
state-as-word, incomplete arguments, and an unknown import. Existing12 append
equation/factory controls and20 transport controls should also pass. The new
ordinary fixture has11 independently written output lines covering fresh,
shared/interior/overlapping/static/Unicode/empty/deep Strings; existing Phase125
owned-list controls provide unrelated structural-list and opaque-head transfer.
None fabricates a runtime heap graph. Clean performance and any dynamic helper
success counters remain root-owned follow-up work.

## If exclusive-spine admission rarely succeeds

The alternative is to remove the flattening boundary itself. A typed generic
`File.write_fragments(List<String>)` can consume ordered owned fragments and
marshal their UTF-8 into one bounded native byte buffer per write operation,
without constructing a complete linked body String. QBE formatting and fragment
ordering remain Bend code; the runtime only marshals ordinary Strings. Pure
String emission remains the independent byte oracle.

This is a new effect/provider contract, not an existing File.write ABI trick.
It must specify fragment ownership on success/error, partial writes, ordering,
UTF-8 across fragments, empty fragments, resource bounds, and exact supported
Char encoding. File.write_bytes currently consumes linked bytes, so merely
switching its argument type does not supply packed storage. The economical
falsifier is one real renderer returning fragments, one generic write, and exact
ordinary byte/error controls. Per-fragment IO effects and another packet-join
loop would repeat the failed Phase134 batching approach.

## Isolated runtime screen

The root-run frozen four-case comparison now passes eight native smokes and 32
complete-output timing observations. Unicode16 and Unicode64 median runtime
ratios are 0.97865 and 0.96174; their only QBE change is the guarded verified
concat call ahead of the identical existing String.append fallback. Capability15
is unchanged. RLE improves to 0.91097, but its sole QBE change is capability11→15:
this is a register-transport certificate recovery, not a new append algorithm.
The unrelated List128 control is byte-identical and runs the exact same
executable in both roles. Its apparent1.06154 ratio at31–38ms therefore measures
variation, not a code regression. We did not spend another campaign chasing that
unchanged-binary difference. See
[the detailed screen](../../selfhost/tools/performance/phase144/emission/string-append/BENCHMARK.md)
and its pinned audit for raw arrays and exact QBE edits. Full compiler benefit
and broad qualification are still separate obligations.
