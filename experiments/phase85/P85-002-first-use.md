# P85-002: first-use versus repeated compiler execution

Status: registered; investigation only. [Design](../../design/phase85/v8-compiler-execution.md).

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
