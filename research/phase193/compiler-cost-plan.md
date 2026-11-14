# Separate N1 and N2 compiler-request gates

`selfhost/tests/phase193/compiler-cost-plan.py` extends the existing Phase192
metadata adapter with an explicit `--stage N1|N2` and a fourth fixed request.
It delegates actual request authentication/argv to maintained `request.py` and
manifest freezing/timing to maintained `bench.py`; it never runs a target or
acquires a compiler. The unchanged Phase192 adapter is pinned as method provenance.

Both gates use numeric256, expression32, tree-bitonic and test-map-set-ops, with
two balanced role rounds: sixteen fresh-process requests. Every invocation
must reproduce its own role's preexisting complete object and empty stderr.
Source input bytes, Base, prepared carrier, stamp, linked runtime and complete
argv tails must agree across roles. Different baseline/candidate output objects
are allowed, because the compiler algorithms/selected code can change.
The respective native45 acquisition must already be complete and each selected
case must have its independent generated-program oracle pass.

N1 defaults to `phase192/native45-01`; N2 defaults to `phase192/native45-02`.
Both pin exact image receipts and actual `N1`/`N2` image bindings, with compiler
source identities `phase192/selected-source01/compiler.bend` and
`phase193/selected-source01/compiler.bend`. N1 additionally requires the identical
QBE-producing image/binding and machine toolchain used for Phase192 N1. This is
the existing `phase186/release-qbe-chain01/n2/program` producer. The bound target
must be QBE for N1 and direct x86 for N2; stage labels alone are insufficient.

The **N1 gate** compares compiler-source changes while holding the QBE producer
and machine toolchain fixed. Generated code layout can still change, so this
does not measure an abstract algorithm independent of machine code. Its purpose
is to screen compiler work before paying for another full native N2 build.
The **N2 gate** measures the combined compiler-source change and its new
direct-x86-generated implementation. It is conditional on the separate N1
admission decision and actual N2/product construction.

Candidate qualification evidence is optional, allowing an early N1 cost screen
before N2 reproduction. Passing the screen does not imply bootstrap completion,
broad conformance or promotion. If an actual completed qualification report is
available, pass `--candidate-qualification REPORT`; the helper pins it without
re-proving its claims. Baseline qualification defaults to Phase192's evidence.

Once the candidate N1 acquisition exists:

```sh
python3 -B selfhost/tests/phase193/compiler-cost-plan.py \
  --stage N1 --candidate-build selfhost/build/phase193/native45-01 \
  --out selfhost/build/phase193/compiler-cost-n1-plan01
python3 -B selfhost/tests/phase193/job.py compiler-cost-n1-01 70 128 \
  python3 -B selfhost/tools/bench/bench.py run \
  --manifest selfhost/build/phase193/compiler-cost-n1-plan01/manifest.json \
  --set full --rounds 2 --budget 60 --cpu 3 --guarded \
  --out selfhost/build/phase193/compiler-cost-n1-01
```

Use the actual candidate acquisition path if it differs from `native45-01`.
The paths shown are planned destinations, not assertions that products exist.
For the later N2 gate, change stage to `N2`, candidate acquisition to its actual
N2 native45 directory, and plan/run names to fresh `compiler-cost-n2-*` roots.
Do not silently substitute N1 products into the N2 comparison.

The maintained runner includes process startup, input/prepared-Base reads,
checking/lowering/emission and output writes in each child clock. Preflight
hashing and complete-output comparison are outside that clock. There is no
assembler, linker, generated-program execution, warmup or hidden source-output
reuse in these timed requests. Cold means a fresh compiler process; OS caches
are not flushed.

The inner 60s budget bounds all sixteen requests; the outer 70s guard supplies
cleanup/report slack with a 128MiB disk budget. Preserve an incomplete run as a
failure, not a favorable subset or automatic replay. Report each case's two
wall samples, paired/role medians, CPU and RSS alongside the four-request
geometric ratio. The bounded screen does not establish confidence intervals,
full-source throughput or generated-program runtime.

Preparation validation authenticated all four existing baseline requests at
both N1 and N2 (eight metadata plans, no target execution), and parsed the Python
adapter successfully. Candidate metadata preparation remains pending its actual
acquisition. No compiler or benchmark job was launched by this preparation task.
