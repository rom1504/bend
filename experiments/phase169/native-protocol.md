# Native runtime-admission diagnostic compatibility

Optional source-only successor; no target execution or promotion is claimed.
The maintained negative-foreign oracle expects `compile: ` before the unchanged
runtime-admission error. The experimental native route previously inherited the
hosted API's `adapter renderer runtime: ` prefix.

[`native-protocol.bend`](../../selfhost/tests/phase169/native-protocol.bend)
overrides only `p169n_prepared`. It passes preparation failures through unchanged,
runs `p86_plan` once and routes its result through `p169np_plan`. Plan failures
remain byte-identical. A successful plan runs `p111_runtime_admission` once;
failure becomes `compile: ` plus that error, while success calls the existing
`p169s_lowered(request, p168_request_mode(1,request))` once. There is no string
replacement, duplicate frontend check or additional lowering. Source checking,
single-verifier admission and streaming are unchanged.

The existing `p169s_plan` and its hosted error contract are not modified.
Eight finite controls check preparation and parse/check/compile errors, a
diagnostic containing the old prefix as ordinary text, the actual missing-provider
admission, unchanged hosted error text, and first unavailable provider ordering.
All failure observations require an empty prefix and ended cursor. Complete
successful emission must also be compared through the real checked frontend;
these negative controls do not establish that result.

Independent source reviews by the sampling and code-shape lanes found no blocker
in the entry change, control scope or versioned preparation. Those reviews
confirm source composition only; they do not replace the pending target gates.

## Frozen source preparation

[`prepare-native-variants-v4.py`](tools/prepare-native-variants-v4.py) authenticates
and imports exact v3, SHA256
`54384f55f7ee9c9e657e853e8eae55a39d3c9e79f50f86168e8763540b04f9f0`.
It reuses v3's parser, modules, original reference checks and extraction logic.
Its local subprocess adapter extends only the metadata-extractor command with
the optional module and API exports. The ordinary extractor still enforces
protected declarations and authenticated override rules. Both command forms and
method pins are recorded; no consumed predecessor is rewritten.

Preparation completed without running a compiler:

```sh
taskset -c 0 python3 -B experiments/phase169/tools/prepare-native-variants-v4.py \
  --api --publication --admission --lazy --single-verify --native-protocol \
  --out selfhost/build/phase169/native-protocol-api-source01

taskset -c 0 python3 -B experiments/phase169/tools/prepare-native-variants-v4.py \
  --publication --admission --lazy --single-verify --native-protocol \
  --out selfhost/build/phase169/native-protocol-source01
```

| Prepared source | Bytes | SHA256 |
|---|---:|---|
| API source01 | 1,641,259 | `3fd47640b982c1afa9677c35cfd012a8ede85c364f0a0e3a71e4759d1ce33749` |
| Native source01 | 1,509,589 | `ed10e79dfe8fd60af969e68b671c3ab0fb864f181cfb428cda3245b096f60b60` |

Each manifest's 42 input pins were verified after extraction. Compared with
`single-verify-native-source01`, the sole changed retained declaration is
`p169n_prepared`; two new helpers replace the now-unreachable `p169s_plan` and
`p169s_admitted` in the main-only dependency closure. API extraction retains
those old exports. This is dependency pruning, not a mutation of their source.

Root-owned execution gates: source-check/acquire the API with its explicit
`exports.json`, run
`bun experiments/phase169/tools/native-protocol-controls.mjs API_REPORT FRESH_OUT`,
then check complete successful output and the maintained native negative-foreign
oracle through the new actual image. Existing live/cache/source-error controls
remain applicable. No current image receipt is relabeled to claim this source.

## Preserved first API failure and fixture-only successor

The parent's first API source check rejected the unannotated local `book` in
`p169npc_request`; the compiler could not infer the fixture list's type. The
failed source and all consumed methods remain unchanged. New
`native-protocol-controls-v2.bend` adds exactly `: List<&2,KDef>` to that binding,
with no changed control expectation or compiler implementation.

[`prepare-native-variants-v5.py`](tools/prepare-native-variants-v5.py) reuses exact
v4/v3 preparation, authenticates the annotation-only inverse and substitutes the
new fixture in the recorded metadata-extractor command. Prepared API source02 is
1,641,275 bytes, SHA256
`2ee4f8c97eeaeaa2e87a759d322a3f2723c2833ee1f40d56ee7960e485bfe69f`.
Only `p169npc_request` differs from API source01; all 45 input pins verify.
The native source remains exact `ed10e79d…` because controls are absent from its
main-only closure; it was not regenerated.

```sh
taskset -c 0 python3 -B experiments/phase169/tools/prepare-native-variants-v5.py \
  --api --publication --admission --lazy --single-verify --native-protocol \
  --out selfhost/build/phase169/native-protocol-api-source02
```

This preparation runs no compiler. Source admission and observed control results
must come from the parent's fresh execution gate.
