# Phase173: reuse the complete checked frontend result for backend experiments

This is a bounded experiment adapter, not another incremental compiler. It avoids
rerunning an unchanged ~45-second hosted frontend when only backend admission or
ABI code changes. Cold-build measurements must still run the ordinary complete
request; these runs explicitly report **warm backend replay**.

## Existing machinery and actual compatibility

Phase115 retained immutable emission alternatives in one process. It did not
provide persistent checked-frontend reuse. The reusable transport already exists
in `experiments/phase154/tools/graph.mjs`: generic encode/decode preserves complete
objects and sharing, with explicit node/byte limits. Phase154 captured full
`P86Plan` values and Phase156 consumed captured graphs. Phase165 also captured a
complete `NR_Request`, but its later backend-replay runner still reran the
frontend. The Phase171 request adapter always calls Base preparation and
`p86_plan` before backend emission.

A metadata-only conservative declaration extraction from these actual API sources
finds exactly the same frontend closure for `p88_cache_prepare` and `p86_plan`:

- `vertical-base-source02`
- `scc-source03`
- `abi-source03`
- `store-direct-source01`

Each closure has 2,135 declarations and 637,203 assembled bytes. The ordered
(kind, name, byte length, exact declaration SHA256) fingerprint is
`7a9c5f9be623e3ebf145d2011201e7f7233713fe2d4ca84cc14702e800e08ec7`.
No frontend declaration differs. This includes the parser/checker, annotation,
ownership, erasure, request construction and referenced type declarations, not
just the top-level `p86_plan` function. It is therefore useful for these backend
patches; changing the native benchmark's source itself still invalidates capture.

## Minimal tools

`selfhost/tests/phase173/plan-binding.py` reads a successful Phase171 assembly and
checked API receipt, authenticates their inputs, and extracts the frontend closure
with the existing Phase147 conservative source extractor. It runs no Bend. It
also binds the upstream revision and exact `bend.ts`, `comp.ts`, Base, hosted
acquirer, stage0 library and Bun identities so that matching Bend source alone
cannot silently cross a changed hosted representation boundary.

`selfhost/tests/phase173/plan-replay.mjs` uses the existing graph transport and
ordinary `p169np_plan`/`p134e_next` backend calls. It supports:

- `capture`: prepare Base, check the complete source, save the entire P86Plan
  including request and verdict, then stop before lowering.
- `capture-emit`: capture and emit through the normal backend once.
- `replay`: freshly decode the pinned graph and emit without calling Base
  preparation or `p86_plan`.

The host only authenticates, transports, calls checked Bend exports, and writes
returned text. It does not lower IR, interpret an optimization rule, reconstruct
selected semantic fields, or turn a caller assertion into a correctness proof.
Each replay decodes a fresh object graph; no mutated in-process state is shared
between candidates. The on-disk graph and its producer inputs are pinned and
verified again after execution.

## Usage and gates

Create a frontend binding for each already checked API:

```sh
python3 -B selfhost/tests/phase173/plan-binding.py \
  --assembly CHECKED_SOURCE/manifest.json \
  --receipt CHECKED_API/report.json \
  --out selfhost/build/phase173/FRESH_BINDING
```

All following target calls belong in the existing disk/resource guard, with one
CPU3 lane and a fresh run root. Use the pinned Bun executable:

```sh
selfhost/.assets/bin/bun selfhost/tests/phase173/plan-replay.mjs \
  --assembly CHECKED_SOURCE/manifest.json \
  --receipt CHECKED_API/report.json \
  --frontend selfhost/build/phase173/FRESH_BINDING/binding.json \
  --source FROZEN_WORKLOAD/compiler.bend \
  --mode capture-emit \
  --out selfhost/build/phase173/FRESH_CAPTURE
```

For the first replay, use the **same** checked API, `--mode replay`,
`--capture FRESH_CAPTURE/plan.json`, a fresh output, and
`--reference FRESH_CAPTURE/report.json`. Require complete QBE byte equality to
validate the transport boundary. A successful ordinary Phase171 request receipt
is also accepted as a QBE reference, for matching source/Base/carrier/stamp.

For another backend candidate, make its own frontend binding and point replay to
the same capture. If the candidate intentionally changes QBE, do not require old
QBE identity; retain the independent final verifier, native complete-output oracle
and appropriate correctness gates. Cached checking is not cached backend approval.

Default transport bounds are one million graph objects and 128 MiB. Explicit
`--node-limit` and `--graph-mib` overrides are capped at four million and 512 MiB;
the execution guard must budget the chosen size and memory. Capture/decoding costs
and retained storage must be measured before assuming the cache pays off. Existing
complete native-store source is about893KB, but no graph-size estimate is treated
as measured evidence.

## Invalidation and accounting

Replay refuses a changed logical source path or bytes, Base path/bytes, prepared
carrier, stamp, Bun engine, acquisition ABI, or frontend declaration closure.
Type definitions are part of that closure. Both producer and consumer APIs must
have successful checked acquisition receipts. Capture preserves every NR_Request
field and all sharing; a projected body list is not an acceptable substitute.

It is valid to retain a successful capture even when a later backend emission
fails: `plan.json` is a separately authenticated successful frontend artifact,
while the overall run receipt correctly remains failed. A partial graph write
never receives a successful capture receipt.

Replay records zero executed Base/frontend time, `warmReplay:true`, the original
omitted preparation costs, and separate decode/lower/verify/render/write times.
These figures must not replace full source-to-executable timings. Adoption or a
cold-speed claim still needs ordinary fresh preparation and its existing gates.

Implementation and static Python syntax inspection are complete. No capture,
replay or compiler target was run by this tool's author; root owns execution and
must record transport equality, actual savings and resource costs.

## Binary transport after the first size refusal

The first actual capture, `selfhost/build/phase173/plan-capture-store03`, completed
Base preparation in0.801s and the full frontend in44.191s, then refused the
one-million-object JSON graph limit. Its guard measured1.20GiB peak process-tree
RSS. This is a transport-policy failure, not a compiler or semantic failure.
The failed receipt remains evidence; the original JSON adapter stays unchanged.

Simply raising the node limit is a poor first retry. At seven-digit references,
the existing graph format needs74bytes for a minimal `Con` object and160bytes for
a small `KTerm`, before each separating comma and any nonempty names. An
illustrative equal mix is roughly224MiB at2Mobjects and448MiB at4Mobjects.
These are sizing examples, **not measurements or upper bounds**: arbitrary string
payloads prevent a node-count-only byte bound.128MiB requires at most67bytes/object
for2Mobjects or34bytes/object for4M;512MiB allows268 or134bytes/object respectively.
JSON additionally materializes Maps, per-edge reference wrappers, entry arrays and
node objects. The failed1M-process RSS cannot safely be extrapolated as a
whole-process linear model because its already-live compiler/frontend heap is
unknown. Keep explicit byte and external RSS limits for any fallback attempt.

`selfhost/tests/phase173/plan-transport-probe.mjs` is a tiny generic transport
control:4,096 shared records, a valid16,384-node linked list, exact Unicode and
numeric fields, cycles, sharing and independent fresh decodes. It imports no
compiler and checks the complete object graph iteratively, avoiding recursive
assertion-library stack limits. Root runs it through the ordinary guard before
another full capture. It tests both `bun:jsc` and Bun's `node:v8` entry point,
plus a JSON reference. The probe does not establish actual-plan transport
correctness or a performance benefit by itself.

The primary Bun documentation describes
[`bun:jsc.serialize`](https://bun.sh/reference/bun/jsc/serialize) with
`binaryType:'nodebuffer'` and
[`deserialize`](https://bun.com/reference/bun/jsc/deserialize) as native
structured-clone transport. Bun's
[`node:v8` documentation](https://bun.sh/reference/node/v8) explicitly says its
wire format is JavaScriptCore's, not Node/V8's. The separate
`selfhost/tests/phase173/plan-replay-binary.mjs` therefore uses the explicit
`bun:jsc` interface and accepts only the exact pinned Bun executable.

The binary adapter retains all source/Base/carrier/stamp/checked-API/frontend and
acquisition-boundary authentication. It saves the complete `P86Plan`, adds an
explicit codec tag, verifies artifact byte length and SHA256 before replay, and
freshly decodes on each use. It does not count or materialize per-object JSON
wrappers. `--graph-mib` still defaults to128MiB and permits at most512MiB; the
process guard bounds peak native serialization/deserialization memory. Use its
same `capture`, `capture-emit` and `replay` modes, omitting `--node-limit`.

After the tiny probe passes, the decisive first gate remains **same checked API,
same actual source, complete decoded-plan emission, byte-identical QBE against
the existing independent ordinary request**. New backend candidates still need
their own semantic/native gates. All accounting remains explicitly warm replay;
the binary artifact is neither a cold-build speedup nor a portable compiler IR.
