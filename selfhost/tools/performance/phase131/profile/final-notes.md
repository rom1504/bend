# Final N2 profile refresh

Pending metadata recipe; no new target results are implied. Reuse the same three
requests, compact Base, exact whole-QBE output oracles, sampler and authenticated
libc unwind table from Phase131 `profile01`. Preserve old profiles separately.
The final N2 has different compiler source and code generation; do not pool its
samples with Phase130, FAST, final N1 or the diagnostic image.

After `final-parent-timing01.json` has been generated from actual final N1/N2
builds and focused19 gates:

```sh
taskset -c 1 python3 -B selfhost/tools/performance/phase131/profile/prepare-final.py prepare \
  --timing-manifest selfhost/build/phase131/final-parent-timing01.json \
  --physical selfhost/build/phase131/final-profile01 \
  --context selfhost/build/phase131/final-context01
```

This prepares physical capture jobs, a one-job diagnostic relink plan, and a new
QBE owner map. It executes no compiler, generated program or machine build. The
only subprocess extracts metadata from the actual N2 input QBE. Exact linked
FID matching remains mandatory during attribution; ownership is conditional
lexical grouping, not a logical stack or source-line provenance.

The root's controlled lane can execute `final-profile01/jobs.json`. It can also
run the existing runtime builder on the new plan, under its ordinary guard:

```sh
python3 -B selfhost/tools/profiler/build-runtime.py \
  --plan selfhost/build/phase131/final-context01/runtime/plan.json \
  --out selfhost/build/phase131/final-context01/build
```

This links actual final N2 `program.o` against the already built diagnostic
`context01/runtime/runtime.o` (SHA `8c582501c5e5c06ed1503c4cbaa73f82da7c72b8cfdd668023c65122d7dbb3a6`).
The preparer authenticates its source/header contents, reversible instrumentation
plan and actual successful build. It does not compile another diagnostic runtime.
The original controls and their scope remain applicable to that exact runtime;
this new plan is link-only and should not be supplied to a control tool requiring
a runtime compilation job.

After the real relink succeeds, repeat the first command with `seal` in place of
`prepare`. Then `final-context01/jobs.json` schedules context-only clean/sample
observations and separate counter-enabled observations. All observations must
match the pre-existing complete QBE output and empty stderr. An oracle mismatch
is a failed capture; do not silently replace the oracle with final output.

The plans retain 8 pairs of 8/13ms samples for closures and 2 pairs for the other
requests. This is a starting budget, not a guarantee of 500 accepted samples.
Keep loss/overrun, physical caller, source/object identity, output and CPU-window
gates. Report insufficient sample counts rather than inflating their confidence.
Context-only and counter-enabled overhead must remain separate.

For offline active owners and event counts, reuse:

```sh
taskset -c 1 python3 -B selfhost/tools/performance/phase129/summarize-context.py \
  --capture selfhost/build/phase131/final-context01 \
  --out selfhost/build/phase131/final-context-analysis01
```

Use generic `compare.py` with baseline mapping
`phase131-final-n2-context=phase131-final-n2`, not the old Phase131 summary wrapper
which hardcodes Phase130 identities. Physical leaves and dispatch context shares
are overlapping measurements and must not be added.

The useful questions are now:

- How much sampled CPU remains in `nc_bangs_names`, `nc_bangs_names_loop` and
  associated graph/name traversal, versus checking, raw closure and verification?
- How much remains in QBE emission, string concatenation/printing, source parsing
  and input/carrier materialization? Use actual owner names from the map, then
  inspect the relevant physical leaves.
- Which owner contexts still dominate runtime allocation, taking, dropping,
  reclamation and scheduler/register traffic? Compare absolute counter totals as
  well as period-weighted sample fractions and clean request CPU.

`entrySegmentDispatches` counts actual direct/factory dispatch entries. It cannot
count every source call, private synchronous worker invocation, or repeated
identical `nc_bangs_names` query key. Active-owner costs may include private callees.
Therefore these profiles can identify remaining hot computation families and
suggest reuse opportunities, but cannot alone establish redundant-query counts
or an inclusive call graph. No new profiler instrumentation is added here.

The manifests keep final N2 explicitly experimental, even if N3 qualification
later succeeds. Cite that independent qualification separately. This bounded
survey ranks remaining compilation work; it does not measure broad generated
program performance or full compiler self-build performance.
