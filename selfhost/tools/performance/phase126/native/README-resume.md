Selected32 post-N1 storage refusal and resume
============================================

The original plan completed authenticated hosted emission, aligned N1 build and N1 focused19. Its fourth successful job was followed by a storage refusal: 262,365,184 bytes free versus 268,435,456 required. The original failed job, guard, checkpoint and all completed output receipts remain unchanged.

`native32-resume-plan01.json` authenticates those four actual successful rows and reruns the original storage gate to a fresh receipt before any remaining target. `resume.py run` executes the unchanged remaining commands through the original serial runner, then produces an explicitly labelled aggregate of four reused and eight fresh job observations. It never reports that the original failed execution completed or that the first four jobs were rerun. The final comparison binds the new resume plan and the actual original N1 image; semantic suites and timing preparation still require all twelve obligations.

The generic original guard needs 416 MiB at startup because it budgets two maximum-size files plus 160 MiB without knowledge of completed stages. The separately scoped `resume-guard.py` admits only the exact selected32 resume-plan hash after authenticating the finished prefix. It retains the original shared `ExecutionGuard`, 6 GiB RSS, 16 GiB available, CPU3, 128 MiB per-file cap, 2400-second deadline and process cleanup. It cannot launch an arbitrary plan or lower those limits.

Actual completed products are QBE 99,526,466 bytes, assembly 72,734,853 bytes, object 21,504,144 bytes and N1 binary 16,109,080 bytes. The staged reserve is:

```
max(128 MiB native stdout cap,
    actual N1 assembly + object + binary + 8 MiB)
+ 96 MiB remaining suites/logs
+ 32 MiB unallocated slack
= 256 MiB
```

The self-emitted QBE must match the complete hosted bytes before N2 starts and is then hardlinked, so its duplicate storage is released before machine construction. The N2 envelope uses identical QBE, builder, tools, flags and runtime; it is a context-specific sizing premise, not a formal bound for arbitrary tool output. The same post-N1 and pre-N2 storage checks remain in the job sequence. This admission does not authorize starting below 256 MiB.

Root can launch only after free space exceeds that unchanged staged reserve:

```sh
python3 -B selfhost/tools/performance/phase126/native/resume-guard.py \
  --plan selfhost/build/phase126/native32-resume-plan01.json
```

Read-only duplicate evidence is in `tooling-emergency-json-duplicates01.json`: six pairs of frozen conformance JSON files have identical SHA256, bytes, mode, owner and mtime. Root subsequently applied only those six pairs, recovering 11,550,720 allocated bytes; the receipt is `selfhost/build/phase126/emergency-exact-dedup01.json`. Free space was then 270,102,528 bytes, exceeding the 268,435,456-byte restart threshold. Root launched the context-specific resume guard in session87952. The remaining six candidate pairs have different mtimes and were unnecessary.

Root's subsequent bounded duplicate audit found a larger pool, recorded in `selfhost/build/phase126/duplicate-audit02.json` (SHA256 `4f1120b1ee2576b09abf6b3e73fe06662af1ab4419f333714a17aa832166d4df`). Root applied only 188 completed historical conformance JSON snapshot duplicates, grouped by identical full mtime, mode, owner and device, with SHA256 and byte comparison before atomic hardlink replacement. No paths or contents were removed. `selfhost/build/phase126/snapshot-exact-dedup02.json` (SHA256 `e1fe54312c85f62a7dd8242766c9b6e136c750d35667c6639ed85cc6cf3e4bc4`) records 418,938,880 allocated bytes recovered and 682,565,632 bytes free afterward. The broader audit's other candidates were not applied.

Root reports that the resumed storage gate passed and native self-emission is running. After successful resumed qualification, use the resume plan, not the failed original plan, with the frozen timing adapter. `resume-review01.json` pins the source-only preparation and arithmetic. No target execution occurred during preparation; root's resumed qualification remains in progress. All scripts and plans are frozen. The recovered headroom makes the remaining broad suite and optional compiler timing feasible to attempt, subject to their unchanged gates; timing still requires 256 MiB free before every request.
