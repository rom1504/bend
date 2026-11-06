# Native route for the Phase168 import-seeded compiler

Source-only preparation at parent `4a47e78`. No compiler or generated target was
executed in this lane. The qualified Phase152 image, runtime and source remain
unchanged. The new files are `selfhost/tests/phase169/streaming.bend`,
`native-entry.bend`, and `tools/prepare-native.py`.

## Exact experimental boundary

`p169s_plan(P86Plan) -> P169Prepared` uses the Phase168 selective scalar producer,
unchanged actual private-program verification, authenticated adapter-public copy,
and unchanged public/borrowed verification. It then uses the same real import
forwarders, seeded region discovery, full fusion index, live eligibility, static
tables and maintained `p134e_registered` cursor as `p168j_plan(1,plan)`.

The only emission change is when text is rendered. `P169Prepared` retains the
small forwarder prefix, actual cursor and error. The native writer opens one
File, writes prefix chunks with their original trailing newlines, then delegates
to existing `p134w_drain`. It never first collects the full compiler QBE text.
One File also avoids mixing buffered `IO.print` with descriptor `File.write`,
which could otherwise reorder prefix and body. File failure closes the handle
and returns the original IO failure. The existing cursor writer handles the
remaining errors and final close.

`p169s_collect_plan` is a hosted equality control: it deliberately materializes
the old exact chunk list. Compare it with retained Phase168 output; no semantic
compiler algorithm belongs in the host harness. Two pure `p169s_controls` rows
check error propagation and refusal to emit an error-bearing prefix/cursor.

The native entry is the Phase164 six-string live/cache request chain with new
names and the new prepared result. Source checking, authenticated Base preparation,
runtime admission and output protocol are unchanged. It intentionally excludes
session/batch commands. The direct worker admission remains a checked DAG with
explicit tail loops; other recursion retains the existing generic continuation
fallback. No machine recursion allowance or depth limit is raised.

## Preparation and acquisition

From the repository root, source extraction only:

```sh
python3 -B experiments/phase169/tools/prepare-native.py --api --out selfhost/build/phase169/api-source01
python3 -B experiments/phase169/tools/prepare-native.py --out selfhost/build/phase169/native-source01
```

The extractor authenticates the maintained parent and records the two existing
experimental overrides, `p168_closed` and `p168v_prepare`; no production
declaration is replaced. `--api` includes the old 68 control exports, baseline
`p134e_plan/begin/next`, and the streaming/collection comparison entries. Normal
native extraction exports only `main`, so the added control exports do not
increase that dependency closure.

Root must wrap every following execution in the maintained disk/process guard,
with a fresh output root, CPU3, one runtime thread, GPU off and the normal 5GiB
reserve. The established N1 acquisition payload is:

```sh
python3 -B selfhost/tools/build/native.py --assets selfhost/manifests/assets-native.json --host native --stage N2 --target qbe --mode cache --image selfhost/build/phase152/native-n2/program --image-receipt selfhost/build/phase152/native-n2/report.json --source selfhost/build/phase169/native-source01/compiler.bend --out selfhost/build/phase169/native-n1 --seconds 420 --output-stage N1-P169-imports
```

This uses the explicit qualified Phase152 producer, not the older `qbe-n2` asset
key. The resulting receipt binds the candidate to its source, linked runtime,
Base policy and `qbe-source-v1` protocol. For subsequent `native.py` requests use
that image/receipt and its exact recorded stage `N1-P169-imports`. The same tool
pipes emission into QBE through its bounded relay, then assembles and links; its
whole pipeline clock is the appropriate complete-build metric.

## Three different full-build questions

1. **Matched canonical throughput:** run both the qualified producer and candidate
   on `selfhost/build/phase152/production-source02/compiler.bend`, exactly
   3,085,157 bytes / SHA256 `027e15041035522ed7e40ef971eff75f24a09ef6a00e3f8fe335839f94bcb8a8`.
   Keep the same Base/carrier/runtime/toolchain and complete machine-build clock.
   This is the appropriate input for comparing with the historical 249.222s
   observation; a fresh matched baseline is preferable.
2. **Actual successor construction:** N1 compiles the identical Phase169 native
   source used to acquire N1, producing N2 with the same experimental main.
   A canonical-source product contains the canonical main, so it is not a
   Phase169 successor even when the candidate compiled it.
3. **Self-reproduction:** N2 emits that identical experimental source and its
   complete stream matches N1's output hash. The existing
   `experiments/phase164/tools/self-emission.py --build N2_REPORT --out FRESH`
   already authenticates this relation and hashes the stream without retaining
   another large QBE file. Its clock excludes machine construction.

The extracted experimental source is expected to be smaller than the canonical
input and has a narrower CLI. Do not describe its smaller-input self-build as a
249-to-X speedup or a newly qualified replacement.

## Compatibility and stop conditions

Phase168 has full value controls and a 20,000-depth recursion/closure test, but
not full native self-hosting. The first real larger request may expose conservative
refusals: source observer permission, a nonclosed early worker needing a real
function ID, an unknown demanded identity, or final actual-ID/adapter verification.
Preserve such diagnostics; neither fabricated IDs nor a relaxed verifier is an
acceptable acquisition fix. The runtime's 16MiB source-reader boundary is well
above these inputs. All intermediate IR, cached plans and region discovery still
consume real memory even though final text collection is removed.

First source-check the API and native entry; run the 68 old controls plus two new
error controls and exact retained-output equality. Then acquire one native image,
check a small complete source-to-QBE request against the independent hosted
product, and only then pay for canonical full throughput and self-source gates.
Do not infer full compiler execution quality or a <=150s result from the Phase168
hosted slice ratios. This preparation supplies a usable route to measure them.
