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
