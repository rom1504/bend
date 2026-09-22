# The normal checked development loop

The documented commands now work against the final Phase 4 source. A genuine
normal 54-export API bootstrap took **20.735 seconds**. The actual 21-case
frontend smoke command took **16.483 seconds** with a cold compiler-side Base
cache and **9.328 seconds median** across three fresh processes with a warm
Base cache. These are complete child-process wall times, not a substitute
benchmark of selected compiler functions.

[Results and exact provenance](evidence/development-final/summary.json) retain
the real bootstrap report, generated API, four raw smoke reports and process
logs. The normal API is under `selfhost/build/phase4/development-final/`; the
published `dist/typed-api.mjs` was not replaced. Its SHA is
`a3a287c25470a5a55d7c49085fce9a4a72aee3dfa6d15d3d5674c7c36566b2a2`.
The assembled source SHA is exactly the combined source used by the full proof:
`34c6ef63931e522a96a4203f8bbd8e103d3a27636cce5dd42d9ec57a8587d122`.
The bootstrap report records pinned checking, ownership, closed-book validation,
54 actual exports and unchanged source/host provenance.

## Results and limits

| Actual command | Process wall | Reference observations | Bend observations |
| --- | ---: | ---: | ---: |
| `typed-driver --bootstrap` | 20.735 s | — | — |
| `phase2-rules`, cold Base cache | 16.483 s | 2.022 s | 13.608 s |
| `phase2-rules`, warm 1 | 9.318 s | 2.116 s | 6.663 s |
| `phase2-rules`, warm 2 | 9.336 s | 2.085 s | 6.572 s |
| `phase2-rules`, warm 3 | 9.328 s | 2.122 s | 6.635 s |

The last two columns sum the 21 per-case observation timers in the actual smoke
report. They exclude imports, Git/provenance checks, report I/O and other command
overhead. Bootstrap plus cold validation sums to **37.217 seconds** of child
process time; that sum excludes controller work between commands. The complete
controller interval, including all four smoke invocations and identity checks,
is 68.203 seconds. It excludes the controller's own Node startup.

All four invocations pass the same nine positive and 12 parse-negative witnesses.
Complete reference and candidate observations, including their respective exact
diagnostic text and phases, are identical across cold/warm runs. They also match
all observations retained by the prior Phase 3 cold-loop report. This does not
mean candidate diagnostics equal TypeScript diagnostics: each implementation's
own observations match its prior results. No acceptance or rejection-phase
oracle was weakened.

The historical workflow used a different source and an in-process measurement
harness. Its 36.350-second observation is not a controlled timing baseline for
these separate real CLI commands; no speedup over that figure is claimed.
These selected frontend checks are a quick development gate, not the full
conformance corpus, generated-code validation, or a self-hosting fixed point.

The new API's compiler-side Base-cache key was absent before the first smoke
invocation. Each resulting cache was verified against the API hash, canonical
Base path/hash, checked-book marker and serialized-book hash. Warm runs use new
Node processes but retain that disk cache. OS caches were not flushed. CPU0 was
reserved for these timings; other physical cores were active. The parent and
smoke commands use Node v24.18.0, a 4 MiB Node stack and 4 GiB heap limit. The
normal bootstrap's stage0 child uses its existing default flags; the parent flags
are not silently claimed to propagate into it.

## Narrow runner repair

`selfhost/tests/frontend/phase2-rules.mjs` previously dereferenced unverified
synchronous Git pipe output. It now captures Git stdout/stderr in temporary
files, checks spawn errors, signals and exit status, verifies the exact pin and
tracked-clean checkout before and after the run, and removes temporary capture
files. The existing source/API/runtime/host checks and all 21 case oracles remain.

Five process-level regression tests pass: wrong pin, nonzero Git status despite
printing the correct pin, a terminated Git process, dirty tracked files, and
missing Git. Each must stop before loading the compiler or running a fixture.
The successful four real smoke invocations exercise the clean-checkout path.

## Reproduction

From the repository root, with a new API/report path:

```sh
NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
export BEND_UPSTREAM="$PWD/selfhost/.bootstrap/upstream"
export BEND_BASE="$BEND_UPSTREAM/bend2/base.bend"
export BEND_TYPED_RUNTIME="$PWD/selfhost/src/runtime.mjs"
export BEND_TYPED_API="$PWD/selfhost/build/phase4/development-replay/api.mjs"
taskset -c 0 "$NODE" --stack-size=4096 --max-old-space-size=4096 \
  selfhost/tools/typed-driver.mjs --bootstrap
taskset -c 0 "$NODE" --stack-size=4096 --max-old-space-size=4096 \
  selfhost/tests/frontend/phase2-rules.mjs \
  selfhost/build/phase4/development-replay/rules-0.json
```

Repeat the second command with a new report filename for each warm invocation.
A new output API path alone does not guarantee a cold cache: the key includes
compiler bytes, canonical Base path and Base bytes. The measurement controller
asserts that the cache is absent before calling its first run cold.

The complete measured recipe is also reproducible with a fresh output directory:

```sh
timeout 420s taskset -c 0 "$NODE" --stack-size=4096 --max-old-space-size=4096 \
  selfhost/tools/performance/phase4/development-final.mjs \
  selfhost/build/phase4/combined-launch.json \
  selfhost/build/phase4/development-final-replay
"$NODE" --test selfhost/tests/frontend/phase2-git.test.mjs
```

If the same API cache already exists, the controller deliberately refuses to
mislabel a warm run as cold. The normal smoke command remains usable with it.
