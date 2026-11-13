# Phase190 legality scope

The new rules operate after native IR admission. They preserve the existing
verifier, runtime ABI and source semantics; they do not establish a new trusted
verification boundary. These are structural arguments and finite executable
checks, **not BendTT theorems or a proof of the complete backend**.

## Repeated comparison conditions

[`branch-selection.bend`](../../selfhost/src/back/x86/branch-selection.bend)
retains the original one-definition/one-read rule. The optional reuse rule
counts, for each name, all reads in setup and body and a subset of those reads:
conditions of structurally adjacent, matching comparison/branch pairs. The
pair scan uses the emitter's name, width and predicate gates and visits each
branch once, including both nested branch forms.

Reuse requires a positive pair count equal to the total read count. Therefore
every read has its own immediately preceding comparison; no other read can
observe the removed Boolean assignment. This argument also covers nested
branches, outer continuations and backedges. A comparison operand, call
argument, returned value or Again argument that reads the condition adds an
unpaired read and refuses reuse. Extra writes are harmless because each
permitted read has a fresh paired producer. Parameter, setup-written and
backend-reserved names remain excluded.

The extra scan requires `p113i_size(body) < 4096`; the size function saturates
at 4096, so a non-strict bound would be ineffective. The bounded pair count
cannot wrap or reach the read counter's saturation value. The rule does not
assume that a shared spelling denotes one SSA value. The checked fold
[diagnostic](../../selfhost/build/phase190/fold-diagnostic01/facts.txt) records
two reads and two writes of `match_condition`, explaining why the earlier
single-use rule rejected both adjacent pairs.

Direct physical comparisons preserve both input homes, including equal
homes. Unknown operands use distinct reserved registers `r10` and `r11`.
Width selection and immediate bounds are unchanged. This relies on the
existing frame contract that allocated homes exclude selector scratch.

## Register allocation boundary

[`loop-liveness.bend`](../../selfhost/src/back/x86/loop-liveness.bend) bounds
analysis to 32 candidate names, 256 setup/body statements and 64 parameters.
The header computation has 33 rounds of fuel. Backward transfer unions branch
entries, models Again's parameter writes in parallel, includes dead writes,
and scans setup plus incoming parameter writes. A call-crossing marker blocks
caller-saved colors; saved colors retain all ordinary interference edges.
Incoming caller colors also obey the actual sequential ABI argument-copy
order. State and backend-owned buffers retain their reserved homes.

`x190_allocate_frame` receives a fresh `x181_frame` and selects either joint
coloring across four saved and five caller registers, or the prior saved-home
selection followed by caller allocation. The legacy caller allocator's input
must already have saved homes but no transient homes. Refusals return through
the complete prior placement path. A separate check rejects conflicting color
membership, duplicate membership and forbidden incoming/call colors before
installing homes.

That check validates a proposed coloring **against the constructed graph**.
It does not independently prove graph completeness, selector effect summaries,
parallel-move scheduling or the complete allocation interface. Those remain
implementation obligations supported by review and finite controls. The
analysis assumes admitted IR and the documented machine clobbers; no claim of
whole-program memory, ownership or compiler correctness follows.

## Recorded evidence and diagnostic limits

The [integrated controls](../../selfhost/build/phase190/integrated-controls01/report.json)
pass 78 metadata checks and their independent machine observers through both
direct objects and assembled text. The new branch observer covers 3,662
observations, including forced physical operands, repeated conditions and
backedges. Passing source checks, these finite executions and an independent
kernel proof are distinct claims. These results do not establish runtime gains,
broad conformance, self-reproduction or release qualification.

The [joint diagnostic](../../selfhost/tests/phase190/liveness-joint-diagnostic.bend)
replays the ordinary integer preparation and calls `x190_allocate_frame` with
the same register-body selection as the emitter. It also reports the active
joint-allocation and branch-reuse flags. Its placement output is applicable
when `float-path=0`; it does not reproduce the specialized F32/XMM planning
path. The earlier diagnostic and its evidence remain separate artifacts.

## Final local-value and composition rules

Local copy facts are bounded to 32 aliases and 512 statements. Sources are
canonicalized before insertion; a destination write invalidates both its own
alias and aliases of that source. Calls, branches and control exits clear facts.
Loads and stores keep their order; this pass never caches memory contents.
Known-zero upper bits permit a full-width copy of an already canonical U32.
Adjacent U64 arithmetic followed by truncation can become U32 arithmetic for
add/sub/mul/and/or/xor; shifts are deliberately excluded. Retained definitions
allow existing dead-write elimination to remove only proven unused snapshots.

Complement simplification inspects only the first comparison/branch inside
an arm whose outer comparison result is known. It requires identical typed,
ordered operands and an equal or exactly complementary predicate. The same
paired-read certificate remains mandatory. Terminal-aware concatenation keeps
unreachable continuations from becoming executable after selecting an arm.

Copy affinity is a preference over legal colors, not graph contraction. Copy
and Again pairs suggest an existing neighbor's color only when interference,
call clobbers and incoming argument constraints permit it. The independent
post-color validator remains unchanged. This does not establish optimality.

The final focused controls cover 12 coalescing metadata cases, 24 predicate
cases and nine local-value cases, plus independent C observations through both
assembly and direct objects (802, 4,840 and 1,400 observations respectively).
Independent source reviews found no concrete correctness defect. Structured
calls and Again propagation lack a dedicated local-value fixture; their
conservative fact-clearing behavior is reviewed, with broader program and
native gates providing separate evidence. No new formal kernel proof is claimed.
