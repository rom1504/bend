# Phase151 independent audit

The frozen Unit counterfactual supports the claimed local cause of the scalar dispatch regression. I found no material discrepancy in the receipt, changed instructions, runtime representation or measured call path. This is evidence about two consumed selector workers in one artifact; it neither promotes the source rewrite nor qualifies a general compiler optimization. This audit read retained files and disassembled the existing runtime object; it executed no compiler or benchmark target and changed no production source.

**Identity and exact scope.** I recomputed the hashes below and independently compared all 26,348 SSA lines against [the observation receipt](../../selfhost/build/phase151/unit-patched02/observation.json). Its complete 84-entry old/new-line list matches the actual diff. There are exactly 42 constructor replacements and 42 sink replacements, with no changed bytes outside the two functions.

| Artifact | SHA256 |
| --- | --- |
| [Original SSA](../../selfhost/build/phase151/probe-native01/program.ssa), 1,046,634 bytes | `ce4d2ca909ac855c8cae8a43c95bfeae75e55e5e7832c43995c25f1d67f00e9d` |
| [Patched SSA](../../selfhost/build/phase151/unit-patched02/program.ssa), 1,042,728 bytes | `13683aad9018682f7a6a5e5f49d245c7ae27b9dd34fa764a850e53dc760dc8cd` |
| Original `probe-native01/program` | `7a80867beb7891dcfe1715282592045516790ce367a8505128e02d7bf405053b` |
| Patched `unit-machine01/program` | `66e434df3b670d120a2d39fcc730ef10311905ed8b7520f831845b84c65fac99` |
| Shared `selfhost/.assets/native/qbe-runtime.o` | `2d07832382a11d7e993124ecc70452e4e1a3b7f753cf429343e1183cd8e493a3` |

The [original build report](../../selfhost/build/phase151/probe-native01/report.json) and [patched machine report](../../selfhost/build/phase151/unit-machine01/report.json) bind these products to the same runtime, QBE/assembler/linker identities and construction flags. Both binaries are 310,200 bytes. The latter report consumes the exact patched SSA; it claims machine construction, not compiler semantic qualification.

The two [body pins](../../selfhost/tests/phase151/unit-counterfactual-pins.json) each occur exactly once and match their recorded bytes/hashes: roles starts at SSA line 4411, binary at 3554. They are the `p113d` workers for `$direct.p151p_roles_select` and `$direct.p151p_binary_select`, with 22 and 20 replaced pairs respectively. The corresponding loops call these exact workers at SSA lines 5283 and 4349. Standalone table definitions, common loop Unit calls, consumer loops, metadata and output logic are unchanged. Existing assembly independently shows 22/20 constructor calls and 22/20 sinks in the original selectors, and zero of either in the patched selectors.

**Semantic justification.** Every changed constructor is exactly `p111_rt_ctor(state, 0, scratch, 0)`. At every site its result passes through two unchanged copy aliases to the replaced sink exactly three lines later. The replacement values are respectively `72057594037927936` and `0`.

The frozen program's constructor table names cid 0 `Unit` and gives it arity zero; its constructor count is 150. In [runtime.c](../../selfhost/src/runtime/qbe/runtime.c#L3936), the constructor checks the admitted cid/arity, then returns `term_pak(cid,0)` immediately for count zero, without reading fields or allocating. [TAG_PAK and term_make](../../selfhost/src/runtime/qbe/runtime.c#L810) give `(1 << 56) | (0 << 40) | 0`, exactly the replacement. [term_triv/term_sink](../../selfhost/src/runtime/qbe/runtime.c#L849) makes this packed term trivial, and `p111_rt_sink` returns zero. Disassembly of the actual linked runtime object confirms the count-zero branch at object address `0x4290` shifts cid by 40 and sets bit 56; its sink returns zero for this tag at `0x40eb`. These are removed calls, checks and resulting register/stack costs, not removed Unit heap allocations. Omitting the constructor check is justified by this authenticated artifact's table; numeric cid 0 is not a portable optimization rule.

**Measured evidence.** [unit-timing00](../../selfhost/build/phase151/unit-timing00-guard/stdout.log) passes 514 exact input pairs, 28 independent table cases, 10 comparator controls and 10 loop observation pairs. The exact table checks mostly exercise unchanged standalone definitions; the patched selectors are exercised by the consuming loop controls and timings, backed by the instruction/ABI argument above. Checksums force complete consumption but are not collision-free equality proofs.

The `unit-timing01..16-guard` process/stdout receipts all complete with exit zero and empty stderr. Each mode uses original–patched–patched–original order, CPU 3, one Bend thread, GPU off, 20,000,000 calls and seed 4294967290. Two observations per image give these mean local-region milliseconds:

| Mode | Original image | Patched image | Guard runs |
| --- | ---: | ---: | --- |
| reference roles | 693.5 | 711 | 01–04 |
| scalar roles | 1313.5 | 685 | 05–08 |
| reference binary | 1566.5 | 1556 | 09–12 |
| scalar binary | 2195 | 1560 | 13–16 |

Every roles run reports hash `3137549701`; every binary run reports `2649365541`. The [probe](../../selfhost/tests/phase151/dispatch-probe.bend) consumes every returned list word/String character, mixes the unmasked input, and demands the final hash before its closing clock. The local region includes dispatch, iteration and observation; external process receipts additionally charge startup/reporting/cleanup. The input distribution uniformly cycles roles 0–15 and binary 26–41, not a measured compiler workload distribution.

The approximately 0.63-second reductions in both scalar regions strongly support the Unit sequences and their resulting machine code as the cause of this witness's regression. They do not isolate an individual runtime-call latency. Reference-path variation and two samples per image preclude claiming a small speedup over the original tables. No complete decoder or whole-compiler run is needed to retain this narrow research result; neither transfer nor whole cold-build benefit has been measured.

**Follow-up and receipt caveat.** The smallest justified implementation investigation is the already documented [preservation of authenticated nullary constants through expansion](../phase131/safe-codegen.md#follow-on-keep-prepared-nullary-constants-through-expansion), followed by this same consumed witness and compiler-cost accounting. The scalar source and 134-line/27-definition balanced workaround remain experimental. One stale provenance field is harmless to the actual result: `unit-counterfactual-pins.json` still describes the older compiled-pins `INPUT OUTPUT` CLI. The [current CLI](../../selfhost/tests/phase151/unit-counterfactual-cli.bend) and [successful patch guard](../../selfhost/build/phase151/unit-patched02-guard/process.json) correctly use `INPUT ROLESPIN BINARYPIN OUTPUT`; use that receipt for reproduction. The pure patcher authenticates exact supplied bodies/counts, while whole-file and pin hashes are the supervisor's obligation. It is not a general SSA transform.
