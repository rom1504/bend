# Final codegen comparison recipe

This is a pending recipe, not a measurement or native qualification. The selected
final source is `1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9`.
The original `timing-plan.py` and all FAST timing manifests stay unchanged.

After actual N1/N2 acquisition and focused19 receipts exist, prepare the higher
value parent-to-N2 comparison:

```sh
python3 -B selfhost/tools/performance/phase131/native/timing-codegen-plan.py \
  --comparison parent-n2 \
  --admission selfhost/build/phase131/combined-literals-admission01.json \
  --acquisition selfhost/build/phase130/p131-final-acquire01/report.json \
  --n1-build selfhost/build/phase111/p131-final-native01-n1/report.json \
  --n1-focused selfhost/build/phase111/p131-final-native01-n1-focused/report.json \
  --self-emission selfhost/build/phase130/p131-final-self01/report.json \
  --n2-build selfhost/build/phase111/p131-final-native01-n2/report.json \
  --n2-focused selfhost/build/phase111/p131-final-native01-n2-focused/report.json \
  --out selfhost/build/phase131/final-parent-timing01.json \
  --tag p131-final-parent-timing01
```

The planner is metadata-only. Missing receipts are errors, not inferred successes.
It authenticates the admitted source, qualified Phase130 producer, compact Base,
raw native emissions, actual image builds and focused19 gates on both images.
Q1/Q2 equality is recorded as an observation and is not required: a changed code
generation policy may first take effect when N1 compiles the source.

The unchanged Phase130 runner command appears in the returned jobs file. Before
a controlled CPU3 run, its `--check-only` mode can inspect the manifest with zero
target jobs and a separate fresh output, for example:

```sh
python3 -B selfhost/tools/performance/phase130/timing-run.py \
  --manifest selfhost/build/phase131/final-parent-timing01.json \
  --out selfhost/build/phase112/p131-final-parent-timing01-check \
  --rounds 3 --modes cache --check-only
```

The 27 measured rows retain Phase130's three cases, three roles, rotated order,
independent full-output oracles, tools, branch alignment and clocks. `phase111`
and `phase112` are legacy left/right keys: here they mean qualified Phase130 N1
and experimental final Phase131 N2. Both use the same compact Base. Upstream
remains its pinned TypeScript/Bun C route. Request and machine-build child clocks
must stay separate; one output execution verifies correctness, not program speed.

An optional `--comparison n1-n2` with fresh `final-generations-timing01.json` and
`p131-final-generations-timing01` paths compares the exact same final source
compiled through two generations. Run it only if the first comparison or code
shape indicates a useful unresolved generation effect.

Both plans label final images experimental and unqualified. The separate
`qualify-final.py` binder still requires N2→Q3, exact Q2=Q3, N3 build, focused19
and ordinary45 before final qualification. No installed selection changes here.
A subsequently successful qualification does not retroactively alter these
immutable timing manifests; cite the independent qualification receipt.
