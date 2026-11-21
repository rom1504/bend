# Phase200 direct x86 runtime

The frozen comparison is the Phase199 native compiler and its live-plus-scan runtime. The 0.5× target refers to the runtime of unchanged Bend programs compiled to direct x86, relative to mature Bend C. Runtime excludes compilation. The controlled trials below have different scopes.

## Register and ownership experiments

The Bend compiler now has a checked candidate that reuses an available producer register when the frame-slot computation and all intervening instructions establish its validity. The rule changed three dynamic-programming worker objects and preserved the unrelated Mandelbrot object byte for byte. The row worker lost four instructions and six frame accesses. Edit distance took 0.936× incumbent runtime and local pair took 0.912×. The generic serialized-row program took 0.994×, despite exactly the same static instruction savings. The 20 full-output checks included the latter's four serialized arrays. [Spill selector, checked machines and measurements](../../research/phase200/spill/)

## How to interpret this phase

The focused compiler rules ran on original sources. The tree, lexer and text experiments investigate higher-level rewrites and have separate admission, correctness and measurement evidence. Each is reported against its own genuine baseline. No isolated speedup is multiplied into the full-suite metric. [Design](../../design/phase200/README.md)

The ownership ablation counted more than four million skipped immediate-tag keep/sink calls on the measured ray invocation. Its first interrupted ray screen gave 0.968× incumbent. The independent continuation gave 1.021× on ray and 1.008× on Map. Increasing the number of skipped calls did not shorten the hot recurrence reliably. The remaining call boundary still constrains register placement, and the guard itself adds instructions. Only the spill rule was selected for the new N1. [Complete counters, timings and refusals](../../research/phase200/abi/)

## Higher-level experiments

- **Lexer.** Generate each token directly into the consumer's scalar state. On the original 256-line workload this eliminated the intermediate generated string, character classification, and token-machine reconstruction while preserving the dynamic PRNG and hash. The transformed Bend program took 0.0822× the incumbent x86 time and 0.1980× mature C time. It returned the same complete outputs on seven input points and passed 25 template controls. All six balanced samples and the early/late timing shift are retained. This comparison uses the source specialization and cannot be included in the catalog compiler score. [Lexer code and evidence](../../research/phase200/lex/)
- **Tree.** A private list of stack frames originally allocated a tagged frame and a list cell for every descent. Encoding the direction in a single recursive constructor preserved bounded native-stack usage and reduced BST64 runtime by 20.5–21.2% across two orders. The source variant using direct call-stack recursion instead took 1.39–1.40× the original time. Both matched eight complete program outputs. [Tree representation experiment](../../research/phase200/tree/README.md)
- **Square root.** A leaf for the cold F32 square-root path passed 65,888 return-bit, errno and floating-point status comparisons and 1,024 register-preservation tests. The related XMM-liveness compiler change needs actual generated-program evidence before selection. [Leaf and checked scope](../../research/phase200/ray/)

## Storage and acquisition

With permission, both loose assembly files from the closed Phase199 compiler builds were archived. Decompressing each archive reproduced the original bytes and SHA-256 before the original path was removed. Both executables and objects remain available. The two verified archives released 151.5 MiB. The new acquisition streams intermediates in memory. Its parity test reproduced the previous compiler ELF byte for byte with the original input pathname; a first failed control uncovered the linker's embedding of that pathname in a local ELF symbol. [Parity, restoration and artifact identities](../../research/phase200/storage/README.md)
