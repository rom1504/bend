# Cold checked-build and targeted validation observation

`cold-edit-loop.mjs` measures one practical compiler development cycle: rebuild
the entire compiler with pinned upstream checking, then run the 21 focused
frontend witnesses against that new API and live upstream. It starts with no
compiler-side Base cache and validates the cache as ordinary requests create it.
The new API must equal the frozen checked candidate byte for byte.

This is one process with a new book for each reference request and the ordinary
Bend host for each candidate request. It does not measure fresh CLI startup for
every fixture, exact diagnostic equivalence, or a full self-reproduction proof.
The separate differential and self-host gates cover those questions. Source,
upstream, export-list metadata, host, fixtures and emitted API identities are
retained. The host is copied with only its project/cache directory relocated;
canonical Base is the same for both compilers. OS caches are not flushed.

The recorded CPU0 observation completed in **36.350 seconds inside the tool**:
checked B1 build
16.444 seconds, followed by 21 live paired cases in 16.348 seconds. Preparation,
imports and identity checks occupy the remainder. Node startup and source
assembly are outside that timer: the build consumes an already assembled frozen
source. All nine positive observations reached `check` with `checked:true`, and
all 12 negative observations rejected at their expected parse phase. The new API
was byte-identical. The pinned TypeScript modules remain loaded during the loop.
Other compiler work ran on separate cores. The next CPU0 validation began after
this observation ended; no same-core overlap occurred. This is not a median or
a controlled speedup over the older phase2 observation.

[Evidence](../../../../implementation/phase3/evidence/cold-edit-loop.json)
records all results and timing scopes.

Configuration paths are relative to the JSON file; for a file in `build/phase3`:

```json
{
  "upstream": "../../.bootstrap/upstream",
  "integrationReport": "native-integrated/report.json",
  "runtime": "final-fixedpoint/runtime.mjs",
  "driver": "../../tools/typed-driver.mjs",
  "cases": "../../tests/frontend/phase2-rules/cases.json"
}
```

Run from `selfhost`, choosing an available core and fresh output directory:

```sh
timeout 180s taskset -c 0 node --stack-size=4096 --max-old-space-size=4096 \
  tools/performance/phase3/cold-edit-loop.mjs CONFIG.json NEW_OUTPUT_DIRECTORY
```

The explicit in-process checked build is useful on supervisors where synchronous
Node children fail. It performs source loading, type checking, ownership,
unresolved-law/hole refusal and library emission. It writes its own distinct
workflow report; it does not invent an ordinary bootstrap sidecar.
