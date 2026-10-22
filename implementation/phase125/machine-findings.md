# Phase125 machine-code audit

This offline audit confirms that the verified-runtime projection removes the intended checks and call arguments. It does not establish cycles saved, hot-path frequencies, or the cause of root's benchmark improvement. No target was executed. Inputs, original runtime/build receipts, source04/source06 identities, binary hashes, and disassembly hashes are retained under `selfhost/tools/performance/phase125/machine/` (`inputs.json`, `runtime-report.json`, `rle-report.json`).

The runtime comparison is precisely Phase118 `runtime-extend01/runtime.o` versus Phase125 `runtime-verified01/runtime.o`, built by root's recorded GCC toolchain. Evidence was extracted with GNU `objdump -drwC` and `nm -S --defined-only`. The table counts each primary named symbol within its nm byte extent, excluding nop alignment. It does **not** include separate outlined cold functions or count tail jumps as calls.

| Helper arity | Old→new symbol bytes | Old→new instructions | Old→new conditional branches |
|---|---:|---:|---:|
| ctor1 | 206→154 | 59→46 | 10→6 |
| ctor2 | 278→226 | 75→62 | 13→9 |
| ctor3 | 262→202 | 72→59 | 12→8 |
| ctor4 | 262→202 | 72→59 | 12→8 |
| take1 | 421→393 | 99→94 | 12→10 |
| take2 | 419→391 | 97→91 | 11→9 |
| take3 | 419→407 | 100→95 | 14→12 |
| take4 | 419→407 | 100→95 | 14→12 |

The constructor2 entry previously tested `%ecx == 2`, compared the CID with descriptor constructor count, compared descriptor arity with two, and tested the fields pointer for null. The new entry omits those four tests/branches and proceeds to the unchanged allocation path. Its capability-eight check, `cid_hot` lookup, field tag/sealing paths, allocation handling, and CTR construction are still present. The two direct `err_fail` call sites in the old primary symbol disappear; this is removal of unreachable defensive paths under the verified contract, **not** two fewer calls on every normal construction. Inlined and outlined ownership/allocation work still exists.

Take2 removes its `%ecx == 2` check and output-pointer null check. The new machine code still extracts CID, checks constructor-count bounds and arity, checks CTR tag, branches on the RFC bit, handles static/dynamic location, copies fields, and performs ownership/reclamation work. This agrees with the weaker take proof: only count and output storage were statically established, not the runtime Term's constructor shape.

The separate source04/source06 RLE binary excerpts confirm caller-side integration rather than merely unused new helper symbols. In `p114r_$direct.expand`, both calls changed from `p118_p111_rt_take2` to `p125_rt_take2`; their two `mov $2,%ecx` count-argument instructions disappear. The one remaining literal `%ecx` count setup belongs to another operation. In the private TRMC concat fallback, its take2 call similarly loses one count-argument move. The public direct concat wrapper still calls the same `p125_rt_concat_typed` helper and the same private fallback; the fallback still contains its extend and finish calls. No additional append fusion, allocation removal, or scheduler elimination is implied by these excerpts.

Representative files: `old-p118_p111_rt_ctor2.asm`, `verified-p125_rt_ctor2.asm`, `old-p118_p111_rt_take2.asm`, `verified-p125_rt_take2.asm`, and `source04-rle-2.asm` / `source06-rle-2.asm`. The JSON records all arities and decodes the numeric function-symbol spelling back to the source-level owner. Symbol layout and register allocation also change, so subtracting these whole-symbol counts is not a model of execution cost. Root's separately matched timing/output reports remain the performance and correctness evidence.
