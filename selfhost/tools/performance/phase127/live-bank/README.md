# Experimental divmod transport certificate repair

This overlay adds only `p126_rt_nat_divmod` to `p118z_runtime`. The ordinary
verifier, runtime, ownership rules, transition rules and installed selections
remain unchanged. `p125_rt_concat_typed` is deliberately excluded pending a
separate contract audit. The existing divmod and application controls are
reused byte-for-byte.

The rationale and independent pointer-safety audit are in
[live-bank-audit.md](../../../../../implementation/phase127/live-bank-audit.md).
Source32 globally refuses live-bank transport when one formatting worker uses
the verified divmod helper. This is a causal experiment, not a new backend or a
raw descriptor-bit mutation.

`prepare.py` requires the exact Phase126 source32 and reviewed runtime SHA256.
It permits one declaration replacement plus fresh controls, and proves inverse
reconstruction of every original source byte. It does not check Bend or run a
target. The first prepared source is `selfhost/build/phase127/live-bank-source01`.

```sh
python3 -B selfhost/tools/performance/phase127/live-bank/prepare.py \
  --out selfhost/build/phase127/live-bank-source01
```

Root-owned serial validation commands, with fresh output paths:

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase127/live-bank-api-replay-guard --seconds 90 \
  --rss-mib 4096 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase111/check-api.py \
  --source selfhost/build/phase127/live-bank-source01/compiler.bend \
  --out selfhost/build/phase111/p127-live-bank-api-replay \
  p88_cache_prepare p86_prepare p86_plan p111_runtime_admission \
  p111_emit_admitted p111_compile_source p127lb_controls \
  p118z_controls p126dp_controls p126dp_app_controls

python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase127/live-bank-finite01-guard --seconds 60 \
  --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  node --stack-size=8192 \
  selfhost/tools/performance/phase127/live-bank/finite.mjs \
  selfhost/build/phase111/p127-live-bank-api-replay/report.json \
  selfhost/build/phase127/live-bank-finite01
```

The retained successful acquisition is `p127-live-bank-api03`; two earlier
2GiB guard stops demonstrate why the replay uses4GiB. Use fresh paths for every
replay, including the finite runner and source materialization.

The 49 predicates are 20 new transport/ABI controls, eight original transport
controls, 16 original divmod controls and five original application controls.
Malformed IR is inspected as data; it is never executed as machine code. The
new controls include unknown symbols, incorrect argument/result types, short
or missing buffers, state aliases/offsets, null output and use before allocation.
The runner binds the checked API to the exact experimental source manifest.

Next emit a small retained case such as tree-bitonic through the repaired
checked API using `phase118/emit-integrated.mjs`, explicitly selecting
`P118_RUNTIME_REPORT=selfhost/build/phase126/runtime-divmod01/report.json`.
Use the same frozen case manifest, source, compiler settings and independent
oracles as Phase126. Before executing anything, compare its QBE against
`selfhost/build/phase126/final32-emission.json`:

```sh
python3 -B selfhost/tools/performance/phase127/live-bank/compare.py \
  --before ORIGINAL_PHASE126_CASE.ssa --after REPAIRED_CASE.ssa \
  --out selfhost/build/phase127/live-bank-case-comparison01.json
```

This read-only comparison requires every byte to match except the single
descriptor's capability value becoming `old | 4`. An unchanged descriptor or
any other difference fails and is preserved. A repaired certificate can still
fail for another independent reason; investigate that refusal rather than
forcing the flag. Only after the small semantic and timing tests should a
full-compiler experiment be considered.

For a causal **same-source compiler executable** comparison, use the repaired
checked API to compile the unchanged Phase126 source32. This should preserve
its instructions while admitting the live bank; compare its complete QBE with
the pinned Phase126 full emission before a normal aligned machine build.
The existing checked request-bound hosted emitter supports that request:

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase127/live-bank-same-source-guard --seconds 1230 \
  --rss-mib 6144 --available-mib 16384 --file-mib 128 --cpu 3 -- \
  selfhost/.bootstrap/bun-1.4.3/bun \
  selfhost/tools/performance/phase118/native-hosted-v2.mjs \
  selfhost/build/phase111/p127-live-bank-api-replay/api.mjs \
  selfhost/build/phase126/observer-divmod-source32/compiler.bend \
  selfhost/build/phase111/p127-live-bank-same-source-emit cache array
```

That image still contains the original compiler source and its original
whitelist; the **producer** of the image was repaired. It isolates the runtime
effect of live-bank admission, not adoption of the new compiler source.

An existing qualified N1 can also compile the repaired source as a distinct
native request, after the checks above. This is the command, not a request to
launch a full qualification campaign:

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase127/live-bank-source-native-guard --seconds 1230 \
  --rss-mib 6144 --available-mib 16384 --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase125/native/native-emit.py \
  --image selfhost/build/phase111/p126-native32-n1/program \
  --source selfhost/build/phase127/live-bank-source01/compiler.bend \
  --out selfhost/build/phase111/p127-live-bank-source-native \
  --mode cache --seconds 1200
```

The old N1 still applies its old whitelist while producing this output. The
new source policy takes effect when a subsequently built repaired compiler
executes another request. Do not confuse these two experiments or report
preparation/checking alone as native qualification. Keep all qualified images
and independent output gates intact; no installed promotion is part of this
overlay.
