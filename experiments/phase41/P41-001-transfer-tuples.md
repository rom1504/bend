# P41-001 — Private transfer tuples

- Status: REJECT source integration. The corrected saved-JS ablation is semantically controlled, but shows no useful benefit.
- Baseline: Phase40 checked06 direct-unfused output and API; upstream pin unchanged.
- Design: [list allocation hypothesis](../../design/phase41/lists.md). Current evidence: [list implementation record](../../implementation/phase41/lists.md).

**Hypothesis.** Replacing only a private, nonescaping `$next=[e0,e1,...]` tuple with scalar temporaries reduces worker allocation while preserving left-to-right RHS evaluation before any `$sN` assignment. Keep List values, tagged intermediate stages, frames, snapshots, guards, and fallback unchanged.

**Cheapest disproof.** The saved-output controls must pass complete values, sharing and alias behavior, host mutation/refusal, error order, parallel-transfer witnesses, and 30,000-depth checks. Then a clean matched screen must show a repeatable benefit against direct-unfused checked06. Stop if V8 removes the allocation already or results differ. The source proposal also fails if the exact static witness, matching field order, fresh temporary scope, or parenthesized expression emission cannot be proved.

**Observed checkpoint.** `lists-controls01` is retained as a failure: Acorn's expression range omitted grouping parentheses, causing a duplicate `$s1` declaration. The v2 grouped-RHS successor passed 55 oracle rows, 106 boundaries, one ordinary admission, and two independent parallel-transfer witnesses. In [`lists-screen01/report.md`](../../selfhost/build/phase41/lists-screen01/report.md) and its [raw JSON](../../selfhost/build/phase41/lists-screen01/report.json), scalar shifts relative to noise were only +0.23% and +0.40% at sizes128/512, with overlapping samples. Reject compiler/source integration. Keep the prototype and failed attempt as evidence; no benefit is established.
