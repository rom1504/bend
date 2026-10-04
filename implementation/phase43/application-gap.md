# Selected14 application gap: static followup

Evidence: `selfhost/build/phase43/integration01/runtime-batch1/report.json`, five balanced fresh-process rounds, Node v24.18.0, CPU 3, 3 calls / 1000 ms warmup, 300 ms target. This followup only reads source, emitted modules and existing reports; it does not execute targets or establish a causal speedup.

| `main.out` | Candidate median | TS median | Candidate / TS | Baseline / candidate |
|---|---:|---:|---:|---:|
| test-morning-program | 210.026 µs | 3.377 µs | 62.19× | 1.020× |
| test-rle-roundtrip | 40.548 µs | 0.587456 µs | 69.02× | 0.98565× |

These are warmed execution times. Import and first call are separately measured: candidate imports are roughly 20–25 ms and TS imports 1–3 ms, but neither contributes to the ratios. The timed worker invokes the exported function, checks its primitive result and updates a checksum ([execute.mjs](../../selfhost/tools/performance/programs/execute.mjs), lines 44–59 and 70–82). There is no separate serialization/readback traversal: morning returns a JS string; RLE returns a JS number. The candidate public wrapper still calls `get`/`call`/`force`, so runtime evaluation is included. Candidate morning half drift ranges approximately −29% to +53%; the ratio is a descriptive timing result with substantial drift, not an allocation measurement or a stable attribution to one mechanism.

## Decisive emitted differences

Both candidate roots are ordinary `fn(0, ...)`, with no entry proof. RLE initializes `regionProof=null` and contains the declaration of `regionProofOpen` but **no call sites** (candidate lines 106–121). Its direct `rle`, `expand` and digest bodies are present, but their call sites explicitly require a non-null inherited proof (lines 812, 816–819). `main.out` builds the six-element list and jumps to generic `go` (line 820). Thus emitted worker presence does not demonstrate execution through those workers. Scalar root capture currently requires positive arity ([region.bend](../../selfhost/src/back/js/region.bend), line 99); the morning String result also falls outside the scalar root type set (line 44).

TS RLE uses a fully saturated five-argument `rle.step`, direct tag/field matches and a tail loop for `rle` (TS lines 225–259). Candidate `rle.step` is a four-argument Fn returning a Bool matcher, and `rle` consumes its List and nested Tuple through successive matchers and partial applications (candidate lines 811–812). Generic evaluation copies or concatenates argument arrays, constructs partially bound Fn objects and repeatedly forces bounce/build messages (candidate lines 55–85). This is a concrete call/evaluation difference, not a proof of its cost share.

Morning likewise enters generic Map operations and then generic split/join (candidate lines 856–875). TS calls the same source Map algorithm directly (TS lines 245–246, 292–308), and directly calls split/join helpers (196–232). **Both** retain source higher-order split/join recursion: TS also constructs `run_clo` callbacks. The difference is direct JS invocation versus generic Fn/matcher/currying machinery, not simply the existence of closures.

Representation also differs: candidate List fields live in `a` arrays and Tuple uses nested two-element arrays (candidate `ctor`, lines 249–258); TS uses tagged records with named `head/tail` and `fst/snd` fields. Both still materialize the encoded list, expanded list and reversed list specified by the RLE source ([fixture](../../selfhost/tools/performance/phase37/fixtures-historical/test-rle-roundtrip.bend), lines 99–156). Candidate U32 arithmetic is already ordinary JS-number arithmetic. Candidate Nat is BigInt while TS Nat is checked JS number; RLE expansion uses `U32.to_nat`, so this is a narrower additional hypothesis, not an explanation for every operation.

## Smallest future falsifier

First instrument the existing emitted module, without granting proof or changing evaluation, to count ordinary `main.out`, generic application/forcing and private RLE/expand entries. Prediction: ordinary RLE `main.out` enters zero private structural workers. A positive private-entry count refutes the disconnected-entry explanation. Next compare three semantically controlled variants: unchanged generic entry; only public entry dispatch removed; one guarded enclosing direct component with the same fresh input construction, compression/reverse/expansion/digest and primitive readback. Keep post-import binding/descriptor/host-hook/error/reentry controls. This separates entry overhead from repeated generic graph execution; representation and Nat should be separate ablations. No caching the nullary result or constant-folding its fixture.

## Frozen identities

All hashes below are copied from existing reported receipts; no new hashing was run.

Selected14 source SHA256: `cb9fe4facc492b6d6ef46669c206c0a7747a10c1f0aad31cf0114df0b288b25a`; checked API: `222902e565253ae20c628301a9191c6d71e47b211f1dc463da4e8eb1b51c86eb`; runtime: `e62cf92d8b600fdc2eb44029b1945f288c81bf878931f883a1b6f4fb5774aaeb`; Base: `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661`.

Fixture paths are `selfhost/tools/performance/phase37/fixtures-historical/test-{morning-program,rle-roundtrip}.bend`. Their SHA256 values are respectively `9033897714291ea49c25046426457ff2753276466092ba71a4e40c1e2b48a04a` and `ce4083dab9a8022b2c8867a30802113735917229341cecb8ce18ff9ac2e33989`; unchanged upstream commit `018751270e800bc222a93dad7f257083ee53a5f7`.

Module prefix: `selfhost/build/phase43/integration01/runtime-batch1/modules/`.

| Program | Relative module path | Reported SHA256 |
|---|---|---|
| Morning candidate | `candidate/modules/test-morning-program.mjs` | `cd10c1447255274c61a2b3cdba140f066353b2bb6f00d9b6a1d9aa173a3aec5f` |
| Morning TS | `baseline/typescript/modules/faff88b122b84d0d18698210c66233cae52493e3cc68c92d95e0c639e20990ad.mjs` | `faff88b122b84d0d18698210c66233cae52493e3cc68c92d95e0c639e20990ad` |
| RLE candidate | `candidate/modules/test-rle-roundtrip.mjs` | `1b7eded608a9a2de95e342975f0285e997832f3e7c31f4674af7925a0394d5de` |
| RLE TS | `baseline/typescript/modules/f21a8eb4239ff0db7fbfda6121f24b04b48c5478fe6de5798660ca5b417c80a8.mjs` | `f21a8eb4239ff0db7fbfda6121f24b04b48c5478fe6de5798660ca5b417c80a8` |
