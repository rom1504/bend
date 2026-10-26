# Final03 N2 serial-runtime stage profile

Prepared metadata only; root owns all six serial target/offline jobs in
`selfhost/build/phase144/final03-stages01/jobs.json`.

The compiler is final source `31e1b13a…e3ea2`, N2 ELF `22380e6a…7898e`, retained
object `8f1f055e…8341`. Diagnostic instrumentation starts from the reviewed
serial-reference-count source and compiles with
`-DP144_SINGLE_MUTATOR_RFC=1`. It does not reuse an atomic diagnostic runtime.
Removing the instrumentation reproduces the complete serial source exactly;
applying the serial transformation to the old diagnostic source produces the
same new source bytes. Both checks are recorded in `ready.json`. Thread/GPU,
provider and compute-worker refusal gates remain in that exact runtime.

The existing generic stage specification is rebound to final N2's actual
dispatch table. Once/first/optional marker semantics remain unchanged. The
qualified ordinal sampler is reused only after exact source/header equality.
Only the diagnostic runtime is compiled and the retained object relinked.

Job order: build, seal, small Lexer-revision capture, offline marker/output
admission, full frozen-Phase142 capture, offline full-stage association. Stop
before the full capture if the pilot fails. Its independent exact oracle comes
from the final checked hosted compiler's `final03-hosted-b01` output. The full
capture uses the new same-image clean `p144-final03-fixed-cold01` oracle:
115,966,145 bytes, SHA256
`ac29be094a56cb5e5125b7982a083a15b8e2d5f8c3505b7c1e484c65675abd36`.
The source input remains unchanged Phase142; final03 legitimately emits
different QBE from source01, so the previous output is not silently reused.

Method: `selfhost/tools/performance/phase144/profile/final-stages-v1.py`.
All target jobs retain CPU3, 3GiB RSS, 16GiB available-memory floor and bounded
time/file limits. The profile does not promote the compiler, establish broad
conformance, or turn diagnostic clocks into clean timings. It can identify the
remaining stage costs after append, predicate and serial-runtime composition;
the earlier source01 profile cannot substitute for this execution.
