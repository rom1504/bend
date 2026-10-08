# Phase65 checked build and export admission

These are recorded successors of the frozen Phase64 factories. `derivation.json`
pins each parent and output and gives exact one-occurrence textual edits. The
baseline is Phase64 State09 (`49431ba`), with 95 checked exports, including `book_context_world`. No factory has
been invoked against current compiler source during preparation of this package.

Root must pause source editors and explicitly select a candidate before these
commands. Each output below must be fresh. From the repository root:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase65/latency/build/export-admission.py admit selfhost/build/phase65/export-state01
taskset -c 0 python3 -B selfhost/tools/performance/phase65/latency/build/make-build.py selfhost/build/phase65/build-state01 --attempt selfhost/build/phase65/checked-state01
taskset -c 0 python3 -B selfhost/tools/performance/phase65/latency/build/make-build.py selfhost/build/phase65/build-state01 --verify
```

The first command records the selected driver and preserves State09's bootstrap
export construction exactly. The second freezes actual build inputs and writes
`development.json`, `recipe.json` and `commands.txt`. Root executes the printed
build command only: it has one CPU3 guard, a 300-second budget, 1 GiB Node heap,
2 GiB process-tree RSS, 4 GiB available-memory floor and 4 MiB stack. The build
uses the equality profile, one worker, strict exact validation with the default
36 focused cases, and the unchanged
Phase23 upstream pin. `--selection FILE` retains the existing focused-selection
option. No build, Node process or compiler target is started by either factory.

After the genuine checked build completes:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase65/latency/build/export-admission.py reference selfhost/build/phase65/export-state01/admission.json selfhost/build/phase65/checked-state01 selfhost/build/phase65/export-reference-state01
```

This writes actual roots and source/API/driver joins plus the guarded root-only
API-validation command. Root then executes that command from the generated
`commands.txt`. It checks exact exported membership and callable functions; a
source declaration alone does not establish checked API provenance.

By default, no extra exports are admitted. If root explicitly selects additional
exports, supply `admit ... --additions PATH.json`; the JSON is an object mapping
source module paths (such as `src/back/js/direct/example.bend`) to nonempty arrays
of new function names. Each module must be in `src/compiler.json`, each function
must have exactly one definition, and the driver must contain the same exact
source-backed conditional export line format used in Phase64. Removing those
explicit new lines must restore State09's export-construction block byte for
byte. Duplicate names, overlap with the baseline, missing declarations and
unexplained export changes are refused. Admission pins the additions document
and copies its source modules; reference joins those copies to the actual checked
snapshot. The resulting API must contain precisely the old 95 exports in their
original order plus the admitted names.

Bindings, B2 construction, qualification and performance measurement are separate
methods owned by the Phase65 measurement workflow. These factories neither
install a compiler nor change any Phase64 snapshot or consumed tool.
