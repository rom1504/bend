# Reproducing the Phase141 compiler simplification

Phase141 shares the normal/incremental top-declaration parser and statically
specializes structural-comparison algorithms. It changes compiler implementation
structure while preserving the frozen generated products. Read the
[report](../../implementation/phase141/README.md) for measured size, speed and
correctness limits; this is not a 10k-line compiler or full conformance proof.

The native source is assembled from the pinned Phase140 experimental source18
with two explicit replacements. Compiler behavior remains implemented in Bend;
the Python tool only selects, replaces and checks source declarations.

```sh
python3 -B selfhost/tools/performance/phase141/prepare-v02.py \
  --out selfhost/build/phase141/replay01 \
  --contract selfhost/tools/performance/phase141/integrated-contract-v02.json \
  --module selfhost/tools/performance/phase141/parser/core-v01.bend \
  --module selfhost/tools/performance/phase141/static-family/core-v01.bend
```

Use a fresh output directory. The resulting `compiler.bend` must have SHA256
`f5bfca6d1fe9b378955d6c89ba5ec2428ec1627d7d008eb0c15eac1b51c8a06a`.
The preserved source snapshot and parent snapshot are in the evidence capsule;
historical modules remain experiment oracles, not simultaneous active parsers.
Exact native image, checked source, runtime, Base and qualification identities
are listed in[candidate.json](../../implementation/phase141/candidate.json).

Use the existing guarded native request driver with the candidate image:

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase111/p141-request-guard01 \
  --seconds 180 --rss-mib 3072 --available-mib 16384 --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase130/native-request.py \
  --image selfhost/build/phase111/p141-integrated-n2/program \
  --source path/to/program.bend \
  --carrier-receipt selfhost/build/phase130/base-carrier01/receipt.json \
  --out selfhost/build/phase130/p141-request01 --seconds 150
```

The source path must identify an existing program. Whole-compiler requests need
a longer guard and larger output-file allowance; use the recorded acquisition
commands rather than applying the small-program limit blindly.

The existing Phase140 session transport remains experimental. Its exact-change,
logical-source, producer, policy, runtime and Base identity checks still apply.
The[four-revision and real compiler-edit evidence](../../implementation/phase141/metrics.json)
does not establish a general persistent incremental compiler service.

The main programming lesson is small: use closed static arguments when sharing
algorithms that require compile-time specialization. Explicit runtime state is
still runtime state; an environment-capturing callback cannot silently be treated
as a closed policy. Preserve fallback, ownership, diagnostics and traversal order,
and compare against an independent old implementation before deleting it.
