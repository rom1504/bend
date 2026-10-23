Native request timing after qualification
========================================

`timing-plan.py` adapts the frozen Phase125 manifest preparation; it calls the unchanged `phase125/native/timing-run.py`. Preparation refuses until all twelve selected32 staged qualification jobs finish successfully with their exact planned commands. It also requires the staged byte-exact reproduction receipt, both focused19 gates, N2 full45, and all actual image/source/runtime bindings. It creates no full compiler image.

After qualification, root can prepare the matched three-case, three-round request screen:

```sh
python3 -B selfhost/tools/performance/phase126/native/timing-plan.py \
  --plan selfhost/build/phase126/native32-staged-plan01.json \
  --out selfhost/build/phase126/native32-transport-manifest01.json \
  --tag p126-native32-transport01 --repeat-phase125
```

Omit `--repeat-phase125` if time or disk does not permit the second block. Execute only the emitted `rootGuardCommand`, after the broad runtime screen if desired. It uses CPU3, 2 GiB RSS, 4 GiB available and exactly 8 MiB per file; bounds are 240 seconds for one block or 420 seconds for both. Qualification and timing methods are separately frozen.

Each block rotates N1, N2 and the pinned upstream compiler across lexer, closure and map requests for three rounds: 27 compiler requests, fresh aligned builds, and 27 independent complete-output observations. Native prepared-Base mode and upstream source-Base mode remain explicit. Request time and request-plus-machine-build time are separate metrics; generated-program execution checks correctness only. This is three-source compiler-cost evidence, not full compiler workload coverage or the 45-program runtime result.

The optional Phase125 repeat binds its actual selected N1/N2 images and old runtime, with exactly the same sources, expected outputs, tools, clocks and Phase123 assembler policy. It runs as a separate sequential block. Generation gains should use the fresh Phase125 repeat, with per-case spreads and block-order limitations retained; historical ratios alone do not establish attribution.

The previous Phase125 block took 59.5 seconds, wrote 27.3 MB, and had a largest file of 1.0 MB. Two blocks are therefore roughly two minutes and 55 MB by historical observation, with no guaranteed size/time claim. The unchanged runner requires **256 MiB free before every request**, independently of the outer guard's 176 MiB startup floor. Do not lower that gate: budget roughly 285 MiB free for one block or 310 MiB for both, and defer if unavailable.

`timing-review01.json` records source-only checks. No final manifest or target run was performed during adapter preparation.
