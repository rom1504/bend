Recursive-region source controls
================================

`recursive-controls.json` freezes six ordinary source programs, complete stdout
and the independent oracle identity. Each `.bend` file also carries its literal
`#|` output. `recursive-controls-oracle.py` computes the numeric answers with
finite unsigned-word arithmetic and explicit frame lists, and the tree answer
with a bottom-up leaf vector. The sharing answers are literal strings. Running
this oracle does not invoke Bend, the candidate or a generated target.

| ID | Required observation |
| --- | --- |
| one | One captured arithmetic continuation; depth zero returns to an already pending external wrapper; 4096 descents exercise an explicit continuation stack. |
| two | Two continuation shapes alternate xor and addition; captured seeds and unwind order affect the result. |
| tree | The first recursive call captures an owned right subtree; the second captures the first result; two subcalls combine with noncommuting arithmetic. |
| ready | A separate tail-recursive scalar helper returns underneath local region frames and an external caller frame; also executes at zero local depth. |
| sharing | Shared string captures are repeated, an owned string tail survives descent, and the shared value is used after the recursive result is consumed. |
| fallback | An indirect call lies inside a recursive computation and an external caller remains pending. Admission must distinguish a refusal from independently proved specialization. |

Source syntax alone cannot establish which lowered owner is H-admitted. Before
calling these H controls, inspect the actual segment and immutable callable
registry using the retained Phase186 `continuation-probe.bend` contract or a
new versioned derivative. Query both raw names and `$direct.`-prefixed names
listed in the metadata; record exact admitted plans, continuation case counts,
and ready targets. Keep no-hit/refused cases in the correctness results. In
particular, do not relabel the indirect-call source as a fallback witness if
ordinary preparation specializes it.

The original planner's contract remains unchanged: one result, no incoming
captures on the owner, flags zero, arity 1..8, original body at most 512 scalar
nodes, clean original source, owner absent from the ready registry, and at most
eight closed continuation cases with matching capture counts. The general
source tests supplement, rather than replace, the existing finite refusals in
`phase186/stacked-frame-controls.bend` for unknown targets, missing cases and
nine-case closure. Its companion C oracle checks stack-pointer restoration,
`rn`, `next`, `seq`, every state register and surrounding stack guards; those
state invariants are stronger than observable stdout alone.

Root should run exact source checking and parent/candidate direct-object
executions against these complete literal outputs, and a separate ready-helper
and depth-zero state-sentinel control on the low-level emitter. These files do
not introduce any invalid-runtime probe or resource-exhaustion test. Source
checking and generated execution had not been run when the fixtures were
authored; the initial metadata explicitly records that limitation.
