# A measured native IR and optimization loop

2026-10-18. Approved scope: execute the five steps proposed after Phase105,
without requiring GPU hardware. This is a bounded backend research slice, not
an unconditional production backend migration or a claim of whole-compiler proof.

## Objective

Reduce elapsed time from a compiler edit to an independently checked result.
Build an executable foundation for searching over code generation choices while
preserving semantics. Measure compilation time, execution time, memory,
correctness and implementation complexity separately.

The current candidate04 compiler and its installed selection remain the reference.
The [Phase105 measurements](../../implementation/phase105/README.md) found full
self C emission at 126.05s for native B1 and 143.65s for B2, versus 48.44s upstream.
Prepared ordinary programs have a different ordering. Historical Clang self-image
construction took 374s; that observation is not a current controlled measurement.
The [backend proposal](../phase105/fast-native-backend.md) and
[recursive research design](../phase104/recursive-improvement.md) explain the
architecture and experimental limits.

## Hypotheses and gates

1. Machine-image construction is a material part of a real native edit/build/test
   cycle. A fresh current-source Clang observation and full-self profile identify
   what a fast backend can remove and what it leaves untouched.
2. A small, typed native IR can express useful compiler-shaped work with both a
   C consumer and a Cranelift consumer, without reimplementing the frontend in
   another language. This must include memory/control work, not just arithmetic.
3. At least one actual transformation can be constrained by an executable
   semantic model and checked Bend laws. Deliberately wrong transformations must
   fail the unchanged contract. Backend correctness remains a separate boundary.
4. A cheaper machine backend improves complete candidate-build plus evaluation
   time for some realistic evaluation counts. A faster object-emission clock
   alone is insufficient evidence.
5. Bounded policy search can make a measured, transferable choice, or establish
   that its cost exceeds the benefit. Both outcomes are useful; no improvement
   is assumed in advance.

## Step 1: bounded attribution

Reuse authenticated candidate04 images, source, prepared Base and exact self-C
from Phase105. Run one full-source diagnostic profile and a current O2 Clang
build under the existing resource guard. Keep profile overhead distinct from
clean timing. Record command, source/tool hashes, CPU, memory, exit, full output
identity and wall/CPU time. Use existing phase clocks and sampling when supported;
do not fabricate an allocation profile from a sampled cleanup stack.

Attribute native costs to the resolution the evidence actually supports. Record
unavailable perf events/permissions rather than repeatedly trying privileged tools.
Clang phase diagnostics may be collected with the timed construction but must
then be labelled an instrumented observation, or run separately from clean timing.
Do not repeat broad45, all bootstrap generations, or the complete conformance suite.

## Step 2: structured IR, two real consumers

Implement the IR definitions, workload construction/lowering, and C emission in
Bend. A narrow, version-pinned Rust adapter may use Cranelift for native code
generation; it is an external backend component, not a replacement Bend frontend.
Its parsing/verification/object emission or JIT costs belong in the measurements.

Agree and commit one explicit transport schema. The prototype needs typed values,
function/block parameters, arithmetic with defined wrapping behavior, branches,
calls, memory operations and a specified tail-transfer strategy. Represent
ownership/effect obligations explicitly where supported. Reject unsupported
operations; do not silently reinterpret them. State whether input is directly
constructed IR or a subset lowered from existing checked KTerm, and preserve that
distinction in the report.

Start with the smallest complete vertical slice. Expand to text scans, tree or
node traversal, allocation/ownership, explicit closure environments, deep transfers
and many functions as supported by the agreed ABI. Reference answers must be
independent of the candidate emitter. Add boundary-value and malformed-IR controls.
The C consumer and Cranelift must execute the same IR and runtime contract.

Keep parallel fork/join, ownership and offload concepts separate from CPU calling
conventions. The existing CUDA/Metal path stays available; no physical GPU result
is claimed. Do not implement an x86 instruction encoder/register allocator here.

## Step 3: laws that constrain real transformations

Give a small supported semantic subset an executable reference interpretation.
Choose a transformation actually used in the prototype, such as constant/branch
simplification, and check a universal Bend law where practical with the existing
independent BendTT workflow. Keep the reference statement/evaluator unchanged
across candidates. Show the connection between the proved helper and the emitted
operations. Preserve unsafe, memory, foreign-call and machine-code boundaries.

At least one well-typed semantic mutant must be rejected. Include independent
execution checks for memory/closure/tail behavior that the theorem does not cover.
Passing finite cases is testing; an independently checked theorem covers exactly
its stated model. Do not claim a proof of the runtime or all compiler passes.

## Step 4: complete iteration comparison

Freeze development and held-out inputs before policy selection. Use multiple
input sizes and a mix of operations; held-outs are new to this search, not a
claim of distribution-wide representativeness. Prevent dead-code elimination with
runtime inputs and full observable answers. Use the same CPU/runtime contracts.

For each backend report input preparation/IR emission, backend startup/compile,
link if applicable, executable startup, repeated runtime and peak memory.
Distinguish JIT and AOT results if both are used; count fresh JIT compilation in
cold end-to-end time. Record one-time Rust/tool acquisition separately from reuse.
Compare at least C O0/O2 when valid and Cranelift's viable optimization settings.
Report medians/ranges with modest repeated observations and randomized/rotated
orders. Do not claim significance for tiny differences.

Evaluate cycle cost as build + k * execution + validation for several k values.
Measured cheaper construction does not establish a faster self-hosted compiler.
Only expand toward full compiler coverage if the measured tradeoff justifies it;
record the missing language/runtime surface before proposing integration.

## Step 5: bounded search

Search a small declared configuration space: backend optimization setting and/or
a semantics-preserving IR policy with a checked contract. Freeze the candidate
list, selection objective and training/held-out split before timing. Include every
attempt, failures and qualification in cost accounting. Recheck the selected
policy on held-out workloads and retain a validated incumbent if it fails.

Compare the selected policy with a fixed baseline using the same workload budget.
Calculate measured payback in future iterations after charging the search/setup
cost. This demonstrates an optimization-loop baseline, not recursive acceleration
unless adopting improvements actually changes subsequent discovery throughput.
Do not rebuild B2 after every small policy attempt.

## Resources and division of work

Root alone schedules heavyweight work serially on CPU3. Offline agents prepare
the IR/C consumer, Cranelift adapter, laws and profiling method in disjoint paths.
No parallel compiler builds. Use existing guard limits, available-memory floors,
timeouts and full process-tree termination. Start with small tests before scaling.

The filesystem has approximately 1.4GiB free at design time. Bind this as an
experimental constraint: cap Rust build jobs at one, disable dev debug/incremental
bulk where safe, monitor scratch growth, and preserve at least 192MiB. Do not
delete historical/user evidence. External dependencies must be pinned and any
network/toolchain failure retained. Avoid installing a second large toolchain.

Record phase elapsed times, measured child time, build/download overhead and
agent role allocation. Do not invent token/quota totals. Keep user updates focused
on findings, changed hypotheses and the next discriminating test.

## Deliverables and completion

- This design and one hypothesis record per substantive experiment, committed
  before its measured intervention.
- Reproducible Phase106 tools/IR/adapter/laws with a README and exact commands.
- Bounded full-source attribution and current Clang evidence.
- Executed two-backend vertical slice, useful law/mutation controls, complete
  iteration measurements and bounded policy selection with held-out evaluation.
- A report under implementation/phase106 with tables, raw evidence links, failures,
  complexity, learned constraints and an explicit integration decision.
- Documentation linked from the self-hosted compiler guide/README; staged commits
  pushed throughout. No PR comment or production promotion is implied.

If a hypothesis fails, complete the experiment and report that result rather than
expanding architecture until it appears successful. Environmental blockers must
be demonstrated with bounded attempts and distinguished from negative results.

## Execution record

Completed in the [Phase106 report](../../implementation/phase106/README.md).
The chosen IR has structured control and mutable typed locals; the Cranelift
consumer constructs SSA/block parameters. It is directly constructed, with two
real lexical algorithms reconstructed, not a general checked-term frontend.
A preregistered backend matrix was followed by a declared fresh-size confirmation
and one-shot scenario using its frozen winner. Those additional observations
did not select a new policy. The repeated-batch generalization failure is retained;
no installed backend or compiler selection changes.
