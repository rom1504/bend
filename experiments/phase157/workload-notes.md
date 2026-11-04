# Phase157 captured compiler workload

Prepared offline from the already checked Phase154 native harness. No compiler,
generated program, checker or benchmark was executed during preparation. The
new transport still requires the root's independent source check and output gate.

## Identical source and exact oracle

`selfhost/tests/phase157/workload.bend` is a standalone `import Base` program:

- 388,521 bytes; SHA256
  `d0dbf871ef6f4b7d966a58293bedb9e1355038f01ebe1f7e81c69e93f1d9081e`.
- 930 declaration blocks: 922 unchanged Phase154 declarations and eight new
  transport/entry functions. Compiler algorithms were not rewritten.
- The original-only/compiler-only closure omits the alternative numeric scalar
  implementation and the unrelated Map fixture. It is smaller than the retained
  490,835-byte two-role/two-family harness without requiring a new semantic oracle.

Compile these **same source bytes and the same Base bytes** with upstream C,
bendc GC, bendc RC and qualified QBE. Compiler-specific runtime argument prefixes
may differ; arguments delivered to `IO.args` must be identical. A source-language
or backend refusal is an unsupported lane, not permission to simplify its input.

Logical program arguments:

```
compiler-work oracle 1
compiler-work bench 0
compiler-work bench 1
compiler-work bench N
```

`oracle 1` must exit zero, emit no stderr, and match the **entire** existing file:

```
selfhost/build/phase154/native-plan03/0-expected.stdout
173582 bytes
SHA256 9c08e21b3f5eac0bf17c1be4fcb76fe1fda79f8faadbf99469dfb03c3399f82e
```

This is full QBE text produced by the original independent Phase154 pipeline,
not a checksum or a new backend's output adopted as truth. The expected file
concatenates five separately admitted original-owner outputs. Its derivation is
recorded in `experiments/phase154/tools/native.py` and the retained
`selfhost/build/phase154/controls03/report.json` and
`selfhost/build/phase154/native-plan03/manifest.json`.

`bench N` allows 0 through 65,536 repetitions and writes every freshly computed
complete output to `/dev/null`. It neither caches a lowered result nor replaces
the consumer with a checksum. `bench 0` still loads and decodes the whole input
book and constructs authentic metadata contexts. Record that setup control
separately; do not subtract it to manufacture a whole-process speedup.

## Actual work and capture identity

Each repetition runs these genuine compiler owners in retained order:

1. `p111_empty`
2. `p111v_contract`
3. `p111v_state_argument`
4. `p111v_value`
5. `p111v_counted_call`

For every owner the path is original `p113d_candidate`, original scalar
transformation through `p154h_old`/`p113k_function`, unchanged independent
`p113e_function` verification, complete `p113e_private` QBE rendering, and
`File.write`. Successful native output checks must precede performance claims.
Failure retains the original diagnostic and nonzero exit rather than becoming a
quick successful observation.

The context is the **entire real captured erased request book**, including cache,
indices and all term metadata, rather than a fabricated small tree. The source
reads this existing immutable path once per process:

```
selfhost/build/phase154/book-fixtures01/compiler-verifier-slice.book.txt
2979167 bytes
SHA256 15f41031b1f89fe4add47cadbb80badbe677798ebd4c42638f17efd42fa502d4
```

The originating graph is:

```
selfhost/build/phase154/capture-plan05/capture/compiler-verifier-slice.graph.json
27427112 bytes
SHA256 e535a9a0d66c735423ab8bd47072b8663deff00a2af598ec4d145d12fbaee846
```

The transport contains 178,345 nodes and 1,171 strings. Existing
`selfhost/build/phase154/check-input01/report.json` records exact decoded-book
comparison with the original capture: all fields and primitive values, not only
a digest. The new source retains that same checked Bend reader. Pin the input,
source, oracle, Base, toolchain and receipt identities before each backend run.

## Mechanical source preparation

The source parent is:

```
selfhost/build/phase154/native-plan03/compiler.bend
490835 bytes
SHA256 ca87075d64987029c27ac7df9b999d5eda356bb651d45b66445254af731a1340
```

Preparation used `selfhost/tools/build/source.py:blocks` to remove only its old
`main`, then `experiments/phase147/tools/prepare.py:extract` from the root `main`
over the original declarations plus the eight `p157w_*`/`main` transport
declarations at the end of this new source. The new transport fixes the old
compiler route, calls the exact `_0` fixture declarations, and removes the old
runtime candidate/family selection. No captured data was pruned or regenerated.
This also gives a small repeatable reconstruction recipe: extract those eight
transport blocks from the new source, remove one leading LF from each (the
separator added by the first extraction), concatenate them, and apply the same
closure operation to the pinned parent. Offline reconstruction reproduced the
complete source bytes exactly. Separately comparing all 922 retained declaration
bodies after removing only outer separator whitespace found zero differences.

The source loop does not benchmark an unused result: `p157w_cases` calls
`p157w_text` inside each iteration and immediately passes its complete text to
the retained error-checked `File.write` consumer. Both the recursive case tail
and the repetition tail occur inside `do IO` after that write. Runtime `count`
comes from `IO.args`/`U32.read`; the transport has no precomputed QBE or result
cache. Ordinary compiler optimization may still specialize constant fixture
metadata, which is legitimate for an identical-source comparison. If profiling
shows common-subexpression elimination across iterations, report that boundary
rather than attributing the result to faster repeated compiler work.

## Cheap measurement ladder and limits

After source/build checks, first run `oracle 1` once per backend. Then use the
same `bench 0`, `bench 1` and bounded `bench N` schedule everywhere, increasing N
only if the steady work is too short relative to startup. Choose a single N
before paired timings, keep one target timing lane, and report complete child
wall/CPU/RSS and build costs separately. Preserve normal ownership cleanup.

This covers five legacy direct-helper lowering/scalar/verifier/emission paths,
not full parsing, dependent checking, the selected `p113pl` pipeline, self-hosting,
all compiler programs or general upstream parity. The original Phase154 capture
had 20 inspected owners; nine across both families were admitted by this retained
producer. The five compiler owners are that established successful subset, not
new cherry-picking by which Phase157 compiler is fastest. Absolute throughput can
be influenced by input decoding and output allocation; the zero-repeat control
and size/repetition ladder make those boundaries visible.
