# Native compiler investigation loops

Run from repository root. Targets execute serially under the Phase86 guard; keep
each output directory fresh. This lane concerns our Bend compiler **running as a
native executable**, distinct from a JS compiler emitting C. Production remains
installed Phase82; the native binaries here are checked upstream-built B1 pilots.

## Fast correctness discriminator

```sh
python3 -B selfhost/tools/performance/phase87/run-map-controls.py selfhost/build/phase87/map-NEW
```

The recorded campaign used `selfhost/build/phase87/map/`; reruns accept a fresh
output directory inside the repository and refuse existing directories, and takes about23 seconds elapsed. Seven checked
programs emit raw JS and C; three native runs deliberately fail unsupported
closure sharing, four print83, and the safe negative must fail checking. Inspect
the summary and stdout/stderr; a completed process alone is not output validation.
The [Map README](map/README.md) defines the exact expected matrix. Full byte pins
and the native failure remain in raw evidence. No full compiler build is needed.

## Native CPU samples without rebuilding

Use the existing `phase68/parity-survey/sample-preload-threads.c` and
`sample-analysis-v2.py`. Build the shared sampler with Clang, `-std=c11 -O2
-fPIC -shared -pthread -ldl -lrt` plus the include path recorded in the guard.
Set only on the target executable:

```text
LD_PRELOAD=/absolute/path/sample.so
BEND_SAMPLE_OUT=/absolute/fresh/path.samples
BEND_SAMPLE_PERIOD_US=4000
```

Use `phase86/compiler-final-o2 --threads 1 --gpu off -- INPUT BASE RUNTIME
EFFECTDIR OUTPUT_PREFIX COUNT` under `phase86/guard.py`, CPU3, normal2GiB RSS
limit. All arguments after `--` are absolute; COUNT is1 or5. The bound Base,
runtime chunks, effects and binary are in Phase86's retained receipt/capsule.
Lexer is compiled only; do not execute its large bang workload. Small takes
about3.2s including Base; the baseline five-Lexer profile takes44s.

Analyze with `--samples`, `--baseline`, `--debug`, `--output`. Supply the same
unstripped executable for baseline/debug when only symbols exist. That provides
leaf-symbol attribution, not DWARF/inline or dynamic call stacks. Require .text
identity, process CPU coverage, no sample-capacity drops, intact handler/thread
lifecycle and enough samples. Primary4000us runs avoid the initial1000us timer
overruns. Sampling includes Base/startup/teardown and timings are diagnostic.
Complete output C hashes must match independent B2.

## Isolated linear builder candidate

`implementation/phase87/linear-builders.patch` changes two copied modules only.
Copy original text/emit modules into `NEW_SHADOW/selfhost/src/back/native/`, copy
the patch as `NEW_SHADOW/candidate.patch`, then apply with `patch -p1 -d
NEW_SHADOW`. Keep original/candidate hashes. `acquire-builders.mjs NEW_OUT
NEW_SHADOW` assembles current modules plus those two overrides and the unchanged
Phase86 entry, checks with pinned upstream, and emits raw JS/C. Run under the
guard with pinned Node,1GiB heap,4MiB stack and120s limit. This acquisition costs
about66s. A full optimized Clang image is a separate guarded stage (360s budget,
6GiB RSS,16GiB available-memory floor, CPU2,3); do not parallelize image builds.

`acquire-controls.mjs NEW_OUT NEW_SHADOW` substitutes the21-assertion entry,
and `baseline` instead of the shadow path selects unchanged modules. The initial
candidate acquisition takes8s; small native build takes2s. Both raw JS and C
should print `True{}`. The authored `#|True` expectation was corrected after the
first run; raw entry/report retain that harmless prediction error. Scaling helper
functions exist in the entry but have not themselves been benchmarked.

Use `phase86/bind-native.py BUILD GUARD BINARY` to authenticate the successful
native build. Use `phase86/js-compat.mjs BUILD NEW_OUT` for the **separately named**
JS sibling carrying only the existing primitive String equality guard; retain
the raw upstream JS. `phase86/compare.py` then accepts the candidate build/binary,
JS derivative and authenticated runtime prefix; select sources, roles, calls,
rounds and deadlines explicitly. It records failures and complete C artifacts.
Compare every native/JS result to the independent B2 hashes in Phase86 summary;
TypeScript emits a different C program and is not a byte-equality oracle.

No public CLI, default native host, native B2 qualification, general closure
sharing feature or PR comment is produced by these investigation tools.

The original Map orchestration script is retained in raw evidence. Its final
version adds an upfront fresh-directory check; underlying checked fixtures,
acquisition, build and target commands are unchanged.
