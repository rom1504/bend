# P87-003: linear native output builders

Status: isolated candidate validated; not promoted. [Design](../../design/phase87/native-compiler-investigation.md).

The exact native B1 five-request Lexer profile has10,983 delivered samples,
zero overruns/drops and99.9999% sampled-thread/process CPU coverage. The two
String.append symbols account for67.39% of whole-process samples, including
Base preparation. This is mechanism evidence, not a predicted removable-time
fraction; append appears in many callers and runtime costs overlap conceptually.

Source inspection finds growing-left concatenation in nt_lines_go, nt_join_go
and ne_segments_go. Test a general linear implementation: reverse characters
for indentation, reverse chunks then prepend each chunk once for joins/segments.
Keep entry, runtime, upstream and production untouched. Do not change a runtime
ownership check. Retain raw/custom runtime scanner behavior.

Use exact helper edge controls then one isolated checked compiler acquisition
and Clang build. Require complete C equality against independent installed B2,
first/fifth timings and no hidden failed Map. Include same-entry JS sibling to
detect representation tradeoffs. The prepared session timings exclude Base;
retain full-process times as well. Candidate success is not promotion/native B2.

Patch: [linear-builders.patch](../../implementation/phase87/linear-builders.patch).
Results: [Phase87 report](../../implementation/phase87/README.md).

Result:26 additional physical Bend lines;21 edge assertions pass on both hosts.
Lexer first/fifth improves8.2–8.9×/13.8–14.4× across historical and fresh pairs;
Numeric1.45–1.74×/1.81–2.08×. Small changes little. Post-profile append share9.01%
versus67.39%, while absolute release-cost estimate stays~3.8s over the five-call
process. Exact C holds on successful source checks. Native Map still fails; Base
still~3s; wider JS/native admission and native B2 remain future gates.
