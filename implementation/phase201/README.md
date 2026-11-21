# Phase201 cold direct-x86 compilation

**The new direct-x86 compiler built the verifier in 8.64s versus 9.27s (6.7% less time). The full compiler did not reach 37s.** The full comparison ran for 229.11s before the filesystem crossed the 5 GiB reserve. Its output roots had grown by only 16 KiB. With no finished object or executable, there is no candidate full-build speedup to report. The qualified full-build reference is 373.57s. [Measured evidence](evidence.json.gz) · [Reproduction](reproduce.md)

The candidate passed upstream source checking with zero holes. The QBE-built x86 producer acquired it in 304.00s. The new executable itself is direct x86, SHA-256 `15199b85f4302a4951b05b7197c319f2d6c730ea8fac8d4c7af047d9417f6142`. It produced the exact 792,160-byte verifier object and its linked program printed 768. The 8.64s integrated timing is a single observation. The qualified release remains selected. The new compiler's own fixed point and broad native qualification are open.

Once there is disk headroom for the guard, this command uses the saved image to rebuild the original compiler source and compare it against the complete frozen object and loaded sections. For a contemporary baseline, run the same operation with a fresh run name and role `baseline`.

```sh
python3 -B research/phase201/cold/job.py coldretryfull01 480 64 \
  python3 -B research/phase201/cold/replay.py --out OUT --full \
  image:selfhost/build/phase201/acquire02/program.gz
```

We used a qualified native Phase198 compiler as the reference and kept its input, Base carrier, one-core policy and output oracles. The new compiler changes how it constructs ELF objects and how its own sequential runtime releases a shared value. Released user programs still link the qualified runtime. [Experiment design](../../experiments/phase201/P201-001-cold-x86.md)

## What changed

The Bend object builder now consumes reversed machine bytes in their existing order when patching eligible local branches. The ELF writer combines validation with counting, combines counting with section layout, and writes the fields of a 24-byte relocation directly into its accumulator. The symbol builder reuses a name hash and updates an entry without inserting and immediately looking up a placeholder. The original path handles an unresolved size directive. Symbol ordering, names, relocations, public calling conventions and machine instruction selection retain their original contracts. [Branch algorithm](../../research/phase201/algorithm/reverse-fixup.bend) · [ELF rules](../../research/phase201/elf/compose.py) · [Symbol update](../../research/phase201/cold/symbols.py)

The experimental runtime moves the non-last shared-reference release ahead of the general destructor. This uses the established single-mutator configuration. Last-owner destruction still runs the original algorithm. [Runtime derivation and limits](../../research/phase201/runtime/README.md)

## Fast experiments

| Operation | Incumbent | Candidate | Evidence |
|---|---:|---:|---|
| Compiler verifier source to executable, clean, two reversed observations per role | 9.27s | 8.74s | Runtime change alone. All emitted objects matched and the generated verifier printed 768. |
| Same verifier with the earlier constructor-runtime alternative | 9.27s | 9.48s | Excluded. |
| Standalone native writer, four paired comparisons | 1.000× | 0.462× | Identical 361,376-byte objects. Independent expected section contents, all 4,096 branches and all 4,096 relocation entries passed. |

The physical verifier profile sampled 2,321 PCs under the x86 producer and 1,902 under the QBE producer. They emitted identical objects. The x86 leaves included 232 samples in destruction, 141 in shared-field copying, 154 in borrowed string equality, 114 in identifier hashing and 113 in string ordering. Sampling recorded timer overruns. These are approximate leaf shares on this request. [Independent writer control](../../research/phase201/elf/results.json)

## Remaining headroom

The frozen compiler's 39,520 continuation functions account for 14,205,793 of its 20,972,577 instruction bytes. Accounting for relocation positions, types, addends and target symbol identities leaves 23,483 unique continuation bodies. Repetitions account for 3,511,139 bytes. A useful next experiment is to recognize one large repeated family before verification and instruction selection, retain a distinct callable identity for each member and measure the cold compiler time that disappears. Folding duplicate output after producing it would still pay the earlier compiler costs. Machine bytes alone give no wall-time estimate. [Reproducible census](../../research/phase201/cold/continuations.py) · [Counts](continuations.json)

The largest exact family alone has 7,174 copies of a 118-byte function. The representative `$p111.k.3195` pops one saved word, reads a state field, calls `p111_rt_apply` and returns the reply. Its exact repetitions account for 846,414 bytes. The first experiment should recognize the typed pop-and-apply sequence, prove all captured operands and ownership actions agree, and reuse selection and encoding while preserving distinct symbol identities. The frozen bytes make an independent oracle possible. [Source lowering](../../selfhost/src/back/qbe/lower.bend) · [Public x86 segment path](../../selfhost/src/back/x86/program.bend)

## Research cost and rejected runs

The initial short probe replaced the mode argument with the source pathname; the existing CLI refused the request. The corrected probe reproduced both compiler products. The upstream checker caught a pattern-binder ordering error in the first branch overlay. The corrected complete source checked with zero holes. These finite gates do not constitute a compiler-correctness proof.

Two resource-guard stops consumed 191.78s on a full diagnostic profile and 281.31s on the first full image acquisition. The guard measures filesystem-wide free space as well as declared roots. The latter run wrote only 16 KiB under its roots while the filesystem fell 12.22 MiB. A repository commit coincided with that stop. The counter does not attribute the writer. The restarted acquisition used the qualified QBE-built x86 producer. It completed in 304.00s of compiler plus linker time. Its product is native direct x86. Further repository commits waited until the physical lane finished.
