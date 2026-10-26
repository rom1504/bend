# A compiler-hot predicate crosses an unnecessary continuation boundary

The integrated N1's `p131i_insert` is still a generic scheduled computation. It
has no private direct worker; `index_leaf`, `index_set` and `p113k_put` likewise
remain generic. `index_node` alone has a23-line direct constructor worker. This
is actual emitted-code evidence, not inference from a source function's name.
The [evidence](predicate-worker-evidence.json) pins the117,055,961-byte integrated
QBE and its actual native binary, with bounded QBE/assembly extracts.

## The smaller decisive problem

On the ordinary `KIndexNode` branch, the generated function **already consumes**
the tree through `p125_rt_take4`. It does not retain the whole boxed root. The
observed `keep` operations preserve scalar stored-hash/split values. Consequently
removing the source `+tree` annotation alone has no demonstrated benefit.

The next predicate is
`Bool.not(U32.is_eq(diff & (split - 1), 0))`. Despite the comparison being scalar,
the generic route saves **seven values plus a return FID in a64-byte continuation
frame**, computes equality, calls the ready `Bool.not` worker, then invokes
`p111_rt_return` to schedule the comparison's consumer. Native machine code
confirms the frame advance by0x40, call to the Bool.not worker, and subsequent
runtime return. The whole generic entry is425 QBE lines /393 disassembly
instruction rows; these totals include cold/failure branches and are not dynamic
instruction counts.

The exact source-level ceiling replaces that negated predicate with its positive
equality and swaps the two syntactic lambda arms. It changes no ownership
annotation, recursion, malformed/legacy fallback, layout or runtime contract.
`predicate/prepare-v01.py` verifies this exact one-condition/two-arm edit against
the current integrated source before composing any fixtures.

This first experiment is deliberately smaller than a tree-reconstruction rewrite.
It can establish whether eliminating a real predicate/continuation boundary pays
off before adding a new optimizer abstraction or runtime cell-credit system.

## Independent gates prepared, not executed here

`selfhost/build/phase144/predicate-proxy-source01/` contains two42-name slices of
the current compiler, preserving laws and source order. The same256 actual
compiler names, two construction/update passes and lookup digest are used in
both. The existing Phase131 independent checksum oracle is unchanged.

The root-only plan at
`selfhost/build/phase144/predicate-proxy-plan01/jobs.json` contains:

- Two independently checked APIs and the existing336 complete-tree comparisons
  plus11,088 independent payload lookups, including duplicate keys, hash
  collisions, wrapped/high-bit inputs and legacy representation cases.
- Two native products with unchanged runtime and exact five-line ordinary output.
- Five alternating timing pairs at64 and256 names, using one baseline-calibrated
  repetition count per size and the existing millisecond-aware output parser.

Before interpreting a speed result, inspect both retained QBE products. The
baseline must reproduce the predicate continuation; the candidate must remove it
or otherwise demonstrate the actual changed work. A proxy in which ordinary
inlining already erases the boundary cannot establish this claimed ceiling.
The original generic/private/full verifiers remain untouched.

## Generalization is plausible but its ceiling is limited

The source census finds **1,161 Bool.not calls**, and87 readily identifiable whole
negated conditions passed to simple `kc`/`nt_choose`/`f_choose` applications.
Sixty of those conditions in53 owners survive the native profile. This is a
conservative syntax census: composite conditions and complex type arguments are
not counted as direct rewrite sites. It is neither dynamic frequency nor a
production transformation.

The previous qualified-Phase143 profile attributes376/10,083 samples (3.73%) to
`p131i_insert`. All87 simple-condition owners together account for622 samples
(6.17%), including100 in `p111q_body_text` and50 in `p111v_decl`. These are whole
active-owner contexts, **not predicate costs**; synchronous helper calls can retain
another caller's context. They give a rough exposure screen, not an additive or
exclusive performance bound. This profile also predates the current integrated
266.86-second clean request. A small kernel win must not be multiplied into a
large whole-compiler forecast.

If the kernel is strong, the smallest general next step is a checked source/IR
canonicalization of an actual certified Boolean negation followed by a chooser.
Recognize the resolved callee's two-case body and native Bool layout; do not use
the text `Bool.not` as authority. Parse complete arguments rather than regex
replacement. Preserve one evaluation of the predicate, branch/lambda ownership,
and eager construction/error order. Initially admit syntactic lambda/value arms
only; swapping arbitrary effectful thunk-producing expressions requires an
additional argument. An independent exact-body law is being developed separately.

For larger gains, the coordinator's separate admission investigation remains
important: an advertised flat-product worker can fail while the ordinary boxed
alternative is never retried. Repairing that dependency boundary could unlock
entire computations, whereas predicate canonicalization removes one particular
unnecessary transition. This audit does not establish the exact ready refusal
for the Patricia group and does not duplicate that investigation.

No compiler or benchmark target ran in this source/machine-metadata audit.
One initial objdump command accidentally reset its symbol filter and produced a
whole-image temporary; that output was rejected/deleted. The evidence records the
corrected symbol-specific command and does not use the rejected count.
