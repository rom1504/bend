# Phase194 generated-text retention proposal

**Prepared only. No archives, pruning or target jobs have run. Root chooses execution under the unchanged shared lock.**

Fourteen exact files occupy 649,965,568 allocated bytes (619.86 MiB). Estimated net recovery500–545MiB includes retaining a full30.4MB C restoration witness; compression has not been measured. The proposal is bounded to generated text, with existing native binaries/objects, profile sample payloads and all current baseline/installed products kept.

The first three independently archived roots contain30.4MB,32.0MB and38.6MB raw C. This keeps initial scratch below the available~0.1GiB margin. The method requires5GiB plus worst-case archive scratch; it cannot override a reserve refusal. Later94–106MB QBE streams are processed only after small batches release headroom.

The two profile stdout files are literal compiler-generated QBE text, separate from samples.txt and contexts/callers/analysis. Successful profile reports preserve the entire emitted-output hashes; new archives retain the actual bytes. No equal canonical hot stream is claimed. The64MiB Phase111 assembly is a failed/truncated QBE product with retained exit-25 report, so its negative evidence remains byte-exact in an archive. Depth-inline C catalogues document completed source transformations (targetsRun:false), not compiler execution qualification.

A bounded scan of 275 maintained tooling/selector/Phase189–194 driver files found no selected-root references. Historical replays may consume the generated paths and require restoration first. This does not prove absence of arbitrary dynamic readers; root confirms the lane and references before approval.

All listed input pins, installed selectors and retained profile associations are authenticated before and after. Every new capsule is reopened and fully hashed, exact selected-member sets are checked, and the first complete C file is restored to isolated retained scratch with hash/mode verification. Existing archive-v02.apply handles durable intent/journal and original-path deletion. Directories and historical receipts remain.

After root review:

```sh
python3 -B selfhost/tests/phase194/retention-method.py --approved-proposal-sha256 07803d8273b65d551b288fabeaa43fe1d1f393bb28e18fd314941af132aa88b5
```

Method SHA-256: `fe949af85800b937e1055a6bdddbc999ad2123458a2b1471837ff888ece899a4`. Syntax checked only. Exact paths, hashes, metadata, completion flags and keep lists are in `retention-plan.json`.

| Batch | MiB |
| --- | ---: |
| `phase103-cli06/image.1.c` | 29.00 |
| `consolidation-native-public-c02/program.1.c` | 30.53 |
| `phase90-js-self11/program.c` | 36.83 |
| `phase102-native-chain01-b1-self-execution/output.1.c` | 28.69 |
| `phase102-native-chain01-reference-execution/output.1.c` | 37.54 |
| `phase102-native-chain02-reference-execution/output.1.c` | 37.59 |
| `phase102-native-chain03-reference-execution/output.1.c` | 37.89 |
| `phase102-native-chain04-reference-execution/output.1.c` | 37.90 |
| `phase102-p144-integrated-upstream01/program.c` | 31.45 |
| `phase102-depth-inline-c01/compiler.c` | 28.69 |
| `phase102-depth-inline-logical-c01/compiler.c` | 28.69 |
| `phase111-full-native01/program.s` | 64.00 |
| `phase138-profile01-capture/000-sample-compiler-self-source-phase137-qualified-n3-context/stdout` | 100.98 |
| `phase169-native-n2-profile01/000-sample-canonical-compiler-n2-imports/stdout` | 90.08 |
