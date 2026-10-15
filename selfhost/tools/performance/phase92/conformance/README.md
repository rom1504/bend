# Frozen native compiler conformance

This method executes the actual native compiler image. Node only orchestrates
file IO, Clang and the existing golden-output judge; it imports no Bend compiler
API. All target commands belong to the root's serial guarded queue.

The frozen D04 entry supports one source importing canonical Base, nine pinned
Base C providers, and checked C emission. It has no parse-only, check-only,
interpreter or JavaScript-emission mode. It cannot reproduce the frontend3174
or JS23 gates unchanged.

The original native100 set contains69 Base-only fixtures and31 exclusions:
30 import additional Bend modules, and one instead uses a fixture-specific
foreign provider. Two of the30 module fixtures also use custom foreign code.
No fixture is flattened, renamed or prefixed with synthetic imports. The
offline inventory retains every original source hash and golden output.

Prepare after the exact upstream-built native B1 and its receipt exist:

```sh
python3 -B selfhost/tools/performance/phase92/conformance/prepare.py \
  --build selfhost/build/phase92/upstream-b1/build.json \
  --out selfhost/build/phase92/conformance01
```

Run the three commands in `conformance01/commands.json` sequentially: B1 native69,
B2 native69, then six rejection observations. Each suite has one outer guard;
the adapter creates no nested guard. Its child timeouts are bounded by the
existing conformance worker, which terminates its process group on timeout.
The native compiler and generated programs use one CPU worker and GPU off.
Generated C is built with the historical conformance recipe Clang C11/O3.

The adapter uses regular files for all child captures, preserving the actual
compiler, Clang and program stdout/stderr in each result. Successful C and ELF
files are ephemeral under the unchanged `--retain failed` harness policy;
their hashes and complete observable results remain in the report. Failures
retain their full work directories. Each case refuses before launching if
free disk is below160MiB. Do not reclassify that refusal as conformance failure.

The native B1 uses upstream's argv convention; native07 requires the explicit
payload sentinel. Both use exactly the admitted Base/runtime/provider/cache
tuple. Shared `comparison/support.py` authenticates their honest, separate
producer/build receipts and identical D04 source. New B1 is not admitted through
the native07 public manifest.

The rejection lane preserves the existing malformed/type-error fixtures and
original `page/deep_list_walk.bend`. It checks exit1, expected phase, no C,
original native diagnostic equality where available, and cross-role diagnostic
identity. D04 intentionally discards `DResult.diagnostic`; its concise checker
error cannot test the JS rich error-page stack overflow. The comparison to
historical JS full/fallback text records that distinction rather than changing
the golden page or calling it a frontend pass.

Collect completed observations offline:

```sh
python3 -B selfhost/tools/performance/phase92/conformance/collect.py \
  --plan selfhost/build/phase92/conformance01/plan.json \
  --out implementation/phase92/native-conformance-results01.json
```

The collector requires69 golden passes per role, unchanged inputs, successful
guards, original historical runtime observation equality, and six valid
rejections. Any31 exclusions remain explicitly outside coverage. Passing does
not establish native100/100, full frontend conformance, GPU/parallel correctness,
JS output support, independent kernel proof, or cross-role complete C equality.
