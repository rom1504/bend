# Phase41 portable performance guide

Run from the repository root. The maintained Phase37 catalog covers 45 input
points across 23 source files. Phase41's portable baseline is available at
[baseline/manifest.json](baseline/manifest.json): it contains starting Phase40
checked06 modules and the unchanged TypeScript modules pinned to
`018751270e800bc222a93dad7f257083ee53a5f7`.

**Phase41 checked01 is installed.** Its postinstall audit passes 15/15 gates
with 227 unchanged canonical source bindings. Source grows by 35 physical
lines and four definitions; 42 of 45 generated modules remain byte-identical to
Phase40, with only the three tree points changed. The upstream pin is unchanged.
Release verification and all 42 ordinary/relocated CLI checks pass. The portable
[`current/manifest.json`](current/manifest.json) bundle is available; its
5-point fast set passes in 16.93 seconds. See the [Phase41 integration account](../../../../implementation/phase41/integration.md)
and [results](../../../../implementation/phase41/README.md).

Normal compiler iteration uses a fresh checked B1 attempt through the
[checked development workflow](../../../../docs/PHASE5_DEVELOPMENT.md).
Build/preparation, clean program timing, and diagnostics are separate steps.

## Current scope

The selected checked source changes three tree modules; the other 42 modules
are byte-identical to Phase40 checked06. This 45-point identity comparison is
not itself a 45-point timing result. The [interim report](../../../../implementation/phase41/README.md)
tracks admission and remaining gates, [tree results](../../../../implementation/phase41/results.md)
record the focused checked-emission screen, and the [design index](../../../../design/phase41/README.md)
links the experiment hypotheses. List next-argument scalarization was rejected
for lack of a useful timing signal; lexer String ownership is deferred. No
catalog-wide Phase41 result is claimed here.

## Reusable 20/60/300/600-second runs

Use Node 24+, Linux, Python 3.9+, `taskset`, an available CPU, and fresh output
directories. Choose an absolute Node path and CPU for the host. Once root creates
the current bundle, set its manifest path below:

```sh
PHASE41_NODE=/absolute/path/to/node
PHASE41_CPU=3
PHASE41_CANDIDATE=selfhost/tools/performance/phase41/current/manifest.json

run41() {
  python3 selfhost/tools/performance/programs/run.py \
    --catalog selfhost/tools/performance/phase37/catalog.json \
    --baseline selfhost/tools/performance/phase41/baseline/manifest.json \
    --candidate "$PHASE41_CANDIDATE" \
    --node "$PHASE41_NODE" --cpu "$PHASE41_CPU" \
    --rss-mib 2048 --available-mib 2048 "$@"
}

run41 --budget 20 --set fast \
  --out selfhost/build/phase41-portable/fast-NEW
run41 --budget 60 --set core \
  --out selfhost/build/phase41-portable/core-NEW
run41 --budget 300 --set broad \
  --out selfhost/build/phase41-portable/broad-NEW
run41 --budget 600 --set full \
  --out selfhost/build/phase41-portable/full-NEW
```

The budget is a wall ceiling, not a duration promise. Incomplete output stays
in its report and does not provide a ratio. The runner executes prepared modules;
it does not build or import the compiler. Keep each run serial and preserve its
fresh output directory.

## Focused final screen and diagnostics

Root's planned final timing selection is three changed tree points plus three
unchanged controls. Run these six together under the deeper 300-second protocol:

```sh
run41 --budget 300 \
  --cases tree-bitonic,variation-tree-bitonic-6-17,variation-tree-bitonic-9-123,local-pair,scalar-region-8192,coverage-numeric-recurrence-1024 \
  --out selfhost/build/phase41-portable/final-six-NEW
```

After a complete timing run, collect separate diagnostics for `tree-bitonic`.
This adds no profiling work to the clean timing samples:

```sh
python3 selfhost/tools/performance/programs/diagnose.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --from-run selfhost/build/phase41-portable/final-six-NEW \
  --cases tree-bitonic --budget 60 --mode all \
  --out selfhost/build/phase41-portable/tree-diagnostics-NEW \
  --node "$PHASE41_NODE" --cpu "$PHASE41_CPU" \
  --rss-mib 2048 --available-mib 2048
```

Diagnostics use a separate budget and are not timing evidence. Keep timing and
profile reports together when reviewing call/allocation changes. The full
maintained catalog and diagnostic options are documented in the
[program runner guide](../programs/README.md) and
[diagnostics guide](../programs/DIAGNOSTICS.md).
