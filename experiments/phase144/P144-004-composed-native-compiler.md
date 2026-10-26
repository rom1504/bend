# P144-004 — compose the measured cold-build changes

This entry records the immutable **final03 intermediate checkpoint**. The later
[final04 composition](../../design/phase144/final04-composition.md) removes broad
append admission, omits the ordinary outer range pass and shares the prefix
disjointness query. Its measured cold target sum is247.000s. Consult the
[current report](../../implementation/phase144/README.md) for the completed phase;
the observations below remain evidence for their original source and runtime.

The experiment combines the parser-prior index, request-local constructor
ownership facts, suffix-aware rendering, guarded single-mutator runtime,
source-backed String append admission and positive predicate branching.
The unchanged Phase142 source is the cold-request input; compiler acquisition
and self-source requests have separate clocks.

The source-only composition initially reduced one clean request from304.534s
to266.862s, with complete old QBE equality. Relinking the same object to the
serial runtime reduced that to249.679s, again with complete equality. Those
measurements justify integration, but do not predict additional savings from
the last two source changes.

Final source `31e1b13a8584130c6a6be67ef6e1f2a6a373433c9c5cac9e880fa3fe403e3ea2`
has64,587 physical lines,604 more than the qualified parent,66 additional
definitions and the same683 laws. All101 protected declarations, including the
11 inherited proof declarations and independent final verifiers, remain exact.
The finite source controls are127/127. The predicate index comparison covers336
complete trees and11,088 payload queries, separately from finite source controls.

Qualified Phase143N2 produces N1, which produces N2. Q2 and the subsequent N2
emission Q3 agree on all117,151,119 bytes. Q1 legitimately differs: the new
compiler changes code generation. Both focused19 suites and N2 ordinary45 pass
their independent stdout/refusal oracles. Host-provider/session checks and the
final authentication receipt are separate gates; consult the final
[qualification](../../implementation/phase144/qualification.json), not this
intermediate experiment narrative, for the closed admission decision.

Final N2 takes251.861s on the unchanged Phase142 source. Machine construction
takes15.469s, totaling267.330s before supervision. This is not an additional win
over the249.679s source01/runtime observation. The append and predicate changes
have useful smaller-workload evidence, but their full compiler benefit is not
demonstrated by this single observation. The generated QBE now differs from the
parent, so broad runtime and independent semantic gates cannot be inherited
solely from the earlier byte-equal source01 experiment.

Three chooser laws were accepted independently by BendTT/Lean, with an expected
false-law rejection. Their scope is total Boolean value equality. Literal-lambda
shape, single predicate evaluation, branch delay and the exact production body
bridge are separate source-review obligations. This is not a proof of effects,
ownership or whole-compiler semantic preservation.

Further bounded ablations remain distinct: omitting the outer range pass is a
code-quality policy experiment; tiny register transfers are a runtime experiment.
Neither is silently included in the above source or timings. The selected
installed compiler remains unchanged. Exact evidence and final interpretation
are consolidated in the [Phase144 report](../../implementation/phase144/README.md).
