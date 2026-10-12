# Original-six runtime comparison and timing drift

The completed Phase70 comparison is **1.12124× upstream runtime** and a
**1.14880× speedup over Phase69** on the same six cases. Candidate time is
0.87047× the contemporaneous Phase69 time. All 54 intervals passed their checksums,
exit/clock checks and 100 ms minimum. These are the current same-campaign numbers;
the historical Phase69 1.0332× upstream result must not be substituted for its
freshly measured baseline.

| Case | Phase69 now, ms | Compiler02, ms | Upstream now, ms | Compiler02/upstream |
|---|---:|---:|---:|---:|
| numeric | 252 | 251 | 250 | 1.004× |
| array | 191 | 185 | 174 | 1.063× |
| closures | 164 | 158 | 225 | 0.702× |
| tree | 338 | 320 | 194 | 1.649× |
| map | 737 | 373 | 420 | 0.888× |
| lexer | 389 | 380 | 210 | 1.810× |

## What changed between measurements

The audit confirms identical repetitions and warmups for every case across the
Phase69 and Phase70 campaigns. Native flags remain `--threads 1 --gpu off` on
CPU3, with the same wrapper arguments. All 37 shared relevant input identities
match, including the reused Phase69/upstream executable, generated C and emission
receipts. This is a saved-binary comparison: neither baseline was recompiled.
The current role named `baseline69` is the historical Phase69 `candidate`, not
its older `baseline23` role.

The same upstream closure executable has median runtime **566 ms historically
versus 225 ms now**. Its CPU user time likewise changes from roughly 0.637 seconds
to 0.254 seconds including warmup. Upstream tree changes from 273 to 194 ms, and
lexer from 245 to 210 ms. Meanwhile the same Phase69 executables move by different
amounts: closures 169→164, tree 390→338, lexer 445→389, array 170→191 and map
697→737 ms. The fresh Phase69/upstream geomean is therefore **1.28809×**, despite
unchanged binaries.

The observations establish execution-condition drift, but do not identify its
physical cause. They do not justify calling it a compiler regression, assuming
one uniform clock-scaling factor, or claiming a specific CPU-frequency, cache,
allocator or scheduler mechanism. User CPU time moving with runtime also means
that simple extra wall-clock waiting is not a sufficient explanation. No hardware
counter or governor evidence was collected for the historical campaign.

## Within-campaign variation and the narrow follow-up

Current closure rounds are:

| Role | Round 0 | Round 1 | Round 2 |
|---|---:|---:|---:|
| Phase69 | 259 | 159 | 164 |
| Compiler02 | 259 | 158 | 157 |
| Upstream | 388 | 224 | 225 |

All three roles are slower in the first closure round; the final two are close.
Array also has material spread: candidate 249/172/185 ms and upstream 172/207/174
ms. Map's candidate samples are relatively stable at 366/376/373 ms, although one
upstream interval is high at 543 ms against 420/407 ms. Tree and lexer have smaller
outlying rounds. All intervals remain visible in the original report.

The justified first follow-up is **six predefined rotated rounds of array and
closures only**: 36 saved-binary intervals, the exact same work, no compiler or
Clang reruns. It should cost roughly 10–15 seconds of guarded target time. The
prepared command is in `compiler02-native06-noise-audit01/repeat-plan.json`.
Retain every interval; do not drop initial or unfavorable rounds. Report this as
a separate sensitivity check, preserving the original six-case result. Do not
construct a hybrid six-case geomean by replacing only its favorable families.
A further rerun needs new evidence, not a desire to recover the historical ratio.

## Evidence

Raw paths are relative to `selfhost/build/phase70`:

- Primary report `compiler02-native06-comparison/report.json`:
  `0e719e8e35c9979aaad94902027e656e6ab353ed54bb316b163a504ef6e4a291`.
- Read-only audit `compiler02-native06-noise-audit01/audit.json`:
  `38944cd27afa4964034492be6c21e3f305bf2b7fe5f218156ad1990e7a132fcf`.
- Prepared follow-up `compiler02-native06-noise-audit01/repeat-plan.json`:
  `cb0fd39f274c0012a7475f3f5461e9c815228ad716f84b69a1a23b3f403e8baf`.

The historical report is `selfhost/build/phase69/typed10-comparison/report.json`,
SHA256 `eb55f4c45eaf8a7ceca302f1e79ebdbeec407ae05485be2943417b5484b28ccd`.
This report only analyzes completed receipts; its preparation executed no targets.

## Completed targeted repeat

Root subsequently ran exactly the recommended array/closures saved-binary repeat
at `selfhost/build/phase70/compiler02-native-stability02/report.json`, SHA256
`eaa4c42fc89d4a743fbf50c4c84d40ba9d05d33b04cc1c49fe0413dd73da5714`.
All **36 intervals qualified**; no compiler or Clang rerun was required.

| Case | Phase69 median ms | Compiler02 median ms | Upstream median ms | Compiler02/upstream |
|---|---:|---:|---:|---:|
| array | 169.0 | 169.5 | 168.0 | 1.0089× |
| closures | 161.5 | 156.5 | 223.0 | 0.7018× |

Array is effectively at parity in this repeat, showing that its original 1.063×
point estimate was sensitive to the short run's spread. The current closure ratio
is reproduced closely: 0.7018× versus the original 0.7022×. This confirms the
current comparison; it does not explain why the unchanged upstream binary was
historically much slower. Candidate samples remained fully retained, including
array's initial 189 ms and closure's final 169 ms observations.

The primary six-family result remains **1.12124× upstream**, with **1.14880× speedup
over contemporaneous Phase69**. No repeat value is spliced into that geomean and
no interval is discarded. This bounded verification resolves the immediate
sampling concern without a broad rerun or a compiler rebuild.
