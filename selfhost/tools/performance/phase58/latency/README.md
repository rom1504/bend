# Small compiler latency experiments

This method reuses the frozen Phase57 ordinary-request worker and runner. It adds
explicit candidate-image bindings and relocates the corrected CPU/allocation
profiler to Phase58. It does not create a checked bootstrap receipt for B2 or for
a JavaScript derivative. Only the root execution owner runs these commands.

Run from the repository root. The reviewed pilot method is
`selfhost/build/phase58/latency-method03`; `derivation.json` preserves the exact
parent hashes, replacements and generated hashes. Its default workload is just
lexer, two images, one fresh process per image and one subsequent request.

```sh
python3 selfhost/build/phase58/latency-method03/run.py \
  selfhost/build/phase58/fields-latency-pilot01 \
  --bindings selfhost/tools/performance/phase58/latency/fields-bindings.json \
  --seconds 60
```

The runner owns the single execution guard, CPU3 affinity, 1 GiB JavaScript heap,
2 GiB process-tree RSS ceiling and 4 GiB available-memory floor. Do not wrap it
in another execution guard. The wall limit is a ceiling, not a duration target;
preparation, hashing and process launch also consume it.

Preparation can instead run once, outside subsequent timing campaigns:

```sh
python3 selfhost/build/phase58/latency-method03/run.py \
  selfhost/build/phase58/fields-latency-preparation01 \
  --bindings selfhost/tools/performance/phase58/latency/fields-bindings.json \
  --prepare-only --seconds 120

python3 selfhost/build/phase58/latency-method03/run.py \
  selfhost/build/phase58/fields-latency-repeat01 \
  --bindings selfhost/tools/performance/phase58/latency/fields-bindings.json \
  --preparations selfhost/build/phase58/fields-latency-preparation01/report.json \
  --seconds 20
```

For a stronger screen, use `--rounds 3 --warm-requests 3 --seconds 180`.
For two input programs, add `--cases test-evening-program,lexer` and increase the
ceiling. Add `typescript` to `--roles` **during preparation too** when a pinned
upstream comparison is needed. Role order rotates between rounds; one round
does not balance order effects. Three later requests do not establish steady state.

Allocation and CPU evidence use separate fresh processes and never enter clean
timing statistics:

```sh
python3 selfhost/build/phase58/latency-method03/run.py \
  selfhost/build/phase58/fields-allocation01 \
  --bindings selfhost/tools/performance/phase58/latency/fields-bindings.json \
  --preparations selfhost/build/phase58/fields-latency-preparation01/report.json \
  --mode allocation --profile-ms 1000 --seconds 60
```

Substitute `--mode cpu` for 1 ms CPU sampling. Allocation sampling uses 128 KiB
intervals and includes objects collected by minor and major GC. Those weights
estimate cumulative allocation, not retained memory or peak RSS. Inspector starts
after imports, the first request and the configured later requests. It encloses
whole additional requests and output checks; one request may exceed the requested
profile window. Trace mode is diagnostic only and has no Phase57-v2 phase markers.

## Image binding

`fields-bindings.json` is the fixed-source saved-output experiment: genuine
Phase56 B2 versus the separately recorded literal-key syntax derivative. It
does not bind a newly checked source implementation.

For the separate fields-only versus fields + lookup **checked B1** pilot, use
`latency-method04/run.py` and `lookup-bindings.json`, with a fresh output such as
`selfhost/build/phase58/lookup-latency-pilot01`. This is a changed-source comparison.
Both actual attempts have `checked: true` and `strictExact: false`; method04
records the latter and permits this explicitly unqualified pilot. Its
`setup-v2.mjs` successor preserves all checked-attempt integrity and output-oracle
requirements. `checked-pilot-method-v2.json` records the narrow change; method03
and its stricter gate remain unchanged. This pilot cannot qualify the full backend
or establish a B2 speedup.

Every binding has `kind: "phase58-compiler-image-bindings"`, `version: 1`, a
`comparison` and a `roles` object. File identities are `{file, sha256}`.

| Role kind | Required fields | Meaning |
|---|---|---|
| `checked` | `attempt` | Genuine checked B1 attempt; method03 also requires strict-exact qualification, method04 records its actual status. |
| `direct` | `attempt`, `emission` | Genuine generator attempt plus complete split-emission report; subject source and generator are checked separately. |
| `syntax` | `parentRole`, `derivation` | Recorded diagnostic edit of a genuine direct role; pins parent, output, producer and scope. |

`fixed-source` requires identical source, driver, Base, legacy runtime and direct
runtime hashes across Bend images. A new generator may emit an old fixed subject.
`changed-source` permits a new compiler algorithm/source and explicitly gives up
that isolation. Neither mode requires different compilers to emit identical text.

Each role privately stages its actual API and driver, primes its own API-keyed
Base disk cache, compiles every selected input, and executes the full catalog
oracle. Measured requests then require byte equality with that role's prepared
checked output. The report separately records whether Bend roles emit equal text.
The built-in TypeScript role retains commit
`018751270e800bc222a93dad7f257083ee53a5f7` and the same catalog oracle.

The separate SCC-sharing experiment uses `latency-method06/run.py` with
`scc-bindings.json`. Its baseline is the new genuine reach01 B2, not Phase56 B2.
The candidate has the distinct role kind `scc-sharing`; its receipt must identify
`phase58-data-only-shared-scc-census`, exact inversion and loop-body identity,
the same genuine emission, and the exact unchanged runtime prefix. Both images
share compiler source, driver, Base and runtime identities. The resulting image
is labelled `diagnostic-scc-sharing`, not a checked compiler or a field-key edit.
Methods03–05 and their consumed predecessors remain unchanged.

Preparation loads the API in its own process. Measured processes explicitly time
ordinary `D.loadApi()`, the first ordinary `D.inspect(..., backend: 'direct')`, and
each later ordinary request; they do not use a persistent inspector. Reported
import + API load + first request excludes provenance checks, process startup and
preparation. Output validation/saving occurs between request windows and can affect
the next request's GC state. This is a bounded diagnostic, not isolated cold start.

## Reproducing the method

`make-method.py NEW_PHASE58_DIRECTORY` only derives files and parses Python. It
imports no compiler and executes no generated program. `setup.mjs` is the new
image adapter. The actual checked-candidate/B2 generation and qualification tools
belong to the separate Phase58 bootstrap plan; use its real receipts in a new
binding. Do not modify frozen or consumed tools, invent attempt metadata, write
closed Phase54–57 raw trees, or reuse an existing output directory.

`make-comparison.py NEW_PHASE58_DIRECTORY --attempt CHECKED_CANDIDATE
--emission ACTUAL_B2_REPORT` writes bindings and shell commands only. The baseline
defaults are the installed Phase56 string01 B1 and its separately qualified B2.
Omit `--emission` until the candidate B2 exists, then make a new recipe directory.
It creates separately labelled changed-source B1 and B2 comparisons, each with
the same pinned TypeScript reference. It does not pool five images into a single
summary or interpret an emitted B2 as another checked attempt.

Each final clean suite is two cases × three roles × three rotated rounds: 18
processes, each with a first request plus three later requests, or 72 requests.
That is a larger follow-up, not the 20–60 s pilot. Each suite's preparation is
reused for its clean run and optional two-image lexer CPU/allocation profiles.
`commands.txt` preserves the exact launch arguments; the script launches none.

For the selected shared candidate, `make-final-matrix.py COMPARISON_REPORT
NEW_FINAL_MATRIX_JSON` preserves those clean commands, includes TypeScript in
both B1/B2 lexer allocation and CPU campaigns, and adds two fresh own-source clean
emissions under the same method02. The materialized plan is
`selfhost/build/phase58/comparison-shared01/final-matrix.json`, with exact shell
commands in `final-matrix.txt`. Its ten commands remain serial and explicitly
identify which runner owns the sole resource guard. Generating this plan launches
no targets.

## Full own-source emission

`make-emission-method-v2.py NEW_PHASE58_DIRECTORY` derives the retained Phase57
two-stage emission diagnostic. The prepared instance is
`selfhost/build/phase58/emission-method02/emission.mjs`, invoked with
`B2_BINDINGS ROLE NEW_OUTPUT clean|cpu|allocation`. Only genuine `direct` roles
are accepted. It reproduces the role's own compiler source and requires complete
B2/B3 byte equality against that role's genuine emission report; sources and image
bytes need not be equal between baseline and candidate.

The caller must provide the sole external CPU3 / 420 s / 1 GiB Node heap / 2 GiB
process-tree RSS / 4 GiB available-memory guard and the existing
`--stack-size=4096 --max-old-space-size=1024` Node flags. This long workload is
separate from the small lexer pilot. Do not nest supervisors.

Clean mode runs each stage once without inspector. CPU mode samples only emitted
reachability and final unsplit library emission, each in its own 25 ms session.
Allocation mode samples those same stages at 1 MiB intervals, including objects
collected by either GC generation. It is a bounded attempt, not a promise to fit:
preserve an RSS refusal and its partial evidence. Coarser sampling changes the
allocation diagnostic's resolution and cannot be pooled with the lexer 128 KiB
samples as exact counts.

Each stage retains its compiler-call clock separately from profiler setup,
serialization and total worker time. Emitted reachability itself renders
definitions; its name does not isolate graph traversal. A prior candidate clean
reproduction may avoid a redundant run, but compare scope and progress-IO clocks
before reporting ratios. One fresh observation of each own-source request is a
changed-source result, not an isolated lookup effect or stationary throughput.
The unexecuted method01 and original factory remain preserved: review found that
three identity checks received string file URLs instead of URL objects. The v2
factory corrects only that preflight path handling and records the exact edit.

## Saved-data analysis

`summarize.py NEW_JSON --latency REPORT [--latency REPORT ...]` independently
recomputes per-case role medians, observed ranges, baseline/candidate and
TypeScript ratios from completed worker receipts. It retains each later-request
sequence and keeps every campaign separate. CPU/allocation campaigns produce
diagnostic summaries instead of clean latency ratios; sampled allocation totals
are checked against raw samples and divided by actual profiled request counts.

Add `--emission baseline=REPORT --emission candidate=REPORT` for completed
own-source reproduction reports. Their source/image identities, exact B2/B3
agreement, phase times and optional one-call profiles remain separate rows.
This reader does not infer external supervisor success from an emission worker
receipt. It rehashes consumed identities and writes only a fresh Phase58 output;
use CPU0 after timing when reading large profiles. No target is executed.
