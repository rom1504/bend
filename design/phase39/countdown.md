# Phase39: extend the existing private countdown representation

Prospective design, 2026-10-01. Root alone executes targets and measurements.
The installed Phase37 numeric module has SHA256
`a2ffdcd6cc70e0f3159219eb4b75551646b1f20d3cea1d21042a1e08454ff540`.
Its two private countdowns still use BigInt: the public Nat successor worker
and the private helper inside `bench`. Generic fallback remains separate.

## Hypothesis and scope

An admitted predecessor used exactly once, as the first self-tail argument,
does not need BigInt representation inside the loop. All canonical Nat values
are below 2^48 and are exact JavaScript Numbers. Preserve the public BigInt ABI,
initial-zero path, original arithmetic and rounding, guards and generic fallback.
The Phase38 **1.1–1.5× numeric** range is speculative, not an acceptance claim.

`j_region_number_counter` already proves this case for private vector loops.
The scalar extension should reuse its one-use and tail-shape proof. It must
not admit escaping predecessors, source arithmetic on the counter, duplicated
uses, copied helper captures or altered public staging. Traversal must include
annotations, as the existing conservative proof does.

## First experiment, before compiler edits

Derive three versions of the exact Phase37 output: unchanged, only the nested
private helper narrowed, and both private loops narrowed. Convert once after
the public successor guard or at nested private entry; change only zero tests
and decrements in the admitted loop. Keep all other code and generic fallback.
Emit separate diagnostic and clean modules, hashes and a compare configuration.

Diagnostic modules count actual loop entries/steps and expose the captured
private helper only for bounded controls. A diagnostic trip cap stops before
more than four loop bodies run when inspecting large Nat values. This is not
compiler admission evidence and must never be used for timing or installed.
Invalid bounded-probe inputs are refused; no 2^48-step loop is attempted.

Controls compare independent recurrence results at small lengths, the maintained
256/1024 catalog points, public direct/partial/raw/extra calls, descriptor and
host mutations, errors and reentry. Public and nested entry counters must be
nonzero. Boundary traces compare exact predecessor values at zero, one, ordinary
and near-maximum inputs, separately recording changed internal types.

## Source integration only after a clear win

The existing scalar emitter hardcodes BigInt in `worker.bend:j_nat_loop_emit`;
`j_nat_loop_body` also needs guarded entry conversion. Root has reserved these
two helpers plus `region.bend:j_region_number_counter` and narrowly related
nested initialization. No compiler edit precedes reviewed controls and timing.
Any additional source ownership change requires coordination with root.

Remove only the vector-specific admission restriction, retaining bounded shape
and one-use facts. Ensure both public and nested loops agree about representation
before changing their zero/decrement literals. Avoid repeated expensive analysis
or an extra runtime guard; compare checked-request cost as a separate outcome.

## Acceptance and stop conditions

Run new directories under CPU3, Node24.18, heap<=1GiB, tree RSS<=2GiB, free memory
floor2GiB and explicit deadlines. Controls precede a 20/60-second clean screen;
root selects deeper confirmation. Stop on changed values/order/error/reentry,
noncanonical admission, missing actual entries, no stable gain or added loop
allocation. Preserve failed attempts. A surviving compiler patch needs actual
source fixtures for one-use admission and escaping-use refusal, inherited owner
controls, checked compilation and broader canaries before promotion.

This changes neither public Nat representation nor language conformance.
It is intended to add little code and no new IR, registry or proof concept.
