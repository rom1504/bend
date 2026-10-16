# Native chunk text experiments

This is an explicitly experimental **generated-C intervention** on authenticated
Phase98 native-B2 products. The compiler is still written in Bend; this directory
does not change or install a compiler image. Its purpose is to establish whether
a general new String ABI is worth implementing in the Bend emitter/runtime.

[Ambitious agenda](../../../../design/phase101/ambitious-native-agenda.md) ·
[Report](../../../../implementation/phase101/README.md) ·
[Independent controls](controls/README.md).

`chunk-runtime.c` represents an owned String cursor using a new tag and a
reference-counted chunk. Each cell preserves the complete U32 Char. Generated
consuming matches, borrowed views, destructor traversal, array replication and
readback are redirected consistently; static legacy strings remain supported.
`chunk-append.c` packs short prefixes and splices exclusive chunks. Optional
`chunk-compare.c` compares borrowed packed spans without changing owned results.
No application-name-specific runtime path is introduced. The prototype is
host-only; it refuses CUDA/Metal compilation and all runs select GPU off.

## Short loops

Reuse the existing compiler products and frozen independent expected outputs:

```sh
python3 -B selfhost/tools/performance/phase101/run.py \
  --apps image-render \
  --fixtures selfhost/build/phase100/image-production01/report.json \
  --cases survey-production --rounds 4 --threads 1,4 \
  --append --compare --out selfhost/build/phase101/FRESH
```

The runner rebuilds only the changed application C (typically seconds), then
alternates baseline/candidate/upstream programs serially. Complete stdout,
stderr and exit status must agree. It records child turnaround and peak RSS;
oracle work, native compilation and Clang builds are outside program clocks.
`--reuse COMPLETED_RUN/report.json` skips rebuilding candidates only when the
source/variant/method bindings agree. Inputs and expected outputs are pinned.

Use `--mode input`, `--mode cons`, or default `all` to isolate representation
producers; `--append` and `--compare` add the general operations separately.
`--chunk-class` controls capacity (default 64 words, 61 Char cells); different
capacities require their own semantic boundary checks. `prepare.py` writes a
standalone candidate plus its transformation counts without executing targets.

```sh
python3 -B selfhost/tools/performance/phase101/controls/prepare.py \
  --out selfhost/build/phase101/CONTROLS_FRESH
python3 -B selfhost/tools/performance/phase101/check.py \
  --manifest selfhost/build/phase101/CONTROLS_FRESH/controls.json \
  --append --compare --out selfhost/build/phase101/CHECK_FRESH
```

The first check admits each source with pinned upstream, emits with installed
native B2 and builds all three variants. Later checks can pass `--reuse` with
the same completed control manifest to reuse authenticated baseline/upstream
products and build only candidate programs. All ten cases run at 1/2/4 workers.
These finite controls are not a universal proof of the runtime or ownership ABI.

## Physical profiles

`profile.py` samples unchanged saved ELF images with the existing all-thread
preload sampler. It checks full output, zero sample loss/overruns and >=95%
thread CPU coverage, then attributes physical instructions to ELF symbols.
No call-stack, allocation census or source-line attribution is implied.

```sh
python3 -B selfhost/tools/performance/phase101/profile.py \
  --app source-index \
  --acquired selfhost/build/phase100/source-acquire01/report.json \
  --fixtures selfhost/build/phase100/source-survey01/report.json \
  --case real-compiler --roles b2 --periods 8000,13000 --rounds 12 \
  --minimum-samples 300 --out selfhost/build/phase101/PROFILE_FRESH
```

The 1–2 ms attempts overran on this host; retain them as rejected captures.
8/13 ms captures passed. These profile clocks are diagnostic, never clean speed
measurements. Runtime targets remain root-owned, serial and bounded by the
existing memory/disk/time guard. No full compiler rebuild is needed for these
iterations. Read the report before deciding whether to promote or extend a
variant; faster rendering does not establish general compiler parity.
