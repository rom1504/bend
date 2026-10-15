# Final compiler compilation-speed screen

Root-run method only. Preparation wrote these files and checked syntax; it did
not execute a compiler. The final image pins and admitted native selection must
exist before the input-only preflight can pass.

```sh
python3 -B selfhost/tools/performance/phase90/final-screen01/run.py \
  --b2-pins selfhost/build/phase90/compiler07-b2/image-pins.json \
  --native-admission selfhost/tools/performance/phase90/runtime-migration01/native-admission.json \
  --out selfhost/build/phase90/final-screen-preflight01 --check-only

python3 -B selfhost/tools/performance/phase90/final-screen01/run.py \
  --b2-pins selfhost/build/phase90/compiler07-b2/image-pins.json \
  --native-admission selfhost/tools/performance/phase90/runtime-migration01/native-admission.json \
  --out selfhost/build/phase90/final-screen01
```

The six fixed sources are Small, numeric_closed, lexer_original, map_closed,
functions65 and Unicode. One guarded setup process uses the exact final B2
and its checked snapshot driver to prepare that API's Base products and emit
six complete C oracles. This setup is reported separately. No source, compiler
algorithm, foreign permission or runtime byte is rewritten by this method.

The campaign then runs 36 fresh processes: two rounds × six sources × TS-Bun,
Node-hosted B2 and admitted native compiler. Role order rotates by source, then
reverses in round two. Every native/B2 output must equal the new B2 oracle in
full bytes. TS uses the unchanged Phase86 `reference.mjs` `typescript` role,
pinned Bun 1.4.3 and its own retained complete-C hashes from Phase88 screen01.
This measures compilation; it does not Clang-build or execute these C programs.

All jobs run serially on CPU3 with the existing process-tree guard, 2 GiB RSS
ceiling, 4 GiB available-memory floor and 30-second per-job deadline. Any process,
output, input-identity or clock failure stops the campaign and retains evidence.
The intended successful campaign is about a minute; this is a planning estimate,
not a measured duration or a whole-campaign deadline.

`report.json` retains both rounds, output identities, guards, per-case medians,
variation and equal-case geometric ratios. Keep these boundaries visible:

- TS performs ordinary source/Base loading, checking and emission inside its
  request clock. It has no separately prepared Base carrier.
- B2 uses an API-specific prepared Base file. Ordinary `inspect` includes cache
  decoding in its request clock. Initial Base preparation is a separate setup
  cost; no persistent inspector or previously warmed request process is used.
- Native loads its authenticated private carrier before the request clock.
  `base_prepare_ms` and `runtime_prepare_ms` are reported separately and remain
  included in process wall time.
- Process wall times include measurement-worker identity checks and output
  validation, so they are not production CLI startup timings. B2's input,
  output and final-validation costs are itemized in `workerValidationMs`.
- Full B2 provenance and selected native admission are checked at campaign
  boundaries. Timed jobs do not replay hundreds of historical receipts.

Fresh processes still share filesystem caches. Two rounds identify a large
regression or gain; this is a selected-workload performance/output screen, not
full conformance, statistical confidence or general compilation-speed parity.
