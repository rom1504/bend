# Native IR research loop

This opt-in experiment implements the [five-step design](../../../../design/phase106/native-ir-research-loop.md).
Read the [results and limits](../../../../implementation/phase106/README.md)
before using the numbers. It does not change `selfhost/bend` or the selected
compiler. The IR, verifier, constant folder, workload constructors and both text
emitters are written in Bend. Rust supplies a narrow Cranelift consumer; Python
and JavaScript are independent experiment/proof orchestration tools.

Run commands from the repository root, with fresh output paths. The existing
CPU3 resource guard serializes target work. Do not run these alongside another
performance campaign. Typical small differential controls take seconds; full
self attribution and Clang construction take minutes and are not routine gates.

## Build reusable tools once

```sh
python3 -B selfhost/tools/performance/phase106/build_producer.py all \
  --out selfhost/build/phase106/local-producer01

CARGO_HOME="$PWD/selfhost/build/phase106/cargo-home" \
CARGO_TARGET_DIR="$PWD/selfhost/build/phase106/cargo-target" \
CARGO_BUILD_JOBS=1 cargo build --locked --release --jobs 1 \
  --manifest-path selfhost/tools/performance/phase106/cranelift/Cargo.toml
```

Use the Phase86 guard around the Cargo command in constrained environments.
The original run used a600s/3GiB limit with8GiB available-memory floor. Cargo's
first dependency acquisition needs network access; subsequent builds can use
`--offline`. Dependency versions are locked. Track download and reusable-tool
construction separately from per-candidate cost. The Bend producer builder
authenticates the installed Phase103 native compiler, assets, startup adapter
and pinned Clang, then records separate emission and image-construction clocks.

## Fast semantic screen

```sh
python3 -B selfhost/tools/performance/phase106/campaign.py generate \
  --producer selfhost/build/phase106/local-producer01/producer \
  --out selfhost/build/phase106/local-artifacts01

python3 -B selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase106/local-controls-guard01 \
  --seconds 300 --rss-mib 2048 --available-mib 4096 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase106/controls.py \
  --artifacts selfhost/build/phase106/local-artifacts01/report.json \
  --producer selfhost/build/phase106/local-producer01/producer \
  --adapter selfhost/build/phase106/cargo-target/release/bend-native-ir-cranelift \
  --out selfhost/build/phase106/local-controls01
```

This compares raw/fold C and Cranelift products with independent arithmetic and
memory-model answers. It includes literal and dynamic arithmetic, overflow,
unsigned comparison, shifts, entry-ABI narrowing, loops, lists, trees, explicit
closures, final reference counts, malformed input and wrong-answer rejection.
All timing inside this batched diagnostic screen is diagnostic, not a benchmark.
See [IR contract](ir/README.md), [adapter contract](cranelift/README.md) and
[laws/replay](laws/README.md) for the exact semantic and proof boundaries.

## Repeated performance and bounded policy search

```sh
python3 -B selfhost/tools/performance/phase106/campaign.py measure \
  --artifacts selfhost/build/phase106/local-artifacts01/report.json \
  --adapter selfhost/build/phase106/cargo-target/release/bend-native-ir-cranelift \
  --rounds 3 --out selfhost/build/phase106/local-measure01

python3 -B selfhost/tools/performance/phase106/campaign.py analyze \
  --report selfhost/build/phase106/local-measure01/report.json \
  --out selfhost/build/phase106/local-analysis01.json
```

`measure` guards every compile/link/execute separately and records precise child
clocks, peak RSS, hashes and complete answers. Three shuffled rounds cover eight
workloads and five profiles; `--rounds` accepts2–5. All candidates use the checked
fold policy. Text/list select the backend; tree/closure are held out from that
selection. Tail/many-functions and shared/borrowed ownership are separate controls.
The1/10/100 execution-batch scenarios are projections from observed medians,
not three additional research campaigns. Reusable tools and initial differential
qualification are outside that narrower target-cost model and must be charged
separately in first-use or total research accounting.

The generated C path still uses Clang; Cranelift replaces its object compilation
step but currently uses the same Clang driver/system linker for linking. Neither
path implements a full new frontend, production ownership ABI, parallel tasks,
GPU lowering or guaranteed mutual tail calls. Passing this slice is permission
to investigate integration, not evidence that the full compiler can use it yet.

## Slow attribution, only when the hypothesis needs it

```sh
python3 -B selfhost/tools/performance/phase106/attribute.py profile \
  --out selfhost/build/phase106/local-profile01
python3 -B selfhost/tools/performance/phase106/attribute.py clang \
  --out selfhost/build/phase106/local-clang01
```

These require the authenticated candidate04/Phase105 artifacts in the recorded
development checkout. The first samples an unchanged native B2 full-source
request and verifies complete output; the second repeats the selected Clang
recipe. They preserve the selection and are deliberately absent from the fast loop.

After selection, `confirm.py --analysis ANALYSIS.json --out FRESH_DIR` freezes
the k=1 winner and compares it with C O2 in three shuffled rounds at two new
sizes per family. It records both repeated batches and separate one-shot checked
processes; it never reselects the winner. `plot.py` takes `--analysis`,
`--confirmation` and `--out` to reproduce the report diagrams. `archive.py`
freezes local receipts/products/methods into a new `implementation/phase106`
subdirectory and verifies every compressed file hash.
