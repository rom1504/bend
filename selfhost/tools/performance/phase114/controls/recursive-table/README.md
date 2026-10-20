# Ordinary recursive-continuation-table controls

`manifest01.json` freezes two ordinary source candidates and independent complete
stdout. The author ran only host-side file/oracle preparation, with no compiler,
API, generated code or native target. Source check first:

```
BUN selfhost/tools/performance/phase114/controls/frontend-preflight.mjs \
  CHECKED_API selfhost/tools/performance/phase114/controls/recursive-table/manifest01.json \
  selfhost/build/phase114/recursive-table-preflight01
```

The existing `controls/prepare-jobs-v2.py --manifest ... --all` prepares the
normal emission/build/complete-output gates. Run unchanged baseline and candidate
against these same expected files. Actual admission and continuation identities
must be inspected separately before claiming the table extension is qualified.

`expression-two-children` evaluates add, multiply and subtract nodes, recursively
evaluating both children before combining results. The distinct operation cases
provide multiple continuation identities and require a continuation to start a
second descent into the same recursive owner. Expected values come from direct
integer arithmetic: `(7+5)*(9-3)-(4*3+2)=58`,
`3*(4+5)+(21-2*6)=36`, and 64 leaves of value 3 total 192. All intermediate
arithmetic remains nonnegative and within U32. The largest tree has depth six.

`owned-scan-caller` reconstructs a tree and counts text leaves. Its first
recursive result owns a tree while the continuation evaluates the second child;
the join returns an owned two-field result. Two result constructors prevent
one-record product flattening from eliminating that owning root. A caller
retains a String across `scan` and uses both the scan result and the label after
return. Shared trees, allocated Unicode strings, repeated calls and retained
external aliases all have complete observations. The depth-six shared tree has
64 leaves. Expected tree formatting and counts are literal mathematical values,
not values copied from a candidate run.

All matches scrutinize explicit parameters or pattern fields. These modest
positive programs are correctness witnesses; the existing original 45-program
expression/tree fixtures remain the performance witnesses. No raw ABI, stress,
malformed-input or custom failure experiments are introduced.
