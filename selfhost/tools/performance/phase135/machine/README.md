# Phase135 framed machine-unit experiment

Initial audit at `17a9e43` on 2026-10-24. Input identities are in
`audit.json`. The root-owned experiments below subsequently checked the source
and small machine products. No production selection or frozen Phase132/134 tool
was changed.

**Use the sealed Bend cursor to announce complete emitted bundles, then hash
and build bounded groups while they stream. Do not recreate Phase132's whole
QBE scanner.** This is a backend cache and transport improvement; it does not
skip frontend, lowering, verification or rendering of unchanged functions.

## Actual existing boundary

The qualified Phase134 source is
`selfhost/build/phase134/verify-selected-source01/compiler.bend`, SHA256
`a00019246b5181b288ab4d3e09e616bd41415fe6381e89a96185c05efa19fb57`.
`P134EmissionPlan` is produced only after existing verification/admission.
`p134e_next` then renders a private/direct function, legacy worker, public
segment bundle, bounded data fragment, or main. Whole semantic state remains
retained; rendered text is released after consumption.

Important distinctions:

- `legacy_end` means an extra LF in the historical output protocol. It does
  **not** identify a compilation-unit boundary. Legacy workers all set it false;
  data declaration headers/fragments do too.
- A public bundle can contain several functions. `p124r_public_h/r/g/extended`
  (52804–52851) concatenate a public wrapper with private region/resume helpers.
  Splitting at every piece is valid only if the complete bundle stays together;
  reporting one piece as exactly one function would be false.
- `p113e_private` (45209), `p112w_private` (41996), `p113e_old_private` (45257), and
  `p126i_emit_one` (54505) produce complete private bundles. Data may span many
  pieces, but only `P134Data{Nil{},...}` closes its declaration.
- All emitted signatures in this source use scalar QBE types (`w`, `l`); there
  is no aggregate type-declaration prelude. Treat this as a pinned producer
  contract, not an assumption about future backends.
- `p111q_tables` (40871) retains the dispatch array, numeric function/constructor
  bindings, effect metadata and static-image references. It must remain current
  and complete. A generated segment is not dead merely because no direct call
  names it.

`frame-plan-v01.bend` adds bundle/data boundary metadata while delegating actual
bytes to the old cursor. It is now included in the independently checked
experimental source01/source02. Reconstructing each payload plus its legacy LF must reproduce the
original stream exactly. A native writer can use this metadata without parsing
QBE instructions or computing String lengths.

## Implemented boundary and transport

1. Add the boundary view to Bend, preserving the current plain writer/API.
   The new writer uses reserved comment markers only **between completed
   declarations**, or a separate metadata channel. Begin/end markers select
   monotonically numbered groups of roughly 1,000 complete function bundles;
   data declarations are a separate current-data group. Never split data or a
   public/private bundle. No per-character length pass in Bend.
2. The host performs byte transport only: recognize the narrow framing protocol,
   hash/write one current unit, and finalize its immutable receipt on end marker.
   Never scan `$` symbols or braces. A small bounded byte scanner must allow
   long data lines without retaining a whole line. A frame count/trailer plus
   successful compiler exit is required before publishing an executable.
3. A matching immutable unit object can be reused. Otherwise run pinned QBE and
   the established aligned assembler. Keep one writer and one controlled build
   lane initially; bounded backpressure prevents temporary unit files from
   accumulating while the compiler runs ahead. Delete transient unit text only
   after its object/receipt is complete, unless explicit reference retention is
   requested. Record total bytes read/hashed and peak retained temporary bytes.
4. Link ordered function groups, the main group and current data with the fixed
   runtime, preserving Phase132 `-no-pie`, branch-aligned assembly and disabled
   build-ID policy for the experiment. A second empty-cache build of the same
   partition is the independent machine reference.

A grouped unit is identified by role and order, but its cache admission uses
complete payload bytes, fixed compiler/QBE/as/link/runtime identities, target,
flags, framing/visibility policy and any copied type prelude. Do not key on the
whole source revision, which would invalidate every unit. Do not omit literal
FID/CID/static-pool words from the payload hash. Position shifts may cause
conservative misses; they are not permission to normalize constants.

QBE compiles each unit independently. Its call argument/result types and any
embedded numeric bindings are already in that input. A consumed current sealed
plan supplies the final cross-function correctness gate. The host must not
invent a source-level dependency analysis or skip this verifier. A per-unit
external signature ledger can be supplied by Bend if the first contract needs
it; recreating a whole-text reference census defeats this experiment.

## Closed-image visibility policy

Private QBE definitions are local ELF symbols. Public bundles may call private
workers in other groups, so splitting unchanged bytes and linking is insufficient.
Phase132 promotes only cross-unit private references after a full text scan.
We should avoid paying that scan again.

The cheapest **closed-image experimental** route is to globalize compiler-
generated defined symbols in the resulting objects with standard `objcopy`,
before caching. Enumerate defined ELF symbols, retain only the audited generated
namespaces and fixed descriptor/data names, never undefined/runtime/system or
assembler `.L` labels. This is a link-visibility action, not Bend semantic
lowering in Python. The approved experimental policy is implemented in `elf-v01.py`: allocated
bytes and logical relocations must remain exact after changing only those symbol
bindings. Every original exported name is retained, and the static executable is
not advertised as an ABI-compatible shared library. Compare symbol/relocation
inventory and monolithic semantic outputs before using it as a research image.

The alternative is a compiler-owned export flag propagated through all private
header emitters and the typed data emitter. There are 15 source sites constructing
`"function l $"` in the selected source. Several are reached through nested
region and array/observer code. Blindly prepending `export` to a public bundle
misses its internal private definitions; scanning/rebuilding each complete
String in Bend introduces avoidable O(output characters) allocation. A minimal
link-layer experiment is cheaper than this production refactor, and the small experiments below qualify that narrow closed-image mechanism.
The alternative export refactor remains unimplemented.

A useful first falsifier is one actual small program with a public wrapper,
private borrowed helper, recursive region and static data. Require cold
partitioned behavior to match independent monolithic output. Then change a
private body and rebuild from its current frames using the old cache. Require
positive object hits and exact equality with an independently cold current
partitioned image. Only after this works should a complete compiler edit pay
for another image campaign.

## Expected costs and honest ceilings

Phase132 measured 65 units: 19.85 seconds cold machine build, 5.98 seconds with
55 hits/10 misses after a real one-function compiler edit. Its 21–23-second full
text preparation erased the machine-stage benefit. Those are single historical
observations, not a forecast for this producer or a promised 70% full-loop gain.
The key hypothesis here is eliminating that separate whole-QBE scan, not making
QBE itself faster.

The original edit changed 476 generated functions and two data declarations;
377 function differences involved static pool words. No complete source
algorithm promises one edited function equals one rebuilt machine unit.
Streaming framing avoids the second full scan and can bound retained unit text,
but still renders/hashes all bytes. Avoiding those bytes requires a later exact
structured-unit and current-binding hit **before rendering**. The current inline
cache alone does not supply that output identity.

A clean cached/current-reference comparison checks ELF headers and every loaded
section's bytes, size, address and alignment (including BSS), plus symbol and
relocation obligations for globalized definitions. Partitioning can change code
layout versus monolithic QBE, so old compiled-program timing cannot simply
transfer. At minimum, run three compiler requests with full output oracles and
three ordinary generated programs before claiming a usable compiler image.
The previous Phase132 9-request/6-ordinary gates are a reusable stronger plan;
charge their measured cost separately from machine reuse. Full self-reproduction
is an integration gate, not required for the first small-program falsifier.

Risks to measure: extra invocations on tiny groups; duplicate global symbols;
object visibility and call relocations; altered instruction layout/alignment;
frame truncation or late compiler failure; cold acquisition overhead; hashing and
receipt verification; retained cache IR/RSS; and independently rebuilding the
reference. A verified cache hit is useful only when the whole edit loop improves.


## Evidence and current limits

- Source01, SHA `40b3e22c3a834e2a37b3c0b297d5458ff015c83cda4a8c72000ff2a0d7b0e572`, passed an independent source check, 121 finite controls and three complete
  frozen QBE byte bridges. The first bridge failed because its host adapter
  expected tagged Booleans; bridge-v02 corrected only that adapter, preserving
  the failed receipt.
- `selfhost/build/phase135/machine-smoke01/report.json` passed three families:
  lexer, closures and Map. Each had a cold, all-hit and independent cold machine
  build. Cached/current-cold loaded sections and ELF headers were identical;
  all three ordinary outputs matched independent monolithic references. The
  small cache contained three units per program, so this does not establish
  partial reuse after a source edit.
- Those frames came from the checked Bend cursor through a host test adapter.
  They qualify boundary/payload, symbol/globalization and object reuse; they
  do **not** qualify the native framed File writer or a full compiler edit.
- Source02, SHA `391a6f2dde2ef960a2d8b33a3100a0d9ba53ff68848a2279d502f7858019091c`, additionally records stage intervals. It passed independent source checking,
  the same 121 controls, and the preparation lane's real A/B output/cache/stats
  bridge plus three refusal cases. Native acquisition and FIFO checks are
  separate next gates.
- `machine-protocol-controls01.json` records 12 byte-framing/refusal controls;
  `machine-session-controls01.json` records 12 tests of the actual statistics
  admission parser. These are metadata tests, not compiler targets.

`session-build-v01.py` supervises one native producer and serial A/B consumers.
It opens private FIFOs in a fresh output directory, preserves all stderr and
statuses, and publishes a complete join only after native exit zero, both
machine receipts, immutable inputs and exact timing/statistics grammar pass.
The cache and output directories must be disjoint. Use the outer process-tree
resource guard; the internal deadline alone is not a memory bound. Premature
producer success without ever opening a FIFO is bounded by that deadline, not
currently detected immediately.

The object-stage receipts deliberately have `publishable:false` and
`producerStatusVerified:false`. They are not silently rewritten. The separate
joined report provides the successful-producer evidence. Its important fields
are `producer`, `sources`, `machineReports`, `producerExitCode`, `inputs`,
`stats`, and `complete`. Stage `render` includes FIFO backpressure and may overlap
machine work; do not add overlapping intervals as though they were exclusive
wall time.

## Root-owned execution recipe

First acquire source02 using the unchanged Phase134 pipe builder. Its output
must live under Phase134 because that tool enforces its historical path policy:

```sh
python3 -B selfhost/tools/performance/phase134/pipe/build-v02.py \
  --image selfhost/build/phase111/p134-selected-n2/program \
  --source selfhost/build/phase135/machine-source02/compiler.bend \
  --carrier-receipt selfhost/build/phase130/base-carrier01/receipt.json \
  --runtime selfhost/build/phase128/runtime-borrow01/runtime.o \
  --out selfhost/build/phase134/p135-machine-native01 --seconds 700
```

Run every command under the coordinated process-tree CPU/RSS guard. After the
image exists, first use `session-build-v01.py` with small existing A/B fixtures
and their independent ordinary QBE references. Then the actual compiler edit is:

```sh
python3 -B selfhost/tools/performance/phase135/machine/session-build-v01.py \
  --image selfhost/build/phase134/p135-machine-native01/program \
  --image-report selfhost/build/phase134/p135-machine-native01/report.json \
  --a selfhost/build/phase131/combined-literals-source01/compiler.bend \
  --b selfhost/build/phase132/source-edit01/compiler.bend \
  --runtime selfhost/build/phase128/runtime-borrow01/runtime.o \
  --carrier-receipt selfhost/build/phase130/base-carrier01/receipt.json \
  --out selfhost/build/phase135/machine-session01 \
  --cache selfhost/build/phase135/machine-cache01 \
  --expected-a selfhost/build/phase130/p131-final-self01/program.ssa \
  --expected-b selfhost/build/phase130/p132-edited-full01/program.ssa \
  --mode warm --retain-b --seconds 1100
```

Normal operation omits `--retain-b`: at most one current grouped IR file is
retained and deleted after object commit. This particular qualification
explicitly retains **all current B grouped IR** to rebuild the same B partition
with a distinct empty cache. That is a charged diagnostic exception, not a claim
of bounded total retained IR. `replay-v01.py --build .../machine-b/report.json`
streams those authenticated current groups; it never rediscovers boundaries or
rescans the previous monolith. Supervise both replay and machine child statuses,
then use `compare-v01.py` on cached/current-cold reports. The independent
monolithic compiler/ordinary gates live in `../validation/machine-gates-v01.py`.

The only expected incremental saving at this boundary is machine translation.
All current semantic preparation, final verification, rendering and payload
hashing are still paid. A high semantic-cache hit count or a high object-hit
count does not establish an end-to-end speedup.
