# P77-005: retain the compiler process across native requests

This is a retrospective record of the Phase77 discriminator, not a preregistration.
Keep ordinary B2 and upstream processes equally warm; load/check each request's
source again. Separate warm speed from cold requests and preparation costs.

The first three separate-program screens suggested0.83–0.90× upstream. A broader
actual-tool test rotates five programs across six rounds per role and measures
1.100× overall,1.114× excluding the first round,1.098× on the final three.
All60 C outputs are exact; function-heavy code remains slower. Session identity
hashing costs about30ms/request and is included. No steady-state parity is claimed.

Accept the serial session tool with bounded request count/RSS recycling, immutable
compiler/Base identities, source-edit/error-isolation controls and installed CLI
output-preservation/alias checks. It caches no user program or native code.
[Report](../../implementation/phase77/README.md), [usage](../../docs/self_hosted/NATIVE_COMPILATION.md).
