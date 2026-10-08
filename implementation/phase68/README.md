# Phase68 native parity investigation and optimization

Status: investigation in progress; no new compiler promoted.
[Design](../../design/phase68/native-parity.md).

The Phase67 installed compiler and 110 inherited files are preserved. Baseline
identities and all new receipts live under `selfhost/build/phase68`; old evidence
remains closed. This phase separates native runtime, B1/B2 C request latency,
Clang time, JS protection, conformance and complexity.

Initial source audits identify missed matcher arity, scheduler continuation
transport, boxed product results and duplicate ordinary/direct emission. These
are hypotheses until the measured experiments below qualify them.

- [Upstream native comparison](../../research/phase68/upstream-native.md)
- [Primary compiler research](../../research/phase68/world-compilers.md)
- [Investigation experiment](../../experiments/phase68/P68-001-investigation.md)
- [Matcher arity experiment](../../experiments/phase68/P68-002-match-arity.md)

No Phase68 gain, parity or conformance expansion is claimed at registration.
