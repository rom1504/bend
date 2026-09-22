# Independent review of saturated substitution workers

Static review finds no semantic blocker for the exact `4318bbcd…` private image and its stated immutable finite-data boundary. This permits the bounded semantic/performance experiment, not promotion or a general matcher rewrite. No compiler execution or timing was run for this review.

The transformer changes one actual `privateWorker1077` call site. Its three arguments are already bound variables, so it does not move an unevaluated later expression ahead of matcher demand. The entire input image and three worker bodies are hash-guarded; original `G.subst_node` and `G.subst_terms` bodies remain byte-identical. Full-image identity also fixes the referenced tail helpers, runtime and constructor metadata.

For canonical six-field KTerm data, the new node worker projects the same fields, completely substitutes the child list, reconstructs the node and only then tail-calls the original `core_rebuild`. It does not skip beta reduction when the target variable is absent. The new list worker returns the same ordered `build('Con', [headThunk, tailThunk])` shape, using private tail bounces for recursion. Empty lists use the existing zero-field builder. Wrong tags, missing/sparse fields and wrong field counts follow the original staged generic calls.

The original arm binds all six fields before child traversal; the new array expression reads removed metadata after child traversal. This differs for getters or concurrent mutation, which are outside the private immutable graph contract. It does not change data or demand for ordinary immutable fields. Retaining `project` and fallback avoids inventing stronger tag validation for arbitrary malformed inputs.

## Controls actually reviewed

`private-substitution-test.mjs` invokes the changed `privateWorker1077` for `mode='subst'`, plus the new node/list workers directly. Testing only the unchanged global entry would have missed the transformation; this harness does not make that mistake. It covers ordinary and generated dependent structures, Lam-headed/neutral Apps, absent-variable beta reduction, removed metadata reference preservation, malformed shapes/kids and original partial/overapplication. The early-matcher/later-argument test intentionally exercises the unchanged public path; it is a boundary control, not evidence that the new worker schedules arbitrary unevaluated expressions safely.

The completed second report records 156 controls, including successful 300-level dependent telescopes and 100,000 list-tail steps (5,406 and 800,002 observed structural nodes). These two controls returned values, not matched exceptions. The hash-based structural observer covers all enumerable fields and distinguishes sparse arrays; function results compare private arity/bound/environment data rather than raw JavaScript function identities. SHA equality is a structural digest check, not a claim that the test stores every full tree byte.

One harness hardening was requested before reusing this gate: successful deep/tail and other valid controls should explicitly assert `ok:true`, since the general differential helper otherwise accepts two equal errors. The current recorded deep/tail observations are already successful, so this is not a discovered compiler mismatch. The head-error-before-malformed-tail control should also assert the observed error equals the isolated head error; equality between two implementations alone does not prove the intended ordering. Preserve earlier reports when making these assertions.

A performance survivor still needs exact whole-compiler output/diagnostic and broader gates. A local helper result cannot establish public-library ABI equivalence, identical resource-exhaustion behavior or full conformance. No canonical worker, runtime, Bend module or default API was changed by this review.

## Gate hardening follow-up

The third immutable controls report passes **157 checks**. The owner added explicit successful-value assertions for valid/deep inputs, walked the actual 100,000-element Con spine through its terminal Nil, and checked that combined head/tail failure equals the isolated head failure. I inspected those assertions and their completed report; no additional execution was performed for this review. [Exact reviewed identities](evidence/private-substitution-workers-review.json) record the final source and report. The original two reports remain retained rather than rewritten. The identified harness gaps are resolved for this bounded gate; real-workload correctness and performance remain separate.
