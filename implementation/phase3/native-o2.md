# Clang O2 on the frozen native compiler

`-O2` is a useful cached-build option in this experiment. It preserved exact
compiler output, had little extra observed build cost, and reduced compilation
time on both measured inputs. The small repeated gain is modest; this is not a
Bend compiler algorithm improvement or a claim of faster generated JavaScript.
No compiler source, production tool or default optimization setting changed.

The exact checked C from the [final native gate](native-final.md) was compiled
with the same Clang 16, frozen cache tool, cache directory and environment. Every
cache-identity field matched the O1 build except `optimization` and the `-O`
argument in the build plan, including identical preprocessed C. Both builds
therefore retain the same complete Bend checking/emission provenance.

| Observation | O1 | O2 |
| --- | ---: | ---: |
| Initial native build, process wall | 71.932 s | 72.733 s |
| C compilation phase | 68.463 s | 69.295 s |
| Cache reuse, process wall | 1.846 s | 1.796 s |
| Full compiler-source inner compilation | 287.315 s | 249.953 s |
| Full compiler-source process wall | 287.540 s | 250.169 s |
| List-sort inner compilation, median of 3 | 1.958 s | 1.894 s |
| List-sort process wall, median of 3 | 2.075 s | 2.008 s |

Full-source and build figures compare two **unpaired single observations** on
CPU 0, with other work on other CPUs. Their approximately 1.15× full-source ratio
is an observation, not an isolated performance guarantee. The list-sort samples
used six fresh compiler processes in order `O1,O2; O2,O1; O1,O2` on CPU 0. Their
median inner compilation ratio is **1.034×**. Raw inner times were O1
`1959,1948,1958` ms and O2 `1894,1901,1878` ms. Startup and wrapper work are
included separately in process wall time; execution of emitted JavaScript is
outside that compilation measurement.

The O2 executable emitted the same 1,131,553-byte compiler library as O1 and
Stage2, SHA-256
`360bb62bec910e8148a8c24ee63c1a350a8fda06c206bdd5f04c153a006804de`.
All six list-sort compilations emitted identical JavaScript; every emitted
program executed successfully and printed `6`. All recorded inputs remained
unchanged. The cached O2 executable matched the fresh O2 binary exactly.
Cache-hit time measures reuse/preprocessing, not the original C compilation.

These observations favor retaining an O2 native executable for repeated use on
this host. They do not justify extrapolating the full-source gain to ordinary
small edits, where the measured saving was only about 64 ms per compile. Larger
performance claims require repeated full-source samples and broader workloads.

[Evidence](evidence/native-o2.json) retains commands, deadlines, actual Clang/cache
reports, source/tool identities, stdout/stderr, unchanged-input checks and the
exact orchestration source. Raw artifacts are under
`selfhost/build/phase3/native-o2/`. The experiment reused the unchanged, archived
asynchronous supervision tools from the final native gate. The O2 build and
full-source execution each had a 600-second inner deadline; both succeeded.
No O3 experiment was run.

To rebuild using the same frozen input and cache from `selfhost`, use a fresh
output path and the Clang include/library environment recorded in the evidence:

```sh
taskset -c 0 node build/phase3/native-final/host/tools/performance/rapid/native-compiler-cache.mjs \
  build/phase3/native-final/checked/program.c build/phase3/native-o2/compiler-o2-new \
  build/phase3/native-final/cache --opt=O2 --timeout-ms=600000
```

The full-source manifest retains exactly the canonical source/Base identities
used by the final fixed-point proof. This native executable emits JavaScript;
its success does not establish a native executable self-hosting fixed point.
