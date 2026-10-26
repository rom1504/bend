# Why speculative append can regress

This optional diagnostic reuses the generic native profiler's exact runtime
materialization, counter storage/JSON, build driver and original ABI counter
control. No frozen generic profiler file is modified. The additive extension
appends seven named counters, preserving the first16 names/order:

- attempted typed concat calls;
- left-spine nodes inspected, including a node that causes refusal;
- successful empty-left returns;
- successful nonempty splices;
- refusals at a static term;
- refusals at a shared RFC cell;
- refusals where a heap wrapper targets a static constructor.

Every hook is inserted around the original decision, without another heap read,
condition evaluation, mutation or ownership operation. Removing the extension
and ordinary profiler hooks reproduces the complete original runtime; removing
seven enum/name additions reproduces the original support include. The existing
profiler remains responsible for overflow, context and output handling.

`commands-v01.sh` is prepared for the root CPU3 lane only. It relinks the retained
final03 row32 and Unicode64 program objects against one diagnostic runtime,
checks the original independently frozen16-channel fixture plus seven expected
zero columns, then runs each ordinary program with counters off/on. These
programs exercise the earlier admitted String append; they are not re-emitted by
the reverted source04 compiler. Exact semantic output and success counts use the
unchanged benchmark observer, with explicitly diagnostic repetitions 1 / warmups 0.

Counts cover the complete invocation, including output validation and wrapper
work. They do not isolate the timed kernel or establish source-level allocation
origins. Private helpers retain their current outer dispatch ID. There are no
performance claims from instrumented elapsed times. Positive hook labels are
source-audited and must satisfy attempt/success/refusal conservation; the old ABI
fixture independently validates old channels and zero new channels, not positive
coverage of every new refusal branch. A separate exact branch fixture would be
needed to promote this into a fully qualified generic profiler extension.

The motivating broad result is row32's confirmed regression under speculative
String append admission, despite smaller Unicode gains. A failed ownership scan
followed by the unchanged fallback adds work. The compiler's admission reversal
is independently justified by repeated clean timings; this diagnostic is useful
for explaining that result and future profitability rules, not for delaying the
reversal or weakening ownership checks.

The prepared runtime is explicitly the **atomic Phase128** source
`6eb24c8d4a5d6358a9b8b4107a75af777a8dbdd06fe5fdce18d73b9f85f4824a`,
compiled with `-O2 -std=gnu11 -ffp-contract=off`. There is no serial-RFC macro.
This matches the `codegen` products used for the isolated clean row32 regression
comparison. It is not a diagnostic profile of the subsequently selected serial
runtime, and must not inherit that runtime's performance or qualification claims.

The root has now executed all three jobs successfully. Row32 recorded 2,064
attempts, 196 successful splices and 1,868 refusals (90.50%); Unicode64 recorded 1,412
attempts, 642 successful splices and 770 refusals (54.53%). All disabled/enabled
ordinary outputs and the exact original ABI control passed. The complete
[source-pinned analysis](../../../../../../../research/phase144/concat-profile.md)
separates the observed counts from timing and qualification claims. The offline
`summarize-v01.py` records the aggregation method and authenticates its inputs;
it writes the fixed research JSON path and refuses to overwrite that published
receipt. Reproduction therefore requires an independent checkout without that
generated summary, with the original pinned evidence paths available.
