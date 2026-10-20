# P114-002 — keep recursive continuation work local

Hypothesis: generic frame/jump/return transport is a major avoidable cost even
when scalar primitives already lower to instructions. Upstream keeps the same
semantic continuation stack within its worker loop; the direct QBE route often
returns through an indirect dispatcher at every recursive edge.

First experiment: derive an exact single-capture, single-constructor unwind plan
from verified original IR. Retain frame payloads, ownership operations and
allocation order; replace internal recursion with a local descent/unwind loop.
Explicit depth prevents consuming the caller's pending frame. Native stack use
is constant. All unknown shapes keep their original emitted chunks.

Candidate04 checks successfully. Three earlier source checker failures are
preserved. Inspection admits actual list builders/mappers and String.append;
two-child recursion, non-final recursive fields and post-call projections retain
fallback. Seven ordinary generated programs pass complete output. Three paired
rounds give list-pipeline700→464ms, or1.509× faster. Tree and lexer QBE are
byte-identical to candidate31; their small timing changes are noise, not gains
or regressions. This is not broad parity.

Evidence: `selfhost/build/phase114/recursive-inspect04/report.json`,
`phase113/p114-recursive-controls04-jobs/report.json`, and
`phase112/p114-recursive-screen04-measure/report.json` beneath `selfhost/build`.
Source SHA256 `71271e22c171d23bef4f099f15032d130349ad7c6f6ca1a72018ea115f73772a`.

Next falsifiable extension: bounded captures and an ordinary acyclic private
resume call. The actual keep_gt1 continuation retains two aliases and evaluates
its predicate after recursion. Preserve that order; a constructor-only matcher
cannot admit it. A later bounded continuation table could handle two-child
recursion. Neither extension is qualified by the first result.

## Broader captured environments

The separately checked general01 extension now passes its two ordinary controls.
It admits keep_gt1 with two captured aliases and the original post-recursive
predicate. Paired three-round list time766→360ms (2.128× faster than31), lexer
393→392ms; all18 output/count observations pass. The list remains6.923× upstream.
See `phase114/general-controls-plan02.json` and
`phase112/p114-general-screen01-measure/report.json` beneath `selfhost/build`.
The original invalid local-match fixture and its unchanged-output helper repair
are retained. General02 only substitutes the independently reviewed faster
recursive-plan scan; it still needs composition qualification.

Next, actual expression eval contains six continuation identities, all with one
capture; tree scan contains two. Some resumes save the first result and descend
again into the second child. This supports a bounded local table experiment,
with exact FID/layout dispatch and a local depth boundary, instead of unbounded
native recursive calls. Implement separately, preserve the single-frame result,
and qualify real generated code before increasing scope.
