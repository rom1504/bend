# Bounded optimizer policy experiments

[Design](../../../../design/phase115/reusable-plans-and-policy-search.md) ·
[Report](../../../../implementation/phase115/README.md) ·
[Data](../../../../implementation/phase115/results.json).

`plans.bend` holds all compiler logic: immutable alternative planning and four
legal emission policies. `negative-decision.bend` is the smaller 17-added-line
candidate that preserves current precedence and avoids retrying rejected H.
Neither changes installed selection. Python/JS authenticate and transport files,
call checked Bend exports, measure, and select policy IDs from recorded costs.

Authoritative experiment: source 04/API04, manifest03, replay-v3/run-set-v3,
`phase115/matrix03`, builds 01, `phase112/p115-runtime01`, and negative-replay01.
The final replay reuses exact matrix02 machine products after full-QBE equality.
Earlier versions retain the rejected attempts and the comparator correction; do not use
the old array-renderer adapter as the current recipe.

Given the pinned original build assets, prepare the append-only experimental
source with `prepare.py --out selfhost/build/phase115/FRESH_SOURCE`, then use the
unchanged Phase111 `check-api.py` with exports shown in the retained API04 receipt.
The checked source needs Base as in existing Phase111/114 recipes. Freeze fresh
source/API identities before using the replay; never replace an artifact behind
an existing manifest. The negative overlay uses `prepare-negative.py` and has
an intentionally fixed fresh destination, whose manifest records its exact diff.

Example reproduction with existing authenticated API/manifest and fresh output:

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase115/replay-user01-guard \
  --seconds 160 --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  selfhost/.bootstrap/bun-1.4.3/bun \
    selfhost/tools/performance/phase115/replay-v3.mjs \
    tree-bitonic selfhost/build/phase115/replay-user01
```

`qualify.py` authenticates complete policy replay and builds distinct QBE only
once through unchanged Phase111 build.py. It constructs an explicit adapter
binding for unchanged Phase112 benchmark45/run.py. The original benchmark,
profile, repetition counts and complete-output checks are not edited. Fresh
build tags/destinations are required for another acquisition; existing recorded
builds are immutable. Original source/expected outputs and qualified reference
API remain independent of the experimental planners.

`summarize.py` reads receipts and recomputes medians and the predeclared training
selection rules. It runs no compiler. `evidence/seal.py` applies the SHA-pinned
original bounded evidence gate to Phase115 and p115-* build scopes. Only exact
receipt captures are restorable; compiler/API/machine products remain external
local dependencies, with recipes and identities retained.
