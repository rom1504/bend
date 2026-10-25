# Integrated hosted session screen

The checked API03 composition combines parser/checker checkpoints, owner annotation/erasure/raw products, optimizer/verifier reuse, registry planning and rendered-unit reuse. This test exercises the composition, not just the individual hit predicates. No installed compiler or native qualification is changed.

Actual report: `selfhost/build/phase140/session-screen01/report.json`; guard: `selfhost/build/phase140/session-screen01-guard/process.json`. The independent API receipt is `selfhost/build/phase111/p140-session-api03/report.json`. All source/tool/carrier/API inputs and source B edits are pinned in the report and rechecked after execution.

## Gates passed

- Complete old fresh A matches the existing frozen native QBE reference.
- Candidate cold A matches old fresh A byte for byte.
- Old fresh B differs from A, confirming a substantive executable edit.
- Candidate cold B, warm B and no-op B each match old fresh B byte for byte.
- Complete frontend `P86Plan` graphs match original cold A and edited B, including annotated/erased requests and metadata.
- Actual type and parse failures match original diagnostics and retain the previous successful compiler cache. A subsequent valid changed source recovers and matches a fresh complete output.
- All seven checked owner-cut controls pass.

## Whole-request observations

| Changed program | Original fresh B | Candidate cold B | Candidate warm B | Candidate no-op B | Fresh/warm | Cold/warm |
|---|---:|---:|---:|---:|---:|---:|
| lexer | 5.302 s | 5.087 s | 2.774 s | 2.386 s | 1.91× | 1.83× |
| coverage-map-churn-128 | 7.187 s | 6.470 s | 2.768 s | 2.759 s | 2.60× | 2.34× |

Both revisions use the same logical source filename. Lexer changes `prng` shift constant13 to12; Map changes `p37.map.update` multiplication constant31 to29. These are actual body changes, not a renamed local output register. Hints are absolute UTF16 offsets computed as `f_source_end(seed.source) + editOffset`; checked Bend derives the parser checkpoint and checker cut itself.

Each timed request includes compilation, registry preparation, rendering, assembling the complete output bytes, hashing and writing a separate complete QBE file. The authenticated Base seed is prepared once and its acquisition is reported separately. Cold means an empty candidate session/cache under an already loaded API and Base seed, not a cold process. No timing includes machine assembly, linking or executing the generated program.

The complete correctness/timing screen took 71.95 seconds with 845 MB sampled process-tree RSS on CPU3. These are single ordered hosted observations, not balanced native benchmarks or statistically qualified speedup claims. In particular, the apparently faster candidate cold path can reflect JIT/order effects. Do not substitute the warm metric for incumbent fresh compilation without labeling the retained state and acquisition cost.

## Remaining work visible in the screen

The warm compile stage remains2.361s for Lexer and1.923s for Map. Registry preparation still takes0.264s and0.519s despite298/299 and547/555 plan hits. Rendering takes0.142s and0.312s. Exact comparisons, metadata preparation and cache retention still cost real work. Map no-op still has four registry and one rendered-unit misses, consistent with conservative refusal; a high hit count alone does not prove eliminated end-to-end cost.

The isolated owner screen had a Lexer raw-stage regression; the integrated Lexer result demonstrates that other stages can still make the complete request cheaper. It does not remove that negative evidence or establish full compiler scalability. Next gates should use a real native compiler edit, charge acquisition and memory, compare exact fresh output, and preserve the existing final verifier.

## Reproduction

Run only on the root-authorized free timing lane with a fresh output and guard path:

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase140/session-screen02-guard --seconds 180 \
  --rss-mib 3072 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  selfhost/.bootstrap/bun-1.4.3/bun \
  selfhost/tools/performance/phase140/session/screen-v01.mjs \
  selfhost/build/phase111/p140-session-api03/report.json \
  selfhost/build/phase140/session-screen02
```

Optional trailing case names select from the frozen Lexer, Map and closures cases. The default screen runs Lexer and Map. The script is host orchestration and exact evidence comparison only; the parser, checker, dependency analysis, cache decisions, transformations and emission all execute the checked Bend API.
