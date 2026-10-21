# P118-003: whole-compiler scale, cost and a stack-safe traversal boundary

Status: hosted cost measured; first native acquisition failed; repaired-source
small controls pass; broad exact-emission bridge and native retry pending.

## Question

Do the program-runtime improvements transfer to the compiler workload without
making optimizer acquisition or ordinary compilation prohibitively expensive?
Do the new analyses scale with the complete compiler's definition/segment lists?

## Evidence

The eight-source matched Bun cost experiment (`float-hosted-cost01/report.json`)
uses independent prepared seeds, one retained warmup and three rotated paired
rounds. Both roles call their own actual Bend `p111_emit_admitted`. All64 complete
request hashes agree with their separately built frozen emissions.

- Whole prepared-request geometric candidate/Phase117: **1.12501×**.
- Admitted optimization/emission entry: **1.18662×**.
- Guard326.614s, peak1.155GiB. Host serialization/hash is a separate clock.

This is a measured compilation-cost regression alongside the3.00893× upstream
generated-program runtime result. It is neither native N1/N2 performance nor
evidence of recursive acceleration. The experiment's complete cost includes
API acquisition, preparation, warmups and validation outside timed requests.

`native-float01-plan.json` attempted a full source acquisition through the actual
integrated entry. Frontend254.449s and runtime admission passed; integrated entry
failed after332.238s with `RangeError: Maximum call stack size exceeded.` Guard
time589.625s, peak4.859GiB, no memory/deadline kill. No N1 was built. The report did
not capture the exception stack, so no exact dynamic culprit is asserted.

Inspection of the authenticated API establishes unbounded host recursion in
the new segment/function scans and in the mature effect predicate newly reached
through observer permission. `native-stack-safe-v2.bend` converts catalogue
walks to direct-tail accumulators while preserving the exact predicates,
constructor/worker order, first diagnostic and permission refusal behavior.
The first source variant failed checking because Bend disallows matching a
computed local; v2 uses parameter accessors and explicit loop state. Both remain.

`safe-stack-controls02.json` passes22 small checks and six32768-entry checks.
The large controls run only repaired pure analyses; they do not deliberately
overflow the old host or execute malformed target programs. Exact API inspection
confirms explicit `for (;;)` loops and no direct self calls for nine catalogue
helpers (`stack-api-shape03.json`). The prior shape02 audit incorrectly searched
only for `while`; its raw snippets already show the loops and the correction is
retained. Structural nesting is still distinct from catalogue length.

## Next gate and decision

Require exact ordinary45/controls19 QBE against the timed float candidate before
retrying the complete compiler. `native-hosted-v2.mjs` preserves the original
actual entry/stage order and adds complete exception-stack capture. The retry's
6GiB process-tree ceiling is explicit, based on the observed4.86GiB peak before
emission; the16GiB available floor and serial CPU3 execution remain.

Native self-reproduction, native correctness and compiler request/build clocks
must be measured separately. Keep installed production and the qualified
Phase114 checkpoint until the new gate succeeds. A successful retry will not
erase the failed acquisition cost or establish recursive research improvement.

An empty-case invocation accidentally omitted the emitter's explicit case names;
it emitted zero programs and establishes nothing. The following plan supplies
all45 and19 names, and the independent evidence bridge requires those exact
counts and source identities.
