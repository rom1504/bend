# Owned hot-list reversal on the RLE fixture

A runtime projection reversed the three encoded runs in place. Its per-invocation counter recorded one raw input node, two count-one reference-wrapper transfers, one completed reversal, and zero calls to the original fallback. On the project assembler layout it reduced median paired runtime by 2.83%, with four favorable rounds out of six. On the default assembler layout it reduced median paired runtime by 4.52%, with six favorable rounds. The experiment required at least five favorable rounds and a median ratio of at most 0.98 in each layout. The project layout missed the consistency requirement. This result closes the named ceiling experiment. A generic compiler rule remains unimplemented. [Predeclared design and criterion](plan.md) · [Measured result and input pins](result.json)

| Layout | Baseline median, µs | Candidate median, µs | Median paired candidate / baseline | Favorable rounds | Candidate / mature C |
| --- | ---: | ---: | ---: | ---: | ---: |
| Project | 1.0625 | 1.0325 | 0.97173 | 4/6 | 2.36349 |
| Default | 1.0550 | 1.0050 | 0.95477 | 6/6 | 2.30054 |

Fresh mature Bend C measured 0.43685 µs per invocation. All 30 calibrated samples are included. The largest unfavorable project-layout pair took 253 ms for the candidate and 214 ms for its same-round baseline. Both layouts were produced by assembling text from the qualified incumbent compiler. The candidate replaces the named reverse entry with the C routine, which can tail-call the original machine worker. The timed binaries contain no event instrumentation. [Timing driver](screen.py) · [Raw timing and guard receipts](receipts.tar.gz)

The real runtime passed 2,306 ownership and output checks, including shared aggregate heads, genuine pair-typed heads, held tails, static data, nonempty accumulators and the identity of a transferred count-one wrapper. Each catalog executable printed the same checksum as mature C and the immutable direct ELF. The catalog RLE fixture uses a fixed input; its two argument tuples therefore exercise the same expression. The independent ownership controls vary list length and sharing. The guarded job took 9.31 seconds. [Ownership controls](control.c) · [Wrapper transfer](rotate.c)

Replay from the repository root with a fresh output directory in the controlled CPU 3 lane.

```sh
python3 -B research/phase198/qualification/job.py reuse-reverse01 38 32 python3 -B research/phase198/reuse/reverse/screen.py --out selfhost/build/phase198/reuse-reverse01
python3 -B research/phase198/reuse/reverse/package.py --run reuse-reverse01
```
