# P144-003 — reference counting under the admitted sequential ABI

Observation:1,834 of10,083 samples lie immediately after three locked RFC
updates. This is a sampling correlation, not an18% guaranteed saving. The
qualified runtime admits one Bend evaluator; host IO workers operate on detached
buffers and packing runs on the evaluator thread.

Hypothesis: a separately audited single-mutator runtime can replace only RFC
increment/decrement with ordinary word operations while preserving allocator,
scheduler and IO synchronization. Reject compute-worker creation explicitly.
This does not authorize arbitrary concurrent C clients or future providers.

Falsifier: relink the exact retained compiler object; do not rebuild the compiler.
The atomic control differs from the qualified object and ELF only in two
nonloaded local-symbol bytes. All loaded code/data, addresses and relocations
are identical. Check old-value/wrapping/high-word/overflow behavior, shared
lifetimes, effect completion and refusal behavior before qualification.

Early evidence:384 helper observations per mode, safe/overflow boundaries and
compute-pool refusal pass. Three small exact-QBE request pairs show candidate
ratios0.898,0.970 and0.968 for Lexer, Map and closures. One pair is a screen;
these initial observations alone did not establish a full-workload gain.

Closed semantic evidence: all61 retained program objects pass under both
runtimes, with full stdout/stderr/exit oracles, plus three fresh runtime CLI
refusals. The three compiler-stage refusals without objects remain historical.
Six balanced fixed-batch pairs on preserved Phase131 code give ratios1.0018
(Map),0.9949 (records),0.9782 (BST),0.9623 (Unicode). This is modest transfer,
not a large general program-speed improvement or a full45-program campaign.

The new integrated Phase144 N1 object was also relinked with the serial runtime.
On the identical frozen Phase142 source and115,909,112-byte QBE oracle,
its native request falls266.862→249.679s (−6.44%). Current Phase143 parent
304.534s gives18.01% combined source+runtime reduction. One clean observation
per role, same CPU3/flags/Base, no cache flush or confidence interval. Child
RSS remains approximately1GiB. This full compiler execution exercises current
NativeHost read/output paths, not every provider failure/cleanup path.

[Full request and relink receipts](../../implementation/phase144/serial-rfc-full-evidence/summary.json)
separate the actual linked runtime from the request tool's future-build context.
There is no new N2 reproduction, installation, default selection, parallel ABI
support or recursive-improvement claim. Keep the qualified atomic runtime.

[Source/machine audit](../../research/phase144/serial-rfc.md),
[independent boundary review](../../implementation/phase144/serial-rfc-safety-review.md),
and frozen methods under `selfhost/tools/performance/phase144/serial-rfc/`.
