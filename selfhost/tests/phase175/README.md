# Frontend component experiments

The compiler work in this loop is implemented in Bend. Python prepares exact
source closures and launches bounded processes; JavaScript calls independently
checked APIs and compares complete values. Neither host adapter implements
parsing, checking, annotation or erasure.

Start with [the design](../../../design/phase175/README.md) and
[frontend boundaries](../../../experiments/phase175/frontend-loop.md).
Use the installed Phase174/Phase171 assets explicitly. Every execution goes
through `job.py`, which uses the maintained disk/process guard on CPU3 and closes
its receipt. Run one target job at a time.

`frontend-prepare.py` accepts explicit modules, replacements, helper preludes,
exports and optional native main. It authenticates the maintained parent and
preserves protected declarations. Preparation is not source checking: acquire
the resulting API with `selfhost/tools/build/hosted.mjs acquire` before using it
as an oracle. Build native experiments with `selfhost/tools/build/native.py`.

`compare-frontends.mjs` compares complete constructor values, scalar fields,
lists, diagnostics and indices against the separately checked baseline API.
Use `--kind stages --modes parse` for a parser-only service, or select
`parse,check,context,annotation,request`. The parser campaign additionally
checks operators and complete parser controls. The semantic campaign checks
private field-erasure controls and dependent/rewrite source examples.

`native-frontend.py` runs fresh native processes in balanced role order. Its
frontend clock excludes the separately timed complete structural digest;
whole-process time includes reads, Base preparation, the digest and teardown.
The digest supplements the complete-value semantic gate. It is not a proof or
a collision-free correctness oracle.

All candidates are experimental until the report records their corresponding
source, semantic, performance and integration gates. These fixtures do not
replace the installed compiler or the independent final verifier.
