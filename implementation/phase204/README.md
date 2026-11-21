# Cold native x86 builds, Phase204

The incumbent is the byte-reproducing Phase203 direct-object compiler. Each native comparison uses one pinned CPU, the same prepared Base and runtime, fresh source compilation and linking, and a digest of the complete product. Generated-program execution speed and compiler execution speed are separate measurements. [Phase203 baseline and profiles](../phase203/README.md)

## What the real verifier revealed

The shared planner returned 983 public segments for the checked compiler-derived verifier. Exactly 161 contain a top-level call to `p111_rt_apply`. All 161 have the same sequence of seven operations. The existing early matcher accepted zero. A late pass converts the fourth operation, a runtime read of register zero, into a 64-bit load from offset 40 of the state struct. The early matcher had been written for the latter representation. This explains how the old compiler could emit thousands of bodies with the expected final machine code while the proposed shortcut did no work on the verifier. The historical 7,174-body census was on a different compiler image. In the actual Phase203 producer, 7,243 of 47,129 distinct public function addresses (15.37%) contain the complete 118-byte template with the displacement resolving to the exact runtime apply symbol. Another 50 functions have that same size but do not match. This is an output census, not a count of matcher admissions. [Current linked ELF census](footprint.json) [Prepared verifier evidence](census.json) · [Earlier machine census](../../research/phase202/continuations/evidence.json)

The new matcher checks the concrete call signature, register index, state operand, scratch layout, field widths, result use, operand identities and order, and the entire remaining body. It invokes the same late register-read expander for the single checked operation. The existing exact template handles the result. The original matcher still handles input that already contains the load. A failed match follows the ordinary compiler. The added rule is an isolated alternative built directly on Phase203. [Bend implementation](../../research/phase204/continuation.bend)

## What generalizes

The retained Phase202 assembly listing has 47,133 complete public functions and only 30,944 distinct bodies after replacing each function's own symbol with the same placeholder. All external call targets, constants, operand order and instruction spellings stayed significant. This leaves **16,189 repeat instances (34.35%)**. The largest family contains 7,237 apply continuations. A second family contains 1,531 66-instruction bodies that call a private Boolean helper and return through the scheduler. A third contains 344 bodies that call a String helper. [Assembly family census](families.json)

This is a reason to measure structural reuse earlier. These functions still need distinct dispatch identities and relocations. The census does not establish that the generic lowering work for all repeated outputs is identical, dead, or removable. Raw linked bytes alone missed the opportunity because PC-relative displacements differ.

## Copy propagation and liveness

| Trial | Complete verifier times in baseline/trial/trial/baseline order | Decision |
| --- | --- | --- |
| Skip copy planning and rewriting on apparently copy-free bodies | 7.486 / 7.351 / 7.441 / 7.570s | Rejected despite identical verifier objects and a 1.75% timing improvement. A generated control showed a change in IR shape. |
| Preserve normalization, reuse local lookup keys, solve the liveness header once and skip loop scoring on bodies without backedges | 7.526 / 7.593 / 7.471 / 7.971s | Objects and executions matched. The two pair ratios were 1.009 and 0.937. The timing signal is inconclusive. |

The old copy pass normalizes wrapped scalar conditionals into branches in the enclosing IR. Returning a body with zero aliases can skip that obligation. The corrected preflight therefore treats a wrapped conditional as a reason to run the original pass. The corrected source also captures the setup list as reusable at the new call sites, as required by the independent upstream checker.

For liveness, ordinary statements generate live bits and clear overwritten bits. Joins union bits. A backedge injects the same loop-header variable, masked by the parameter writes. No statement's live bit depends on a different header bit while graph collection is disabled. For the resulting transfer expression, starting from zero gives a fixed point in one evaluation. With no backedge in either the setup or the body, the graph collector does not read the header at all. Lean 4.32 checked the universal 32-bit algebraic idempotence lemma. The correspondence between the Bend transfer cases and this algebra is a source argument. The theorem covers the algebra. It does not certify the compiler. [Lean lemma](../../research/phase204/Liveness.lean) · [Bend shortcut](../../research/phase204/liveness.bend)

Two independently source-checked versions of the relevant functions agreed on 128 generated bodies for copy output, the full interference graph, candidate name order and observable scores. Of these, 104 contained a backedge and 92 had a nonzero reference header. Another 2,304 name lookups covered missing keys and the high register bit. The receipts include the deterministic fixture, initial failing assertion, source checks, and both native comparisons. [Differential and source checks](controls.json.gz) · [Timing receipts](alternatives.json.gz)

## String operations

A direct native program visited 120 pairs of compiler identifiers, short strings, long common prefixes and Unicode strings for 5,000 rounds. Independent checksums covered every execution. In five alternating pairs, processing two characters per FNV recurrence took **1.103×** the original runtime. Both variants still emitted the borrowed hash worker. Rewriting equality to return directly on a mismatching character took **3.109×** the original runtime and lost the borrowed-reader worker. Both proposals were rejected before a full compiler build. This input distribution measures the local observers. It cannot predict their whole-build share. [Microbenchmark](../../research/phase204/strings.py) · [Machine worker identities and timings](strings.json.gz)

The first hash fixture used an unsupported match position, and the first equality candidate from Phase202 matched a computed expression. The corrected native sources produced the expected independent results. The initial hosted segment census also needed the host's absolute Node executable path to run under the build supervisor.
