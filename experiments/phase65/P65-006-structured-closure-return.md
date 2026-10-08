# P65-006: preserve structured nested closure bodies

Status: registered before target execution; source-reviewed, unapplied.
Owner: output-metadata lane. Independent reviewer: correctness owner.

The no-argument live-lambda return arm currently renders its already structured
nested body through `jd_expr` → `jd_closure` → `jd_body`, then scans all of that
String again through `jd_text_raw`. Compose the same JDText body between fixed
literal prefix/suffix leaves instead. This is a one-line replacement with zero
added types, helpers or lines, distinct from P65-004's rejected multi-binder
candidate, which admitted no groups on the four-source census.

The enclosing production call proves Lam + normalized All + live quantity.
Preserve owner removal, type normalization, `$arg`, complete bytes, use/ref
order, scanner fallback and size refusal. Tree structure intentionally differs.
The [patch and receipt](../../selfhost/tools/performance/phase65/output-metadata/closure-candidate.json)
bind the change; [report](../../implementation/phase65/output-metadata.md) owns
outcomes. No gain is asserted at registration.

First use the [genuine-B2 census](../../selfhost/tools/performance/phase65/output-metadata/closure-opportunity.mjs)
against Phase64 State09 `b09fe54a…`, with the existing Phase65 baseline preparation,
four-source plan, lexical ownership and complete original output oracle. Then
root alone builds checked B1 and runs focused transport/enclosing/module
comparisons. Controls include captures/owner removal, nested/erased lambdas,
unknown/malformed/split metadata, ordered duplicate refs and cap−1/cap/cap+1.
Never compare raw JDText tree shape as the correctness oracle.

Root owns guarded serial CPU3 target execution; source/data preparation uses
CPU0. Instrumented counts are not clean performance. If admitted and exact,
use the unchanged four-source fresh-process clean campaign, keeping compiler
latency separate from unchanged generated-program execution. Reject on any
semantic discrepancy, negligible admission, request regression or noise-sized
gain that does not justify retention. Broader genuine-B2 and release gates still
precede installation. All failed attempts remain separate preserved evidence.
