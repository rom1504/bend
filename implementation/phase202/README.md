# Phase202 cold direct-x86 self-build

**Cold self-build reached 318.24s.** The previous compiler took 330.68s on the identical source, a saving of 12.44s (3.76%). The fresh 32,661,488-byte object and complete linked ELF matched the acquisition exactly. Reaching 37s requires another 8.60× speedup. This comparison contains one clean full build per role.

| Producer on the same 1,973,225-byte source | Compiler and object emission | Link | Complete |
| --- | ---: | ---: | ---: |
| Phase201 x86 | 330.41s | 0.28s | 330.68s |
| Phase202 x86, compiling itself | 317.97s | 0.28s | 318.24s |

[Measurement summary](results.json) · [Cold build and transfer receipts](cold.json.gz)

## Complete builds

The reference for this phase is a native x86 compiler compiling Bend compiler source into a new x86 object and linking it. Both producer roles use one core, the same prepared Base, the same target runtime and fresh compiler-source products. The earlier 373.57s qualified Phase198 result uses different source. The design, commands and exact inputs are retained. [Design](../../experiments/phase202/P202-001-cold-x86.md) · [Reproduction](reproduce.md)

The previous Phase201 compiler reproduced its 32,545,288-byte object and its linked executable exactly in 332.27s, including 0.28s linking. Its diagnostic sampler collected 16,592 PCs with zero drops or timer overruns. Phase201's 304.00s acquisition used a QBE-built producer. [Diagnostic and fast-gate receipts](probes.json.gz)

The repeated verifier check took **8.07s versus 8.33s** (3.18% less time, two observations per role in reversed order). Its object and output matched on all four requests. Producer peak process-tree RSS was 1.72 GiB for Phase202 and 1.73 GiB for Phase201 on the full builds.

The corrected portfolio replay compiled and executed **24 distinct programs from native45** within the session. Every emitted object matched the qualified compiler byte for byte and every program passed its independent result oracle. Full-suite qualification and production installation remain open.

## Work eliminated

| Experimental change | Gate and result |
| --- | --- |
| Stream validated ELF sections directly to the output handle | Removed construction of the whole-object byte list. Four alternating pairs took 0.856× the existing Phase201 writer on a 361,376-byte ELF. |
| Derive section lengths from verified lengths, symbol counts and relocation widths | Removed a second traversal of the payload. The complete sized writer took 0.739× Phase201, with all eight objects identical. A late invalid relocation after valid text produced exit 1 and zero output. |
| Dispatch on the first mnemonic character before checking the exact suffix | Four pairs averaged 178 ms with the original lookup and 35 ms with the candidate. The test visits 794 spellings, including all 98 valid spellings, and checks all five decoded fields. Many inputs exercise rejection; this distribution deliberately differs from normal instruction emission. |
| Recognize a fully specified pop/apply continuation before general instruction selection | The positive control matched all 118 bytes, the distinct owner symbol and the external PC-relative relocation. Three near misses fell back. The frozen object contains 7,174 copies of these bytes including the relocation target. This census measures emitted bodies; the focused test does not count admissions in a full run. |

The sized writer independently reconstructs the layout of the frozen 32,448,072-byte self-object with ten nonempty writes. In the successful case the existing output contract is exact. A failed system write may leave a partial product, so the consumer must check the compiler's exit status before accepting the object. [ELF experiments](../../research/phase202/elf/) · [Opcode controls](../../research/phase202/opcodes/CONTROLS.md) · [Continuation controls](../../research/phase202/continuations/README.md)

The independent upstream checker accepted the integrated compiler with zero unresolved holes. This is a source/type gate. The experimental overlays keep the qualified compiler available. The neutral-state string equality idea was held out of this image.

## What the whole-run profile changes

| Named leaf category | Approximate CPU sample share |
| --- | ---: |
| String operations and hashing | 21.1% |
| Reference counts and destruction | 17.5% |
| Runtime field extraction | 12.8% |
| Explicitly named x86 functions | 5.9% |

The three largest listed categories account for 8,531 of 16,592 samples (51.4%). Even eliminating all of those samples in isolation would leave roughly 161 CPU seconds at this workload size. Runtime helpers serve several stages. The first sample inside a function defined by the x86 backend occurred around 136.30 CPU seconds, after samples in the checker, frontend and shared native/QBE preparation. The first sampled encoder function appeared at 140.28s; named ELF helpers appeared at 317.64s. A named checker helper was still sampled at 44.18s. These are sampled landmarks. Function entry can precede the first sample. [Symbolized profile](full-profile.json) · [Raw capture](full-profile.pcs.gz)

For the 37s objective, measure **prepared cursor production** and **cursor-to-object consumption** as separate intervals on the same source and image. At the boundary record how often each phase hashes full identifier strings, extracts shared fields or rebuilds symbol maps. This distinguishes the payoff from assigning compact identities during checking from the payoff of bypassing whole-function planning on the x86 side. The name-operation samples alone cannot support a 9× prediction. A repeat of the standalone writer benchmark cannot settle that question either.

## Rejected runs and costs

The first frozen-source run stopped at 238.03s. Its output root had only 16 KiB allocated, while total filesystem free space fell by more than the 256 MiB allowance. The subsequent 2 GiB allowance covered unrelated writers and preserved the 5 GiB reserve. Early checks found invalid pattern-binder order, a computed match scrutinee and a missing diagnostic export. Corrected source and fixtures passed before native acquisition. The combined compiler source is 1,973,225 bytes, 18,026 bytes larger than Phase201. [All fast and failed receipts](probes.json.gz)

The first portfolio replay incorrectly compared a runtime-emitted elapsed-milliseconds field byte for byte. The runner now calls the frozen native suite’s output, repetition-count and clock-bound oracle and still requires the entire emitted object to match. A first retry overconstrained the workload arguments. The corrected runner replays each case’s own recorded arguments.
