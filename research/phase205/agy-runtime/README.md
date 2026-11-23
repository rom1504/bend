# Two AGY ports on Phase205

The runtime fast paths saved 0.825 s per native45 fixed batch (5.07%). The second, independent port made the primary raytrace and Mandelbrot programs 3.06× and 1.83× faster than linking the runtime port alone. These are experimental products.

## Same-object runtime experiment

All 45 x86 objects came from the checked Phase205 selected06 native compiler. Each original object hash and original executable hash was checked against final-broad06. A fresh build of AGY-002 using our runtime.c and scan.c reproduced AGY’s runtime object SHA-256, `464e88f399c53d23c615bcb136b1337ae4c7c110a5b437243a30ad6f71e952af`. The baseline runtime was `1c819e63…`. The patch is a research build input against the identified source. AGY provenance is commit `295d6d25c3dd40f31b90d34355a5dbe6467d2e0a`, research/agy/rt/build_rt.py. This builds the single-mutator x86 runtime.

Every invocation checked expected output, exit status, stderr and repetition metadata. There were 44 ABI checks, two live descriptor-mutation checks, ten runtime behavior cases, and 45 native45 outputs. The zero-work case was excluded from ratios. For each eligible program, all three executables (mature Bend C, parent x86 and the runtime port) ran on CPU 3 in each of the six role orders, using previously calibrated repetitions. Fixed-batch totals use the frozen catalog weights applied to same-session medians.

| Fixed native45 batch | Seconds | Relative to C |
|---|---:|---:|
| Mature Bend C | 10.481 | 1.000 |
| Phase205 x86 | 16.287 | 1.554 |
| Phase205 x86 with runtime port | 15.462 | 1.475 |

The port took 0.956× parent runtime geometrically. Unicode-64 took 15.5% less time, record aggregation-256 12.4% less, RLE 12.0% less, and BST-64 11.2% less. Raytrace was the largest observed slowdown at 2.4%. The changed runtime adds zero Bend source lines. The ABI observer initially ran under the historical role called “candidate”, which expects stale metadata. Its actual result was the correct live result. The final job used the live role and retained both independent observers.

## Fork optimization

The second experiment adds AGY’s checked binary-fork reduction to selected06, with lookup deferred until after a definition passes the existing eligibility predicate. Source provenance is research/agy/bf_linearize.bend at AGY commit `fb74dedcfe73de36dd54c2261a636bdd612263fa`. The assembled candidate grew from 46,122 to 46,485 lines (+363) and from 4,994 to 5,043 definitions (+49). Our checked hosted API acquisition completed in 17.4 s. All candidate emission used the pinned Phase205 Base and the ordinary x86 object emitter and verifier.

| Input | Phase205 x86 | Runtime port | Both ports |
|---|---:|---:|---:|
| Raytrace | 146.5 ms | 150 ms | 49 ms |
| Mandelbrot | 147.5 ms | 146 ms | 80 ms |
| Mandelbrot variation 4/7 | 144 ms | 144.5 ms | 144 ms |
| Local fold | 144 ms | 145 ms | 145 ms |

Medians are for identical work within each row. The two unaffected objects were byte-identical to their Phase205 native parents. An independently authored stride-seven reduction exercised depths 0, 1 and 8, with wrapping U32 indices and a nonlinear leaf. Its ELF contains the generated fast worker and prints exactly the three results calculated by an independent integer oracle. The lexer and edit-distance fixtures also contain the same kind of reduction in their *batch wrapper*. A speed change there is not evidence for a faster lexer or edit-distance algorithm.

The producer of the candidate user objects is a checked hosted compiler. This trial does not establish native self-reproduction, cold compiler time, or legality against alternate Base definitions. Before promotion, validate the Base/intrinsic assumptions and guarded fallback and reproduce the native compiler against the established baseline. The installed compiler and runtime were left alone.

## Reproduce

Run from the repository root. Use fresh output paths for repeats.

```sh
b=selfhost/build/phase205
g=selfhost/tools/build-retention/guard.py
python3 -B "$g" --out "$b/agy-rt-02-guard" --run-root "$b/agy-rt-02" --disk-mib 128 --cpu 3 --seconds 295 -- python3 -B research/phase205/agy-runtime/screen.py "$b/agy-rt-02"
python3 -B research/phase205/agy-runtime/summarize.py "$b/agy-rt-02/results.json"
python3 -B "$g" --out "$b/agy-fork-01-guard" --run-root "$b/agy-fork-01" --disk-mib 128 --rss-mib 3072 --cpu 3 --seconds 205 -- python3 -B research/phase205/agy-fork/trial.py "$b/agy-fork-01" "$b/agy-rt-02"
python3 -B "$g" --out "$b/agy-transfer-01-guard" --run-root "$b/agy-transfer-01" --disk-mib 128 --rss-mib 3072 --cpu 3 --seconds 130 -- python3 -B research/phase205/agy-fork/transfer.py "$b/agy-transfer-01" "$b/agy-fork-01" "$b/agy-rt-02"
```

The compressed JSON alongside this note retains per-run measurements, executable and object hashes, and independent control results.

The final bounded combined-suite run completed 16/45 comparisons, including 5 changed objects. Its 130-second budget expired. The other cases remain unqualified for the combined compiler. No combined whole-suite runtime ratio is available. See [partial transfer results](transfer-samples.json.gz).
