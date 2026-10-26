# Independent review of serial-RFC relink measurements

Read-only source and receipt review of `serial-rfc/relink-v01.py` and
`serial-rfc/batch-relink-v01.py`, after their coordinator-owned execution.
No target executions or builds were performed by this reviewer.

No material provenance, oracle or measurement-scope defect was found.

The semantic plan joins qualified Phase143 N2 to its actual source emissions,
QBE products, retained program objects, build inputs and independent complete
stdout oracles. Atomic and serial images link the identical per-case object.
The six preliminary cases precede the remaining55. Fresh thread/GPU refusals
are recorded separately. The three source-level refusals have no program
objects and are explicitly historical; runtime relinking does not rerun them.
Process durations are retained as correctness costs, not kernel-speed claims.

The fixed-batch plan joins the qualified Phase131 native image and source to
its byte-equal native/hosted products, the actual previously measured objects,
the frozen batch manifest and unchanged result/count/elapsed observer. It
retains the same repetitions, warmups and arguments. Each case uses six pairs
with alternating runtime order; case order also rotates. Nonzero exit, stderr,
wrong output or changed input fails the observation. The minimum-duration gate
prevents reporting a speed ratio for a sub20ms result. Four selected batches
are not the full benchmark, current Phase143 code generation, or a measurement
of compiler throughput.

The helper controls include the actual candidate runtime, compare both returned
old values and complete64-bit cells to the original atomic operations, and
independently check upper-word preservation. Overflow and compute-pool refusal
are explicit failure controls. These check update semantics; they do not by
themselves prove lifetime behavior in `term_drop`.

The harnesses rely on the coordinator's outer process-tree guard in addition to
their own child deadlines and CPU3 affinity checks. The reviewed admission is
the closed native executable and fixed provider set; arbitrary concurrent C
embedding remains outside its contract. Array/printing cases alone do not
exercise file-worker threads. Actual native compiler requests exercise
NativeHost reads, while broader I/O claims need their own preserved evidence.

The subsequent integrated compiler composition has its own plan and receipt.
It reuses the exact new Phase144 N1 program object and changes its linked
runtime only. It must not inherit a claim of full native self-reproduction
qualification from these61 old program-object relinks.

## Final composition observation

The integrated relink source and plan received a separate independent review.
The coordinator then ran the same frozen Phase142 compilation with the exact
integrated N1 object and serial runtime. Its full115,909,112-byte output matches
the independent frozen oracle. Native time is249.679s against266.862s for that
same object with the atomic runtime (6.44% reduction); the current Phase143
parent observation is304.534s. The
[published receipt capsule](../../implementation/phase144/serial-rfc-full-evidence/summary.json)
checks source/carrier/oracle/image joins and retains the three full requests,
their guards, and the actual acquisition/relink receipts.

These are single full observations, with no statistical confidence bound.
They establish successful execution of this compiler workload and its actual
NativeHost read/output effects, not every provider/failure path. The supplied
image's linked runtime is proved by the relink receipt; the native-request
`runtime` field explicitly describes only a future machine-build context.
N2 self-reproduction, broad new-source native qualification and installed
selection remain absent. The original qualified runtime is retained.
