# Compiler analysis facts and their lifetime

The installed compiler remains Phase78. The
[Phase80 implementation experiments](../../implementation/phase80/README.md)
are preserved separately and are not enabled by this document.

The frontend keeps two related graphs. `KWorld.book` is the chronological
semantic world used for checking and specialization. `KWorld.checked` retains
completed checked output. Finalization chooses the output definitions that
backends will consume. A type normalized before a later law fill is not
automatically reusable in the final world.

`annotate_selected` reconstructs backend types on the reachable definitions.
Annotations retain normalized type heads and constructor-field quantities.
Checked layout validation consumes those quantities. The prepared Base world
is bound to compiler/source/ABI identities and binder-range invariants; attaching
checking-local fresh IDs can invalidate that permission even when the source
program still checks.

The native `NR_Request` then retains ordered reachable names, erased ordinary
bodies and arities, foreign paths and scope. Static preparation can retain both
the prepared body and its original erased form. Consumers use the appropriate
body for their analysis. These are per-request products, not globally reusable
facts about a name. See the [native request guide](NATIVE_COMPILATION.md).

For new optimization work, identify the producer, graph version and consumer
before adding a fact. Binder IDs identify binders; they do not identify expression
nodes. Rewriting, specialization and changed environments can invalidate a
previous analysis. Exact object identity is useful observational evidence, but
term-only identity is insufficient when a function also depends on a book or
environment. Charge fact construction, transport, decoding, lookup and memory
cost to the measured workflow.

Phase80 illustrates two distinct outcomes. Retaining all checker types reduces
annotation work but makes prepared graphs and later scans more expensive. A
small body-local occurrence summary avoids repeated different-binder traversals
and needs no frontend graph change, but its measured whole-request saving is
only about2%. Both results constrain a future compact native IR: remove several
consumer walks together and demonstrate the net saving before expanding it.

The [Phase80 fast methods](../../selfhost/tools/performance/phase80/README.md)
separate exact-output screens, held-outs, CPU profiles and logical counters.
Production compiler algorithms and experimental summaries are written in Bend;
JavaScript instrumentation observes their execution only.
