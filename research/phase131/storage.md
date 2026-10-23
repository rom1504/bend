# Phase131 storage and native acquisition audit

Audit starts at `9f7ab43`, with 407MiB free on the build filesystem. Initial
investigation was read-only; the coordinator subsequently authorized applying
the exact proposal below. No compiler or generated program ran, no artifact path
or unique content was removed, and the installed selection was unchanged.

## Storage decision

Do not expect another large saving from the recent full compiler chains.
Phase128 and Phase130 already share their exact self-emitted QBE, and earlier
assembly/object deduplication preserved the corresponding paths. Matching
executable sizes are insufficient: Phase128 N1/N2 have different complete ELF
hashes. The 38,327,511-byte Phase98 `public-self02.c` matches an old request's
`program.1.c` byte-for-byte, but its mode is0600 versus0644; the existing policy
correctly excludes that pair.

The remaining economical scope is repeated generated benchmark output in closed
phases. A metadata-only scan of Phase1–62,67–75,77–93 and95–110 found2,305
same-size groups with1,667,100,672 allocated bytes in independent inodes.
That is a candidate ceiling, not an exact-duplicate claim. The largest useful
groups are typically repeated100–150KiB JS/C products, rather than large images.

[`storage-plan.py`](../../selfhost/tools/performance/phase131/storage-plan.py)
partitions those candidates by device, mode, uid/gid and extended attributes,
then requires both SHA256 equality and streamed byte equality. It proposes only
single-link destinations and stops after a bounded recovery target. It excludes
symlinks, toolchains, `.bend` source snapshots, JSON caches, runtimes, installed
images, and recent/current phase trees. Its output is compatible with the
existing Phase112 applier; **the planner never applies the proposal**.

```sh
taskset -c 1 python3 -B selfhost/tools/performance/phase131/storage-plan.py \
  --out selfhost/build/phase131/storage-proposal01.json --recovery-mib 800
```

The coordinating agent must review that proposal, recheck exact identities, and
use the existing atomic hardlink receipt workflow before counting recovered
space. Paths and contents must remain unchanged. Hardlinked artifacts must
never be edited in place; every future campaign needs fresh output paths.

The completed proposal contains386 groups and7,519 destinations, representing
**838,934,528 allocated bytes (800.07MiB)**. It read936,035,403 bytes for hashing
and took118.00s on CPU1; the additional equality reads are not included in that
hash-byte count. The3,987,036-byte proposal has SHA256
`124c6980d5e32cffd6b95baaa1d0d0268a46a3b2a6df6f40e31dd38bc58e0195`.
The proposal itself reclaimed nothing; the completed application below confirms
the recovery. No `node_modules`, `.bootstrap` or toolchain paths were selected.

The largest verified groups illustrate the scope:

| Keeper (under `selfhost/build/`) | File bytes | Duplicate destinations | Allocated recovery |
|---|---:|---:|---:|
| `phase5/equality-measurement/run-01/core-0-checked.mjs` |138,371|169|23,535,616|
| `phase90/final-screen01/1-numeric_closed-js-b2/numeric_closed.c` |114,791|170|20,193,280|
| `phase90/final-screen01/1-small-js-b2/small.c` |94,141|178|16,769,024|
| `phase90/final-screen01/1-unicode-js-b2/unicode.c` |93,828|176|16,580,608|

The Phase112 applier rewrites its growing whole JSON receipt after each
replacement. For7,519 paths, prefer the already-reviewed Phase130 application
workflow if it avoids this quadratic reporting overhead while preserving every
identity/equality check and the complete final receipt. Do not trade away the
checks merely to accelerate bookkeeping.

### Completed application and interrupted receipt

The coordinator began the original Phase112 applier. Its growing full-history
receipt became the bottleneck, so the coordinator interrupted **that owned
session only**, which returned exit130. The partial
`storage-recovered01/report.json` remains unchanged. Interrupting prevented its
final save; its last replacement was pending despite already having completed
the atomic path replacement.

The authorized successor,
[`storage-resume.py`](../../selfhost/tools/performance/phase131/storage-resume.py),
requires either a finished prior receipt or explicit coordinator termination
attestation. It retains the original Phase112 path, hash and identity checks,
authenticates the original proposal and method, and reconciles **every** proposed
destination with its actual original or keeper inode before making changes.
It writes a fresh remaining proposal, preserves all already-shared identities,
and appends pending/completed journal records rather than repeatedly rewriting
the complete history. A small summary is checkpointed every64 replacements.

The resumed run completed5,956 replacements in34.30s and reclaimed an additional
669,605,888 allocated bytes. The1,563 actual completed original replacements
account for169,328,640 bytes, including the69,632 bytes missing from the
interrupted summary counter. Total confirmed recovery is exactly
**838,934,528 bytes**, matching the original proposal. Free space after completion
was1,097.88MiB.

`selfhost/build/phase131/storage-completion-audit01.json` independently reconciles
all7,519 destinations with386 keeper hashes, size/mode/owner/xattrs, and every
pending/completed journal pair. It pins the original proposal, both application
receipts, remaining proposal, already-shared records, journal and exact successor
method. This audit performs no additional replacements. The final receipt is
`selfhost/build/phase131/storage-recovered02/report.json`.

```sh
taskset -c 1 python3 -B selfhost/tools/performance/phase131/storage-resume.py \
  --proposal selfhost/build/phase131/storage-proposal01.json \
  --previous-report selfhost/build/phase131/storage-recovered01/report.json \
  --previous-stopped-exit-code 130 \
  --out selfhost/build/phase131/storage-recovered02
```

The explicit exit-code argument records the coordinator's observed termination;
it must never be supplied while an earlier applier is still running. The fresh
output requirement means the completed command above is a provenance record,
not a command to rerun against its existing output directory.

## Cheapest correct native acquisition

For an analysis/transport change that is intended to preserve complete QBE,
replace the expensive full hosted emission with the already-qualified native
producer. Keep independent source checking and all actual native gates:

1. Freeze candidate source S, its composition manifest, the qualified producer,
   Base/carrier, runtime and machine tools. Independently check the complete
   source with `phase111/check-api.py`, which calls pinned upstream
   `book_valid`, rejects unresolved holes, and performs upstream ownership
   checking while acquiring the test API. Run the change's finite controls and
   small exact-QBE comparisons before paying for any full image.
2. Use qualified Phase130 N2 as **N0 for this campaign**. N0 compiles S into Q0;
   the standard QBE/as/link builder produces new N1 from Q0.
3. N1 compiles the exact same S, Base and carrier into Q1. Require complete raw
   `Q1 == Q0`, including native print newlines. Build N2 from Q1 with the same
   pinned runtime, machine tools and alignment flags.
4. Require focused19 on both new images:16 executions and3 expected refusals.
   Require ordinary45 on new N2 with the original independent output oracles.
   Preserve all original source/runtime/ownership admission obligations.
5. Bind this chain and every source/API/runtime/tool/output identity in a new
   Phase131 qualification receipt. Keep the previous qualified images and
   installed selection intact.

This establishes a chain rooted in an already-qualified native compiler; it
must not be described as a newly measured hosted→N1→N2 chain. Source checking is
independent of the candidate compiler, but finite exact-output tests are not a
proof that every source produces identical QBE.

For code-generation changes, Q0 and Q1 may legitimately differ: N0 compiles S
with the old strategy, whereas N1 uses the new strategy. Preserve that evidence,
build N2 from Q1, and require N2(S)=Q1 before claiming a stable QBE generation.
Do not suppress an unexpected mismatch merely by classifying it as codegen.

### Existing gate commands

These are command templates for the coordinator, **not executions performed by
this audit**. Each target command goes through the existing `phase111/guard.py`
with CPU3,16GiB available floor, explicit wall/file caps, and the justified RSS
limit. Full image jobs may use6GiB RSS; ordinary gates should use their smaller
established limit. Require at least1GiB free before starting the chain.

```sh
python3 -B selfhost/tools/performance/phase111/check-api.py \
  --source "$candidate_source" --out selfhost/build/phase111/p131-api01 \
  p88_cache_prepare p88_decode_admitted p86_prepare p86_plan \
  p111_runtime_admission p111_emit_admitted p111_compile_source

python3 -B selfhost/tools/performance/phase130/native-request.py \
  --image selfhost/build/phase111/p130-native01-n2/program \
  --source "$candidate_source" \
  --carrier-receipt selfhost/build/phase130/base-carrier01/receipt.json \
  --out selfhost/build/phase130/p131-n0-emit01 --seconds 600

python3 -B selfhost/tools/performance/phase123/build-aligned.py \
  --source selfhost/build/phase130/p131-n0-emit01/program.ssa \
  --runtime selfhost/build/phase128/runtime-borrow01/runtime.o \
  --out selfhost/build/phase111/p131-n1 --seconds 180

python3 -B selfhost/tools/performance/phase130/native-request.py \
  --image selfhost/build/phase111/p131-n1/program --source "$candidate_source" \
  --carrier-receipt selfhost/build/phase130/base-carrier01/receipt.json \
  --expected-qbe selfhost/build/phase130/p131-n0-emit01/program.ssa \
  --out selfhost/build/phase130/p131-n1-emit01 --seconds 600

python3 -B selfhost/tools/performance/phase123/build-aligned.py \
  --source selfhost/build/phase130/p131-n1-emit01/program.ssa \
  --runtime selfhost/build/phase128/runtime-borrow01/runtime.o \
  --out selfhost/build/phase111/p131-n2 --seconds 180

python3 -B selfhost/tools/performance/phase125/native/coverage.py \
  --image selfhost/build/phase111/p131-n1/program \
  --runtime selfhost/build/phase128/runtime-borrow01/runtime.o \
  --suite focused --mode cache --out selfhost/build/phase111/p131-n1-focused

python3 -B selfhost/tools/performance/phase125/native/coverage.py \
  --image selfhost/build/phase111/p131-n2/program \
  --runtime selfhost/build/phase128/runtime-borrow01/runtime.o \
  --suite focused --mode cache --out selfhost/build/phase111/p131-n2-focused

python3 -B selfhost/tools/performance/phase125/native/full45.py \
  --image selfhost/build/phase111/p131-n2/program \
  --runtime selfhost/build/phase128/runtime-borrow01/runtime.o \
  --partition all45 --mode cache --out selfhost/build/phase111/p131-n2-full45
```

Add candidate-specific finite controls to the checked API's exports. The
existing native request tool restricts outputs to Phase130, so the templates use
fresh `p131-*` directories there; an explicit Phase131 adapter may instead change
that path contract. The ordinary gates deliberately exercise the original
decimal carrier, while self-emission uses the authenticated compact carrier.

**One necessary new binder:** Phase130's `admit.py` permits only its specific
Base-decoder overrides, and `qualify.py` requires a hosted acquisition receipt.
Do not weaken those frozen tools or relabel an N0 receipt as hosted. A small
Phase131 binder must authenticate the current declaration diff and unchanged
runtime/verifier contracts, independent checked-source receipt, Phase130
qualification and exact N0 ELF, both native requests, both builds, and all three
semantic gates. It can reuse Phase128's offline `build`/`verify` helpers.

### Expected cost, distinguished from a measurement

Phase130's recorded full hosted acquisition was872.50 guarded seconds, near6GiB
RSS; same-source native self-emission was399.32 guarded seconds, near2.81GB.
Replacing one comparable hosted emission by N0 emission therefore offers about
473s of historical-cost headroom (~7.9min), before candidate effects and drift.
The complete new chain has two native emissions and retains checking/build/gate
costs; this is not a measured2× improvement in total qualification or research
throughput. Exact QBE makes repeated broad program-runtime timing unnecessary
for a pure compiler-cost change, but it does not waive native semantic gates.
