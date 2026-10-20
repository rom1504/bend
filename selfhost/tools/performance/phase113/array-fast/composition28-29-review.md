# Source28/source29 fixture-only correction

The semantic review in composition26-27-review.md still applies. Exact normalized
declaration comparison finds no production changes from26 to28 or27 to29, no
added declarations and no removed declarations. Only `p113wt_text` and
`p113_width_control_report` change.

The earlier checked APIs passed, but three exact-text controls supplied a
nonterminal snippet to `p111q_body_text`; its fallthrough guard correctly refused
to render it. The corrected test helper appends `Result(0)` and the three exact
expectations include `ret 0`. Original emitter, verifier, guard, operand widths,
freshness, branch facts, array identity and heap-base behavior are unchanged.
The failed width-native26 receipt and old source/admission records remain.

The new admission pins width/modules-v3.json, the corrected fixture bytes,
complete ordered compositions, successful checked APIs and the same runtime.
Source28 keeps192/512 inline budgets; source29 keeps384/1024. Receipt completion
does not replace independent native128 arithmetic observations, complete owning
array/branch controls or selection measurements. No target was run for this
source comparison or admission preparation.
