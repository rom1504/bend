# Phase92: matched native compiler stages

This compares two native executables of exactly the same frozen Bend compiler
source, `d04ad79c…`. Native B1 is emitted by pinned upstream TypeScript to C;
native B2 is the admitted self-emitted native07 image. Their Clang executable
and O2 build arguments match, apart from C input and executable destination.
The compiled compiler's C representation/runtime is the deliberate variable.

Both stages receive identical source, Base, runtime parts, nine effect providers
and prepared-Base carrier. The only argv normalization is explicit: upstream's
IO.args includes its executable name, while native07 needs its admitted sentinel.
The same Bend entry removes this first item. `support.py` authenticates these
bindings once and exports `authenticate`, `native_args` and `unchanged` for the
benchmark and conformance adapter. No Node process executes native requests.

## Six-source first screen

```sh
python3 -B selfhost/tools/performance/phase92/comparison/run.py \
  --b1-build selfhost/build/phase92/upstream-b1/build.json \
  --corpus screen --out selfhost/build/phase92/screen01
```

Defaults are two balanced fresh-process rounds across Small, Numeric, Lexer,
Map, Functions65 and Unicode. Each round rotates/reverses B1, B2 and fresh
TS/Bun order. Every complete C output must match its authenticated Phase90
six-source oracle. All input hashes are checked again after the campaign.
`--cases small,map_closed --rounds 1` provides a smaller explicitly scoped loop;
`--calls 5` retains each repeated request and verifies every returned C.

The primary ratio is native **B2/B1**, for both first-request time and process
wall time. Both request clocks include full C/error/verdict consumption and
exclude prepared-Base decoding, runtime transport and output-file writes.
Base/runtime preparation is separately recorded. Process clocks include
startup, preparation, emission, output writes and teardown, excluding Python
authentication. Millisecond request clocks and two rounds make this a screen,
not a high-precision estimate for every program.

The additional B1/TS-Bun and B2/TS-Bun ratios retain the historical reference
worker's boundaries: TypeScript loads/checks source Base during its request;
native stages decode the same prepared carrier beforehand. TypeScript output
hashing/writing is outside its request timer. Imports are reported separately.
These reference ratios do not isolate backend lowering or imply equivalent
cache preparation. `--live` measures both native stages without their carrier;
it is a distinct experiment and must use a fresh output directory.

## Expanded output and execution qualification

```sh
python3 -B selfhost/tools/performance/phase92/comparison/run.py \
  --b1-build selfhost/build/phase92/upstream-b1/build.json \
  --corpus broad45 --execute --out selfhost/build/phase92/broad01
```

This uses the existing 45 closed catalog points derived from 23 original
programs, retaining their names, source derivations and expected complete stdout.
Each native stage emits every point once. Both complete C files must equal the
independent checked-JS output with the two authenticated runtime edits replayed
exactly. Those retained C oracles already have exact optimized preprocessing
against the independently executed historical outputs.

After all emissions agree, one O2 executable per identical C product is built
and run with one CPU thread and GPU off. Complete expected stdout is checked.
This is generated-program **correctness**, not a fresh program-speed benchmark.
Exact C continuity can support retaining earlier performance evidence only for
the identical output/runtime/toolchain scope. The compiler request timings are
not generated-program execution timings, and no C12 speed ratio is inferred
from these closed points.

The original Phase91 JS23/C12 continuity inputs are recorded separately. Every
original C12 batch source imports another module as W, outside the frozen native
entry's single-Base scope. They are explicitly excluded rather than inlined,
renamed or silently substituted. The closed45 lane does not claim original C12,
arbitrary imports, all native effects, GPU coverage or full language conformance.

## Execution and evidence

Only root runs target commands, serially through the existing guard: CPU3,
2 GiB process-tree RSS, 4 GiB available-memory floor, 60-second compiler/build
deadlines and 20-second generated-program deadlines. Before each job the runner
requires 176 MiB free disk, retaining a 160 MiB reserve plus output headroom.
The broad lane retains about 27 MiB of generated C, plus executables and logs.
Failed guards, partial reports and differing outputs remain available.

`--check-only` performs authentication and corpus checks without targets.
Actual offline preparations passed in `screen-preflight01` and
`broad-preflight01`; neither is a performance or conformance result. Reports
record the exact methods, commands, assets, C products, clock boundaries and
selection. Fresh output directories are mandatory; existing evidence is never
overwritten.
