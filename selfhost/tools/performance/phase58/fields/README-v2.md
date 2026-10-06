# Source-corrected field controls v2

V1 remains unchanged. Its baseline acquisition failed because duplicated
`shared(+value:P58Fields)` requires a Data type but the fixture declared Type.
No candidate emission or compiler-optimization failure was observed.
V2 changes only that declaration to Data, then binds its new source/catalog
identities in the successor controller. The other products remain Type because
they are not duplicated. All 17 observation groups and strict qualification,
private-copy provenance, syntax and partial-deferral gates remain intact.

Root-only serial commands from repository root, under the existing sole guard:

```sh
NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
$NODE --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase58/qualification/paired-fixtures-v2.mjs \
  selfhost/build/phase56/checked-string01 selfhost/build/phase58/checked-fields01 \
  selfhost/tools/performance/phase58/fields/catalog-v2.json \
  selfhost/build/phase58/fields-fixtures02
$NODE --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase58/fields/controls-v2.mjs \
  selfhost/build/phase58/fields-fixtures02/baseline/literal-fields.mjs \
  selfhost/build/phase58/fields-fixtures02/candidate/literal-fields.mjs \
  selfhost/build/phase58/fields-controls02
```

No targets executed by the producer. Source checking and generated observations
remain pending root's jobs. `fixture-v2-derivation.json` pins all before/after
bytes and the one-line source diff; it does not rewrite the failed receipt.
