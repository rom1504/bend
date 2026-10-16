# P102-002: remove continuation transport with typed whole-function lowering

Status: supported and implemented; native chain qualification in progress.
Registered 2026-10-16. [Campaign](../../design/phase102/ambitious-native-campaign.md).

Hypothesis: extend existing direct/scalar lowering across a larger typed region
so scanning/state-machine programs avoid repeated saves of 10–15 values.
Phase101 physical source-index profiles identify three continuations accounting
for about 34.5% of sampled leaves. Those shares are evidence of location, not a
speedup estimate or a complete ownership attribution.

Inspect existing lowering and refused shapes first. Prototype a general
structural mechanism, preserve strict calls and fallback, then measure complete
source indexing and held-out applications. Expected useful gain is conditional;
do not replace an application with handwritten code. Record compiler code size
and acquisition cost before integration.

Result: compose existing admitted NF workers through a narrow checked local-call
permission. The initial implementation checked but did not activate; source02
corrected the permission boundary, source03 the host-only segment marking.
Owning-observer forwarding then breaks an admission dependency cycle without
allowing recursive C calls. A measured4→8KiB inlining budget removes another
small hot call boundary. In the four-round inline-parent screen, source indexing
the compiler takes101.3ms versus203.2ms installed and93.85ms upstream. Generated
source indexing takes59.23ms versus62.64ms upstream. This is application runtime,
not compiler throughput, and later isolated cell reuse targets rendering.

Unchanged-ELF profiles confirm disappearance of the three original hot
continuations. They do not establish call-stack/allocation attribution. Evidence:
`phase102/typed-profile01`, `observer-profile01`, `observer-screen01`,
`inline-screen01`; see [report](../../implementation/phase102/README.md).
