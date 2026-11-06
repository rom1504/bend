# Reproduce the final Phase169 candidate

Run from the repository root with the pinned assets/checkouts already available.
These commands select the combined source explicitly: publication, admission,
lazy eligibility, single verification, native diagnostic protocol, certified
ordinary composition and cold constructors. They do not install a compiler,
change a selector, or replay historical failed variants.

The completed hosted source is `cold-api-source01` (SHA`7cf2a64a…`); the native
closure is `quality-native-source01` (SHA`db744d67…`). Their manifests and
derivation files record the exact extraction inputs and commands. The final
native generation's performance/qualification status belongs to its own build
and qualification receipts, not to the earlier148.821s single-verifier image.

## Fresh paths and one resource lane

Choose a never-used prefix; every command below creates a new artifact root and,
for target jobs, a separate new guard root. Stop after a failed command and keep
its evidence. Do not rerun into that root or delete it to hide a failed attempt.
The helper merely applies the maintained guard to the exact argv that follows.

```bash
set -euo pipefail
P169_PREFIX=selfhost/build/phase169/reproduce01
P169_CASES=editdist,tree-bitonic,lexer,test-rle-roundtrip,test-map-set-ops,raytrace

p169_guard() {
  local p169_out=$1 p169_seconds=$2 p169_rss=$3 p169_disk=$4
  shift 4
  python3 -B selfhost/tools/build-retention/guard.py \
    --out "${p169_out}-guard" --run-root "$p169_out" \
    --seconds "$p169_seconds" --rss-mib "$p169_rss" \
    --disk-mib "$p169_disk" --available-mib 16384 --file-mib 128 --cpu 3 -- "$@"
}
```

The default5GiB disk reserve still applies in addition to the declared output
budget. All target commands run serially on CPU3. Keep sampling/preload/event
variables absent. Do not nest another resource guard. Output budgets below are
ceilings, not measured timings. Source preparation is metadata extraction only.

## Checked API and finite controls

```bash
python3 -B experiments/phase169/tools/prepare-cold-emission.py \
  --api --publication --admission --lazy --single-verify --native-protocol \
  --ordinary-composition --cold-constructors --out "${P169_PREFIX}-api-source"

p169_guard "${P169_PREFIX}-api" 90 3072 16 \
  selfhost/.assets/bin/bun selfhost/tools/build/hosted.mjs acquire \
    --source "${P169_PREFIX}-api-source/compiler.bend" \
    --exports "${P169_PREFIX}-api-source/exports.json" \
    --out "${P169_PREFIX}-api" \
    --upstream selfhost/.bootstrap/upstream-phase66 --engine selfhost/.assets/bin/bun

p169_guard "${P169_PREFIX}-controls" 20 2048 4 \
  selfhost/.assets/bin/bun experiments/phase169/tools/finite-controls.mjs \
    "${P169_PREFIX}-api/report.json" "${P169_PREFIX}-controls" \
    p169c_controls:8 p169o_controls:10 p169a_controls:10 p169np_controls:8 \
    p169e_controls:16 p169q_controls:14 p169sv_controls:16 p169s_controls:2 \
    p168tc_controls:4 p167e_controls:30 p167ob_controls:5 \
    p128bs_controls:12 p128br_call_controls:10 p128bl_controls:7
```

Require the checked acquisition and all152 finite observations to pass.
This reproduces `cold-api01` / `cold-controls01`; it is not a theorem or native
program qualification. The separate six error-priority controls already have
their own frozen receipt; they need not rerun every historical source variant.

## Six-family generated-program screen

This reproduces `cold-programs01` / `cold-six-timing01`: checked hosted emission,
native execution, and the same retained Phase152 reference products. Build only
the selected candidate products; do not rebuild the baseline.

```bash
p169_guard "${P169_PREFIX}-programs" 210 2048 64 \
  python3 -B experiments/phase169/tools/pilot-builds.py \
    --receipt "${P169_PREFIX}-api/report.json" --cases "$P169_CASES" \
    --out "${P169_PREFIX}-programs"

python3 -B experiments/phase169/tools/screen-builds.py --variant quality \
  --build "editdist:${P169_PREFIX}-programs/editdist/report.json" \
  --build "tree-bitonic:${P169_PREFIX}-programs/tree-bitonic/report.json" \
  --build "lexer:${P169_PREFIX}-programs/lexer/report.json" \
  --build "test-rle-roundtrip:${P169_PREFIX}-programs/test-rle-roundtrip/report.json" \
  --build "test-map-set-ops:${P169_PREFIX}-programs/test-map-set-ops/report.json" \
  --build "raytrace:${P169_PREFIX}-programs/raytrace/report.json" \
  --out "${P169_PREFIX}-screen"

p169_guard "${P169_PREFIX}-timing" 75 1024 16 \
  python3 -B selfhost/tools/bench/bench.py run \
    --manifest "${P169_PREFIX}-screen/programs.manifest.json" \
    --cases "$P169_CASES" --budget 60 --rounds 4 --scale 1 \
    --guarded --cpu 3 --out "${P169_PREFIX}-timing"
```

Every run checks the independent complete value, warmup count and repetition
count. Require48 correct observations, all six cases timing-eligible and a
complete aggregate. The measured frozen screen is0.981596× geometric mean,
tree1.011538× and worst raytrace1.046854×. Reproduction is a new observation, not
a requirement to reproduce those precise clocks. This is six preselected
families, not full45 or upstream parity. The reference products and all input
pins must still exist, or be restored from their authenticated archive.

For a timing-only replay of retained products, omit acquisition and freezing,
and pass the existing
`selfhost/build/phase169/cold-six-screen01/programs.manifest.json` to the same
guarded runner with the six explicit IDs and a fresh output/guard pair.

## Native compiler generations

Prepare only `main` from the same combined modules, then run the independent
source checker. Its expected successful body check ends with explicit
unsafe/foreign proof refusal; `sourceChecked:true` and `proofAccepted:false`
are distinct results.

```bash
python3 -B experiments/phase169/tools/prepare-quality-native.py \
  --publication --admission --lazy --single-verify --native-protocol \
  --ordinary-composition --cold-constructors --out "${P169_PREFIX}-native-source"

p169_guard "${P169_PREFIX}-source-check" 75 2048 4 \
  python3 -B experiments/phase169/tools/check-source.py \
    --source "${P169_PREFIX}-native-source/compiler.bend" \
    --out "${P169_PREFIX}-source-check"

p169_guard "${P169_PREFIX}-n1" 270 4096 120 \
  python3 -B selfhost/tools/build/native.py \
    --assets selfhost/manifests/assets-native.json --host native \
    --stage N2-P169-single --target qbe --mode cache \
    --image selfhost/build/phase169/single-native-n2/program \
    --image-receipt selfhost/build/phase169/single-native-n2/report.json \
    --source "${P169_PREFIX}-native-source/compiler.bend" \
    --out "${P169_PREFIX}-n1" --seconds 240 --output-stage N1-P169-quality

p169_guard "${P169_PREFIX}-n2" 270 4096 120 \
  python3 -B selfhost/tools/build/native.py \
    --assets selfhost/manifests/assets-native.json --host native \
    --stage N1-P169-quality --target qbe --mode cache \
    --image "${P169_PREFIX}-n1/program" --image-receipt "${P169_PREFIX}-n1/report.json" \
    --source "${P169_PREFIX}-native-source/compiler.bend" \
    --out "${P169_PREFIX}-n2" --seconds 240 --output-stage N2-P169-quality
```

`--stage` describes the executing compiler; `--output-stage` binds the new
compiler image. These are native N1/N2 generations, not hosted B1/B2. All source
requests use the explicit authenticated cached Base. Builders hash the complete
stream without retaining another100MB QBE copy. Compare the complete `irDigest`,
assembly and object hashes in the two successful receipts. If whole ELF hashes
differ, inspect their exact mapped bytes before calling reproduction a failure
or claiming full-file identity; see [the earlier ELF audit](../../experiments/phase169/elf-reproduction.md).

The new native entry accepts the six-string `qbe-source-v1` request and excludes
session/batch operations. Qualify its independent ordinary outputs and exact
refusals explicitly; `--suite all` selects the full maintained64-case finite
qualification, rather than a default or silently reduced subset:

```bash
p169_guard "${P169_PREFIX}-qualification" 630 2048 384 \
  python3 -B selfhost/tools/build/qualification.py \
    --assets selfhost/manifests/assets-native.json --host native \
    --stage N2-P169-quality --target qbe --mode cache \
    --image "${P169_PREFIX}-n2/program" --image-receipt "${P169_PREFIX}-n2/report.json" \
    --suite all --seconds 90 --build-seconds 60 --execute-seconds 20 \
    --out "${P169_PREFIX}-qualification"
```

This qualification measures behavior, not generated-program speed. To transfer
the six-family timing result to native N2, acquire those same catalog wrappers
with `bench/acquire.py`, an explicit `N2-P169-quality` image/receipt role, and a
fresh manifest; reuse the retained Phase152 products and independent catalog
oracles. The earlier candidate-only selection/merger is pinned to the old
single-verifier image and must not be relabeled or silently reused for this one.

## Full canonical compile clock

This preserves the3,085,157-byte input used by244.461→187.496s. It does not
substitute the smaller native closure. The expected QBE comes from the retained
complete candidate product; the added quality capabilities are predicted to be
disabled on this File-effect workload, so exact emission is the required gate.

```bash
p169_guard "${P169_PREFIX}-canonical" 330 4096 144 \
  python3 -B selfhost/tools/build/native.py \
    --assets selfhost/manifests/assets-native.json --host native \
    --stage N2-P169-quality --target qbe --mode cache \
    --image "${P169_PREFIX}-n2/program" --image-receipt "${P169_PREFIX}-n2/report.json" \
    --source selfhost/build/phase152/composite01/compiler.bend \
    --expected selfhost/build/phase169/canonical-candidate01/program.ssa \
    --out "${P169_PREFIX}-canonical" --seconds 300
```

Use `wallSeconds` from the completed native build receipt: it includes compiler,
pipelined QBE, assembly and linking. Do not add overlapping child clocks or
substitute a sampled compiler-only interval. The canonical product still has
the original canonical main/algorithms; it is a generated-code transfer, not
the next experimental compiler generation. Seal/retain completed and failed
receipts through the maintained retention workflow before collecting a final
capsule. No command here promotes the candidate or authorizes deleting evidence.

## Final actual-native broad evidence

The final64 qualification passed. The final full canonical clock is185.190s;
native N1→N2 self-compilation is147.764s. `program-runtime.json` supplies the final
44-point geometric0.968962× comparison with Phase152, plus family/source weighting.

`quality-six-native01` and `quality-remaining-native01` acquired disjoint6+39
program sets using `quality-screen.recipe.json`. The final frozen manifest is
`selfhost/build/phase169/quality-broad-screen01/programs.manifest.json`.
After restoring its authenticated artifacts if necessary, repeat execution using
the maintained bench runner with a fresh output, `--set full --budget300
--rounds4 --scale1`. Keep its failed aggregate if any timed case is unresolved.
The original run completed360 exact outputs; four very fast cases required the
[predeclared resolution repair](../../experiments/phase169/broad-resolution.md).
Only those four were rerun at `--scale40`, with both images and all other work
parameters identical, producing32 additional exact observations.

`tools/summarize-programs.py` in `experiments/phase169` authenticates the two
reports and derives the explicitly repaired summary. Its fixed input/output
paths document this captured experiment; use fresh names for a new campaign,
retaining its raw reports and revised method identity. The final receipt capsule
contains the exact guard commands, frozen manifests and raw result/count bytes.
Large compiler images and source artifacts stay in their verified local retention
archives; the small Git capsule is not a substitute for those artifacts.
