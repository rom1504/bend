# P93-001: original45 native generated-program runtime

User request: benchmark the 45 historical JS catalog points using the native
compiler. [Frozen design](../../design/phase93/native-program-runtime.md).

Question: what runtime ratio do the native B1/B2 products attain against the
pinned upstream C backend on identical workloads and Clang settings?

Correctness requires exact full outputs and every batch result checked; B1/B2
product equality permits one runtime sample stream for both stages. Measurement
requires calibrated in-program intervals and explicit aggregation. This phase
does not promote a compiler change. Failures and optimized-away work remain
visible. Results belong in [the report](../../implementation/phase93/README.md).
