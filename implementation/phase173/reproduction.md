# Reproducing the completed Phase173 experiments

This capsule preserves **experimental evidence, not a qualified successor**.
No full self-build result, sub-100-second result, production promotion, or
N1/N2 qualification is established here. The installed reference remains
Phase170. Experiments continuing after this capsule was collected need their
own receipts and must not be silently attributed to these source versions.

The [capsule inventory](evidence/inventory.json) records its collection time,
file hashes and exclusions. Packaging copied existing evidence and inspected
source; it did not run any target. Original measured artifacts were not edited.

## What is retained

- [Exact frozen Bend modules](evidence/modules/), retaining original filenames
  and module order: baseline helpers, measured store05, flat7, borrowed-record
  revision02 and revision04, and SCC03.
- [Original run receipts](evidence/receipts/), including successful checks,
  finite controls, native acquisitions/pairs, guard/resource receipts, and
  relevant failures. These files are byte-for-byte copies, not rewritten
  versions with more favorable labels.
- [Source-manifest projections](evidence/sources/): all input pins, exact
  assembled-source hashes, export/binding files, replacement hashes, protected
  declaration status and helper-law placement. Large generated declaration and
  source-map inventories are omitted; the original manifest's own hash is
  retained explicitly.
- [Historical commands and reconstruction recipes](evidence/recipes.json),
  [source identities](evidence/source-pins.json),
  [results summary](evidence/results-summary.json),
  [referenced artifact pins](evidence/referenced-artifact-pins.json), and
  [copy provenance](evidence/copy-provenance.json).
- The actual 39,333-byte verifier workload, owned SCC workloads, and small
  expected outputs under [workloads](evidence/workloads/).

Generated compiler sources, generated JavaScript APIs, QBE, assembly, objects,
binaries and multi-megabyte complete-value JSON observations are **not copied**.
Their exact identities remain in the receipts; they can be reconstructed from
the frozen source, workload, qualified compiler and toolchain. This is not a
standalone toolchain distribution.

## Source identity is essential

The currently edited `selfhost/tests/phase173/store.bend` is newer than the
measured store05. Current `store-compact.bend` and `store-controls.bend` also
differ from measured store05 and flat7. Using those current files would create
a different experiment. [source-vs-working.json](evidence/source-vs-working.json)
records the exact differences in file identity at capsule collection.

| Variant | Frozen module directory | Checked API source SHA256 |
| --- | --- | --- |
| Independent baseline | `base-modules02` | `7a778c2fb40189ec62a72bed34d85fc7560a87138e4fa3e352ab91259784dd77` |
| Measured store05 | `store-modules05` | `9d609268974257429393a441096e77f09e4d9a2b8cfe7ba3d78d76a6fc35c9c5` |
| Measured flat7 | `store-flat7-modules01` | `4eee8b77da3b94efa19fb10b09c551be0fdd193537ddd8e094935d759e313c6c` |
| Borrow revision04 | `borrow-modules04` | `e0f958e3306ccac62d2207353720f23272b61c6027f5b42c4b1bba9af8bb439b` |
| SCC03 | `scc-modules03` | `1f1d9cb5f4087b2ab99c9949db0b0843c051750dfe14955c4150405d6c12c11a` |

The seven-field variant's measured filename is still **`store.bend`** inside
its frozen directory. Do not substitute the latest flat7/read-gates experiment.
Similarly, SCC03 is distinct from later `scc-v2.bend` or other working revisions.

## Reproduction prerequisites

Use a separate clean checkout or new run roots. Never overwrite the measured
`selfhost/build/phase173` directories or modify old receipts to make their hashes
pass. The historical absolute paths in receipts are provenance, not portable
configuration; newly acquired receipts must describe the actual new paths.

The source transport checks the maintained Phase170 parent, exactly 3,150,535
bytes with SHA256
`434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71`.
Keep `selfhost/src/compiler.json`, its modules, the prepared Base, upstream
checkout, Bun, qualified `qbe-n2` compiler, QBE executable, runtime object and
assembler/linker consistent with the retained input/toolchain pins. Missing
external assets must be restored or reacquired independently; a missing pin is
not permission to silently substitute a new baseline.

Use the existing single CPU3 execution lane, one outer retention guard per job,
the 5-GiB disk reserve, explicit time/disk/RSS limits, and fresh output folders.
The original guard receipts retain actual resource limits and observed peaks.
They do not record the original requested timeout, so the recipes explicitly
avoid inventing it. Choose an explicit bounded timeout above the retained
historical wall time and close the run normally.

## Rebuild the checked APIs from frozen modules

`evidence/recipes.json` contains exact ordered source-reconstruction argument
arrays for all six variants. Module/prelude paths there identify the historical
snapshot locations. Replace only that input path prefix with the matching
`implementation/phase173/evidence/modules/` directory and select a fresh output
root. Preserve filenames, module order, `--replace` declarations and exports.

For example, the measured store05 uses:

```sh
python3 -B selfhost/tests/phase171/prepare-api.py \
  --prelude implementation/phase173/evidence/modules/store-modules05/vertical-prelude.bend \
  --module implementation/phase173/evidence/modules/store-modules05/store.bend \
  --module implementation/phase173/evidence/modules/store-modules05/store-compact.bend \
  --module implementation/phase173/evidence/modules/store-modules05/store-controls.bend \
  --module implementation/phase173/evidence/modules/store-modules05/vertical.bend \
  --module implementation/phase173/evidence/modules/store-modules05/vertical-store.bend \
  --export p173v_inputs --export p173v_control_inputs \
  --export p173v_candidate --export p173v_roundtrip \
  --export p173st_observe --export p173st_refusal \
  --out selfhost/build/phase173/replay-store-source05
```

This command transports source and metadata; it does not check or execute Bend.
Verify the resulting source's **bytes and SHA256** against the frozen source
pin before acquisition. New manifest paths and manifest hashes will differ;
the actual assembled Bend source must match.

Acquire and source-check through the maintained hosted tool, for example:

```sh
python3 -B selfhost/tests/phase173/job.py --rss-mib 3072 \
  replay-store-api05 90 64 \
  selfhost/.assets/bin/bun selfhost/tools/build/hosted.mjs acquire \
  --source selfhost/build/phase173/replay-store-source05/compiler.bend \
  --exports selfhost/build/phase173/replay-store-source05/exports.json \
  --out selfhost/build/phase173/replay-store-api05 \
  --upstream selfhost/.bootstrap/upstream-phase66 \
  --engine selfhost/.assets/bin/bun
```

Repeat with the separately reconstructed baseline, flat7, borrowed-record or
SCC variant as needed. Acquisition timings are not generated-program runtime.
SCC finite controls must use the exact checked SCC03 source; later SCC versions
are distinct candidates even if their intended transformation is similar.

## Reproduce semantic and native comparisons

The full historical command arrays are in `recipes.json`, with corresponding
guard receipts. Keep dependent stages linked to **new** successful receipts:

1. Run `selfhost/tests/phase173/controls.mjs` against the matching source
   manifest and checked API receipt. Store controls compare complete values and
   ordered references; SCC controls include both final direct verifiers.
2. Run `vertical.mjs` with the independently checked baseline API, candidate API,
   and preserved `workloads/verifier-source03.bend`. It captures all 101 actual
   erased bodies and compares complete input and output values. It must report
   complete inputs and complete pass outputs equal, not merely equal digests.
3. Use `vertical-native.py --controls <new-controls-report> --role
   baseline|candidate|oracle --out <fresh-root>` to regenerate each native
   source. This is literal transport of complete observations, with bounded
   helper construction; it performs no compiler optimization on the host.
   The oracle program contains the independently observed expected values.
4. Build all three with the same qualified producer, runtime and toolchain:
   `selfhost/tools/build/native.py --assets selfhost/manifests/assets-native.json
   --image-key qbe-n2 --host native --target qbe --stage N2 --mode cache
   --retain-ir`, plus fresh source/output paths and an explicit time bound.
   Run through the retention guard. The `N2` invocation label is not a new
   self-hosting qualification.
5. Execute the independent constant oracle, then use `native-pair.py` with
   matching build receipts, `--rounds 4`, and its complete expected stdout.
   The harness alternates AB/BA order and times fresh whole processes, including
   setup, complete consumption, output and teardown.
6. To evaluate SCC03 on the store workload, emit the **same measured
   store-native-candidate-source02 input** through the checked SCC03 API using
   the retained `scc-store-emission01` recipe, build that emitted IR with the
   same runtime/toolchain, and compare against the ordinary build of that same
   store source. Do not compare this row's ratio to a different-source baseline.

Expected native source identities from the bounded literal transport:

| Source | Bytes | SHA256 |
| --- | ---: | --- |
| Baseline consumer | 843,034 | `911f6994b97539648b13f95be63ea7056b0d31658859e79d3b5199b7ec155887` |
| Store05 consumer | 892,697 | `8ca5a159c6ae2f484eb6a6cf8642ac42f99f561ae536c6a81bad53e1b6068a95` |
| Constant expected-output oracle | 1,147,865 | `592e1aa21333a32fa785f0711010555f5ab349285a6cb717a090b90a6cb2cdeb` |
| Flat7 consumer | 892,317 | `050814ccee569eed4e8b62d1407bfb7e1ebda70e46c3f3ee16657f0f80997e7f` |

The complete native output is 962,601 bytes with SHA256
`6f2f5400603f0f7209abd2da2317ef3bd8097fff19d4f36b2b39797d18001ac7`.
The recorded pair harness compares actual bytes; this pin is a reproducibility
identifier, not a substitute for the independent expected-value construction.

## Completed results represented in this capsule

| Comparison | Baseline median | Candidate median | Candidate/baseline | Interpretation |
| --- | ---: | ---: | ---: | --- |
| Store05 versus ordinary complete consumer | 0.078725s | 0.157692s | 2.003073 | Indexed representation regressed this complete native computation. |
| Flat7 versus contemporaneous ordinary consumer | 0.079870s | 0.157263s | 1.968975 | No meaningful recovery versus store05's candidate runtime. |
| SCC03 versus ordinary execution of the same store05 consumer | 0.159526s | 0.150364s | 0.942567 | 5.74% improvement within this already-slower representation; not a canonical-compiler speedup. |

The SCC owned-list source produced exact `200000\n` in both programs. Its
fresh-process timings are below the harness's 30ms resolution threshold; the
receipt says `resolved: false`, so no runtime ratio is reported as established.

Borrow revision04 has source checking and 38 finite controls in this capsule.
Its retained compiler-workload emission is a code-generation observation, not a
qualified native runtime speedup. The earlier verifier request emitted exactly
baseline QBE because no regions were admitted; its byte equality establishes
that negative observation, not successful optimization.

## Historical failures and method drift

Retained failures include source parser/type errors, a missing Base import, the
first SCC control runner's wrong expected text prefix, and the original
monolithic literal transport exceeding the unchanged 65,535-local verifier
limit. These are not counted as passing tests or benchmark samples.

The orchestration scripts evolved during the experiment. Original receipts keep
their exact method hashes; `evidence/harness-current/` preserves the packaging-
time versions separately. If a method hash differs, do not edit the old receipt
or claim that the current script was the historical executable. Reproduction
with the newer checked orchestration produces fresh receipts while preserving
the frozen Bend source, workload, runtime/toolchain comparison and full-output
obligations. Tool improvements do not retroactively change historical timings.

Only the original frozen module sets and exact generated source pins establish
which implementation a measurement concerns. Continue experiments under fresh
versioned names, retain negative results, and reserve full qualification for an
independently justified integrated candidate.
