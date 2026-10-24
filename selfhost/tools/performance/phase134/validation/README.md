# Phase134 validation adapters

These scripts only authenticate evidence and write metadata. The root agent runs
the selected guarded jobs. They do not compile Bend, weaken independent oracles,
promote a compiler, or claim native qualification.

`plan.py freeze --out selfhost/build/phase134/referenceNN.json` binds Phase131's
**measured N2** (`2fae3602…`) as the immediate timing parent and separately keeps
the **qualified N3** (`c00778cf…`) fallback. It authenticates the selected source,
runtime, compact Base receipt, three request products and45 native wrapper
products. This explicitly replaces the Phase130/Phase128 assumptions in older
planners. Historical timing values are not reused to calculate new ratios.

From the repository root, after the independent source check, acquisition and
aligned image build exist:

```sh
python3 -B selfhost/tools/performance/phase134/validation/plan.py candidate \
  --reference selfhost/build/phase134/referenceNN.json \
  --source-manifest CANDIDATE/manifest.json --checked-api CHECK/report.json \
  --emission ACQUISITION/report.json --build IMAGE/report.json \
  --generation N1 --tag p134-candidateNN \
  --out selfhost/build/phase134/candidateNN.json
```

The sibling `candidateNN-jobs.json` contains grouped jobs. Run `requests` first:
Lexer, Closures256 and Map128 must reproduce the actual Phase131 QBE exactly for
this byte-preserving refactor. Then use `focused19`. Reserve `ordinary45` and
`wrappers` for the useful integration checkpoint. The unchanged focused/ordinary
supervisors retain their legacy prepared-Base transport; the exact-QBE requests
and timing use the selected compact carrier. They exercise distinct supported
entry paths. These correctness timings are not clean performance measurements.

For the next native generation pass `--producer-plan` with the previous candidate
plan. Its source/runtime must be identical and its actual image must have emitted
the new image. Reproduction, source correctness and qualification remain separate.

Once focused19 passes, repeat the candidate command with action `timing`, add
`--focused selfhost/build/phase111/p134-candidateNN-focused19/report.json`, and
choose a fresh output and tag. Its one guarded job reuses the original Phase130
wait4 timing supervisor with exactly27 observations: three cases, three rotated
rounds and three roles. `phase111` means Phase131 N2; `phase112` means the supplied
candidate generation; `upstream` is unchanged. Run this CPU3 job without competing
target workloads. Both native roles are fresh processes using compact Base; this
is not a resident or incremental-cache benchmark.

```sh
python3 -B selfhost/tools/performance/phase134/validation/metrics.py \
  --report selfhost/build/phase112/p134-TIMING/report.json \
  --out selfhost/build/phase134/timing-summaryNN.json
```

After all45 wrapper jobs succeed:

```sh
python3 -B selfhost/tools/performance/phase134/validation/plan.py finish-wrappers \
  --plan selfhost/build/phase134/candidateNN.json \
  --out selfhost/build/phase134/wrapper-equalityNN.json
```

This rechecks complete bytes, source/image/runtime/carrier and the retained measured
binary identities. It permits reuse of those identical Phase131 machine products
and their historical performance evidence. It does not produce a fresh whole-suite
runtime ratio. Ordinary45 outputs and repetition-wrapper outputs are different
oracles; never substitute one for the other.

Preserve the unchanged native request tool (Phase130 output directory), aligned
builder (Phase111), and timing runner (Phase112). New metadata lives in Phase134.
All directories/tags must be fresh. Source/API admission alone does not prove the
new streaming ownership/late-error contract; keep its finite controls and final
verifier audit separate. Fixed-point qualification remains Q1=Q2 for truly unchanged
code generation, or Q2=Q3 after an emitter change, with each image bound separately.

Metadata checks (no target launches):

```sh
python3 -B selfhost/tools/performance/phase134/validation/test_metadata.py \
  --reference selfhost/build/phase134/reference03.json
```

Historical initial adapter smoke evidence used the existing Phase131 N3 as a stand-in:
`selfhost/build/phase134/adapter-test01.json` and `adapter-timing-test01.json`.
The original timing runner accepted the latter with `--check-only`, recording
`targetJobs: 0` in `selfhost/build/phase112/p134-adapter-check-only01/report.json`.
These are adapter checks, not new compiler or performance results. Five explicit
reference-substitution controls reject the wrong parent, carrier, corpus, request
product and wrapper product before any target could run. A later actual-candidate
check exposed an overly broad path test: `/bend2/` also occurs in the workspace
root. The checker filter now matches only the three upstream basenames in their
`bend2` directory and the Bun binary. `reference03.json` supersedes the earlier
references; `n1-validation01.json` successfully binds actual Phase134 source02,
API02, acquisition01 and N1 under the corrected script.

## Native qualification binder

`qualify.py` is a data-only binder for the explicitly reviewed source02. It checks
source-module replay, exact unchanged verifier/proof bytes, the nine successful
result substitutions, the two native request call-name changes, fresh checked
request routing and all15 finite predicates. It does not accept arbitrary source
changes merely because a manifest says `complete`.

```sh
python3 -B selfhost/tools/performance/phase134/validation/qualify.py \
  --reference selfhost/build/phase134/reference03.json \
  --source-manifest selfhost/build/phase134/stream-source02/manifest.json \
  --checked-api selfhost/build/phase111/p134-stream-api02/report.json \
  --finite selfhost/build/phase128/p134-stream-finite03/report.json \
  --acquisition ACQUISITION/report.json --n1-build N1/report.json \
  --self-emission SELF/report.json --n2-build N2/report.json \
  --first-focused N1_FOCUSED/report.json --final-focused N2_FOCUSED/report.json \
  --final-full45 N2_ORDINARY45/report.json --policy q1-q2 \
  --out selfhost/build/phase134/native-qualificationNN.json
```

For an explicitly justified Q2=Q3 qualification, select `--policy q2-q3`, supply
`--reproduction` and `--n3-build`, and bind `--first-focused` to N2 and both final
gates to N3. A failed Q1=Q2 check does not silently switch policy. Optional
`--wrapper-equality` independently rechecks all45 native wrapper byte identities
against the retained measured products. `--source-only` audits the source/control
contract without requiring native receipts and always reports `nativeQualified:
false`. Final results retain actual source, image, output, runtime, tool and gate
pins for the phase archive. Neither mode installs or selects the compiler.

`qualify-batch.py` is a separate contract for `batch-source05` (source
`95c4ac4f…68c99`). Use the same native-chain arguments, with its checked API05
and finite05 receipts. It authenticates the earlier stream contract and proves
that the renderer/admission bodies remain unchanged; only writer dispatch and
the replacement writer helpers differ. Its five-module replay and15+10 predicates
are bound separately. The original `qualify.py` and first-stream receipts remain
unchanged. The source-only batch audit is recorded in
`selfhost/build/phase134/batch-source-contract01.json`.

Batch audit: entering fill has `count < 64` and `used < 65536`. Overflow with a
nonempty packet retains exactly one lookahead piece; an oversized piece enters
only an empty packet and immediately flushes. Reversed accumulation preserves
piece order and appends exactly the prior per-chunk newline. File errors retain
the failure path and discard remaining state. Limits count characters, not UTF-8
bytes; a single oversized original piece and lookahead are explicit exceptions.
This structural audit does not establish a measured allocation bound or a speedup:
capped length scans and packet concatenation add work.

The initial batch01 hosted controls failed with a stack overflow before any packet
row. That negative evidence remains. Version05 uses direct self-tail length and
fixture loops plus the existing tail-loop equality oracle; its original15 and new10
controls pass. Native reproduction and performance remain separate gates.
