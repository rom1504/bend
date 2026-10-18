# Native streaming contingency — inactive, unvalidated source

`stream-native.bend` is an optional IO consumer over the existing checked
frontend, structured lowering, verifier and QBE emitters. It is deliberately
absent from `modules.txt`, `entry.bend` and every previously frozen source.
No compilation or target execution was performed when preparing it.

The current native entry accumulates all function/data strings before its
first `IO.print`. For the full compiler's 50.7 MB QBE module, ASCII `SCon`
nodes alone can occupy roughly 0.8 GB at two eight-byte fields per character,
before intermediate strings, allocator overhead, IR and frontend state.
This is a storage estimate, not a measured attribution of the running job.

The fallback runs exactly the existing preparation, planning, runtime-provider
admission, lowering and IR-verification operations, in that order. Every gate
finishes before output begins. It then constructs the ID indexes and detached
typed metadata once, consumes the segment list one function at a time, consumes
the data objects one at a time, and prints the process entry last. It calls the
existing `p111q_segment`, `p111q_tables`, `p111q_data` and `p111q_main`; it contains
no second lowering algorithm, formatter or runtime ABI.

Each `IO.print` receives exactly one of the old chunks, in the old order, so its
extra newline is preserved byte for byte. There is no diagnostic output on
stdout or stderr on success. Gate failures preserve existing exit status and
error prefixes. I/O failure after printing starts can leave partial output, as
the current materializing consumer already can.

Ownership is intentional: `p111s_print_ready` consumes the outer program, and
the IO continuation retains only remaining segments, IDs and detached tables.
It cannot retain already emitted bodies through a whole-program alias. The
tables contain scalar metadata, names and relocations, not instruction bodies.
This still holds all metadata and formats one complete data table at a time;
it does not claim a constant-memory frontend, lowering pass or module printer.

## Exact optional integration

Only after deciding to test this fallback, prepare a new source snapshot with
the regular module list, this additional module, and a copied entry containing
the following single call-site replacement:

```diff
--- entry.bend
+++ entry-stream.bend
@@
-        u => p111_native_request(path,base,cache,stamp,String.eq(mode,"cache")),
+        u => p111s_native_request(path,base,cache,stamp,String.eq(mode,"cache")),
```

Keep `p111_compile_source` and all existing pure APIs unchanged. There is no
need to replace the current main or alter module selection in the checkout.
For the preparation tool, pass all original `--module` paths, then
`--module experimental/stream-native.bend`, then the copied entry path, and
`--without-entry` so the regular entry is not appended again. Paths supplied to
the tool should be absolute or relative to the invocation's working directory.

The small duplicated code here is gate/IO adaptation, not compiler semantics.
If the fallback becomes selected long term, factor preparation through lowering
into a shared program-result helper and retain two consumers. That cleanup is
unnecessary for a bounded contingency experiment.

## Required checks, in order

1. Check the new module and copied entry with the real Bend checker. Confirm
   the current selection/frozen-source hashes remain unchanged.
2. On the existing focused fixtures, compare native raw stdout exactly against
   `p111_compile_source(...).chunks` joined with one added LF per chunk. Require
   successful exit, empty stderr and unchanged semantic outputs after QBE
   assembly/linking. Include a multi-segment continuation/closure case, IO,
   Unicode metadata and an empty metadata table.
3. On the existing invalid-source, unavailable-provider and malformed-IR
   controls, require refusal before the first stdout byte and unchanged error
   prefix/status. Malformed IR can exercise `p111s_print_verified` only after
   calling the real verifier; passing an invented empty error is not admission.
4. Run the full source once under the same memory/time guard. Compare raw QBE
   bytes with the frozen materializing output for that exact source, then the
   usual native semantic gate. Record first-output time, wall time and peak RSS.

Do not compare the newly compiled streaming compiler's own source against a
different materializing compiler source and call byte differences a failure.
Both emitters must receive the same frozen input and authenticated Base/cache.
If checking or lowering is the bottleneck, streaming may not improve time or
prevent the existing memory limit. Absence of early output alone does not
identify the active phase.
