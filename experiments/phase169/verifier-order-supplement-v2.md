# Supplemental error-order controls: source correction

The v1 source acquisition failed checking because local message literals in
`p169svo_expected` lacked explicit types. The v1 module, preparer, source snapshot
and failure evidence are retained. No candidate compiler implementation changed.

`selfhost/tests/phase169/verifier-order-controls-v2.bend` adds `: String` to the
six local message constants (`body`, `abi`, `projection`, `private`, `forward`,
`prefix`). All fixtures, verifier calls, error expectations and exported
signatures are unchanged. The new `tools/prepare-verifier-order-v2.py` reads this
module against the same exact frozen parent and permits no overrides.

Prepared source: `selfhost/build/phase169/verifier-order-source02/compiler.bend`,
1,519,797 bytes, 4,473 declarations, SHA256
`eb179eadb492e1d33a7d7f416e36993f2ab8139766c25c923905665f4a694c52`.
Preparation executed no compiler or generated target. Root must perform the
checked acquisition before running the unchanged literal-oracle harness:

```sh
selfhost/.assets/bin/bun experiments/phase169/tools/verifier-order-controls-v1.mjs CHECKED_API_REPORT selfhost/build/phase169/verifier-order-source02/manifest.json FRESH_OUT
```

The six controls and their scope are described in
[the original supplement](verifier-order-supplement-v1.md). Its native-entry
discussion concerns the argument shape; the separate
[native protocol correction](native-protocol.md) addresses runtime-error prefix
compatibility.
