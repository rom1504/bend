# Confirmed multiline-string diagnostic location defect

The read-only review's counterexample is confirmed on genuine integration01 and final integration05. It **does not change acceptance, phase or checked status**. The earlier compiler already assigns the wrong lexer line; the final renderer additionally displays an excerpt from that wrong line because its first-character guard happens to match.

```bend
import Base
def main() -> String:
  "a
?"
?
```

Pinned TypeScript rejects the final `?` on physical line5. Integration01 says `Error: line 4:0: expected def, law, type or import; got ?`. Integration05 displays the structured expectation and highlights line4, the string-content `?"`, rather than the actual offending line5. Both parse/check lanes reject in parse with `checked:false` in all three compilers. Removing the final `?` gives a valid neighbor that agrees exactly in parse and check.

The four-observation maintained validation ran separately against each genuine API, with fresh live TypeScript in each paired gate. Each selected semantic oracle passes; **each variant retains two exact diagnostic mismatches**. No source or renderer fix was attempted, and no claim of diagnostic parity follows the acceptance-only oracle.

Root prepared the original source/selection under `build/phase5/static-review`. Identical fixture bytes were copied to the sibling `static-review-fixtures` directory before execution: otherwise the harness's recursive external-input hashing would include its own growing output directories. Original plan/selection and executed selection are retained. Outputs are `static-review/{baseline-01,final-01}`; all three compiler/preparation sessions exited0 before the exclusive proof started.

The [compact evidence](static-counterexample-evidence/manifest.json) retains exact paired observations, workflow lineage reports, sources and the comparison. Full raw reports and frozen harnesses remain at their recorded build paths. This is not a new standalone compiler archive.

The static cause is `f_scan_quote` permitting physical newlines while `f_lex_scanned` advances only column, then `fpe_here` comparing only the first source character at the recorded location. A future fix should establish accurate token positions or refuse uncertain rendering while preserving rejection priority. It requires a separate checked change and regression gate; the final frozen source is unchanged.
