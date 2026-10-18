# Actual Base String.append control

Frozen at 20:16:21 UTC. `source.bend` imports Base and calls its actual
`String.append`; it contains no copy of the algorithm. Request `String.append`
through native general entry and link the resulting `nx_entry(ctx,left,right)`
with this harness and its authenticated runtime. The manifest pins the complete
Base file and exact declaration, expected two-String signature, and self-only
dependency closure.

Ten graphs produce twenty independent complete-value observations. They cover
empty sides, Unicode/NUL, unique inputs, shared left and right roots, static
inputs, two owners of one physical root, and a right input physically equal to
a suffix of the left. The largest first input has 1,024 cells; the two shared
controls have lengths 512 and 513. Arbitrary recursion depth remains unqualified.

The harness only constructs and observes Strings. `reference.py` states finite
scalar-array concatenation independently. Both release orders preserve aliases
or the output as appropriate, then require empty scratch and zero dynamic live
words. `prepare.py --out FRESH_DIR` authenticates and copies the frozen assets;
`check.py --stdout FILE` checks saved output. Initial preparation is
`selfhost/build/phase110/base-string-append-controls01`. No compiler or target
was run during preparation; root owns qualification and execution.
