# Phase194 predicate machine audit

The predicate candidate removes all three materialized Boolean/test chains from the actual positive row loop used by local-pair and editdist. Comparisons now feed the existing three conditional moves directly. Original frame allocation remains unchanged.

This is an offline audit of Phase193 `budget-native45-02` against Phase194 `predicate-dev-build01`, using the six exact case products selected for runtime comparison. No target was executed here. [Derivation script](predicate-machine-witnesses/derive.py) uses `nm`, bounded per-function `objdump`, and section sizes; [report](predicate-machine-witnesses/report.json) records exact binaries, hashes, symbols, addresses and assembly witnesses.

| Row metric (same in both cases) | Phase193 | Predicate |
| --- | ---: | ---: |
| Whole function bytes | 1535 | 1479 |
| Reserved frame bytes | 3136 | 3136 |
| Whole function instructions | 314 | 298 |
| Positive loop instructions | 93 | 77 |
| Positive loop SETcc / TEST / CMOV | 3 / 3 / 3 | 0 / 0 / 3 |
| Positive loop frame-memory instructions | 21 | 20 |
| Positive loop calls | 0 | 0 |

The counted positive path includes its loop-header comparison/branch and backedge, excluding the zero-count exit. These are static instruction counts, not dynamic samples or a speed estimate. Frame-memory counts exclude address-only LEA and NOP.

In [local-pair baseline](predicate-machine-witnesses/local-pair-baseline-0.asm), the cost comparison becomes SETcc, zero extension, a copy/truncation, XOR-one inversion and TEST before CMOV. The two minima similarly materialize predicates before testing them. In [the candidate](predicate-machine-witnesses/local-pair-predicate-0.asm), CMP at `0x40cbbc` feeds CMOVNE at `0x40cbd3`; the minima use CMP/CMOVB at `0x40cc3c`/`0x40cc49` and `0x40cc7a`/`0x40cc8b`. Only MOV loads/snapshots intervene, preserving flags. Selected inputs are captured before result publication. The predicate spill at `-0xb50(%rbp)` disappears; surrounding selected-input/result spills remain. Editdist has the same changes, with its candidate row addresses five bytes later.

| Case | Whole `.text` bytes, baseline → predicate | Other inspected functions |
| --- | ---: | --- |
| local-pair | 130785 → 130097 | `$product.row` above |
| editdist | 135665 → 135009 | `$product.row` above |
| numeric recurrence 256 | 101633 → 101633 | `$direct.p37.numeric`: unchanged measured function metrics |
| ray active 64/2440 | 149249 → 149233 | `$product.trace`, `$direct.subray`, `$direct.trace`: unchanged measured function metrics |
| lexer | 130465 → 130481 | `$product.lex`, `$direct.cls`: unchanged measured function metrics |
| tree-bitonic | 131569 → 131569 | `$direct.scan`, `$direct.warp`, `$direct.warp_leaf.go`: unchanged measured function metrics |

Here “unchanged measured function metrics” means identical symbol size, frame reservation, instruction count, frame-memory count, SETcc/TEST/CMOV and call counts. It does not assert byte equality or absence of changes elsewhere. Whole-section size includes other functions and alignment; it is not attributable entirely to the row. Original frame layout explains why removing one spill does not shrink the reserved stack.

The machine evidence establishes that the intended optimization reaches real row kernels and leaves substantial memory traffic intact. Finite predicate controls passed in the root-owned `predicate-controls01` run; runtime gains and their uncertainty belong to the independently executed balanced comparison, not to these static counts. This audit alone makes no compiler-request speed, suite-wide speed, ABI-proof or installation claim.
