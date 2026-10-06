# Generated-program performance preservation

This is a data-only comparison and timing plan. It does not compile, execute or
qualify a compiler. Use it after the root agent finishes a full checked acquisition
with the existing Phase53 wrapper. For example, from the repository root:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 selfhost/tools/performance/phase53/acquire.py --catalog selfhost/tools/performance/phase37/catalog.json --set full --attempt selfhost/build/phase56/checked-string01 --out selfhost/build/phase56/string01-full --backend direct --role candidate --node /home/ai/.nvm/versions/node/v24.18.0/bin/node --cpu 3 --heap-mib 1024 --rss-mib 2048 --available-mib 4096
```

Acquisition owns the usual serial target lock and has its own resource limits.
Launch acquisition and timing with CPU3 in the controller's allowed affinity;
their parsers validate that before placing child processes on CPU3.
Once its complete manifest exists, the root agent can run the comparator on CPU0:

```sh
PYTHONDONTWRITEBYTECODE=1 taskset -c 0 python3 selfhost/tools/performance/phase56/performance/compare.py --candidate selfhost/build/phase56/string01-full/manifest.json --attempt selfhost/build/phase56/checked-string01 --out selfhost/build/phase56/string01-performance
```

`compare.py` reuses the existing verified bundle reader and unchanged Phase52
complete-row observer. It requires all 45 points / 23 checked source emissions,
joins every candidate receipt to the specified checked attempt, checks the raw
output and reconstructs the observer output exactly. It compares whole module
bytes, including the runtime, rather than selected function bodies or normalized
text. The Phase55 host02 output must also match the published Phase53 current
bundle exactly. The report lists changed and unchanged IDs, source counts and
families; a changed module is conservatively treated as needing new timing even
if its changed function might not run at that point.

The tool writes a fresh `baseline/manifest.json` using exact host02 modules and
the published pinned TypeScript modules. Original compiler identities remain
attached to each role. It also writes `timing-commands.json`, containing ordinary
`programs/run.py` argument arrays for **only changed points**, in groups of at
most 15 with the 600-second preset. The root agent should execute those commands
serially. That preset retains five rotated rounds (and the runner's existing
ray policy), rather than spending 669 fresh samples on byte-identical outputs.

For a quick initial screen, run the same command with `--budget 60`, a small
explicit `--cases` subset, and a different fresh output directory. A 20-second
screen is suitable for gross regressions, not a final small-gain estimate. Budgets
are ceilings, not requested runtimes; incomplete reports remain incomplete and
must not be used to claim successful retention.

Unchanged points retain **dated** Phase53 runtime evidence by exact artifact and
point identity. They are not new measurements. Changed points use fresh paired
host02/candidate/TypeScript samples. Do not pool old and new samples or describe
a mixed historical/fresh geometric mean as a new controlled whole-corpus result.
This check establishes performance evidence continuity, not complete semantic
conformance; independent source, host-boundary and release gates remain separate.
