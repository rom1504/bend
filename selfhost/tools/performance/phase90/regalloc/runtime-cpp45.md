# Optimized small-program preservation check

Root runs `runtime-cpp45-v2.py FRESH_OUT` inside the normal serial guard. The `--check-only` mode performs only file/schema/hash/replacement checks; it does not invoke Clang. Preflight02 passed all 45 cases with FID_ENTER 22–606 and 163 pinned headers. Version 1 and its preflight remain preserved; that method had only the 160 headers observed without optimization and was not run on targets.

Version 2 adds the three headers enabled by `__USE_EXTERN_INLINES` at O2: `bits/stdio.h`, `bits/stdlib-bsearch.h`, and `bits/mathinline.h`. The separate optimization-header audit binds their bytes, the inclusion guards, and `features.h`. None contains further include directives. The corpus does not define `_FORTIFY_SOURCE`; the command adds no such definition. Actual preprocessing must still refuse any header outside the pinned set.

For each retained checked C program, the script applies exactly the2 approved runtime edits and proves inverse identity. It preprocesses both versions with the same Clang, O2, include directory, environment, working directory and `<stdin>` filename, using read-only regular-file stdin at offset0. Actual header lists must match and belong to the set pinned before execution; headers are rechecked after each invocation. It compares every output byte, then records output hashes/sizes and removes only its own matching temporary `.i` files. The derived C and stderr are retained. C output equality is stronger than token equality here, but this is not a new Bend emission or a runtime timing measurement.

The check intentionally does not require mutable canonical runtime bytes: the old runtime comes from an already pinned compiler snapshot in the corpus receipt; the new runtime comes from the explicit candidate plan. Its source reconstruction must match that candidate exactly. Prior corpus/request receipts remain unchanged.

`runtime-boundary01/commands.json` contains4 tiny serial compile/run controls: threshold4095/4096 at O0/O2. The source uses the exact candidate attribute guard and conditional host getter block, actual21-word musttail calls, and a full live argument checksum. It additionally checks which dispatch macro and attribute branch was selected. The integer threshold is synthetic with two actual functions; this is a branch/ABI control, not a full4096-function program. No GPU execution claim is made.

Fresh actual compiler emissions with the new runtime are qualified separately by the native/JS cross-host gates. Do not conflate those with this derivative corpus check.
