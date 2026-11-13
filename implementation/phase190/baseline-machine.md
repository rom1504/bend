# Phase190 bounded static machine audit

The frozen Phase188 direct-object `local-fold` executable still has **66
instructions and 21 explicit frame-memory references on its positive iteration
path**. These are independently recounted from the current ELF, not copied from
Phase186. The whole function has 190 instructions and 82 frame references.
No inspected executable, compiler, or benchmark was run by this audit.

The inspected symbol is
`p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_`
(`product.fold.loop` direct entry). It starts at `0x409cd4`, ends exclusively at
`0x40a04f`, and occupies 891 bytes. The source catalog is
[`native45-final06/report.json`](../../selfhost/build/phase188/native45-final06/report.json).
The executable is
[`local-fold/object/machine/program`](../../selfhost/build/phase188/native45-final06/local-fold/object/machine/program).

| Static instruction set | Instructions | Explicit frame refs | Moves | Calls | Branches | Conditional branches |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Whole function | 190 | 82 | 142 | 2 | 5 | 3 |
| Positive iteration path | 66 | 21 | 49 | 0 | 3 | 2 |

## Exact positive-path spans and interpretation

The instruction spans are end exclusive, relative to the symbol:

* `[+0x1d7,+0x200)` = `[0x409eab,0x409ed4)`.
* `[+0x22a,+0x328)` = `[0x409efe,0x409ffc)`.

At `0x409eab` the code checks `%r13 == 0`. For a positive remaining count,
the `je` at `0x409ece` takes the path to `0x409efe`, bypassing the return block.
The second check computes `%r13 != 0`; its `je` at `0x409f21` is not taken.
The body decrements `%r13` through `%rdi`, updates the loop state, and the `jmp`
at `0x409ff7` returns to `0x409eab`. This is the ordinary positive path after
the entry guards pass. No trip count, total dynamic instruction count, or
runtime improvement follows from this static observation; entry setup, exits,
fallbacks, and the rest of the program are separate.

The 21 frame references consist of four predicate spill/reload instructions
(`0x409ebd`, `0x409ec4`, `0x409f10`, `0x409f17`), five index/accumulator reads
and writes (`0x409f31`, `0x409f46`, `0x409f78`, `0x409fe8`, `0x409ff3`),
three invariant reads (`0x409f4a`, `0x409f61`, `0x409fcc`),
and nine temporary transport instructions (`0x409f71`, `0x409f7e`, `0x409f88`,
`0x409f8f`, `0x409fa1`, `0x409fa8`, `0x409fb2`, `0x409fb9`, `0x409fec`).
This exposes concrete candidate mechanisms without claiming a speedup.

Frame references mean explicit `%rbp`/`%ebp` addressing. These counts do not
represent cache misses or DRAM accesses. The script separately identifies
`lea` address calculations (zero here), and does not count implicit stack
accesses by push/pop/call/ret. Moves include `movabs` and extending moves.

## Reproduce and compare

The maintained static inspector is
[`machine-audit.py`](../../selfhost/tests/phase190/machine-audit.py), with the
explicit baseline spans in
[`local-fold-baseline-regions.json`](../../selfhost/tests/phase190/local-fold-baseline-regions.json).
It runs only `nm` and `objdump` for binary inspection, checks exact symbol-byte
coverage, authenticates artifacts before and after inspection, and refuses
output-directory reuse or invalid/overlapping instruction spans.

```sh
python3 -B selfhost/tests/phase190/machine-audit.py \
  --baseline selfhost/build/phase188/native45-final06/local-fold/object/machine/program \
  --symbol p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_ \
  --regions selfhost/tests/phase190/local-fold-baseline-regions.json \
  --out selfhost/build/phase190/machine-audit-baseline02
```

The retained invocation is
[`machine-audit-baseline01/report.json`](../../selfhost/build/phase190/machine-audit-baseline01/report.json)
with [raw disassembly](../../selfhost/build/phase190/machine-audit-baseline01/baseline.0.asm)
and [raw symbol table](../../selfhost/build/phase190/machine-audit-baseline01/baseline.nm.txt).
To compare another machine, add `--candidate PATH`; whole-function deltas are
candidate minus baseline. Repeat `--symbol` for additional symbols. Candidate
loop spans must be inspected independently and added under the `candidate`
region-spec key; baseline offsets must not be blindly reused after code changes.
Only regions with the same explicit name are compared.

Inspector smoke validation passed identical-artifact zero deltas and rejection
of a missing symbol. The baseline's summed decoded instruction lengths exactly
cover all 891 symbol bytes. These checks validate the transport/parser scope,
not compiler correctness.

## Exact identities

Both inspection tools identify themselves as GNU Binutils for Debian 2.35.2.
All digests below are SHA-256; the JSON receipt also records sizes, resolved
paths, arguments, and raw-output hashes.

| Artifact | SHA-256 |
| --- | --- |
| Baseline executable, 192728 bytes | `b4a844237ab474d131048fa454fd131b8f71b4039bacb695d96223bcc0d6b5af` |
| `/usr/bin/x86_64-linux-gnu-nm` | `87b64b1602fce14d565fb381703cdccfeac6c9e2dc262058b639357d86af56e3` |
| `/usr/bin/x86_64-linux-gnu-objdump` | `0a5231844dd50b01c5161cd8857c61fc6c56704c8553d61a20264e8227561930` |
| `/usr/bin/python3.9` | `ca7655083b581ffe36c72dcb445857704db533ca39b03f79c97d8d0ef3bef9af` |
| Audit script | `019882bc0fefbb2b81e294a1d15245611718fe9ad5159bf9d2134864538283d4` |
| Fresh raw disassembly | `d8644dbe78a2f9aca8e1609bef5263ac8b654cc5d4c7ec7903948eb465210552` |

No new QBE recount was made here, so the earlier 17/0 QBE comparison remains
historical evidence rather than a freshly authenticated result of this audit.

## Follow-up: remaining selector work after register placement

This second read-only audit partitions the same 66 instructions. Categories are
disjoint; predicate materialization includes its two extending moves, while
the five width-publication moves are the separate 32-bit self-moves.

| Category | Count | Exact contents |
| --- | ---: | --- |
| Data computation and array accesses | 10 | count decrement; index increment; mask; multiply by four; two address additions; accumulator addition; xor; array load and store |
| Comparisons and control flow | 5 | two comparisons, two conditional branches, one backedge |
| Boolean materialization and testing | 6 | two `setcc`, two `movzbl`, two `test` |
| Predicate and temporary frame transport | 13 | four predicate refs plus nine temporary refs listed above |
| Parameter/invariant frame transport | 8 | five index/accumulator refs plus three invariant refs listed above |
| Register-to-register transport | 19 | two comparison-input copies, fourteen body copies, three backedge copies |
| Width publication | 5 | self-moves at `0x409f35`, `0x409f41`, `0x409f7c`, `0x409f85`, `0x409f9c` |
| Total | 66 | |

The final six instructions before the backedge are three logical assignments,
each emitted through `%r10`: count from `%rdi` to `%r13`, index from `%r8` to
`-0x40(%rbp)`, and accumulator from `-0x998(%rbp)` to `-0x50(%rbp)`. The first
two are avoidable scratch chains; the final memory-to-memory transfer still
needs a register unless allocation removes a memory home.

**The largest separate selector opportunity is physical operand forwarding and
copy coalescing.** Merely putting more locals in homes can turn frame traffic
into register copies; it does not automatically eliminate those copies. Nine
instructions in this exact baseline can be removed by the following local
physical rewrites, without changing the IR computation or allocating more
homes:

| Existing span | Equivalent local instruction choice | Reduction |
| --- | --- | ---: |
| `0x409f6b`: copy `%rdx` to `%r10`, then array load through `%r10` | load directly through `%rdx` into `%r10d` | 1 |
| `0x409fd6`–`0x409fdc`: copy base to `%r10`, value to `%r11`, store | `movl %esi,(%rdx)` | 2 |
| `0x409fdf`–`0x409fe2`: `%rdi` → `%r10` → `%r13` | `movq %rdi,%r13` | 1 |
| `0x409fe5`–`0x409fe8`: `%r8` → `%r10` → frame | store `%r8` directly | 1 |
| `0x409f5e` and `0x409fc9`: copy `%r9` to `%r11` before address addition | use `%r9` directly as each addition's source | 2 |
| `0x409f9e` and `0x409faf`: copy to `%r10` before temporary frame store | store `%rbx` or `%rsi` directly | 2 |

Each removed scratch value is overwritten before its next surviving use on
this path. The direct load keeps its destination in `%r10`; the source address
is evaluated before that destination is written. These are candidate rewrite
witnesses, not changes already implemented or correctness-tested. They yield
a concrete **66 → 57 static-instruction target** independently of the new
allocator and branch fusion; their savings must be recounted on the candidate
because those changes can overlap them.

The five width self-moves offer a smaller separate opportunity. Two follow
frame loads and can potentially be selected as 32-bit loads; two follow
arithmetic and can potentially be absorbed into 32-bit arithmetic; the fifth
follows reloading a previously zero-extended array element. The last needs
value/storage provenance. A generic `movl %reg,%reg` deletion is unsound because
it clears the upper 32 bits. With these exact width facts established, these
five sites suggest **57 → 52** before counting allocator/fusion savings. There
are no per-iteration tag shifts here; descriptor/tag decoding happens before
the loop. Width operations must not be confused with that setup work.

### Existing forwarding does not perform this physical cleanup

[`scratch-forward.bend`](../../selfhost/src/back/x86/scratch-forward.bend)
tracks fixed IR scratch-buffer cells and replaces known loads with `N111Set`.
It keeps stores/allocas, kills facts across control edges, and runs before
physical allocation in `x185_function_place`. It is not a machine-register
forwarder. In particular:

* [`physical-moves.bend`](../../selfhost/src/back/x86/physical-moves.bend)
  removes a source copy only when an assigned destination already is that
  source's home. Loads still snapshot their base in `%r10`; stack destinations
  still use the old scratch sequence.
* [`register-binary.bend`](../../selfhost/src/back/x86/register-binary.bend),
  `x185_physical_selected`, always snapshots a non-immediate right operand into
  `%r11`, even when its physical source differs from the destination. Direct
  operand use needs an explicit alias check; destination/right alias is the
  reason the existing conservative snapshot is sound.
* [`parallel-moves.bend`](../../selfhost/src/back/x86/parallel-moves.bend),
  `x186_p_chosen`, schedules by physical home but emits each surviving move as
  load-to-`%r10` plus store-from-`%r10`. It already removes home-identical moves
  and preserves dependencies, so direct register/memory instruction selection
  can be layered after the existing schedule.
* [`machine.bend`](../../selfhost/src/back/x86/machine.bend) concatenates,
  renders, and assembles typed sequences; there is no general physical
  move/width peephole in that consumer.

The present machine operand model already represents arbitrary register bases
and register ALU operands, so the nine local reductions need no new addressing
form. Scaled indexed addressing is a larger separate extension: `X187Mem`
currently has only base plus displacement, not index and scale. That extension
could subsume multiply/address instructions, but is unnecessary for the first
physical-copy experiment.

### Cheap attainable-size estimate, with limits

Keeping both original checks and the duplicate address addition leaves a core
of **15 computation/access/control instructions** in the partition above.
That is an accounting floor for those retained operations, not an achievable
whole-loop claim: state transport, alias preservation, two-address x86
constraints, width publication, and finite homes still cost instructions.
With suitable register placement plus physical-copy and width cleanup, a
**roughly 20–30 instruction path** is a plausible engineering target without
changing the IR algorithm. This estimate is not a measured candidate or a
formal lower bound. The first concrete test should be the nine local copy
reductions on actual candidate disassembly; obtaining 17/0 or extrapolating
runtime from instruction ratios is not justified by this audit.

The second logically redundant count check and repeated address computation
suggest further dominance/value reuse work, but neither should be credited to
adjacent compare/branch fusion or register allocation alone. Eliminating them
requires additional facts across the control or value sequence.

## Candidate alpha: actual static comparison

The completed
[`candidate-build01/report.json`](../../selfhost/build/phase190/candidate-build01/report.json)
was observed with `complete: true` before pinning the executable. Root identifies
this candidate as policy 2 plus liveness and branch selection, with physical
operand improvements disabled. The inspected product is
[`candidate-build01/local-fold/machine/program`](../../selfhost/build/phase190/candidate-build01/local-fold/machine/program).
Its compiler API is `candidate-api08/api.mjs`, SHA-256
`f1ba92f4201892dbc17bca184227fc2776651bd9f9a8bdadafbafbcb7eea2778`.

| Static instruction set | Baseline instructions | Alpha instructions | Baseline frame refs | Alpha frame refs | Baseline moves | Alpha moves |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Whole function | 190 | 183 | 82 | 41 | 142 | 135 |
| Positive iteration | 66 | 59 | 21 | 10 | 49 | 42 |

The candidate symbol starts at `0x409954`, ends exclusively at `0x409c5a`,
and occupies 774 bytes. Its positive path is independently selected as
`[+0x194,+0x1b2)` plus `[+0x1da,+0x2b3)`, or
`[0x409ae8,0x409b06)` plus `[0x409b2e,0x409c07)`. Both paths retain three
branches and zero calls. The candidate whole function adds 12 explicit `%rsp`
references for fallback-call argument snapshots; none lies in the positive
iteration. Thus 82→41 `%rbp` references must not be described as the whole
function's total explicit stack-reference reduction (82→53).

**Branch fusion does not fire at either of this loop's two checks.** Each still
contains a compare, `sete`/`setne`, `movzbl`, a move into `%r10`, `test`, and
`je`, at `0x409ae8`–`0x409b00` and `0x409b2e`–`0x409b46`. Enabling a pass is
not evidence that this witness benefits from it.

The candidate's 59 instructions partition as follows:

| Category | Baseline | Alpha |
| --- | ---: | ---: |
| Computation and array accesses | 10 | 10 |
| Comparisons and control flow | 5 | 5 |
| Boolean materialization and testing | 6 | 6 |
| Explicit frame transport | 21 | 10 |
| Register-to-register transport | 19 | 23 |
| Width self-moves | 5 | 5 |

The remaining ten frame references are three invariant reads (mask at
`0x409b7a`, array base at `0x409b8e` and `0x409bd1`) and seven temporary
transfers. Count is stored at `0x409b56` and reloaded at `0x409be4`; next index
is stored at `0x409b73` and reloaded at `0x409bee`; accumulator is stored at
`0x409bb1` and reloaded at `0x409bb8` and `0x409bf8`. State placement has
removed frame traffic but leaves snapshots for next-state values.

Remaining physical copy witnesses include the load-base copy at `0x409b98`,
two store-operand copies at `0x409bdb`/`0x409bde`, and three backedge
load-to-`%r10`/copy-to-home pairs at `0x409be4`–`0x409bff`. Each of those
backedge pairs could instead load directly into its destination after the
existing dependency schedule. The xor input also travels `%r8`→`%r9`→`%r11`
at `0x409bbf`/`0x409bc2`. These confirm that physical operand cleanup remains
relevant on the actual allocated candidate, rather than only the baseline.

The retained comparison with explicit region deltas is
[`machine-audit-alpha02/report.json`](../../selfhost/build/phase190/machine-audit-alpha02/report.json),
with [raw candidate disassembly](../../selfhost/build/phase190/machine-audit-alpha02/candidate.0.asm)
and [region specification](../../selfhost/tests/phase190/local-fold-alpha-regions.json).
`machine-audit-alpha01` retains the earlier whole-function inspection used to
locate candidate spans. All tool identities remain those recorded above.

| Alpha identity | SHA-256 |
| --- | --- |
| Executable, 188624 bytes | `2d1845693cb26ad8d9bb46079acfe1c5d34bdd2c358f5bcbef40415a10650e65` |
| Complete build report | `a91c7748a7bd6fe121e70a0687d7b07dd912a23bbb8097ca690fd490034d585f` |
| Raw candidate disassembly | `f7ea3e8c0ce2079df4bcb4e64ff028af3ed6025406c5a65504ae2a9a1f58847a` |

This audit executes no generated program and makes no correctness, timing,
promotion, or total-dynamic-work claim.

## Prepared physical profiling follow-up

[`profile-plan.py`](../../selfhost/tests/phase190/profile-plan.py) now prepares
recipes for the maintained general profiler without executing targets. The
first [prepared plan](../../selfhost/build/phase190/profile-plan01/plan.json)
pins baseline, operand-build01, retained C, their shared source/independent
oracle, the calibration receipt, and the retained all-thread sampler. General
`run.py --check-only` accepted the manifest with 23 pinned inputs and reported
`targetsRun: false`.

Runtime02 CPU calibration selects 121723 baseline repetitions, 122679 operand
repetitions, and 957660 C repetitions, with four warmups and unchanged 4096/17
arguments. Each execution is estimated at 2.9 seconds; one clean execution and
8ms/13ms captures for all three roles total approximately 26.1 target CPU
seconds and 585 pooled samples per role. The actual fresh outputs and sampling
quality remain unobserved until root runs the plan.

`plan.json` supplies the exact `captureCommand` argv: the existing general
profiler inside a 60-second CPU3 guard, 2GiB RSS limit, 16GiB available-memory
floor, 64MiB whole-run disk budget, and default 5GiB disk reserve. The capture
output and guard output are fresh, distinct roots. Its two `offlineCommands`
then run the maintained comparator and renderer. No diagnostic runtime relink
or compiler build is requested. Every execution independently checks the full
fixed output, warmup count, repetition count, one unsigned elapsed-time line,
empty stderr, and successful exit.

Use accepted sample counts of at least 500, both periods, zero loss/overruns,
valid thread lifecycle/delivery, sufficient sampled process/child CPU coverage,
and usable symbol attribution. Shares use period weighting; 500 is the
comparator's accepted-sample threshold, not a time-weighted substitute for
sample count. Missing threads or failed coverage prohibit quantitative hot-share
claims even if sample counts are sufficient. The all-thread collector supports
aggregate physical attribution, not a global chronological timeline. C may
inline its loop into a caller. Physical ELF names alone do not establish source
ownership. Since counts differ by role, divide clean CPU and estimated owner
CPU by each repetition count before comparing; raw total-CPU ratios are not
per-iteration speed ratios.

## Observed profiles and preserved comparator refusal

Root completed all nine executions in
[`profile-capture01/report.json`](../../selfhost/build/phase190/profile-capture01/report.json).
All fresh independent output checks pass. The maintained comparator correctly
refuses the combined recipe: `Same workload name has different source/arguments:
local-fold`, because calibrated repetition arguments differ by role. This is a
negative harness result, not a profile-quality failure. The original report and
manifest remain unchanged; no workload-identity check was relaxed.

[`profile-analyze-roles.py`](../../selfhost/tests/phase190/profile-analyze-roles.py)
authenticates the original report/manifest, commands, executable bytes, outputs,
and capture/analysis bindings, then calls the maintained `pool_captures`
separately for each exact role command. Its
[`profile-role-analysis01/report.json`](../../selfhost/build/phase190/profile-role-analysis01/report.json)
retains the comparator refusal and independent within-role pools.

| Role | Accepted 8ms/13ms samples | Dominant physical leaf | Period-weighted share | Clean CPU per repetition |
| --- | ---: | --- | ---: | ---: |
| Baseline | 323 / 200 = 523 | `p113d_FID_$product.fold.loop` | 99.749% | 21.553 µs |
| Operands | 338 / 210 = 548 | `p113d_FID_$product.fold.loop` | 99.558% | 22.207 µs |
| Retained C | 330 / 202 = 532 | `NF_FID_p93.loop` | 99.848% | 2.741 µs |

All three pools pass the unchanged 500-sample threshold; all six captures have
zero dropped samples, overruns, unknown leaves, and rejected captures. Thread
lifecycle/delivery checks pass. Sampled-thread CPU covers more than 99.999% of
process CPU; capture windows cover more than 99.91% of child CPU. Sampling/clean
wall ratios are respectively 0.99046, 1.00095, and 1.00661. The CPU-per-repetition
column is descriptive normalization of one clean observation per role, not a
balanced performance qualification. Estimates have no confidence intervals.
The loop's physical dominance is supported; optimizing runtime allocation or
dispatch outside this loop cannot explain away this witness's remaining gap.

## Joint candidate and the actual hot C instruction region

The completed `joint-build01` product has a **39-instruction positive iteration,
two frame references, 26 moves, zero calls, and three branches**. Its whole
function has 147 instructions, 31 frame references, and 564 bytes. The
independently selected positive spans are `[0x40948f,0x40949c)` and
`[0x4094cc,0x409553)`, offsets `[+0x115,+0x122)` and `[+0x152,+0x1d9)` from
symbol start `0x40937a`. Both branch comparisons now feed branches directly.

The 39 instructions partition into 10 computation/access operations, five
comparisons/control instructions, two frame transfers, 17 register copies, and
five width self-moves. Next index alone spills at `0x4094f7` and reloads at
`0x409541`. The sequence at `0x409526`/`0x409529` copies `%rbx`→`%rdx`→`%rbx`
without an intervening modification; saving the accumulator in `%rdx` is useful,
but the immediate copy back is redundant. The five width self-moves remain at
`0x4094e6`, `0x4094f2`, `0x409519`, `0x40951e`, and `0x409524`. Array address
addition is still performed twice, at `0x409511` and `0x409538`.

[Joint audit](../../selfhost/build/phase190/machine-audit-joint02/report.json) ·
[raw joint instructions](../../selfhost/build/phase190/machine-audit-joint02/candidate.0.asm) ·
[exact joint spans](../../selfhost/tests/phase190/local-fold-joint-regions.json).
The joint executable SHA-256 is
`407880c4f083cdd8e0ff8eb57dc3db7aa0f8f31d850f4cca2587377630fa7624`.
The existing profile campaign covers baseline/operands/C, **not joint**.

The retained C hot caller contains the actual inner loop at ELF
`[0xf880,0xf8b2)`, offsets `[+0x220,+0x252)` in `NF_FID_p93.loop`. It contains
**15 instructions for two semantic element updates**, zero frame/stack
references, zero calls, and one conditional backedge. Its effective static
count is therefore 7.5 instructions per element, excluding setup and tails;
this must not be compared as 15 versus one 39-instruction joint iteration.
The even 4096-element workload executes this two-element body.

```asm
mov    %ecx,%r9d
and    %r11d,%r9d
add    (%r15,%r9,4),%edi
mov    %edi,%r10d
xor    %ecx,%r10d
mov    %r10d,(%r15,%r9,4)
lea    1(%rcx),%r9d
mov    %r9d,%r10d
and    %r11d,%r10d
add    (%r15,%r10,4),%edi
xor    %edi,%r9d
mov    %r9d,(%r15,%r10,4)
add    $2,%rcx
cmp    %rcx,%rbx
jne    0xf880
```

This is scalar unrolling, not SIMD fold arithmetic or an algebraic elimination
of the recurrence. Seven distinct GPRs suffice in this loop (`rcx`, `r9`,
`r11`, `r15`, `rdi`, `r10`, `rbx`); simply exceeding nine allocator homes is
not the missing prerequisite. The accumulator remains in `%edi` across both
updates and backedges, with 32-bit arithmetic handling truncation. Scaled
indexed operands absorb multiply/address work, and memory-source `add`
absorbs the explicit array-load temporary. One induction comparison/backedge
serves two elements; the repeated count-zero checks and separate count decrement
are absent. Register coalescing and width-aware selection are still useful
before adding indexed-memory selection, recurrence-aware loop control, or
unrolling. The instruction difference is evidence of remaining generated work,
not a direct prediction of a matching speed ratio.

[C audit](../../selfhost/build/phase190/machine-audit-c02/report.json) ·
[raw C instructions](../../selfhost/build/phase190/machine-audit-c02/baseline.0.asm) ·
[exact C spans](../../selfhost/tests/phase190/local-fold-c-regions.json).
The retained C executable SHA-256 is
`ddf9f48cb789b857115946cc18a79796f344e747094b6ceff2e6f1229c8a0ffc`.

The existing analyzer's ASLR-corrected ELF PCs independently pin the hot region:
528 of 532 C samples land inside `[0xf880,0xf8b2)`, a period-weighted **99.297%**
of all C samples. All 522 baseline fold samples lie within the exact positive
spans audited above, weighted **99.749%** of all baseline samples. The
[PC aggregation receipt](../../selfhost/build/phase190/profile-pc-audit01/report.json)
pins its [offline derivation](../../selfhost/build/phase190/profile-pc-audit01/derive.py)
and original per-capture analyses. C's largest recorded PC is `0xf8a2` (67
samples; 12.457% weighted), and baseline's is `0x409faf` (65; 12.442%). These
timer-sampled PCs localize execution; they are not retired-instruction counts
or proofs that those individual instructions have that fraction of latency.

## Final selected experimental bundle

The `final-build01` fold loop has **27 instructions, zero explicit frame/stack
references, 16 moves, zero calls, and two branches** per positive iteration.
This improves on joint's 39 instructions/two frame references and baseline's
66/21. Its exact spans are `[0x40931f,0x40932c)` and
`[0x40935c,0x4093b1)`, offsets `[+0x15b,+0x168)` and `[+0x198,+0x1ed)` from
the function start `0x4091c4`. One condition/backedge remains; the next-index
spill and complementary second condition are gone. Two width self-moves remain
at `0x40938a` and `0x409399`, alongside register copies and duplicate address
addition. The whole function has 128 instructions and 493 bytes; its cold
fallback call stages 12 explicit `%rsp` references outside the positive loop.

[Final static receipt](../../selfhost/build/phase190/machine-audit-final02/report.json) ·
[raw final instructions](../../selfhost/build/phase190/machine-audit-final02/candidate.0.asm) ·
[exact final spans](../../selfhost/tests/phase190/local-fold-final-regions.json).
No final-bundle target was executed by this static inspection, and the prior
baseline/operands/C profile does not become a final-bundle profile.

A [portable metadata capsule](evidence/REPRODUCE.md) now retains these receipts,
earlier failures and audits, controls through `final-controls01`, emission/build
receipts through `final-emit01`/`final-build01`, and runtime reports through
`runtime06`. Its inventory and deterministic archive were independently reread
and byte-for-byte replayed from the listed original evidence. Selected-source
checking and later additions are outside this capsule's snapshot boundary.
