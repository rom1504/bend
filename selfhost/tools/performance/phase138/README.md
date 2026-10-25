# Reproduce the Phase138 profile investigation

Run from the repository root, with the retained qualified artifacts available.
Use fresh output directories; commands below name the completed immutable run.
Preparation validates Phase137 source/image/object and the unchanged diagnostic
runtime provenance. Host code handles metadata/profiling only; no compiler logic
or implementation is moved out of Bend.

```sh
python3 -B selfhost/tools/performance/phase138/prepare-profile.py prepare --out selfhost/build/phase138/profile01
python3 -B selfhost/tools/performance/phase111/guard.py --out selfhost/build/phase138/link-guard01 --seconds 90 --rss-mib 2048 --available-mib 16384 --file-mib 256 --cpu 3 -- python3 -B selfhost/tools/profiler/build-runtime.py --plan selfhost/build/phase138/profile01/runtime/plan.json --out selfhost/build/phase138/profile01/build
python3 -B selfhost/tools/performance/phase138/prepare-profile.py seal --out selfhost/build/phase138/profile01
python3 -B selfhost/tools/performance/phase111/guard.py --out selfhost/build/phase138/profile-guard01 --seconds 660 --rss-mib 4096 --available-mib 16384 --file-mib 256 --cpu 3 -- python3 -B selfhost/tools/profiler/run.py --manifest selfhost/build/phase138/profile01/manifest.json --out selfhost/build/phase138/profile01/capture --names compiler-self-source --modes sample --rounds 1 --periods-us 32000
python3 -B selfhost/tools/performance/phase138/analyze-profile.py --profile selfhost/build/phase138/profile01 --out selfhost/build/phase138/analysis01
```

The32ms capture disables event counters and checks complete output against the
digest from the existing clean Phase137 build. It is not a clean benchmark.
The current compiler/QBE/ABI are unchanged. All profile-derived summaries use
the generic profiler's existing attribution and quality checks.

The [report](../../../../implementation/phase138/README.md) and evidence capsule
distinguish fresh samples, historical stage clocks and future targets. The
capsule deliberately omits the105.9MB stdout and17MB diagnostic ELF; their exact
identities and construction inputs remain recorded. Restore archived metadata at
its repository-relative paths for offline analysis; retained native artifacts
are needed for a fresh capture. Never overwrite an earlier evidence directory.
