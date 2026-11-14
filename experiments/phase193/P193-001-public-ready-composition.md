# P193-001: consume existing ready plans in x86 public fallback

Hypothesis: generic public scheduling survives even when independently admitted
helper implementations exist. Reusing QBE's bounded continuation/public-tail
plans should remove capture/dispatch work across compiler and user workloads.

Evidence: physical same-source compiler profile; index_leaf/index_remove/p111v_put/
p131i_insert disassembly; exact ready-helper presence. Missing R/G worker coverage
was too small/cold to explain the gap. See research/phase193/public-fallback-audit.md.

Prediction: a general capability, not a new source recognizer, with modest compile
cost. Falsifiers: unavailable target or live caller state changes; no actual kernel
runtime improvement; compile overhead outweighs execution savings; broad regressions.

Implemented in Bend public-composition.bend using original admission and fallback.
Fast kernel7.72% win; Map19.8%, expression4.95%, tree1.79%, lexer2.75%.13 structural
controls and1024 independent runtime observations pass. Full native/cost decision
is pending in implementation/phase193/README.md; no installed promotion inferred.
