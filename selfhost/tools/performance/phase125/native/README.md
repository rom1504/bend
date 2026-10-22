# Phase125 native checkpoint preparation

Source-only preparation at HEAD `06dea60`. No compiler/API/native target was run
by this preparation, and no existing evidence was deleted or changed. The
candidate at preparation time was Phase124 `ready-source02`, SHA256
`0b3d94f75cee1390299fdeb8f8af7d3bd3d79cfe8be72408bdd7c83315390663`.
Its exact Phase118 composition/native-entry contract replay passes. Its current
four-export API lacks `p86_prepare` and `p111_compile_source`.

## Root execution

Run from the repository root. All target commands belong in the root's serial
CPU3 guard. Substitute the final **frozen** source/API/runtime/ABI receipt paths;
the scripts never choose a different source or runtime after a failure.

Acquire a fresh six-export API using the existing checked-source tool:

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase125/native-api01-guard --seconds 180 \
  --rss-mib 6144 --available-mib 16384 --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase111/check-api.py \
  --source SOURCE --out selfhost/build/phase111/p125-native-api01 \
  p88_cache_prepare p86_prepare p86_plan p111_runtime_admission \
  p111_emit_admitted p111_compile_source
```

Prepare the qualification plan (this command is data-only):

```sh
python3 -B selfhost/tools/performance/phase125/native/plan.py prepare \
  --source SOURCE --api selfhost/build/phase111/p125-native-api01/api.mjs \
  --runtime RUNTIME --abi-receipt ABI_RECEIPT \
  --tag p125-native01 --rss-mib 6144 \
  --out selfhost/build/phase125/native01-plan.json
```

`--abi-receipt` may be omitted only for the exact qualified Phase118 runtime
object. For a changed runtime it must have kind
`phase125-native-runtime-abi-admission`, `complete: true`, exact `source`,
`runtime`, and `runtimeSource` pins, a nonempty `imports` list with unique
`symbol` fields, and `inputs` binding the checked import/declaration/implementation
authority. The plan authenticates every nested file pin and matches the runtime
source to its completed build receipt. This records the producer's explicit ABI
admission; symbol presence or successful linking cannot substitute for it.

Execute exactly the resulting `rootGuardCommand` array. It contains the existing
serial `phase113/run-jobs.py` supervisor and these eight jobs:

1. Re-authenticate the frozen plan and all inputs.
2. Unchanged `phase118/native-hosted-v2.mjs`: complete source check, runtime
   admission, request-bound integrated lowering/verifying/emission.
3. Build N1 using `phase123/build-aligned.py`.
4. N1 original focused19: 16 exact positive outputs and the three original
   type/affine/foreign-stage refusals.
5. N1 checks/compiles the identical source through its ordinary native bridge;
   raw stdout becomes QBE, then the aligned builder produces N2.
6. Authenticate actual source/API/runtime/Base/cache/product/image lineage and
   compare hosted and native QBE byte-for-byte, without normalization.
7. N2 original focused19.
8. N2 original full45, with its original sources and complete-output oracles.

Each QBE product is assembled with exactly
`as -mbranches-within-32B-boundaries`. The N1/N2 comparison and coverage wrappers
also check this option in completed build receipts. The full45 wrapper first
authenticates its frozen original supervisor binding, then uses the separately
pinned aligned derivative. `derivation01.json` records the original/new methods
and narrow edits; `review01.json` records offline checks. The original native
compiler's source/runtime/IR verification remains active. There is no N2→N3,
ELF fixed-point, installed selection, or promotion claim.

After **all** qualification jobs succeed, prepare matched compiler requests:

```sh
python3 -B selfhost/tools/performance/phase125/native/timing-plan.py \
  --plan selfhost/build/phase125/native01-plan.json \
  --tag p125-native01-transport --repeat-phase118 \
  --out selfhost/build/phase125/native01-transport-manifest.json
```

Execute the resulting `*-jobs.json` using the same CPU3/6GiB/16GiB/128MiB outer
guard and serial supervisor. The three frozen lexer/closure/map requests, exact
outputs, three rotated rounds, tools, Base/cache and clocks are unchanged.
Native request time includes input reads, checking/compilation, stdout and exit;
ready-executable time also includes fresh QBE/as/link. Upstream emits C and
recompiles its runtime through Clang. This is a comparison of those workflows,
not same-format backend throughput. The optional Phase118 repeat uses the old
qualified images/runtime but aligns their newly emitted products identically;
it is a separate sequential block, not interleaved across Phase118/125. The old
compiler images retain their historical acquisition policy.

Do not substitute old `native-plan-v2.py` wholesale: it invokes the unaligned
builder. Old native coverage, native-emission build integration and timing
runner have the same issue; old comparison also rejects the aligned build kind.
These adapters preserve the old gates while making the selected build policy
explicit.

## Resources and storage

The last complete Phase118 chain took 1286 seconds and peaked at approximately
5.385 GiB process-tree RSS. Hosted emission took 701 seconds; native self-emission
took 407 seconds. A 6 GiB ceiling with 16 GiB available-memory floor therefore
has about 0.615 GiB historical margin, not a proof that Phase125 will fit.
Old raw QBE was 85,831,654 bytes and assembly 63,190,018 bytes. The 128 MiB file
cap admits those outputs with headroom; do not silently increase it on failure.

The old fresh hosted/N1/self/N1-focused/N2-focused/full45 products occupied
440,029,184 allocated bytes (about 420 MiB) before deduplication. A three-role
timing block used another 26 MiB. Reserve roughly 450–550 MiB for the new chain
and small receipts; this is a planning range, not an upper bound. The guard
requires more than 416 MiB free at startup (`160 + 2*128` MiB), so a checkpoint
can fit on disk yet leave too little space to start the next guarded block.

The three exact Phase118 duplicate pairs are recorded in `dedup-plan01.json`:
hosted/self QBE, N1/N2 assembly, and N1/N2 object. They initially offered
167,768,064 allocated bytes (160 MiB). At this file's final read-only validation
all three already shared their keeper inode (`nlink=2`), so **additional savings
are zero**. Do not count that recovery twice. Older Phase112/114 pairs were
already hardlinked too. No additional unowned/failure artifacts are proposed
for removal or archival. New hosted/native duplicate products can be considered
only after authenticated byte equality, preserving every path and byte and
keeping an explicit dedup receipt. No deduplication was performed by this agent.

## Bounded scalability audit

* Phase121 `fusion03.bend` adds recognition inside the existing candidate walk,
  with 2048 syntax-node/64-depth admission budgets and arity ≤8. Callback source
  inspection is bounded to two/three parameters. One residual boundary is
  `p121f_children`: it recursively materializes a whole child list before the
  next fuel test. A very wide reflected node can exceed the nominal fuel's
  transient allocation/stack bound. No actual compiler failure was observed;
  ordinary syntax child counts are small. The surrounding candidate-list walk
  predates Phase121 and already passed Phase118 full self-compilation.
* Phase123 `predicate/model02.bend` updates epoch/key facts in existing range
  scans; expensive lookups are lazy, with depth-32 index operations. This adds
  per-statement records and string keys, not a new unconditional whole-program
  pass. `scaled-address02.bend` recognizes a fixed local expression. Full-image
  allocation/RSS cost remains unmeasured by the two small hosted cost cases.
* Phase124 `ready-call/model.bend` keeps direct→old H→R→G precedence and attempts
  extended H only on the residual path. It constructs the immutable
  ready/direct view once. `p124r_public_chunks` is a direct self-tail traversal
  and the checked JS API emits it as a loop. Extended H retains arity 1–8,
  incoming 0/result 1/flags 0, body size ≤512, namespace and capture limits.
  Residual candidates can incur another bounded body/continuation scan; the
  scan/fact/text allocation cost may accumulate across tens of thousands of
  segments. No new unbounded global traversal was found in this bounded audit.

The first full hosted stage is the useful scale gate: preserve its exact stage
receipt and memory/error stack if it fails. Then native self-emission tests the
same new traversals under native ownership and stack behavior. Existing small
hosted cost neutrality does not establish either full-image result.
