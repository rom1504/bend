# Dependency planner

A small command-line application that reads a dependency graph, selects requested targets, and prints their complete prerequisite-first build order. Shared prerequisites appear once. Missing dependencies and cycles produce explicit paths. The application reads its graph and roots at runtime; they are not compiled into the program.

`main.bend` is one Base-only source file for the retained Phase98 native backend. It uses `IO.args`, `File.open`, `File.size`, `File.read`, `File.close`, and `IO.print`. It does not execute build commands or inspect timestamps. Its output can drive a build/rebuild tool after that tool chooses the targets that need rebuilding.

Once the source has been compiled into a native program, invoke it as:

```sh
./dependency-plan --threads 1 --gpu off -- --graph selfhost/apps/dependency-plan/fixtures/shared.graph app tests app
```

The explicit `--graph` marker accommodates both native and upstream argument conventions. Tokens preceding that marker are ignored; all tokens after the file path are requested roots. At least one root is required. The runtime's `--` keeps application arguments separate from runtime options.

The example prints exactly:

```text
plan-v1
roots app tests app
order core lib assets ui app harness tests
reachable 7
edges 8
declared 8
```

The root record preserves the request, including repetitions. The order contains each reachable target once, with every prerequisite before its consumer. Dependency order within each row and root order determine DFS postorder; declaration order does not otherwise affect it. `edges` counts declared dependency occurrences on reachable targets, including repeated edges. `declared` counts all graph rows, including unreachable ones.

## Input

Each nonempty row is a target followed by zero or more prerequisites:

```text
app library assets
library core
core
assets
```

Spaces, tabs and carriage returns separate tokens. A `#` starts a comment through the end of the line, including after a token. Names contain 1–128 ASCII letters, digits, `_`, `-`, `.`, or `/`. Blank lines and CRLF files are supported. Duplicate declarations are rejected; duplicate edges are allowed.

The complete file is parsed before planning. Invalid names or duplicate declarations are errors even in unreachable rows. Missing dependencies and cycles are checked only in the requested reachable subgraph. An unrelated broken target therefore does not prevent planning an independent target.

The limits are 1 MiB of file bytes, 4,096 declarations, 32,768 dependency occurrences, and 128 requested roots. The reader expects a regular, settled UTF-8 file. A sized read followed by an EOF check rejects a short read with remaining data or a growing file instead of silently accepting a prefix. File-operation failures use stable application diagnostics without platform-specific OS messages.

## Errors

Domain errors are complete stdout records, ending in one newline. They do not include a partial successful plan. Examples:

```text
error missing assets
path app assets
```

```text
error cycle library
path app library parser library
```

The path includes the complete active root prefix, not just the shortest cycle. Other records are `error duplicate LINE NAME`, `error invalid-name LINE NAME`, `error invalid-root NAME`, `error graph-limit`, `error root-limit`, `error input-limit`, `error file-open`, `error file-size`, `error file-read`, `error incomplete-read`, and `error usage: --graph FILE ROOT...`. Empty invalid roots retain the space after `invalid-root`.

Successful plans and handled application errors both complete the IO computation normally. Consumers must inspect the first stdout record; a process failure instead indicates a runtime or execution failure. `internal-stack` and `internal-budget` records are invariant failures, not expected graph errors.

## Algorithm and bounds

The Bend implementation uses an explicit work stack of enter/exit records, an active path, and a completed-target set. Entering a completed target does no further work. Entering an active target reports a cycle. An exit adds the target to the completed set and postorder. This preserves sharing without expanding a DAG into a tree.

The loop has structural fuel `R + E + V + 1`, using the number of requested roots and all declared edges/nodes. Every root or dependency occurrence can add one enter record. Each reached declared target adds at most one exit record. The extra step observes the empty work stack. Cycles and missing nodes stop earlier. An already completed result is accepted with zero remaining fuel.

Graph lookup and active/completed membership use linked lists. Space is linear in the graph and work stack; worst-case planning time is quadratic or `O(VE)` because lookup/membership scans are linear. This is deliberately a moderate graph application, not a large indexed build database. The initial survey includes irregular shared DAGs of 100, 350 and 800 nodes, a 511-node tree, and a 1,000-node chain.

## Oracle and generated inputs

`oracle.py` uses only Python's standard library. Its independent algorithm uses a dictionary, recursive three-color DFS, and a Python active stack rather than the Bend work-item/fuel implementation. It emits complete newline-exact output.

```sh
python3 selfhost/apps/dependency-plan/oracle.py plan --graph selfhost/apps/dependency-plan/fixtures/shared.graph app tests app
python3 selfhost/apps/dependency-plan/oracle.py generate --output /tmp/dependencies.graph --nodes 350 --seed 17 --fanout 5
python3 selfhost/apps/dependency-plan/oracle.py plan --graph /tmp/dependencies.graph n0349
```

The generator also supports `--shape tree` and `--shape chain`. Generated DAGs have a backbone plus seeded irregular edges to older targets, which guarantees reachability while creating shared subgraphs. Generation prints the requested root names.

The shared application runner imports `cases(out_dir: Path, depth='smoke'|'survey')`. Each case provides `id`, runtime `argv`, full `expected` stdout, and `input_files`. Smoke has ten cases; survey has twenty-one. Cases include shared and repeated roots, missing dependencies, reachable and unreachable cycles, invalid names/declarations, empty roots, CRLF/comments, bounds, and generated graphs. Case generation and oracle execution run no Bend compiler or native application.

## Native threading scope

The maintained [runtime CLI](../../src/runtime/native/runtime.c) accepts `--threads N`, with a positive integer clamped to 128 workers; absent that flag, CPU affinity and cgroup quota inform its default. There is no `BEND_THREADS` environment option or `-T` alias in this runtime. `--gpu off` selects CPU execution; GPU work otherwise requires eligible bang calls and a usable device/backend. This planner introduces no bang calls.

Worker count is a runtime capability, not a promise that this DFS scales. Its shared active/completed state imposes a sequential traversal, and its IO sequence is ordered. A 1/2/4-worker sweep is a useful serial-workload control; independent graph queries or level computations would be separate future application designs. Multiworker measurements must allow the process corresponding CPU affinity rather than pinning every worker to one CPU.

The native compiler host's [launcher](../../tools/native/launch.py) currently fixes its own compiler process to one worker. That does not remove `--threads` from the separate generated application's runtime. No runtime or compiler source is changed by this application.

Compilation and native execution are performed by the root-owned Phase100 runner. This directory does not claim a native result before those receipts exist.
