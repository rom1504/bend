# Bootstrap branch

This branch starts from upstream
`6018e28ecc67cf1fffc0c20c64b11023474c2df8` and keeps the upstream tree intact.
The `selfhost/` directory contains the supplied compiler port and its historical
validation evidence. The first commit preserves every supplied archive file
byte for byte; the second adds the controlled performance baseline.

Archived reports retain their original paths and artifact identities as
historical provenance. Read [README.md](../README.md) for relocation limits on
byte-identical self-rebuilds.

From the fork checkout root, try the supplied compiler with Node 24 or newer:

```sh
cd selfhost
node cli.mjs tests/conformance/typed-smoke/base-u32.bend --check-only
```

No bootstrap build is needed to run the supplied generated artifacts.

## Repeat the performance baseline

The benchmark and bootstrap tools require an exact pinned upstream HEAD. This
branch adds commits on top of that pin, so create a separate clean worktree.
Run these commands from `selfhost/`, using Python 3, Linux taskset, and an
available logical CPU:

```sh
git worktree add --detach .bootstrap/upstream 6018e28ecc67cf1fffc0c20c64b11023474c2df8
export BEND_UPSTREAM="$PWD/.bootstrap/upstream"
BEND_BENCH_NODE="$(command -v node)" BEND_BENCH_CPU=2 \
  python3 tools/performance/run.py build/performance/new-baseline
```

The output directory must not already exist. The selfhost ignore rules exclude
the upstream worktree, build caches and trial outputs. The
[performance report](PERFORMANCE-BASELINE.md) links raw measurements and the
full reproduction protocol. Compiler implementation files remain unchanged.
