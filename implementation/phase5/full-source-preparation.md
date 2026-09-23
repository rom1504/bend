# P5-023 preparation gates

The final comparison tool is ready; **this report contains no full-source performance result or fixed-point claim**. Five pure refusal tests pass, the corrected six-process tiny-library smoke passes, and the genuine final attempt-05 full source passes an untimed root-selection preflight.

The checked API is `5969c53d34a088bc9630eb2c065c2eea7fd260294cf3fefb14dffb305b7e4667`, compiling final source `e3b927d13dc2645e19171b72de60c49dd5bc5e5059863937153b957e2ce0ec1d`. Its actual Bend loader/specializer/root selector and pinned TypeScript loader identify the same **1,566 eligible roots**. Their natural orders differ, and the full-source order is not simply reversed. The final preflight records `prepared:true`, `complete:false`: it does not claim checking, ownership or emission. Both API-specific Base caches are separately validated and their decoded graphs agree.

The smoke caught two erroneous benchmark assumptions before any long sample:

1. Smoke-01 incorrectly required Bend's default export keys to equal selected roots. Bend deliberately exposes all `G` entries, including runtime globals and dependencies. The tiny program compiled successfully; the oracle failed. TypeScript retains an exact ordered export check; Bend now requires every selected root to be present and exact B1/derived export-key equality.
2. Smoke-02 captured the unchanged real `j_roots` return and found the same 41 fixture roots in reversed natural orders. The approved preregistration amendment makes the actual B1 preflight order the explicit common workload parameter. TypeScript verifies eligible membership before passing that exact order into its unchanged `js_lib`. Each timed B1/derived compilation must independently reproduce the preflight order.

Smoke-03 then passed all six fresh processes: full checking/ownership/completeness, requested root order, exact B1/derived output bytes, repeated TypeScript output bytes within its emitter family, and output execution. Its tiny library does not export the compiler's `j_library_roots`; that additional actual-H classifier gate remains required for the final full-source samples. No compiler or language algorithm was changed to make the smoke pass.

The delegated `j_roots` capture performs only an assignment after calling the original function unchanged. That assignment is inside request timing; list conversion is outside it. Normal API timing wrappers remain, so these are instrumented compiler-request observations, separately from complete fresh-process wall time. Priming and root preflight are setup costs outside the six samples.

[The evidence manifest](full-source-preparation-evidence/manifest.json) retains the failed reports, error output, consumed tool versions, corrected smoke observations, all-five-tests output and final-source preflight. Historical input paths are not rewritten. The original APIs and Base caches remain associated with their genuine checked attempts; this compact preparation archive is not a relocated compiler package. The final run plan is [P5-023](../../experiments/phase5/P5-023-final-full-source-comparison.md).

The direct file-backed test invocation reports all five test cases. The earlier `node --test` subprocess wrapper exposed only its enclosing file result; it is not counted as five independently visible checks. Root controls the long campaign and the subsequent unchanged `selfhost.mjs` proof from genuine checked B1.
