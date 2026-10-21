# P118-003: whole-compiler scale, cost and a stack-safe traversal boundary

Status: complete. Broad safe03 exact45/19 bridge passes;40 analysis checks pass;
native N1/N2 qualify and matched native requests improve about26% over Phase114.
The timed hosted compiler still costs12.5% more than Phase117.

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

## Captured second failure and third candidate

The second attempt passes frontend255.526s, then fails lowering after0.966s in
`nc_pack_foreign`. Guard259.211s, peak3,929,579,520B. The complete error trace is
retained. This is an existing eager Boolean catalogue recursion, also present in
qualified Phase114; the staged host used the same lowerer. Catalogue size grew
6,186→6,384. There is no precise measured stack threshold, and the first failure
remains unattributed. Recursive calls through `nt_choose` can use a trampoline;
source recursion alone is insufficient evidence of host-stack growth.

`native-pack-stack.bend` implements the same complete finite predicate using an
explicit children-before-siblings worklist. It does not broaden permission or
skip trusted cache children. safe03 passes the earlier28 plus12 new controls,
including32768-element flat/deep inputs. Native acquisition is a fresh plan;
failed plans and their cost remain. See the independent stack diagnosis for pins.

## Completed result

safe03 passes the complete native gate in1286.036s, peak5.385GiB. Native self-request
406.614s produces85,831,654 bytes exactly matching hosted acquisition; N1/N2 each
pass focused19 and N2 passes45. Fresh native N1/N2 requests are2.09187×/2.10976×
upstream, ready stages1.01626×/1.02441×. Direct native request medians use25.70%/
25.55% less time than the contemporaneous Phase114 rerun; upstream drift is retained.
See the phase native-results JSON for every pin, sample, clock and comparison.
The native and timed-hosted sources remain distinct despite exact45/19 output
bridges. Installed production stays unchanged; no recursive acceleration claim.
