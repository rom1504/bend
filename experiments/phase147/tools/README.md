# Phase147 complete verifier experiment

These campaign tools import maintained source/build helpers. They do not import
historical implementation scripts or implement compiler judgments in Python/JS.
The additive candidate stays outside `selfhost/src/compiler.json` until an
explicit integration decision. Original verifier declarations remain exact.

The prepared baseline02/candidate03/candidate04 sequence below belongs to the
frozen pre-integration source boundary. After integration, the candidate module
already exists in the maintained recipe; do not add it a second time or rerun
`prepare.py` against a silently changed baseline. Reuse the immutable extracted
images for those comparisons, and use the explicit integration plans below for
the new complete compiler source.

The fast loop is:

1. `prepare.py baseline` extracts the checked current pipeline and original
   verifier API once. Run its `jobs.json` command under the supplied outer guard.
2. `capture.mjs` calls that immutable Bend API to produce current raw/direct IR
   for Lexer, Map and a dependency-closed actual compiler-verifier workload.
   It independently runs the original complete verifiers before selecting six
   whole raw and six whole direct functions per family. Two branch-heavy bodies
   plus a declaration-order spread preserve varied shapes. Every original global
   metadata header and each direct call's ordered predecessor context remains.
   This compiler workload is explicitly a slice, not a full self-hosting request.
3. `prepare.py candidate --candidate MODULE --observer OBSERVER` extracts only
   the candidate, required original dependencies and test observers. Its checked
   API is small; rebuilding the full compiler is unnecessary for a candidate edit.
4. `controls.mjs` compares independent fixed expected diagnostics, complete
   parameter seeds, schema rows/error/count and live rows/terminal/error.
   [`verifier-cases.json`](../../../selfhost/tests/phase147/verifier-cases.json)
   is separate data. `screen.mjs` compares the captured actual function errors.
   Test observers compare semantic rows, never Patricia layout/bucket order.
5. `native-slice.py` prepares a bounded whole-region source only after completed
   candidate acquisition and controls. The original and candidate modes live in
   **one binary**. Mode and repetitions come from runtime arguments, preventing
   a fixed source-level loop count. Each repetition constructs global metadata,
   checks the selected complete functions, and releases temporary state before
   publishing the scalar count. Direct ready signatures advance in original order.
6. `time-native.py` checks zero-repeat startup and complete outputs, calibrates
   both modes above 100 ms, then runs four alternating pairs. Wall/user/system
   measurements include process startup and final cleanup. Startup observations
   are reported without subtraction. Short signals are explicitly unqualified.

No generated invalid IR is executed. Hosted correctness is distinct from native
ownership/reclamation cost. A selected-function result is not a whole compiler
speed ratio, a mathematical proof, or evidence of upstream parity.

The current prepared sequence is:

| Step | Root-owned job plan |
| --- | --- |
| Original API | `selfhost/build/phase147/verifier-baseline02/jobs.json` |
| Candidate API | `selfhost/build/phase147/verifier-candidate03/jobs.json` |
| Independent controls | `selfhost/build/phase147/verifier-controls-plan01.json` |
| Current raw/direct capture | `selfhost/build/phase147/verifier-capture-plan01.json` |
| Actual function comparison | `selfhost/build/phase147/verifier-real-plan02.json` |
| First native build | `selfhost/build/phase147/verifier-native-lexer01/jobs.json` |
| Transfer builds | `selfhost/build/phase147/verifier-native-map01/jobs.json`, `verifier-native-compiler01/jobs.json` |
| Native measurements | `selfhost/build/phase147/verifier-native-timing-jobs01.json` |

Run only the next justified step in the single root CPU3 lane. Every plan uses
one existing process/disk guard and fresh artifact roots. Preparation is offline;
the guard wraps actual acquisition, capture, controls, native build and timing.
The files above are local run artifacts; regenerate fresh names for another edit.

For a native slice built at `RUN/native/program`, the exact transport is:

```sh
RUN/native/program --threads 1 --gpu off -- verifier-slice old 16
RUN/native/program --threads 1 --gpu off -- verifier-slice new 16
```

The QBE runtime omits `argv[0]` from `IO.args`; `verifier-slice` is an explicit
sentinel consumed by this test entry. Initial preparation metadata omitted that
sentinel. The timing runner records the correction; generated source and images
do not need to change. Both valid commands must print `12 * REPEATS` and a newline,
with empty stderr and exit0. One native build suffices for both modes.

Preserved failures matter. Baseline01 extraction mishandled character literals
containing `#` or `"`, swallowing a following dependency. The extractor now masks
whole character/string literals before comment/name collection; baseline02 passed.
Candidate01 exposed Bend's computed-match restriction; candidate03 contains the
explicit helper/affinity corrections and passed independent source checking.
Neither failed receipt nor an already consumed source is rewritten for a retry.
Real-screen01 passed a file-pin object where the reader expected its file path;
the failed method was preserved before correcting that orchestration call.
Real-screen02 passed all 36 captured complete functions.

Candidate04 is the scalar-query refinement of candidate03. Its preparation is
`verifier-candidate04/jobs.json`, followed by `gate-jobs.json` in that directory.
Those gates reuse the immutable baseline API and original captured inputs: 60
initial controls, 16 supplemental controls, and 36 actual functions. Native
preparations use `verifier-native-{lexer,map,compiler}02`, followed by
`verifier-native-timing-jobs02.json`. Each binary still contains its own unchanged
original baseline; compare within-binary ratios before comparing revisions.

For mechanism evidence, `verifier-profile-lexer01/jobs.json` reuses the existing
candidate03 Lexer binary and maintained sampler. It executes old/new modes for
768 iterations each with exact `9216\n` output, sampling at 16 ms. The manifest
pins all binaries, inputs and independent outputs. No compiler-image owner or
unwind table is applied to a different executable. A single period and one
observation per mode are descriptive; clean paired timings remain separate.

For whole-compiler integration, `integration-plan.py --source ASSEMBLED_SOURCE
--out FRESH_PLAN` references one explicit source and writes root-owned jobs.
The maintained checked acquisition validates the entire book and unresolved
holes/laws while exporting only `p111_empty`; it avoids emitting a full JS
compiler API. Native acquisition uses the installed qualified N2 and retains
the candidate's complete QBE once. `request-pairs.py` compares complete outputs
and three alternating native request pairs on the frozen source cases. Its
baseline is the installed N2 with its actual original source identity, not the
newly linked cold-baseline executable.

The cold gate compiles the frozen 3,010,912-byte source SHA256 `00940ed5…` and
requires the exact 117,232,528-byte `dceae94a…` QBE, using the same emission,
QBE, assembly and link pipeline as `cold-baseline01`. After fast and cold gates
actually pass, `integration-sequel.py --plan PLAN/manifest.json --out FRESH`
prepares N1→N2 construction and N2-emitted Q3 byte identity against the retained
candidate QBE, followed by maintained qualification. It reuses N1 and does not
copy the full source or invent completed gates. Root controls all execution.

Integration-plan01/02 incorrectly precreated a guard artifact root;
integration-plan03 then exposed a missing output directory in the direct
stage0-library invocation. The corrected plan04 delegates fresh-directory
creation to maintained `hosted.mjs acquire`. The original three generator
versions are preserved under their exact consumed SHA256 identities.

`corpus-identity.py freeze --out FRESH.json` authenticates the retained Phase146
positive QBE and machine-object references against the qualified suite receipts,
current catalog sources/oracles, and pinned machine toolchain/runtime. The
historical 77 products comprise 16 focused at N1, the same 16 at N2, and 45 broad
at N2: **61 unique positive inputs**, with 26.5 MB of retained QBE. Preparation
does not rerun the original compiler or copy its generated products.

After the new N2 finishes maintained focused19 and broad45 qualification,
`corpus-identity.py compare --references REFERENCES --image-report N2/report.json
--qualification FOCUSED/report.json --qualification BROAD/report.json --out FRESH`
compares all 61 complete QBE files and objects literally. The three negative
cases remain current independent refusal gates; the historical foreign-refusal
phase label is not reused. Exact generated bytes are distinct from a new runtime
timing measurement. `corpus-identity-command01.json` records the current local
comparison command, which launches no compiler or generated program.
