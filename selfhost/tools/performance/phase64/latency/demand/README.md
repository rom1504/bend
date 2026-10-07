# Prepared Base demand diagnostic

This probe copies State09's qualified baseline preparation into a fresh project.
Its API, source, Base, runtimes and prepared cache retain their hashes. Two changes
are explicit in the plan: the reviewed proxy graph helper, and a derived driver
that labels each actual exported API call and cache decoding. API methods are
wrapped after importing the private module, with the preceding label restored in
`finally`; ordinary `inspect` receives no custom API and retains the owned path.

The helper still eagerly decodes every graph node. Proxies count accesses to
original Base nodes and properties; they do not implement selective loading.
These counts can show repeated scans or distinguish source checking from cache
admission. They are not latency results or predicted savings. Shared nodes may
appear in several phases; do not sum per-phase unique-node counts.

Preparation is data only and has already created `state09-demand01`:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase64/latency/demand/factory.py prepare selfhost/build/phase64/baseline-state09/preparation/report.json selfhost/build/phase64/state09-demand01
```

Root alone executes the generated command:

```sh
python3 -B selfhost/tools/performance/phase64/latency/demand/factory.py run selfhost/build/phase64/state09-demand01/plan.json selfhost/build/phase64/state09-demand01/execution
```

Numeric, Lexer and Map each get one fresh serial CPU3 process, with 1 GiB heap,
2 GiB process-tree RSS, 4 GiB available-memory floor and 90 seconds per worker.
Every result must match the complete qualified raw module. Before/after hashes
reject changes to original or copied inputs and prepared cache files. Full
node/property observations are in each `.demand.json`; worker receipts contain
compact per-phase summaries. Failures remain in the execution report. No target
was executed by the factory's author during preparation.
