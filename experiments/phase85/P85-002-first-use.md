# P85-002: first-use versus repeated compiler execution

Status: completed; substantial directly observed V8 compilation CPU.
[Design](../../design/phase85/v8-compiler-execution.md) ·
[Report](../../implementation/phase85/README.md).

Hypothesis: a substantial part of B2's fresh-request gap is sensitive to V8
tiering, rather than unavoidable semantic work. Three rotated clean rounds of
five ordinary requests on Numeric/Map/Functions65/Lexer establish the effect.
Separate CPU/tier/GC evidence and supported tier ceilings investigate mechanism.
Repeated calls do not reuse a persistent inspector or result cache; process reuse
still changes many states and must not be called pure JIT savings. Upstream
retains its existing load/check/emit boundary, without its CLI proof report.

Accept a mechanism only after a bounded exact-output intervention or direct
timeline evidence. Report first, later and import-plus-first clocks separately.
Do not promote flags or warm results as a new cold compilation metric. Production
and installed Phase82 remain unchanged.

First/fifth four-source B2/TS ratios1.394/0.989; not steady-state or every-source
parity. Thread CPU compilation differences account for96.1%/64.6% of Numeric/
Functions65 observed CPU gaps in one instrumented pair each. Maglev-only improves
cold B2 time21.5% but worsens fifth time17.5%; TS improves even more cold. Paired
two-CPU affinity improves B2 cold time38.8%, TS34.7%; relative parity remains open.
Keep flags, warm-process and hardware results separate from installed metrics.
