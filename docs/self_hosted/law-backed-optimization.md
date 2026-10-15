# Laws for compiler optimization

The [Phase94 pilot](../../implementation/phase94/README.md) proves equivalence
of an environment-preparation helper and embeds that exact helper in a native
compiler candidate. It establishes a practical method; the candidate is not
the default compiler because its end-to-end performance was neutral.

The useful unit is a small, pure operation with an explicit specification:

1. Write the reference result, including ordering and ownership/drop information.
2. Freeze it before evaluating performance changes.
3. Prove the replacement equal for all admitted inputs in safe Bend.
4. Independently check the complete elaboration with upstream BendTT/Lean.
5. Require deliberately wrong replacements to fail, and test unsafe boundaries.
6. Bind the checked helper bytes to the actual compiler and measure both the
   helper and real compilation. Promote only for sufficient benefit.

The [safe helper, reference and proof](../../selfhost/proofs/phase94/README.md)
illustrate this method. The theorem preserves the exact live binding list and
drop accumulator even with duplicates and arbitrary pure total callbacks.
It does not prove the unsafe adapters, liveness analysis, C backend or runtime.
Finite tests and exact product comparisons cover different obligations.

Independent verdicts take about 0.3 seconds after a roughly 53-second kernel
module build; source checking, elaboration and initial toolchain authentication
are separate costs. See the [commands and evidence](../../selfhost/tools/performance/phase94/README.md).

The local helper saved 18–39% time, but the compiler screen was 0.997× baseline:
effectively unchanged. Choose subsequent proof targets using measured inclusive
cost, not merely how convenient they are to specify. Production correctness,
compilation latency, generated-program runtime and simplicity remain separate
promotion criteria.

The [Phase95 follow-up](../../implementation/phase95/README.md) attributes cleanup
to physical callers before testing another helper. A shared-list membership scan
has large selective-hit gains but almost neutral compiler performance; miss costs
and actual hit distribution matter. Its existing unsafe mutually recursive helper
is tested, not independently proved. Reusing a familiar helper does not transfer
the Phase94 theorem to it. The profiler also loses logical tail-call ancestors,
so a large equality bucket cannot be assigned wholesale to one caller.
