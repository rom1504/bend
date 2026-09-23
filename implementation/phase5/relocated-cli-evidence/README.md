# Default CLI from a fresh relocated package

The original report records four actual invocations from a new `/tmp` tree,
with no `.bootstrap` or `build` directory at the start and no `BEND_*` or
`NODE_OPTIONS` overrides. Copy exactly the paths/hashes in `report.json` from
the repository, plus the two retained input files, into a new scratch directory.
The recorded absolute historical directory is not needed to replay.

With Node24, from that scratch directory:

```sh
node tools/development/release.mjs --verify
node cli.mjs nat.bend --interpret
node cli.mjs nat.bend --run
node cli.mjs hello.bend --run
```

All exit0. The programs print8,8 andhello respectively. Stdout/stderr are retained
unchanged. The release manifest and checked-parent transformation are already
tracked with the release; no upstream compiler is consulted by these commands.
This supplements the earlier verification-only relocation check and exercises
Base loading, JS generation/execution and the IO effect route after relocation.
