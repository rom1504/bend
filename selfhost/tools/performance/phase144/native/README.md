# Phase144 final native qualification

The final03 workflow is **closed and qualified** within [the published finite scope](../../../../../implementation/phase144/qualification.json). Only the root agent ran target commands, serially on CPU3; metadata preparation and sealing ran on CPU1. No installed compiler or default runtime changed. The commands below document the actual route; reproduction requires fresh output and guard paths.

`workflow-v03.py` accepts the selected source manifest, its independently checked API receipt, its actual 127-control receipt, and either qualified Phase143 native image as producer (default: N2). It reconstructs the explicit overlay; for the lexical predicate variant it also reruns the exact bounded source transformer. The protected verifier and 11 inherited proof declarations must retain exact bodies. The finite controls must consume the selected source/API, not a previous source version.

The actual selected source passed its independent check and 127 controls before preparation:

```sh
python3 -B selfhost/tools/performance/phase144/native/workflow-v03.py prepare \
  --manifest selfhost/build/phase144/predicate-canonical-source01/manifest.json \
  --checked-api selfhost/build/phase111/p144-integrated-api03/report.json \
  --controls selfhost/build/phase144/predicate-integrated-controls01/report.json \
  --label final03 \
  --out selfhost/build/phase144/final03-plan
```

The command is metadata only. Its `plan.json` contains six **complete outer-guard commands** in `jobs[].guardedCommand`; execute them in order, stopping at any nonzero exit. Each target has a fresh guard and fresh output directory. `jobs[].command` is only the inner command. The guard owns process-tree timeout, RSS, available-memory floor, file-size cap, and CPU affinity.

| Job | Producer and result | Required evidence |
| --- | --- | --- |
| `n1` | Qualified Phase143 N2 compiles S → Q1 → N1 | Exact checked S, retained full Q1, unchanged QBE/assembler/link tools, serial runtime object |
| `n2` | N1 compiles the same S → Q2 → N2 | Exact same source/Base/carrier and explicit serial link |
| `q3` | N2 compiles the same S → Q3 | Complete raw **Q2 = Q3** byte equality |
| `n1-focused19` | N1 compiles the frozen focused corpus | 16 exact independent stdout observations + 3 stage-specific refusals |
| `n2-focused19` | N2 compiles the same corpus | The same 19 obligations |
| `n2-full45` | N2 compiles all frozen ordinary sources | 45 exact independent stdout observations |

Q1 may differ from Q2: the selected compiler changes code generation. There is no requirement or claim that the old compiler produces identical code. Q3 is emitted and compared directly; an additional N3 executable is unnecessary for the stated N2 fixed point. Machine-object or ELF equality is not inferred from equal QBE.

The two native builds reuse `phase134/pipe/build-v02.py`: producer stdout is streamed into QBE, while the entire IR is retained for reproduction. The semantic gates reuse `phase125/native/coverage.py` and `full45.py`, with the candidate runtime passed explicitly and **without historical QBE references**. They compile with the actual native images and retain independent full stdout/refusal oracles. There is no hosted 45-program duplication.

The runtime is exactly `serial-rfc01/serial-rfc.o` (`2d078323…e493a3`), with its compilation/word controls and prior 61-program relink evidence bound. Actual N1/N2 linked-runtime identity comes from their native build receipts. The inherited `phase130/native-request.py` receipt's `runtime` field is future-build context; it is not evidence of the requesting executable's linked runtime. The qualifier explicitly uses the N2 link receipt for that authority.

A separate final-image smoke report binds NativeHost path/publish and batch/session behavior. Its root-only inner command (wrap in a fresh Phase111 guard, CPU3, 3GiB RSS, 16GiB available floor, 240s) is:

```sh
python3 -B selfhost/tools/performance/phase144/native/host-smokes-v03.py \
  --plan selfhost/build/phase144/final03-plan/plan.json \
  --revision-oracle selfhost/build/phase144/final03-hosted-b01/report.json \
  --out selfhost/build/phase144/final03-host-smokes02
```

It compiles one small checked source with N2 and links the exact serial object, then checks both path modes, Unicode publication/readback, `EEXIST` refusal without overwriting, and no leftover temporary publication file. It then runs the frozen four-job lexer batch and A/B lexer session with complete current-policy hosted QBE oracles from independently checked API03. The session/batch supervisors are exact documented derivatives that bind the actual linked runtime instead of the old contextual runtime. No performance claims follow from this smoke. These are distinct gates: successful batch/session output alone does not prove path/publish callback execution. The final seal command is:

```sh
python3 -B selfhost/tools/performance/phase144/native/seal-v02.py \
  --plan selfhost/build/phase144/final03-plan/plan.json \
  --host-smokes selfhost/build/phase144/final03-host-smokes02/report.json \
  --out selfhost/build/phase144/final03-qualification.json
```

The sealer rechecks source/runtime admission, all input/output identities, all six guards, full QBE reproduction, every semantic build and complete independent observation, and the separate smoke result. It writes `nativeQualified: true` only after all are present and pass. A failure is retained; it is not converted into a qualification by shortening the case list.

The admitted runtime policy is one Bend heap mutator, `--threads 1 --gpu off`, and the pinned provider table. Host IO workers still exist. This qualification does not extend to arbitrary C embedding, foreign callbacks, compute workers, GPU runtimes, all language conformance, mathematical correctness of the compiler, speed claims, or installed/default promotion.

The first v01 metadata preparation refused Python-tuple versus JSON-list equality before any plan or target was created. v02 normalizes only that metadata representation; full source byte equality remains required. The original method and exact one-edit derivation are preserved.

v03 also validates explicit canonical paths before projecting newer receipt pins to the inherited three-field file/size/hash identity. No file hash or real-path check is omitted.

The final `seal-v02.py` is an explicit successor of the consumed v03 seal function. It adds runtime prerequisite counts and exact source bindings, verifies the actual smoke methods and complete child observations, and freshly rehashes all retained inputs before writing the final receipt. The consumed plan and target commands remain unchanged.

The B hosted oracle is acquired only once, under a separate root guard. A is reused from the closed `predicate-byte-candidate01` lexer emission. B uses the frozen edited source bytes but the same logical A path:

```sh
selfhost/.bootstrap/bun-1.4.3/bun \
  selfhost/tools/performance/phase144/native/hosted-smoke-oracle-v01.mjs \
  selfhost/build/phase111/p144-integrated-api03/report.json \
  selfhost/build/phase144/predicate-canonical-source01/manifest.json \
  selfhost/build/phase88/broad-fixtures03/lexer.bend \
  selfhost/build/phase140/session-screen03/lexer-b.bend \
  selfhost/build/phase144/final03-hosted-b01
```

This is a two-fixture hosted differential oracle, not a redundant hosted ordinary45 run. The new append policy can change QBE legitimately, so the old Phase140 QBE remains historical evidence and is not used as the current smoke oracle. The frozen source edits, owner/hint/order, and independent ordinary-program stdout expectations do not change.

The initial final-image smoke01 retained a harness expectation failure: the provider correctly returned `EEXIST` and the fixture printed `17`, then `IO.pure(U32,1)` completed through `FID_IO_EMIT` with process status zero. Only `IO.die`/`Halt` requests a nonzero process exit. The independently reviewed v03 smoke and v02 sealer correct only this process-status oracle; exact refusal output, no overwrite, temporary-file cleanup and readback remain required. Earlier methods and the failed raw receipt remain unchanged. `final03-smoke-jobs02.json` contains the complete fresh outer-guard command.

Final publication is data-only via `publish-v01.py`: it projects the exact sealed raw receipt into the compact qualification and candidate records, verifies their displayed source/API/runtime/image/evidence identities, and keeps `incrementalQualified`, installed and default-selection flags false. Ordinary native qualification includes both focused19 suites and N2 ordinary45; the single A/B session and batch are supplemental finite smokes only.
