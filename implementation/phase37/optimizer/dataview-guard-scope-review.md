# DataView guard scope and possible entry-cost reduction

This is author review of the guard correction, not an independent review or an
executed experiment. No source changes or timings were made for this analysis.

A complete search of the current split runtime finds one `new DataView`, in
`runtime/js/base.mjs`, at module initialization beside the four-byte buffer.
Subsequent accesses are calls on that already allocated, module-private view:

| Helper | Receiver operations | Current callers |
| --- | --- | --- |
| `bitsFloat` | `setUint32`, `getFloat32` | F32 literal emission and native F32 constructor decoding |
| `floatBits` | `setFloat32`, `getUint32` | F32 constructor matching/readback and the public `F32.bits` native |

None of these paths constructs a new view after import. Checking the live
`globalThis.DataView` binding and the captured constructor's `prototype`
property on every region entry is therefore conservative but redundant for the
current runtime: replacing those bindings cannot change the already allocated
view's receiver or own prototype. Removing those checks does not remove the
essential instance check.

The required obligation for these four property reads is that the receiver has
the captured prototype, has no own property shadowing any of the four names,
and the captured prototype still has the original own data-method values. With
those conditions, method lookup terminates at that prototype. Its parent is not
consulted, so checking that parent on every entry is also redundant for these
specific operations. The native methods use DataView internal slots; they do
not read a replaceable JavaScript `buffer` accessor to obtain storage.

A narrow follow-up could remove the two constructor/global entries from
`regionNumericHooks` and the prototype-parent comparison, saving three
reflection checks per outer entry. It must retain the instance prototype
comparison, all four instance own-property refusals and all four original
prototype method checks. A previously leaked view remains the motivating
counterexample for the own-instance checks.

Any such change still needs the existing actual DataView controls, new controls
showing that harmless constructor/global replacement can safely retain private
entry, and paired short-root timings. No numerical speed estimate follows from
counting three checks. The current source proof assumes the same initialization
environment as the existing intrinsic snapshots; this review does not establish
safety for arbitrary hostile instrumentation installed before module import.

If a later runtime feature creates a view during an admitted guarded region,
that feature introduces a fresh constructor obligation. The reasoning above
covers future executions of the current code, not unknown future source changes.
