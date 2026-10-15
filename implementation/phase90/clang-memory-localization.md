# Clang full-image memory localization

A noinline dispatch-table accessor allowed the full compiler image to build at O1: 267.681 s and 4,170,858,496 bytes peak RSS (3.885 GiB). The unchanged direct-table image had exceeded 10 GiB without completing. This establishes a build-feasibility improvement, not a speedup ratio against a successful optimized baseline. Runtime qualification and the final thresholded integration remain separate gates.

The bounded live direct-table diagnostic stopped at 97.973 s on the 6 GiB tree-RSS guard (peak 6,447,259,648 bytes). It drained 139,187,924 bytes of diagnostic stderr while storing bounded recent events, counts and periodic RSS samples. The wrapper and compiler were stopped together; the state is intentionally incomplete. This is an instrumented diagnostic, not a compiler speed result.

RSS reached about 3.56 GiB before LLVM pass logging began, then stayed near 3.60–3.63 GiB throughout all 40,153 early SROA/EarlyCSE functions, global cleanup and AlwaysInliner. At 87.03 s the pipeline entered ModuleInlinerWrapper's CGSCC setup and requested LazyCallGraphAnalysis. TargetLibraryAnalysis events finished at 87.385 s. RSS subsequently grew from 3.63 GiB at 90.165 s to 5.915 GiB at 97.684 s, with no new pass event. Thus the observed late growth is in callgraph/CGSCC setup, not the already-completed early SROA or AlwaysInliner stage. This does not attribute every byte of retained memory to one allocation site.

The source-supported mechanism is dense reference edges to the 39,642-entry global function-pointer table. An initial direct-text search found only 3 WL_DYN uses, inside the noinline FID_ENTER, BEND_CLO_APPLY and FID_EXIT segments. The missing multiplication is C macro expansion: WL_RETN expands WL_POP, which expands WL_DYN. There are 15,296 non-definition WL_RETN sites in the full C. They introduce direct table references in many generated segments before LLVM optimization; AlwaysInliner is not needed for that duplication. Site count is not a measured count of distinct LLVM graph nodes or edges.

LLVM's current LazyCallGraph implementation recursively visits constant operands of each function and records references to reachable function definitions, including references reached through global initializer operands. The exact 22.1.4 source file was unavailable through web fetching, so the detailed mechanism is supported by current primary source, measured stage attribution and the successful accessor intervention, rather than a direct graph dump from this binary. [LazyCallGraph source](https://llvm.org/doxygen/LazyCallGraph_8cpp_source.html).

The synthetic controls vary 512/2048 table entries and direct/accessor dispatch. All 4 builds succeeded, and all 4 executables matched the independent oracle. Every function executes three dynamic transitions; the oracle checks all live word registers and Env/stack fields. These are single build measurements, not repeated timing estimates. MB below means decimal bytes/1,000,000.

| Functions | Lookup | Build seconds | Peak RSS MB | Correct output |
|---:|---|---:|---:|---|
| 512 | Direct | 1.968 | 157.34 | Yes |
| 512 | Accessor | 1.886 | 152.48 | Yes |
| 2048 | Direct | 8.193 | 379.87 | Yes |
| 2048 | Accessor | 7.387 | 224.63 | Yes |

The full derivative changes exactly 2 C snippets: dynamic dispatch calls a noinline preserve_most accessor, and only that accessor references the table. Exact inverse replay recovers the original emitted C. Build guard and honest own-backend binding are at `own-native06-build-guard/process.json` and `compiler-own-native06.own-build.json`. The derived image is 2914c0a45305684013bbfc8dd4172f4ddd55347196a4bb3561ec34e0bf60804d. An accessor can add runtime overhead; memory and arithmetic controls alone do not establish compiled-program or compiler-execution speed gains.

The final integration is prepared but unapplied in `selfhost/tools/performance/phase90/regalloc/runtime-accessor-01/`: combine the upstream O0 attribute guard with a host-only accessor for FID_ENTER>=4096. The conditional is placed after the emitted FID_ENTER macro, not at the initial WL_DYN definition. Optimized smaller images retain direct lookup; GPU dispatch is excluded. The checked Bend template-generation plan then produces a coordinated runtime/template/typed-driver-pin patch. Threshold 4096 is a policy boundary, not a proven universal crossover.

Raw evidence: `selfhost/build/phase90/clang-pass01/{samples.jsonl,state.json}`, `clang-pass01-guard/process.json`, `table-accessor-control01/report.json` and `own-native06-build-guard/process.json`. Method: `selfhost/tools/performance/phase90/regalloc/pass-watch.py`. Diagnostic derivative recipe: `regalloc/prepare-table-accessor.py`; exact parent/edits/inverse and control identities are in `selfhost/build/phase90/table-accessor01/derivation.json`.
