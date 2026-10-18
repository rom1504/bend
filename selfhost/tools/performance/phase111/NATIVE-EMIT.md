# Native compiler request transport

`native-emit.py` is a root-run supervisor for an already acquired Phase111 native
compiler image. It does not acquire that image or implement any compiler algorithm.
Run it inside the same serial CPU, memory, and process-tree guard used for compiler
acquisition. The script provides wall timeouts and child process-group cleanup;
it does not enforce memory limits.

```sh
python3 selfhost/tools/performance/phase111/native-emit.py \
  --image /absolute/path/to/acquired/program \
  --source /absolute/path/to/input.bend \
  --out selfhost/build/phase111/native-request01 \
  --mode cache \
  --reference selfhost/build/phase111/API_EMISSION_DIRECTORY
```

`--reference` accepts a complete emission directory or its `report.json`. The
reference must bind the same source path/bytes, mode, selected admission, Base,
and (in cache mode) carrier. It can come from `emit.mjs`, `staged-emit.mjs`, or a
previous successful `native-emit.py` request. Bare QBE files are not reference
receipts. Comparison is exact bytes, without whitespace or newline normalization.

Add `--runtime selfhost/build/phase111/RUNTIME_DIRECTORY/runtime.o` to invoke
unchanged `build.py`. Add `--expected /absolute/path/to/expected.stdout` to run
the resulting program and require its exact stdout, empty stderr, and zero exit.
`--expected` requires `--runtime`; runtime directories containing `runtime.o` and
image directories containing `program` are also accepted. Defaults are 300 seconds
for the native request and 180 seconds per builder command; override with
`--seconds` and `--build-seconds`. Output directories must be fresh and beneath
`selfhost/build/phase111`.

`native-assets01.json` freezes the selected native admission, exact Base, cache
carrier and stamp. The low-level invocation is:

```text
IMAGE --threads 1 --gpu off -- phase111 ABS_INPUT ABS_BASE cache ABS_CARRIER STAMP
```

The explicit `phase111` is necessary: the portable runtime copies only the
arguments after `--` into `IO.args`; the Bend entry consumes the first as its
unused program placeholder. Live mode uses `live` in the same position. It still
passes carrier/stamp slots, which the entry ignores, and does not read or require
the carrier file.

The native entry performs one `IO.print` per QBE chunk, which appends a newline
per chunk. Both existing API transports write `chunk + "\n"`. Raw native stdout
goes directly to `program.ssa`; the supervisor neither adds a final newline nor
strips diagnostics. Native emission requires a zero exit, nonempty stdout, and
empty `emit.stderr`. This alone does not establish that stdout is valid QBE.

`report.json` records input/image/method/asset hashes, exact child commands,
exit status, output/error hashes, native request wall time, and separate emission,
comparison, build, and semantic gates. Failed requests retain partial stdout and
stderr with a failed stage; negative source refusals never become successful
emission gates. The complete flag means all requested gates passed. The native
wall clock includes file reads, compilation, and output writes; it is not
comparable to a staged API compiler-only clock. The outer guard supplies process
tree resource accounting.

An adjacent complete image build receipt is pinned when its binary matches the
supplied image. This binds that receipt, not a new acquisition proof. Full image
provenance still follows its emission, checked source, and cached runtime receipts.
The request pins the root source, not a transitive imported-source closure; use
the assembled compiler source or preserve separate imported-source provenance.
Successfully running a native compiler on a small fixture is a native request
gate. Full self-host qualification additionally requires emitting the current
assembled compiler, building that successor, and checking its products and
semantics.
