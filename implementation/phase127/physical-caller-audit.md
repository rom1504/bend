# Exact physical caller attribution

The new bounded CFI collector confirms that Phase126's additional libc fill
work is physically called by `p111_rt_jump` and `p111_rt_return`. Phase125 has
no sampled fill work in these captures. This narrows the runtime path; it does
not yet measure the benefit of restoring live-register-bank admission.

The offline join verifies each original PC against its exact libc CFI interval,
checks object hashes and mappings, resolves `return_address - 1`, and verifies
the sampler/sidecar pairing against the frozen runner receipt. All **24 captures
have zero lost samples**, and all **612 eligible libc samples** produce resolved
physical callers. Unsupported PCs remain in the denominator.

| Request | Phase125 fill samples | Phase126 fill samples | Phase126 callers | Period-weighted fill share of all samples |
| --- | ---: | ---: | --- | ---: |
| lexer | 0 / 892 | 104 / 1005 | jump 55, return 49 | 10.11% |
| Map churn | 0 / 1188 | 172 / 1582 | return 87, jump 84, closure apply 1 | 10.67% |
| closures | 0 / 238 | 38 / 284 | jump 21, return 17 | 13.30% |

Memory-copy samples resolve almost exclusively to `p111_set_regs`: Phase125 has
145 such samples and Phase126 has 152, plus one Phase126 closure-apply sample.
Fill is therefore a distinct added instruction category, rather than unresolved
copy work being mislabeled as allocation or reclamation.

These are **physical** callers. Inlining or tail calls can hide intermediate
helpers such as `p111_set_regs`; this report does not reconstruct those frames.
Individual captures have fewer than 500 samples, and the pooled closure totals
also remain below 500. The evidence supports identifying recurring callers,
not precise confidence intervals or a causal saved-time estimate.

[The compact evidence manifest](physical-caller-summary.json) preserves raw
counts and actual-period-weighted shares, frozen source receipt and tool
identities. Full per-capture matrices and ordered events are under
`selfhost/build/phase127/physical-attribution02/`. The original tool version is
retained in its `methods/attribute.py` snapshot.

For example, reproduce one capture with:

```sh
python3 selfhost/tools/profiler/attribute.py \
  --analysis selfhost/build/phase127/physical02/001-sample-lexer-phase126/analysis.json \
  --callers selfhost/build/phase127/physical02/001-sample-lexer-phase126/callers.txt \
  --table selfhost/build/phase127/libc-unwind01/table.json \
  --owners selfhost/build/phase127/phase126-owners01.json \
  --out /tmp/bend-physical-attribution-fresh
```

Optional owner binding checks actual linked ELF segment-table pointers against
the owner map's FID sequence. The Phase126 control checked all **46,991 FIDs**
and found **60,253 matching function symbols**. Lexical ownership remains
conditional on the recorded emitter contract; this check proves dispatch
identity, not the compiler's complete producer lineage.
