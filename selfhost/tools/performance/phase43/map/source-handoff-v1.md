# Actual Map source qualification handoff

`fixture-catalog-v1.json` pins minimal fresh scalar roots and renamed equivalent.
Both return `(seed+2) >>> 0`; catalog seed0xffffffff independently expects1.
Public full-value `fixture.bend` remains separate; no optimizer permits data roots.

Root runs these serially, under bounded supervision, with fresh output paths:

```sh
NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
"$NODE" selfhost/tools/performance/phase43/map/trace-instances-v1.mjs \
 "$CHECKED_ATTEMPT" selfhost/tools/performance/phase43/map/scalar-fixture.bend \
 p43.map.scalar "$FRESH_QUICK_TRACE" quick
"$NODE" selfhost/tools/performance/phase43/map/trace-instances-v1.mjs \
 "$CHECKED_ATTEMPT" selfhost/tools/performance/phase43/map/scalar-fixture.bend \
 p43.map.scalar "$FRESH_FULL_TRACE" full
python3 selfhost/tools/performance/programs/prepare.py \
 --attempt "$CHECKED_ATTEMPT" --role candidate \
 --catalog selfhost/tools/performance/phase43/map/fixture-catalog-v1.json \
 --set full --out "$FRESH_PREPARATION" --node "$NODE" --cpu 3
```

Quick trace intercepts library emission before planner contexts and stops after
root gates/collection; full additionally serializes exact replay, rewrite, JPure,
worker caps and final root emission. Both consume checked attempt/API/runtime/Base
identities and preserve an overlay, never install a compiler or rewrite a flag.
A report is saved before each potentially expensive stage, so root's30s/source
limit can identify the interrupted stage. Neither was target-executed by Map owner.

Source05 is review-approved for bounded experimentation only. Apply
`annotation-v1.patch` to the experimental production source before rebuilding:
it annotates the sole local KDef constructor binding, preserving semantics.
Actual private lexical workers, correct live erased-slot mapping, entry activation,
full values/aliases/refusals/native hooks/errors/deep behavior and checked emission
receipts remain root qualification requirements. Saved-JS15/259 controls do not
establish any of these compiler admission claims.
