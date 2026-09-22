# Compiler representation experiments

This experiment tests whether generated accessors and generic child lists explain the self-emitted compiler's cost. It leaves the compiler sources, public runtime and KTerm/KDef layout unchanged. All candidate transformations are disposable, private compiler images. They are not public ABI optimizations.

## Mechanism and semantic boundary

`KTerm` stores a string tag, name, integer identifier, quantity, linked list of children, and removed names. `KDef` has nine positional fields. The self-emitted JavaScript implements scalar accessor workers using `project("KTerm", value).slice()[slot]` (and analogous constructors). The complete API contains 66 such scalar projections. A child lookup also calls `ks`, constructs a partial `terms_at` application, and traverses the generic linked list.

Three interventions isolate these costs: remove the array copy while retaining `project`; replace only `kid` with direct traversal of the same immutable child list; combine both. No constructor layout, tag representation, list representation, or source algorithm changes.

The copy is observable at the public ABI: an array containing property getters reads all six fields before selecting one. Removing the copy reads only the selected field. The focused test deliberately confirms this difference. Therefore these transformations require a data-only compiler request boundary, compiler-created immutable ADTs, unchanged private global bindings, and no externally supplied arrays, getters or proxies. They must not be promoted to the public generated library runtime. The child worker additionally relies on valid compiler-created lists and U32 indices.

The structural gate passes 16,200 comparisons across 300 reproducible immutable terms, six accessors, and child indices 0–11. Names include a non-BMP character and a lone UTF-16 surrogate. These are accessor-shape tests, not claims that randomly generated terms pass the kernel. Checked real source compilations supply the independent semantic gate: exact emitted JavaScript and execution output must match the original image.

## Initial uncached pilot

One exploratory sample per variant compiled tree and list-sort fixtures with Base caching disabled. The baseline took 14.993 s and 18.223 s respectively. No-copy took 15.178 s and 22.438 s; direct child access took 14.946 s and 18.395 s; combined took 14.660 s and 21.026 s. All outputs matched byte for byte and executed correctly. These single samples show no convincing improvement and are not a representative warm edit-loop comparison.

A separate instrumented tree compilation counted 3,616,655 KTerm and 2,760,860 KDef projection-copy operations. It invoked `kid` 200,185 times; 199,848 of these requested child zero or one. Of 785,784 KTerm constructor calls, 449,104 had no children, 215,504 had one, and 115,500 had two. Constructor counts are semantic calls, not measured heap allocations: the engine may eliminate temporary objects or arrays.

Most of this pilot's cost is Base work. The instrumented run spent about 5.36 s parsing Base, 3.23 s loading its graph, and 7.59 s checking; annotation was 0.19 s and program emission 0.20 s. The large raw projection counts therefore cannot justify a large representation rewrite by themselves. Root profiling also identifies generic application dispatch as materially larger than projection runtime. A private call-site accessor inline experiment is being investigated separately in the private-image workstream.

## Measurement corrections and retained failures

The first cache-enabled pass exposed a preparation asymmetry: the original H image already had a validated Base cache, but transformed images did not. Creating those caches before the clock also warmed the engine, reducing their first compile times. These initial samples are exploratory and excluded from the final comparison. Final measurements require preexisting validated caches for every image, while recording the read/validation preparation time separately.

A shared resource incident affected the interval 14:39–14:57 UTC. The root's full-source profiling process timed out, another agent observed exit 137, and this runner suffered a long scheduling delay followed by a generated-program child timeout. Resource pressure is a plausible cause, not a proven diagnosis. The incomplete tree-repeat report, its failure note and the earlier complete warm report are preserved. All timing samples overlapping that interval are excluded from the final comparison. Exact-output checks already completed remain useful correctness observations.

Warm counter runs counted 791,697 KTerm and 505,618 KDef projection copies for tree, and 1,501,643 and 1,035,972 for list-sort. Child indices zero/one account for 16,920 of 16,930 tree lookups and 65,191 of 65,241 list lookups. These deterministic operation counts are independent of elapsed-time validity. Warm cache transport also creates 39,962 KTerm placeholder arrays before filling them. The original raw histogram records their tag as `undefined` and includes them in arity zero; corrected summaries exclude those placeholders from known-term shape statistics. The uncached pilot has no such placeholders.

## Final clean comparison

After the resource incident ended, all 24 fresh-process samples completed with unchanged input/tool hashes. Every Base cache existed before preparation. Each workload has three alternating repetitions per variant; all emitted JavaScript bytes and execution results match the original H image.

| Workload | Original H | No projection copy | Direct child worker | Combined |
| --- | ---: | ---: | ---: | ---: |
| tree | 3.185 s | 3.195 s | 3.156 s | 3.134 s |
| list | 6.421 s | 5.992 s | 5.853 s | 5.800 s |

These measurements support a small, workload-dependent private-image improvement. They do not justify a wholesale KTerm layout rewrite, a public ABI change, or a full compiler-source speedup claim. The private calling-convention experiment can next test whether removing accessor dispatch itself improves the result further. This workstream makes no production change.

The [compact summary](evidence/representation-summary.json), [complete final report](evidence/representation-final.json.gz), [structural gate](evidence/representation-gate.json), and [variant manifest](evidence/representation-variants.json) retain measurements and artifact identities. The exploratory pilot/warm reports and interrupted repeat remain alongside them; the final table uses only the clean final report.

## Reproduction and provenance

The frozen H image is `selfhost/build/phase4/baseline/api/h.mjs`, SHA-256 `360bb62bec910e8148a8c24ee63c1a350a8fda06c206bdd5f04c153a006804de`. The baseline image in the transformation manifest is byte-identical. Timings use Node v24.18.0, a 4 MiB JavaScript stack and 4 GiB heap, CPU 3, fresh processes and file-backed capture. Instrumented runs are excluded from timing comparisons.

The tools are `selfhost/tools/performance/phase4/representation-{prepare,transform,test,worker,run}.mjs`. Prepare takes `H_API NEW_DIRECTORY`; the test takes `VARIANT_DIRECTORY NEW_REPORT`; the runner takes `CONFIG NEW_OUTPUT_DIRECTORY`. The JSON config selects frozen driver/runtime/Base, variants directory, workloads and exact execution outputs. Run the runner under `taskset -c 3` so all child processes inherit the same CPU affinity. `cache: "validated"` primes the normal checked Base cache before each measured compilation and records preparation separately; omission disables caching. Three alternating rounds are the default.

The original uncached tool sources were copied into the pilot output directory before adding warm-cache support. Reports retain input/tool hashes and reject drift. The original pilot and focused-gate reports are archived with the warm follow-up when complete.
