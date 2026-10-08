# P68-013: assemble native runtime sections without rescanning generated C

Registered before candidate application or target execution. Source owner:
p68_upstream; root owns serial CPU3 compiler and target runs.

Actual inline09 B2 CPU profiles attribute 149.7/136.1/173.2ms to ne_program's
runtime injection for numeric/array/lexer. Its four sequential nt_replace passes
walk 1.471M/1.502M/1.907M characters through growing generated C. The unchanged
runtime is 82,017 characters and the final injection marker starts at 80,046.
Pinned upstream comp.ts:3250 instead interpolates four assembled sections directly
at lines3565/4302/4349/5929. These are sampled costs and static counts, not a
promised end-to-end gain.

Hypothesis: split only the original runtime at the four ordered first section
headers, then concatenate the generated sections between those pieces. Require
a newline immediately after every recognized header. Before taking this fast
path, scan each of the first three generated sections for the marker prefix //,
using a pure tail scanner with no substring comparison or text construction per
character. The last Requests insertion needs no guard because the old algorithm
never searches after inserting it. Actual09 and10 numeric/array/lexer first-three
payloads contain no //; Requests contains six occurrences and must be excluded.

Missing, reordered, malformed headers or suspicious generated payloads retain
the exact old sequential ne_fill/nt_replace algorithm. This preserves first-match
behavior on arbitrary runtime text, injected markers, absent sections and unusual
caller-provided IR. Runtime source bytes and emitted code semantics do not change.
The fast path still validates generated payloads once; it avoids repeated scans
of already assembled output. It is not a claim of zero text traversal.

First gates: source proof/review of marker and splice boundaries; checked compiler
build; actual B1/B2 helper discrimination proving the fast route is entered on
real payloads and fallback on adversarial custom inputs; exact full-C equality;
existing native correctness controls; matched C-request measurements/profile.
Do not infer success from Python restatement or a control that only exercises
fallback. No production edits or target runs are performed by this source lane.
