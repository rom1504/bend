# Phase97: compositional ownership preservation

The pilot answers a narrower question than compiler correctness: can safe Bend
express a useful ownership semantics, and can the independent kernel verify
that an operation replacement preserves all modeled observations in arbitrary
surrounding code? The answer for this small model is yes. Seven actual proof
bodies passed the source checker and the independent BendTT kernel without
proof repairs: four public laws and three support lemmas. The emitted package
contains 26 definitions, including datatype machinery and Base dependencies;
none are opaque. It is 9,592 bytes with SHA-256
`b5db0bffd4e856876bc90ca8aea19b353dbf09c854b57c421250499b65dff05a`.

Source: [ownership package](../../selfhost/proofs/phase97/ownership/README.md).
Accepted evidence:
[ownership-proof02/report.json](../../selfhost/build/phase97/ownership-proof02/report.json).
This is universal formal evidence about the model, not a finite execution test
or a verification of the native implementation.

## Semantics and transformation

The language is a finite sequence of `Keep`, `Read`, and `Drop` operations over
one immutable cell. A live cell stores a payload of arbitrary Data type and a
structural natural number of *additional* roots. The first root is represented
by the live constructor itself. Dropping its last root yields a dead cell.
Every operation on a dead cell faults, including `Keep`; there is no
resurrection. Empty programs can finish with either a live or dead cell.

`Read` emits the immutable payload value into a chronological trace. Successful
execution returns the entire final cell and trace. A dead-root fault stops
execution and retains every preceding read. Its final root count is zero.
The model does not silently assume machine arithmetic: counts use `Nat`, and
there is no counter wrap or overflow condition in the modeled language.

The proved replacement is:

```text
prefix; Keep; Read; Drop; suffix  ==  prefix; Read; suffix
```

Equality is of the complete outcome, not merely a checksum, length or final
root count. The prefix, suffix, initial count and payload are arbitrary. A
prefix that faults and a suffix that faults are both covered. The local result
is lifted through sequencing with a structural proof over the prefix. The
sequencing law uses actual Base list append, and the executable model itself
is included in independent checking. There are no callback assumptions,
opaque semantic functions, new axioms or unsafe proof bodies.

The shape follows the useful part of the pinned upstream proof method:
define an explicit executable reference meaning, compare complete results,
then prove composition. The small local replacement alone is computational;
the `execute_append` induction establishes that the result representation is
adequate for arbitrary surrounding operation sequences. This is not yet a
compiler pass that searches and rewrites programs.

## Connection to actual operations

These are proposed correspondence obligations, not established simulation
lemmas. The runtime source is the C runtime emitted by `bend2/comp.ts`.

| Model operation | Relevant production site | Missing correspondence |
| --- | --- | --- |
| `Keep` | [`term_keep`](../../bend2/comp.ts#L3905), [`rfc_bump`](../../bend2/comp.ts#L3898) | A runtime term denotes the modeled live object, a new owner is created, redirect wrapping preserves identity, and the bounded counter does not overflow |
| `Read` | [`term_peek`](../../bend2/comp.ts#L3921), field loads in [`ctr_take`](../../bend2/comp.ts#L4034) | The particular handle remains valid, the load observes the immutable payload, and the returned observation does not outlive required ownership |
| `Drop` | [`term_drop`](../../bend2/comp.ts#L3944) | Exactly one valid owner is consumed; the final owner frees the object and recursively accounts for children |
| Contextual sequencing | Retain/load/drop order generated around shared constructor access | Lowering, evaluation order and any callbacks preserve the modeled order and have no unmodeled effects |

The runtime also distinguishes immediate terms, unique heap terms and shared
redirects. `term_keep` may allocate a redirect or report an error. Its count is
bounded, whereas the model's count is unbounded. `term_drop` traverses an object
graph and deallocates descendants, whereas the model has one cell.

The particularly relevant boundary is
[`span_fade`](../../bend2/comp.ts#L4022): it retains shared child fields and then
drops the parent. Those child fields can escape into new owners. They are
**different objects**, and a copied runtime pointer is not the model's pure
payload observation. The model therefore does not authorize removing those
retains. A separate runtime fault demonstration can falsify an unsafe retain
deletion, but it does not supply the formal bridge either.

## What a production bridge must prove

1. Relate concrete heap blocks, redirect cells and individual live handles to
   abstract object identity and ownership counts. Aggregate count positivity
   alone does not establish validity of a particular pointer.
2. Account for nested fields and ownership transfer: a parent holding a child
   and an escaped child handle contribute different obligations. Prove the
   invariant before and after `ctr_take` and `span_fade`.
3. Establish each modeled operation's concrete simulation, including bounded
   counters, allocation failure and runtime errors, or state and discharge
   preconditions excluding those cases for the transformation.
4. Relate the actual lowering rule to the operation sequence, including the
   ownership and nonescape condition of the observed value. A source-pattern
   resemblance is insufficient.
5. Extend the semantics for concurrent sharing, atomic memory order, mutation
   and alias provenance before claiming those behaviors are covered.

The strongest limitation is the missing relation between concrete handles and
the abstract cell. Even a perfect proof of this model cannot make a dangling
native pointer valid. A practical next formal step is a two-object parent/child
ownership-transfer model that distinguishes a parent-owned child reference
from an escaped root; that directly expresses the obligation exposed by
`span_fade`. It should then be connected to the exact production body before
using the result to approve a runtime optimization.

## Falsification and status

Three semantic helper variants were checked against unchanged
proof bodies: drop the last owner before reading, omit the read, or retain
without releasing. With a single initial root, payload `7n` and empty suffix,
they respectively change fault status, the read trace, and final root count.
All three passed their law-free source checks, then all three failed the
unchanged `temporary_read_preserves` proof with expected/observed mismatches.
The full composition entry was checked for each mutant. Evidence:
[ownership-negatives01/report.json](../../selfhost/build/phase97/ownership-negatives01/report.json).
The omitted-read mutant first failed in the dead-cell branch, where skipping
the read removes a fault; its live-cell trace witness above was not separately
executed. This distinction avoids attributing an unobserved diagnostic to the
negative check.

The positive independent result and the kernel's unequal-label rejection are
recorded in the accepted report. The semantic mutation checks operated
at the frontend and are labeled separately from the independent kernel
proof. Runtime executions are another separate evidence category.

The separate [runtime boundary report](../../selfhost/build/phase97/ownership-boundary01/report.json)
authenticates an isolated copy of the actual Phase96 native generated C. Its
only mutation changes `rfc_bump(e, term_loc(f), 1)` to a zero increment in
`span_fade`. The candidate compiled in 11.848 seconds, then exited with code 1
and `bend: a function the device does not hold`. It emitted eight correct
prefix lines; the baseline emitted all 32 oracle lines and exited successfully.
The run reported no resource stop. This is a concrete runtime rejection of the
deliberately wrong implementation, not independent kernel evidence.

Offline verification replayed that one C change exactly, checked the baseline
against the full raw oracle and the mutant against its matching prefix, and
reauthenticated the original proof source bytes and emitted BendTT. The accepted
model/local/composition bytes also match every negative snapshot. The wrong C
runtime and all three wrong model protocols were isolated build artifacts;
production source and the accepted proof files remain unchanged.

## Feasibility lessons

The 203 source lines, including comments and blank lines, were sufficient for
an executable ownership model, semantic anchors and an actual sequencing
induction. The initial local package and the composition extension passed their
first submitted checks. The full run observed 0.534 seconds for source checking,
0.554 seconds for safe emission, and 0.370 seconds for independent acceptance;
the kernel rejection control took another 0.289 seconds. Each semantic helper
admission or law rejection took 0.493–0.514 seconds. These are single process
observations using the existing audited toolchain, excluding toolchain setup,
orchestration and authoring time. They do not predict full-compiler proof cost.

Small, explicit semantics with structural state and complete results are
tractable in the current safe language. The useful step beyond a local equation
was proving result sequencing, which made the replacement valid in arbitrary
prefixes and suffixes without assuming those contexts succeed. Mutating actual
helper bodies after proving the law kept the rejection experiment tied to the
meaning being specified; standalone admission ruled out trivial syntax or
usage failures.

The separate compiled C failure makes the limiting lesson concrete: this proof
does not constrain the production runtime until a correspondence is proved.
The single-cell value-read model omits exactly the escaped child ownership
involved in `span_fade`. Extending the model and proving that relation is the
next substantive obligation, rather than simply increasing the number of
algebraic laws. This pilot supplies a small proved contract and a measured
checking workflow; it supplies no end-to-end correctness estimate.
