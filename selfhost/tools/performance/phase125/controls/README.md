# Ordinary-source owned-append controls

`cases.json` is ready for the existing emission/functional harness under case
`p125-owned-append01`. No Bend check, compiler build or target run was performed
while preparing these files. `prepare.py` only generated independent expected
outputs and authenticated source/oracle manifests.

The two actual append functions, `ledger.join` and `label.join`, have the exact
ordinary arity-two structural equations, with no primitive or fabricated Term.
`ledger.changed` increments each left head and is a namespaced near miss: its
`p125p_inspect` result should be false. These analysis expectations are frozen in
`admission-expectations.json`, separately from runtime fast-path behavior.

The21 stdout lines cover:

- Retained whole left and right aliases, with all three complete lists printed.
- A freshly allocated prefix over an externally retained interior tail; complete
  result and retained tail printed after append.
- Right equal to a retained left suffix; complete overlapping result and original
  tail printed after append.
- Literal static-eligible input, both without an external alias and with one.
- A fresh list spine carrying heap String payloads shared with the right list and
  an independently retained String; complete result and original String printed.
- Empty-left/nonempty-right and empty/empty, including their retained values.
- The transformed-head near miss, including UINT_MAX→0 wrapping.
- A4096-element freshly generated scalar spine with a two-element suffix; expected
  length4098 and ordered U32 digest4232905495.

Small cases print complete values. For the deep case, the independent host oracle
enumerates4095…0,UINT_MAX,17 and computes `h = (65599*h + value) mod 2^32` from
seed2166136261. This finite length/digest check is deliberately bounded; it is not
an exhaustive equality or native-stack proof.

Source construction and retained aliases establish ordinary semantic situations;
they do **not** fabricate or guarantee a particular RFC/raw/static representation
after optimization. Read the actual helper counters/admission and emitted code
to distinguish RFC1 success, shared/static refusal, and fallback. A source-output
pass alone cannot prove that a particular fast-path branch executed. In particular,
these controls do not guarantee a wrapped-static node; the runtime guard still
requires independent source inspection or a separate lawful witness for that case.

The oracle is a short independent Python list model, not a Bend evaluator or output
captured from either compiler. Regeneration refuses changes to frozen outputs.
Preserve a rejected source version and create a new version if checking finds a
syntax/typing issue; do not silently repair expected output from target results.
