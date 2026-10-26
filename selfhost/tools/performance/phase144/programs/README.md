# Native generated-program regression screen

`runtime-v04.py prepare` freezes a root-owned two-job campaign. It does not run
compiler or program targets. The prepared jobs are
`selfhost/build/phase144/programs-plan04/jobs.json`; acquisition must complete
before measurement. Both jobs use the serial CPU3 resource guard, with a16GiB
available-memory floor. Estimated work is9–11min; caps are600s and400s.
The earlier three-role V01/plan01 remain unchanged and unconsumed; V03 adds the
independently checked experimental fast policy and stricter historical admission.
Independent review found no gate/oracle blocker in V03 but noted that four roles
over three rotations were not position-balanced. V04 uses four complete rotations;
the unconsumed V03 source and plan remain frozen.

This uses the exact Phase112/131 historical45 repetition wrappers:44 timed
programs and the original zero-work correctness control. Paths, source bytes,
runtime arguments, frozen50ms count profile×4, warmups and complete-output/count
oracle remain unchanged. Ordinary native qualification's45 small sources are a
different execution workload and cannot replace this screen.

Fresh Phase143 N2 and final03 N2 each compile every frozen wrapper. There was
no Phase143 timed-wrapper campaign to reuse. Whole-QBE byte equality may reuse
a retained Phase131 object/binary or the other current product; changed output
uses the existing branch-aligned QBE/assembler builder. Both code-generation
roles use the old runtime. Relinking the exact candidate object against the
selected serial runtime adds the third role:

| Role | Native compiler | Program runtime | Question |
|---|---|---|---|
| baseline | Qualified Phase143 N2 | Phase128 atomic | Current reference |
| codegen | Final03 N2 | Same atomic runtime | Code-generation effect |
| candidate | Final03 N2 | Selected serial runtime | Complete-product effect |
| fast | Experimental fast-policy N1 | Same serial runtime | Outer-range-pass omission |

The fast image was built by final03 N2 from the exact independently checked
source with171 finite controls. Its sole override omits the outer range pass.
This screen does not give it full native self-hosting qualification. Its image,
source, parent, runtime, API and control receipts are explicitly pinned. It also
compiles every frozen wrapper freshly; identical products can reuse objects.

Each acquired product passes the existing full output/count oracle with one
repetition before timing. The four timed roles rotate across four rounds,
giving720 observations, with every role once in every position. The report retains all commands, complete stdout/stderr,
individual intervals and per-case medians;44 eligible cases contribute to the
geometric ratios. This is a descriptive regression screen, not a confidence
interval, all-language correctness claim, or new upstream ratio. Historical
measurements are never mixed into current timing ratios.

Every historical product must have exactly three successful matching observations
at rounds0/1/2. Per-role medians below20ms are flagged as low-resolution evidence;
the flag does not silently change the frozen corpus, counts or aggregate.

Compiler emission, machine construction, reused products, runtime relinking,
correctness smokes and timed execution costs remain separate in the receipts.
No compiler source, installed selection, runtime source or benchmark definition
is changed. The initial preparer attempt encountered a missing `runtime` field
in the qualification receipt before any output or target execution; the fixed
preparer binds the runtime through the joined candidate and actual N2 build.

## Bounded completion after the timing deadline

Acquisition completed all45 cases. The400s measurement guard then stopped after
707 complete observations: all704 rows of the first44 cases and three rows of
the last case. Its original incomplete report and deadline receipt remain
unchanged. Recorded completed target executions took332.13s; another67.05s was
observer, authentication and receipt-persistence overhead. The original timing
cap underestimated complete supervisor cost.

`resume-last-v01.py` authenticates the plan, acquisition, exact original method,
deadline and all707 complete outputs through the unchanged oracle. It retains
the704 complete-case rows and excludes the three last-case rows solely because
that case is incomplete. The root job in`programs-resume-plan01/jobs.json` runs
all16 observations of that final case again, using the same products, counts and
role ordering, then joins720 observations. It neither emits nor rebuilds anything.
The excluded observations remain in the joined report. The last case is measured
in a separate time block; this limitation is explicit rather than hidden by
mixing its partial and resumed pairs.

## Observer cost recovery, prepared only

`runtime-v05.py` is a small source-only successor, not a rerun of the campaign.
During measurement it writes the growing JSON receipt once per complete case,
instead of once after recording the child job and again after recording each
observation. Each child's stdout/stderr files remain written immediately; the
same full-output oracle runs before admitting the observation. Initial and final
receipts, including ordinary exception persistence, remain. A hard kill loses
only the uncheckpointed partial case from the JSON; its raw output files remain.
Acquisition checkpoint behavior is unchanged.

For the actual completed720-observation corpus, source-derived accounting gives
**1,442→47 receipt writes** and **1,038,960→34,560 serialized job/row entries**,
about96.7% less repeated receipt work. This is an operation-count result, not a
measured wall-time speedup. The earlier67.05s residual includes authentication,
serialization and other observer work; no dedicated profile attributes it all
to writes. No target or heavy write benchmark was run to support this change.
The [offline accounting](../../../../../implementation/phase144/programs/checkpoint-analysis.json)
pins both source versions, the interrupted report and the completed720-row join.

## Final04 promotion check without another full timing campaign

`final-gate-v01.py` prepares `programs-final04-plan01/jobs.json`. Execution first
requires the actual final04 N2 build, exact Q3 reproduction and N2 focused gates;
the preparer does not assume future receipts already passed.

The gate emits all45 original timed wrappers through N2. It may reuse an old
object only after complete QBE byte equality. Otherwise it builds the new QBE
with the same branch-aligned policy. Each selected serial-runtime product then
executes once against the original full output/count oracle.

Existing four-round timing is labeled **inherited**, and only if the final
product has the same runtime and exact bytes, addresses and sizes for all loaded
ELF sections (except GNU build ID) as the prior candidate or fast product.
Candidate precedes fast in a fixed priority independent of timings. The gate
does not publish a fresh aggregate by relabeling these historical observations.

Only genuinely changed timed products and the previously regressing row32 case
receive a new eight-pair timing block. Row32 compares the original143 atomic
product with the new selected serial product, so it checks the complete product
regression; other changed cases compare against final03 with the same serial
runtime. More than eight changed cases stops for coordinator review instead of
silently starting another broad campaign. No compiler source or benchmark count
is changed by this observer.

The actual gate passed all45 executions and inherited35 machine-identical cases.
Ten products changed relative to the prior serial-runtime images; every one of
those ten restores the exact original143 program object. The coordinator
explicitly reviewed this outcome and authorized a ten-case bound. The original
eight-case observer remains unchanged. `final-timing-v01.py` freezes precisely
these ten cases in`programs-final04-ten-plan01/jobs.json`, with a160s guard,
eight alternating pairs, and once-per-case checkpoints. This is160 new
observations, not another720-observation campaign.
