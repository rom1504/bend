# Small context-build tranche

[storage-proposal08.json](storage-proposal08.json) archives only the completed
assembly/object pairs from `context-value-baseline10` and
`context-value-native10`. Their exact allocations are 15.328125 and 15.34375 MiB:
**30.671875 MiB total**. Hashes/inodes match successful reports and sealed/completed
writers. No broad historical audit, target, capture or apply ran.

The **archive cap is 8 MiB per root**, allowing the first bounded capture with the
observed 13.19 MiB headroom above the 5 GiB reserve. Comparable machine captures
predict about **3.82 MiB archived total**, **26.85 MiB recovered**, and **40.05 MiB
headroom** afterward. The full two-root cap would leave about 27.86 MiB before
small receipts and filesystem effects. Measure actual space after each root.

Keep both executable programs, runtime, source/input evidence, all receipts,
logs and the completed diff09 evidence. In particular,
`context-value-baseline09/program.ssa` is a live input to the successful recovered
baseline10 build and **must remain hot**. N2 SSA is outside this proposal; it may
only move under a separate later exact selection. Native comparisons consume
binary/runtime/receipt/input identities rather than these generated machine
intermediates, as confirmed by the root coordinator and writer input arrays.

After active targets finish, root can capture the first pair:

```sh
python3 -B experiments/phase169/archive-selected-v02.py \
  --proposal experiments/phase173/storage-proposal08.json \
  --name p173-context-value-baseline10 \
  --out selfhost/build-retention/phase169/p173-context-value-baseline10
```

Inspect its exact plan, then separately apply:

```sh
python3 -B selfhost/tools/build-retention/archive-v02.py apply \
  --plan selfhost/build-retention/phase169/p173-context-value-baseline10/verified/plan.json \
  --out selfhost/build-retention/phase169/p173-context-value-baseline10/applied
```

Repeat for `p173-context-value-native10`, using the corresponding fresh capture
and apply paths. Enforce **5 GiB + 8 MiB before each capture**, because the frozen
helper itself permits only a 4 GiB floor. Preserve capsules, plans and journals
for exact maintained restoration; never reopen the existing sealed closures.
