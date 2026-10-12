# Native compilation requests

The C target is implemented in Bend under `selfhost/src/back/native/`. B1 and
B2 are JavaScript compiler images; both produce C source which Clang builds
separately. Compiler request latency, Clang time and generated-program execution
are different measurements. See the [Phase75 design](../../design/phase75/native-compilation-parity.md)
and [report](../../implementation/phase75/README.md).

The checked driver shares an immutable indexed context between annotation and
runtime-layout validation. It then asks Bend to create an `NR_Request` containing
the source context, ordered reachable names, erased ordinary bodies, foreign
paths and foreign scope. This is a request-local product, not a cross-request
cache. Foreign wrappers retain their fresh-ID-dependent construction. The source
book remains available for ownership and binder-range validation; generated IDs
must never substitute for those checks.

Static constructor preparation consumes the retained erased bodies. The same
private definition fact can retain runtime arity, with an explicit presence bit.
Only the owned checked request computes it in advance. Raw static preparation
adds no telescope evaluation, preserving raw demand/error behavior.

`NF_Plan` chooses and admits ordinary/product workers before generic lowering
when the checked representation certificate permits it and the reachable program
has no bang calls. Generic scheduler bodies and device fallbacks remain. An
experiment omitting already-admitted host bodies reduced compilation time but
caused repeatable generated-program regressions through changed native layout;
that permission path was removed. Bang/raw paths retain their original error
order: failed generic lowering returns before optional worker planning.

Private constructor lookup shares a depth-first, first-winner index across the
request. Static preparation retains that index. Variable-use analysis has a
separate compact U32 set, with exact full-width keys and no allocation on repeated
insertion. It retains Var-as-leaf behavior even for malformed raw terms.

Product-route retry retains prior code unless that function references a
withdrawn product signature. Constructor facts and other lowering inputs do not
change in this retry. Observer routing and worker admission rules are preserved.

Trust reporting is independent of optimization. One Bend result supplies both
the verdict and ordered unsafe-definition names. A fully completed safe dependency
walk may share its safety facts with subsequent roots in the same immutable
book. A walk that encounters unsafe code contributes no such facts. Public
`driver_report` and `driver_bad_names` remain available as differential oracles.

For a small edit, use the checked B1 workflow in
[PHASE5_DEVELOPMENT](../PHASE5_DEVELOPMENT.md), then the three-source compilation
screen and exact C comparison. Run raw/native integration, genuine B2/B3 and the
twelve-family runtime comparison when selecting a release. The
[Phase75 methods](../../selfhost/tools/performance/phase75/README.md) document the
commands and limits. Avoid running large validations after every minor edit.
